import React, { useState } from 'react';
import { Search, Filter, Star, Clock, MessageCircle, Calendar, TrendingUp, User } from 'lucide-react';

export const TutorStudents: React.FC = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [filterBy, setFilterBy] = useState('all');
  const [sortBy, setSortBy] = useState('recent');

  const students = [
    {
      id: '1',
      name: 'Marco Verdi',
      avatar: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subjects: ['Matematica', 'Fisica'],
      totalSessions: 8,
      totalHours: 12,
      averageRating: 5.0,
      lastSession: '2 giorni fa',
      status: 'active',
      progress: 85,
      nextSession: new Date(Date.now() + 24 * 60 * 60 * 1000),
      totalSpent: 640,
      joinedDate: '2024-01-15',
      notes: 'Studente molto motivato, eccelle in calcolo differenziale'
    },
    {
      id: '2',
      name: 'Laura Rossi',
      avatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subjects: ['Fisica', 'Chimica'],
      totalSessions: 12,
      totalHours: 18,
      averageRating: 4.8,
      lastSession: '1 settimana fa',
      status: 'active',
      progress: 70,
      nextSession: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
      totalSpent: 1080,
      joinedDate: '2023-11-20',
      notes: 'Preparazione esame di Fisica II, focus su meccanica quantistica'
    },
    {
      id: '3',
      name: 'Alessandro Blu',
      avatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subjects: ['Matematica'],
      totalSessions: 5,
      totalHours: 7.5,
      averageRating: 4.6,
      lastSession: '3 settimane fa',
      status: 'inactive',
      progress: 45,
      nextSession: null,
      totalSpent: 400,
      joinedDate: '2024-02-10',
      notes: 'Difficoltà con algebra lineare, necessita rinforzo sui concetti base'
    },
    {
      id: '4',
      name: 'Sofia Gialli',
      avatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subjects: ['Fisica', 'Matematica'],
      totalSessions: 15,
      totalHours: 22.5,
      averageRating: 4.9,
      lastSession: '4 giorni fa',
      status: 'active',
      progress: 92,
      nextSession: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
      totalSpent: 1350,
      joinedDate: '2023-09-05',
      notes: 'Studentessa eccellente, quasi pronta per esame finale'
    }
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300';
      case 'inactive':
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300';
      default:
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'active':
        return 'Attivo';
      case 'inactive':
        return 'Inattivo';
      default:
        return status;
    }
  };

  const filteredStudents = students.filter(student => {
    if (searchQuery && !student.name.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !student.subjects.some(subject => subject.toLowerCase().includes(searchQuery.toLowerCase()))) {
      return false;
    }

    if (filterBy === 'active' && student.status !== 'active') return false;
    if (filterBy === 'inactive' && student.status !== 'inactive') return false;

    return true;
  });

  const sortOptions = [
    { value: 'recent', label: 'Ultima Sessione' },
    { value: 'sessions', label: 'Numero Sessioni' },
    { value: 'rating', label: 'Valutazione' },
    { value: 'alphabetical', label: 'Alfabetico' },
    { value: 'joined', label: 'Data Iscrizione' }
  ];

  const filterOptions = [
    { value: 'all', label: 'Tutti gli Studenti' },
    { value: 'active', label: 'Studenti Attivi' },
    { value: 'inactive', label: 'Studenti Inattivi' }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-stone-50 via-emerald-50/20 to-teal-50/10 dark:from-stone-950 dark:via-stone-900 dark:to-stone-900">
      {/* Header */}
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 via-teal-500/5 to-cyan-500/5 dark:from-emerald-400/5 dark:via-teal-400/5 dark:to-cyan-400/5"></div>
        
        <div className="relative max-w-7xl mx-auto px-6 py-12">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-8">
            <div>
              <div className="inline-flex items-center space-x-2 bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm px-4 py-2 rounded-full border border-emerald-200/50 dark:border-emerald-800/50 mb-4">
                <div className="w-2 h-2 bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full animate-pulse"></div>
                <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">I Miei Studenti</span>
              </div>
              
              <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-stone-900 via-emerald-800 to-teal-800 dark:from-stone-100 dark:via-emerald-200 dark:to-teal-200 bg-clip-text text-transparent mb-4 leading-tight">
                Gestisci i Tuoi Studenti
              </h1>
              <p className="text-xl text-stone-600 dark:text-stone-300 max-w-2xl leading-relaxed">
                Monitora i progressi, pianifica sessioni e mantieni un rapporto personalizzato con ogni studente.
              </p>
            </div>

            {/* Quick Stats */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-emerald-600 dark:text-emerald-400 mb-1">{students.length}</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Studenti Totali</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-teal-600 dark:text-teal-400 mb-1">{students.filter(s => s.status === 'active').length}</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Attivi</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-cyan-600 dark:text-cyan-400 mb-1">4.8</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Rating Medio</div>
              </div>
              <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl p-6 border border-white/50 dark:border-stone-800/50 text-center">
                <div className="text-3xl font-bold text-purple-600 dark:text-purple-400 mb-1">60h</div>
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400">Ore Totali</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Filters and Search */}
        <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 mb-8">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            {/* Search Bar */}
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-emerald-500 dark:text-emerald-400" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Cerca studenti..."
                className="w-full pl-12 pr-4 py-3 bg-white/90 dark:bg-stone-800/90 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl text-stone-900 dark:text-stone-100 placeholder-stone-500 dark:placeholder-stone-400 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200"
              />
            </div>

            <div className="flex items-center space-x-4">
              {/* Filter Dropdown */}
              <div className="relative">
                <select
                  value={filterBy}
                  onChange={(e) => setFilterBy(e.target.value)}
                  className="appearance-none px-4 py-3 pr-10 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200 font-medium"
                >
                  {filterOptions.map(option => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
                <div className="absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
                  <svg className="w-4 h-4 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </div>
              </div>

              {/* Sort Dropdown */}
              <div className="relative">
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value)}
                  className="appearance-none px-4 py-3 pr-10 border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl bg-white/90 dark:bg-stone-800/90 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-emerald-400 dark:focus:border-emerald-500 transition-all duration-200 font-medium"
                >
                  {sortOptions.map(option => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
                <div className="absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
                  <svg className="w-4 h-4 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Students Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {filteredStudents.map((student) => (
            <div 
              key={student.id}
              className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 hover:shadow-lg transition-all duration-300"
            >
              {/* Student Header */}
              <div className="flex items-start space-x-4 mb-6">
                <img 
                  src={student.avatar}
                  alt={student.name}
                  className="w-16 h-16 rounded-full object-cover border-2 border-emerald-200 dark:border-emerald-700"
                />
                
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-2">
                    <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100">
                      {student.name}
                    </h3>
                    <span className={`text-xs font-bold px-3 py-1 rounded-full ${getStatusColor(student.status)}`}>
                      {getStatusLabel(student.status)}
                    </span>
                  </div>
                  
                  <div className="flex flex-wrap gap-2 mb-3">
                    {student.subjects.map((subject) => (
                      <span 
                        key={subject}
                        className="text-xs font-medium bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 px-2 py-1 rounded-full"
                      >
                        {subject}
                      </span>
                    ))}
                  </div>

                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <div className="text-stone-500 dark:text-stone-500">Sessioni</div>
                      <div className="font-bold text-stone-900 dark:text-stone-100">{student.totalSessions}</div>
                    </div>
                    <div>
                      <div className="text-stone-500 dark:text-stone-500">Ore Totali</div>
                      <div className="font-bold text-stone-900 dark:text-stone-100">{student.totalHours}h</div>
                    </div>
                    <div>
                      <div className="text-stone-500 dark:text-stone-500">Rating Medio</div>
                      <div className="flex items-center space-x-1">
                        <Star className="w-4 h-4 fill-current text-amber-400" />
                        <span className="font-bold text-stone-900 dark:text-stone-100">{student.averageRating}</span>
                      </div>
                    </div>
                    <div>
                      <div className="text-stone-500 dark:text-stone-500">Speso</div>
                      <div className="font-bold text-stone-900 dark:text-stone-100">{student.totalSpent}N</div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Progress Bar */}
              <div className="mb-4">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium text-stone-700 dark:text-stone-300">
                    Progresso Generale
                  </span>
                  <span className="text-sm text-emerald-600 dark:text-emerald-400 font-bold">
                    {student.progress}%
                  </span>
                </div>
                <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
                  <div 
                    className="bg-gradient-to-r from-emerald-400 to-teal-500 h-2 rounded-full transition-all duration-500"
                    style={{ width: `${student.progress}%` }}
                  ></div>
                </div>
              </div>

              {/* Notes */}
              {student.notes && (
                <div className="mb-4 p-3 bg-stone-50/50 dark:bg-stone-800/50 rounded-lg">
                  <div className="text-xs font-medium text-stone-500 dark:text-stone-500 mb-1">Note:</div>
                  <p className="text-sm text-stone-700 dark:text-stone-300">{student.notes}</p>
                </div>
              )}

              {/* Last Session & Next Session */}
              <div className="grid grid-cols-2 gap-4 mb-4 text-sm">
                <div>
                  <div className="text-stone-500 dark:text-stone-500 mb-1">Ultima Sessione</div>
                  <div className="font-medium text-stone-900 dark:text-stone-100">{student.lastSession}</div>
                </div>
                <div>
                  <div className="text-stone-500 dark:text-stone-500 mb-1">Prossima Sessione</div>
                  <div className="font-medium text-stone-900 dark:text-stone-100">
                    {student.nextSession 
                      ? student.nextSession.toLocaleDateString('it-IT')
                      : 'Non programmata'
                    }
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex space-x-3">
                <button className="flex-1 bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-medium py-2 px-4 rounded-lg hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center justify-center space-x-2">
                  <Calendar className="w-4 h-4" />
                  <span>Prenota</span>
                </button>
                <button className="flex-1 border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 font-medium py-2 px-4 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors flex items-center justify-center space-x-2">
                  <MessageCircle className="w-4 h-4" />
                  <span>Messaggio</span>
                </button>
                <button className="border border-stone-300 dark:border-stone-600 text-stone-600 dark:text-stone-400 font-medium py-2 px-3 rounded-lg hover:bg-stone-50 dark:hover:bg-stone-800/50 transition-colors">
                  <TrendingUp className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Empty State */}
        {filteredStudents.length === 0 && (
          <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-12 text-center">
            <div className="text-6xl mb-4">👥</div>
            <h3 className="text-xl font-semibold text-stone-900 dark:text-stone-100 mb-2">
              Nessuno studente trovato
            </h3>
            <p className="text-stone-600 dark:text-stone-400 mb-6">
              {searchQuery 
                ? `Nessuno studente corrisponde alla ricerca "${searchQuery}"`
                : 'Non hai ancora studenti in questa categoria.'
              }
            </p>
          </div>
        )}
      </div>
    </div>
  );
};