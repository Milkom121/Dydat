import { Injectable, ExecutionContext } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { Request } from 'express';

@Injectable()
export class CustomThrottlerGuard extends ThrottlerGuard {
  protected async getTracker(req: Request): Promise<string> {
    // Usa IP + User-Agent per tracking più accurato
    const userAgent = req.get('User-Agent') || 'unknown';
    const ip = req.ip || req.connection.remoteAddress || 'unknown';
    
    return `${ip}_${this.hashString(userAgent)}`;
  }

  protected getErrorMessage(): string {
    return 'Troppi tentativi. Riprova tra qualche minuto.';
  }

  private hashString(str: string): string {
    // Simple hash per User-Agent
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash).toString();
  }

  protected async shouldSkip(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request>();
    
    // Skip rate limiting per health check endpoints
    if (request.url === '/health' || request.url === '/api/health') {
      return true;
    }

    // Skip per utenti admin autenticati (optional)
    const user = request.user as any;
    if (user && user.role === 'ADMIN') {
      return true;
    }

    return false;
  }
} 