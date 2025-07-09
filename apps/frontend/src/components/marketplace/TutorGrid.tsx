import React from 'react';
import { TutorCard } from './TutorCard';

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
  const tutors = [
    {
      id: 1,
      name: 'Marco Alberti',
      specializations: ['React', 'TypeScript', 'Node.js'],
      rating: 4.9,
      reviewCount: 156,
      completedSessions: 1247,
      hourlyRate: 45,
      avatar: 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      description: 'Full-stack developer con 8 anni di esperienza. Specializzato in React e Node.js.',
      availability: ['Pomeriggio', 'Sera'],
      verificationLevel: 'Esperto',
      responseTime: '< 1 ora',
      languages: ['Italiano', 'Inglese'],
      experience: 8
    },
    {
      id: 2,
      name: 'Laura Fontana',
      specializations: ['Python', 'Data Science', 'Machine Learning'],
      rating: 4.8,
      reviewCount: 203,
      completedSessions: 890,
      hourlyRate: 55,
      avatar: 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      description: 'Data Scientist con PhD in Informatica. Esperta in Python e ML.',
      availability: ['Mattino', 'Pomeriggio'],
      verificationLevel: 'Certificato',
      responseTime: '< 30 min',
      languages: ['Italiano', 'Inglese', 'Francese'],
      experience: 6
    },
    {
      id: 3,
      name: 'Alessandro Verde',
      specializations: ['UI/UX Design', 'Figma', 'Adobe Creative'],
      rating: 4.7,
      reviewCount: 89,
      completedSessions: 456,
      hourlyRate: 35,
      avatar: 'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      description: 'UX Designer con esperienza in startup e grandi aziende.',
      availability: ['Sera', 'Weekend'],
      verificationLevel: 'Verificato',
      responseTime: '< 2 ore',
      languages: ['Italiano', 'Inglese'],
      experience: 5
    },
    {
      id: 4,
      name: 'Sofia Bianchi',
      specializations: ['Matematica', 'Fisica', 'Chimica'],
      rating: 4.9,
      reviewCount: 278,
      completedSessions: 1456,
      hourlyRate: 28,
      avatar: 'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      description: 'Professore di Matematica con 10 anni di esperienza nell\'insegnamento.',
      availability: ['Mattino', 'Pomeriggio', 'Sera'],
      verificationLevel: 'Certificato',
      responseTime: '< 15 min',
      languages: ['Italiano'],
      experience: 10
    },
    {
      id: 5,
      name: 'Roberto Neri',
      specializations: ['Digital Marketing', 'SEO', 'Social Media'],
      rating: 4.6,
      reviewCount: 134,
      completedSessions: 678,
      hourlyRate: 40,
      avatar: 'https://images.pexels.com/photos/1516680/pexels-photo-1516680.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      description: 'Marketing Manager con esperienza in crescita digitale e strategie SEO.',
      availability: ['Pomeriggio', 'Sera'],
      verificationLevel: 'Esperto',
      responseTime: '< 1 ora',
      languages: ['Italiano', 'Inglese', 'Spagnolo'],
      experience: 7
    },
    {
      id: 6,
      name: 'Giulia Rosso',
      specializations: ['Inglese', 'Letteratura', 'Conversazione'],
      rating: 4.8,
      reviewCount: 312,
      completedSessions: 1823,
      hourlyRate: 32,
      avatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=150&h=150&fit=crop',
      description: 'Insegnante madrelingua inglese con certificazione TEFL.',
      availability: ['Mattino', 'Pomeriggio', 'Sera', 'Weekend'],
      verificationLevel: 'Premium',
      responseTime: '< 10 min',
      languages: ['Italiano', 'Inglese'],
      experience: 12
    }
  ];

  // Filter tutors
  const filteredTutors = tutors.filter(tutor => {
    if (searchQuery && 
        !tutor.name.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !tutor.specializations.some(spec => spec.toLowerCase().includes(searchQuery.toLowerCase())) &&
        !tutor.description.toLowerCase().includes(searchQuery.toLowerCase())) {
      return false;
    }

    if (filters.specialization && 
        !tutor.specializations.some(spec => spec.includes(filters.specialization))) {
      return false;
    }

    // Price range filter
    if (filters.priceRange) {
      const [min, max] = filters.priceRange.split('-').map(p => parseInt(p.replace(/[€\/h]/g, '')));
      if (filters.priceRange.includes('+')) {
        if (tutor.hourlyRate < min) return false;
      } else {
        if (tutor.hourlyRate < min || tutor.hourlyRate > max) return false;
      }
    }

    if (filters.availability && 
        !tutor.availability.includes(filters.availability)) {
      return false;
    }

    if (filters.rating) {
      const minRating = parseFloat(filters.rating.replace('+', ''));
      if (tutor.rating < minRating) return false;
    }

    if (filters.verificationLevel && 
        tutor.verificationLevel !== filters.verificationLevel) {
      return false;
    }

    return true;
  });

  // Sort tutors
  const sortedTutors = [...filteredTutors].sort((a, b) => {
    switch (sortBy) {
      case 'rating':
        return b.rating - a.rating;
      case 'price_low':
        return a.hourlyRate - b.hourlyRate;
      case 'price_high':
        return b.hourlyRate - a.hourlyRate;
      case 'experience':
        return b.experience - a.experience;
      case 'sessions':
        return b.completedSessions - a.completedSessions;
      default:
        return 0;
    }
  });

  return (
    <div className="space-y-6">
      {/* Results Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          {searchQuery ? `Risultati per "${searchQuery}"` : 'Tutti i Tutor'}
        </h2>
        <span className="text-stone-600 dark:text-stone-400">
          {sortedTutors.length} tutor disponibili
        </span>
      </div>

      {/* Tutor Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {sortedTutors.map(tutor => (
          <TutorCard key={tutor.id} tutor={tutor} />
        ))}
      </div>

      {/* No Results */}
      {sortedTutors.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">🔍</div>
          <h3 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-2">
            Nessun tutor trovato
          </h3>
          <p className="text-stone-600 dark:text-stone-400 mb-6">
            Prova a modificare i filtri di ricerca o cerca altri termini.
          </p>
          <button
            onClick={() => window.location.reload()}
            className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-semibold py-3 px-8 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200"
          >
            Ricarica Tutor
          </button>
        </div>
      )}
    </div>
  );
}; 