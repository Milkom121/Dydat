/**
 * @fileoverview Dashboard Studente
 * Dashboard dedicato agli studenti con corsi, progressi e attività di apprendimento
 */

import React from 'react';
import { 
  BookOpen, 
  Clock, 
  Trophy, 
  TrendingUp, 
  PlayCircle,
  CheckCircle,
  Calendar,
  Zap,
  Target,
  Brain
} from 'lucide-react';

export const StudentDashboard: React.FC = () => {
  // Mock data per studente
  const studentData = {
    user: {
      name: 'Marco Rossi',
      level: 12,
      xp: 2850
    },
    stats: {
      corsiAttivi: 4,
      oreStudio: 156,
      certificati: 3,
      streak: 12
    },
    corsiInCorso: [
      {
        id: '1',
        title: 'React Avanzato',
        instructor: 'Giuseppe Verdi',
        progress: 75,
        nextLesson: 'Hooks Personalizzati',
        timeLeft: '2h 30m',
        thumbnail: '/placeholder-course.jpg'
      },
      {
        id: '2',
        title: 'TypeScript Masterclass',
        instructor: 'Maria Bianchi',
        progress: 45,
        nextLesson: 'Tipi Generici',
        timeLeft: '1h 45m',
        thumbnail: '/placeholder-course.jpg'
      },
      {
        id: '3',
        title: 'Design System',
        instructor: 'Elena Rossi',
        progress: 20,
        nextLesson: 'Component Library',
        timeLeft: '45m',
        thumbnail: '/placeholder-course.jpg'
      }
    ],
    obiettiviSettimanali: {
      oreStudio: { current: 8, target: 15 },
      lezioniCompletate: { current: 6, target: 10 },
      esercizi: { current: 12, target: 20 }
    },
    prossimeSessioni: [
      {
        id: '1',
        time: '15:00',
        subject: 'Matematica',
        tutor: 'Prof. Alberti',
        type: 'online'
      },
      {
        id: '2',
        time: '17:30',
        subject: 'Fisica',
        tutor: 'Dott. Ferrari',
        type: 'presenza'
      }
    ]
  };

  const { stats, corsiInCorso, obiettiviSettimanali, prossimeSessioni } = studentData;

  return (
    <div className="p-6 space-y-6">
      {/* Header Dashboard Studente */}
      <div className="bg-gradient-to-r from-blue-500 to-purple-600 rounded-xl p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold mb-2">
              🎓 Benvenuto, Studente!
            </h1>
            <p className="text-blue-100">
              Continua il tuo percorso di apprendimento. Hai {stats.corsiAttivi} corsi attivi.
            </p>
          </div>
          <div className="text-center">
            <div className="text-3xl font-bold">{studentData.user.level}</div>
            <div className="text-sm text-blue-100">Livello</div>
          </div>
        </div>
      </div>

      {/* Statistiche Studente */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Corsi Attivi</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">{stats.corsiAttivi}</p>
            </div>
            <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900/20 rounded-xl flex items-center justify-center">
              <BookOpen className="w-6 h-6 text-blue-600 dark:text-blue-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">+2 questo mese</span>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Ore Studio</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">{stats.oreStudio}h</p>
            </div>
            <div className="w-12 h-12 bg-green-100 dark:bg-green-900/20 rounded-xl flex items-center justify-center">
              <Clock className="w-6 h-6 text-green-600 dark:text-green-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">+15h questa settimana</span>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Certificati</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">{stats.certificati}</p>
            </div>
            <div className="w-12 h-12 bg-yellow-100 dark:bg-yellow-900/20 rounded-xl flex items-center justify-center">
              <Trophy className="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">+1 questo mese</span>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-stone-600 dark:text-stone-400">Streak Giorni</p>
              <p className="text-2xl font-bold text-stone-900 dark:text-stone-100">{stats.streak}</p>
            </div>
            <div className="w-12 h-12 bg-orange-100 dark:bg-orange-900/20 rounded-xl flex items-center justify-center">
              <Zap className="w-6 h-6 text-orange-600 dark:text-orange-400" />
            </div>
          </div>
          <div className="mt-4 flex items-center text-sm">
            <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
            <span className="text-green-600 dark:text-green-400">Record personale!</span>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Corsi in Corso */}
        <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
              I Miei Corsi
            </h2>
            <button className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 text-sm font-medium">
              Vedi tutti
            </button>
          </div>
          
          <div className="space-y-4">
            {corsiInCorso.map((corso) => (
              <div key={corso.id} className="border border-stone-200 dark:border-stone-700 rounded-lg p-4 hover:bg-stone-50 dark:hover:bg-stone-700/50 transition-colors">
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h3 className="font-semibold text-stone-900 dark:text-stone-100">{corso.title}</h3>
                    <p className="text-sm text-stone-600 dark:text-stone-400">di {corso.instructor}</p>
                  </div>
                  <div className="text-sm font-medium text-blue-600 dark:text-blue-400">
                    {corso.progress}%
                  </div>
                </div>
                
                <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2 mb-3">
                  <div 
                    className="bg-blue-600 h-2 rounded-full transition-all duration-300" 
                    style={{ width: `${corso.progress}%` }}
                  ></div>
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="text-sm text-stone-600 dark:text-stone-400">
                    <span className="font-medium">Prossima:</span> {corso.nextLesson}
                  </div>
                  <button className="flex items-center space-x-1 bg-blue-600 text-white px-3 py-1 rounded-lg text-sm hover:bg-blue-700 transition-colors">
                    <PlayCircle className="w-4 h-4" />
                    <span>Continua</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Obiettivi Settimanali */}
        <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
              Obiettivi Settimanali
            </h2>
            <Target className="w-5 h-5 text-stone-400" />
          </div>
          
          <div className="space-y-6">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-stone-900 dark:text-stone-100">Ore di Studio</span>
                <span className="text-sm text-stone-600 dark:text-stone-400">
                  {obiettiviSettimanali.oreStudio.current}/{obiettiviSettimanali.oreStudio.target}h
                </span>
              </div>
              <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                <div 
                  className="bg-green-600 h-2 rounded-full transition-all duration-300" 
                  style={{ width: `${(obiettiviSettimanali.oreStudio.current / obiettiviSettimanali.oreStudio.target) * 100}%` }}
                ></div>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-stone-900 dark:text-stone-100">Lezioni Completate</span>
                <span className="text-sm text-stone-600 dark:text-stone-400">
                  {obiettiviSettimanali.lezioniCompletate.current}/{obiettiviSettimanali.lezioniCompletate.target}
                </span>
              </div>
              <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                <div 
                  className="bg-blue-600 h-2 rounded-full transition-all duration-300" 
                  style={{ width: `${(obiettiviSettimanali.lezioniCompletate.current / obiettiviSettimanali.lezioniCompletate.target) * 100}%` }}
                ></div>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-stone-900 dark:text-stone-100">Esercizi Completati</span>
                <span className="text-sm text-stone-600 dark:text-stone-400">
                  {obiettiviSettimanali.esercizi.current}/{obiettiviSettimanali.esercizi.target}
                </span>
              </div>
              <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                <div 
                  className="bg-purple-600 h-2 rounded-full transition-all duration-300" 
                  style={{ width: `${(obiettiviSettimanali.esercizi.current / obiettiviSettimanali.esercizi.target) * 100}%` }}
                ></div>
              </div>
            </div>
          </div>

          <div className="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
            <div className="flex items-center space-x-2">
              <Brain className="w-5 h-5 text-blue-600 dark:text-blue-400" />
              <span className="text-sm font-medium text-blue-900 dark:text-blue-100">
                Ottimo lavoro! Stai raggiungendo i tuoi obiettivi.
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Prossime Sessioni Tutoring */}
      <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
            Prossime Sessioni di Tutoring
          </h2>
          <Calendar className="w-5 h-5 text-stone-400" />
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {prossimeSessioni.map((sessione) => (
            <div key={sessione.id} className="border border-stone-200 dark:border-stone-700 rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-lg font-semibold text-stone-900 dark:text-stone-100">{sessione.time}</span>
                <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                  sessione.type === 'online' 
                    ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                    : 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400'
                }`}>
                  {sessione.type === 'online' ? 'Online' : 'In Presenza'}
                </span>
              </div>
              <h3 className="font-medium text-stone-900 dark:text-stone-100">{sessione.subject}</h3>
              <p className="text-sm text-stone-600 dark:text-stone-400">con {sessione.tutor}</p>
              
              <div className="mt-3 flex space-x-2">
                <button className="flex-1 bg-blue-600 text-white px-3 py-2 rounded-lg text-sm hover:bg-blue-700 transition-colors">
                  Entra nella Sessione
                </button>
                <button className="px-3 py-2 text-stone-600 dark:text-stone-400 hover:text-stone-900 dark:hover:text-stone-100 transition-colors">
                  <Calendar className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
        
        {prossimeSessioni.length === 0 && (
          <div className="text-center py-8">
            <Calendar className="w-12 h-12 text-stone-300 dark:text-stone-600 mx-auto mb-4" />
            <p className="text-stone-600 dark:text-stone-400 mb-4">Nessuna sessione programmata</p>
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
              Prenota Tutoring
            </button>
          </div>
        )}
      </div>

      {/* Quick Actions */}
      <div className="bg-gradient-to-r from-purple-500 to-pink-600 rounded-xl p-6 text-white">
        <h2 className="text-xl font-bold mb-4">🚀 Azioni Rapide</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <BookOpen className="w-6 h-6 mb-2" />
            <div className="font-medium">Esplora Corsi</div>
            <div className="text-sm text-purple-100">Scopri nuovi corsi</div>
          </button>
          
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <Brain className="w-6 h-6 mb-2" />
            <div className="font-medium">AI Companion</div>
            <div className="text-sm text-purple-100">Studia con l'IA</div>
          </button>
          
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <Zap className="w-6 h-6 mb-2" />
            <div className="font-medium">Flashcards</div>
            <div className="text-sm text-purple-100">Ripassa velocemente</div>
          </button>
        </div>
      </div>
    </div>
  );
}; 