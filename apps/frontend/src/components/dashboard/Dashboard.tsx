/**
 * @fileoverview Componente Dashboard principale
 * Dashboard multi-ruolo che si adatta dinamicamente al ruolo selezionato
 */

import React from 'react';
import { useUserRoles } from '@/hooks/useUserRoles';
import { StudentDashboard } from './StudentDashboard';
import { CreatorDashboard } from './CreatorDashboard';
import { TutorDashboard } from './TutorDashboard';

export const Dashboard: React.FC = () => {
  const { currentRole, isLoading } = useUserRoles();

  // Mostra loading se necessario
  if (isLoading) {
    return (
      <div className="p-6 flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-stone-600 dark:text-stone-400">Caricamento dashboard...</p>
        </div>
      </div>
    );
  }

  // Renderizza il dashboard appropriato in base al ruolo
  switch (currentRole) {
    case 'student':
      return <StudentDashboard />;
    
    case 'creator':
      return <CreatorDashboard />;
    
    case 'tutor':
      return <TutorDashboard />;
    
    default:
      // Fallback per ruoli non supportati o guest
      return (
        <div className="p-6">
          <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-xl p-6 text-center">
            <h2 className="text-xl font-bold text-yellow-900 dark:text-yellow-100 mb-2">
              Dashboard Non Disponibile
            </h2>
            <p className="text-yellow-700 dark:text-yellow-300 mb-4">
              Il dashboard per il ruolo "{currentRole}" non è ancora disponibile.
            </p>
            <p className="text-sm text-yellow-600 dark:text-yellow-400">
              Cambia ruolo utilizzando il selettore nell'header per accedere alle funzionalità disponibili.
            </p>
          </div>
        </div>
      );
  }
}; 