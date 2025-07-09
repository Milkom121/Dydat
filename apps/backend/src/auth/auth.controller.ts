import {
  Controller,
  Post,
  Body,
  Get,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  Patch,
  Delete,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { Roles } from './decorators/roles.decorator';
import { CurrentUser } from './decorators/current-user.decorator';
import { User, UserRole } from './entities/user.entity';

/**
 * @swagger
 * tags:
 *   - name: Authentication
 *     description: Endpoint per autenticazione e gestione utenti
 * 
 * components:
 *   securitySchemes:
 *     BearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 *   
 *   schemas:
 *     AuthResponse:
 *       type: object
 *       properties:
 *         message:
 *           type: string
 *           example: "Operazione completata con successo"
 *         access_token:
 *           type: string
 *           example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *         user:
 *           $ref: '#/components/schemas/UserResponse'
 *     
 *     UserResponse:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *           example: "123e4567-e89b-12d3-a456-426614174000"
 *         email:
 *           type: string
 *           format: email
 *           example: "mario.rossi@example.com"
 *         firstName:
 *           type: string
 *           example: "Mario"
 *         lastName:
 *           type: string
 *           example: "Rossi"
 *         role:
 *           type: string
 *           enum: [STUDENT, CREATOR, ADMIN]
 *           example: "STUDENT"
 *         isActive:
 *           type: boolean
 *           example: true
 *         emailVerified:
 *           type: boolean
 *           example: false
 *         createdAt:
 *           type: string
 *           format: date-time
 *           example: "2025-01-08T10:30:00Z"
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           example: "2025-01-08T10:30:00Z"
 *     
 *     ErrorResponse:
 *       type: object
 *       properties:
 *         statusCode:
 *           type: number
 *           example: 400
 *         message:
 *           type: string
 *           example: "Errore di validazione"
 *         error:
 *           type: string
 *           example: "Bad Request"
 *         timestamp:
 *           type: string
 *           format: date-time
 *           example: "2025-01-08T10:30:00Z"
 *         path:
 *           type: string
 *           example: "/api/auth/register"
 */
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * @swagger
   * /auth/register:
   *   post:
   *     tags: [Authentication]
   *     summary: Registra nuovo utente
   *     description: Crea un nuovo account utente nel sistema
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/RegisterDto'
   *           examples:
   *             student:
   *               summary: Studente
   *               value:
   *                 email: "studente@example.com"
   *                 password: "SecurePass123!"
   *                 firstName: "Mario"
   *                 lastName: "Rossi"
   *                 role: "STUDENT"
   *             creator:
   *               summary: Content Creator
   *               value:
   *                 email: "creator@example.com"
   *                 password: "SecurePass123!"
   *                 firstName: "Giulia"
   *                 lastName: "Bianchi"
   *                 role: "CREATOR"
   *     responses:
   *       201:
   *         description: Registrazione completata con successo
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/AuthResponse'
   *       400:
   *         description: Dati di input non validi
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       409:
   *         description: Email già registrata
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       429:
   *         description: Troppi tentativi di registrazione
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @Throttle({ default: { limit: 3, ttl: 60000 } }) // 3 registrazioni per minuto
  async register(@Body() registerDto: RegisterDto) {
    const result = await this.authService.register(registerDto);
    return {
      message: 'Registrazione completata con successo',
      access_token: result.access_token,
      user: result.user,
    };
  }

  /**
   * @swagger
   * /auth/login:
   *   post:
   *     tags: [Authentication]
   *     summary: Effettua login
   *     description: Autentica utente e restituisce JWT token
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/LoginDto'
   *           example:
   *             email: "mario.rossi@example.com"
   *             password: "SecurePass123!"
   *     responses:
   *       200:
   *         description: Login effettuato con successo
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/AuthResponse'
   *       401:
   *         description: Credenziali non valide
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       429:
   *         description: Troppi tentativi di login
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 5, ttl: 60000 } }) // 5 login tentativi per minuto
  async login(@Body() loginDto: LoginDto) {
    const result = await this.authService.login(loginDto);
    return {
      message: 'Login effettuato con successo',
      access_token: result.access_token,
      user: result.user,
    };
  }

  /**
   * @swagger
   * /auth/logout:
   *   post:
   *     tags: [Authentication]
   *     summary: Logout utente (invalidazione token)
   *     description: Invalida il token JWT dell'utente autenticato
   *     security:
   *       - BearerAuth: []
   *     responses:
   *       200:
   *         description: Logout effettuato con successo
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: "Logout effettuato con successo"
   *                 user:
   *                   $ref: '#/components/schemas/UserResponse'
   *       401:
   *         description: Token non valido o mancante
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async logout(@CurrentUser() user: User) {
    // TODO: Implementare token blacklist per invalidazione sicura
    return {
      message: 'Logout effettuato con successo',
      user: user.toJSON(),
    };
  }

  /**
   * @swagger
   * /auth/profile:
   *   get:
   *     tags: [Authentication]
   *     summary: Ottieni profilo utente
   *     description: Restituisce i dati del profilo dell'utente autenticato
   *     security:
   *       - BearerAuth: []
   *     responses:
   *       200:
   *         description: Profilo utente recuperato
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: "Profilo utente recuperato"
   *                 user:
   *                   $ref: '#/components/schemas/UserResponse'
   *       401:
   *         description: Token non valido o mancante
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Get('profile')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { limit: 30, ttl: 60000 } }) // 30 richieste profilo per minuto
  async getProfile(@CurrentUser() user: User) {
    return {
      message: 'Profilo utente recuperato',
      user: user.toJSON(),
    };
  }

  /**
   * @swagger
   * /auth/profile:
   *   patch:
   *     tags: [Authentication]
   *     summary: Aggiorna profilo utente
   *     description: Modifica nome e cognome dell'utente autenticato
   *     security:
   *       - BearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/UpdateProfileDto'
   *           example:
   *             firstName: "Luigi"
   *             lastName: "Verdi"
   *     responses:
   *       200:
   *         description: Profilo aggiornato con successo
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: "Profilo aggiornato con successo"
   *                 user:
   *                   $ref: '#/components/schemas/UserResponse'
   *       400:
   *         description: Dati di input non validi
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       401:
   *         description: Token non valido o mancante
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Patch('profile')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { limit: 10, ttl: 60000 } }) // 10 update profilo per minuto
  async updateProfile(
    @CurrentUser() user: User,
    @Body() updateProfileDto: UpdateProfileDto,
  ) {
    const updatedUser = await this.authService.updateProfile(user.id, updateProfileDto);
    return {
      message: 'Profilo aggiornato con successo',
      user: updatedUser.toJSON(),
    };
  }

  /**
   * @swagger
   * /auth/change-password:
   *   post:
   *     tags: [Authentication]
   *     summary: Cambia password utente
   *     description: Modifica la password dell'utente autenticato
   *     security:
   *       - BearerAuth: []
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ChangePasswordDto'
   *           example:
   *             currentPassword: "OldPassword123!"
   *             newPassword: "NewPassword123!"
   *     responses:
   *       200:
   *         description: Password cambiata con successo
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: "Password cambiata con successo"
   *       400:
   *         description: Password non valida
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       401:
   *         description: Password attuale incorretta o token non valido
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       429:
   *         description: Troppi tentativi di cambio password
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Post('change-password')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 3, ttl: 3600000 } }) // 3 cambi password per ora
  async changePassword(
    @CurrentUser() user: User,
    @Body() changePasswordDto: ChangePasswordDto,
  ) {
    await this.authService.changePassword(
      user.id,
      changePasswordDto.currentPassword,
      changePasswordDto.newPassword,
    );
    return {
      message: 'Password cambiata con successo',
    };
  }

  /**
   * @swagger
   * /auth/account:
   *   delete:
   *     tags: [Authentication]
   *     summary: Elimina account utente
   *     description: Elimina definitivamente l'account dell'utente autenticato
   *     security:
   *       - BearerAuth: []
   *     responses:
   *       200:
   *         description: Account eliminato con successo
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: "Account eliminato con successo"
   *       401:
   *         description: Token non valido o mancante
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       429:
   *         description: Troppi tentativi di eliminazione
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Delete('account')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 1, ttl: 3600000 } }) // 1 eliminazione per ora
  async deleteAccount(@CurrentUser() user: User) {
    await this.authService.deleteAccount(user.id);
    return {
      message: 'Account eliminato con successo',
    };
  }

  /**
   * @swagger
   * /auth/admin/users:
   *   get:
   *     tags: [Authentication]
   *     summary: Lista tutti gli utenti (Admin Only)
   *     description: Restituisce lista di tutti gli utenti registrati. Richiede privilegi di amministratore.
   *     security:
   *       - BearerAuth: []
   *     responses:
   *       200:
   *         description: Lista utenti recuperata
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: "Lista utenti recuperata"
   *                 users:
   *                   type: array
   *                   items:
   *                     $ref: '#/components/schemas/UserResponse'
   *                 total:
   *                   type: number
   *                   example: 150
   *                 requestedBy:
   *                   $ref: '#/components/schemas/UserResponse'
   *       401:
   *         description: Token non valido o mancante
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       403:
   *         description: Accesso negato - solo amministratori
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Get('admin/users')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Throttle({ default: { limit: 20, ttl: 60000 } }) // 20 richieste admin per minuto
  async getAllUsers(@CurrentUser() adminUser: User) {
    const users = await this.authService.getAllUsers();
    return {
      message: 'Lista utenti recuperata',
      users: users.map(user => user.toJSON()),
      total: users.length,
      requestedBy: adminUser.toJSON(),
    };
  }

  /**
   * @swagger
   * /auth/admin/users/:userId/role:
   *   patch:
   *     tags: [Authentication]
   *     summary: Gestione ruoli utente
   *     description: Modifica il ruolo di un utente registrato
   *     security:
   *       - BearerAuth: []
   *     parameters:
   *       - name: userId
   *         in: path
   *         required: true
   *         schema:
   *           type: string
   *           format: uuid
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/UserRoleDto'
   *     responses:
   *       200:
   *         description: Ruolo utente aggiornato
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: "Ruolo utente aggiornato"
   *                 updatedBy:
   *                   $ref: '#/components/schemas/UserResponse'
   *       400:
   *         description: Dati di input non validi
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       401:
   *         description: Token non valido o mancante
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   *       403:
   *         description: Accesso negato - solo amministratori
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ErrorResponse'
   */
  @Patch('admin/users/:userId/role')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Throttle({ default: { limit: 5, ttl: 60000 } }) // 5 cambi ruolo per minuto
  async updateUserRole(
    @CurrentUser() adminUser: User,
    @Body() roleData: { role: UserRole },
  ) {
    // TODO: Implementare gestione ruoli utente
    return {
      message: 'Ruolo utente aggiornato',
      updatedBy: adminUser.toJSON(),
    };
  }

  /**
   * @swagger
   * /auth/verify:
   *   get:
   *     tags: [Authentication]
   *     summary: Verifica validità token
   *     description: Controlla se il token JWT è valido e restituisce informazioni utente
   *     security:
   *       - BearerAuth: []
   *     responses:
   *       200:
   *         description: Token valido
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 valid:
   *                   type: boolean
   *                   example: true
   *                 user:
   *                   $ref: '#/components/schemas/UserResponse'
   *                 timestamp:
   *                   type: string
   *                   format: date-time
   *                   example: "2025-01-08T10:30:00Z"
   *       401:
   *         description: Token non valido o scaduto
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 valid:
   *                   type: boolean
   *                   example: false
   *                 error:
   *                   type: string
   *                   example: "Token expired"
   */
  @Get('verify')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { limit: 100, ttl: 60000 } }) // 100 verifiche per minuto
  async verifyToken(@CurrentUser() user: User) {
    return {
      valid: true,
      user: user.toJSON(),
      timestamp: new Date().toISOString(),
    };
  }
} 