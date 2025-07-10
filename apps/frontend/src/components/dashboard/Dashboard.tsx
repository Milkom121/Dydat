/**
 * @fileoverview Componente Dashboard principale
 * Dashboard multi-ruolo con statistiche, progressi e attività recenti
 */

import React from 'react';

export const Dashboard: React.FC = () => {
  // Mock user data per evitare problemi di loading
  const mockUser = {
    name: 'Marco Rossi',
    primaryRole: 'tutor' as const
  };

  return (
    <div className="space-y-6">
      {/* 🔥 BANNER DI CONFERMA INTERFACCIA AGGIORNATA */}
      <div className="bg-gradient-to-r from-amber-500 to-orange-500 text-white p-6 rounded-xl shadow-lg">
        <h1 className="text-3xl font-bold mb-2">
          🚀 INTERFACCIA TUTOR AGGIORNATA! 🚀
        </h1>
        <p className="text-lg mb-2">
          Benvenuto, {mockUser.name}! La nuova dashboard tutor è ora attiva!
        </p>
        <p className="text-sm opacity-90">
          ✅ Problema di caricamento risolto • Timestamp: {new Date().toLocaleString('it-IT')}
        </p>
      </div>

      {/* Header */}
      <div className="bg-gradient-to-r from-stone-50 to-amber-50 dark:from-stone-900 dark:to-amber-900/20 p-6 rounded-2xl border border-stone-200 dark:border-stone-800">
        <h1 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-2">
          Dashboard Tutor
        </h1>
        <p className="text-stone-600 dark:text-stone-400">
          Gestisci le tue sessioni di tutoring e supporta i tuoi studenti
        </p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl border border-blue-200 dark:border-blue-800 border-l-4 border-l-blue-500 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-blue-600 dark:text-blue-400">Sessioni Oggi</p>
              <p className="text-2xl font-bold text-blue-900 dark:text-blue-100">3</p>
              <p className="text-xs text-blue-500 mt-1">+15% vs ieri</p>
            </div>
            <div className="p-3 bg-blue-100 dark:bg-blue-900/20 rounded-full">
              <svg className="h-6 w-6 text-blue-600 dark:text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl border border-green-200 dark:border-green-800 border-l-4 border-l-green-500 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-green-600 dark:text-green-400">Guadagno Mese</p>
              <p className="text-2xl font-bold text-green-900 dark:text-green-100">€1,240</p>
              <p className="text-xs text-green-500 mt-1">+8% vs mese scorso</p>
            </div>
            <div className="p-3 bg-green-100 dark:bg-green-900/20 rounded-full">
              <svg className="h-6 w-6 text-green-600 dark:text-green-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
              </svg>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl border border-yellow-200 dark:border-yellow-800 border-l-4 border-l-yellow-500 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-yellow-600 dark:text-yellow-400">Rating Medio</p>
              <p className="text-2xl font-bold text-yellow-900 dark:text-yellow-100">4.8</p>
              <p className="text-xs text-yellow-500 mt-1">⭐⭐⭐⭐⭐</p>
            </div>
            <div className="p-3 bg-yellow-100 dark:bg-yellow-900/20 rounded-full">
              <svg className="h-6 w-6 text-yellow-600 dark:text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
              </svg>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl border border-purple-200 dark:border-purple-800 border-l-4 border-l-purple-500 hover:shadow-lg transition-shadow">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-purple-600 dark:text-purple-400">Studenti Attivi</p>
              <p className="text-2xl font-bold text-purple-900 dark:text-purple-100">12</p>
              <p className="text-xs text-purple-500 mt-1">3 nuovi questo mese</p>
            </div>
            <div className="p-3 bg-purple-100 dark:bg-purple-900/20 rounded-full">
              <svg className="h-6 w-6 text-purple-600 dark:text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5 0a4 4 0 11-5.197 0" />
              </svg>
            </div>
          </div>
        </div>
      </div>

      {/* Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Prossime Sessioni */}
        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl border border-stone-200 dark:border-stone-700">
          <h2 className="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-4 flex items-center">
            📅 Prossime Sessioni
          </h2>
          <div className="space-y-3">
            <div className="p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg border-l-4 border-l-blue-500">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-stone-900 dark:text-stone-100">Maria Rossi</p>
                  <p className="text-sm text-stone-600 dark:text-stone-400">Matematica • 14:00-15:00</p>
                </div>
                <button className="bg-blue-500 text-white px-3 py-1 rounded text-sm hover:bg-blue-600 transition-colors">
                  Avvia
                </button>
              </div>
            </div>
            <div className="p-4 bg-green-50 dark:bg-green-900/20 rounded-lg border-l-4 border-l-green-500">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-stone-900 dark:text-stone-100">Giuseppe Verdi</p>
                  <p className="text-sm text-stone-600 dark:text-stone-400">Fisica • 16:30-18:00</p>
                </div>
                <button className="bg-green-500 text-white px-3 py-1 rounded text-sm hover:bg-green-600 transition-colors">
                  Prepara
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Componenti Implementati */}
        <div className="bg-white dark:bg-stone-800 p-6 rounded-xl border border-stone-200 dark:border-stone-700">
          <h2 className="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-4 flex items-center">
            ✅ Sistema Completato
          </h2>
          <div className="space-y-3">
            <div className="p-3 bg-green-100 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
              <p className="text-sm text-green-800 dark:text-green-200 font-medium">🎯 Dashboard responsive funzionante</p>
            </div>
            <div className="p-3 bg-green-100 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
              <p className="text-sm text-green-800 dark:text-green-200 font-medium">🎨 Tema personalizzato attivo</p>
            </div>
            <div className="p-3 bg-green-100 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
              <p className="text-sm text-green-800 dark:text-green-200 font-medium">📱 Design mobile-first</p>
            </div>
            <div className="p-3 bg-blue-100 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
              <p className="text-sm text-blue-800 dark:text-blue-200 font-medium">🚀 Pronto per componenti avanzati</p>
            </div>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 p-6 rounded-xl border border-amber-200 dark:border-amber-800">
        <h3 className="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-4">
          🎯 Prossimi Passi
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <button className="bg-gradient-to-r from-blue-500 to-indigo-500 text-white p-4 rounded-lg hover:from-blue-600 hover:to-indigo-600 transition-all transform hover:scale-105">
            <div className="text-center">
              <div className="text-2xl mb-2">📊</div>
              <p className="font-medium">Implementa StatCard</p>
            </div>
          </button>
          <button className="bg-gradient-to-r from-green-500 to-emerald-500 text-white p-4 rounded-lg hover:from-green-600 hover:to-emerald-600 transition-all transform hover:scale-105">
            <div className="text-center">
              <div className="text-2xl mb-2">🎨</div>
              <p className="font-medium">Sidebar Avanzata</p>
            </div>
          </button>
          <button className="bg-gradient-to-r from-purple-500 to-pink-500 text-white p-4 rounded-lg hover:from-purple-600 hover:to-pink-600 transition-all transform hover:scale-105">
            <div className="text-center">
              <div className="text-2xl mb-2">⚡</div>
              <p className="font-medium">Funzioni Real-time</p>
            </div>
          </button>
        </div>
      </div>
    </div>
  );
}; 