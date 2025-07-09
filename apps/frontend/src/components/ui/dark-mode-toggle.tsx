'use client';

/**
 * Dark Mode Toggle Component
 * Accessible toggle button with smooth animations and icons
 */

import { useTheme } from '@/components/theme-provider';
import { Sun, Moon, Monitor } from 'lucide-react';
import { cn } from '@/lib/utils';

interface DarkModeToggleProps {
  className?: string;
  showLabel?: boolean;
  variant?: 'button' | 'dropdown';
}

export function DarkModeToggle({ 
  className, 
  showLabel = false, 
  variant = 'button' 
}: DarkModeToggleProps) {
  const { theme, setTheme, actualTheme } = useTheme();

  if (variant === 'dropdown') {
    return (
      <div className="relative">
        <div className="flex flex-col space-y-1">
          <button
            onClick={() => setTheme('light')}
            className={cn(
              'flex items-center space-x-2 px-3 py-2 rounded-lg text-sm transition-colors',
              theme === 'light' 
                ? 'bg-primary-100 text-primary-700' 
                : 'hover:bg-gray-100 dark:hover:bg-gray-800'
            )}
          >
            <Sun className="w-4 h-4" />
            <span>Light</span>
          </button>
          <button
            onClick={() => setTheme('dark')}
            className={cn(
              'flex items-center space-x-2 px-3 py-2 rounded-lg text-sm transition-colors',
              theme === 'dark' 
                ? 'bg-primary-100 text-primary-700' 
                : 'hover:bg-gray-100 dark:hover:bg-gray-800'
            )}
          >
            <Moon className="w-4 h-4" />
            <span>Dark</span>
          </button>
          <button
            onClick={() => setTheme('system')}
            className={cn(
              'flex items-center space-x-2 px-3 py-2 rounded-lg text-sm transition-colors',
              theme === 'system' 
                ? 'bg-primary-100 text-primary-700' 
                : 'hover:bg-gray-100 dark:hover:bg-gray-800'
            )}
          >
            <Monitor className="w-4 h-4" />
            <span>System</span>
          </button>
        </div>
      </div>
    );
  }

  const cycleTheme = () => {
    if (theme === 'light') {
      setTheme('dark');
    } else if (theme === 'dark') {
      setTheme('system');
    } else {
      setTheme('light');
    }
  };

  const getIcon = () => {
    if (theme === 'system') {
      return <Monitor className="w-5 h-5" />;
    }
    return actualTheme === 'dark' ? <Moon className="w-5 h-5" /> : <Sun className="w-5 h-5" />;
  };

  const getLabel = () => {
    if (theme === 'system') {
      return `System (${actualTheme})`;
    }
    return theme === 'dark' ? 'Dark' : 'Light';
  };

  return (
    <button
      onClick={cycleTheme}
      className={cn(
        'dark-mode-toggle group relative',
        className
      )}
      aria-label={`Switch to ${theme === 'light' ? 'dark' : theme === 'dark' ? 'system' : 'light'} mode`}
      title={`Current: ${getLabel()}. Click to cycle.`}
    >
      {/* Icon with smooth transition */}
      <div className="relative overflow-hidden">
        <div 
          className={cn(
            'transition-all duration-300 transform',
            'text-gray-600 dark:text-gray-300',
            'group-hover:text-primary-600 dark:group-hover:text-primary-400',
            'group-hover:scale-110'
          )}
        >
          {getIcon()}
        </div>
      </div>
      
      {/* Optional label */}
      {showLabel && (
        <span className="ml-2 text-sm font-medium text-gray-700 dark:text-gray-300">
          {getLabel()}
        </span>
      )}
      
      {/* Tooltip for button variant */}
      {!showLabel && (
        <div className="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-2 py-1 bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none whitespace-nowrap">
          {getLabel()}
          <div className="absolute top-full left-1/2 transform -translate-x-1/2 border-2 border-transparent border-t-gray-900 dark:border-t-gray-100"></div>
        </div>
      )}
    </button>
  );
}

// Compact version for mobile
export function DarkModeToggleCompact({ className }: { className?: string }) {
  const { theme, setTheme, actualTheme } = useTheme();

  const toggleTheme = () => {
    setTheme(actualTheme === 'dark' ? 'light' : 'dark');
  };

  return (
    <button
      onClick={toggleTheme}
      className={cn(
        'p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors',
        className
      )}
      aria-label={`Switch to ${actualTheme === 'dark' ? 'light' : 'dark'} mode`}
    >
      {actualTheme === 'dark' ? (
        <Sun className="w-4 h-4 text-yellow-500" />
      ) : (
        <Moon className="w-4 h-4 text-gray-700" />
      )}
    </button>
  );
} 