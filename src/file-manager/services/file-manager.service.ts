import { Injectable } from "@nestjs/common";
import { Response } from "express";
import loggerService from "../../logger.service";

@Injectable()
export class FileManagerService {
  constructor() {}

  processUploadedFiles(
    files: Express.Multer.File[],
    userEmail: string,
  ): ProcessedFilesResult {
    if (!files)
      return {
        errors: ["No files found"],
        savedFileNames: null,
        savedFilesOriginalNames: null,
      };
    files.forEach((file) => {
      const tmpFile = { ...file, userEmail };
      loggerService.log(`uploaded File: ${JSON.stringify(tmpFile)}`);
    });
    return {
      errors: null,
      savedFileNames: files.map((file) => file.filename),
      savedFilesOriginalNames: files.map((file) => file.originalname),
    };
  }

  serveDefaultPhoto(res: Response): void {
    res.sendFile("default.jpg", { root: "src/KEEP_TRACK/uploads" });
  }

  servePhoto(filename: string, res: Response): void {
    res.sendFile(filename, { root: "src/KEEP_TRACK/uploads" });
  }
}

export interface ProcessedFilesResult {
  errors: string[];
  savedFileNames: string[];
  savedFilesOriginalNames: string[];
}
