import React, { useState } from 'react';
import { CourseCard } from './CourseCard';
import { CourseListItem } from './CourseListItem';
import { Loader2 } from 'lucide-react';

interface CourseGridProps {
  searchQuery: string;
  filters: any;
  viewMode: 'grid' | 'list';
  sortBy: string;
}

export const CourseGrid: React.FC<CourseGridProps> = ({
  searchQuery,
  filters,
  viewMode,
  sortBy
}) => {
  const [loading, setLoading] = useState(false);

  // Mock course data
  const courses = [
    {
      id: 1,
      title: 'React Avanzato: Hooks e Performance',
      instructor: 'Marco Rossi',
      rating: 4.8,
      reviewCount: 1247,
      students: 8934,
      duration: '12h 30min',
      level: 'Avanzato',
      price: 89.99,
      originalPrice: 129.99,
      category: 'Programmazione',
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Padroneggia React con hooks avanzati, ottimizzazioni delle performance e pattern moderni.',
      lessons: 45,
      lastUpdated: '2024-12-01',
      bestseller: true,
      canBuyIndividualLessons: true,
      lessonPrice: 4.99
    },
    {
      id: 2,
      title: 'TypeScript da Zero a Esperto',
      instructor: 'Laura Bianchi',
      rating: 4.9,
      reviewCount: 892,
      students: 5621,
      duration: '8h 15min',
      level: 'Intermedio',
      price: 69.99,
      originalPrice: 99.99,
      category: 'Programmazione',
      image: 'https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Impara TypeScript dalle basi fino ai concetti più avanzati con progetti pratici.',
      lessons: 32,
      lastUpdated: '2024-11-28',
      bestseller: false,
      canBuyIndividualLessons: true,
      lessonPrice: 3.99
    },
    {
      id: 3,
      title: 'UI/UX Design con Figma',
      instructor: 'Alessandro Verde',
      rating: 4.7,
      reviewCount: 1534,
      students: 12456,
      duration: '15h 45min',
      level: 'Principiante',
      price: 79.99,
      originalPrice: 119.99,
      category: 'Design',
      image: 'https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Crea interfacce utente moderne e user experience coinvolgenti con Figma.',
      lessons: 58,
      lastUpdated: '2024-12-03',
      bestseller: true,
      canBuyIndividualLessons: false,
      lessonPrice: 0
    },
    {
      id: 4,
      title: 'Digital Marketing Strategy',
      instructor: 'Francesca Neri',
      rating: 4.6,
      reviewCount: 743,
      students: 3892,
      duration: '10h 20min',
      level: 'Intermedio',
      price: 59.99,
      originalPrice: 89.99,
      category: 'Marketing',
      image: 'https://images.pexels.com/photos/265087/pexels-photo-265087.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Strategie di marketing digitale per far crescere il tuo business online.',
      lessons: 38,
      lastUpdated: '2024-11-25',
      bestseller: false,
      canBuyIndividualLessons: true,
      lessonPrice: 2.99
    },
    {
      id: 5,
      title: 'Python per Data Science',
      instructor: 'Roberto Blu',
      rating: 4.8,
      reviewCount: 2156,
      students: 15678,
      duration: '18h 30min',
      level: 'Intermedio',
      price: 99.99,
      originalPrice: 149.99,
      category: 'Data Science',
      image: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Analizza dati e crea modelli di machine learning con Python.',
      lessons: 67,
      lastUpdated: '2024-12-05',
      bestseller: true,
      canBuyIndividualLessons: true,
      lessonPrice: 3.49
    },
    {
      id: 6,
      title: 'Fotografia Digitale Avanzata',
      instructor: 'Sofia Giallo',
      rating: 4.5,
      reviewCount: 456,
      students: 2134,
      duration: '6h 45min',
      level: 'Avanzato',
      price: 49.99,
      originalPrice: 79.99,
      category: 'Fotografia',
      image: 'https://images.pexels.com/photos/606541/pexels-photo-606541.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Tecniche avanzate di fotografia digitale e post-produzione.',
      lessons: 24,
      lastUpdated: '2024-11-20',
      bestseller: false,
      canBuyIndividualLessons: true,
      lessonPrice: 3.99
    },
    {
      id: 7,
      title: 'Business Strategy & Leadership',
      instructor: 'Giulia Rosso',
      rating: 4.7,
      reviewCount: 834,
      students: 4567,
      duration: '14h 20min',
      level: 'Avanzato',
      price: 119.99,
      originalPrice: 179.99,
      category: 'Business',
      image: 'https://images.pexels.com/photos/3183197/pexels-photo-3183197.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Sviluppa strategie di business vincenti e competenze di leadership.',
      lessons: 52,
      lastUpdated: '2024-11-30',
      bestseller: false,
      canBuyIndividualLessons: true,
      lessonPrice: 5.99
    },
    {
      id: 8,
      title: 'AI & Machine Learning Fundamentals',
      instructor: 'Andrea Nero',
      rating: 4.9,
      reviewCount: 1876,
      students: 11234,
      duration: '22h 10min',
      level: 'Intermedio',
      price: 149.99,
      originalPrice: 199.99,
      category: 'AI & Data Science',
      image: 'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      description: 'Fondamenti di intelligenza artificiale e machine learning con progetti pratici.',
      lessons: 78,
      lastUpdated: '2024-12-07',
      bestseller: true,
      canBuyIndividualLessons: true,
      lessonPrice: 4.49
    }
  ];

  // Filter courses based on search and filters
  const filteredCourses = courses.filter(course => {
    if (searchQuery && !course.title.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !course.instructor.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !course.description.toLowerCase().includes(searchQuery.toLowerCase())) {
      return false;
    }

    if (filters.category && course.category !== filters.category) return false;
    if (filters.level && course.level !== filters.level) return false;
    
    // Price filter
    if (filters.price) {
      if (filters.price === 'Gratuito' && course.price > 0) return false;
      if (filters.price === '€1-€25' && (course.price < 1 || course.price > 25)) return false;
      if (filters.price === '€25-€50' && (course.price < 25 || course.price > 50)) return false;
      if (filters.price === '€50-€100' && (course.price < 50 || course.price > 100)) return false;
      if (filters.price === '€100+' && course.price < 100) return false;
    }

    // Rating filter
    if (filters.rating) {
      const minRating = parseFloat(filters.rating.replace('+', ''));
      if (course.rating < minRating) return false;
    }
    
    return true;
  });

  // Sort courses
  const sortedCourses = [...filteredCourses].sort((a, b) => {
    switch (sortBy) {
      case 'rating':
        return b.rating - a.rating;
      case 'price_low':
        return a.price - b.price;
      case 'price_high':
        return b.price - a.price;
      case 'newest':
        return new Date(b.lastUpdated).getTime() - new Date(a.lastUpdated).getTime();
      case 'popular':
        return b.students - a.students;
      default:
        return 0; // relevance
    }
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <Loader2 className="w-8 h-8 animate-spin text-amber-500" />
        <span className="ml-2 text-stone-600 dark:text-stone-400">Caricamento corsi...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Results Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          {searchQuery ? `Risultati per "${searchQuery}"` : 'Tutti i Corsi'}
        </h2>
        <span className="text-stone-600 dark:text-stone-400">
          {sortedCourses.length} corsi trovati
        </span>
      </div>

      {/* Course Grid/List */}
      {viewMode === 'grid' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {sortedCourses.map(course => (
            <CourseCard key={course.id} course={course} />
          ))}
        </div>
      ) : (
        <div className="space-y-4">
          {sortedCourses.map(course => (
            <CourseListItem key={course.id} course={course} />
          ))}
        </div>
      )}

      {/* No Results */}
      {sortedCourses.length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">🔍</div>
          <h3 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-2">
            Nessun corso trovato
          </h3>
          <p className="text-stone-600 dark:text-stone-400 mb-6">
            Prova a modificare i filtri di ricerca o cerca altri termini.
          </p>
          <button
            onClick={() => window.location.reload()}
            className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-semibold py-3 px-8 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200"
          >
            Ricarica Corsi
          </button>
        </div>
      )}
    </div>
  );
}; 