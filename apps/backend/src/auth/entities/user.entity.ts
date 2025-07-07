import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum UserRole {
  STUDENT = 'STUDENT',
  CREATOR = 'CREATOR', 
  ADMIN = 'ADMIN'
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column()
  firstName: string;

  @Column()
  lastName: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.STUDENT
  })
  role: UserRole;

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: false })
  emailVerified: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Computed property per nome completo
  get fullName(): string {
    return `${this.firstName} ${this.lastName}`;
  }

  // Helper methods per controllo ruoli
  isStudent(): boolean {
    return this.role === UserRole.STUDENT;
  }

  isCreator(): boolean {
    return this.role === UserRole.CREATOR;
  }

  isAdmin(): boolean {
    return this.role === UserRole.ADMIN;
  }

  // Check se l'utente può creare contenuti
  canCreateContent(): boolean {
    return this.role === UserRole.CREATOR || this.role === UserRole.ADMIN;
  }

  // Check se l'utente ha privilegi amministrativi
  hasAdminPrivileges(): boolean {
    return this.role === UserRole.ADMIN;
  }
} 