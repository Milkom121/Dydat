import React from 'react';
import { Star, Clock, Users } from 'lucide-react';

export const RecommendedCoursesWidget: React.FC = () => {
  const recommendedCourses = [
    {
      id: 1,
      title: 'TypeScript Avanzato',
      instructor: 'Marco Rossi',
      rating: 4.8,
      students: 1247,
      duration: '6h 30m',
      price: '89€',
      thumbnail: 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop'
    },
    {
      id: 2,
      title: 'Node.js e Express',
      instructor: 'Sofia Bianchi',
      rating: 4.9,
      students: 892,
      duration: '8h 15m',
      price: '129€',
      thumbnail: 'https://images.pexels.com/photos/11035380/pexels-photo-11035380.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop'
    }
  ];

  return (
    <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
      <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-6">
        Corsi Consigliati
      </h2>
      
      <div className="space-y-4">
        {recommendedCourses.map((course) => (
          <div key={course.id} className="group">
            <div className="flex space-x-3">
              <img 
                src={course.thumbnail}
                alt={course.title}
                className="w-16 h-16 rounded-lg object-cover"
              />
              <div className="flex-1 min-w-0">
                <h3 className="font-medium text-stone-900 dark:text-stone-100 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                  {course.title}
                </h3>
                <p className="text-sm text-stone-500 dark:text-stone-500 mb-2">
                  {course.instructor}
                </p>
                <div className="flex items-center space-x-3 text-xs text-stone-500 dark:text-stone-500">
                  <div className="flex items-center space-x-1">
                    <Star className="w-3 h-3 text-amber-500 fill-current" />
                    <span>{course.rating}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Users className="w-3 h-3" />
                    <span>{course.students.toLocaleString()}</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Clock className="w-3 h-3" />
                    <span>{course.duration}</span>
                  </div>
                </div>
              </div>
              <div className="text-right">
                <span className="text-lg font-bold text-stone-900 dark:text-stone-100">
                  {course.price}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
      
      <button className="w-full mt-6 bg-gradient-to-r from-amber-400 to-orange-500 text-white font-medium py-3 px-4 rounded-lg hover:from-amber-500 hover:to-orange-600 transition-all duration-200">
        Scopri di più
      </button>
    </div>
  );
}; 