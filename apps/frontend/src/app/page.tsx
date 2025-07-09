/**
 * @fileoverview Pagina principale dell'applicazione
 * Layout principale con Header, Sidebar e Dashboard integrati
 */

'use client';

import React, { useState } from 'react';
import { Header } from '../components/layout';
import { Sidebar } from '../components/layout/Sidebar';
import { Dashboard } from '../components/dashboard/Dashboard';
import { MyCourses } from '../components/courses/MyCourses';
import { PersonalProfile } from '../components/profile/PersonalProfile';
import { CourseMarketplace } from '../components/marketplace/CourseMarketplace';
import { TutoringMarketplace } from '../components/marketplace/TutoringMarketplace';
import { useTheme } from '../components/theme-provider';

export default function HomePage() {
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [currentPath, setCurrentPath] = useState('/dashboard');
  const { actualTheme } = useTheme();

  const toggleSidebar = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  const handleNavigate = (path: string) => {
    setCurrentPath(path);
  };

  const renderContent = () => {
    switch (currentPath) {
      case '/dashboard':
        return <Dashboard />;
      case '/profile':
        return <PersonalProfile />;
      case '/my-courses':
        return <MyCourses />;
      case '/catalog':
        return <CourseMarketplace />;
      case '/marketplace':
        return <TutoringMarketplace />;
      case '/learning-suite':
      case '/learning-suite/canvas':
      case '/learning-suite/flashcards':
      case '/learning-suite/ai-companion':
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Suite di Apprendimento
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
      case '/create':
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Studio di Creazione
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
      case '/analytics':
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Analytics Corsi
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
      case '/organizations':
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Le Mie Organizzazioni
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
      case '/tutoring':
      case '/tutoring/dashboard':
      case '/tutoring/students':
      case '/tutoring/calendar':
      case '/tutoring/requests':
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Sessioni Tutoraggio
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
      case '/achievements':
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Achievements
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
      case '/settings':
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Impostazioni
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
      default:
        return (
          <div className="p-6">
            <div className="card text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Sezione in Sviluppo
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
        );
    }
  };

  return (
    <div className={`min-h-screen transition-colors duration-200 ${
      actualTheme === 'dark' ? 'dark bg-stone-950' : 'bg-stone-50'
    }`}>
      {/* Header */}
      <Header 
        onToggleSidebar={toggleSidebar}
      />
      
      {/* Layout con Sidebar e Main Content */}
      <div className="flex">
        {/* Sidebar */}
        <Sidebar 
          isCollapsed={isSidebarCollapsed}
          currentPath={currentPath}
          onNavigate={handleNavigate}
        />
        
        {/* Main Content */}
        <main className={`flex-1 transition-all duration-300 ${
          isSidebarCollapsed ? 'ml-16' : 'ml-64'
        } pt-16`}>
          {renderContent()}
        </main>
      </div>
    </div>
  );
} 