import { Repository } from "typeorm";
import { RegisterUserDto } from "../dto/register-user.dto";
import { User } from "../interfaces/user.entity";
import { Sucursal, Role } from "@/enums";
import {
  ConflictException,
  InternalServerErrorException,
  NotFoundException,
} from "@nestjs/common"; // for error handling
import { InjectRepository } from "@nestjs/typeorm";

export class UsersRepository extends Repository<User> {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {
    super(
      userRepository.target,
      userRepository.manager,
      userRepository.queryRunner,
    );
  }
  // Helper method to validate and map sucursal values
  private mapSucursales(sucursales: string[]): Sucursal[] {
    const validSucursales = sucursales
      .map((sucursal) => Sucursal[sucursal])
      .filter((sucursal) => sucursal != null);

    return validSucursales.length > 0
      ? validSucursales
      : [Sucursal["Santa Ana"]];
  }

  // Helper method to validate and map role values
  private mapRoles(roles: string[]): Role[] {
    const validRoles = roles
      .map((role) => Role[role])
      .filter((role) => role != null);

    return validRoles.length > 0 ? validRoles : [Role.seller];
  }

  public validateAdminRole(user: User): boolean {
    return (
      user.roles.includes(Role.admin) || user.roles.includes(Role.gerente_area)
    );
  }
  async createUser(registerUserDto: RegisterUserDto): Promise<User> {
    const { name, email, password, sucursal, roles } = registerUserDto;

    // Use helper methods to validate and map enums
    const sucursalSel = this.mapSucursales(sucursal);
    const rolesSel = this.mapRoles(roles);

    const user = this.create({
      name,
      email,
      password,
      sucursal: sucursalSel,
      roles: rolesSel,
    });

    try {
      const savedUser = await this.save(user);
      return savedUser;
    } catch (e) {
      if (e.message.includes("duplicate key value"))
        // Postgres error message
        throw new ConflictException("Este email ya está registrado");
      throw new InternalServerErrorException();
    }
  }

  async findOneByEmail(email: string): Promise<User> {
    const user: User = await this.findOne({ where: { email } });

    if (!user) {
      throw new NotFoundException(`User with email ${email} not found`);
    }

    return user;
  }
}
