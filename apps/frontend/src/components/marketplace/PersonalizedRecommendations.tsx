import React from 'react';
import { BookOpen, Target, Clock, Star, ArrowRight } from 'lucide-react';

export const PersonalizedRecommendations: React.FC = () => {
  const recommendations = [
    {
      id: 1,
      title: 'TypeScript Avanzato',
      instructor: 'Marco Verdi',
      rating: 4.8,
      duration: '8h 30min',
      price: 79.99,
      category: 'Programmazione',
      image: 'https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      reason: 'Basato sui tuoi corsi JavaScript'
    },
    {
      id: 2,
      title: 'Advanced React Patterns',
      instructor: 'Sofia Blu',
      rating: 4.9,
      duration: '12h 15min',
      price: 89.99,
      category: 'Programmazione',
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      reason: 'Prossimo step nel tuo percorso React'
    },
    {
      id: 3,
      title: 'UI/UX Design System',
      instructor: 'Luca Rossi',
      rating: 4.7,
      duration: '10h 45min',
      price: 69.99,
      category: 'Design',
      image: 'https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      reason: 'Complementa le tue skill di sviluppo'
    },
    {
      id: 4,
      title: 'Node.js & API Development',
      instructor: 'Andrea Neri',
      rating: 4.8,
      duration: '14h 20min',
      price: 94.99,
      category: 'Backend',
      image: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      reason: 'Completa il tuo stack full-stack'
    }
  ];

  return (
    <div className="mb-16">
      <div className="bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-3xl border border-amber-200/30 dark:border-amber-800/30 p-8 mb-8">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center space-x-4">
            <div className="w-12 h-12 bg-gradient-to-r from-amber-400 to-orange-500 rounded-2xl flex items-center justify-center">
              <Target className="w-6 h-6 text-white" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                Raccomandato per te
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Corsi selezionati in base ai tuoi interessi e progressi
              </p>
            </div>
          </div>
          <button className="text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 font-semibold transition-colors flex items-center space-x-2">
            <span>Vedi tutti</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {recommendations.map((course) => (
            <div 
              key={course.id}
              className="group bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 overflow-hidden hover:shadow-xl transition-all duration-300 hover:-translate-y-1"
            >
              {/* Course Image */}
              <div className="relative overflow-hidden">
                <img
                  src={course.image}
                  alt={course.title}
                  className="w-full h-32 object-cover group-hover:scale-105 transition-transform duration-300"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                
                {/* Recommendation Reason */}
                <div className="absolute bottom-2 left-2 right-2">
                  <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-lg px-3 py-1">
                    <div className="flex items-center space-x-2">
                      <div className="w-2 h-2 bg-gradient-to-r from-amber-400 to-orange-500 rounded-full"></div>
                      <span className="text-xs font-medium text-stone-700 dark:text-stone-300">
                        {course.reason}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Course Content */}
              <div className="p-4 space-y-3">
                {/* Category */}
                <span className="inline-block text-xs font-medium text-amber-600 dark:text-amber-400 bg-amber-50 dark:bg-amber-900/20 px-3 py-1 rounded-full">
                  {course.category}
                </span>

                {/* Title */}
                <h3 className="font-bold text-stone-900 dark:text-stone-100 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                  {course.title}
                </h3>

                {/* Instructor */}
                <p className="text-sm text-stone-600 dark:text-stone-400">
                  di {course.instructor}
                </p>

                {/* Stats */}
                <div className="flex items-center justify-between text-xs text-stone-500 dark:text-stone-400">
                  <div className="flex items-center space-x-1">
                    <Star className="w-3 h-3 fill-current text-amber-400" />
                    <span>{course.rating}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Clock className="w-3 h-3" />
                    <span>{course.duration}</span>
                  </div>
                </div>

                {/* Price and CTA */}
                <div className="flex items-center justify-between pt-2 border-t border-stone-200 dark:border-stone-700">
                  <span className="font-bold text-stone-900 dark:text-stone-100">
                    €{course.price}
                  </span>
                  <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white text-xs font-semibold py-2 px-4 rounded-lg hover:from-amber-500 hover:to-orange-600 transition-all duration-200">
                    Aggiungi
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}; 