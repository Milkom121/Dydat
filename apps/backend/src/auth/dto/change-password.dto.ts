import { IsString, MinLength } from 'class-validator';

/**
 * @swagger
 * components:
 *   schemas:
 *     ChangePasswordDto:
 *       type: object
 *       required:
 *         - currentPassword
 *         - newPassword
 *       properties:
 *         currentPassword:
 *           type: string
 *           description: Password attuale dell'utente
 *           example: "OldPassword123!"
 *         newPassword:
 *           type: string
 *           minLength: 8
 *           description: Nuova password dell'utente (minimo 8 caratteri)
 *           example: "NewPassword123!"
 */
export class ChangePasswordDto {
  @IsString({ message: 'Password attuale deve essere una stringa' })
  currentPassword: string;

  @IsString({ message: 'Nuova password deve essere una stringa' })
  @MinLength(8, { message: 'Nuova password deve essere almeno 8 caratteri' })
  newPassword: string;
} 