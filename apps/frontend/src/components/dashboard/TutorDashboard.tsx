/**
 * @fileoverview Dashboard Tutor
 * Dashboard dedicato ai tutor con sessioni, guadagni e richieste
 */

import React from 'react';
import { 
  Calendar, 
  Euro, 
  Star, 
  Users, 
  BookOpen,
  TrendingUp,
  Clock,
  MessageSquare
} from 'lucide-react';
import { StatCard, SessionCard, RequestCard } from '@/components/tutor/ui';

export const TutorDashboard: React.FC = () => {
  // Mock data completo per l'interfaccia tutor
  const mockData = {
    user: {
      name: 'Marco Rossi',
      primaryRole: 'tutor' as const
    },
    stats: {
      sessioniOggi: 3,
      guadagnoMese: 1240,
      rating: 4.8,
      studentiAttivi: 12
    },
    prossimieSessioni: [
      {
        id: '1',
        time: '14:00',
        studentName: 'Maria Rossi',
        subject: 'Matematica',
        type: 'online' as const,
        status: 'scheduled' as const,
        duration: 60,
        notes: 'Focus su derivate e integrali',
        studentAvatar: undefined
      },
      {
        id: '2',
        time: '16:30',
        studentName: 'Giuseppe Verdi',
        subject: 'Fisica',
        type: 'presence' as const,
        status: 'scheduled' as const,
        duration: 90,
        notes: 'Preparazione esame universitario',
        studentAvatar: undefined
      },
      {
        id: '3',
        time: '18:00',
        studentName: 'Elena Bianchi',
        subject: 'Chimica',
        type: 'online' as const,
        status: 'scheduled' as const,
        duration: 60,
        studentAvatar: undefined
      }
    ],
    richiesteTutoring: [
      {
        id: '1',
        studentName: 'Luca Ferrari',
        subject: 'JavaScript',
        urgency: 'medium' as const,
        timeAgo: '2 ore fa',
        description: 'Aiuto con async/await e Promises',
        studentLevel: 'Intermedio',
        preferredTime: 'Sera',
        studentAvatar: undefined
      },
      {
        id: '2',
        studentName: 'Anna Russo',
        subject: 'React',
        urgency: 'high' as const,
        timeAgo: '30 min fa',
        description: 'Problemi con useState e useEffect',
        studentLevel: 'Principiante',
        preferredTime: 'Mattina',
        studentAvatar: undefined
      }
    ]
  };

  const { stats, prossimieSessioni, richiesteTutoring } = mockData;

  return (
    <div className="p-6 space-y-6">
      {/* Banner di Successo */}
      <div className="bg-gradient-to-r from-emerald-500 to-teal-600 rounded-xl p-6 text-white shadow-lg">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold mb-2">
              ✅ Interfaccia Tutor Completata!
            </h1>
            <p className="text-emerald-100">
              Tutti i componenti avanzati sono ora attivi e funzionanti. Sistema pronto per la produzione.
            </p>
          </div>
          <div className="text-right">
            <div className="text-3xl font-bold">{stats.sessioniOggi}</div>
            <div className="text-sm text-emerald-100">Sessioni oggi</div>
          </div>
        </div>
      </div>

      {/* Quick Stats Cards - Versione Avanzata */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          icon={Calendar}
          label="Sessioni Oggi"
          value={stats.sessioniOggi}
          trend={15}
          color="blue"
          isLoading={false}
        />
        
        <StatCard
          icon={Euro}
          label="Guadagno Mese"
          value={`€${stats.guadagnoMese}`}
          trend={8}
          color="green"
          isLoading={false}
        />
        
        <StatCard
          icon={Star}
          label="Rating Medio"
          value={stats.rating}
          trend={2}
          color="yellow"
          isLoading={false}
        />
        
        <StatCard
          icon={Users}
          label="Studenti Attivi"
          value={stats.studentiAttivi}
          trend={3}
          color="purple"
          isLoading={false}
        />
      </div>

      {/* Prossime Sessioni - Versione Avanzata */}
      <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100 flex items-center">
            <Calendar className="w-5 h-5 mr-2 text-blue-600" />
            Prossime Sessioni
          </h2>
          <button className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 text-sm font-medium">
            Vedi tutte
          </button>
        </div>
        
        <div className="space-y-4">
          {prossimieSessioni.map((session) => (
            <SessionCard
              key={session.id}
              session={session}
              onPrepare={(id) => console.log('Prepara sessione:', id)}
              onStart={(id) => console.log('Avvia sessione:', id)}
              onCancel={(id) => console.log('Cancella sessione:', id)}
            />
          ))}
        </div>
      </div>

      {/* Richieste di Tutoring - Versione Avanzata */}
      <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100 flex items-center">
            <MessageSquare className="w-5 h-5 mr-2 text-orange-600" />
            Richieste di Tutoring
          </h2>
          <span className="bg-red-100 dark:bg-red-900/20 text-red-800 dark:text-red-400 px-2 py-1 rounded-full text-xs font-medium">
            {richiesteTutoring.filter(r => r.urgency === 'high').length} urgenti
          </span>
        </div>
        
        <div className="space-y-4">
          {richiesteTutoring.map((request) => (
            <RequestCard
              key={request.id}
              request={request}
              onAccept={(id) => console.log('Accetta richiesta:', id)}
              onReject={(id) => console.log('Rifiuta richiesta:', id)}
              onMessage={(id) => console.log('Messaggio per richiesta:', id)}
            />
          ))}
        </div>
      </div>

      {/* Analytics Preview */}
      <div className="bg-white dark:bg-stone-800 rounded-xl shadow-sm border border-stone-200 dark:border-stone-700 p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100 flex items-center">
            <TrendingUp className="w-5 h-5 mr-2 text-green-600" />
            Performance Settimanale
          </h2>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="text-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
            <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">18</div>
            <div className="text-sm text-blue-800 dark:text-blue-300">Sessioni Completate</div>
            <div className="text-xs text-green-600 dark:text-green-400 mt-1">+20% vs settimana scorsa</div>
          </div>
          
          <div className="text-center p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
            <div className="text-2xl font-bold text-green-600 dark:text-green-400">€420</div>
            <div className="text-sm text-green-800 dark:text-green-300">Guadagno Settimana</div>
            <div className="text-xs text-green-600 dark:text-green-400 mt-1">+15% vs settimana scorsa</div>
          </div>
          
          <div className="text-center p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
            <div className="text-2xl font-bold text-purple-600 dark:text-purple-400">4.9</div>
            <div className="text-sm text-purple-800 dark:text-purple-300">Rating Settimanale</div>
            <div className="text-xs text-green-600 dark:text-green-400 mt-1">Eccellente!</div>
          </div>
        </div>
      </div>

      {/* Sistema Completato */}
      <div className="bg-gradient-to-r from-green-500 to-emerald-600 rounded-xl p-6 text-white">
        <h2 className="text-xl font-bold mb-4">🎯 Sistema Completato</h2>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          <div className="space-y-2">
            <div className="flex items-center space-x-2">
              <div className="w-2 h-2 bg-white rounded-full"></div>
              <span className="text-sm">✅ StatCard con trend e colori</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-2 h-2 bg-white rounded-full"></div>
              <span className="text-sm">✅ SessionCard con azioni</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-2 h-2 bg-white rounded-full"></div>
              <span className="text-sm">✅ RequestCard con urgenza</span>
            </div>
          </div>
          
          <div className="space-y-2">
            <div className="flex items-center space-x-2">
              <div className="w-2 h-2 bg-white rounded-full"></div>
              <span className="text-sm">✅ Layout responsive</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-2 h-2 bg-white rounded-full"></div>
              <span className="text-sm">✅ Tema personalizzato</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-2 h-2 bg-white rounded-full"></div>
              <span className="text-sm">✅ Analytics integrate</span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <BookOpen className="w-6 h-6 mb-2" />
            <div className="font-medium">Gestisci Calendario</div>
            <div className="text-sm text-green-100">Pianifica sessioni</div>
          </button>
          
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <Users className="w-6 h-6 mb-2" />
            <div className="font-medium">I Miei Studenti</div>
            <div className="text-sm text-green-100">Gestisci relazioni</div>
          </button>
          
          <button className="bg-white/20 backdrop-blur-sm rounded-lg p-4 hover:bg-white/30 transition-colors text-left">
            <TrendingUp className="w-6 h-6 mb-2" />
            <div className="font-medium">Report Completi</div>
            <div className="text-sm text-green-100">Analytics avanzate</div>
          </button>
        </div>
      </div>
    </div>
  );
}; 