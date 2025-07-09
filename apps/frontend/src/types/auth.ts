/**
 * Authentication Types for Dydat Frontend
 * Mirrors the backend NestJS DTOs and entities
 */

// User roles enum - matches backend UserRole enum
export enum UserRole {
  STUDENT = 'STUDENT',
  CREATOR = 'CREATOR',
  ADMIN = 'ADMIN',
}

// User entity type - matches backend User entity
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  createdAt: string;
  updatedAt: string;
}

// Auth DTOs - matches backend DTOs exactly
export interface RegisterDto {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: UserRole;
}

export interface LoginDto {
  email: string;
  password: string;
}

export interface UpdateProfileDto {
  firstName?: string;
  lastName?: string;
}

export interface ChangePasswordDto {
  currentPassword: string;
  newPassword: string;
}

// API Response types
export interface AuthResponse {
  access_token: string;
  user: User;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

// Error response type - matches backend exception filter
export interface ApiErrorResponse {
  statusCode: number;
  message: string | string[];
  error: string;
  timestamp: string;
  path: string;
}

// Auth state for store
export interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}

// Auth actions for store
export interface AuthActions {
  login: (credentials: LoginDto) => Promise<void>;
  register: (userData: RegisterDto) => Promise<void>;
  logout: () => void;
  updateProfile: (data: UpdateProfileDto) => Promise<void>;
  changePassword: (data: ChangePasswordDto) => Promise<void>;
  deleteAccount: () => Promise<void>;
  loadUserFromToken: () => void;
  refreshToken: () => Promise<void>;
}

// Combined auth store type
export interface AuthStore extends AuthState, AuthActions {}

// Role permission helpers - matches backend user entity methods
export interface UserPermissions {
  isStudent: boolean;
  isCreator: boolean;
  isAdmin: boolean;
  canCreateCourses: boolean;
  canManageUsers: boolean;
  hasPermission: (requiredRole: UserRole) => boolean;
}

// Form states
export interface LoginFormData {
  email: string;
  password: string;
  rememberMe?: boolean;
}

export interface RegisterFormData {
  email: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  acceptTerms: boolean;
}

export interface ProfileFormData {
  firstName: string;
  lastName: string;
}

export interface PasswordFormData {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

// Navigation and routing
export interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: UserRole;
  fallback?: React.ReactNode;
}

// Session management
export interface Session {
  user: User;
  token: string;
  expiresAt: number;
  refreshToken?: string;
} 