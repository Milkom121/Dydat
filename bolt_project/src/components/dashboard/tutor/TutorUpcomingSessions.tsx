import React from 'react';
import { Calendar, Clock, Zap } from 'lucide-react';

export const TutorUpcomingSessions: React.FC = () => {
  const upcomingSessions = [
    {
      id: '1',
      studentName: 'Marco Verdi',
      studentAvatar: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Matematica',
      topic: 'Calcolo Differenziale',
      time: '14:30',
      duration: 60,
      price: 80,
      isNew: false
    },
    {
      id: '2',
      studentName: 'Laura Rossi',
      studentAvatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Fisica',
      topic: 'Meccanica Quantistica',
      time: '16:00',
      duration: 90,
      price: 120,
      isNew: true
    }
  ];

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-gradient-to-r from-blue-400 to-indigo-500 rounded-lg">
            <Calendar className="w-5 h-5 text-white" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
              Prossime Sessioni
            </h2>
            <p className="text-stone-600 dark:text-stone-400">
              Le tue sessioni programmate per oggi
            </p>
          </div>
        </div>
        <button className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium">
          Vedi Calendario
        </button>
      </div>

      <div className="space-y-4">
        {upcomingSessions.map((session) => (
          <div 
            key={session.id}
            className="flex items-center space-x-4 p-4 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/10 dark:to-indigo-900/10 rounded-xl border border-blue-200/50 dark:border-blue-800/50"
          >
            <img 
              src={session.studentAvatar}
              alt={session.studentName}
              className="w-12 h-12 rounded-full object-cover border-2 border-blue-200 dark:border-blue-700"
            />
            
            <div className="flex-1">
              <div className="flex items-center space-x-2 mb-1">
                <h3 className="font-bold text-stone-900 dark:text-stone-100">
                  {session.studentName}
                </h3>
                {session.isNew && (
                  <span className="bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 text-xs font-bold px-2 py-1 rounded-full">
                    NUOVO
                  </span>
                )}
              </div>
              <p className="text-sm text-stone-600 dark:text-stone-400 mb-1">
                {session.subject} • {session.topic}
              </p>
              <div className="flex items-center space-x-4 text-xs text-stone-500 dark:text-stone-500">
                <span className="flex items-center space-x-1">
                  <Clock className="w-3 h-3" />
                  <span>{session.time}</span>
                </span>
                <span>{session.duration} min</span>
                <span className="flex items-center space-x-1">
                  <Zap className="w-3 h-3" />
                  <span>{session.price}N</span>
                </span>
              </div>
            </div>

            <div className="flex space-x-2">
              <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-medium py-2 px-4 rounded-lg hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
                Inizia
              </button>
              <button className="border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 font-medium py-2 px-4 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors">
                Chat
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};