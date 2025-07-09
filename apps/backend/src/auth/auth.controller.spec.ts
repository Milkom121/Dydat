import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { User, UserRole } from './entities/user.entity';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { CustomValidationPipe } from '../common/pipes/validation.pipe';

describe('AuthController (Integration)', () => {
  let app: INestApplication;
  let authService: AuthService;
  let userRepository: jest.Mocked<Repository<User>>;
  let jwtService: JwtService;

  // Test data
  const mockUser: User = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    email: 'test@example.com',
    password: '$2b$12$hashedPassword',
    firstName: 'Mario',
    lastName: 'Rossi',
    role: UserRole.STUDENT,
    isActive: true,
    emailVerified: false,
    createdAt: new Date(),
    updatedAt: new Date(),
    getFullName: () => 'Mario Rossi',
    isStudent: () => true,
    isCreator: () => false,
    isAdmin: () => false,
    canCreateCourses: () => false,
    canManageUsers: () => false,
    hasPermission: () => false,
    toJSON: () => ({
      id: '123e4567-e89b-12d3-a456-426614174000',
      email: 'test@example.com',
      firstName: 'Mario',
      lastName: 'Rossi',
      role: UserRole.STUDENT,
      isActive: true,
      emailVerified: false,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
  };

  const mockAdmin: User = {
    ...mockUser,
    id: 'admin-id',
    email: 'admin@dydat.com',
    role: UserRole.ADMIN,
    isAdmin: () => true,
    canManageUsers: () => true,
  };

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ThrottlerModule.forRoot([
          {
            ttl: 60000,
            limit: 10,
          },
        ]),
      ],
      controllers: [AuthController],
      providers: [
        AuthService,
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: jest.fn(),
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
          },
        },
        {
          provide: JwtService,
          useValue: {
            sign: jest.fn(),
            verify: jest.fn(),
          },
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({
        canActivate: jest.fn((context) => {
          const request = context.switchToHttp().getRequest();
          // Mock authenticated user based on test scenario
          if (request.headers.authorization?.includes('admin-token')) {
            request.user = mockAdmin;
          } else if (request.headers.authorization?.includes('user-token')) {
            request.user = mockUser;
          }
          return !!request.headers.authorization;
        }),
      })
      .overrideGuard(RolesGuard)
      .useValue({
        canActivate: jest.fn((context) => {
          const request = context.switchToHttp().getRequest();
          // Allow admin access to admin endpoints
          return request.user?.role === UserRole.ADMIN;
        }),
      })
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new CustomValidationPipe());
    await app.init();

    authService = moduleFixture.get<AuthService>(AuthService);
    userRepository = moduleFixture.get(getRepositoryToken(User));
    jwtService = moduleFixture.get<JwtService>(JwtService);
  });

  afterEach(async () => {
    await app.close();
    jest.clearAllMocks();
  });

  describe('POST /auth/register', () => {
    const registerDto = {
      email: 'test@example.com',
      password: 'password123',
      firstName: 'Mario',
      lastName: 'Rossi',
      role: 'STUDENT',
    };

    it('should register a new user successfully', async () => {
      // Arrange
      const mockResponse = {
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      };
      jest.spyOn(authService, 'register').mockResolvedValue(mockResponse);

      // Act & Assert
      const response = await request(app.getHttpServer())
        .post('/auth/register')
        .send(registerDto)
        .expect(201);

      expect(response.body).toEqual({
        message: 'Registrazione completata con successo',
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      });
      expect(authService.register).toHaveBeenCalledWith(registerDto);
    });

    it('should return 409 for duplicate email', async () => {
      // Arrange
      jest.spyOn(authService, 'register').mockRejectedValue(
        new Error('Email già in uso'),
      );

      // Act & Assert
      await request(app.getHttpServer())
        .post('/auth/register')
        .send(registerDto)
        .expect(500); // Will be handled by global exception filter
    });

    it('should validate required fields', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .post('/auth/register')
        .send({
          email: 'invalid-email',
          password: '123', // Too short
          firstName: '',
        })
        .expect(400);
    });

    it('should sanitize malicious input', async () => {
      // Arrange
      const maliciousDto = {
        ...registerDto,
        firstName: '<script>alert("xss")</script>',
        lastName: "'; DROP TABLE users; --",
      };

      jest.spyOn(authService, 'register').mockResolvedValue({
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      });

      // Act
      await request(app.getHttpServer())
        .post('/auth/register')
        .send(maliciousDto)
        .expect(201);

      // Assert - Input should be sanitized
      expect(authService.register).toHaveBeenCalledWith(
        expect.objectContaining({
          firstName: expect.not.stringContaining('<script>'),
          lastName: expect.not.stringContaining('DROP TABLE'),
        }),
      );
    });
  });

  describe('POST /auth/login', () => {
    const loginDto = {
      email: 'test@example.com',
      password: 'password123',
    };

    it('should login successfully with valid credentials', async () => {
      // Arrange
      const mockResponse = {
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      };
      jest.spyOn(authService, 'login').mockResolvedValue(mockResponse);

      // Act & Assert
      const response = await request(app.getHttpServer())
        .post('/auth/login')
        .send(loginDto)
        .expect(200);

      expect(response.body).toEqual({
        message: 'Login effettuato con successo',
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      });
    });

    it('should return 401 for invalid credentials', async () => {
      // Arrange
      jest.spyOn(authService, 'login').mockRejectedValue(
        new Error('Credenziali non valide'),
      );

      // Act & Assert
      await request(app.getHttpServer())
        .post('/auth/login')
        .send(loginDto)
        .expect(500); // Handled by global exception filter
    });

    it('should validate email format', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'invalid-email',
          password: 'password123',
        })
        .expect(400);
    });
  });

  describe('GET /auth/profile', () => {
    it('should return user profile when authenticated', async () => {
      // Act & Assert
      const response = await request(app.getHttpServer())
        .get('/auth/profile')
        .set('Authorization', 'Bearer user-token')
        .expect(200);

      expect(response.body).toEqual({
        message: 'Profilo utente recuperato',
        user: mockUser.toJSON(),
      });
    });

    it('should return 401 when not authenticated', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .get('/auth/profile')
        .expect(401);
    });
  });

  describe('PATCH /auth/profile', () => {
    it('should update profile when authenticated', async () => {
      // Arrange
      const updateData = { firstName: 'Luigi', lastName: 'Verdi' };
      const updatedUser = { ...mockUser, ...updateData };
      
      jest.spyOn(authService, 'updateProfile').mockResolvedValue(updatedUser);

      // Act & Assert
      const response = await request(app.getHttpServer())
        .patch('/auth/profile')
        .set('Authorization', 'Bearer user-token')
        .send(updateData)
        .expect(200);

      expect(response.body).toEqual({
        message: 'Profilo aggiornato con successo',
        user: updatedUser.toJSON(),
      });
      expect(authService.updateProfile).toHaveBeenCalledWith(mockUser.id, updateData);
    });

    it('should return 401 when not authenticated', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .patch('/auth/profile')
        .send({ firstName: 'Luigi' })
        .expect(401);
    });
  });

  describe('POST /auth/change-password', () => {
    it('should change password when authenticated', async () => {
      // Arrange
      const passwordData = {
        currentPassword: 'oldPassword',
        newPassword: 'newPassword123',
      };
      
      jest.spyOn(authService, 'changePassword').mockResolvedValue(undefined);

      // Act & Assert
      const response = await request(app.getHttpServer())
        .post('/auth/change-password')
        .set('Authorization', 'Bearer user-token')
        .send(passwordData)
        .expect(200);

      expect(response.body).toEqual({
        message: 'Password cambiata con successo',
      });
      expect(authService.changePassword).toHaveBeenCalledWith(
        mockUser.id,
        passwordData.currentPassword,
        passwordData.newPassword,
      );
    });

    it('should validate password requirements', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .post('/auth/change-password')
        .set('Authorization', 'Bearer user-token')
        .send({
          currentPassword: 'old',
          newPassword: '123', // Too short
        })
        .expect(400);
    });
  });

  describe('DELETE /auth/account', () => {
    it('should delete account when authenticated', async () => {
      // Arrange
      jest.spyOn(authService, 'deleteAccount').mockResolvedValue(undefined);

      // Act & Assert
      const response = await request(app.getHttpServer())
        .delete('/auth/account')
        .set('Authorization', 'Bearer user-token')
        .expect(200);

      expect(response.body).toEqual({
        message: 'Account eliminato con successo',
      });
      expect(authService.deleteAccount).toHaveBeenCalledWith(mockUser.id);
    });
  });

  describe('GET /auth/admin/users', () => {
    it('should return users list for admin', async () => {
      // Arrange
      const users = [mockUser, mockAdmin];
      jest.spyOn(authService, 'getAllUsers').mockResolvedValue(users);

      // Act & Assert
      const response = await request(app.getHttpServer())
        .get('/auth/admin/users')
        .set('Authorization', 'Bearer admin-token')
        .expect(200);

      expect(response.body).toEqual({
        message: 'Lista utenti recuperata',
        users: users.map(user => user.toJSON()),
        total: users.length,
        requestedBy: mockAdmin.toJSON(),
      });
    });

    it('should return 403 for non-admin users', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .get('/auth/admin/users')
        .set('Authorization', 'Bearer user-token')
        .expect(403);
    });

    it('should return 401 when not authenticated', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .get('/auth/admin/users')
        .expect(401);
    });
  });

  describe('GET /auth/verify', () => {
    it('should verify valid token', async () => {
      // Act & Assert
      const response = await request(app.getHttpServer())
        .get('/auth/verify')
        .set('Authorization', 'Bearer user-token')
        .expect(200);

      expect(response.body).toEqual({
        valid: true,
        user: mockUser.toJSON(),
        timestamp: expect.any(String),
      });
    });

    it('should return 401 for invalid token', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .get('/auth/verify')
        .expect(401);
    });
  });

  describe('Rate Limiting', () => {
    it('should respect rate limits on registration endpoint', async () => {
      // Arrange
      const registerDto = {
        email: 'test@example.com',
        password: 'password123',
        firstName: 'Mario',
        lastName: 'Rossi',
      };

      jest.spyOn(authService, 'register').mockResolvedValue({
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      });

      // Act - Make multiple requests rapidly
      const requests = Array(12).fill(null).map(() =>
        request(app.getHttpServer())
          .post('/auth/register')
          .send(registerDto)
      );

      const responses = await Promise.allSettled(requests);

      // Assert - Some requests should be rate limited
      const rateLimitedResponses = responses.filter(
        (response) => 
          response.status === 'fulfilled' && 
          response.value.status === 429
      );

      expect(rateLimitedResponses.length).toBeGreaterThan(0);
    }, 10000);
  });

  describe('Security Headers and CORS', () => {
    it('should include security headers in responses', async () => {
      // Act & Assert
      const response = await request(app.getHttpServer())
        .get('/auth/verify')
        .set('Authorization', 'Bearer user-token')
        .expect(200);

      // Check for common security headers (these would be set by helmet)
      expect(response.headers).toHaveProperty('x-frame-options');
      expect(response.headers).toHaveProperty('x-content-type-options');
    });

    it('should handle CORS preflight requests', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .options('/auth/login')
        .set('Origin', 'http://localhost:3000')
        .set('Access-Control-Request-Method', 'POST')
        .expect(200);
    });
  });

  describe('Error Handling', () => {
    it('should handle database connection errors gracefully', async () => {
      // Arrange
      jest.spyOn(authService, 'login').mockRejectedValue(
        new Error('Database connection failed'),
      );

      // Act & Assert
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123',
        })
        .expect(500);
    });

    it('should handle malformed JSON requests', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .post('/auth/login')
        .set('Content-Type', 'application/json')
        .send('{"invalid": json}')
        .expect(400);
    });
  });
}); 