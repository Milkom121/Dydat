import { IsString, IsOptional } from 'class-validator';

/**
 * @swagger
 * components:
 *   schemas:
 *     UpdateProfileDto:
 *       type: object
 *       properties:
 *         firstName:
 *           type: string
 *           description: Nuovo nome dell'utente
 *           example: "Luigi"
 *         lastName:
 *           type: string
 *           description: Nuovo cognome dell'utente
 *           example: "Verdi"
 */
export class UpdateProfileDto {
  @IsOptional()
  @IsString({ message: 'Nome deve essere una stringa' })
  firstName?: string;

  @IsOptional()
  @IsString({ message: 'Cognome deve essere una stringa' })
  lastName?: string;
} 