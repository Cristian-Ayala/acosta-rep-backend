import { Body, Controller, Patch, Post, Res, UseGuards } from "@nestjs/common";
import { AuthService } from "../services/auth.service";
import { RegisterUserDto } from "../dto/register-user.dto";
import { LoginDto } from "../dto/login.dto";
import { AuthGuard } from "@nestjs/passport";
import { GetUser } from "../decorators/get-user.decorator";
import { User } from "../interfaces/user.entity";
import { ChangePasswordDto } from "../dto/change-password.dto";
import { Response } from "express";
import { ChangePasswordAdminDto } from "../dto/change-password-admin.dto";

@Controller("auth")
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post("/register")
  @UseGuards(AuthGuard())
  register(
    @Body() registerUserDto: RegisterUserDto,
    @Res() res: Response,
  ): Promise<Response> {
    return this.authService.registerUser(registerUserDto, res);
  }

  @Post("/login")
  login(@Body() loginDto: LoginDto, @Res() res: Response): Promise<Response> {
    return this.authService.login(loginDto, res);
  }

  @Patch("/change-password")
  @UseGuards(AuthGuard())
  changePassword(
    @Body() changePasswordDto: ChangePasswordDto,
    @GetUser() user: User,
    @Res() res: Response,
  ): Promise<Response> {
    return this.authService.changePassword(changePasswordDto, user, res);
  }

  @Patch("/change-password-admin")
  @UseGuards(AuthGuard())
  changePasswordAdmin(
    @Body() changePasswordAdminDto: ChangePasswordAdminDto,
    @GetUser() user: User,
    @Res() res: Response,
  ): Promise<Response> {
    return this.authService.changePasswordAdmin(changePasswordAdminDto, user, res);
  }
}
