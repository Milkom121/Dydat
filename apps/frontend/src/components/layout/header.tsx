/**
 * @fileoverview Componente Header principale
 * Header fisso con logo, ricerca, notifiche, role switcher e profilo utente
 */

'use client';

import React, { useState, useEffect } from 'react';
import { 
  Menu, 
  Search, 
  Bell, 
  User, 
  Settings, 
  Zap,
  Sun,
  Moon
} from 'lucide-react';
import { useUserRoles } from '../../hooks/useUserRoles';
import { RoleSwitcher } from './RoleSwitcher';
import { useTheme } from '../theme-provider';

interface HeaderProps {
  onToggleSidebar: () => void;
  className?: string;
}

/**
 * Componente Header principale dell'applicazione
 */
export const Header: React.FC<HeaderProps> = ({ 
  onToggleSidebar,
  className = ''
}) => {
  const { user, isLoading } = useUserRoles();
  const { theme, setTheme, actualTheme } = useTheme();
  const [isSearchFocused, setIsSearchFocused] = useState(false);
  const [isNotificationsOpen, setIsNotificationsOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = () => {
      setIsNotificationsOpen(false);
      setIsProfileOpen(false);
    };

    document.addEventListener('click', handleClickOutside);
    return () => document.removeEventListener('click', handleClickOutside);
  }, []);

  // Mock notifications data
  const notifications = [
    {
      id: 1,
      title: 'Nuovo corso disponibile',
      message: 'React Advanced Patterns è ora disponibile',
      timestamp: new Date(),
      isRead: false
    },
    {
      id: 2,
      title: 'Sessione completata',
      message: 'Hai completato la sessione di tutoring con Marco',
      timestamp: new Date(Date.now() - 1000 * 60 * 30),
      isRead: true
    }
  ];

  const unreadCount = notifications.filter(n => !n.isRead).length;

  const toggleTheme = () => {
    if (theme === 'light') {
      setTheme('dark');
    } else if (theme === 'dark') {
      setTheme('system');
    } else {
      setTheme('light');
    }
  };

  const getThemeIcon = () => {
    if (theme === 'system') {
      return actualTheme === 'dark' ? <Moon className="w-5 h-5 text-slate-400" /> : <Sun className="w-5 h-5 text-amber-500" />;
    }
    return actualTheme === 'dark' ? <Moon className="w-5 h-5 text-slate-400" /> : <Sun className="w-5 h-5 text-amber-500" />;
  };

  const getThemeLabel = () => {
    if (theme === 'system') {
      return `Sistema (${actualTheme === 'dark' ? 'Scuro' : 'Chiaro'})`;
    }
    return actualTheme === 'dark' ? 'Modalità Scura' : 'Modalità Chiara';
  };

  return (
    <header className={`fixed top-0 left-0 right-0 z-50 bg-white dark:bg-stone-900 border-b border-stone-200 dark:border-stone-800 h-16 theme-transition ${className}`}>
      <div className="flex items-center justify-between px-4 h-full">
        {/* Left Section */}
        <div className="flex items-center space-x-4">
          {/* Sidebar Toggle */}
          <button 
            onClick={onToggleSidebar}
            className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors focus-visible"
            aria-label="Toggle sidebar"
          >
            <Menu className="w-5 h-5 text-stone-600 dark:text-stone-400" />
          </button>
          
          {/* Logo */}
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-br from-dydat-amber to-dydat-orange rounded-lg flex items-center justify-center hover-lift">
              <span className="text-white font-bold text-sm">D</span>
            </div>
            <span className="text-xl font-bold text-stone-900 dark:text-stone-100">
              Dydat
            </span>
          </div>
        </div>

        {/* Center Section - Search */}
        <div className="hidden md:flex flex-1 max-w-md mx-8">
          <div className="relative w-full">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-stone-400" />
            <input
              type="text"
              placeholder="Cerca corsi, lezioni, contenuti..."
              className={`w-full pl-10 pr-4 py-2 border border-stone-200 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 placeholder-stone-500 focus:outline-none focus:ring-2 focus:ring-dydat-amber focus:border-transparent transition-all duration-200 ${
                isSearchFocused ? 'ring-2 ring-dydat-amber' : ''
              }`}
              onFocus={() => setIsSearchFocused(true)}
              onBlur={() => setIsSearchFocused(false)}
            />
          </div>
        </div>

        {/* Right Section */}
        <div className="flex items-center space-x-3">
          {/* Role Switcher */}
          {!isLoading && user && (
            <RoleSwitcher />
          )}
          
          {/* Dark Mode Toggle */}
          <button 
            onClick={toggleTheme}
            className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors focus-visible"
            aria-label={getThemeLabel()}
            title={`Tema attuale: ${getThemeLabel()}. Clicca per cambiare.`}
          >
            {getThemeIcon()}
          </button>
          
          {/* Notifications */}
          <div className="relative">
            <button 
              onClick={() => setIsNotificationsOpen(!isNotificationsOpen)}
              className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors relative focus-visible"
              aria-label="Notifications"
            >
              <Bell className="w-5 h-5 text-stone-600 dark:text-stone-400" />
              {unreadCount > 0 && (
                <span className="absolute -top-1 -right-1 w-5 h-5 bg-dydat-orange text-white text-xs font-bold rounded-full flex items-center justify-center">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </span>
              )}
            </button>
            
            {/* Notifications Dropdown */}
            {isNotificationsOpen && (
              <div className="absolute right-0 top-full mt-2 w-80 bg-white dark:bg-stone-900 rounded-xl shadow-strong border border-stone-200 dark:border-stone-800 py-2 z-50">
                <div className="px-4 py-2 border-b border-stone-200 dark:border-stone-800">
                  <h3 className="font-semibold text-stone-900 dark:text-stone-100">Notifiche</h3>
                </div>
                <div className="max-h-64 overflow-y-auto">
                  {notifications.map((notification) => (
                    <div
                      key={notification.id}
                      className={`px-4 py-3 hover:bg-stone-50 dark:hover:bg-stone-800 cursor-pointer border-l-4 ${
                        notification.isRead 
                          ? 'border-transparent' 
                          : 'border-dydat-amber bg-amber-50/50 dark:bg-amber-900/10'
                      }`}
                    >
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <p className="text-sm font-medium text-stone-900 dark:text-stone-100">
                            {notification.title}
                          </p>
                          <p className="text-xs text-stone-600 dark:text-stone-400 mt-1">
                            {notification.message}
                          </p>
                        </div>
                        <span className="text-xs text-stone-500 dark:text-stone-500 ml-2">
                          {notification.timestamp.toLocaleTimeString('it-IT', { 
                            hour: '2-digit', 
                            minute: '2-digit' 
                          })}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="px-4 py-2 border-t border-stone-200 dark:border-stone-800">
                  <button className="text-sm text-dydat-amber hover:text-dydat-orange transition-colors">
                    Vedi tutte le notifiche
                  </button>
                </div>
              </div>
            )}
          </div>
          
          {/* Neuroni Display */}
          {!isLoading && user && (
            <div className="flex items-center space-x-2 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20 px-4 py-2 rounded-full border border-amber-200/50 dark:border-amber-800/50 hover-lift">
              <Zap className="w-4 h-4 text-amber-600 dark:text-amber-400" />
              <span className="text-sm font-bold text-amber-700 dark:text-amber-300">
                {user.neurons.toLocaleString()}
              </span>
              <span className="text-xs text-amber-600 dark:text-amber-400 font-medium">N</span>
            </div>
          )}
          
          {/* User Profile */}
          {!isLoading && user && (
            <div className="relative">
              <button 
                onClick={() => setIsProfileOpen(!isProfileOpen)}
                className="w-10 h-10 rounded-full overflow-hidden border-2 border-amber-200 dark:border-amber-700 hover:border-amber-300 dark:hover:border-amber-600 transition-colors focus-visible relative"
                aria-label="User profile"
              >
                {user.avatar ? (
                  <img 
                    src={user.avatar} 
                    alt={user.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full bg-gradient-to-r from-dydat-amber to-dydat-orange flex items-center justify-center">
                    <User className="w-5 h-5 text-white" />
                  </div>
                )}
                
                {/* Level Badge */}
                <div className="absolute -bottom-1 -right-1 bg-gradient-to-r from-purple-500 to-pink-500 text-white text-xs font-bold px-2 py-1 rounded-full shadow-lg">
                  {user.level}
                </div>
              </button>
              
              {/* Profile Dropdown */}
              {isProfileOpen && (
                <div className="absolute right-0 top-full mt-2 w-64 bg-white dark:bg-stone-900 rounded-xl shadow-strong border border-stone-200 dark:border-stone-800 py-2 z-50">
                  <div className="px-4 py-3 border-b border-stone-200 dark:border-stone-800">
                    <div className="flex items-center space-x-3">
                      <div className="w-12 h-12 rounded-full overflow-hidden">
                        {user.avatar ? (
                          <img 
                            src={user.avatar} 
                            alt={user.name}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full bg-gradient-to-r from-dydat-amber to-dydat-orange flex items-center justify-center">
                            <User className="w-6 h-6 text-white" />
                          </div>
                        )}
                      </div>
                      <div className="flex-1">
                        <p className="font-semibold text-stone-900 dark:text-stone-100">
                          {user.name}
                        </p>
                        <p className="text-sm text-stone-600 dark:text-stone-400">
                          {user.email}
                        </p>
                      </div>
                    </div>
                  </div>
                  
                  <div className="py-2">
                    <button className="w-full px-4 py-2 text-left hover:bg-stone-50 dark:hover:bg-stone-800 transition-colors flex items-center space-x-3">
                      <User className="w-4 h-4 text-stone-600 dark:text-stone-400" />
                      <span className="text-stone-900 dark:text-stone-100">Il Mio Profilo</span>
                    </button>
                    <button className="w-full px-4 py-2 text-left hover:bg-stone-50 dark:hover:bg-stone-800 transition-colors flex items-center space-x-3">
                      <Settings className="w-4 h-4 text-stone-600 dark:text-stone-400" />
                      <span className="text-stone-900 dark:text-stone-100">Impostazioni</span>
                    </button>
                  </div>
                  
                  <div className="px-4 py-2 border-t border-stone-200 dark:border-stone-800">
                    <button className="text-sm text-red-600 hover:text-red-700 transition-colors">
                      Logout
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
      
      {/* Mobile Search */}
      <div className="md:hidden px-4 pb-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-stone-400" />
          <input
            type="text"
            placeholder="Cerca..."
            className="w-full pl-10 pr-4 py-2 border border-stone-200 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 placeholder-stone-500 focus:outline-none focus:ring-2 focus:ring-dydat-amber focus:border-transparent"
          />
        </div>
      </div>
    </header>
  );
};

export type { HeaderProps }; 