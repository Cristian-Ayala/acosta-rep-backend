import {
  BadRequestException,
  Controller,
  Post,
  Get,
  UploadedFiles,
  UseInterceptors,
  Param,
  Res,
  Body,
} from "@nestjs/common";
import loggerService from "../../logger.service";
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
        destination: "src/KEEP_TRACK/uploads",
        filename: (req, file, cb) => {
          loggerService.log(`filename file ${JSON.stringify(file, null, 2)}`);
          loggerService.log(`filename file type: ${typeof file}`);
          loggerService.log(`filename file originalname: ${file.originalname}`);
          const [name, fileExtName] = replaceDotsWithUnderscores(
            file.originalname,
          );
          const newFileName = `${name}-${Date.now()}.${fileExtName}`;
          cb(null, newFileName);
        },
      }),
      fileFilter: (req, file, cb) => {
        loggerService.log(`fileFilter file ${JSON.stringify(file, null, 2)}`);
        loggerService.log(`fileFilter file type: ${typeof file}`);
        loggerService.log(`fileFilter file originalname: ${file.originalname}`);
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
    @Body() body: any,
  ): Promise<ProcessedFilesResult> {
    // Make sure the necessary properties are defined before accessing them
    const userEmail = body.userEmail || null;
    loggerService.log(`userEmail ${userEmail}`);
    loggerService.log(`files ${files}`);
    loggerService.log(`files ${JSON.stringify(files, null, 2)}`);
    return this.fileManagerService.processUploadedFiles(files, userEmail);
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
