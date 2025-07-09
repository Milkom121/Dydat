/**
 * @fileoverview Sistema di tipi per i corsi
 * Gestisce corsi, lezioni, progressi e marketplace
 */

import { User } from './auth';

// ============================================================================
// TIPI BASE CORSI
// ============================================================================

/**
 * Stato di pubblicazione del corso
 */
export type CourseStatus = 
  | 'draft'         // Bozza
  | 'review'        // In revisione
  | 'published'     // Pubblicato
  | 'archived'      // Archiviato
  | 'suspended';    // Sospeso

/**
 * Livello di difficoltà del corso
 */
export type CourseLevel = 
  | 'beginner'      // Principiante
  | 'intermediate'  // Intermedio
  | 'advanced'      // Avanzato
  | 'expert';       // Esperto

/**
 * Tipo di corso
 */
export type CourseType = 
  | 'video'         // Video corso
  | 'text'          // Corso testuale
  | 'interactive'   // Interattivo
  | 'mixed'         // Misto
  | 'live';         // Live

/**
 * Modalità di accesso
 */
export type AccessMode = 
  | 'free'          // Gratuito
  | 'paid'          // A pagamento
  | 'subscription'  // Abbonamento
  | 'organization'; // Organizzazione

// ============================================================================
// STRUTTURA CORSO
// ============================================================================

/**
 * Corso principale
 */
export interface Course {
  id: string;
  title: string;
  description: string;
  shortDescription: string;
  
  // Metadata
  slug: string;
  tags: string[];
  categories: CourseCategory[];
  language: string;
  
  // Contenuto
  thumbnail: string;
  previewVideo?: string;
  level: CourseLevel;
  type: CourseType;
  
  // Struttura
  modules: CourseModule[];
  totalLessons: number;
  totalDuration: number; // in minuti
  
  // Creatore
  instructorId: string;
  instructor: User;
  coInstructors: User[];
  
  // Pricing
  accessMode: AccessMode;
  price: number;
  currency: string;
  discountPrice?: number;
  
  // Statistiche
  enrollmentCount: number;
  rating: number;
  reviewCount: number;
  completionRate: number;
  
  // Stato
  status: CourseStatus;
  isActive: boolean;
  isFeatured: boolean;
  
  // Requisiti
  prerequisites: string[];
  requirements: string[];
  targetAudience: string[];
  learningOutcomes: string[];
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
  publishedAt?: Date;
  lastModifiedAt: Date;
}

/**
 * Categoria del corso
 */
export interface CourseCategory {
  id: string;
  name: string;
  slug: string;
  description: string;
  icon: string;
  color: string;
  parentId?: string;
  subcategories?: CourseCategory[];
  courseCount: number;
  isActive: boolean;
}

/**
 * Modulo del corso
 */
export interface CourseModule {
  id: string;
  courseId: string;
  title: string;
  description: string;
  order: number;
  
  // Contenuto
  lessons: Lesson[];
  duration: number; // in minuti
  
  // Stato
  isLocked: boolean;
  unlockConditions: UnlockCondition[];
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Lezione
 */
export interface Lesson {
  id: string;
  moduleId: string;
  title: string;
  description: string;
  order: number;
  
  // Contenuto
  type: LessonType;
  content: LessonContent;
  duration: number; // in minuti
  
  // Risorse
  resources: LessonResource[];
  attachments: LessonAttachment[];
  
  // Interattività
  quiz?: Quiz;
  assignments: Assignment[];
  
