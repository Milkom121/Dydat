import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import * as helmet from 'helmet';
import * as compression from 'compression';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { CustomValidationPipe } from './common/pipes/validation.pipe';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  
  try {
    const app = await NestFactory.create(AppModule, {
      logger: process.env.NODE_ENV === 'production' 
        ? ['error', 'warn', 'log'] 
        : ['error', 'warn', 'log', 'debug', 'verbose'],
    });

    // Trust proxy per correct IP detection dietro load balancer
    app.set('trust proxy', 1);

    // Security middleware
    app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", "data:", "https:"],
          fontSrc: ["'self'"],
          connectSrc: ["'self'"],
          frameSrc: ["'none'"],
        },
      },
      crossOriginEmbedderPolicy: false, // Necessario per alcuni use cases
      crossOriginResourcePolicy: { policy: "cross-origin" },
    }));

    // Compression per performance
    app.use(compression({
      level: 6, // Bilancia compression ratio vs CPU usage
      threshold: 1024, // Comprimi solo file > 1KB
      filter: (req, res) => {
        // Non comprimere se client non lo supporta
        if (req.headers['x-no-compression']) {
          return false;
        }
        // Usa default compression filter
        return compression.filter(req, res);
      },
    }));

    // CORS configuration
    const corsOrigins = process.env.NODE_ENV === 'production'
      ? [
          'https://dydat.com',
          'https://www.dydat.com',
          'https://app.dydat.com',
          'https://dashboard.dydat.com',
        ]
      : [
          'http://localhost:3000',
          'http://localhost:3001',
          'http://127.0.0.1:3000',
        ];

    app.enableCors({
      origin: corsOrigins,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: [
        'Content-Type',
        'Authorization',
        'X-Requested-With',
        'Accept',
        'Origin',
        'User-Agent',
      ],
      credentials: true,
      maxAge: 86400, // 24 ore per preflight cache
    });

    // Global filters
    app.useGlobalFilters(new GlobalExceptionFilter());

    // Global interceptors
    app.useGlobalInterceptors(new LoggingInterceptor());

    // Global pipes
    app.useGlobalPipes(new CustomValidationPipe());

    // API prefix
    app.setGlobalPrefix('api', {
      exclude: ['health', '/'], // Exclude health check from prefix
    });

    // Health check endpoint semplice
    app.getHttpAdapter().get('/health', (req, res) => {
      res.status(200).json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV,
        version: process.env.npm_package_version || '1.0.0',
      });
    });

    // Graceful shutdown handling
    process.on('SIGTERM', async () => {
      logger.log('SIGTERM received, shutting down gracefully...');
      await app.close();
      process.exit(0);
    });

    process.on('SIGINT', async () => {
      logger.log('SIGINT received, shutting down gracefully...');
      await app.close();
      process.exit(0);
    });

    // Gestione uncaught exceptions
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });

    process.on('unhandledRejection', (reason, promise) => {
      logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
      process.exit(1);
    });

    const port = process.env.PORT || 3001;
    await app.listen(port, '0.0.0.0');

    logger.log(`🚀 Application is running on: http://0.0.0.0:${port}`);
    logger.log(`🔒 Security middleware enabled`);
    logger.log(`📊 Logging and monitoring active`);
    logger.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    logger.log(`🔧 CORS origins: ${corsOrigins.join(', ')}`);

  } catch (error) {
    logger.error('Failed to start application:', error);
    process.exit(1);
  }
}

bootstrap();
