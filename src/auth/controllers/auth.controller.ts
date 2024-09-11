import { Body, Controller, Patch, Post, Res, UseGuards } from "@nestjs/common";
import { AuthService } from "../services/auth.service";
import { RegisterUserDto } from "../dto/register-user.dto";
import { LoginDto } from "../dto/login.dto";
import { AuthGuard } from "@nestjs/passport";
import { GetUser } from "../decorators/get-user.decorator";
import { User } from "../interfaces/user.entity";
import { ChangePasswordDto } from "../dto/change-password.dto";
import { Response } from "express";

@Controller("auth")
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post("/register")
  register(@Body() registerUserDto: RegisterUserDto): Promise<void> {
    return this.authService.registerUser(registerUserDto);
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
  ): Promise<void> {
    return this.authService.changePassword(changePasswordDto, user);
  }
}
