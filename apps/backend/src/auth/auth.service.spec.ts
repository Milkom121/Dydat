import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException, ConflictException, NotFoundException } from '@nestjs/common';
import { Repository } from 'typeorm';
import { AuthService } from './auth.service';
import { User, UserRole } from './entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcryptjs';

// Mock bcrypt
jest.mock('bcryptjs');
const mockedBcrypt = bcrypt as jest.Mocked<typeof bcrypt>;

describe('AuthService', () => {
  let service: AuthService;
  let userRepository: jest.Mocked<Repository<User>>;
  let jwtService: jest.Mocked<JwtService>;

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

  const mockRegisterDto: RegisterDto = {
    email: 'test@example.com',
    password: 'password123',
    firstName: 'Mario',
    lastName: 'Rossi',
    role: UserRole.STUDENT,
  };

  const mockLoginDto: LoginDto = {
    email: 'test@example.com',
    password: 'password123',
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
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
            createQueryBuilder: jest.fn(() => ({
              where: jest.fn().mockReturnThis(),
              getOne: jest.fn(),
              getMany: jest.fn(),
            })),
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
    }).compile();

    service = module.get<AuthService>(AuthService);
    userRepository = module.get(getRepositoryToken(User));
    jwtService = module.get(JwtService);

    // Setup default bcrypt mocks
    mockedBcrypt.hash.mockResolvedValue('$2b$12$hashedPassword');
    mockedBcrypt.compare.mockResolvedValue(true);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should successfully register a new user', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null); // Email not exists
      userRepository.create.mockReturnValue(mockUser);
      userRepository.save.mockResolvedValue(mockUser);
      jwtService.sign.mockReturnValue('jwt-token');

      // Act
      const result = await service.register(mockRegisterDto);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { email: mockRegisterDto.email },
      });
      expect(mockedBcrypt.hash).toHaveBeenCalledWith(mockRegisterDto.password, 12);
      expect(userRepository.create).toHaveBeenCalledWith({
        ...mockRegisterDto,
        password: '$2b$12$hashedPassword',
      });
      expect(userRepository.save).toHaveBeenCalledWith(mockUser);
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: mockUser.id,
        email: mockUser.email,
        role: mockUser.role,
      });
      expect(result).toEqual({
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      });
    });

    it('should throw ConflictException if email already exists', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);

      // Act & Assert
      await expect(service.register(mockRegisterDto)).rejects.toThrow(
        new ConflictException('Email già in uso'),
      );
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { email: mockRegisterDto.email },
      });
      expect(userRepository.create).not.toHaveBeenCalled();
    });

    it('should handle database errors during registration', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);
      userRepository.save.mockRejectedValue(new Error('Database error'));

      // Act & Assert
      await expect(service.register(mockRegisterDto)).rejects.toThrow('Database error');
    });

    it('should register user with CREATOR role', async () => {
      // Arrange
      const creatorDto = { ...mockRegisterDto, role: UserRole.CREATOR };
      const creatorUser = { ...mockUser, role: UserRole.CREATOR };
      
      userRepository.findOne.mockResolvedValue(null);
      userRepository.create.mockReturnValue(creatorUser);
      userRepository.save.mockResolvedValue(creatorUser);
      jwtService.sign.mockReturnValue('jwt-token');

      // Act
      const result = await service.register(creatorDto);

      // Assert
      expect(userRepository.create).toHaveBeenCalledWith({
        ...creatorDto,
        password: '$2b$12$hashedPassword',
      });
      expect(result.user.role).toBe(UserRole.CREATOR);
    });
  });

  describe('login', () => {
    it('should successfully login with valid credentials', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);
      mockedBcrypt.compare.mockResolvedValue(true);
      jwtService.sign.mockReturnValue('jwt-token');

      // Act
      const result = await service.login(mockLoginDto);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { email: mockLoginDto.email },
      });
      expect(mockedBcrypt.compare).toHaveBeenCalledWith(
        mockLoginDto.password,
        mockUser.password,
      );
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: mockUser.id,
        email: mockUser.email,
        role: mockUser.role,
      });
      expect(result).toEqual({
        access_token: 'jwt-token',
        user: mockUser.toJSON(),
      });
    });

    it('should throw UnauthorizedException if user not found', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.login(mockLoginDto)).rejects.toThrow(
        new UnauthorizedException('Credenziali non valide'),
      );
      expect(mockedBcrypt.compare).not.toHaveBeenCalled();
    });

    it('should throw UnauthorizedException if password is invalid', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);
      mockedBcrypt.compare.mockResolvedValue(false);

      // Act & Assert
      await expect(service.login(mockLoginDto)).rejects.toThrow(
        new UnauthorizedException('Credenziali non valide'),
      );
      expect(mockedBcrypt.compare).toHaveBeenCalledWith(
        mockLoginDto.password,
        mockUser.password,
      );
    });

    it('should throw UnauthorizedException if user is inactive', async () => {
      // Arrange
      const inactiveUser = { ...mockUser, isActive: false };
      userRepository.findOne.mockResolvedValue(inactiveUser);

      // Act & Assert
      await expect(service.login(mockLoginDto)).rejects.toThrow(
        new UnauthorizedException('Account disattivato'),
      );
      expect(mockedBcrypt.compare).not.toHaveBeenCalled();
    });
  });

  describe('validateUser', () => {
    const mockPayload = {
      sub: mockUser.id,
      email: mockUser.email,
      role: mockUser.role,
    };

    it('should return user for valid JWT payload', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);

      // Act
      const result = await service.validateUser(mockPayload);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { id: mockPayload.sub },
      });
      expect(result).toBe(mockUser);
    });

    it('should return null if user not found', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);

      // Act
      const result = await service.validateUser(mockPayload);

      // Assert
      expect(result).toBeNull();
    });

    it('should return null if user is inactive', async () => {
      // Arrange
      const inactiveUser = { ...mockUser, isActive: false };
      userRepository.findOne.mockResolvedValue(inactiveUser);

      // Act
      const result = await service.validateUser(mockPayload);

      // Assert
      expect(result).toBeNull();
    });
  });

  describe('updateProfile', () => {
    it('should update user profile successfully', async () => {
      // Arrange
      const updateData = { firstName: 'Luigi', lastName: 'Verdi' };
      const updatedUser = { ...mockUser, ...updateData };
      
      userRepository.findOne.mockResolvedValue(mockUser);
      userRepository.save.mockResolvedValue(updatedUser);

      // Act
      const result = await service.updateProfile(mockUser.id, updateData);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { id: mockUser.id },
      });
      expect(userRepository.save).toHaveBeenCalledWith({
        ...mockUser,
        ...updateData,
      });
      expect(result).toBe(updatedUser);
    });

    it('should throw NotFoundException if user not found', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(
        service.updateProfile(mockUser.id, { firstName: 'Luigi' }),
      ).rejects.toThrow(new NotFoundException('Utente non trovato'));
    });
  });

  describe('changePassword', () => {
    it('should change password successfully', async () => {
      // Arrange
      const currentPassword = 'oldPassword';
      const newPassword = 'newPassword123';
      
      userRepository.findOne.mockResolvedValue(mockUser);
      mockedBcrypt.compare.mockResolvedValue(true);
      mockedBcrypt.hash.mockResolvedValue('$2b$12$newHashedPassword');

      // Act
      await service.changePassword(mockUser.id, currentPassword, newPassword);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { id: mockUser.id },
      });
      expect(mockedBcrypt.compare).toHaveBeenCalledWith(
        currentPassword,
        mockUser.password,
      );
      expect(mockedBcrypt.hash).toHaveBeenCalledWith(newPassword, 12);
      expect(userRepository.save).toHaveBeenCalledWith({
        ...mockUser,
        password: '$2b$12$newHashedPassword',
      });
    });

    it('should throw UnauthorizedException for invalid current password', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);
      mockedBcrypt.compare.mockResolvedValue(false);

      // Act & Assert
      await expect(
        service.changePassword(mockUser.id, 'wrongPassword', 'newPassword'),
      ).rejects.toThrow(new UnauthorizedException('Password attuale non corretta'));
    });
  });

  describe('deleteAccount', () => {
    it('should delete account successfully', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);
      userRepository.delete.mockResolvedValue({ affected: 1, raw: {} });

      // Act
      await service.deleteAccount(mockUser.id);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { id: mockUser.id },
      });
      expect(userRepository.delete).toHaveBeenCalledWith(mockUser.id);
    });

    it('should throw NotFoundException if user not found', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);

      // Act & Assert
      await expect(service.deleteAccount(mockUser.id)).rejects.toThrow(
        new NotFoundException('Utente non trovato'),
      );
    });
  });

  describe('getAllUsers', () => {
    it('should return all users for admin', async () => {
      // Arrange
      const users = [mockUser, { ...mockUser, id: 'another-id' }];
      userRepository.find.mockResolvedValue(users);

      // Act
      const result = await service.getAllUsers();

      // Assert
      expect(userRepository.find).toHaveBeenCalledWith({
        select: ['id', 'email', 'firstName', 'lastName', 'role', 'isActive', 'createdAt'],
        order: { createdAt: 'DESC' },
      });
      expect(result).toBe(users);
    });

    it('should return empty array if no users found', async () => {
      // Arrange
      userRepository.find.mockResolvedValue([]);

      // Act
      const result = await service.getAllUsers();

      // Assert
      expect(result).toEqual([]);
    });
  });

  describe('edge cases and error handling', () => {
    it('should handle bcrypt hashing errors', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);
      mockedBcrypt.hash.mockRejectedValue(new Error('Hashing failed'));

      // Act & Assert
      await expect(service.register(mockRegisterDto)).rejects.toThrow('Hashing failed');
    });

    it('should handle JWT signing errors', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);
      userRepository.create.mockReturnValue(mockUser);
      userRepository.save.mockResolvedValue(mockUser);
      jwtService.sign.mockImplementation(() => {
        throw new Error('JWT signing failed');
      });

      // Act & Assert
      await expect(service.register(mockRegisterDto)).rejects.toThrow('JWT signing failed');
    });

    it('should handle concurrent registration attempts', async () => {
      // Arrange - Simula race condition
      userRepository.findOne.mockResolvedValueOnce(null).mockResolvedValueOnce(mockUser);
      userRepository.save.mockRejectedValue({
        code: '23505', // PostgreSQL unique violation
        message: 'duplicate key value violates unique constraint',
      });

      // Act & Assert
      await expect(service.register(mockRegisterDto)).rejects.toThrow();
    });
  });

  describe('performance and optimization', () => {
    it('should use proper database queries for findUserByEmail', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(mockUser);

      // Act
      await service.login(mockLoginDto);

      // Assert
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { email: mockLoginDto.email },
      });
      expect(userRepository.findOne).toHaveBeenCalledTimes(1);
    });

    it('should not fetch sensitive data in getAllUsers', async () => {
      // Act
      await service.getAllUsers();

      // Assert
      expect(userRepository.find).toHaveBeenCalledWith({
        select: ['id', 'email', 'firstName', 'lastName', 'role', 'isActive', 'createdAt'],
        order: { createdAt: 'DESC' },
      });
      // Verifica che password non sia inclusa nel select
      const selectFields = userRepository.find.mock.calls[0][0].select;
      expect(selectFields).not.toContain('password');
    });
  });
}); 