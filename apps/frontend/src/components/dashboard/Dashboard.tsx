/**
 * @fileoverview Componente Dashboard principale
 * Dashboard multi-ruolo con statistiche, progressi e attività recenti
 */

import React, { useEffect, useMemo } from 'react';
import { useUserRoles } from '../../hooks/useUserRoles';
import { getRoleDisplayName } from '../../types/auth';
import { UserRole } from '../../types/auth';

// Student Dashboard Components
import { ContinueLearningWidget } from './student/ContinueLearningWidget';
import { StatsWidget } from './student/StatsWidget';
import { ChallengesWidget } from './student/ChallengesWidget';
import { StudyScheduleWidget } from './student/StudyScheduleWidget';
import { RecommendedCoursesWidget } from './student/RecommendedCoursesWidget';

export const Dashboard: React.FC = () => {
  const { user, currentRole, hasPermission, isLoading } = useUserRoles();

  // Debug logs to track role changes
  useEffect(() => {
    console.log('Dashboard re-rendered with role:', currentRole, 'User:', user?.name);
  }, [currentRole]);

  // Render Student Dashboard
  const renderStudentDashboard = () => (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-2 space-y-6">
        <ContinueLearningWidget />
        <ChallengesWidget />
        <StudyScheduleWidget />
        
        {hasPermission('canCreateCourses') && (
          <div className="bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/10 dark:to-pink-900/10 rounded-xl p-6 border border-purple-200 dark:border-purple-800">
            <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-4">
              Studio di Creazione
            </h3>
            <p className="text-stone-600 dark:text-stone-400 mb-4">
              Gestisci i tuoi corsi e monitora le performance
            </p>
            <button className="bg-gradient-to-r from-purple-400 to-pink-500 text-white font-medium py-3 px-6 rounded-lg hover:from-purple-500 hover:to-pink-600 transition-all duration-200">
              Vai allo Studio
            </button>
          </div>
        )}
        
        {hasPermission('canManageOrganization') && (
          <div className="bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-900/10 dark:to-teal-900/10 rounded-xl p-6 border border-emerald-200 dark:border-emerald-800">
            <h3 className="text-xl font-bold text-stone-900 dark:text-stone-100 mb-4">
              Gestione Organizzazione
            </h3>
            <p className="text-stone-600 dark:text-stone-400 mb-4">
              Monitora il progresso del team e gestisci i percorsi formativi
            </p>
            <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-medium py-3 px-6 rounded-lg hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
              Dashboard Organizzazione
            </button>
          </div>
        )}
      </div>

      <div className="space-y-6">
        <StatsWidget />
        <RecommendedCoursesWidget />
      </div>
    </div>
  );

  // Render Tutor Dashboard
  const renderTutorDashboard = () => (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-2 space-y-6">
        <div className="bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-900/10 dark:to-teal-900/10 rounded-xl p-8 border border-emerald-200 dark:border-emerald-800">
          <h3 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
            Dashboard Tutoring
          </h3>
          <p className="text-stone-600 dark:text-stone-400 mb-6">
            Gestisci le tue sessioni di tutoring e supporta i tuoi studenti nel loro percorso di apprendimento.
          </p>
          <div className="grid grid-cols-2 gap-4">
            <button className="bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-bold py-3 px-6 rounded-xl hover:from-emerald-500 hover:to-teal-600 transition-all duration-200">
              Nuova Sessione
            </button>
            <button className="border border-emerald-300 dark:border-emerald-600 text-emerald-600 dark:text-emerald-400 font-bold py-3 px-6 rounded-xl hover:bg-emerald-50 dark:hover:bg-emerald-900/10 transition-colors">
              I Miei Studenti
            </button>
          </div>
        </div>
      </div>
      
      <div className="space-y-6">
        <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
          <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100 mb-4">
            Statistiche Tutor
          </h3>
          <div className="space-y-4">
            <div className="flex justify-between">
              <span className="text-stone-600 dark:text-stone-400">Sessioni Totali</span>
              <span className="font-bold text-stone-900 dark:text-stone-100">143</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-600 dark:text-stone-400">Studenti Attivi</span>
              <span className="font-bold text-stone-900 dark:text-stone-100">67</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-600 dark:text-stone-400">Rating Medio</span>
              <span className="font-bold text-stone-900 dark:text-stone-100">4.9</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  // Render Creator Dashboard
  const renderCreatorDashboard = () => (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div className="lg:col-span-2 space-y-6">
        <div className="bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/10 dark:to-pink-900/10 rounded-xl p-8 border border-purple-200 dark:border-purple-800">
          <h3 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
            Studio di Creazione
          </h3>
          <p className="text-stone-600 dark:text-stone-400 mb-6">
            Benvenuto nel tuo studio di creazione! Qui puoi gestire i tuoi corsi, monitorare le performance e creare nuovi contenuti.
          </p>
          <div className="grid grid-cols-2 gap-4">
            <button className="bg-gradient-to-r from-purple-400 to-pink-500 text-white font-bold py-3 px-6 rounded-xl hover:from-purple-500 hover:to-pink-600 transition-all duration-200">
              Crea Nuovo Corso
            </button>
            <button className="border border-purple-300 dark:border-purple-600 text-purple-600 dark:text-purple-400 font-bold py-3 px-6 rounded-xl hover:bg-purple-50 dark:hover:bg-purple-900/10 transition-colors">
              Gestisci Corsi
            </button>
          </div>
        </div>
      </div>
      
      <div className="space-y-6">
        <div className="bg-white dark:bg-stone-900 rounded-xl p-6 border border-stone-200 dark:border-stone-800">
          <h3 className="text-lg font-bold text-stone-900 dark:text-stone-100 mb-4">
            Statistiche Creator
          </h3>
          <div className="space-y-4">
            <div className="flex justify-between">
              <span className="text-stone-600 dark:text-stone-400">Corsi Pubblicati</span>
              <span className="font-bold text-stone-900 dark:text-stone-100">3</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-600 dark:text-stone-400">Studenti Totali</span>
              <span className="font-bold text-stone-900 dark:text-stone-100">1,247</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-600 dark:text-stone-400">Rating Medio</span>
              <span className="font-bold text-stone-900 dark:text-stone-100">4.8</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  // Memoize dashboard content to ensure it updates when role changes
  const dashboardContent = useMemo(() => {
    console.log('Generating dashboard content for role:', currentRole);
    
    switch (currentRole) {
      case 'tutor':
        return renderTutorDashboard();
      case 'creator':
        return renderCreatorDashboard();
      case 'student':
      case 'member':
      default:
        return renderStudentDashboard();
    }
  }, [currentRole, hasPermission]);

  // Show loading state if user is not loaded yet
  if (isLoading || !user) {
    return (
      <div className="p-6 flex items-center justify-center">
        <div className="text-stone-600 dark:text-stone-400">Caricamento...</div>
      </div>
    );
  }

  const getRoleDescription = () => {
    switch (currentRole) {
      case 'student':
        return 'Continua il tuo percorso di apprendimento e raggiungi i tuoi obiettivi';
      case 'creator':
        return 'Gestisci i tuoi corsi e monitora le performance';
      case 'tutor':
        return 'Offri il tuo supporto e guida altri studenti';
      case 'manager':
        return 'Supervisiona il progresso del tuo team';
      case 'admin':
        return 'Gestisci la tua organizzazione e i percorsi formativi';
      default:
        return 'Benvenuto nella piattaforma Dydat';
    }
  };

  return (
    <div className="p-6 space-y-6">
      {/* Welcome Section */}
      <div className="mb-8">
        <div className="flex items-center space-x-4 mb-4">
          <h1 className="text-3xl font-bold text-stone-900 dark:text-stone-100">
            Benvenuto, {user?.name || 'Utente'}
          </h1>
          <div className="bg-gradient-to-r from-amber-100 to-orange-100 dark:from-amber-900/20 dark:to-orange-900/20 px-4 py-2 rounded-full border border-amber-200/50 dark:border-amber-800/50">
            <span className="text-sm font-medium text-amber-700 dark:text-amber-300">
              {getRoleDisplayName(currentRole)}
            </span>
          </div>
        </div>
        <p className="text-lg text-stone-600 dark:text-stone-400">
          {getRoleDescription()}
        </p>
      </div>

      {/* Main Grid */}
      {dashboardContent}
    </div>
  );
}; 