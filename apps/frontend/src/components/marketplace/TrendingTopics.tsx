import React from 'react';
import { TrendingUp, ArrowRight, Hash, Users } from 'lucide-react';

export const TrendingTopics: React.FC = () => {
  const trendingTopics = [
    {
      id: 1,
      name: 'Artificial Intelligence',
      courses: 156,
      students: 45678,
      growth: '+45%',
      color: 'from-purple-400 to-pink-500',
      icon: '🤖',
      description: 'Scopri il futuro dell\'AI'
    },
    {
      id: 2,
      name: 'React & Next.js',
      courses: 89,
      students: 23456,
      growth: '+32%',
      color: 'from-blue-400 to-cyan-500',
      icon: '⚛️',
      description: 'Framework JavaScript moderni'
    },
    {
      id: 3,
      name: 'Digital Marketing',
      courses: 124,
      students: 34567,
      growth: '+28%',
      color: 'from-green-400 to-emerald-500',
      icon: '📊',
      description: 'Strategie marketing 2024'
    },
    {
      id: 4,
      name: 'Python Data Science',
      courses: 78,
      students: 19876,
      growth: '+38%',
      color: 'from-yellow-400 to-orange-500',
      icon: '🐍',
      description: 'Analisi dati con Python'
    },
    {
      id: 5,
      name: 'UI/UX Design',
      courses: 67,
      students: 16543,
      growth: '+25%',
      color: 'from-red-400 to-pink-500',
      icon: '🎨',
      description: 'Design dell\'esperienza utente'
    },
    {
      id: 6,
      name: 'Blockchain & Web3',
      courses: 43,
      students: 12890,
      growth: '+67%',
      color: 'from-indigo-400 to-purple-500',
      icon: '⛓️',
      description: 'Tecnologie decentralizzate'
    }
  ];

  return (
    <div className="mb-16">
      <div className="flex items-center justify-between mb-8">
        <div className="flex items-center space-x-4">
          <div className="w-12 h-12 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-2xl flex items-center justify-center">
            <TrendingUp className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-3xl font-bold text-stone-900 dark:text-stone-100">
              Argomenti di Tendenza
            </h2>
            <p className="text-stone-600 dark:text-stone-400">
              I topic più ricercati e in crescita nella nostra piattaforma
            </p>
          </div>
        </div>
        <button className="text-emerald-600 dark:text-emerald-400 hover:text-emerald-700 dark:hover:text-emerald-300 font-semibold transition-colors flex items-center space-x-2">
          <span>Esplora tutti</span>
          <ArrowRight className="w-4 h-4" />
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {trendingTopics.map((topic) => (
          <div 
            key={topic.id}
            className="group relative overflow-hidden bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 hover:shadow-xl transition-all duration-300 hover:-translate-y-1"
          >
            {/* Background Gradient */}
            <div className={`absolute inset-0 bg-gradient-to-br ${topic.color} opacity-5 group-hover:opacity-10 transition-opacity duration-300`}></div>
            
            {/* Content */}
            <div className="relative p-6 space-y-4">
              {/* Header */}
              <div className="flex items-start justify-between">
                <div className="flex items-center space-x-3">
                  <div className={`w-12 h-12 bg-gradient-to-r ${topic.color} rounded-2xl flex items-center justify-center text-xl shadow-lg`}>
                    {topic.icon}
                  </div>
                  <div>
                    <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100 group-hover:text-emerald-600 dark:group-hover:text-emerald-400 transition-colors">
                      {topic.name}
                    </h3>
                    <p className="text-sm text-stone-600 dark:text-stone-400">
                      {topic.description}
                    </p>
                  </div>
                </div>

                {/* Growth Badge */}
                <div className="bg-gradient-to-r from-emerald-100 to-teal-100 dark:from-emerald-900/30 dark:to-teal-900/30 text-emerald-700 dark:text-emerald-300 px-3 py-1 rounded-full text-sm font-bold border border-emerald-200 dark:border-emerald-800/50">
                  {topic.growth}
                </div>
              </div>

              {/* Stats */}
              <div className="grid grid-cols-2 gap-4">
                <div className="bg-stone-50/80 dark:bg-stone-800/50 rounded-xl p-4 border border-stone-200/50 dark:border-stone-700/50">
                  <div className="flex items-center space-x-2 mb-2">
                    <Hash className="w-4 h-4 text-stone-500 dark:text-stone-400" />
                    <span className="text-xs font-medium text-stone-500 dark:text-stone-400 uppercase tracking-wide">Corsi</span>
                  </div>
                  <div className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                    {topic.courses}
                  </div>
                </div>

                <div className="bg-stone-50/80 dark:bg-stone-800/50 rounded-xl p-4 border border-stone-200/50 dark:border-stone-700/50">
                  <div className="flex items-center space-x-2 mb-2">
                    <Users className="w-4 h-4 text-stone-500 dark:text-stone-400" />
                    <span className="text-xs font-medium text-stone-500 dark:text-stone-400 uppercase tracking-wide">Studenti</span>
                  </div>
                  <div className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                    {topic.students.toLocaleString()}
                  </div>
                </div>
              </div>

              {/* CTA */}
              <div className="pt-2">
                <button className={`w-full bg-gradient-to-r ${topic.color} text-white font-semibold py-3 px-4 rounded-xl hover:shadow-lg transition-all duration-200 transform hover:scale-[1.02] flex items-center justify-center space-x-2`}>
                  <span>Esplora Corsi</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Decorative Elements */}
            <div className="absolute top-0 right-0 w-20 h-20 opacity-10">
              <div className={`w-full h-full bg-gradient-to-br ${topic.color} rounded-full transform translate-x-6 -translate-y-6`}></div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}; 