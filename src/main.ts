import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import loggerService from "./logger.service";
import { ValidationPipe } from "@nestjs/common";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: loggerService,
  });
  app.useGlobalPipes(new ValidationPipe()); // Enable global validation pipe
  const port = process.env.PORT || 3000; // Use the PORT environment variable if set, or default to 3000
  // Enable CORS
  app.enableCors();
  await app.listen(port);
  const url = await app.getUrl();
  console.log(`NestJS application is running on ${url}`);
}
bootstrap();
