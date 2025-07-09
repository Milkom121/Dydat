import React from 'react';
import { Target } from 'lucide-react';

export const TutorGoals: React.FC = () => {
  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
      <div className="flex items-center space-x-3 mb-4">
        <div className="p-2 bg-gradient-to-r from-amber-400 to-orange-500 rounded-lg">
          <Target className="w-4 h-4 text-white" />
        </div>
        <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
          Obiettivi Mensili
        </h3>
      </div>

      <div className="space-y-4">
        <div>
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
              Sessioni (15/20)
            </span>
            <span className="text-sm text-amber-600 dark:text-amber-400">75%</span>
          </div>
          <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
            <div className="bg-gradient-to-r from-amber-400 to-orange-500 h-2 rounded-full" style={{ width: '75%' }}></div>
          </div>
        </div>

        <div>
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
              Rating 4.9+ (4.8)
            </span>
            <span className="text-sm text-emerald-600 dark:text-emerald-400">95%</span>
          </div>
          <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
            <div className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full" style={{ width: '95%' }}></div>
          </div>
        </div>
      </div>
    </div>
  );
};