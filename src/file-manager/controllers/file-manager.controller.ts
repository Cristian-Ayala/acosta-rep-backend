import {
  BadRequestException,
  Controller,
  Post,
  Get,
  UploadedFiles,
  UseInterceptors,
  Param,
  Res,
} from "@nestjs/common";
import { FilesInterceptor } from "@nestjs/platform-express";
import { diskStorage } from "multer";
import { Response } from "express";
import {
  FileManagerService,
  ProcessedFilesResult,
} from "../services/file-manager.service";

function replaceDotsWithUnderscores(inputString: string): [string, string] {
  const parts = inputString.split(".");
  const extension = parts.pop(); // Remove the last part as the extension
  return [parts.join("_"), extension];
}

@Controller("file-manager")
export class FileManagerController {
  constructor(private readonly fileManagerService: FileManagerService) {}

  @Post("upload-photo")
  @UseInterceptors(
    FilesInterceptor("file", 10, {
      storage: diskStorage({
        destination: "./uploads",
        filename: (req, file, cb) => {
          const [name, fileExtName] = replaceDotsWithUnderscores(
            file.originalname,
          );
          const newFileName = `${name}-${Date.now()}.${fileExtName}`;
          cb(null, newFileName);
        },
      }),
      fileFilter: (req, file, cb) => {
        if (!file.originalname.match(/\.(jpg|jpeg|png|gif|webp)$/)) {
          return cb(
            new BadRequestException("Only image files are allowed!"),
            false,
          );
        }
        cb(null, true);
      },
    }),
  )
  async uploadPhoto(
    @UploadedFiles() files: Express.Multer.File[],
  ): Promise<ProcessedFilesResult> {
    return this.fileManagerService.processUploadedFiles(files);
  }

  @Get("photo/")
  async getDefaultPhoto(@Res() res: Response) {
    return this.fileManagerService.serveDefaultPhoto(res);
  }

  @Get("photo/:filename")
  async getPhoto(@Param("filename") filename: string, @Res() res: Response) {
    return this.fileManagerService.servePhoto(filename, res);
  }
}
