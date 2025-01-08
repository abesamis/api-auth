import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.set('trust proxy', 1); // Trust Google Cloud Run proxy
  await app.listen(process.env.PORT ?? 8080);
}
bootstrap();
