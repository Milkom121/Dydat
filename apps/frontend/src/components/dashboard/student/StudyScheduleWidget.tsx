import React from 'react';
import { Calendar, Clock, ArrowRight } from 'lucide-react';

export const StudyScheduleWidget: React.FC = () => {
  const todaySchedule = [
    {
      id: 1,
      time: '10:00',
      course: 'React Advanced',
      lesson: 'Hooks personalizzati',
      duration: 45,
      completed: false
    },
    {
      id: 2,
      time: '14:30',
      course: 'TypeScript Avanzato',
      lesson: 'Generics e utility types',
      duration: 30,
      completed: false
    },
    {
      id: 3,
      time: '16:00',
      course: 'UI/UX Design',
      lesson: 'Design systems',
      duration: 60,
      completed: true
    }
  ];

  return (
    <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
          Programma di Oggi
        </h2>
        <div className="flex items-center space-x-2 text-stone-500 dark:text-stone-500">
          <Calendar className="w-4 h-4" />
          <span className="text-sm">3 sessioni</span>
        </div>
      </div>
      
      <div className="space-y-3">
        {todaySchedule.map((session) => (
          <div 
            key={session.id}
            className={`flex items-center justify-between p-3 rounded-lg transition-all ${
              session.completed 
                ? 'bg-emerald-50 dark:bg-emerald-900/10 border border-emerald-200 dark:border-emerald-800' 
                : 'bg-stone-50 dark:bg-stone-800/50 hover:bg-stone-100 dark:hover:bg-stone-800'
            }`}
          >
            <div className="flex items-center space-x-3">
              <div className={`w-2 h-8 rounded-full ${
                session.completed ? 'bg-emerald-500' : 'bg-amber-500'
              }`}></div>
              <div>
                <div className="flex items-center space-x-2">
                  <span className="text-sm font-medium text-stone-900 dark:text-stone-100">
                    {session.time}
                  </span>
                  <span className="text-xs text-stone-500 dark:text-stone-500">•</span>
                  <span className="text-xs text-stone-500 dark:text-stone-500 flex items-center space-x-1">
                    <Clock className="w-3 h-3" />
                    <span>{session.duration} min</span>
                  </span>
                </div>
                <h3 className="font-medium text-stone-900 dark:text-stone-100">
                  {session.course}
                </h3>
                <p className="text-sm text-stone-500 dark:text-stone-500">
                  {session.lesson}
                </p>
              </div>
            </div>
            
            {!session.completed && (
              <button className="p-2 rounded-lg bg-amber-100 dark:bg-amber-900/20 text-amber-600 dark:text-amber-400 hover:bg-amber-200 dark:hover:bg-amber-900/30 transition-colors">
                <ArrowRight className="w-4 h-4" />
              </button>
            )}
          </div>
        ))}
      </div>
      
      <button className="w-full mt-4 text-center text-sm text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 font-medium">
        Visualizza programma completo
      </button>
    </div>
  );
}; 