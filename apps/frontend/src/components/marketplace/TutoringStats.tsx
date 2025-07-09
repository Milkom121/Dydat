import React from 'react';
import { Clock, BookOpen, Star, TrendingUp, Calendar, Award } from 'lucide-react';

export const TutoringStats: React.FC = () => {
  const stats = {
    totalSessions: 24,
    totalHours: 38.5,
    averageRating: 4.8,
    completionRate: 96,
    favoriteSubjects: ['React', 'TypeScript', 'Python'],
    thisMonth: {
      sessions: 6,
      hours: 9.5,
      improvement: '+23%'
    },
    achievements: [
      { name: 'Studente Dedicato', icon: '📚', description: '10+ sessioni completate' },
      { name: 'Feedback Eccellente', icon: '⭐', description: 'Rating medio 4.5+' },
      { name: 'Learner Costante', icon: '🎯', description: 'Sessioni per 3 mesi consecutivi' }
    ]
  };

  return (
    <div className="space-y-6">
      <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100">
        Le Tue Statistiche
      </h3>

      {/* Main Stats */}
      <div className="grid grid-cols-1 gap-4">
        <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 shadow-lg">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-xl flex items-center justify-center">
              <BookOpen className="w-5 h-5 text-white" />
            </div>
            <div>
              <div className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                {stats.totalSessions}
              </div>
              <div className="text-sm text-stone-600 dark:text-stone-400">
                Sessioni Totali
              </div>
            </div>
          </div>
          <div className="text-xs text-emerald-600 dark:text-emerald-400 font-medium">
            +{stats.thisMonth.sessions} questo mese
          </div>
        </div>

        <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 shadow-lg">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-gradient-to-r from-blue-400 to-cyan-500 rounded-xl flex items-center justify-center">
              <Clock className="w-5 h-5 text-white" />
            </div>
            <div>
              <div className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                {stats.totalHours}h
              </div>
              <div className="text-sm text-stone-600 dark:text-stone-400">
                Ore di Studio
              </div>
            </div>
          </div>
          <div className="text-xs text-blue-600 dark:text-blue-400 font-medium">
            +{stats.thisMonth.hours}h questo mese
          </div>
        </div>

        <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 shadow-lg">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-gradient-to-r from-amber-400 to-orange-500 rounded-xl flex items-center justify-center">
              <Star className="w-5 h-5 text-white" />
            </div>
            <div>
              <div className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                {stats.averageRating}
              </div>
              <div className="text-sm text-stone-600 dark:text-stone-400">
                Rating Medio
              </div>
            </div>
          </div>
          <div className="flex items-center space-x-1">
            {Array.from({ length: 5 }, (_, i) => (
              <Star
                key={i}
                className={`w-3 h-3 ${
                  i < Math.floor(stats.averageRating)
                    ? 'text-amber-400 fill-current'
                    : 'text-gray-300 dark:text-gray-600'
                }`}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Progress This Month */}
      <div className="bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/20 dark:to-teal-900/20 rounded-2xl border border-emerald-200/50 dark:border-emerald-800/50 p-6">
        <div className="flex items-center space-x-3 mb-4">
          <TrendingUp className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
          <h4 className="font-bold text-stone-900 dark:text-stone-100">
            Progresso Questo Mese
          </h4>
        </div>
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <span className="text-sm text-stone-600 dark:text-stone-400">Completamento</span>
            <span className="text-sm font-bold text-emerald-600 dark:text-emerald-400">
              {stats.completionRate}%
            </span>
          </div>
          <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
            <div 
              className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full transition-all duration-300"
              style={{ width: `${stats.completionRate}%` }}
            ></div>
          </div>
          <div className="text-xs text-stone-600 dark:text-stone-400">
            Miglioramento: <span className="text-emerald-600 dark:text-emerald-400 font-medium">{stats.thisMonth.improvement}</span>
          </div>
        </div>
      </div>

      {/* Favorite Subjects */}
      <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 shadow-lg">
        <h4 className="font-bold text-stone-900 dark:text-stone-100 mb-4">
          Materie Preferite
        </h4>
        <div className="space-y-2">
          {stats.favoriteSubjects.map((subject, index) => (
            <div
              key={subject}
              className="flex items-center justify-between p-3 bg-stone-50 dark:bg-stone-800/50 rounded-xl"
            >
              <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                {subject}
              </span>
              <div className="w-6 h-6 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full flex items-center justify-center text-white text-xs font-bold">
                {index + 1}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Achievements */}
      <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 shadow-lg">
        <div className="flex items-center space-x-3 mb-4">
          <Award className="w-5 h-5 text-amber-500" />
          <h4 className="font-bold text-stone-900 dark:text-stone-100">
            Achievement
          </h4>
        </div>
        <div className="space-y-3">
          {stats.achievements.map((achievement, index) => (
            <div
              key={index}
              className="flex items-center space-x-3 p-3 bg-amber-50 dark:bg-amber-900/20 rounded-xl border border-amber-200/50 dark:border-amber-800/50"
            >
              <div className="text-2xl">{achievement.icon}</div>
              <div className="flex-1 min-w-0">
                <div className="text-sm font-bold text-stone-900 dark:text-stone-100">
                  {achievement.name}
                </div>
                <div className="text-xs text-stone-600 dark:text-stone-400">
                  {achievement.description}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="space-y-3">
        <button className="w-full bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-semibold py-3 px-4 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
          Prenota Prossima Sessione
        </button>
        <button className="w-full border-2 border-emerald-400 text-emerald-600 dark:text-emerald-400 font-semibold py-3 px-4 rounded-xl hover:bg-emerald-50 dark:hover:bg-emerald-900/20 transition-all duration-200">
          Vedi Tutor Preferiti
        </button>
      </div>
    </div>
  );
}; 