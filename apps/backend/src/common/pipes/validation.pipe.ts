import {
  PipeTransform,
  Injectable,
  ArgumentMetadata,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';

@Injectable()
export class CustomValidationPipe implements PipeTransform<any> {
  private readonly logger = new Logger('ValidationPipe');

  async transform(value: any, { metatype }: ArgumentMetadata) {
    if (!metatype || !this.toValidate(metatype)) {
      return this.sanitizeInput(value);
    }

    // Sanitizza i dati prima della validazione
    const sanitizedValue = this.sanitizeInput(value);
    
    // Security checks prima della validazione
    this.performSecurityChecks(sanitizedValue);

    const object = plainToClass(metatype, sanitizedValue);
    const errors = await validate(object, {
      whitelist: true, // Rimuove proprietà non definite nei DTO
      forbidNonWhitelisted: true, // Lancia errore per proprietà extra
      transform: true, // Trasforma automaticamente i tipi
      disableErrorMessages: process.env.NODE_ENV === 'production', // Nasconde dettagli in produzione
    });

    if (errors.length > 0) {
      // Log tentativi di validation failure per security audit
      this.logger.warn({
        message: 'Validation failed',
        errors: errors.map(error => ({
          property: error.property,
          constraints: error.constraints,
          value: error.value,
        })),
        type: 'VALIDATION_FAILURE',
      });

      const errorMessages = this.formatErrors(errors);
      throw new BadRequestException({
        message: 'Dati di input non validi',
        errors: errorMessages,
      });
    }

    return object;
  }

  private toValidate(metatype: Function): boolean {
    const types: Function[] = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype);
  }

  private sanitizeInput(value: any): any {
    if (value === null || value === undefined) {
      return value;
    }

    if (typeof value === 'string') {
      return this.sanitizeString(value);
    }

    if (Array.isArray(value)) {
      return value.map(item => this.sanitizeInput(item));
    }

    if (typeof value === 'object') {
      const sanitized = {};
      for (const key in value) {
        if (value.hasOwnProperty(key)) {
          sanitized[this.sanitizeString(key)] = this.sanitizeInput(value[key]);
        }
      }
      return sanitized;
    }

    return value;
  }

  private sanitizeString(input: string): string {
    if (typeof input !== 'string') {
      return input;
    }

    return input
      .trim() // Rimuove spazi all'inizio e alla fine
      .replace(/[\0\x08\x09\x1a\n\r"'\\\%]/g, '') // Rimuove caratteri pericolosi
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '') // Rimuove script tags
      .replace(/javascript:/gi, '') // Rimuove javascript: protocols
      .replace(/on\w+\s*=/gi, '') // Rimuove event handlers
      .substring(0, 10000); // Limita lunghezza massima
  }

  private performSecurityChecks(value: any): void {
    if (typeof value === 'string') {
      this.checkForSQLInjection(value);
      this.checkForXSS(value);
      this.checkForPathTraversal(value);
    }

    if (typeof value === 'object' && value !== null) {
      Object.values(value).forEach(val => {
        if (typeof val === 'string') {
          this.checkForSQLInjection(val);
          this.checkForXSS(val);
          this.checkForPathTraversal(val);
        }
      });
    }
  }

  private checkForSQLInjection(input: string): void {
    const sqlPatterns = [
      /(\bunion\b.*\bselect\b)/i,
      /(\bdrop\b.*\btable\b)/i,
      /(\bdelete\b.*\bfrom\b)/i,
      /(\binsert\b.*\binto\b)/i,
      /(\bupdate\b.*\bset\b)/i,
      /(\bexec\b|\bexecute\b)/i,
      /('|\"|;|--|\/\*|\*\/)/,
      /(\bor\b.*=.*\bor\b)/i,
      /(\band\b.*=.*\band\b)/i,
    ];

    if (sqlPatterns.some(pattern => pattern.test(input))) {
      this.logger.error({
        message: 'SQL Injection attempt detected',
        input: input.substring(0, 100), // Log solo i primi 100 caratteri
        type: 'SECURITY_ALERT',
        severity: 'CRITICAL',
      });

      throw new BadRequestException('Input non valido rilevato');
    }
  }

  private checkForXSS(input: string): void {
    const xssPatterns = [
      /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi,
      /<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi,
      /javascript:/gi,
      /on\w+\s*=/gi,
      /<img[^>]+src[^>]*>/gi,
      /<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>/gi,
      /<embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed>/gi,
    ];

    if (xssPatterns.some(pattern => pattern.test(input))) {
      this.logger.error({
        message: 'XSS attempt detected',
        input: input.substring(0, 100),
        type: 'SECURITY_ALERT',
        severity: 'HIGH',
      });

      throw new BadRequestException('Contenuto non sicuro rilevato');
    }
  }

  private checkForPathTraversal(input: string): void {
    const pathTraversalPatterns = [
      /\.\./,
      /\.\.\\/,
      /\.\.\/\//,
      /\%2e\%2e/i,
      /\%2f/i,
      /\%5c/i,
    ];

    if (pathTraversalPatterns.some(pattern => pattern.test(input))) {
      this.logger.error({
        message: 'Path traversal attempt detected',
        input: input.substring(0, 100),
        type: 'SECURITY_ALERT',
        severity: 'HIGH',
      });

      throw new BadRequestException('Percorso non valido rilevato');
    }
  }

  private formatErrors(errors: any[]): string[] {
    return errors.map(error => {
      const constraints = Object.values(error.constraints || {});
      return `${error.property}: ${constraints.join(', ')}`;
    });
  }
} 