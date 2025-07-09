import React from 'react';
import { TrendingUp, Clock, Target, Zap, Calendar } from 'lucide-react';

export const StudyStats: React.FC = () => {
  const stats = [
    {
      icon: Clock,
      label: 'Tempo di Studio',
      value: '24h 30min',
      subtitle: 'Questa settimana',
      color: 'from-blue-400 to-blue-600',
      change: '+15%'
    },
    {
      icon: Target,
      label: 'Obiettivo Settimanale',
      value: '5/7 giorni',
      subtitle: '71% completato',
      color: 'from-emerald-400 to-emerald-600',
      change: '+2 giorni'
    },
    {
      icon: Zap,
      label: 'Streak Corrente',
      value: '12 giorni',
      subtitle: 'Record personale!',
      color: 'from-amber-400 to-orange-500',
      change: 'Nuovo record!'
    },
    {
      icon: TrendingUp,
      label: 'Media Completamento',
      value: '85%',
      subtitle: 'Sopra la media',
      color: 'from-purple-400 to-purple-600',
      change: '+12%'
    }
  ];

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
      <div className="flex items-center space-x-3 mb-6">
        <div className="p-2 bg-gradient-to-r from-blue-400 to-purple-500 rounded-lg">
          <TrendingUp className="w-5 h-5 text-white" />
        </div>
        <div>
          <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
            Statistiche di Studio
          </h2>
          <p className="text-sm text-stone-600 dark:text-stone-400">
            I tuoi progressi questa settimana
          </p>
        </div>
      </div>

      <div className="space-y-4">
        {stats.map((stat, index) => (
          <div key={index} className="p-4 bg-stone-50/50 dark:bg-stone-800/50 rounded-xl">
            <div className="flex items-center space-x-3 mb-3">
              <div className={`p-2 rounded-lg bg-gradient-to-r ${stat.color}`}>
                <stat.icon className="w-4 h-4 text-white" />
              </div>
              <div className="flex-1">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                    {stat.label}
                  </span>
                  <span className="text-xs text-emerald-600 dark:text-emerald-400 font-medium">
                    {stat.change}
                  </span>
                </div>
                <div className="text-lg font-bold text-stone-900 dark:text-stone-100">
                  {stat.value}
                </div>
                <div className="text-xs text-stone-500 dark:text-stone-500">
                  {stat.subtitle}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Weekly Calendar */}
      <div className="mt-6 p-4 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-xl border border-amber-200/50 dark:border-amber-800/50">
        <div className="flex items-center space-x-2 mb-3">
          <Calendar className="w-4 h-4 text-amber-600 dark:text-amber-400" />
          <span className="text-sm font-medium text-amber-700 dark:text-amber-300">
            Attività Settimanale
          </span>
        </div>
        <div className="grid grid-cols-7 gap-1">
          {['L', 'M', 'M', 'G', 'V', 'S', 'D'].map((day, index) => (
            <div key={index} className="text-center">
              <div className="text-xs text-stone-500 dark:text-stone-500 mb-1">{day}</div>
              <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold ${
                index < 5 
                  ? 'bg-gradient-to-r from-emerald-400 to-emerald-500 text-white' 
                  : 'bg-stone-200 dark:bg-stone-700 text-stone-500 dark:text-stone-400'
              }`}>
                {index + 1}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};