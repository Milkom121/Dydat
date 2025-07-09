import React from 'react';
import { Clock, Brain, Calendar } from 'lucide-react';

export const StudyScheduleWidget: React.FC = () => {
  const schedule = [
    {
      time: '09:00',
      title: 'Ripasso JavaScript ES6',
      duration: '30 min',
      type: 'review',
      priority: 'alta'
    },
    {
      time: '14:00',
      title: 'Nuova lezione: React Hooks',
      duration: '45 min',
      type: 'new',
      priority: 'media'
    },
    {
      time: '17:00',
      title: 'Pratica Canvas - Mappa Mentale',
      duration: '20 min',
      type: 'practice',
      priority: 'bassa'
    }
  ];

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'review':
        return 'bg-blue-100 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300';
      case 'new':
        return 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300';
      case 'practice':
        return 'bg-purple-100 dark:bg-purple-900/20 text-purple-700 dark:text-purple-300';
      default:
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'alta':
        return 'border-l-red-500';
      case 'media':
        return 'border-l-amber-500';
      case 'bassa':
        return 'border-l-emerald-500';
      default:
        return 'border-l-stone-300';
    }
  };

  return (
    <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
          Agenda di Studio
        </h2>
        <div className="flex items-center space-x-2 text-stone-500 dark:text-stone-500">
          <Calendar className="w-4 h-4" />
          <span className="text-sm">Oggi</span>
        </div>
      </div>
      
      <div className="space-y-4">
        {schedule.map((item, index) => (
          <div 
            key={index}
            className={`p-4 rounded-lg border-l-4 ${getPriorityColor(item.priority)} bg-stone-50 dark:bg-stone-800/50`}
          >
            <div className="flex items-start justify-between mb-2">
              <div className="flex items-center space-x-3">
                <div className="text-center">
                  <div className="text-lg font-bold text-stone-900 dark:text-stone-100">
                    {item.time}
                  </div>
                </div>
                <div className="flex-1">
                  <h3 className="font-medium text-stone-900 dark:text-stone-100 mb-1">
                    {item.title}
                  </h3>
                  <div className="flex items-center space-x-2">
                    <span className={`text-xs px-2 py-1 rounded-full ${getTypeColor(item.type)}`}>
                      {item.type === 'review' && 'Ripasso'}
                      {item.type === 'new' && 'Nuovo'}
                      {item.type === 'practice' && 'Pratica'}
                    </span>
                    <span className="flex items-center space-x-1 text-sm text-stone-500 dark:text-stone-500">
                      <Clock className="w-3 h-3" />
                      <span>{item.duration}</span>
                    </span>
                  </div>
                </div>
              </div>
              <button className="text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 transition-colors">
                <Brain className="w-5 h-5" />
              </button>
            </div>
          </div>
        ))}
      </div>
      
      <div className="mt-6 p-4 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-lg border border-amber-200 dark:border-amber-800">
        <div className="flex items-center space-x-2 mb-2">
          <Brain className="w-4 h-4 text-amber-600 dark:text-amber-400" />
          <span className="text-sm font-medium text-amber-700 dark:text-amber-300">
            Consiglio AI
          </span>
        </div>
        <p className="text-xs text-amber-600 dark:text-amber-400">
          Ottimo momento per una pausa! Considera di fare una camminata di 10 minuti prima della prossima sessione.
        </p>
      </div>
    </div>
  );
};