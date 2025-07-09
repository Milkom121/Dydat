import React, { useState } from 'react';
import { Calendar, Clock, Video, MessageCircle, Star, MoreHorizontal } from 'lucide-react';

export const MyTutoringSessions: React.FC = () => {
  const [activeTab, setActiveTab] = useState('upcoming');

  const sessions = {
    upcoming: [
      {
        id: 1,
        tutorName: 'Marco Alberti',
        tutorAvatar: 'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
        subject: 'React Avanzato',
        date: '2024-01-15',
        time: '15:00 - 16:00',
        status: 'confermata',
        type: 'video',
        notes: 'Revisione del progetto e correzione hook personalizzati'
      },
      {
        id: 2,
        tutorName: 'Sofia Bianchi',
        tutorAvatar: 'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
        subject: 'Matematica',
        date: '2024-01-16',
        time: '18:30 - 19:30',
        status: 'in_attesa',
        type: 'video',
        notes: 'Preparazione esame di Analisi 2'
      }
    ],
    completed: [
      {
        id: 3,
        tutorName: 'Laura Fontana',
        tutorAvatar: 'https://images.pexels.com/photos/733872/pexels-photo-733872.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
        subject: 'Python Data Science',
        date: '2024-01-10',
        time: '14:00 - 15:30',
        status: 'completata',
        type: 'video',
        rating: 5,
        feedback: 'Ottima spiegazione dei concetti di machine learning!'
      },
      {
        id: 4,
        tutorName: 'Alessandro Verde',
        tutorAvatar: 'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
        subject: 'UI/UX Design',
        date: '2024-01-08',
        time: '16:00 - 17:00',
        status: 'completata',
        type: 'video',
        rating: 4,
        feedback: 'Buone competenze, consiglio per progetti futuri.'
      }
    ]
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confermata':
        return 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300';
      case 'in_attesa':
        return 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300';
      case 'completata':
        return 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300';
      default:
        return 'bg-gray-100 dark:bg-gray-900/30 text-gray-700 dark:text-gray-300';
    }
  };

  const renderStars = (rating: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <Star
        key={i}
        className={`w-4 h-4 ${
          i < rating 
            ? 'text-amber-400 fill-current' 
            : 'text-gray-300 dark:text-gray-600'
        }`}
      />
    ));
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100">
          Le Mie Sessioni
        </h2>
        <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-semibold py-2 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
          Prenota Nuova Sessione
        </button>
      </div>

      {/* Tab Navigation */}
      <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-1">
        <div className="flex space-x-1">
          <button
            onClick={() => setActiveTab('upcoming')}
            className={`flex-1 py-3 px-6 rounded-xl font-medium transition-all duration-200 ${
              activeTab === 'upcoming'
                ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white shadow-md'
                : 'text-stone-600 dark:text-stone-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20'
            }`}
          >
            Prossime ({sessions.upcoming.length})
          </button>
          <button
            onClick={() => setActiveTab('completed')}
            className={`flex-1 py-3 px-6 rounded-xl font-medium transition-all duration-200 ${
              activeTab === 'completed'
                ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white shadow-md'
                : 'text-stone-600 dark:text-stone-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20'
            }`}
          >
            Completate ({sessions.completed.length})
          </button>
        </div>
      </div>

      {/* Sessions List */}
      <div className="space-y-4">
        {sessions[activeTab as keyof typeof sessions].map((session) => (
          <div
            key={session.id}
            className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 shadow-lg hover:shadow-xl transition-all duration-300"
          >
            <div className="flex items-start justify-between">
              <div className="flex items-start space-x-4 flex-1">
                {/* Tutor Avatar */}
                <img
                  src={session.tutorAvatar}
                  alt={session.tutorName}
                  className="w-12 h-12 rounded-xl object-cover border-2 border-white shadow-md"
                />

                {/* Session Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100">
                        {session.subject}
                      </h3>
                      <p className="text-sm text-stone-600 dark:text-stone-400">
                        con {session.tutorName}
                      </p>
                    </div>
                    <span className={`px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(session.status)}`}>
                      {session.status.replace('_', ' ')}
                    </span>
                  </div>

                  {/* Date and Time */}
                  <div className="flex items-center space-x-4 text-sm text-stone-600 dark:text-stone-400 mb-3">
                    <div className="flex items-center space-x-2">
                      <Calendar className="w-4 h-4" />
                      <span>{new Date(session.date).toLocaleDateString('it-IT')}</span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Clock className="w-4 h-4" />
                      <span>{session.time}</span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Video className="w-4 h-4" />
                      <span>Video Call</span>
                    </div>
                  </div>

                  {/* Notes/Feedback */}
                  {'notes' in session && (
                    <p className="text-sm text-stone-600 dark:text-stone-400 bg-stone-50 dark:bg-stone-800/50 p-3 rounded-lg">
                      <strong>Note:</strong> {session.notes}
                    </p>
                  )}

                  {'feedback' in session && (
                    <div className="space-y-2">
                      <div className="flex items-center space-x-2">
                        <span className="text-sm font-medium text-stone-700 dark:text-stone-300">La tua valutazione:</span>
                        <div className="flex items-center space-x-1">
                          {renderStars(session.rating)}
                        </div>
                      </div>
                      <p className="text-sm text-stone-600 dark:text-stone-400 bg-stone-50 dark:bg-stone-800/50 p-3 rounded-lg">
                        {session.feedback}
                      </p>
                    </div>
                  )}
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center space-x-2">
                {activeTab === 'upcoming' && (
                  <>
                    <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white p-2 rounded-lg hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
                      <Video className="w-4 h-4" />
                    </button>
                    <button className="bg-white dark:bg-stone-800 text-stone-600 dark:text-stone-400 p-2 rounded-lg border border-stone-300 dark:border-stone-600 hover:bg-stone-50 dark:hover:bg-stone-700 transition-all duration-200">
                      <MessageCircle className="w-4 h-4" />
                    </button>
                  </>
                )}
                <button className="bg-white dark:bg-stone-800 text-stone-600 dark:text-stone-400 p-2 rounded-lg border border-stone-300 dark:border-stone-600 hover:bg-stone-50 dark:hover:bg-stone-700 transition-all duration-200">
                  <MoreHorizontal className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Empty State */}
      {sessions[activeTab as keyof typeof sessions].length === 0 && (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">📚</div>
          <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-2">
            Nessuna sessione {activeTab === 'upcoming' ? 'in programma' : 'completata'}
          </h3>
          <p className="text-stone-600 dark:text-stone-400 mb-6">
            {activeTab === 'upcoming' 
              ? 'Prenota la tua prima sessione di tutoring!' 
              : 'Le tue sessioni completate appariranno qui.'}
          </p>
          {activeTab === 'upcoming' && (
            <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-semibold py-3 px-8 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
              Trova un Tutor
            </button>
          )}
        </div>
      )}
    </div>
  );
}; 