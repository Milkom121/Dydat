import React from 'react';
import { Calendar, Users, Clock, Star, TrendingUp, MessageSquare, Zap, Target } from 'lucide-react';
import { useUserRoles } from '../../hooks/useUserRoles';

export const TutorDashboard: React.FC = () => {
  const { user } = useUserRoles();

  const todayStats = {
    sessionsToday: 3,
    hoursToday: 4.5,
    studentsToday: 3,
    earningsToday: 270
  };

  const weekStats = {
    totalSessions: 12,
    totalHours: 18,
    totalStudents: 8,
    totalEarnings: 1080,
    averageRating: 4.9
  };

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
    <div className="min-h-screen bg-gradient-to-br from-stone-50 via-emerald-50/20 to-teal-50/10 dark:from-stone-950 dark:via-stone-900 dark:to-stone-900">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 via-teal-500/5 to-cyan-500/5 dark:from-emerald-400/5 dark:via-teal-400/5 dark:to-cyan-400/5"></div>
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_70%_30%,rgba(16,185,129,0.1),transparent_50%)] dark:bg-[radial-gradient(circle_at_70%_30%,rgba(16,185,129,0.05),transparent_50%)]"></div>
        
        <div className="relative max-w-7xl mx-auto px-6 py-12">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-8">
            <div>
              <div className="inline-flex items-center space-x-2 bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm px-4 py-2 rounded-full border border-emerald-200/50 dark:border-emerald-800/50 mb-4">
                <div className="w-2 h-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full animate-pulse"></div>
                <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">Dashboard Tutor</span>
              </div>
              
              <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-stone-900 via-emerald-800 to-teal-800 dark:from-stone-100 dark:via-emerald-200 dark:to-teal-200 bg-clip-text text-transparent mb-4 leading-tight">
                Benvenuto, {user?.name}
              </h1>
              <p className="text-xl text-stone-600 dark:text-stone-300 max-w-2xl leading-relaxed">
                Gestisci le tue sessioni di tutoraggio e aiuta gli studenti a raggiungere i loro obiettivi.
              </p>
            </div>

            {/* Today's Quick Stats */}
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-emerald-600 dark:text-emerald-400 mb-1">{todayStats.sessionsToday}</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Sessioni Oggi</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-teal-600 dark:text-teal-400 mb-1">{todayStats.earningsToday}N</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Guadagni Oggi</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-8">
            {/* Weekly Performance */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-8">
              <div className="flex items-center space-x-3 mb-6">
                <div className="p-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-lg">
                  <TrendingUp className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
                    Performance Settimanale
                  </h2>
                  <p className="text-stone-600 dark:text-stone-400">
                    I tuoi risultati degli ultimi 7 giorni
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 md:grid-cols-5 gap-6">
                <div className="text-center">
                  <div className="text-3xl font-bold text-emerald-600 dark:text-emerald-400 mb-2">
                    {weekStats.totalSessions}
                  </div>
                  <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
                    Sessioni
                  </div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-teal-600 dark:text-teal-400 mb-2">
                    {weekStats.totalHours}h
                  </div>
                  <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
                    Ore Totali
                  </div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-cyan-600 dark:text-cyan-400 mb-2">
                    {weekStats.totalStudents}
                  </div>
                  <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
                    Studenti
                  </div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-purple-600 dark:text-purple-400 mb-2">
                    {weekStats.totalEarnings}N
                  </div>
                  <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
                    Guadagni
                  </div>
                </div>
                <div className="text-center">
                  <div className="text-3xl font-bold text-amber-600 dark:text-amber-400 mb-2">
                    {weekStats.averageRating}
                  </div>
                  <div className="text-sm font-medium text-stone-600 dark:text-stone-400">
                    Rating Medio
                  </div>
                </div>
              </div>
            </div>

            {/* Upcoming Sessions */}
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
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Quick Actions */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
              <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100 mb-4">
                Azioni Rapide
              </h3>
              <div className="space-y-3">
                <button className="w-full text-left p-3 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/10 dark:to-teal-900/10 rounded-lg border border-emerald-200/50 dark:border-emerald-800/50 hover:from-emerald-100 dark:hover:from-emerald-900/20 transition-colors">
                  <div className="font-medium text-emerald-700 dark:text-emerald-300 text-sm">
                    📅 Gestisci Disponibilità
                  </div>
                  <div className="text-xs text-emerald-600 dark:text-emerald-400">
                    Aggiorna i tuoi orari liberi
                  </div>
                </button>
                <button className="w-full text-left p-3 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/10 dark:to-indigo-900/10 rounded-lg border border-blue-200/50 dark:border-blue-800/50 hover:from-blue-100 dark:hover:from-blue-900/20 transition-colors">
                  <div className="font-medium text-blue-700 dark:text-blue-300 text-sm">
                    👤 Modifica Profilo
                  </div>
                  <div className="text-xs text-blue-600 dark:text-blue-400">
                    Aggiorna bio e specializzazioni
                  </div>
                </button>
                <button className="w-full text-left p-3 bg-gradient-to-r from-purple-50 to-pink-50 dark:from-purple-900/10 dark:to-pink-900/10 rounded-lg border border-purple-200/50 dark:border-purple-800/50 hover:from-purple-100 dark:hover:from-purple-900/20 transition-colors">
                  <div className="font-medium text-purple-700 dark:text-purple-300 text-sm">
                    💰 Gestisci Tariffe
                  </div>
                  <div className="text-xs text-purple-600 dark:text-purple-400">
                    Modifica prezzi e pacchetti
                  </div>
                </button>
              </div>
            </div>

            {/* Recent Requests */}
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

            {/* Goals */}
            <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
              <div className="flex items-center space-x-3 mb-4">
                <div className="p-2 bg-gradient-to-r from-amber-400 to-orange-500 rounded-lg">
                  <Target className="w-4 h-4 text-white" />
                </div>
                <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
                  Obiettivi Mensili
                </h3>
              </div>

              <div className="space-y-4">
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                      Sessioni (15/20)
                    </span>
                    <span className="text-sm text-amber-600 dark:text-amber-400">75%</span>
                  </div>
                  <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                    <div className="bg-gradient-to-r from-amber-400 to-orange-500 h-2 rounded-full" style={{ width: '75%' }}></div>
                  </div>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                      Rating 4.9+ (4.8)
                    </span>
                    <span className="text-sm text-emerald-600 dark:text-emerald-400">95%</span>
                  </div>
                  <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                    <div className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full" style={{ width: '95%' }}></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};