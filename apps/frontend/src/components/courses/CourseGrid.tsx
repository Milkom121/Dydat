import React from 'react';
import { MyCourseCard } from './MyCourseCard';
import { MyCourseListItem } from './MyCourseListItem';

interface CourseGridProps {
  activeTab: string;
  viewMode: 'grid' | 'list';
  sortBy: string;
  searchQuery: string;
}

export const CourseGrid: React.FC<CourseGridProps> = ({
  activeTab,
  viewMode,
  sortBy,
  searchQuery
}) => {
  // Mock data - in a real app this would come from an API
  const allCourses = [
    {
      id: 1,
      title: 'React Avanzato: Hooks e Performance',
      instructor: 'Marco Rossi',
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      progress: 65,
      status: 'in-progress',
      rating: 4.8,
      totalLessons: 20,
      completedLessons: 13,
      duration: '12h 30min',
      lastAccessed: '2 ore fa',
      certificate: false,
      category: 'Programmazione'
    },
    {
      id: 2,
      title: 'TypeScript da Zero a Esperto',
      instructor: 'Laura Bianchi',
      image: 'https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      progress: 40,
      status: 'in-progress',
      rating: 4.9,
      totalLessons: 32,
      completedLessons: 12,
      duration: '8h 15min',
      lastAccessed: '1 giorno fa',
      certificate: false,
      category: 'Programmazione'
    },
    {
      id: 3,
      title: 'UI/UX Design con Figma',
      instructor: 'Alessandro Verde',
      image: 'https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      progress: 100,
      status: 'completed',
      rating: 4.7,
      totalLessons: 58,
      completedLessons: 58,
      duration: '15h 45min',
      lastAccessed: '3 giorni fa',
      certificate: true,
      category: 'Design'
    },
    {
      id: 4,
      title: 'Digital Marketing Strategy',
      instructor: 'Francesca Neri',
      image: 'https://images.pexels.com/photos/265087/pexels-photo-265087.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      progress: 100,
      status: 'completed',
      rating: 4.6,
      totalLessons: 38,
      completedLessons: 38,
      duration: '10h 20min',
      lastAccessed: '1 settimana fa',
      certificate: true,
      category: 'Marketing'
    },
    {
      id: 5,
      title: 'Python per Data Science',
      instructor: 'Roberto Blu',
      image: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=400&h=250&fit=crop',
      progress: 25,
      status: 'in-progress',
      rating: 4.8,
      totalLessons: 67,
      completedLessons: 17,
      duration: '18h 30min',
      lastAccessed: '2 giorni fa',
      certificate: false,
      category: 'Data Science'
    }
  ];

  // Filter courses based on active tab
  const filteredCourses = allCourses.filter(course => {
    if (activeTab === 'all') return true;
    if (activeTab === 'in-progress') return course.status === 'in-progress';
    if (activeTab === 'completed') return course.status === 'completed';
    if (activeTab === 'certificates') return course.certificate;
    return true;
  }).filter(course => {
    if (!searchQuery) return true;
    return course.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
           course.instructor.toLowerCase().includes(searchQuery.toLowerCase()) ||
           course.category.toLowerCase().includes(searchQuery.toLowerCase());
  });

  if (filteredCourses.length === 0) {
    return (
      <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-12 text-center">
        <div className="text-6xl mb-4">📚</div>
        <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2">
          Nessun corso trovato
        </h3>
        <p className="text-stone-600 dark:text-stone-400 mb-6">
          {searchQuery 
            ? `Nessun corso corrisponde alla ricerca "${searchQuery}"`
            : 'Non hai ancora corsi in questa categoria.'
          }
        </p>
        {activeTab === 'all' && !searchQuery && (
          <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-bold py-3 px-6 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200">
            Esplora il Catalogo
          </button>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Results Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          {activeTab === 'all' && 'Tutti i Corsi'}
          {activeTab === 'in-progress' && 'Corsi in Corso'}
          {activeTab === 'completed' && 'Corsi Completati'}
          {activeTab === 'certificates' && 'Certificati Ottenuti'}
          {activeTab === 'wishlist' && 'Lista Desideri'}
        </h2>
        <span className="text-stone-600 dark:text-stone-400">
          {filteredCourses.length} {filteredCourses.length === 1 ? 'corso' : 'corsi'}
        </span>
      </div>

      {/* Course Grid/List */}
      {viewMode === 'grid' ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredCourses.map(course => (
            <MyCourseCard key={course.id} course={course} />
          ))}
        </div>
      ) : (
        <div className="space-y-4">
          {filteredCourses.map(course => (
            <MyCourseListItem key={course.id} course={course} />
          ))}
        </div>
      )}
    </div>
  );
}; 