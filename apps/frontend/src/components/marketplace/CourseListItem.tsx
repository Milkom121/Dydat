import React from 'react';
import { Star, Clock, Users, Award, PlayCircle, ShoppingCart } from 'lucide-react';

interface CourseListItemProps {
  course: {
    id: number;
    title: string;
    instructor: string;
    rating: number;
    reviewCount: number;
    students: number;
    duration: string;
    level: string;
    price: number;
    originalPrice: number;
    category: string;
    image: string;
    description: string;
    lessons: number;
    lastUpdated: string;
    bestseller: boolean;
    canBuyIndividualLessons: boolean;
    lessonPrice: number;
  };
}

export const CourseListItem: React.FC<CourseListItemProps> = ({ course }) => {
  const discount = Math.round((1 - course.price / course.originalPrice) * 100);

  return (
    <div className="group bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 shadow-lg hover:shadow-xl transition-all duration-300 overflow-hidden">
      <div className="flex flex-col md:flex-row">
        {/* Course Image */}
        <div className="relative md:w-80 h-48 md:h-auto overflow-hidden">
          <img
            src={course.image}
            alt={course.title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          />
          
          {/* Badges */}
          <div className="absolute top-4 left-4 flex flex-col gap-2">
            {course.bestseller && (
              <span className="bg-gradient-to-r from-amber-400 to-orange-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-md">
                Bestseller
              </span>
            )}
            {discount > 0 && (
              <span className="bg-gradient-to-r from-red-500 to-pink-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-md">
                -{discount}%
              </span>
            )}
          </div>

          {/* Level Badge */}
          <div className="absolute top-4 right-4">
            <span className={`text-xs font-medium px-3 py-1 rounded-full ${
              course.level === 'Principiante' 
                ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300'
                : course.level === 'Intermedio'
                ? 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300'
                : 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300'
            }`}>
              {course.level}
            </span>
          </div>

          {/* Play Button Overlay */}
          <div className="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
            <PlayCircle className="w-12 h-12 text-white/80" />
          </div>
        </div>

        {/* Course Content */}
        <div className="flex-1 p-6 flex flex-col justify-between">
          <div className="space-y-4">
            {/* Header */}
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <div className="flex items-center space-x-3">
                  <span className="text-xs font-medium text-amber-600 dark:text-amber-400 bg-amber-50 dark:bg-amber-900/20 px-3 py-1 rounded-full">
                    {course.category}
                  </span>
                  <div className="flex items-center space-x-1 text-amber-500">
                    <Star className="w-4 h-4 fill-current" />
                    <span className="text-sm font-semibold text-stone-700 dark:text-stone-300">
                      {course.rating}
                    </span>
                    <span className="text-xs text-stone-500 dark:text-stone-400">
                      ({course.reviewCount} recensioni)
                    </span>
                  </div>
                </div>

                <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                  {course.title}
                </h3>

                <p className="text-sm text-stone-600 dark:text-stone-400">
                  di <span className="font-medium text-stone-700 dark:text-stone-300">{course.instructor}</span>
                </p>
              </div>

              {/* Pricing */}
              <div className="text-right space-y-2">
                <div className="flex items-center space-x-2">
                  <span className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                    €{course.price}
                  </span>
                  {course.originalPrice > course.price && (
                    <span className="text-sm text-stone-500 dark:text-stone-400 line-through">
                      €{course.originalPrice}
                    </span>
                  )}
                </div>
                {course.canBuyIndividualLessons && (
                  <div className="text-xs text-stone-500 dark:text-stone-400">
                    o €{course.lessonPrice}/lezione
                  </div>
                )}
              </div>
            </div>

            {/* Description */}
            <p className="text-stone-600 dark:text-stone-400 line-clamp-2">
              {course.description}
            </p>

            {/* Course Stats */}
            <div className="flex items-center space-x-6 text-sm text-stone-500 dark:text-stone-400">
              <div className="flex items-center space-x-2">
                <Clock className="w-4 h-4" />
                <span>{course.duration}</span>
              </div>
              <div className="flex items-center space-x-2">
                <Users className="w-4 h-4" />
                <span>{course.students.toLocaleString()} studenti</span>
              </div>
              <div className="flex items-center space-x-2">
                <Award className="w-4 h-4" />
                <span>{course.lessons} lezioni</span>
              </div>
              <div className="text-xs">
                Aggiornato: {new Date(course.lastUpdated).toLocaleDateString('it-IT')}
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center justify-between pt-4 border-t border-stone-200 dark:border-stone-700">
            <div className="flex items-center space-x-4">
              <button className="text-sm text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 transition-colors font-medium">
                Anteprima gratuita
              </button>
              <button className="text-sm text-stone-600 dark:text-stone-400 hover:text-stone-700 dark:hover:text-stone-300 transition-colors">
                Aggiungi ai preferiti
              </button>
            </div>

            <div className="flex items-center space-x-3">
              {course.canBuyIndividualLessons && (
                <button className="text-sm border-2 border-amber-400 text-amber-600 dark:text-amber-400 font-semibold py-2 px-4 rounded-xl hover:bg-amber-50 dark:hover:bg-amber-900/20 transition-all duration-200">
                  Singole lezioni
                </button>
              )}
              <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-semibold py-2 px-6 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200 flex items-center space-x-2">
                <ShoppingCart className="w-4 h-4" />
                <span>Acquista corso</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}; 