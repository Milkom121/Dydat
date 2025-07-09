import React, { useState } from 'react';
import { Calendar, Clock, Plus, Edit, Trash2, Users, ChevronLeft, ChevronRight } from 'lucide-react';

export const TutorCalendar: React.FC = () => {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [viewMode, setViewMode] = useState<'week' | 'day'>('week');

  // Mock availability data
  const availability = {
    monday: [{ start: '09:00', end: '12:00' }, { start: '14:00', end: '18:00' }],
    tuesday: [{ start: '09:00', end: '12:00' }, { start: '14:00', end: '18:00' }],
    wednesday: [{ start: '09:00', end: '12:00' }, { start: '14:00', end: '18:00' }],
    thursday: [{ start: '09:00', end: '12:00' }, { start: '14:00', end: '18:00' }],
    friday: [{ start: '09:00', end: '12:00' }, { start: '14:00', end: '16:00' }],
    saturday: [],
    sunday: []
  };

  // Mock sessions data
  const sessions = [
    {
      id: '1',
      studentName: 'Marco Verdi',
      studentAvatar: 'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Matematica',
      topic: 'Calcolo Differenziale',
      date: new Date(2024, 11, 16),
      startTime: '10:00',
      endTime: '11:00',
      duration: 60,
      price: 80,
      status: 'confirmed'
    },
    {
      id: '2',
      studentName: 'Laura Rossi',
      studentAvatar: 'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Fisica',
      topic: 'Meccanica Quantistica',
      date: new Date(2024, 11, 16),
      startTime: '15:00',
      endTime: '16:30',
      duration: 90,
      price: 120,
      status: 'confirmed'
    },
    {
      id: '3',
      studentName: 'Alessandro Blu',
      studentAvatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      subject: 'Matematica',
      topic: 'Algebra Lineare',
      date: new Date(2024, 11, 17),
      startTime: '11:00',
      endTime: '12:00',
      duration: 60,
      price: 80,
      status: 'pending'
    }
  ];

  const getWeekDays = (date: Date) => {
    const week = [];
    const startOfWeek = new Date(date);
    const day = startOfWeek.getDay();
    const diff = startOfWeek.getDate() - day + (day === 0 ? -6 : 1);
    startOfWeek.setDate(diff);

    for (let i = 0; i < 7; i++) {
      const day = new Date(startOfWeek);
      day.setDate(startOfWeek.getDate() + i);
      week.push(day);
    }
    return week;
  };

  const weekDays = getWeekDays(currentDate);
  const dayNames = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
  const hours = Array.from({ length: 12 }, (_, i) => i + 8); // 8:00 to 19:00

  const getSessionsForDate = (date: Date) => {
    return sessions.filter(session => 
      session.date.toDateString() === date.toDateString()
    );
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed':
        return 'bg-emerald-100 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800';
      case 'pending':
        return 'bg-amber-100 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300 border-amber-200 dark:border-amber-800';
      case 'cancelled':
        return 'bg-red-100 dark:bg-red-900/20 text-red-700 dark:text-red-300 border-red-200 dark:border-red-800';
      default:
        return 'bg-stone-100 dark:bg-stone-800 text-stone-700 dark:text-stone-300 border-stone-200 dark:border-stone-700';
    }
  };

  const navigateWeek = (direction: 'prev' | 'next') => {
    const newDate = new Date(currentDate);
    newDate.setDate(currentDate.getDate() + (direction === 'next' ? 7 : -7));
    setCurrentDate(newDate);
  };

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
                <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">Calendario & Disponibilità</span>
              </div>
              
              <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-stone-900 via-emerald-800 to-teal-800 dark:from-stone-100 dark:via-emerald-200 dark:to-teal-200 bg-clip-text text-transparent mb-4 leading-tight">
                Gestisci la Tua Agenda
              </h1>
              <p className="text-xl text-stone-600 dark:text-stone-300 max-w-2xl leading-relaxed">
                Organizza le tue sessioni, imposta la disponibilità e ottimizza il tuo tempo.
              </p>
            </div>

            {/* Quick Actions */}
            <div className="flex space-x-4">
              <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200 flex items-center space-x-2">
                <Plus className="w-5 h-5" />
                <span>Aggiungi Disponibilità</span>
              </button>
              <button className="border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 font-bold py-3 px-6 rounded-xl hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors flex items-center space-x-2">
                <Edit className="w-5 h-5" />
                <span>Modifica Orari</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Calendar Controls */}
        <div className="bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6 mb-8">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            {/* Date Navigation */}
            <div className="flex items-center space-x-4">
              <button
                onClick={() => navigateWeek('prev')}
                className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors"
              >
                <ChevronLeft className="w-5 h-5 text-stone-600 dark:text-stone-400" />
              </button>
              
              <div className="text-center">
                <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
                  {currentDate.toLocaleDateString('it-IT', { month: 'long', year: 'numeric' })}
                </h2>
                <p className="text-sm text-stone-600 dark:text-stone-400">
                  {weekDays[0].toLocaleDateString('it-IT', { day: 'numeric' })} - {weekDays[6].toLocaleDateString('it-IT', { day: 'numeric' })}
                </p>
              </div>
              
              <button
                onClick={() => navigateWeek('next')}
                className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors"
              >
                <ChevronRight className="w-5 h-5 text-stone-600 dark:text-stone-400" />
              </button>
            </div>

            {/* View Mode Toggle */}
            <div className="flex border-2 border-stone-200/50 dark:border-stone-700/50 rounded-xl overflow-hidden bg-white/80 dark:bg-stone-800/80">
              <button
                onClick={() => setViewMode('week')}
                className={`px-4 py-2 transition-all duration-200 ${
                  viewMode === 'week'
                    ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white'
                    : 'text-stone-600 dark:text-stone-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20'
                }`}
              >
                Settimana
              </button>
              <button
                onClick={() => setViewMode('day')}
                className={`px-4 py-2 transition-all duration-200 ${
                  viewMode === 'day'
                    ? 'bg-gradient-to-r from-emerald-400 to-teal-500 text-white'
                    : 'text-stone-600 dark:text-stone-400 hover:bg-emerald-50 dark:hover:bg-emerald-900/20'
                }`}
              >
                Giorno
              </button>
            </div>
          </div>
        </div>

        {/* Calendar Grid */}
        <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 overflow-hidden">
          {/* Week Header */}
          <div className="grid grid-cols-8 border-b border-stone-200/50 dark:border-stone-800/50">
            <div className="p-4 bg-stone-50/50 dark:bg-stone-800/50">
              <Clock className="w-5 h-5 text-stone-500 dark:text-stone-500" />
            </div>
            {weekDays.map((day, index) => (
              <div key={index} className="p-4 text-center bg-stone-50/50 dark:bg-stone-800/50">
                <div className="text-sm font-medium text-stone-600 dark:text-stone-400 mb-1">
                  {dayNames[index]}
                </div>
                <div className={`text-lg font-bold ${
                  day.toDateString() === new Date().toDateString()
                    ? 'text-emerald-600 dark:text-emerald-400'
                    : 'text-stone-900 dark:text-stone-100'
                }`}>
                  {day.getDate()}
                </div>
              </div>
            ))}
          </div>

          {/* Calendar Body */}
          <div className="max-h-96 overflow-y-auto">
            {hours.map((hour) => (
              <div key={hour} className="grid grid-cols-8 border-b border-stone-200/50 dark:border-stone-800/50 min-h-16">
                {/* Hour Label */}
                <div className="p-4 bg-stone-50/50 dark:bg-stone-800/50 flex items-center justify-center">
                  <span className="text-sm font-medium text-stone-600 dark:text-stone-400">
                    {hour.toString().padStart(2, '0')}:00
                  </span>
                </div>

                {/* Day Columns */}
                {weekDays.map((day, dayIndex) => {
                  const daySessions = getSessionsForDate(day).filter(session => {
                    const sessionHour = parseInt(session.startTime.split(':')[0]);
                    return sessionHour === hour;
                  });

                  return (
                    <div key={dayIndex} className="p-2 border-r border-stone-200/50 dark:border-stone-800/50 min-h-16">
                      {daySessions.map((session) => (
                        <div
                          key={session.id}
                          className={`p-2 rounded-lg border text-xs mb-1 ${getStatusColor(session.status)}`}
                        >
                          <div className="font-medium mb-1">{session.studentName}</div>
                          <div className="opacity-75">{session.subject}</div>
                          <div className="opacity-75">{session.startTime}-{session.endTime}</div>
                        </div>
                      ))}
                    </div>
                  );
                })}
              </div>
            ))}
          </div>
        </div>

        {/* Today's Sessions Summary */}
        <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Today's Sessions */}
          <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
            <div className="flex items-center space-x-3 mb-6">
              <div className="p-2 bg-gradient-to-r from-blue-400 to-indigo-500 rounded-lg">
                <Calendar className="w-5 h-5 text-white" />
              </div>
              <div>
                <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100">
                  Sessioni di Oggi
                </h3>
                <p className="text-stone-600 dark:text-stone-400">
                  {new Date().toLocaleDateString('it-IT', { weekday: 'long', day: 'numeric', month: 'long' })}
                </p>
              </div>
            </div>

            <div className="space-y-4">
              {getSessionsForDate(new Date()).map((session) => (
                <div 
                  key={session.id}
                  className="flex items-center space-x-4 p-4 bg-stone-50/50 dark:bg-stone-800/50 rounded-xl"
                >
                  <img 
                    src={session.studentAvatar}
                    alt={session.studentName}
                    className="w-10 h-10 rounded-full object-cover"
                  />
                  
                  <div className="flex-1">
                    <div className="font-medium text-stone-900 dark:text-stone-100">
                      {session.studentName}
                    </div>
                    <div className="text-sm text-stone-600 dark:text-stone-400">
                      {session.subject} • {session.startTime}-{session.endTime}
                    </div>
                  </div>

                  <div className="text-right">
                    <div className="font-bold text-emerald-600 dark:text-emerald-400">
                      {session.price}N
                    </div>
                    <div className={`text-xs font-medium px-2 py-1 rounded-full ${getStatusColor(session.status)}`}>
                      {session.status === 'confirmed' ? 'Confermata' : 'In Attesa'}
                    </div>
                  </div>
                </div>
              ))}

              {getSessionsForDate(new Date()).length === 0 && (
                <div className="text-center py-8">
                  <div className="text-4xl mb-2">📅</div>
                  <p className="text-stone-600 dark:text-stone-400">
                    Nessuna sessione programmata per oggi
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* Availability Settings */}
          <div className="bg-white/90 dark:bg-stone-900/90 backdrop-blur-sm rounded-2xl border border-white/50 dark:border-stone-800/50 p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-gradient-to-r from-purple-400 to-pink-500 rounded-lg">
                  <Clock className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100">
                    Disponibilità Settimanale
                  </h3>
                  <p className="text-stone-600 dark:text-stone-400">
                    I tuoi orari di lavoro
                  </p>
                </div>
              </div>
              <button className="text-purple-600 dark:text-purple-400 hover:text-purple-700 dark:hover:text-purple-300 font-medium">
                Modifica
              </button>
            </div>

            <div className="space-y-3">
              {Object.entries(availability).map(([day, slots]) => (
                <div key={day} className="flex items-center justify-between p-3 bg-stone-50/50 dark:bg-stone-800/50 rounded-lg">
                  <div className="font-medium text-stone-900 dark:text-stone-100 capitalize">
                    {day === 'monday' && 'Lunedì'}
                    {day === 'tuesday' && 'Martedì'}
                    {day === 'wednesday' && 'Mercoledì'}
                    {day === 'thursday' && 'Giovedì'}
                    {day === 'friday' && 'Venerdì'}
                    {day === 'saturday' && 'Sabato'}
                    {day === 'sunday' && 'Domenica'}
                  </div>
                  <div className="text-sm text-stone-600 dark:text-stone-400">
                    {slots.length > 0 
                      ? slots.map(slot => `${slot.start}-${slot.end}`).join(', ')
                      : 'Non disponibile'
                    }
                  </div>
                </div>
              ))}
            </div>

            <button className="w-full mt-6 py-3 px-4 border-2 border-dashed border-purple-300 dark:border-purple-600 text-purple-600 dark:text-purple-400 rounded-xl hover:bg-purple-50 dark:hover:bg-purple-900/10 transition-colors font-medium">
              + Aggiungi Nuovo Orario
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};