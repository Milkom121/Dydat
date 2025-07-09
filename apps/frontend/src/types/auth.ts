/**
 * @fileoverview Sistema di tipi per autenticazione, ruoli e permessi
 * Basato sul design del bolt_project con architettura robusta e modulare
 */

// ============================================================================
// TIPI BASE UTENTE
// ============================================================================

/**
 * Ruoli disponibili nel sistema Dydat
 * Ogni ruolo ha permessi specifici e accesso a funzionalità dedicate
 */
export type UserRole = 'guest' | 'student' | 'creator' | 'tutor' | 'member' | 'manager' | 'admin';

/**
 * Interfaccia per le organizzazioni
 * Supporta sia aziende che istituti educativi
 */
export interface Organization {
  id: string;
  name: string;
  type: 'company' | 'institute';
  role: 'member' | 'manager' | 'admin';
  logo?: string;
  description?: string;
  website?: string;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Interfaccia per i badge/achievements
 * Sistema di gamification per riconoscere i progressi
 */
export interface Badge {
  id: string;
  name: string;
  description: string;
  icon: string;
  category: 'learning' | 'teaching' | 'community' | 'achievement' | 'special';
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
  xpReward: number;
  earnedAt: Date;
}

/**
 * Interfaccia principale per l'utente
 * Contiene tutti i dati necessari per l'autenticazione e la personalizzazione
 */
export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  bio?: string;
  location?: string;
  website?: string;
  
  // Sistema ruoli
  primaryRole: UserRole;
  roles: UserRole[];
  
  // Organizzazioni
  organizations: Organization[];
  
  // Sistema gamification
  level: number;
  xp: number;
  neurons: number; // Valuta virtuale Dydat
  badges: Badge[];
  
  // Preferenze
  preferences: UserPreferences;
  
  // Metadata
  isEmailVerified: boolean;
  isActive: boolean;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Preferenze utente per personalizzazione
 */
export interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  language: 'it' | 'en' | 'es' | 'fr' | 'de';
  notifications: NotificationPreferences;
  privacy: PrivacyPreferences;
  learning: LearningPreferences;
}

export interface NotificationPreferences {
  email: boolean;
  push: boolean;
  courseUpdates: boolean;
  tutoringReminders: boolean;
  achievementAlerts: boolean;
  marketplaceUpdates: boolean;
}

export interface PrivacyPreferences {
  profileVisibility: 'public' | 'private' | 'connections';
  showEmail: boolean;
  showLocation: boolean;
  showLearningProgress: boolean;
}

export interface LearningPreferences {
  difficultyLevel: 'beginner' | 'intermediate' | 'advanced';
  learningStyle: 'visual' | 'auditory' | 'kinesthetic' | 'reading';
  studyReminders: boolean;
  autoPlayVideos: boolean;
  subtitles: boolean;
}

// ============================================================================
// SISTEMA PERMESSI
// ============================================================================

/**
 * Interfaccia per i permessi del sistema
 * Definisce cosa ogni ruolo può fare
 */
export interface RolePermissions {
  // Corsi
  canCreateCourses: boolean;
  canEditOwnCourses: boolean;
  canDeleteOwnCourses: boolean;
  canPublishCourses: boolean;
  canAccessPrivateCourses: boolean;
  canCommissionCourses: boolean;
  
  // Tutoring
  canOfferTutoring: boolean;
  canBookTutoring: boolean;
  canManageTutoringSessions: boolean;
  canAccessTutorAnalytics: boolean;
  
  // Organizzazione
  canManageOrganization: boolean;
  canInviteMembers: boolean;
  canManageMembers: boolean;
  canAccessOrgAnalytics: boolean;
  
  // Sistema
  canAccessAnalytics: boolean;
  canManageUsers: boolean;
  canModerateContent: boolean;
  canAccessAdminPanel: boolean;
  
  // Marketplace
  canSellCourses: boolean;
  canBuyCourses: boolean;
  canRateAndReview: boolean;
  canReportContent: boolean;
}

/**
 * Funzione per ottenere i permessi basati sui ruoli
 * @param roles - Array dei ruoli dell'utente
 * @returns Oggetto con tutti i permessi
 */
export const getRolePermissions = (roles: UserRole[]): RolePermissions => {
  const hasRole = (role: UserRole) => roles.includes(role);
  
  return {
    // Corsi
    canCreateCourses: hasRole('creator') || hasRole('admin'),
    canEditOwnCourses: hasRole('creator') || hasRole('admin'),
    canDeleteOwnCourses: hasRole('creator') || hasRole('admin'),
    canPublishCourses: hasRole('creator') || hasRole('admin'),
    canAccessPrivateCourses: hasRole('member') || hasRole('manager') || hasRole('admin'),
    canCommissionCourses: hasRole('manager') || hasRole('admin'),
    
    // Tutoring
    canOfferTutoring: hasRole('tutor') || hasRole('admin'),
    canBookTutoring: hasRole('student') || hasRole('member') || hasRole('admin'),
    canManageTutoringSessions: hasRole('tutor') || hasRole('admin'),
    canAccessTutorAnalytics: hasRole('tutor') || hasRole('admin'),
    
    // Organizzazione
    canManageOrganization: hasRole('manager') || hasRole('admin'),
    canInviteMembers: hasRole('manager') || hasRole('admin'),
    canManageMembers: hasRole('manager') || hasRole('admin'),
    canAccessOrgAnalytics: hasRole('manager') || hasRole('admin'),
    
    // Sistema
    canAccessAnalytics: hasRole('creator') || hasRole('tutor') || hasRole('manager') || hasRole('admin'),
    canManageUsers: hasRole('admin'),
    canModerateContent: hasRole('admin'),
    canAccessAdminPanel: hasRole('admin'),
    
    // Marketplace
    canSellCourses: hasRole('creator') || hasRole('admin'),
    canBuyCourses: !hasRole('guest'),
    canRateAndReview: hasRole('student') || hasRole('member') || hasRole('admin'),
    canReportContent: !hasRole('guest'),
  };
};

