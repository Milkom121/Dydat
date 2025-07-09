import React from 'react';
import { Trophy, Zap, Target, TrendingUp } from 'lucide-react';

export const StatsWidget: React.FC = () => {
  const stats = [
    {
      icon: Zap,
      label: 'Livello XP',
      value: 'Livello 12',
      progress: 75,
      color: 'from-amber-400 to-orange-500'
    },
    {
      icon: Trophy,
      label: 'Badge Sbloccati',
      value: '8/15',
      progress: 53,
      color: 'from-emerald-400 to-teal-500'
    },
    {
      icon: Target,
      label: 'Obiettivo Settimanale',
      value: '4/7 giorni',
      progress: 57,
      color: 'from-blue-400 to-indigo-500'
    },
    {
      icon: TrendingUp,
      label: 'Streak Corrente',
      value: '12 giorni',
      progress: 100,
      color: 'from-purple-400 to-pink-500'
    }
  ];

  return (
    <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
      <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-6">
        Le Mie Statistiche
      </h2>
      
      <div className="space-y-4">
        {stats.map((stat) => (
          <div key={stat.label} className="space-y-2">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <div className={`p-2 rounded-lg bg-gradient-to-r ${stat.color}`}>
                  <stat.icon className="w-4 h-4 text-white" />
                </div>
                <div>
                  <p className="text-sm font-medium text-stone-900 dark:text-stone-100">
                    {stat.label}
                  </p>
                  <p className="text-xs text-stone-500 dark:text-stone-500">
                    {stat.value}
                  </p>
                </div>
              </div>
              <span className="text-sm font-medium text-stone-600 dark:text-stone-400">
                {stat.progress}%
              </span>
            </div>
            <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
              <div 
                className={`bg-gradient-to-r ${stat.color} h-2 rounded-full transition-all duration-500`}
                style={{ width: `${stat.progress}%` }}
              ></div>
            </div>
          </div>
        ))}
      </div>
      
      <div className="mt-6 p-4 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-lg border border-amber-200 dark:border-amber-800">
        <div className="flex items-center space-x-2 mb-2">
          <Zap className="w-4 h-4 text-amber-600 dark:text-amber-400" />
          <span className="text-sm font-medium text-amber-700 dark:text-amber-300">
            Prossimo Livello
          </span>
        </div>
        <p className="text-xs text-amber-600 dark:text-amber-400">
          Solo 250 XP per raggiungere il Livello 13!
        </p>
      </div>
    </div>
  );
};