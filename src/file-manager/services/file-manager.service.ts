import { Injectable } from "@nestjs/common";
import { Response } from "express";

@Injectable()
export class FileManagerService {
  constructor() {}

  processUploadedFiles(files: Express.Multer.File[]): ProcessedFilesResult {
    if (!files)
      return {
        errors: ["No files found"],
        savedFileNames: null,
        savedFilesOriginalNames: null,
      };
    files.forEach((file) => {
      console.log("uploaded File: ", file);
    });
    return {
      errors: null,
      savedFileNames: files.map((file) => file.filename),
      savedFilesOriginalNames: files.map((file) => file.originalname),
    };
  }

  serveDefaultPhoto(res: Response): void {
    res.sendFile("default.jpg", { root: "./uploads" });
  }

  servePhoto(filename: string, res: Response): void {
    res.sendFile(filename, { root: "./uploads" });
  }
}

export interface ProcessedFilesResult {
  errors: string[];
  savedFileNames: string[];
  savedFilesOriginalNames: string[];
}
