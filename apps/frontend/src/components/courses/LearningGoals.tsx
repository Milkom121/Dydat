import React from 'react';
import { Target, Plus, CheckCircle } from 'lucide-react';

export const LearningGoals: React.FC = () => {
  const goals = [
    {
      id: 1,
      title: 'Completare React Avanzato',
      description: 'Finire tutte le 20 lezioni entro fine mese',
      progress: 65,
      deadline: '31 Dic 2024',
      priority: 'alta',
      completed: false
    },
    {
      id: 2,
      title: 'Ottenere certificazione TypeScript',
      description: 'Superare l\'esame finale con almeno 80%',
      progress: 40,
      deadline: '15 Gen 2025',
      priority: 'media',
      completed: false
    },
    {
      id: 3,
      title: 'Studiare 5 ore a settimana',
      description: 'Mantenere costanza nello studio',
      progress: 100,
      deadline: 'Settimanale',
      priority: 'alta',
      completed: true
    }
  ];

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'alta':
        return 'border-l-red-500 bg-red-50/50 dark:bg-red-900/10';
      case 'media':
        return 'border-l-amber-500 bg-amber-50/50 dark:bg-amber-900/10';
      case 'bassa':
        return 'border-l-emerald-500 bg-emerald-50/50 dark:bg-emerald-900/10';
      default:
        return 'border-l-stone-300 bg-stone-50/50 dark:bg-stone-800/50';
    }
  };

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-lg">
            <Target className="w-5 h-5 text-white" />
          </div>
          <div>
            <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
              Obiettivi di Apprendimento
            </h2>
            <p className="text-sm text-stone-600 dark:text-stone-400">
              Traccia i tuoi progressi
            </p>
          </div>
        </div>
        <button className="p-2 rounded-lg bg-emerald-100 dark:bg-emerald-900/20 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-200 dark:hover:bg-emerald-900/30 transition-colors">
          <Plus className="w-4 h-4" />
        </button>
      </div>

      <div className="space-y-4">
        {goals.map((goal) => (
          <div 
            key={goal.id}
            className={`p-4 rounded-xl border-l-4 ${getPriorityColor(goal.priority)} ${
              goal.completed ? 'opacity-75' : ''
            }`}
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex-1">
                <div className="flex items-center space-x-2 mb-1">
                  <h3 className={`font-medium ${
                    goal.completed 
                      ? 'line-through text-stone-500 dark:text-stone-500' 
                      : 'text-stone-900 dark:text-stone-100'
                  }`}>
                    {goal.title}
                  </h3>
                  {goal.completed && (
                    <CheckCircle className="w-4 h-4 text-emerald-500" />
                  )}
                </div>
                <p className="text-sm text-stone-600 dark:text-stone-400 mb-2">
                  {goal.description}
                </p>
                <div className="text-xs text-stone-500 dark:text-stone-500">
                  Scadenza: {goal.deadline}
                </div>
              </div>
            </div>

            {!goal.completed && (
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-stone-600 dark:text-stone-400">Progresso</span>
                  <span className="font-medium text-emerald-600 dark:text-emerald-400">
                    {goal.progress}%
                  </span>
                </div>
                <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                  <div 
                    className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full transition-all duration-500"
                    style={{ width: `${goal.progress}%` }}
                  ></div>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      <button className="w-full mt-4 py-3 px-4 border-2 border-dashed border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 rounded-xl hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors font-medium">
        + Aggiungi Nuovo Obiettivo
      </button>
    </div>
  );
}; 