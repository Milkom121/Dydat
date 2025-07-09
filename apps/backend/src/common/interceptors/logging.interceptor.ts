import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { Request, Response } from 'express';

interface LogContext {
  method: string;
  url: string;
  userAgent?: string;
  ip: string;
  userId?: string;
  userRole?: string;
  statusCode?: number;
  responseTime: number;
  error?: string;
  timestamp: string;
}

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<Request>();
    const response = context.switchToHttp().getResponse<Response>();
    const startTime = Date.now();

    const logContext: LogContext = {
      method: request.method,
      url: request.url,
      userAgent: request.get('User-Agent'),
      ip: this.getClientIp(request),
      userId: (request.user as any)?.id,
      userRole: (request.user as any)?.role,
      responseTime: 0,
      timestamp: new Date().toISOString(),
    };

    return next.handle().pipe(
      tap(() => {
        logContext.responseTime = Date.now() - startTime;
        logContext.statusCode = response.statusCode;
        
        this.logRequest(logContext);
      }),
      catchError((error) => {
        logContext.responseTime = Date.now() - startTime;
        logContext.statusCode = response.statusCode || 500;
        logContext.error = error.message;
        
        this.logError(logContext, error);
        throw error;
      }),
    );
  }

  private logRequest(context: LogContext) {
    const { method, url, statusCode, responseTime, userId, userRole } = context;
    
    if (this.isSensitiveEndpoint(url)) {
      // Log dettagliato per endpoint di sicurezza
      this.logger.log({
        message: `${method} ${url} - ${statusCode} (${responseTime}ms)`,
        ...context,
        type: 'SECURITY_AUDIT',
      });
    } else if (statusCode >= 400) {
      // Log warning per errori client
      this.logger.warn({
        message: `${method} ${url} - ${statusCode} (${responseTime}ms)`,
        ...context,
        type: 'CLIENT_ERROR',
      });
    } else {
      // Log normale per richieste standard
      this.logger.log(
        `${method} ${url} - ${statusCode} (${responseTime}ms) ${userId ? `[User: ${userId}/${userRole}]` : '[Anonymous]'}`,
      );
    }
  }

  private logError(context: LogContext, error: any) {
    const { method, url, statusCode, responseTime, userId } = context;
    
    this.logger.error({
      message: `${method} ${url} - ${statusCode} (${responseTime}ms) - ERROR`,
      ...context,
      errorStack: error.stack,
      type: 'APPLICATION_ERROR',
    });

    // Log speciale per errori di sicurezza
    if (this.isSecurityError(error)) {
      this.logger.error({
        message: 'SECURITY INCIDENT DETECTED',
        ...context,
        incidentType: this.classifySecurityIncident(error),
        severity: 'HIGH',
        type: 'SECURITY_INCIDENT',
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

  private isSensitiveEndpoint(url: string): boolean {
    const sensitivePatterns = [
      '/auth/',
      '/login',
      '/register',
      '/admin/',
      '/password',
      '/user/',
    ];
    
    return sensitivePatterns.some(pattern => url.includes(pattern));
  }

  private isSecurityError(error: any): boolean {
    const securityKeywords = [
      'unauthorized',
      'forbidden',
      'authentication',
      'permission',
      'token',
      'jwt',
      'credential',
    ];
    
    const errorMessage = error.message?.toLowerCase() || '';
    return securityKeywords.some(keyword => errorMessage.includes(keyword));
  }

  private classifySecurityIncident(error: any): string {
    const message = error.message?.toLowerCase() || '';
    
    if (message.includes('token')) return 'INVALID_TOKEN';
    if (message.includes('unauthorized')) return 'UNAUTHORIZED_ACCESS';
    if (message.includes('forbidden')) return 'FORBIDDEN_ACCESS';
    if (message.includes('authentication')) return 'AUTHENTICATION_FAILURE';
    if (message.includes('permission')) return 'PERMISSION_DENIED';
    
    return 'UNKNOWN_SECURITY_ERROR';
  }
} 