import { Module } from "@nestjs/common";

import { FileManagerController } from "./controllers/file-manager.controller";

import { FileManagerService } from "./services/file-manager.service";

@Module({
  controllers: [FileManagerController],
  providers: [FileManagerService],
})
export class FileManagerModule {}
