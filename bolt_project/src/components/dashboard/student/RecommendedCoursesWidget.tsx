import React from 'react';
import { Star, Clock, Users, ArrowRight } from 'lucide-react';

export const RecommendedCoursesWidget: React.FC = () => {
  const courses = [
    {
      id: 1,
      title: 'TypeScript Avanzato',
      instructor: 'Marco Rossi',
      rating: 4.8,
      duration: '6h 30min',
      students: 1247,
      image: 'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      price: '89€'
    },
    {
      id: 2,
      title: 'Node.js e Express',
      instructor: 'Laura Bianchi',
      rating: 4.9,
      duration: '8h 15min',
      students: 892,
      image: 'https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop',
      price: '99€'
    }
  ];

  return (
    <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
          Corsi Consigliati
        </h2>
        <button className="text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 transition-colors">
          <ArrowRight className="w-5 h-5" />
        </button>
      </div>
      
      <div className="space-y-4">
        {courses.map((course) => (
          <div 
            key={course.id}
            className="group p-4 rounded-lg border border-stone-200 dark:border-stone-700 hover:border-amber-300 dark:hover:border-amber-600 transition-all duration-200 cursor-pointer"
          >
            <div className="flex space-x-4">
              <img 
                src={course.image}
                alt={course.title}
                className="w-16 h-16 rounded-lg object-cover"
              />
              <div className="flex-1 min-w-0">
                <h3 className="font-medium text-stone-900 dark:text-stone-100 mb-1 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                  {course.title}
                </h3>
                <p className="text-sm text-stone-500 dark:text-stone-500 mb-2">
                  {course.instructor}
                </p>
                <div className="flex items-center space-x-3 text-xs text-stone-400 dark:text-stone-500">
                  <div className="flex items-center space-x-1">
                    <Star className="w-3 h-3 fill-current text-amber-400" />
                    <span>{course.rating}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Clock className="w-3 h-3" />
                    <span>{course.duration}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Users className="w-3 h-3" />
                    <span>{course.students}</span>
                  </div>
                </div>
              </div>
            </div>
            <div className="flex items-center justify-between mt-3 pt-3 border-t border-stone-200 dark:border-stone-700">
              <span className="text-lg font-bold text-amber-600 dark:text-amber-400">
                {course.price}
              </span>
              <button className="text-sm text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 font-medium transition-colors">
                Scopri di più
              </button>
            </div>
          </div>
        ))}
      </div>
      
      <button className="w-full mt-4 py-3 px-4 border border-amber-300 dark:border-amber-600 text-amber-600 dark:text-amber-400 rounded-lg hover:bg-amber-50 dark:hover:bg-amber-900/10 transition-colors">
        Vedi tutti i corsi consigliati
      </button>
    </div>
  );
};