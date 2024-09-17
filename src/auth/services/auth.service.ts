import {
  BadRequestException,
  Injectable,
  Res,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import { Response } from "express";
import { ChangePasswordAdminDto } from "../dto/change-password-admin.dto";
import { ChangePasswordDto } from "../dto/change-password.dto";
import { LoginDto } from "../dto/login.dto";
import { RegisterUserDto } from "../dto/register-user.dto";
import { JwtPayload } from "../interfaces/jwt.payload";
import { User } from "../interfaces/user.entity";
import { UsersRepository } from "../repositories/users.repository";
import { EncoderService } from "../services/encoder.service";

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(UsersRepository)
    private usersRepository: UsersRepository,
    private enconderService: EncoderService,
    private jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async registerUser(
    registerUserDto: RegisterUserDto,
    @Res() res: Response,
  ): Promise<Response> {
    registerUserDto.password = await this.enconderService.encodePassword(
      registerUserDto.password,
    );
    const usr = await this.usersRepository.createUser(registerUserDto);
    return res.status(201).json({ message: "Usuario creado correctamente" });
  }

  async login(loginDto: LoginDto, @Res() res: Response): Promise<Response> {
    const { email, password } = loginDto;
    const user = await this.usersRepository.findOneByEmail(email);

    if (!user.active || !(await this.enconderService.checkPassword(password, user.password)))
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
    @Res() res: Response,
  ): Promise<Response> {
    const { oldPassword, newPassword } = changePasswordDto;
    if (await this.enconderService.checkPassword(oldPassword, user.password)) {
      user.password = await this.enconderService.encodePassword(newPassword);
      this.usersRepository.save(user);
      return res
        .status(200)
        .json({ message: "Contraseña cambiada correctamente" });
    } else {
      throw new BadRequestException("La contraseña actual no es correcta");
    }
  }

  async changePasswordAdmin(
    changePasswordDto: ChangePasswordAdminDto,
    user: User,
    @Res() res: Response,
  ): Promise<Response> {
    const { newPassword, idUser } = changePasswordDto;

    if (!this.usersRepository.validateAdminRole(user))
      throw new UnauthorizedException(
        "No tienes permisos para realizar esta acción",
      );

    const userModify = await this.usersRepository.findOneBy({ id: idUser });

    if (!userModify)
      throw new BadRequestException("El usuario no existe en la base de datos");

    userModify.password =
      await this.enconderService.encodePassword(newPassword);
    this.usersRepository.save(userModify);

    return res
      .status(200)
      .json({ message: "Contraseña cambiada correctamente" });
  }
}
