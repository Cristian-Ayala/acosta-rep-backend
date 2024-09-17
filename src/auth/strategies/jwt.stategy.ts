import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { PassportStrategy } from "@nestjs/passport";
import { InjectRepository } from "@nestjs/typeorm";
import { ExtractJwt, Strategy } from "passport-jwt";
import loggerService from "@/logger.service";
import { JwtPayload } from "../interfaces/jwt.payload";
import { User } from "../interfaces/user.entity";
import { UsersRepository } from "../repositories/users.repository";

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    @InjectRepository(UsersRepository) private usersRepository: UsersRepository,
    private configService: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService
        .get<string>("JWT_PUBLIC_KEY_VALUE")
        .replace(/\\n/g, "\n"),
      algorithms: ["RS512"],
    });
  }

  async validate(payload: JwtPayload): Promise<User> {
    if (!payload) throw new UnauthorizedException("Token Invalido");
    const { email } = payload;
    const user = this.usersRepository.findOneByEmail(email);

    if (!user) throw new UnauthorizedException();

    return user;
  }
}
