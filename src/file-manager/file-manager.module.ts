import { Module } from "@nestjs/common";
import { FileManagerController } from "./controllers/file-manager.controller";
import { FileManagerService } from "./services/file-manager.service";
import { AuthModule } from "../auth/auth.module";
@Module({
  imports: [AuthModule],
  controllers: [FileManagerController],
  providers: [FileManagerService],
})
export class FileManagerModule {}
