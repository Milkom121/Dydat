import React from 'react';
import { Play, Clock, CheckCircle, Award, Star, MoreVertical } from 'lucide-react';

interface Course {
  id: number;
  title: string;
  instructor: string;
  image: string;
  progress: number;
  status: string;
  rating: number;
  totalLessons: number;
  completedLessons: number;
  duration: string;
  lastAccessed: string;
  certificate: boolean;
  category: string;
}

interface MyCourseCardProps {
  course: Course;
}

export const MyCourseCard: React.FC<MyCourseCardProps> = ({ course }) => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300';
      case 'in-progress':
        return 'bg-amber-100 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300';
      default:
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'completed':
        return 'Completato';
      case 'in-progress':
        return 'In Corso';
      default:
        return 'Non Iniziato';
    }
  };

  return (
    <div className="group bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 overflow-hidden hover:shadow-xl transition-all duration-300 hover:scale-105">
      {/* Course Image */}
      <div className="relative">
        <img 
          src={course.image}
          alt={course.title}
          className="w-full h-48 object-cover"
        />
        
        {/* Overlay on Hover */}
        <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 transition-all duration-300 flex items-center justify-center">
          <button className="opacity-0 group-hover:opacity-100 transition-all duration-300 bg-white text-stone-900 px-6 py-3 rounded-xl font-bold flex items-center space-x-2 hover:bg-stone-100 transform hover:scale-105">
            <Play className="w-4 h-4" />
            <span>{course.status === 'completed' ? 'Rivedi' : 'Continua'}</span>
          </button>
        </div>

        {/* Status Badge */}
        <div className="absolute top-3 left-3">
          <span className={`text-xs font-bold px-3 py-1 rounded-full ${getStatusColor(course.status)}`}>
            {getStatusLabel(course.status)}
          </span>
        </div>

        {/* Certificate Badge */}
        {course.certificate && (
          <div className="absolute top-3 right-3">
            <div className="bg-gradient-to-r from-purple-500 to-pink-500 text-white p-2 rounded-full shadow-lg">
              <Award className="w-4 h-4" />
            </div>
          </div>
        )}

        {/* Progress Bar */}
        <div className="absolute bottom-0 left-0 right-0 bg-black bg-opacity-50 p-3">
          <div className="flex items-center justify-between text-white text-sm mb-2">
            <span>{course.progress}% completato</span>
            <span>{course.completedLessons}/{course.totalLessons} lezioni</span>
          </div>
          <div className="w-full bg-white bg-opacity-30 rounded-full h-2">
            <div 
              className="bg-gradient-to-r from-amber-400 to-orange-500 h-2 rounded-full transition-all duration-500"
              style={{ width: `${course.progress}%` }}
            ></div>
          </div>
        </div>
      </div>

      {/* Course Content */}
      <div className="p-6">
        {/* Header */}
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <span className="text-xs font-medium text-amber-600 dark:text-amber-400 bg-amber-50 dark:bg-amber-900/20 px-2 py-1 rounded mb-2 inline-block">
              {course.category}
            </span>
            <h3 className="font-bold text-lg text-stone-900 dark:text-stone-100 mb-1 line-clamp-2 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
              {course.title}
            </h3>
            <p className="text-stone-600 dark:text-stone-400 text-sm">
              {course.instructor}
            </p>
          </div>
          <button className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors">
            <MoreVertical className="w-4 h-4 text-stone-500" />
          </button>
        </div>

        {/* Stats */}
        <div className="flex items-center space-x-4 text-sm text-stone-500 dark:text-stone-500 mb-4">
          <div className="flex items-center space-x-1">
            <Star className="w-4 h-4 fill-current text-amber-400" />
            <span>{course.rating}</span>
          </div>
          <div className="flex items-center space-x-1">
            <Clock className="w-4 h-4" />
            <span>{course.duration}</span>
          </div>
        </div>

        {/* Last Accessed */}
        <div className="text-xs text-stone-500 dark:text-stone-500 mb-4">
          Ultimo accesso: {course.lastAccessed}
        </div>

        {/* Action Button */}
        <button className="w-full bg-gradient-to-r from-amber-400 to-orange-500 text-white font-bold py-3 px-4 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200 transform hover:scale-105">
          {course.status === 'completed' ? 'Rivedi Corso' : 'Continua Corso'}
        </button>
      </div>
    </div>
  );
};