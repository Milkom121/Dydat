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

interface MyCourseListItemProps {
  course: Course;
}

export const MyCourseListItem: React.FC<MyCourseListItemProps> = ({ course }) => {
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
    <div className="group bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 hover:shadow-lg transition-all duration-300">
      <div className="flex items-center space-x-6">
        {/* Course Image */}
        <div className="relative flex-shrink-0">
          <img 
            src={course.image}
            alt={course.title}
            className="w-32 h-24 object-cover rounded-xl"
          />
          
          {/* Play Button Overlay */}
          <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 transition-all duration-300 flex items-center justify-center rounded-xl">
            <button className="opacity-0 group-hover:opacity-100 transition-all duration-300 bg-white text-stone-900 p-3 rounded-full hover:bg-stone-100">
              <Play className="w-5 h-5" />
            </button>
          </div>

          {/* Certificate Badge */}
          {course.certificate && (
            <div className="absolute -top-2 -right-2">
              <div className="bg-gradient-to-r from-purple-500 to-pink-500 text-white p-2 rounded-full shadow-lg">
                <Award className="w-4 h-4" />
              </div>
            </div>
          )}
        </div>

        {/* Course Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between mb-3">
            <div className="flex-1">
              <div className="flex items-center space-x-3 mb-2">
                <span className="text-xs font-medium text-amber-600 dark:text-amber-400 bg-amber-50 dark:bg-amber-900/20 px-2 py-1 rounded">
                  {course.category}
                </span>
                <span className={`text-xs font-bold px-3 py-1 rounded-full ${getStatusColor(course.status)}`}>
                  {getStatusLabel(course.status)}
                </span>
              </div>

              <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-2 group-hover:text-amber-600 dark:group-hover:text-amber-400 transition-colors">
                {course.title}
              </h3>

              <p className="text-stone-600 dark:text-stone-400 mb-3">
                di {course.instructor}
              </p>

              {/* Progress */}
              <div className="space-y-2 mb-4">
                <div className="flex justify-between text-sm">
                  <span className="text-stone-600 dark:text-stone-400">
                    Progresso: {course.completedLessons}/{course.totalLessons} lezioni
                  </span>
                  <span className="font-medium text-amber-600 dark:text-amber-400">
                    {course.progress}%
                  </span>
                </div>
                <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                  <div 
                    className="bg-gradient-to-r from-amber-400 to-orange-500 h-2 rounded-full transition-all duration-500"
                    style={{ width: `${course.progress}%` }}
                  ></div>
                </div>
              </div>

              {/* Stats */}
              <div className="flex items-center space-x-6 text-stone-500 dark:text-stone-500 text-sm">
                <div className="flex items-center space-x-1">
                  <Star className="w-4 h-4 fill-current text-amber-400" />
                  <span>{course.rating}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Clock className="w-4 h-4" />
                  <span>{course.duration}</span>
                </div>
                <span>Ultimo accesso: {course.lastAccessed}</span>
              </div>
            </div>

            <button className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors">
              <MoreVertical className="w-5 h-5 text-stone-500" />
            </button>
          </div>
        </div>

        {/* Action Button */}
        <div className="flex-shrink-0">
          <button className="bg-gradient-to-r from-amber-400 to-orange-500 text-white font-bold py-3 px-8 rounded-xl hover:from-amber-500 hover:to-orange-600 transition-all duration-200 transform hover:scale-105 shadow-lg">
            {course.status === 'completed' ? 'Rivedi' : 'Continua'}
          </button>
        </div>
      </div>
    </div>
  );
};