/**
 * Funzione per ottenere il nome visualizzato del ruolo
 * @param role - Ruolo da convertire
 * @returns Nome localizzato del ruolo
 */
export const getRoleDisplayName = (role: UserRole): string => {
  const roleNames = {
    guest: 'Ospite',
    student: 'Studente',
    creator: 'Creatore',
    tutor: 'Tutor',
    member: 'Membro Team',
    manager: 'Manager',
    admin: 'Amministratore'
  };
  return roleNames[role];
};

/**
 * Funzione per ottenere il colore del ruolo
 * @param role - Ruolo per cui ottenere il colore
 * @returns Classe CSS per il gradiente del ruolo
 */
export const getRoleColor = (role: UserRole): string => {
  const roleColors = {
    guest: 'from-stone-400 to-stone-500',
    student: 'from-blue-400 to-blue-500',
    creator: 'from-purple-400 to-purple-500',
    tutor: 'from-emerald-400 to-emerald-500',
    member: 'from-amber-400 to-amber-500',
    manager: 'from-orange-400 to-orange-500',
    admin: 'from-red-400 to-red-500'
  };
  return roleColors[role];
};

/**
 * Funzione per ottenere la descrizione del ruolo
 * @param role - Ruolo per cui ottenere la descrizione
 * @returns Descrizione del ruolo
 */
export const getRoleDescription = (role: UserRole): string => {
  const roleDescriptions = {
    guest: 'Accesso limitato alle funzionalità pubbliche',
    student: 'Accesso completo ai corsi e alle funzionalità di apprendimento',
    creator: 'Può creare e pubblicare corsi, accedere alle analytics',
    tutor: 'Può offrire sessioni di tutoraggio e gestire studenti',
    member: 'Membro di un\'organizzazione con accesso a contenuti privati',
    manager: 'Gestisce un\'organizzazione e i suoi membri',
    admin: 'Accesso completo a tutte le funzionalità del sistema'
  };
  return roleDescriptions[role];
};

// ============================================================================
// TIPI PER AUTENTICAZIONE
// ============================================================================

/**
 * Dati per il login
 */
export interface LoginCredentials {
  email: string;
  password: string;
  rememberMe?: boolean;
}

/**
 * Dati per la registrazione
 */
export interface RegisterData {
  name: string;
  email: string;
  password: string;
  confirmPassword: string;
  primaryRole: UserRole;
  acceptTerms: boolean;
  acceptPrivacy: boolean;
}

/**
 * Risposta del server per l'autenticazione
 */
export interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
  expiresIn: number;
}

/**
 * Stato dell'autenticazione
 */
export interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  token: string | null;
}

// ============================================================================
// TIPI PER SESSIONI E SICUREZZA
// ============================================================================

/**
 * Informazioni sulla sessione
 */
export interface SessionInfo {
  id: string;
  userId: string;
  deviceInfo: DeviceInfo;
  ipAddress: string;
  userAgent: string;
  isActive: boolean;
  lastActivity: Date;
  createdAt: Date;
  expiresAt: Date;
}

/**
 * Informazioni sul dispositivo
 */
export interface DeviceInfo {
  type: 'desktop' | 'mobile' | 'tablet';
  os: string;
  browser: string;
  location?: string;
}

/**
 * Log di audit per sicurezza
 */
export interface AuditLog {
  id: string;
  userId: string;
  action: string;
  resource: string;
  details: Record<string, any>;
  ipAddress: string;
  userAgent: string;
  timestamp: Date;
}

// ============================================================================
// TIPI API
// ============================================================================

/**
 * Risposta generica API
 */
export interface ApiResponse<T = any> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: string;
}

/**
 * Risposta di errore API
 */
export interface ApiErrorResponse {
  statusCode: number;
  message: string;
  error: string;
  timestamp: string;
  path: string;
}

// ============================================================================
// TIPI STORE E DTO
// ============================================================================

/**
 * DTO per login
 */
export interface LoginDto {
  email: string;
  password: string;
  rememberMe?: boolean;
}

/**
 * DTO per registrazione
 */
export interface RegisterDto {
  name: string;
  email: string;
  password: string;
  confirmPassword: string;
  primaryRole: UserRole;
  acceptTerms: boolean;
  acceptPrivacy: boolean;
}

/**
 * DTO per aggiornamento profilo
 */
export interface UpdateProfileDto {
  name?: string;
  bio?: string;
  location?: string;
  website?: string;
  avatar?: string;
  preferences?: Partial<UserPreferences>;
}

/**
 * DTO per cambio password
 */
export interface ChangePasswordDto {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

/**
 * Hook per permessi utente
 */
export interface UserPermissions extends RolePermissions {
  isAuthenticated: boolean;
  hasRole: (role: UserRole) => boolean;
  hasAnyRole: (roles: UserRole[]) => boolean;
  hasAllRoles: (roles: UserRole[]) => boolean;
}

/**
 * Interfaccia per lo store di autenticazione
 */
export interface AuthStore {
  // State
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  
  // Actions
  login: (credentials: LoginDto) => Promise<void>;
  register: (userData: RegisterDto) => Promise<void>;
  logout: () => void;
  updateProfile: (data: UpdateProfileDto) => Promise<void>;
  changePassword: (data: ChangePasswordDto) => Promise<void>;
  deleteAccount: () => Promise<void>;
  loadUserFromToken: () => void;
  refreshToken: () => Promise<void>;
}