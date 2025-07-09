import React from 'react';
import { TutorCard } from './TutorCard';
import { TutorProfile } from '../../types/tutoring';

interface TutorGridProps {
  searchQuery: string;
  filters: any;
  sortBy: string;
}

export const TutorGrid: React.FC<TutorGridProps> = ({
  searchQuery,
  filters,
  sortBy
}) => {
  // Mock tutor data
  const tutors: TutorProfile[] = [
    {
      id: '1',
      userId: 'tutor1',
      name: 'Dr. Elena Rossi',
      avatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&fit=crop',
      title: 'Esperta in Matematica e Fisica',
      bio: 'Dottorato in Fisica Teorica con 8 anni di esperienza nell\'insegnamento. Specializzata in matematica avanzata e fisica quantistica.',
      specializations: ['Matematica', 'Fisica', 'Calcolo', 'Algebra Lineare'],
      languages: ['Italiano', 'Inglese'],
      experience: 8,
      rating: 4.9,
      reviewCount: 127,
      totalSessions: 450,
      responseTime: 'Entro 1 ora',
      availability: {
        timezone: 'Europe/Rome',
        schedule: {
          monday: [{ start: '09:00', end: '18:00' }],
          tuesday: [{ start: '09:00', end: '18:00' }],
          wednesday: [{ start: '09:00', end: '18:00' }],
          thursday: [{ start: '09:00', end: '18:00' }],
          friday: [{ start: '09:00', end: '16:00' }]
        },
        nextAvailable: new Date(Date.now() + 2 * 60 * 60 * 1000) // 2 hours from now
      },
      pricing: {
        baseRate: 80,
        sessionTypes: [
          { id: '1', name: 'Aiuto Rapido', duration: 30, price: 40, description: 'Risolvi un dubbio specifico' },
          { id: '2', name: 'Lezione Standard', duration: 60, price: 80, description: 'Approfondimento completo' },
          { id: '3', name: 'Sessione Intensiva', duration: 90, price: 110, description: 'Studio approfondito' }
        ]
      },
      badges: [
        { id: '1', name: 'Top Tutor', description: 'Tra i migliori tutor della piattaforma', icon: '👑', color: 'gold' },
        { id: '2', name: 'Risposta Rapida', description: 'Risponde sempre entro 1 ora', icon: '⚡', color: 'blue' }
      ],
      isOnline: true,
      verificationLevel: 'expert'
    },
    {
      id: '2',
      userId: 'tutor2',
      name: 'Marco Bianchi',
      avatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&fit=crop',
      title: 'Full-Stack Developer & Mentor',
      bio: 'Senior Developer con 6 anni di esperienza in React, Node.js e Python. Appassionato di insegnamento e mentoring.',
      specializations: ['Programmazione', 'JavaScript', 'React', 'Node.js', 'Python'],
      languages: ['Italiano', 'Inglese'],
      experience: 6,
      rating: 4.8,
      reviewCount: 89,
      totalSessions: 320,
      responseTime: 'Entro 2 ore',
      availability: {
        timezone: 'Europe/Rome',
        schedule: {
          monday: [{ start: '18:00', end: '22:00' }],
          tuesday: [{ start: '18:00', end: '22:00' }],
          wednesday: [{ start: '18:00', end: '22:00' }],
          thursday: [{ start: '18:00', end: '22:00' }],
          saturday: [{ start: '10:00', end: '16:00' }],
          sunday: [{ start: '10:00', end: '16:00' }]
        },
        nextAvailable: new Date(Date.now() + 4 * 60 * 60 * 1000)
      },
      pricing: {
        baseRate: 60,
        sessionTypes: [
          { id: '1', name: 'Code Review', duration: 30, price: 30, description: 'Revisione del codice' },
          { id: '2', name: 'Lezione Coding', duration: 60, price: 60, description: 'Programmazione pratica' },
          { id: '3', name: 'Progetto Guidato', duration: 120, price: 100, description: 'Sviluppo progetto completo' }
        ]
      },
      badges: [
        { id: '3', name: 'Coding Expert', description: 'Esperto in programmazione', icon: '💻', color: 'green' },
        { id: '4', name: 'Paziente', description: 'Ottimo con i principianti', icon: '🤝', color: 'blue' }
      ],
      isOnline: false,
      lastSeen: new Date(Date.now() - 30 * 60 * 1000),
      verificationLevel: 'verified'
    },
    {
      id: '3',
      userId: 'tutor3',
      name: 'Sofia Verde',
      avatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&fit=crop',
      title: 'UX/UI Designer & Creative Director',
      bio: 'Creative Director con 10 anni di esperienza in design digitale. Specializzata in UX/UI design e design thinking.',
      specializations: ['Design', 'UI/UX', 'Figma', 'Adobe Creative Suite', 'Design Thinking'],
      languages: ['Italiano', 'Inglese', 'Spagnolo'],
      experience: 10,
      rating: 4.9,
      reviewCount: 156,
      totalSessions: 380,
      responseTime: 'Entro 30 min',
      availability: {
        timezone: 'Europe/Rome',
        schedule: {
          monday: [{ start: '10:00', end: '17:00' }],
          tuesday: [{ start: '10:00', end: '17:00' }],
          wednesday: [{ start: '10:00', end: '17:00' }],
          thursday: [{ start: '10:00', end: '17:00' }],
          friday: [{ start: '10:00', end: '15:00' }]
        },
        nextAvailable: new Date(Date.now() + 1 * 60 * 60 * 1000)
      },
      pricing: {
        baseRate: 90,
        sessionTypes: [
          { id: '1', name: 'Portfolio Review', duration: 45, price: 60, description: 'Revisione portfolio' },
          { id: '2', name: 'Design Critique', duration: 60, price: 90, description: 'Analisi design' },
          { id: '3', name: 'Workshop Design', duration: 90, price: 120, description: 'Workshop pratico' }
        ]
      },
      badges: [
        { id: '5', name: 'Design Master', description: 'Maestro del design', icon: '🎨', color: 'purple' },
        { id: '6', name: 'Super Veloce', description: 'Risposta in 30 minuti', icon: '🚀', color: 'orange' }
      ],
      isOnline: true,
      verificationLevel: 'expert'
    },
    {
      id: '4',
      userId: 'tutor4',
      name: 'Alessandro Neri',
      avatar: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=300&h=300&fit=crop',
      title: 'Data Scientist & AI Researcher',
      bio: 'PhD in Computer Science, specializzato in Machine Learning e Data Science. Ricercatore presso università e consulente aziendale.',
      specializations: ['Data Science', 'Machine Learning', 'Python', 'Statistics', 'AI'],
      languages: ['Italiano', 'Inglese'],
      experience: 7,
      rating: 4.7,
      reviewCount: 73,
      totalSessions: 210,
      responseTime: 'Entro 3 ore',
      availability: {
        timezone: 'Europe/Rome',
        schedule: {
          tuesday: [{ start: '19:00', end: '22:00' }],
          thursday: [{ start: '19:00', end: '22:00' }],
          saturday: [{ start: '14:00', end: '18:00' }],
          sunday: [{ start: '14:00', end: '18:00' }]
        },
        nextAvailable: new Date(Date.now() + 6 * 60 * 60 * 1000)
      },
      pricing: {
        baseRate: 100,
        sessionTypes: [
          { id: '1', name: 'Consulenza Rapida', duration: 30, price: 50, description: 'Consulenza specifica' },
          { id: '2', name: 'Analisi Dati', duration: 90, price: 130, description: 'Analisi approfondita' },
          { id: '3', name: 'ML Workshop', duration: 120, price: 180, description: 'Workshop Machine Learning' }
        ]
      },
      badges: [
        { id: '7', name: 'AI Expert', description: 'Esperto di Intelligenza Artificiale', icon: '🤖', color: 'blue' },
        { id: '8', name: 'Ricercatore', description: 'Ricercatore universitario', icon: '🔬', color: 'green' }
      ],
      isOnline: false,
      lastSeen: new Date(Date.now() - 2 * 60 * 60 * 1000),
      verificationLevel: 'expert'
    }
  ];

  // Filter tutors based on search and filters
  const filteredTutors = tutors.filter(tutor => {
    if (searchQuery && !tutor.name.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !tutor.specializations.some(spec => spec.toLowerCase().includes(searchQuery.toLowerCase())) &&
        !tutor.bio.toLowerCase().includes(searchQuery.toLowerCase())) {
      return false;
    }

    if (filters.specialization && !tutor.specializations.includes(filters.specialization)) {
      return false;
    }

    if (filters.verificationLevel && tutor.verificationLevel !== filters.verificationLevel) {
      return false;
    }

    // Add more filter logic here

    return true;
  });

  if (filteredTutors.length === 0) {
    return (
      <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-12 text-center">
        <div className="text-6xl mb-4">🔍</div>
        <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2">
          Nessun tutor trovato
        </h3>
        <p className="text-stone-600 dark:text-stone-400 mb-6">
          {searchQuery 
            ? `Nessun tutor corrisponde alla ricerca "${searchQuery}"`
            : 'Prova a modificare i filtri di ricerca.'
          }
        </p>
        <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
          Rimuovi Filtri
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Results Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          {searchQuery ? `Risultati per "${searchQuery}"` : 'Tutor Disponibili'}
        </h2>
        <span className="text-stone-600 dark:text-stone-400">
          {filteredTutors.length} tutor trovati
        </span>
      </div>

      {/* Tutor Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {filteredTutors.map(tutor => (
          <TutorCard key={tutor.id} tutor={tutor} />
        ))}
      </div>
    </div>
  );
};