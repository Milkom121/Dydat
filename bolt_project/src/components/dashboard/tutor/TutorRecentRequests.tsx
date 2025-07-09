import React from 'react';

export const TutorRecentRequests: React.FC = () => {
  const recentRequests = [
    {
      id: '1',
      studentName: 'Alessandro Blu',
      subject: 'Matematica',
      topic: 'Algebra Lineare',
      urgency: 'high',
      budget: 100,
      timeAgo: '2 ore fa'
    },
    {
      id: '2',
      studentName: 'Sofia Gialli',
      subject: 'Fisica',
      topic: 'Termodinamica',
      urgency: 'medium',
      budget: 80,
      timeAgo: '4 ore fa'
    }
  ];

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
          Richieste Recenti
        </h3>
        <span className="bg-red-100 dark:bg-red-900/20 text-red-700 dark:text-red-300 text-xs font-bold px-2 py-1 rounded-full">
          {recentRequests.length}
        </span>
      </div>

      <div className="space-y-3">
        {recentRequests.map((request) => (
          <div 
            key={request.id}
            className="p-3 bg-stone-50/50 dark:bg-stone-800/50 rounded-lg hover:bg-stone-100/50 dark:hover:bg-stone-700/50 transition-colors cursor-pointer"
          >
            <div className="flex items-center justify-between mb-2">
              <h4 className="font-medium text-stone-900 dark:text-stone-100 text-sm">
                {request.studentName}
              </h4>
              <span className={`text-xs font-bold px-2 py-1 rounded-full ${
                request.urgency === 'high' 
                  ? 'bg-red-100 dark:bg-red-900/20 text-red-700 dark:text-red-300'
                  : 'bg-amber-100 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300'
              }`}>
                {request.urgency === 'high' ? 'URGENTE' : 'NORMALE'}
              </span>
            </div>
            <p className="text-xs text-stone-600 dark:text-stone-400 mb-2">
              {request.subject} • {request.topic}
            </p>
            <div className="flex items-center justify-between text-xs text-stone-500 dark:text-stone-500">
              <span>Budget: {request.budget}N</span>
              <span>{request.timeAgo}</span>
            </div>
          </div>
        ))}
      </div>

      <button className="w-full mt-4 py-2 px-4 text-center text-emerald-600 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/10 rounded-lg transition-colors font-medium text-sm">
        Vedi Tutte le Richieste
      </button>
    </div>
  );
};