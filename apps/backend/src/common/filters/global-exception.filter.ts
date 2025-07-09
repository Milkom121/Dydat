import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { QueryFailedError } from 'typeorm';

interface ErrorResponse {
  statusCode: number;
  timestamp: string;
  path: string;
  method: string;
  message: string;
  error?: string;
  details?: any;
}

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionFilter');

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const errorResponse = this.buildErrorResponse(exception, request);
    
    // Log dell'errore con context per debugging
    this.logError(exception, request, errorResponse);

    response.status(errorResponse.statusCode).json(errorResponse);
  }

  private buildErrorResponse(exception: unknown, request: Request): ErrorResponse {
    const timestamp = new Date().toISOString();
    const path = request.url;
    const method = request.method;

    // Gestione HttpException (errori NestJS)
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      
      return {
        statusCode: status,
        timestamp,
        path,
        method,
        message: this.getHttpExceptionMessage(exceptionResponse),
        error: exception.name,
        details: typeof exceptionResponse === 'object' ? exceptionResponse : undefined,
      };
    }

    // Gestione errori database TypeORM
    if (exception instanceof QueryFailedError) {
      return this.handleDatabaseError(exception, { timestamp, path, method });
    }

    // Gestione errori generici
    if (exception instanceof Error) {
      return {
        statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
        timestamp,
        path,
        method,
        message: this.isProduction() 
          ? 'Errore interno del server' 
          : exception.message,
        error: 'InternalServerError',
      };
    }

    // Fallback per errori sconosciuti
    return {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      timestamp,
      path,
      method,
      message: 'Si è verificato un errore imprevisto',
      error: 'UnknownError',
    };
  }

  private getHttpExceptionMessage(exceptionResponse: any): string {
    if (typeof exceptionResponse === 'string') {
      return exceptionResponse;
    }
    
    if (exceptionResponse.message) {
      return Array.isArray(exceptionResponse.message) 
        ? exceptionResponse.message.join(', ')
        : exceptionResponse.message;
    }
    
    return exceptionResponse.error || 'Errore HTTP';
  }

  private handleDatabaseError(
    error: QueryFailedError,
    context: { timestamp: string; path: string; method: string }
  ): ErrorResponse {
    const { timestamp, path, method } = context;
    
    // Errori PostgreSQL comuni
    const pgError = error as any;
    
    switch (pgError.code) {
      case '23505': // unique_violation
        return {
          statusCode: HttpStatus.CONFLICT,
          timestamp,
          path,
          method,
          message: 'Risorsa già esistente (violazione vincolo univocità)',
          error: 'ConflictError',
        };
        
      case '23503': // foreign_key_violation
        return {
          statusCode: HttpStatus.BAD_REQUEST,
          timestamp,
          path,
          method,
          message: 'Riferimento non valido (violazione chiave esterna)',
          error: 'ReferenceError',
        };
        
      case '23502': // not_null_violation
        return {
          statusCode: HttpStatus.BAD_REQUEST,
          timestamp,
          path,
          method,
          message: 'Campo obbligatorio mancante',
          error: 'ValidationError',
        };
        
      case '42P01': // undefined_table
        return {
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          timestamp,
          path,
          method,
          message: 'Errore di configurazione database',
          error: 'DatabaseConfigError',
        };
        
      default:
        return {
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          timestamp,
          path,
          method,
          message: this.isProduction() 
            ? 'Errore database' 
            : `Database Error: ${error.message}`,
          error: 'DatabaseError',
        };
    }
  }

  private logError(exception: unknown, request: Request, errorResponse: ErrorResponse): void {
    const { statusCode, path, method } = errorResponse;
    const userAgent = request.get('User-Agent');
    const ip = this.getClientIp(request);
    const userId = (request.user as any)?.id;
    const userRole = (request.user as any)?.role;

    const logContext = {
      statusCode,
      path,
      method,
      userAgent,
      ip,
      userId,
      userRole,
      timestamp: errorResponse.timestamp,
    };

    if (statusCode >= 500) {
      // Errori server - priorità alta
      this.logger.error({
        message: `Server Error: ${method} ${path} - ${statusCode}`,
        exception: exception instanceof Error ? exception.message : 'Unknown error',
        stack: exception instanceof Error ? exception.stack : undefined,
        ...logContext,
        severity: 'HIGH',
        type: 'SERVER_ERROR',
      });
    } else if (statusCode === 401 || statusCode === 403) {
      // Errori di autenticazione/autorizzazione - security audit
      this.logger.warn({
        message: `Security: ${method} ${path} - ${statusCode}`,
        ...logContext,
        type: 'SECURITY_AUDIT',
        incidentType: statusCode === 401 ? 'UNAUTHORIZED' : 'FORBIDDEN',
      });
    } else if (statusCode >= 400) {
      // Altri errori client
      this.logger.warn({
        message: `Client Error: ${method} ${path} - ${statusCode}`,
        ...logContext,
        type: 'CLIENT_ERROR',
      });
    }

    // Log speciale per tentativi di accesso sospetti
    if (this.isSuspiciousRequest(request, errorResponse)) {
      this.logger.error({
        message: 'SUSPICIOUS ACTIVITY DETECTED',
        ...logContext,
        suspiciousIndicators: this.getSuspiciousIndicators(request, errorResponse),
        severity: 'CRITICAL',
        type: 'SECURITY_ALERT',
      });
    }
  }

  private getClientIp(request: Request): string {
    return (
      request.headers['x-forwarded-for'] as string ||
      request.headers['x-real-ip'] as string ||
      request.connection.remoteAddress ||
      request.socket.remoteAddress ||
      'unknown'
    );
  }

  private isProduction(): boolean {
    return process.env.NODE_ENV === 'production';
  }

  private isSuspiciousRequest(request: Request, errorResponse: ErrorResponse): boolean {
    const { statusCode, path } = errorResponse;
    
    // Tentativi ripetuti su endpoint sensibili
    if ((statusCode === 401 || statusCode === 403) && this.isSensitiveEndpoint(path)) {
      return true;
    }
    
    // Richieste a endpoint inesistenti con pattern sospetti
    if (statusCode === 404 && this.hasAttackPattern(path)) {
      return true;
    }
    
    // User-Agent sospetti
    const userAgent = request.get('User-Agent')?.toLowerCase() || '';
    if (this.isSuspiciousUserAgent(userAgent)) {
      return true;
    }
    
    return false;
  }

  private getSuspiciousIndicators(request: Request, errorResponse: ErrorResponse): string[] {
    const indicators: string[] = [];
    const { statusCode, path } = errorResponse;
    const userAgent = request.get('User-Agent')?.toLowerCase() || '';
    
    if ((statusCode === 401 || statusCode === 403) && this.isSensitiveEndpoint(path)) {
      indicators.push('REPEATED_AUTH_FAILURE');
    }
    
    if (this.hasAttackPattern(path)) {
      indicators.push('ATTACK_PATTERN_DETECTED');
    }
    
    if (this.isSuspiciousUserAgent(userAgent)) {
      indicators.push('SUSPICIOUS_USER_AGENT');
    }
    
    return indicators;
  }

  private isSensitiveEndpoint(path: string): boolean {
    const sensitivePatterns = ['/auth/', '/admin/', '/user/', '/password'];
    return sensitivePatterns.some(pattern => path.includes(pattern));
  }

  private hasAttackPattern(path: string): boolean {
    const attackPatterns = [
      'admin', 'wp-admin', 'login.php', '.env', 'config',
      'phpmyadmin', 'sql', 'database', '.git', 'backup',
      '../', '..\\', '<script', 'union select', 'drop table'
    ];
    
    const pathLower = path.toLowerCase();
    return attackPatterns.some(pattern => pathLower.includes(pattern));
  }

  private isSuspiciousUserAgent(userAgent: string): boolean {
    const suspiciousPatterns = [
      'bot', 'crawler', 'spider', 'scraper', 'curl', 'wget',
      'postman', 'insomnia', 'burp', 'sqlmap', 'nikto'
    ];
    
    return suspiciousPatterns.some(pattern => userAgent.includes(pattern));
  }
} 