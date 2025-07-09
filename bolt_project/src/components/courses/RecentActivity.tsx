import React from 'react';
import { Activity, Play, Award, BookOpen, Clock } from 'lucide-react';

export const RecentActivity: React.FC = () => {
  const activities = [
    {
      id: 1,
      type: 'lesson_completed',
      title: 'Lezione completata',
      description: 'useContext in profondità',
      course: 'React Avanzato',
      time: '2 ore fa',
      icon: Play,
      color: 'from-emerald-400 to-emerald-600'
    },
    {
      id: 2,
      type: 'certificate_earned',
      title: 'Certificato ottenuto',
      description: 'UI/UX Design con Figma',
      course: 'Design',
      time: '3 giorni fa',
      icon: Award,
      color: 'from-purple-400 to-purple-600'
    },
    {
      id: 3,
      type: 'course_started',
      title: 'Nuovo corso iniziato',
      description: 'Python per Data Science',
      course: 'Data Science',
      time: '1 settimana fa',
      icon: BookOpen,
      color: 'from-blue-400 to-blue-600'
    },
    {
      id: 4,
      type: 'study_session',
      title: 'Sessione di studio',
      description: '2h 30min di apprendimento',
      course: 'Vari corsi',
      time: '1 settimana fa',
      icon: Clock,
      color: 'from-amber-400 to-orange-500'
    }
  ];

  return (
    <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
      <div className="flex items-center space-x-3 mb-6">
        <div className="p-2 bg-gradient-to-r from-indigo-400 to-purple-500 rounded-lg">
          <Activity className="w-5 h-5 text-white" />
        </div>
        <div>
          <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
            Attività Recente
          </h2>
          <p className="text-sm text-stone-600 dark:text-stone-400">
            I tuoi ultimi progressi
          </p>
        </div>
      </div>

      <div className="space-y-4">
        {activities.map((activity) => (
          <div key={activity.id} className="flex items-start space-x-4 p-3 rounded-xl hover:bg-stone-50/50 dark:hover:bg-stone-800/50 transition-colors">
            <div className={`p-2 rounded-lg bg-gradient-to-r ${activity.color} flex-shrink-0`}>
              <activity.icon className="w-4 h-4 text-white" />
            </div>
            
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between mb-1">
                <h3 className="font-medium text-stone-900 dark:text-stone-100 text-sm">
                  {activity.title}
                </h3>
                <span className="text-xs text-stone-500 dark:text-stone-500">
                  {activity.time}
                </span>
              </div>
              
              <p className="text-sm text-stone-600 dark:text-stone-400 mb-1">
                {activity.description}
              </p>
              
              <span className="text-xs text-stone-500 dark:text-stone-500">
                {activity.course}
              </span>
            </div>
          </div>
        ))}
      </div>

      <button className="w-full mt-4 py-3 px-4 text-center text-amber-600 dark:text-amber-400 hover:bg-amber-50 dark:hover:bg-amber-900/10 rounded-xl transition-colors font-medium">
        Vedi tutta l'attività
      </button>
    </div>
  );
};