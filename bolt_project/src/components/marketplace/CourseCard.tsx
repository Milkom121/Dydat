import React, { useState } from 'react';
import { Star, Clock, Users, Play, Heart, ShoppingCart, Zap } from 'lucide-react';

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

interface CourseCardProps {
  course: Course;
}

export const CourseCard: React.FC<CourseCardProps> = ({ course }) => {
  const [isWishlisted, setIsWishlisted] = useState(false);
  const [showPurchaseOptions, setShowPurchaseOptions] = useState(false);

  const discount = course.originalPrice 
    ? Math.round(((course.originalPrice - course.price) / course.originalPrice) * 100)
    : 0;

  const handleAddToCart = (type: 'full' | 'lesson') => {
    // Handle add to cart logic
    console.log(`Added ${type} to cart for course ${course.id}`);
  };

  return (
    <div className="group bg-white dark:bg-stone-900 rounded-xl border border-stone-200 dark:border-stone-800 overflow-hidden hover:shadow-lg transition-all duration-300 hover:scale-105">
      {/* Course Image */}
      <div className="relative">
        <img 
          src={course.image}
          alt={course.title}
          className="w-full h-48 object-cover"
        />
        
        {/* Overlay on Hover */}
        <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 transition-all duration-300 flex items-center justify-center">
          <button className="opacity-0 group-hover:opacity-100 transition-all duration-300 bg-white text-stone-900 px-4 py-2 rounded-lg font-medium flex items-center space-x-2 hover:bg-stone-100">
            <Play className="w-4 h-4" />
            <span>Anteprima</span>
          </button>
        </div>

        {/* Badges */}
        <div className="absolute top-3 left-3 flex flex-col space-y-2">
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

        {/* Wishlist Button */}
        <button
          onClick={() => setIsWishlisted(!isWishlisted)}
          className="absolute top-3 right-3 p-2 rounded-full bg-white dark:bg-stone-800 shadow-md hover:scale-110 transition-transform"
        >
          <Heart 
            className={`w-4 h-4 ${
              isWishlisted 
                ? 'fill-red-500 text-red-500' 
                : 'text-stone-400 hover:text-red-500'
            }`} 
          />
        </button>
      </div>

      {/* Course Content */}
      <div className="p-5">
        {/* Category & Level */}
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-medium text-amber-600 dark:text-amber-400 bg-amber-50 dark:bg-amber-900/20 px-2 py-1 rounded">
            {course.category}
          </span>
          <span className="text-xs text-stone-500 dark:text-stone-500">
            {course.level}
          </span>
        </div>

        {/* Title */}
        <h3 className="font-semibold text-stone-900 dark:text-stone-100 mb-2 line-clamp-2 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
          {course.title}
        </h3>

        {/* Instructor */}
        <p className="text-sm text-stone-600 dark:text-stone-400 mb-3">
          {course.instructor}
        </p>

        {/* Rating & Stats */}
        <div className="flex items-center space-x-4 mb-3 text-sm text-stone-500 dark:text-stone-500">
          <div className="flex items-center space-x-1">
            <Star className="w-4 h-4 fill-current text-amber-400" />
            <span className="font-medium">{course.rating}</span>
            <span>({course.reviewCount})</span>
          </div>
          <div className="flex items-center space-x-1">
            <Users className="w-4 h-4" />
            <span>{course.students.toLocaleString()}</span>
          </div>
          <div className="flex items-center space-x-1">
            <Clock className="w-4 h-4" />
            <span>{course.duration}</span>
          </div>
        </div>

        {/* Price */}
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-2">
            <span className="text-xl font-bold text-stone-900 dark:text-stone-100">
              €{course.price}
            </span>
            {course.originalPrice && (
              <span className="text-sm text-stone-500 dark:text-stone-500 line-through">
                €{course.originalPrice}
              </span>
            )}
          </div>
          {course.canBuyIndividualLessons && (
            <div className="text-right">
              <div className="text-xs text-stone-500 dark:text-stone-500">
                o singole lezioni
              </div>
              <div className="text-sm font-medium text-amber-600 dark:text-amber-400">
                €{course.lessonPrice}/lezione
              </div>
            </div>
          )}
        </div>

        {/* Purchase Options */}
        <div className="space-y-2">
          <button
            onClick={() => handleAddToCart('full')}
            className="w-full bg-gradient-to-r from-amber-400 to-orange-500 text-white font-medium py-2 px-4 rounded-lg hover:from-amber-500 hover:to-orange-600 transition-all duration-200 flex items-center justify-center space-x-2"
          >
            <ShoppingCart className="w-4 h-4" />
            <span>Acquista Corso</span>
          </button>
          
          {course.canBuyIndividualLessons && (
            <button
              onClick={() => setShowPurchaseOptions(!showPurchaseOptions)}
              className="w-full border border-amber-300 dark:border-amber-600 text-amber-600 dark:text-amber-400 font-medium py-2 px-4 rounded-lg hover:bg-amber-50 dark:hover:bg-amber-900/10 transition-colors flex items-center justify-center space-x-2"
            >
              <Zap className="w-4 h-4" />
              <span>Lezioni Singole</span>
            </button>
          )}
        </div>

        {/* Lesson Count */}
        <div className="mt-3 text-xs text-stone-500 dark:text-stone-500 text-center">
          {course.lessons} lezioni • Aggiornato {new Date(course.lastUpdated).toLocaleDateString('it-IT')}
        </div>
      </div>
    </div>
  );
};