  // Stato
  isPreview: boolean;
  isLocked: boolean;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Tipo di lezione
 */
export type LessonType = 
  | 'video'         // Video
  | 'text'          // Testo
  | 'audio'         // Audio
  | 'interactive'   // Interattivo
  | 'quiz'          // Quiz
  | 'assignment'    // Compito
  | 'live';         // Live

/**
 * Contenuto della lezione
 */
export interface LessonContent {
  type: LessonType;
  data: VideoContent | TextContent | AudioContent | InteractiveContent;
}

export interface VideoContent {
  videoUrl: string;
  thumbnailUrl: string;
  duration: number;
  quality: string[];
  subtitles: Subtitle[];
  chapters: VideoChapter[];
}

export interface TextContent {
  content: string; // HTML o Markdown
  estimatedReadingTime: number;
  wordCount: number;
}

export interface AudioContent {
  audioUrl: string;
  duration: number;
  transcript?: string;
}

export interface InteractiveContent {
  type: 'simulation' | 'exercise' | 'game' | 'demo';
  url: string;
  instructions: string;
  completionCriteria: string;
}

/**
 * Sottotitoli
 */
export interface Subtitle {
  language: string;
  url: string;
  isDefault: boolean;
}

/**
 * Capitolo video
 */
export interface VideoChapter {
  id: string;
  title: string;
  startTime: number; // in secondi
  endTime: number;
  description?: string;
}

/**
 * Risorsa della lezione
 */
export interface LessonResource {
  id: string;
  lessonId: string;
  title: string;
  description: string;
  type: 'link' | 'document' | 'tool' | 'reference';
  url: string;
  isExternal: boolean;
  order: number;
}

/**
 * Allegato della lezione
 */
export interface LessonAttachment {
  id: string;
  lessonId: string;
  name: string;
  type: string;
  url: string;
  size: number;
  downloadCount: number;
  uploadedAt: Date;
}

// ============================================================================
// QUIZ E ASSIGNMENTS
// ============================================================================

/**
 * Quiz
 */
export interface Quiz {
  id: string;
  lessonId: string;
  title: string;
  description: string;
  
  // Configurazione
  timeLimit?: number; // in minuti
  maxAttempts: number;
  passingScore: number;
  isRandomized: boolean;
  
  // Domande
  questions: QuizQuestion[];
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Domanda del quiz
 */
export interface QuizQuestion {
  id: string;
  quizId: string;
  type: QuestionType;
  question: string;
  explanation?: string;
  points: number;
  order: number;
  
  // Opzioni (per multiple choice)
  options?: QuestionOption[];
  
  // Risposta corretta
  correctAnswer: string | string[];
  
  // Media
  image?: string;
  video?: string;
  audio?: string;
}

/**
 * Tipo di domanda
 */
export type QuestionType = 
  | 'multiple_choice'   // Scelta multipla
  | 'true_false'        // Vero/Falso
  | 'short_answer'      // Risposta breve
  | 'essay'             // Saggio
  | 'fill_blank'        // Riempi gli spazi
  | 'matching'          // Abbinamento
  | 'ordering';         // Ordinamento

/**
 * Opzione della domanda
 */
export interface QuestionOption {
  id: string;
  text: string;
  isCorrect: boolean;
  explanation?: string;
  order: number;
}

/**
 * Assignment/Compito
 */
export interface Assignment {
  id: string;
  lessonId: string;
  title: string;
  description: string;
  instructions: string;
  
  // Configurazione
  dueDate?: Date;
  maxScore: number;
  submissionType: 'text' | 'file' | 'url' | 'mixed';
  allowedFileTypes?: string[];
  maxFileSize?: number;
  
  // Valutazione
  rubric?: AssignmentRubric;
  isAutoGraded: boolean;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Rubrica di valutazione
 */
export interface AssignmentRubric {
  id: string;
  assignmentId: string;
  criteria: RubricCriterion[];
  totalPoints: number;
}

/**
 * Criterio della rubrica
 */
export interface RubricCriterion {
  id: string;
  name: string;
  description: string;
  maxPoints: number;
  levels: RubricLevel[];
}

/**
 * Livello della rubrica
 */
export interface RubricLevel {
  id: string;
  name: string;
  description: string;
  points: number;
}

// ============================================================================
// PROGRESSO E COMPLETAMENTO
// ============================================================================

/**
 * Iscrizione al corso
 */
export interface CourseEnrollment {
  id: string;
  courseId: string;
  course: Course;
  studentId: string;
  student: User;
  
  // Progresso
  progress: number; // percentuale 0-100
  completedLessons: string[];
  currentLessonId?: string;
  
  // Tempo
  totalTimeSpent: number; // in minuti
  lastAccessedAt: Date;
  
  // Stato
  status: EnrollmentStatus;
  startedAt: Date;
  completedAt?: Date;
  
  // Certificato
  certificate?: Certificate;
  
  // Metadata
  enrolledAt: Date;
  updatedAt: Date;
}

/**
 * Stato dell'iscrizione
 */
export type EnrollmentStatus = 
  | 'active'        // Attivo
  | 'completed'     // Completato
  | 'paused'        // In pausa
  | 'dropped'       // Abbandonato
  | 'expired';      // Scaduto

/**
 * Progresso della lezione
 */
export interface LessonProgress {
  id: string;
  lessonId: string;
  studentId: string;
  enrollmentId: string;
  
