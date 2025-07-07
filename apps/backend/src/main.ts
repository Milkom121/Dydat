import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Abilita la validazione globale
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true, // Rimuove automaticamente proprietà non definite nei DTO
    forbidNonWhitelisted: true, // Restituisce errore se ci sono proprietà extra
    transform: true, // Trasforma automaticamente i tipi
  }));

  // Abilita CORS per il frontend
  app.enableCors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    credentials: true,
  });

  const port = process.env.PORT ?? 3001;
  await app.listen(port);
  console.log(`🚀 Backend running on http://localhost:${port}`);
}
bootstrap();
