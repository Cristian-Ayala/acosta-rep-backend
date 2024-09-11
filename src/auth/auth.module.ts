import { Module } from "@nestjs/common";
import { AuthController } from "./controllers/auth.controller";
import { AuthService } from "./services/auth.service";
import { TypeOrmModule } from "@nestjs/typeorm";
import { UsersRepository } from "./repositories/users.repository";
import { User } from "./interfaces/user.entity";
import { EncoderService } from "./services/encoder.service";
import { PassportModule } from "@nestjs/passport";
import { JwtModule } from "@nestjs/jwt";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { JwtStrategy } from "./strategies/jwt.stategy";

@Module({
  imports: [
    ConfigModule,
    PassportModule.register({ defaultStrategy: "jwt" }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        publicKey: configService.get<string>("JWT_PUBLIC_KEY_JSON"),
        privateKey: configService.get<string>("JWT_PRIVATE_KEY_JSON"),
        signOptions: {
          algorithm: "RS512",
          expiresIn: configService.get<string>("JWT_EXPIRATION"),
        },
        verifyOptions: {
          algorithms: ["RS512"],
        },
      }),
    }),
    TypeOrmModule.forFeature([User]),
  ],
  controllers: [AuthController],
  providers: [AuthService, UsersRepository, EncoderService, JwtStrategy],
  exports: [JwtStrategy, PassportModule],
})
export class AuthModule {}
