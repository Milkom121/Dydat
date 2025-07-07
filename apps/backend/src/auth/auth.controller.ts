import { Controller, Post, Get, Body, ValidationPipe, UseGuards, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { Roles } from './decorators/roles.decorator';
import { User, UserRole } from './entities/user.entity';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body(ValidationPipe) registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body(ValidationPipe) loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  async getProfile(@CurrentUser() user: User) {
    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.fullName,
      role: user.role,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    };
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getCurrentUser(@CurrentUser() user: User) {
    return {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      role: user.role,
      permissions: {
        canCreateContent: user.canCreateContent(),
        hasAdminPrivileges: user.hasAdminPrivileges(),
        isStudent: user.isStudent(),
        isCreator: user.isCreator(),
        isAdmin: user.isAdmin(),
      },
    };
  }

  // Endpoint di test per verificare i ruoli
  @Get('admin-only')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  async adminOnly(@CurrentUser() user: User) {
    return {
      message: 'This endpoint is only accessible by admins!',
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
      },
    };
  }

  @Get('creator-or-admin')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.CREATOR, UserRole.ADMIN)
  async creatorOrAdmin(@CurrentUser() user: User) {
    return {
      message: 'This endpoint is accessible by creators and admins!',
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
      },
    };
  }

  @Get('authenticated-only')
  @UseGuards(JwtAuthGuard)
  async authenticatedOnly(@CurrentUser() user: User) {
    return {
      message: 'This endpoint requires authentication but no specific role!',
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
      },
    };
  }
} 