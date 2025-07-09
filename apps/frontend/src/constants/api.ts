/**
 * API Configuration Constants for Dydat Frontend
 * Integrates with NestJS Backend running on localhost:3001 (development)
 */

// Base API URL - Environment dependent
export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

// API Routes - Auth Module
export const AUTH_ENDPOINTS = {
  REGISTER: '/auth/register',
  LOGIN: '/auth/login',
  PROFILE: '/auth/profile',
  UPDATE_PROFILE: '/auth/profile',
  CHANGE_PASSWORD: '/auth/change-password',
  DELETE_ACCOUNT: '/auth/delete-account',
  ADMIN_USERS: '/auth/admin/users',
} as const;

// API Routes - Future Modules (placeholder for expansion)
export const COURSE_ENDPOINTS = {
  LIST: '/courses',
  CREATE: '/courses',
  GET_BY_ID: '/courses/:id',
  UPDATE: '/courses/:id',
  DELETE: '/courses/:id',
  ENROLL: '/courses/:id/enroll',
} as const;

export const USER_ENDPOINTS = {
  DASHBOARD: '/users/dashboard',
  ACHIEVEMENTS: '/users/achievements',
  PROGRESS: '/users/progress',
} as const;

// HTTP Status Codes
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
} as const;

// Request timeouts
export const API_TIMEOUTS = {
  DEFAULT: 10000, // 10 seconds
  UPLOAD: 60000,  // 1 minute for file uploads
  AUTH: 5000,     // 5 seconds for auth requests
} as const;

// Rate limiting info (matches backend configuration)
export const RATE_LIMITS = {
  LOGIN: 5,           // 5 attempts per minute
  REGISTER: 3,        // 3 attempts per minute
  CHANGE_PASSWORD: 3, // 3 attempts per hour
  DELETE_ACCOUNT: 1,  // 1 attempt per hour
  PROFILE: 30,        // 30 requests per minute
} as const;

// Error messages
export const API_ERROR_MESSAGES = {
  NETWORK_ERROR: 'Errore di connessione. Verifica la tua connessione internet.',
  TIMEOUT_ERROR: 'La richiesta è scaduta. Riprova più tardi.',
  UNAUTHORIZED: 'Sessione scaduta. Effettua di nuovo il login.',
  FORBIDDEN: 'Non hai i permessi per eseguire questa azione.',
  NOT_FOUND: 'Risorsa non trovata.',
  CONFLICT: 'Conflitto nei dati. Riprova con informazioni diverse.',
  VALIDATION_ERROR: 'Dati non validi. Controlla i campi inseriti.',
  RATE_LIMIT: 'Troppe richieste. Attendi prima di riprovare.',
  SERVER_ERROR: 'Errore del server. Riprova più tardi.',
  UNKNOWN_ERROR: 'Errore sconosciuto. Contatta il supporto se persiste.',
} as const;

// Content types
export const CONTENT_TYPES = {
  JSON: 'application/json',
  FORM_DATA: 'multipart/form-data',
  URL_ENCODED: 'application/x-www-form-urlencoded',
} as const;

// Local storage keys
export const STORAGE_KEYS = {
  ACCESS_TOKEN: 'dydat_access_token',
  REFRESH_TOKEN: 'dydat_refresh_token',
  USER_DATA: 'dydat_user_data',
  THEME: 'dydat_theme',
  LANGUAGE: 'dydat_language',
} as const; 