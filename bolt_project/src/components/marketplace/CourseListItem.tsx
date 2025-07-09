import React, { useState } from 'react';
import { Star, Clock, Users, Play, Heart, ShoppingCart, Zap, BookOpen } from 'lucide-react';

interface Course {
  id: number;
  title: string;
  instructor: string;
  rating: number;
  reviewCount: number;
  students: number;
  duration: string;
  level: string;
  price: number;
  originalPrice?: number;
  category: string;
  image: string;
  description: string;
  lessons: number;
  lastUpdated: string;
  bestseller: boolean;
  canBuyIndividualLessons: boolean;
  lessonPrice: number;
}

interface CourseListItemProps {
  course: Course;
}

export const CourseListItem: React.FC<CourseListItemProps> = ({ course }) => {
  const [isWishlisted, setIsWishlisted] = useState(false);

  const discount = course.originalPrice 
    ? Math.round(((course.originalPrice - course.price) / course.originalPrice) * 100)
    : 0;

  const handleAddToCart = (type: 'full' | 'lesson') => {
    console.log(`Added ${type} to cart for course ${course.id}`);
  };

  return (
    <div className="group bg-white dark:bg-stone-900 rounded-xl border border-stone-200 dark:border-stone-800 p-6 hover:shadow-lg transition-all duration-300">
      <div className="flex space-x-6">
        {/* Course Image */}
        <div className="relative flex-shrink-0">
          <img 
            src={course.image}
            alt={course.title}
            className="w-48 h-32 object-cover rounded-lg"
          />
          
          {/* Play Button Overlay */}
          <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 transition-all duration-300 flex items-center justify-center rounded-lg">
            <button className="opacity-0 group-hover:opacity-100 transition-all duration-300 bg-white text-stone-900 p-3 rounded-full hover:bg-stone-100">
              <Play className="w-5 h-5" />
            </button>
          </div>

          {/* Badges */}
          <div className="absolute top-2 left-2 flex flex-col space-y-1">
            {course.bestseller && (
              <span className="bg-amber-500 text-white text-xs font-bold px-2 py-1 rounded">
                BESTSELLER
              </span>
            )}
            {discount > 0 && (
              <span className="bg-red-500 text-white text-xs font-bold px-2 py-1 rounded">
                -{discount}%
              </span>
            )}
          </div>
        </div>

        {/* Course Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between mb-3">
            <div className="flex-1">
              {/* Category & Level */}
              <div className="flex items-center space-x-3 mb-2">
                <span className="text-xs font-medium text-amber-600 dark:text-amber-400 bg-amber-50 dark:bg-amber-900/20 px-2 py-1 rounded">
                  {course.category}
                </span>
                <span className="text-xs text-stone-500 dark:text-stone-500">
                  {course.level}
                </span>
              </div>

              {/* Title */}
              <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                {course.title}
              </h3>

              {/* Instructor */}
              <p className="text-stone-600 dark:text-stone-400 mb-3">
                di {course.instructor}
              </p>

              {/* Description */}
              <p className="text-stone-600 dark:text-stone-400 text-sm mb-4 line-clamp-2">
                {course.description}
              </p>

              {/* Stats */}
              <div className="flex items-center space-x-6 text-sm text-stone-500 dark:text-stone-500 mb-4">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 fill-current text-amber-400" />
                  <span className="font-medium">{course.rating}</span>
                  <span>({course.reviewCount} recensioni)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Users className="w-4 h-4" />
                  <span>{course.students.toLocaleString()} studenti</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="w-4 h-4" />
                  <span>{course.duration}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <BookOpen className="w-4 h-4" />
                  <span>{course.lessons} lezioni</span>
                </div>
              </div>

              {/* Last Updated */}
              <p className="text-xs text-stone-500 dark:text-stone-500">
                Aggiornato il {new Date(course.lastUpdated).toLocaleDateString('it-IT')}
              </p>
            </div>

            {/* Wishlist Button */}
            <button
              onClick={() => setIsWishlisted(!isWishlisted)}
              className="p-2 rounded-full hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors"
            >
              <Heart 
                className={`w-5 h-5 ${
                  isWishlisted 
                    ? 'fill-red-500 text-red-500' 
                    : 'text-stone-400 hover:text-red-500'
                }`} 
              />
            </button>
          </div>
        </div>

        {/* Price & Actions */}
        <div className="flex-shrink-0 w-48 text-right">
          {/* Price */}
          <div className="mb-4">
            <div className="text-2xl font-bold text-stone-900 dark:text-stone-100">
              €{course.price}
            </div>
            {course.originalPrice && (
              <div className="text-stone-500 dark:text-stone-500 line-through">
                €{course.originalPrice}
              </div>
            )}
            {course.canBuyIndividualLessons && (
              <div className="mt-2 text-sm">
                <div className="text-stone-500 dark:text-stone-500">
                  o singole lezioni da
                </div>
                <div className="font-medium text-amber-600 dark:text-amber-400">
                  €{course.lessonPrice}
                </div>
              </div>
            )}
          </div>

          {/* Action Buttons */}
          <div className="space-y-2">
            <button
              onClick={() => handleAddToCart('full')}
              className="w-full bg-gradient-to-r from-amber-400 to-orange-500 text-white font-medium py-3 px-4 rounded-lg hover:from-amber-500 hover:to-orange-600 transition-all duration-200 flex items-center justify-center space-x-2"
            >
              <ShoppingCart className="w-4 h-4" />
              <span>Acquista Corso</span>
            </button>
            
            {course.canBuyIndividualLessons && (
              <button
                onClick={() => handleAddToCart('lesson')}
                className="w-full border border-amber-300 dark:border-amber-600 text-amber-600 dark:text-amber-400 font-medium py-3 px-4 rounded-lg hover:bg-amber-50 dark:hover:bg-amber-900/10 transition-colors flex items-center justify-center space-x-2"
              >
                <Zap className="w-4 h-4" />
                <span>Lezioni Singole</span>
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};