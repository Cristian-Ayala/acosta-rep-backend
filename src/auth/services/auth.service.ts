import {
  BadRequestException,
  Injectable,
  Res,
  UnauthorizedException,
} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { RegisterUserDto } from "../dto/register-user.dto";
import { UsersRepository } from "../repositories/users.repository";
import { EncoderService } from "../services/encoder.service";
import { LoginDto } from "../dto/login.dto";
import { JwtService } from "@nestjs/jwt";
import { JwtPayload } from "../interfaces/jwt.payload";
import { ChangePasswordDto } from "../dto/change-password.dto";
import { User } from "../interfaces/user.entity";
import { ConfigService } from "@nestjs/config";
import { Response } from 'express';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UsersRepository)
    private usersRepository: UsersRepository,
    private enconderService: EncoderService,
    private jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async registerUser(registerUserDto: RegisterUserDto): Promise<void> {
    registerUserDto.password = await this.enconderService.encodePassword(
      registerUserDto.password,
    );
    return this.usersRepository.createUser(registerUserDto);
  }

  async login(loginDto: LoginDto, @Res() res: Response): Promise<Response> {
    const { email, password } = loginDto;
    const user = await this.usersRepository.findOneByEmail(email);

    if (!(await this.enconderService.checkPassword(password, user.password)))
      throw new UnauthorizedException("Por favor, verifica tus credenciales");

    const payload: JwtPayload = {
      id: user.id,
      email,
      active: user.active,
      roles: user.roles,
      sucursal: user.sucursal,
      "https://hasura.io/jwt/claims": {
        "x-hasura-default-role": user.roles[0],
        "x-hasura-allowed-roles": user.roles,
        "x-hasura-user-id": user.id,
        "x-hasura-user-email": email,
      },
    };
    const accessToken = this.jwtService.sign(payload, {
      algorithm: "RS512",
      privateKey: this.configService
        .get<string>("JWT_PRIVATE_KEY_VALUE")
        .replace(/\\n/g, "\n"),
    });
    return res.status(200).json({ accessToken });
  }

  async changePassword(
    changePasswordDto: ChangePasswordDto,
    user: User,
  ): Promise<void> {
    const { oldPassword, newPassword } = changePasswordDto;
    if (await this.enconderService.checkPassword(oldPassword, user.password)) {
      user.password = await this.enconderService.encodePassword(newPassword);
      this.usersRepository.save(user);
    } else {
      throw new BadRequestException("Old password does not match");
    }
  }
}
