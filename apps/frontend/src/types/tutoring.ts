/**
 * @fileoverview Sistema di tipi per il tutoring
 * Gestisce tutor, studenti, sessioni e prenotazioni
 */

import { User } from './auth';

// ============================================================================
// TIPI BASE TUTORING
// ============================================================================

/**
 * Stato di una sessione di tutoring
 */
export type TutoringSessionStatus = 
  | 'scheduled'     // Programmata
  | 'in_progress'   // In corso
  | 'completed'     // Completata
  | 'cancelled'     // Cancellata
  | 'no_show'       // Non presentato
  | 'rescheduled';  // Riprogrammata

/**
 * Tipo di sessione di tutoring
 */
export type SessionType = 
  | 'individual'    // Individuale
  | 'group'         // Gruppo
  | 'workshop'      // Workshop
  | 'consultation'; // Consultazione

/**
 * Modalità di erogazione
 */
export type DeliveryMode = 
  | 'online'        // Online
  | 'in_person'     // In presenza
  | 'hybrid';       // Ibrido

/**
 * Livello di difficoltà
 */
export type DifficultyLevel = 
  | 'beginner'      // Principiante
  | 'intermediate'  // Intermedio
  | 'advanced'      // Avanzato
  | 'expert';       // Esperto

// ============================================================================
// PROFILO TUTOR
// ============================================================================

/**
 * Specializzazione del tutor
 */
export interface TutorSpecialization {
  id: string;
  name: string;
  category: string;
  subcategory?: string;
  level: DifficultyLevel;
  yearsOfExperience: number;
  certifications: string[];
  description: string;
}

/**
 * Disponibilità del tutor
 */
export interface TutorAvailability {
  id: string;
  tutorId: string;
  dayOfWeek: number; // 0 = Domenica, 1 = Lunedì, etc.
  startTime: string; // HH:MM format
  endTime: string;   // HH:MM format
  timezone: string;
  isRecurring: boolean;
  validFrom: Date;
  validUntil?: Date;
  maxBookingsPerSlot: number;
  slotDuration: number; // in minuti
}

/**
 * Profilo completo del tutor
 */
export interface TutorProfile {
  id: string;
  userId: string;
  user: User;
  
  // Informazioni professionali
  title: string;
  bio: string;
  specializations: TutorSpecialization[];
  languages: string[];
  education: Education[];
  experience: Experience[];
  
  // Valutazioni e statistiche
  rating: number;
  totalReviews: number;
  totalSessions: number;
  totalStudents: number;
  successRate: number;
  
  // Prezzi e disponibilità
  hourlyRate: number;
  currency: string;
  availability: TutorAvailability[];
  deliveryModes: DeliveryMode[];
  
  // Configurazioni
  isActive: boolean;
  isVerified: boolean;
  autoAcceptBookings: boolean;
  maxStudentsPerSession: number;
  cancellationPolicy: string;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Educazione del tutor
 */
export interface Education {
  id: string;
  institution: string;
  degree: string;
  fieldOfStudy: string;
  startDate: Date;
  endDate?: Date;
  description?: string;
  grade?: string;
  isVerified: boolean;
}

/**
 * Esperienza lavorativa del tutor
 */
export interface Experience {
  id: string;
  company: string;
  position: string;
  startDate: Date;
  endDate?: Date;
  description: string;
  skills: string[];
  isCurrentPosition: boolean;
}

// ============================================================================
// SESSIONI DI TUTORING
// ============================================================================

/**
 * Sessione di tutoring
 */
export interface TutoringSession {
  id: string;
  tutorId: string;
  tutor: TutorProfile;
  studentId: string;
  student: User;
  
  // Dettagli sessione
  title: string;
  description: string;
  subject: string;
  topics: string[];
  
  // Scheduling
  scheduledAt: Date;
  duration: number; // in minuti
  timezone: string;
  
  // Modalità e tipo
  type: SessionType;
  deliveryMode: DeliveryMode;
  difficultyLevel: DifficultyLevel;
  
  // Stato e prezzo
  status: TutoringSessionStatus;
  price: number;
  currency: string;
  
  // Link e risorse
  meetingLink?: string;
  meetingPassword?: string;
  materials: SessionMaterial[];
  
