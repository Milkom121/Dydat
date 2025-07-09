import React, { useState } from 'react';
import { Calendar, Clock, User, Star, MessageCircle, Video, CheckCircle, XCircle } from 'lucide-react';

export const MyTutoringSessions: React.FC = () => {
  const [activeTab, setActiveTab] = useState('upcoming');

  const sessions = [
    {
      id: '1',
      tutorName: 'Dr. Elena Rossi',
      tutorAvatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Matematica',
      topic: 'Calcolo Differenziale',
      scheduledAt: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
      duration: 60,
      price: 80,
      status: 'confirmed',
      sessionType: 'Lezione Standard',
      description: 'Approfondimento su limiti e derivate'
    },
    {
      id: '2',
      tutorName: 'Marco Bianchi',
      tutorAvatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Programmazione',
      topic: 'React Hooks',
      scheduledAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // tomorrow
      duration: 90,
      price: 90,
      status: 'pending',
      sessionType: 'Sessione Intensiva',
      description: 'useState, useEffect e custom hooks'
    },
    {
      id: '3',
      tutorName: 'Sofia Verde',
      tutorAvatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Design',
      topic: 'UI/UX Principles',
      scheduledAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // yesterday
      duration: 60,
      price: 90,
      status: 'completed',
      sessionType: 'Design Critique',
      description: 'Revisione portfolio e feedback',
      rating: 5,
      feedback: 'Sessione fantastica! Sofia mi ha aiutato molto a migliorare il mio portfolio.'
    }
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed':
        return 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300';
      case 'pending':
        return 'bg-amber-100 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300';
      case 'completed':
        return 'bg-blue-100 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300';
      case 'cancelled':
        return 'bg-red-100 dark:bg-red-900/20 text-red-700 dark:text-red-300';
      default:
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'confirmed':
        return 'Confermata';
      case 'pending':
        return 'In Attesa';
      case 'completed':
        return 'Completata';
      case 'cancelled':
        return 'Annullata';
      default:
        return status;
    }
  };

  const filteredSessions = sessions.filter(session => {
    if (activeTab === 'upcoming') {
      return session.status === 'confirmed' || session.status === 'pending';
    }
    if (activeTab === 'completed') {
      return session.status === 'completed';
    }
    if (activeTab === 'cancelled') {
      return session.status === 'cancelled';
    }
    return true;
  });

  const tabs = [
    { id: 'upcoming', label: 'Prossime', count: sessions.filter(s => s.status === 'confirmed' || s.status === 'pending').length },
    { id: 'completed', label: 'Completate', count: sessions.filter(s => s.status === 'completed').length },
    { id: 'cancelled', label: 'Annullate', count: sessions.filter(s => s.status === 'cancelled').length }
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          Le Mie Sessioni di Tutoraggio
        </h2>
      </div>

      {/* Tabs */}
      <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-2">
        <div className="flex space-x-2">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center space-x-2 px-4 py-3 rounded-xl font-medium transition-all duration-200 ${
                activeTab === tab.id
                  ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white shadow-lg'
                  : 'text-stone-600 dark:text-stone-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 hover:text-emerald-600 dark:hover:text-emerald-400'
              }`}
            >
              <span>{tab.label}</span>
              <span className={`text-xs px-2 py-1 rounded-full ${
                activeTab === tab.id
                  ? 'bg-white/20 text-white'
                  : 'bg-stone-200 dark:bg-stone-700 text-stone-600 dark:text-stone-400'
              }`}>
                {tab.count}
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Sessions List */}
      <div className="space-y-4">
        {filteredSessions.length === 0 ? (
          <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-12 text-center">
            <div className="text-6xl mb-4">📚</div>
            <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2">
              Nessuna sessione trovata
            </h3>
            <p className="text-stone-600 dark:text-stone-400 mb-6">
              {activeTab === 'upcoming' && 'Non hai sessioni programmate al momento.'}
              {activeTab === 'completed' && 'Non hai ancora completato nessuna sessione.'}
              {activeTab === 'cancelled' && 'Non hai sessioni annullate.'}
            </p>
            {activeTab === 'upcoming' && (
              <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
                Trova un Tutor
              </button>
            )}
          </div>
        ) : (
          filteredSessions.map((session) => (
            <div 
              key={session.id}
              className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 hover:shadow-lg transition-all duration-300"
            >
              <div className="flex items-start space-x-6">
                {/* Tutor Avatar */}
                <img 
                  src={session.tutorAvatar}
                  alt={session.tutorName}
                  className="w-16 h-16 rounded-full object-cover border-2 border-emerald-200 dark:border-emerald-700"
                />

                {/* Session Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between mb-3">
                    <div>
                      <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-1">
                        {session.topic}
                      </h3>
                      <p className="text-stone-600 dark:text-stone-400 mb-2">
                        con {session.tutorName} • {session.subject}
                      </p>
                      <div className="flex items-center space-x-4 text-sm text-stone-500 dark:text-stone-500">
                        <div className="flex items-center space-x-1">
                          <Calendar className="w-4 h-4" />
                          <span>{session.scheduledAt.toLocaleDateString('it-IT')}</span>
                        </div>
                        <div className="flex items-center space-x-1">
                          <Clock className="w-4 h-4" />
                          <span>{session.scheduledAt.toLocaleTimeString('it-IT', { hour: '2-digit', minute: '2-digit' })}</span>
                        </div>
                        <div className="flex items-center space-x-1">
                          <span>{session.duration} min</span>
                        </div>
                      </div>
                    </div>

                    <div className="text-right">
                      <span className={`text-xs font-bold px-3 py-1 rounded-full ${getStatusColor(session.status)}`}>
                        {getStatusLabel(session.status)}
                      </span>
                      <div className="text-lg font-bold text-stone-900 dark:text-stone-100 mt-2">
                        {session.price} N
                      </div>
                    </div>
                  </div>

                  <p className="text-stone-600 dark:text-stone-400 mb-4">
                    {session.description}
                  </p>

                  {/* Completed Session Feedback */}
                  {session.status === 'completed' && session.rating && (
                    <div className="bg-gradient-to-r from-blue-50 to-cyan-50 dark:from-blue-900/10 dark:to-cyan-900/10 border border-blue-200/50 dark:border-blue-800/50 rounded-xl p-4 mb-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <div className="flex items-center space-x-1">
                          {[...Array(5)].map((_, i) => (
                            <Star 
                              key={i}
                              className={`w-4 h-4 ${
                                i < session.rating! 
                                  ? 'fill-current text-amber-400' 
                                  : 'text-stone-300 dark:text-stone-600'
                              }`}
                            />
                          ))}
                        </div>
                        <span className="text-sm font-medium text-blue-700 dark:text-blue-300">
                          La tua valutazione
                        </span>
                      </div>
                      <p className="text-sm text-blue-800 dark:text-blue-200">
                        "{session.feedback}"
                      </p>
                    </div>
                  )}

                  {/* Action Buttons */}
                  <div className="flex items-center space-x-3">
                    {session.status === 'confirmed' && (
                      <>
                        <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-medium py-2 px-4 rounded-lg hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center space-x-2">
                          <Video className="w-4 h-4" />
                          <span>Entra in Sessione</span>
                        </button>
                        <button className="border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 font-medium py-2 px-4 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors flex items-center space-x-2">
                          <MessageCircle className="w-4 h-4" />
                          <span>Messaggio</span>
                        </button>
                      </>
                    )}

                    {session.status === 'pending' && (
                      <>
                        <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-medium py-2 px-4 rounded-lg hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center space-x-2">
                          <CheckCircle className="w-4 h-4" />
                          <span>Conferma</span>
                        </button>
                        <button className="border border-red-300 dark:border-red-600 text-red-600 dark:text-red-400 font-medium py-2 px-4 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/10 transition-colors flex items-center space-x-2">
                          <XCircle className="w-4 h-4" />
                          <span>Annulla</span>
                        </button>
                      </>
                    )}

                    {session.status === 'completed' && (
                      <button className="border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 font-medium py-2 px-4 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors">
                        Prenota di Nuovo
                      </button>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};