  // Progresso
  progress: number; // percentuale 0-100
  isCompleted: boolean;
  timeSpent: number; // in minuti
  
  // Interazioni
  lastPosition?: number; // per video/audio
  bookmarks: LessonBookmark[];
  notes: LessonNote[];
  
  // Quiz e assignments
  quizAttempts: QuizAttempt[];
  assignmentSubmissions: AssignmentSubmission[];
  
  // Metadata
  startedAt: Date;
  completedAt?: Date;
  lastAccessedAt: Date;
}

/**
 * Segnalibro della lezione
 */
export interface LessonBookmark {
  id: string;
  lessonId: string;
  studentId: string;
  title: string;
  description?: string;
  position: number; // posizione nel video/audio
  createdAt: Date;
}

/**
 * Nota della lezione
 */
export interface LessonNote {
  id: string;
  lessonId: string;
  studentId: string;
  content: string;
  position?: number; // posizione nel video/audio
  isPrivate: boolean;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Tentativo di quiz
 */
export interface QuizAttempt {
  id: string;
  quizId: string;
  studentId: string;
  
  // Risultati
  score: number;
  maxScore: number;
  percentage: number;
  isPassed: boolean;
  
  // Risposte
  answers: QuizAnswer[];
  
  // Tempo
  timeSpent: number; // in secondi
  startedAt: Date;
  submittedAt: Date;
}

/**
 * Risposta del quiz
 */
export interface QuizAnswer {
  id: string;
  attemptId: string;
  questionId: string;
  answer: string | string[];
  isCorrect: boolean;
  points: number;
  timeSpent: number; // in secondi
}

/**
 * Submission assignment
 */
export interface AssignmentSubmission {
  id: string;
  assignmentId: string;
  studentId: string;
  
  // Contenuto
  content?: string;
  files: SubmissionFile[];
  urls: string[];
  
  // Valutazione
  score?: number;
  maxScore: number;
  feedback?: string;
  rubricScores?: RubricScore[];
  
  // Stato
  status: SubmissionStatus;
  
  // Metadata
  submittedAt: Date;
  gradedAt?: Date;
  gradedBy?: string;
}

/**
 * Stato della submission
 */
export type SubmissionStatus = 
  | 'draft'         // Bozza
  | 'submitted'     // Inviata
  | 'graded'        // Valutata
  | 'returned'      // Restituita
  | 'late';         // In ritardo

/**
 * File della submission
 */
export interface SubmissionFile {
  id: string;
  submissionId: string;
  name: string;
  type: string;
  url: string;
  size: number;
  uploadedAt: Date;
}

/**
 * Punteggio della rubrica
 */
export interface RubricScore {
  criterionId: string;
  levelId: string;
  points: number;
  feedback?: string;
}

// ============================================================================
// CERTIFICATI
// ============================================================================

/**
 * Certificato
 */
export interface Certificate {
  id: string;
  courseId: string;
  course: Course;
  studentId: string;
  student: User;
  
  // Dettagli
  certificateNumber: string;
  title: string;
  description: string;
  
  // Design
  templateId: string;
  backgroundImage: string;
  
  // Validazione
  issuedAt: Date;
  expiresAt?: Date;
  isValid: boolean;
  
  // Verifica
  verificationCode: string;
  verificationUrl: string;
  
  // Metadata
  createdAt: Date;
  updatedAt: Date;
}

// ============================================================================
// CONDIZIONI E UNLOCK
// ============================================================================

/**
 * Condizione di sblocco
 */
export interface UnlockCondition {
  id: string;
  type: UnlockConditionType;
  targetId: string; // ID della risorsa target
  value?: number;
  operator?: 'eq' | 'gt' | 'gte' | 'lt' | 'lte';
}

/**
 * Tipo di condizione di sblocco
 */
export type UnlockConditionType = 
  | 'lesson_completed'      // Lezione completata
  | 'quiz_passed'           // Quiz superato
  | 'assignment_submitted'  // Assignment inviato
  | 'time_spent'            // Tempo trascorso
  | 'score_achieved'        // Punteggio raggiunto
  | 'date_reached';         // Data raggiunta 