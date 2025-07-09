import React from 'react';
import { TrendingUp, Users, Clock, Star, Zap } from 'lucide-react';

export const TutorOverview: React.FC = () => {
  const weekStats = {
    totalSessions: 12,
    totalHours: 18,
    totalStudents: 8,
    totalEarnings: 1080,
    averageRating: 4.9
  };

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8">
      <div className="flex items-center space-x-3 mb-6">
        <div className="p-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-lg">
          <TrendingUp className="w-5 h-5 text-white" />
        </div>
        <div>
          <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
            Performance Settimanale
          </h2>
          <p className="text-stone-600 dark:text-stone-400">
            I tuoi risultati degli ultimi 7 giorni
          </p>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-5 gap-6">
        <div className="text-center">
          <div className="text-3xl font-bold text-emerald-600 dark:text-emerald-400 mb-2">
            {weekStats.totalSessions}
          </div>
          <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
            Sessioni
          </div>
        </div>
        <div className="text-center">
          <div className="text-3xl font-bold text-teal-600 dark:text-teal-400 mb-2">
            {weekStats.totalHours}h
          </div>
          <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
            Ore Totali
          </div>
        </div>
        <div className="text-center">
          <div className="text-3xl font-bold text-cyan-600 dark:text-cyan-400 mb-2">
            {weekStats.totalStudents}
          </div>
          <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
            Studenti
          </div>
        </div>
        <div className="text-center">
          <div className="text-3xl font-bold text-purple-600 dark:text-purple-400 mb-2">
            {weekStats.totalEarnings}N
          </div>
          <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
            Guadagni
          </div>
        </div>
        <div className="text-center">
          <div className="text-3xl font-bold text-amber-600 dark:text-amber-400 mb-2">
            {weekStats.averageRating}
          </div>
          <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
            Rating Medio
          </div>
        </div>
      </div>
    </div>
  );
};