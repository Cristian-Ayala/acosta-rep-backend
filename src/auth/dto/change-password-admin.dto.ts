import { IsNotEmpty, IsUUID, Length } from "class-validator";
import { UUID } from "crypto";

export class ChangePasswordAdminDto {
  @IsNotEmpty()
  @Length(6, 20)
  newPassword: string;

  @IsUUID()
  idUser: UUID;
}
