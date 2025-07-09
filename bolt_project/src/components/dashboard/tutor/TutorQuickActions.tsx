import React from 'react';

export const TutorQuickActions: React.FC = () => {
  return (
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
  );
};