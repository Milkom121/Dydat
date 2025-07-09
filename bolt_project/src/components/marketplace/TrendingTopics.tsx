import React from 'react';
import { TrendingUp, ArrowRight } from 'lucide-react';

export const TrendingTopics: React.FC = () => {
  const trendingTopics = [
    {
      name: 'Intelligenza Artificiale',
      courses: 156,
      growth: '+45%',
      color: 'from-purple-400 to-purple-600'
    },
    {
      name: 'React & Next.js',
      courses: 234,
      growth: '+32%',
      color: 'from-blue-400 to-blue-600'
    },
    {
      name: 'UI/UX Design',
      courses: 189,
      growth: '+28%',
      color: 'from-pink-400 to-pink-600'
    },
    {
      name: 'Data Science',
      courses: 167,
      growth: '+38%',
      color: 'from-green-400 to-green-600'
    },
    {
      name: 'Cybersecurity',
      courses: 98,
      growth: '+52%',
      color: 'from-red-400 to-red-600'
    },
    {
      name: 'Cloud Computing',
      courses: 143,
      growth: '+41%',
      color: 'from-indigo-400 to-indigo-600'
    }
  ];

  return (
    <div className="mb-16">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-4">
          <div className="p-3 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-xl shadow-lg">
            <TrendingUp className="w-5 h-5 text-white" />
          </div>
          <div>
            <h2 className="text-3xl font-bold text-stone-900 dark:text-stone-100">
              Argomenti di Tendenza
            </h2>
            <p className="text-lg text-stone-600 dark:text-stone-400">
              Le competenze più richieste del momento
            </p>
          </div>
        </div>
        
        <button className="flex items-center space-x-2 text-amber-600 dark:text-amber-400 hover:text-amber-700 dark:hover:text-amber-300 transition-colors font-medium px-4 py-2 rounded-lg hover:bg-amber-50 dark:hover:bg-amber-900/20">
          <span className="font-semibold">Vedi tutti</span>
          <ArrowRight className="w-4 h-4" />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {trendingTopics.map((topic, index) => (
          <div 
            key={index}
            className="group bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border-2 border-white/50 dark:border-stone-800/50 p-8 hover:shadow-xl transition-all duration-500 hover:scale-105 cursor-pointer hover:border-emerald-300/50 dark:hover:border-emerald-600/50"
          >
            <div className="flex items-center justify-between mb-6">
              <div className={`w-16 h-16 bg-gradient-to-r ${topic.color} rounded-2xl flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300`}>
                <TrendingUp className="w-6 h-6 text-white" />
              </div>
              <div className="text-right">
                <div className="text-lg font-bold text-emerald-600 dark:text-emerald-400">
                  {topic.growth}
                </div>
                <div className="text-sm text-stone-500 dark:text-stone-500 font-medium">
                  crescita
                </div>
              </div>
            </div>
            
            <h3 className="font-bold text-xl text-stone-900 dark:text-stone-100 mb-3 group-hover:text-emerald-600 dark:group-hover:text-emerald-400 transition-colors">
              {topic.name}
            </h3>
            
            <p className="text-stone-600 dark:text-stone-400 font-medium">
              {topic.courses} corsi disponibili
            </p>
          </div>
        ))}
      </div>
    </div>
  );
};