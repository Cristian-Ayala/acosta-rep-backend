import {
  Body,
  Controller,
  FileTypeValidator,
  Get,
  MaxFileSizeValidator,
  Param,
  ParseFilePipe,
  Post,
  Res,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";
import { FilesInterceptor } from "@nestjs/platform-express";
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

  @UseGuards(AuthGuard())
  @Post("upload-photo")
  @UseInterceptors(FilesInterceptor("file"))
  async uploadPhoto(
    @UploadedFiles(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 1 * 1024 * 1024 }), // 1MB
          new FileTypeValidator({ fileType: /^image\/(jpeg|png|webp|gif)$/ }),
        ],
      }),
    )
    files: Express.Multer.File[],
    @Body() body: any,
  ): Promise<ProcessedFilesResult> {
    // Make sure the necessary properties are defined before accessing them
    const userId = body.userId || null;
    return this.fileManagerService.processUploadedFiles(files, userId);
  }

  @UseGuards(AuthGuard())
  @Get("photo/")
  async getDefaultPhoto(@Res() res: Response) {
    return this.fileManagerService.serveDefaultPhoto(res);
  }

  @UseGuards(AuthGuard())
  @Get("photo/:filename")
  async getPhoto(@Param("filename") filename: string, @Res() res: Response) {
    return this.fileManagerService.servePhoto(filename, res);
  }
}
