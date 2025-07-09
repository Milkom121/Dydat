import React from 'react';
import { Play, Clock, CheckCircle, Target } from 'lucide-react';

export const CourseProgress: React.FC = () => {
  const currentCourses = [
    {
      id: 1,
      title: 'React Avanzato: Hooks e Performance',
      instructor: 'Marco Rossi',
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      progress: 65,
      currentLesson: 'Lezione 12: useContext in profondità',
      timeRemaining: '15 min',
      totalLessons: 20,
      completedLessons: 13,
      lastAccessed: '2 ore fa'
    },
    {
      id: 2,
      title: 'TypeScript da Zero a Esperto',
      instructor: 'Laura Bianchi',
      image: 'https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      progress: 40,
      currentLesson: 'Lezione 8: Generics avanzati',
      timeRemaining: '25 min',
      totalLessons: 32,
      completedLessons: 12,
      lastAccessed: '1 giorno fa'
    }
  ];

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8">
      <div className="flex items-center space-x-3 mb-6">
        <div className="p-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-lg">
          <Target className="w-5 h-5 text-white" />
        </div>
        <div>
          <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
            Continua ad Imparare
          </h2>
          <p className="text-stone-600 dark:text-stone-400">
            Riprendi da dove avevi lasciato
          </p>
        </div>
      </div>

      <div className="space-y-6">
        {currentCourses.map((course) => (
          <div 
            key={course.id}
            className="group bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-2xl p-6 border-2 border-amber-200/50 dark:border-amber-800/50 hover:border-amber-300 dark:hover:border-amber-600 transition-all duration-300"
          >
            <div className="flex items-start space-x-6">
              {/* Course Image */}
              <div className="relative flex-shrink-0">
                <img 
                  src={course.image}
                  alt={course.title}
                  className="w-24 h-24 rounded-xl object-cover"
                />
                <div className="absolute inset-0 bg-black bg-opacity-40 rounded-xl flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                  <Play className="w-6 h-6 text-white" />
                </div>
              </div>

              {/* Course Info */}
              <div className="flex-1 min-w-0">
                <h3 className="font-bold text-lg text-stone-900 dark:text-stone-100 mb-2 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                  {course.title}
                </h3>
                <p className="text-stone-600 dark:text-stone-400 mb-3">
                  {course.instructor}
                </p>
                
                <div className="space-y-3">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-stone-600 dark:text-stone-400">
                      {course.currentLesson}
                    </span>
                    <span className="text-amber-600 dark:text-amber-400 font-medium">
                      {course.progress}% completato
                    </span>
                  </div>
                  
                  <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-3">
                    <div 
                      className="bg-gradient-to-r from-amber-400 to-orange-500 h-3 rounded-full transition-all duration-500"
                      style={{ width: `${course.progress}%` }}
                    ></div>
                  </div>
                  
                  <div className="flex items-center justify-between text-sm text-stone-500 dark:text-stone-500">
                    <div className="flex items-center space-x-4">
                      <span className="flex items-center space-x-1">
                        <CheckCircle className="w-4 h-4" />
                        <span>{course.completedLessons}/{course.totalLessons} lezioni</span>
                      </span>
                      <span className="flex items-center space-x-1">
                        <Clock className="w-4 h-4" />
                        <span>{course.timeRemaining} rimanenti</span>
                      </span>
                    </div>
                    <span>Ultimo accesso: {course.lastAccessed}</span>
                  </div>
                </div>
              </div>

              {/* Action Button */}
              <div className="flex-shrink-0">
                <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-bold py-3 px-6 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200 transform hover:scale-105 shadow-lg">
                  Continua
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};