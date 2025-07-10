'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  Home, 
  Calendar, 
  Users, 
  MessageSquare, 
  BarChart3, 
  User, 
  Settings,
  Menu,
  X,
  Bell,
  HelpCircle
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useAuthStore } from '@/stores/auth';

const navigation = [
  { 
    name: 'Dashboard', 
    href: '/tutor/dashboard', 
    icon: Home,
    badge: null
  },
  { 
    name: 'Calendario', 
    href: '/tutor/calendario', 
    icon: Calendar,
    badge: 3 // Sessioni oggi
  },
  { 
    name: 'I Miei Studenti', 
    href: '/tutor/studenti', 
    icon: Users,
    badge: null
  },
  { 
    name: 'Richieste', 
    href: '/tutor/richieste', 
    icon: MessageSquare,
    badge: 5 // Nuove richieste
  },
  { 
    name: 'Analytics', 
    href: '/tutor/analytics', 
    icon: BarChart3,
    badge: null
  },
  { 
    name: 'Profilo', 
    href: '/tutor/profilo', 
    icon: User,
    badge: null
  },
];

const bottomNavigation = [
  {
    name: 'Impostazioni',
    href: '/tutor/impostazioni',
    icon: Settings,
  },
  {
    name: 'Supporto',
    href: '/tutor/supporto',
    icon: HelpCircle,
  },
];

export function TutorSidebar() {
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();
  const { user } = useAuthStore();

  return (
    <>
      {/* Mobile menu button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="lg:hidden fixed top-4 left-4 z-50 p-2 rounded-md bg-white dark:bg-stone-800 shadow-lg border border-stone-200 dark:border-stone-700 hover:bg-stone-50 dark:hover:bg-stone-750 transition-colors"
      >
        {isOpen ? <X size={20} /> : <Menu size={20} />}
      </button>

      {/* Sidebar */}
      <div className={cn(
        "fixed inset-y-0 left-0 z-40 w-64 bg-white dark:bg-stone-800 shadow-xl border-r border-stone-200 dark:border-stone-700 transform transition-transform duration-300 ease-in-out",
        isOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
      )}>
        <div className="flex flex-col h-full">
          {/* Logo & User Info */}
          <div className="px-4 py-6 border-b border-stone-200 dark:border-stone-700">
            <div className="flex items-center space-x-3 mb-4">
              <div className="w-8 h-8 bg-gradient-to-br from-amber-400 to-amber-600 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">D</span>
              </div>
              <h1 className="text-lg font-bold text-stone-900 dark:text-stone-100">
                Dydat Tutor
              </h1>
            </div>
            
            {/* User Quick Info */}
            <div className="flex items-center space-x-3 p-3 bg-stone-50 dark:bg-stone-750 rounded-lg">
              {user?.avatar ? (
                <img
                  src={user.avatar}
                  alt={user.name}
                  className="w-8 h-8 rounded-full object-cover"
                />
              ) : (
                <div className="w-8 h-8 rounded-full bg-amber-100 dark:bg-amber-900/20 flex items-center justify-center">
                  <User className="h-4 w-4 text-amber-600 dark:text-amber-400" />
                </div>
              )}
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-stone-900 dark:text-stone-100 truncate">
                  {user?.name || 'Tutor'}
                </p>
                <p className="text-xs text-stone-500 dark:text-stone-400">
                  Online
                </p>
              </div>
              <div className="w-2 h-2 bg-green-500 rounded-full"></div>
            </div>
          </div>

          {/* Main Navigation */}
          <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
            {navigation.map((item) => {
              const isActive = pathname === item.href;
              return (
                <Link
                  key={item.name}
                  href={item.href}
                  onClick={() => setIsOpen(false)}
                  className={cn(
                    "group flex items-center justify-between px-3 py-3 text-sm font-medium rounded-lg transition-all duration-200",
                    isActive
                      ? "bg-amber-100 text-amber-900 dark:bg-amber-900/20 dark:text-amber-400 shadow-sm"
                      : "text-stone-700 hover:bg-stone-100 dark:text-stone-300 dark:hover:bg-stone-700/50 hover:text-stone-900 dark:hover:text-stone-100"
                  )}
                >
                  <div className="flex items-center">
                    <item.icon className={cn(
                      "mr-3 h-5 w-5 transition-colors",
                      isActive 
                        ? "text-amber-600 dark:text-amber-400" 
                        : "text-stone-500 dark:text-stone-400 group-hover:text-stone-700 dark:group-hover:text-stone-300"
                    )} />
                    {item.name}
                  </div>
                  {item.badge && (
                    <span className="inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white bg-red-500 rounded-full">
                      {item.badge}
                    </span>
                  )}
                </Link>
              );
            })}
          </nav>

          {/* Bottom Navigation */}
          <div className="p-4 border-t border-stone-200 dark:border-stone-700 space-y-1">
            {bottomNavigation.map((item) => (
              <Link
                key={item.name}
                href={item.href}
                onClick={() => setIsOpen(false)}
                className="group flex items-center px-3 py-3 text-sm font-medium text-stone-700 hover:bg-stone-100 dark:text-stone-300 dark:hover:bg-stone-700/50 hover:text-stone-900 dark:hover:text-stone-100 rounded-lg transition-all duration-200"
              >
                <item.icon className="mr-3 h-5 w-5 text-stone-500 dark:text-stone-400 group-hover:text-stone-700 dark:group-hover:text-stone-300 transition-colors" />
                {item.name}
              </Link>
            ))}
            
            {/* Quick Stats */}
            <div className="mt-4 p-3 bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-lg">
              <div className="flex items-center justify-between text-xs">
                <span className="text-stone-600 dark:text-stone-400">Questo mese</span>
                <span className="font-semibold text-blue-600 dark:text-blue-400">€1,240</span>
              </div>
              <div className="mt-1 w-full bg-stone-200 dark:bg-stone-700 rounded-full h-1.5">
                <div className="bg-blue-500 h-1.5 rounded-full" style={{ width: '68%' }}></div>
              </div>
              <div className="mt-1 text-xs text-stone-500 dark:text-stone-400">
                68% dell'obiettivo
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Overlay for mobile */}
      {isOpen && (
        <div
          className="fixed inset-0 z-30 bg-black bg-opacity-50 lg:hidden backdrop-blur-sm"
          onClick={() => setIsOpen(false)}
        />
      )}
    </>
  );
} 