import React from 'react';
import { Target, Calendar, CheckCircle } from 'lucide-react';

export const ChallengesWidget: React.FC = () => {
  const challenges = [
    {
      id: 1,
      title: 'Completa 3 lezioni oggi',
      description: 'Mantieni il ritmo di studio quotidiano',
      progress: 2,
      total: 3,
      reward: '50 XP',
      completed: false
    },
    {
      id: 2,
      title: 'Studia per 2 ore questa settimana',
      description: 'Raggiungi il tuo obiettivo settimanale',
      progress: 1.5,
      total: 2,
      reward: '100 XP',
      completed: false
    },
    {
      id: 3,
      title: 'Crea 5 flashcard dal Canvas',
      description: 'Sperimenta con gli strumenti di studio',
      progress: 5,
      total: 5,
      reward: '75 XP',
      completed: true
    }
  ];

  return (
    <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
          Le Mie Sfide
        </h2>
        <div className="flex items-center space-x-2 text-stone-500 dark:text-stone-500">
          <Calendar className="w-4 h-4" />
          <span className="text-sm">Questa settimana</span>
        </div>
      </div>
      
      <div className="space-y-4">
        {challenges.map((challenge) => (
          <div 
            key={challenge.id}
            className={`p-4 rounded-lg border-2 transition-all ${
              challenge.completed 
                ? 'bg-emerald-50 dark:bg-emerald-900/10 border-emerald-200 dark:border-emerald-800' 
                : 'bg-stone-50 dark:bg-stone-800/50 border-stone-200 dark:border-stone-700'
            }`}
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center space-x-3">
                <div className={`p-2 rounded-lg ${
                  challenge.completed ? 'bg-emerald-100 dark:bg-emerald-900/20' : 'bg-amber-100 dark:bg-amber-900/20'
                }`}>
                  {challenge.completed ? (
                    <CheckCircle className="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
                  ) : (
                    <Target className="w-4 h-4 text-amber-600 dark:text-amber-400" />
                  )}
                </div>
                <div>
                  <h3 className="font-medium text-stone-900 dark:text-stone-100">
                    {challenge.title}
                  </h3>
                  <p className="text-sm text-stone-500 dark:text-stone-500">
                    {challenge.description}
                  </p>
                </div>
              </div>
              <div className="text-right">
                <span className={`text-xs font-medium px-2 py-1 rounded-full ${
                  challenge.completed 
                    ? 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300' 
                    : 'bg-amber-100 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300'
                }`}>
                  +{challenge.reward}
                </span>
              </div>
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-stone-600 dark:text-stone-400">
                  {challenge.progress}/{challenge.total}
                </span>
                <span className={`font-medium ${
                  challenge.completed 
                    ? 'text-emerald-600 dark:text-emerald-400' 
                    : 'text-amber-600 dark:text-amber-400'
                }`}>
                  {Math.round((challenge.progress / challenge.total) * 100)}%
                </span>
              </div>
              <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                <div 
                  className={`h-2 rounded-full transition-all duration-500 ${
                    challenge.completed 
                      ? 'bg-emerald-500' 
                      : 'bg-gradient-to-r from-amber-400 to-orange-500'
                  }`}
                  style={{ width: `${Math.min((challenge.progress / challenge.total) * 100, 100)}%` }}
                ></div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};