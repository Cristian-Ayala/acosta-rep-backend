import { LoggerService as LS } from "@nestjs/common";
import * as winston from "winston";
import * as winstonDailyRotateFile from "winston-daily-rotate-file";

class LoggerService implements LS {
  private logger: winston.Logger;

  constructor() {
    this.logger = winston.createLogger({
      level: "info",
      defaultMeta: { service: "user-service" },
      transports: [
        // log errors has its own file
        new winstonDailyRotateFile({
          filename: `src/KEEP_TRACK/logs/%DATE%-error.log`,
          level: "error",
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.json(),
          ),
          datePattern: "YYYY-MM-DD",
          zippedArchive: false,
          maxFiles: "365d",
          maxSize: "5m", // Maximum size of the file after which it will rotate 5MB
        }),
        // log info has its own file
        new winstonDailyRotateFile({
          filename: `src/KEEP_TRACK/logs/%DATE%-info.log`,
          level: "info",
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.json(),
          ),
          datePattern: "YYYY-MM-DD",
          zippedArchive: false,
          maxFiles: "365d",
          maxSize: "5m", // Maximum size of the file after which it will rotate 5MB
        }),
        // logging all levels
        new winstonDailyRotateFile({
          filename: `src/KEEP_TRACK/logs/%DATE%-combined.log`,
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.json(),
          ),
          datePattern: "YYYY-MM-DD",
          zippedArchive: false,
          maxFiles: "365d",
          maxSize: "5m", // Maximum size of the file after which it will rotate 5MB
        }),
        // log in console
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.cli(),
            winston.format.splat(),
            winston.format.timestamp(),
            winston.format.printf((info) => {
              return `${info.timestamp} ${info.level}: ${info.message}`;
            }),
          ),
        }),
      ],
    });

    console.log = (message: any, params?: any) => {
      this.logger.debug(message, params);
    };
  }

  log(message: string) {
    this.logger.info(message);
    console.log(message); // Print to console
  }

  error(message: string, trace: string) {
    this.logger.error(message, trace);
    console.error(message, trace); // Print to console
  }

  warn(message: string) {
    this.logger.warn(message);
    console.warn(message); // Print to console
  }

  debug(message: string) {
    this.logger.debug(message);
    console.debug(message); // Print to console
  }

  verbose(message: string) {
    this.logger.verbose(message);
    console.log(message); // Print to console
  }
}

const loggerService = new LoggerService();

export default loggerService;
