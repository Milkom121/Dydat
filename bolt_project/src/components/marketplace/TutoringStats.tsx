import React from 'react';
import { TrendingUp, Clock, Star, Zap, Calendar, Target } from 'lucide-react';

export const TutoringStats: React.FC = () => {
  const stats = [
    {
      icon: Clock,
      label: 'Ore di Tutoraggio',
      value: '24h',
      subtitle: 'Questo mese',
      color: 'from-blue-400 to-blue-600',
      change: '+8h'
    },
    {
      icon: Star,
      label: 'Rating Medio',
      value: '4.8',
      subtitle: 'Dalle tue sessioni',
      color: 'from-amber-400 to-orange-500',
      change: '+0.2'
    },
    {
      icon: Zap,
      label: 'Neuroni Spesi',
      value: '1,240 N',
      subtitle: 'Totale investito',
      color: 'from-purple-400 to-purple-600',
      change: '+320 N'
    },
    {
      icon: Target,
      label: 'Obiettivi Raggiunti',
      value: '8/10',
      subtitle: 'Questo trimestre',
      color: 'from-emerald-400 to-emerald-600',
      change: '+2'
    }
  ];

  const recentAchievements = [
    {
      title: 'Prima Sessione Completata',
      description: 'Hai completato la tua prima sessione di tutoraggio!',
      icon: '🎓',
      date: '2 giorni fa'
    },
    {
      title: 'Studente Costante',
      description: '5 sessioni completate questo mese',
      icon: '📚',
      date: '1 settimana fa'
    },
    {
      title: 'Feedback Eccellente',
      description: 'Hai ricevuto una valutazione 5 stelle',
      icon: '⭐',
      date: '2 settimane fa'
    }
  ];

  return (
    <div className="space-y-6">
      {/* Stats Overview */}
      <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
        <div className="flex items-center space-x-3 mb-6">
          <div className="p-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-lg">
            <TrendingUp className="w-5 h-5 text-white" />
          </div>
          <div>
            <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
              Le Tue Statistiche
            </h2>
            <p className="text-sm text-stone-600 dark:text-stone-400">
              Progresso nel tutoraggio
            </p>
          </div>
        </div>

        <div className="space-y-4">
          {stats.map((stat, index) => (
            <div key={index} className="p-4 bg-stone-50/50 dark:bg-stone-800/50 rounded-xl">
              <div className="flex items-center space-x-3 mb-3">
                <div className={`p-2 rounded-lg bg-gradient-to-r ${stat.color}`}>
                  <stat.icon className="w-4 h-4 text-white" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                      {stat.label}
                    </span>
                    <span className="text-xs text-emerald-600 dark:text-emerald-400 font-medium">
                      {stat.change}
                    </span>
                  </div>
                  <div className="text-lg font-bold text-stone-900 dark:text-stone-100">
                    {stat.value}
                  </div>
                  <div className="text-xs text-stone-500 dark:text-stone-500">
                    {stat.subtitle}
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Learning Goals */}
      <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
        <div className="flex items-center space-x-3 mb-6">
          <div className="p-2 bg-gradient-to-r from-purple-400 to-pink-500 rounded-lg">
            <Target className="w-5 h-5 text-white" />
          </div>
          <div>
            <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
              Obiettivi di Apprendimento
            </h3>
            <p className="text-sm text-stone-600 dark:text-stone-400">
              I tuoi prossimi traguardi
            </p>
          </div>
        </div>

        <div className="space-y-4">
          <div className="p-4 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/10 dark:to-teal-900/10 rounded-xl border border-emerald-200/50 dark:border-emerald-800/50">
            <div className="flex items-center justify-between mb-2">
              <span className="font-medium text-emerald-700 dark:text-emerald-300">
                Completare 10 sessioni
              </span>
              <span className="text-sm text-emerald-600 dark:text-emerald-400">
                8/10
              </span>
            </div>
            <div className="w-full bg-emerald-200 dark:bg-emerald-800 rounded-full h-2">
              <div className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full" style={{ width: '80%' }}></div>
            </div>
          </div>

          <div className="p-4 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-xl border border-amber-200/50 dark:border-amber-800/50">
            <div className="flex items-center justify-between mb-2">
              <span className="font-medium text-amber-700 dark:text-amber-300">
                Raggiungere rating 4.9
              </span>
              <span className="text-sm text-amber-600 dark:text-amber-400">
                4.8/4.9
              </span>
            </div>
            <div className="w-full bg-amber-200 dark:bg-amber-800 rounded-full h-2">
              <div className="bg-gradient-to-r from-amber-400 to-orange-500 h-2 rounded-full" style={{ width: '95%' }}></div>
            </div>
          </div>
        </div>
      </div>

      {/* Recent Achievements */}
      <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
        <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100 mb-4">
          Risultati Recenti
        </h3>

        <div className="space-y-3">
          {recentAchievements.map((achievement, index) => (
            <div key={index} className="flex items-start space-x-3 p-3 rounded-lg hover:bg-stone-50/50 dark:hover:bg-stone-800/50 transition-colors">
              <div className="text-2xl">{achievement.icon}</div>
              <div className="flex-1 min-w-0">
                <h4 className="font-medium text-stone-900 dark:text-stone-100 text-sm">
                  {achievement.title}
                </h4>
                <p className="text-xs text-stone-600 dark:text-stone-400 mb-1">
                  {achievement.description}
                </p>
                <span className="text-xs text-stone-500 dark:text-stone-500">
                  {achievement.date}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/10 dark:to-teal-900/10 rounded-2xl border border-emerald-200/50 dark:border-emerald-800/50 p-6">
        <h3 className="text-lg font-bold text-emerald-700 dark:text-emerald-300 mb-4">
          Azioni Rapide
        </h3>
        <div className="space-y-3">
          <button className="w-full text-left p-3 bg-white/80 dark:bg-stone-800/80 rounded-lg hover:bg-white dark:hover:bg-stone-800 transition-colors">
            <div className="font-medium text-stone-900 dark:text-stone-100 text-sm">
              📅 Prenota una nuova sessione
            </div>
            <div className="text-xs text-stone-600 dark:text-stone-400">
              Trova un tutor per il tuo prossimo argomento
            </div>
          </button>
          <button className="w-full text-left p-3 bg-white/80 dark:bg-stone-800/80 rounded-lg hover:bg-white dark:hover:bg-stone-800 transition-colors">
            <div className="font-medium text-stone-900 dark:text-stone-100 text-sm">
              ⚡ Richiesta rapida
            </div>
            <div className="text-xs text-stone-600 dark:text-stone-400">
              Ricevi proposte personalizzate dai tutor
            </div>
          </button>
        </div>
      </div>
    </div>
  );
};