  // Feedback
  tutorFeedback?: SessionFeedback;
  studentFeedback?: SessionFeedback;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
  completedAt?: Date;
  cancelledAt?: Date;
  cancellationReason?: string;
}

/**
 * Materiale della sessione
 */
export interface SessionMaterial {
  id: string;
  sessionId: string;
  name: string;
  type: 'document' | 'video' | 'audio' | 'image' | 'link' | 'other';
  url: string;
  size?: number;
  uploadedBy: 'tutor' | 'student';
  uploadedAt: Date;
}

/**
 * Feedback della sessione
 */
export interface SessionFeedback {
  id: string;
  sessionId: string;
  rating: number; // 1-5
  comment: string;
  strengths: string[];
  improvements: string[];
  wouldRecommend: boolean;
  createdAt: Date;
}

// ============================================================================
// RICHIESTE E PRENOTAZIONI
// ============================================================================

/**
 * Stato della richiesta di tutoring
 */
export type TutoringRequestStatus = 
  | 'pending'       // In attesa
  | 'accepted'      // Accettata
  | 'rejected'      // Rifiutata
  | 'cancelled'     // Cancellata
  | 'expired';      // Scaduta

/**
 * Richiesta di tutoring
 */
export interface TutoringRequest {
  id: string;
  studentId: string;
  student: User;
  tutorId: string;
  tutor: TutorProfile;
  
  // Dettagli richiesta
  subject: string;
  topics: string[];
  description: string;
  difficultyLevel: DifficultyLevel;
  
  // Preferenze
  preferredDates: Date[];
  preferredDuration: number;
  deliveryMode: DeliveryMode;
  sessionType: SessionType;
  maxPrice: number;
  
  // Stato
  status: TutoringRequestStatus;
  
  // Messaggi
  messages: RequestMessage[];
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
  expiresAt: Date;
  respondedAt?: Date;
}

/**
 * Messaggio nella richiesta
 */
export interface RequestMessage {
  id: string;
  requestId: string;
  senderId: string;
  sender: User;
  content: string;
  attachments: MessageAttachment[];
  createdAt: Date;
}

/**
 * Allegato del messaggio
 */
export interface MessageAttachment {
  id: string;
  messageId: string;
  name: string;
  type: string;
  url: string;
  size: number;
}

// ============================================================================
// RICERCHE E FILTRI
// ============================================================================

/**
 * Filtri per la ricerca tutor
 */
export interface TutorSearchFilters {
  query?: string;
  subjects?: string[];
  specializations?: string[];
  languages?: string[];
  deliveryModes?: DeliveryMode[];
  difficultyLevels?: DifficultyLevel[];
  priceRange?: {
    min: number;
    max: number;
  };
  rating?: number;
  availability?: {
    date: Date;
    timeSlots: string[];
  };
  location?: {
    city?: string;
    country?: string;
    radius?: number; // in km
  };
  isVerified?: boolean;
  sortBy?: 'rating' | 'price' | 'experience' | 'reviews' | 'availability';
  sortOrder?: 'asc' | 'desc';
}

/**
 * Risultato della ricerca tutor
 */
export interface TutorSearchResult {
  tutor: TutorProfile;
  matchScore: number;
  availableSlots: AvailableSlot[];
  distance?: number; // in km se location-based
}

/**
 * Slot disponibile
 */
export interface AvailableSlot {
  date: Date;
  startTime: string;
  endTime: string;
  duration: number;
  price: number;
  maxStudents: number;
  currentBookings: number;
}

// ============================================================================
// STATISTICHE E ANALYTICS
// ============================================================================

/**
 * Statistiche del tutor
 */
export interface TutorStats {
  tutorId: string;
  period: {
    startDate: Date;
    endDate: Date;
  };
  
  // Sessioni
  totalSessions: number;
  completedSessions: number;
  cancelledSessions: number;
  noShowSessions: number;
  
  // Studenti
  totalStudents: number;
  newStudents: number;
  returningStudents: number;
  
  // Valutazioni
  averageRating: number;
  totalReviews: number;
  ratingDistribution: Record<number, number>;
  
  // Guadagni
  totalEarnings: number;
  averageSessionPrice: number;
  
  // Tempo
  totalTeachingHours: number;
  averageSessionDuration: number;
  
  // Materie più richieste
  popularSubjects: SubjectStats[];
  
  // Performance
  responseRate: number;
  acceptanceRate: number;
  completionRate: number;
  onTimeRate: number;
}

/**
 * Statistiche per materia
 */
export interface SubjectStats {
  subject: string;
  sessionsCount: number;
  averageRating: number;
  totalEarnings: number;
  growthRate: number;
}

/**
 * Statistiche dello studente
 */
export interface StudentStats {
  studentId: string;
  period: {
    startDate: Date;
    endDate: Date;
  };
  
  // Sessioni
  totalSessions: number;
  completedSessions: number;
  cancelledSessions: number;
  
  // Apprendimento
  totalLearningHours: number;
  averageSessionDuration: number;
  subjectsStudied: string[];
  
  // Spesa
  totalSpent: number;
  averageSessionCost: number;
  
  // Progressi
  completionRate: number;
  averageRating: number; // rating dato ai tutor
  
  // Tutor
  totalTutors: number;
  favoriteTutors: string[];
} 