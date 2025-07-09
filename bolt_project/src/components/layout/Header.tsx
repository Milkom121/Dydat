import React from 'react';
import { Search, Bell, User, Menu, Sun, Moon, Zap } from 'lucide-react';
import { RoleSwitcher } from './RoleSwitcher';
import { useUserRoles } from '../../hooks/useUserRoles';

interface HeaderProps {
  onToggleSidebar: () => void;
  isDarkMode: boolean;
  onToggleDarkMode: () => void;
}

export const Header: React.FC<HeaderProps> = ({ 
  onToggleSidebar, 
  isDarkMode, 
  onToggleDarkMode 
}) => {
  const { user } = useUserRoles();

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-white dark:bg-stone-900 border-b border-stone-200 dark:border-stone-800 h-16">
      <div className="flex items-center justify-between px-4 h-full">
        {/* Left Section */}
        <div className="flex items-center space-x-4">
          <button 
            onClick={onToggleSidebar}
            className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors"
          >
            <Menu className="w-5 h-5 text-stone-600 dark:text-stone-400" />
          </button>
          
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-br from-amber-400 to-orange-500 rounded-lg flex items-center justify-center">
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
              className="w-full pl-10 pr-4 py-2 border border-stone-200 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-800 text-stone-900 dark:text-stone-100 placeholder-stone-500 focus:outline-none focus:ring-2 focus:ring-amber-400 focus:border-transparent"
            />
          </div>
        </div>

        {/* Right Section */}
        <div className="flex items-center space-x-3">
          {/* Role Switcher */}
          <RoleSwitcher />
          
          <button 
            onClick={onToggleDarkMode}
            className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors"
          >
            {isDarkMode ? (
              <Sun className="w-5 h-5 text-amber-400" />
            ) : (
              <Moon className="w-5 h-5 text-stone-600" />
            )}
          </button>
          
          <div className="relative">
            <button className="p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-800 transition-colors relative">
              <Bell className="w-5 h-5 text-stone-600 dark:text-stone-400" />
              <span className="absolute top-1 right-1 w-2 h-2 bg-orange-500 rounded-full"></span>
            </button>
          </div>
          
          {/* Neuroni Display */}
          <div className="flex items-center space-x-2 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20 px-4 py-2 rounded-full border border-amber-200/50 dark:border-amber-800/50">
            <Zap className="w-4 h-4 text-amber-600 dark:text-amber-400" />
            <span className="text-sm font-bold text-amber-700 dark:text-amber-300">
              {user?.neurons?.toLocaleString() || '0'}
            </span>
            <span className="text-xs text-amber-600 dark:text-amber-400 font-medium">N</span>
          </div>
          
          {/* User Avatar */}
          <div className="relative">
            <button className="w-10 h-10 rounded-full overflow-hidden border-2 border-amber-200 dark:border-amber-700 hover:border-amber-300 dark:hover:border-amber-600 transition-colors">
              {user?.avatar ? (
                <img 
                  src={user.avatar} 
                  alt={user.name}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full bg-gradient-to-r from-amber-400 to-orange-500 flex items-center justify-center">
                  <User className="w-5 h-5 text-white" />
                </div>
              )}
            </button>
            
            {/* Level Badge */}
            <div className="absolute -bottom-1 -right-1 bg-gradient-to-r from-purple-500 to-pink-500 text-white text-xs font-bold px-2 py-1 rounded-full shadow-lg">
              {user?.level || 1}
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};