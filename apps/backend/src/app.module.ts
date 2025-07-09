import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { User } from './auth/entities/user.entity';
import { CustomThrottlerGuard } from './common/guards/throttler.guard';

@Module({
  imports: [
    // Rate Limiting Configuration
    ThrottlerModule.forRootAsync({
      useFactory: () => ({
        throttlers: [
          {
            name: 'short',
            ttl: 1000, // 1 secondo
            limit: 10, // 10 richieste per secondo (burst protection)
          },
          {
            name: 'medium',
            ttl: 60000, // 1 minuto  
            limit: 100, // 100 richieste per minuto
          },
          {
            name: 'long',
            ttl: 900000, // 15 minuti
            limit: 500, // 500 richieste per 15 minuti
          },
        ],
        // Configurazioni avanzate
        ignoreUserAgents: [
          /googlebot/gi,
          /bingbot/gi,
          /health-check/gi,
        ],
        skipIf: (context) => {
          const request = context.switchToHttp().getRequest();
          // Skip rate limiting per health checks
          return request.url === '/health' || request.url === '/api/health';
        },
      }),
    }),

    // Database Configuration
    TypeOrmModule.forRootAsync({
      useFactory: () => {
        const isProduction = process.env.NODE_ENV === 'production';
        
        return {
          type: 'postgres',
          host: process.env.DB_HOST || 'localhost',
          port: parseInt(process.env.DB_PORT || '5432', 10),
          username: process.env.DB_USERNAME || 'postgres',
          password: process.env.DB_PASSWORD || 'postgres',
          database: process.env.DB_NAME || 'dydat_dev',
          entities: [User], // Entità utente per il sistema di autenticazione
          
          // Configurazione migrazioni
          synchronize: false, // Mai usare true in produzione - usiamo migrazioni
          migrationsRun: isProduction, // Auto-run migrazioni solo in produzione
          migrations: ['dist/database/migrations/*.js'], // Path compilato
          migrationsTableName: 'dydat_migrations',
          
          // Configurazioni di connessione
          logging: !isProduction ? ['query', 'error', 'warn'] : ['error'], // Log dettagliato in dev
          ssl: isProduction ? { rejectUnauthorized: false } : false, // SSL per Aurora in produzione
          retryAttempts: 3,
          retryDelay: 3000,
          autoLoadEntities: true,
          
          // Pool di connessioni per performance
          extra: {
            max: isProduction ? 20 : 5, // Pool size massimo
            min: 2, // Pool size minimo
            acquire: 30000, // Timeout acquisizione connessione
            idle: 10000, // Timeout idle connessione
            evict: 60000, // Timeout per eviction delle connessioni inattive
          },

          // Configurazioni cache query per performance
          cache: isProduction ? {
            type: 'database',
            tableName: 'dydat_query_cache',
            duration: 30000, // 30 secondi di cache
          } : false,
        };
      },
    }),

    AuthModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    // Registro il CustomThrottlerGuard globalmente
    {
      provide: APP_GUARD,
      useClass: CustomThrottlerGuard,
    },
  ],
})
export class AppModule {}
