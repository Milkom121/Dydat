import { Injectable, UnauthorizedException, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { User, UserRole } from './entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

export interface JwtPayload {
  sub: string; // user id
  email: string;
  role: UserRole;
  firstName: string;
  lastName: string;
}

export interface AuthResponse {
  access_token: string;
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    role: UserRole;
    emailVerified: boolean;
  };
}

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto): Promise<AuthResponse> {
    const { email, password, firstName, lastName, role } = registerDto;

    // Check se l'utente esiste già
    const existingUser = await this.userRepository.findOne({ where: { email } });
    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash della password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Crea nuovo utente
    const user = this.userRepository.create({
      email,
      password: hashedPassword,
      firstName,
      lastName,
      role: role || UserRole.STUDENT,
    });

    const savedUser = await this.userRepository.save(user);

    // Genera JWT
    const payload: JwtPayload = {
      sub: savedUser.id,
      email: savedUser.email,
      role: savedUser.role,
      firstName: savedUser.firstName,
      lastName: savedUser.lastName,
    };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: savedUser.id,
        email: savedUser.email,
        firstName: savedUser.firstName,
        lastName: savedUser.lastName,
        role: savedUser.role,
        emailVerified: savedUser.emailVerified,
      },
    };
  }

  async login(loginDto: LoginDto): Promise<AuthResponse> {
    const { email, password } = loginDto;

    // Trova l'utente
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verifica la password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check se l'utente è attivo
    if (!user.isActive) {
      throw new UnauthorizedException('Account is deactivated');
    }

    // Genera JWT
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      firstName: user.firstName,
      lastName: user.lastName,
    };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        emailVerified: user.emailVerified,
      },
    };
  }

  async validateUser(payload: JwtPayload): Promise<User | null> {
    const user = await this.userRepository.findOne({ 
      where: { id: payload.sub, email: payload.email } 
    });
    
    if (user && user.isActive) {
      return user;
    }
    
    return null;
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }
} 