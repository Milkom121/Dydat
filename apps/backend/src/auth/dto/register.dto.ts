import { IsEmail, IsString, MinLength, MaxLength, IsEnum, IsOptional } from 'class-validator';
import { UserRole } from '../entities/user.entity';

/**
 * @swagger
 * components:
 *   schemas:
 *     RegisterDto:
 *       type: object
 *       required:
 *         - email
 *         - password
 *         - firstName
 *         - lastName
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *           description: Email address dell'utente
 *           example: "mario.rossi@example.com"
 *         password:
 *           type: string
 *           minLength: 8
 *           description: Password dell'utente (minimo 8 caratteri)
 *           example: "SecurePass123!"
 *         firstName:
 *           type: string
 *           description: Nome dell'utente
 *           example: "Mario"
 *         lastName:
 *           type: string
 *           description: Cognome dell'utente
 *           example: "Rossi"
 *         role:
 *           type: string
 *           enum: [STUDENT, CREATOR, ADMIN]
 *           description: Ruolo dell'utente
 *           example: "STUDENT"
 *           default: "STUDENT"
 */
export class RegisterDto {
  @IsEmail({}, { message: 'Email non valida' })
  email: string;

  @IsString({ message: 'Password deve essere una stringa' })
  @MinLength(8, { message: 'Password deve essere almeno 8 caratteri' })
  @MaxLength(128, { message: 'Password must not exceed 128 characters' })
  password: string;

  @IsString({ message: 'Nome deve essere una stringa' })
  @MinLength(2, { message: 'First name must be at least 2 characters long' })
  @MaxLength(50, { message: 'First name must not exceed 50 characters' })
  firstName: string;

  @IsString({ message: 'Cognome deve essere una stringa' })
  @MinLength(2, { message: 'Last name must be at least 2 characters long' })
  @MaxLength(50, { message: 'Last name must not exceed 50 characters' })
  lastName: string;

  @IsOptional()
  @IsEnum(UserRole, { message: 'Ruolo non valido' })
  role?: UserRole = UserRole.STUDENT;
} 