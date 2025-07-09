export interface TutorProfile {
  id: string;
  userId: string;
  name: string;
  avatar?: string;
  title: string;
  bio: string;
  specializations: string[];
  languages: string[];
  experience: number; // years
  rating: number;
  reviewCount: number;
  totalSessions: number;
  responseTime: string; // e.g., "Entro 2 ore"
  availability: TutorAvailability;
  pricing: TutorPricing;
  badges: TutorBadge[];
  isOnline: boolean;
  lastSeen?: Date;
  verificationLevel: 'basic' | 'verified' | 'expert';
}

export interface TutorAvailability {
  timezone: string;
  schedule: WeeklySchedule;
  nextAvailable?: Date;
}

export interface WeeklySchedule {
  [key: string]: TimeSlot[]; // monday, tuesday, etc.
}

export interface TimeSlot {
  start: string; // "09:00"
  end: string; // "17:00"
}

export interface TutorPricing {
  baseRate: number; // Neuroni per ora
  sessionTypes: SessionType[];
}

export interface SessionType {
  id: string;
  name: string;
  duration: number; // minutes
  price: number; // Neuroni
  description: string;
}

export interface TutorBadge {
  id: string;
  name: string;
  description: string;
  icon: string;
  color: string;
}

export interface TutoringSession {
  id: string;
  tutorId: string;
  studentId: string;
  subject: string;
  sessionType: SessionType;
  scheduledAt: Date;
  duration: number;
  status: 'pending' | 'confirmed' | 'in-progress' | 'completed' | 'cancelled';
  price: number;
  description?: string;
  materials?: string[];
  feedback?: SessionFeedback;
  canvasId?: string; // ID del canvas collaborativo
}

export interface SessionFeedback {
  rating: number;
  comment: string;
  skills: string[];
  wouldRecommend: boolean;
  createdAt: Date;
}

export interface TutoringRequest {
  id: string;
  studentId: string;
  subject: string;
  description: string;
  urgency: 'low' | 'medium' | 'high';
  budget: number;
  preferredTime?: Date;
  duration: number;
  status: 'open' | 'matched' | 'closed';
  createdAt: Date;
  responses: TutorResponse[];
}

export interface TutorResponse {
  id: string;
  tutorId: string;
  message: string;
  proposedPrice: number;
  proposedTime: Date;
  createdAt: Date;
}

export const SPECIALIZATIONS = [
  'Matematica',
  'Fisica',
  'Chimica',
  'Informatica',
  'Programmazione',
  'Web Development',
  'Data Science',
  'Machine Learning',
  'Design',
  'UI/UX',
  'Marketing',
  'Business',
  'Lingue',
  'Inglese',
  'Spagnolo',
  'Francese',
  'Tedesco',
  'Economia',
  'Finanza',
  'Psicologia',
  'Filosofia',
  'Storia',
  'Letteratura'
];

export const SESSION_TYPES = [
  {
    id: 'quick-help',
    name: 'Aiuto Rapido',
    duration: 30,
    description: 'Risolvi un dubbio specifico o un esercizio'
  },
  {
    id: 'standard-lesson',
    name: 'Lezione Standard',
    duration: 60,
    description: 'Approfondimento di un argomento'
  },
  {
    id: 'intensive-session',
    name: 'Sessione Intensiva',
    duration: 90,
    description: 'Studio approfondito e pratica'
  },
  {
    id: 'exam-prep',
    name: 'Preparazione Esame',
    duration: 120,
    description: 'Preparazione mirata per esami'
  }
];