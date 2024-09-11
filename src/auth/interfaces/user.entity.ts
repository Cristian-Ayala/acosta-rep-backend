import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from "typeorm";
import { Sucursal, Role } from "@/enums";

@Entity({ name: "users" })
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @Column({ length: 20 })
  name: string;

  @Column({ length: 100, unique: true })
  email: string;

  @Column({ length: 100 })
  password: string;

  @Column({ type: "boolean", default: true })
  active: boolean;

  @CreateDateColumn()
  created_on: Date;

  @Column({
    type: "enum",
    enum: Sucursal,
    array: true, // Allows storing an array of enum values
  })
  sucursal: Sucursal[];

  @Column({
    type: "enum",
    enum: Role,
    array: true, // Allows storing an array of enum values
  })
  roles: Role[];
}
