import { IsEmail, IsString, MinLength } from 'class-validator';

/**
 * @swagger
 * components:
 *   schemas:
 *     LoginDto:
 *       type: object
 *       required:
 *         - email
 *         - password
 *       properties:
 *         email:
 *           type: string
 *           format: email
 *           description: Email address dell'utente
 *           example: "mario.rossi@example.com"
 *         password:
 *           type: string
 *           description: Password dell'utente
 *           example: "SecurePass123!"
 */
export class LoginDto {
  @IsEmail({}, { message: 'Email non valida' })
  email: string;

  @IsString({ message: 'Password deve essere una stringa' })
  @MinLength(1, { message: 'Password is required' })
  password: string;
} 