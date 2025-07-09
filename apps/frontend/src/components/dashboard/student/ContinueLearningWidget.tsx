import React from 'react';
import { Play, Clock, BarChart3 } from 'lucide-react';

export const ContinueLearningWidget: React.FC = () => {
  return (
    <div className="bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-900/10 dark:to-orange-900/10 rounded-xl p-6 border border-amber-200 dark:border-amber-800">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-bold text-stone-900 dark:text-stone-100">
          Continua ad Imparare
        </h2>
        <div className="flex items-center space-x-2 text-amber-600 dark:text-amber-400">
          <BarChart3 className="w-4 h-4" />
          <span className="text-sm font-medium">65% completato</span>
        </div>
      </div>
      
      <div className="flex items-center space-x-4 mb-6">
        <div className="relative">
          <img 
            src="https://images.pexels.com/photos/5212345/pexels-photo-5212345.jpeg?auto=compress&cs=tinysrgb&w=300&h=200&fit=crop"
            alt="Corso React Advanced"
            className="w-20 h-20 rounded-lg object-cover"
          />
          <div className="absolute inset-0 bg-black bg-opacity-40 rounded-lg flex items-center justify-center">
            <Play className="w-6 h-6 text-white" />
          </div>
        </div>
        
        <div className="flex-1">
          <h3 className="font-semibold text-stone-900 dark:text-stone-100 mb-1">
            React Advanced: Hooks e Context API
          </h3>
          <p className="text-sm text-stone-600 dark:text-stone-400 mb-2">
            Lezione 12: useContext in profondità
          </p>
          <div className="flex items-center space-x-4 text-sm text-stone-500 dark:text-stone-500">
            <span className="flex items-center space-x-1">
              <Clock className="w-3 h-3" />
              <span>15 min rimanenti</span>
            </span>
          </div>
        </div>
      </div>
      
      <div className="space-y-3">
        <div className="flex justify-between text-sm">
          <span className="text-stone-600 dark:text-stone-400">Progresso</span>
          <span className="text-amber-600 dark:text-amber-400 font-medium">13/20 lezioni</span>
        </div>
        <div className="w-full bg-stone-200 dark:bg-stone-700 rounded-full h-2">
          <div className="bg-gradient-to-r from-amber-400 to-orange-500 h-2 rounded-full" style={{ width: '65%' }}></div>
        </div>
      </div>
      
      <button className="w-full mt-6 bg-gradient-to-r from-amber-400 to-orange-500 text-white font-medium py-3 px-4 rounded-lg hover:from-amber-500 hover:to-orange-600 transition-all duration-200 transform hover:scale-105">
        Riprendi Lezione
      </button>
    </div>
  );
}; 