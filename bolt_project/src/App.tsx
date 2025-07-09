import React, { useState } from 'react';
import { Header } from './components/layout/Header';
import { Sidebar } from './components/layout/Sidebar';
import { Dashboard } from './components/dashboard/Dashboard';
import { CourseMarketplace } from './components/marketplace/CourseMarketplace';
import { MyCourses } from './components/courses/MyCourses';
import { TutoringMarketplace } from './components/marketplace/TutoringMarketplace';
import { TutorDashboard } from './components/tutoring/TutorDashboard';
import { TutorStudents } from './components/tutoring/TutorStudents';
import { TutorCalendar } from './components/tutoring/TutorCalendar';
import { TutorRequests } from './components/tutoring/TutorRequests';
import { TutorProfile } from './components/tutoring/TutorProfile';
import { useDarkMode } from './hooks/useDarkMode';
import { PersonalProfile } from './components/profile/PersonalProfile';

function App() {
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [currentPath, setCurrentPath] = useState('/dashboard');
  const { isDarkMode, toggleDarkMode } = useDarkMode();

  const toggleSidebar = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  const handleNavigate = (path: string) => {
    setCurrentPath(path);
  };

  return (
    <div className={`min-h-screen bg-stone-50 dark:bg-stone-900 transition-colors duration-300 ${isDarkMode ? 'dark' : ''}`}>
      <Header 
        onToggleSidebar={toggleSidebar}
        isDarkMode={isDarkMode}
        onToggleDarkMode={toggleDarkMode}
      />
      
      <Sidebar 
        isCollapsed={isSidebarCollapsed}
        currentPath={currentPath}
        onNavigate={handleNavigate}
      />
      
      <main className={`pt-16 transition-all duration-300 ${
        isSidebarCollapsed ? 'ml-16' : 'ml-64'
      }`}>
        {currentPath === '/dashboard' && <Dashboard />}
        {currentPath === '/catalog' && <CourseMarketplace />}
        {currentPath === '/my-courses' && <MyCourses />}
        {currentPath === '/marketplace' && <TutoringMarketplace />}
        {currentPath === '/tutor-dashboard' && <TutorDashboard />}
        {currentPath === '/tutor-students' && <TutorStudents />}
        {currentPath === '/tutor-calendar' && <TutorCalendar />}
        {currentPath === '/tutor-requests' && <TutorRequests />}
        {currentPath === '/tutor-profile' && <TutorProfile />}
        {currentPath === '/profile' && <PersonalProfile />}
        {currentPath !== '/dashboard' && currentPath !== '/catalog' && (
          currentPath !== '/my-courses' && currentPath !== '/marketplace' && 
          !currentPath.startsWith('/tutor-') && currentPath !== '/profile' && (
          <div className="p-6">
            <div className="bg-white dark:bg-stone-900 rounded-xl p-8 border border-stone-200 dark:border-stone-800 text-center">
              <h2 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-4">
                Sezione in Sviluppo
              </h2>
              <p className="text-stone-600 dark:text-stone-400">
                Questa sezione sarà presto disponibile. Stiamo lavorando per offrirti un'esperienza straordinaria.
              </p>
            </div>
          </div>
          )
        )}
      </main>
    </div>
  );
}

export default App;