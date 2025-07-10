'use client';

import { useState } from 'react';
import { Bell, Search, User, LogOut, Settings, HelpCircle, ChevronDown, Plus } from 'lucide-react';
import { DarkModeToggle } from '@/components/ui/dark-mode-toggle';
import { Button } from '@/components/ui/button';
import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'next/navigation';
import { cn } from '@/lib/utils';

// Mock notifications data
const notifications = [
  {
    id: 1,
    title: 'Nuova richiesta di tutoring',
    message: 'Anna Russo ha richiesto una sessione di Fisica',
    time: '5 min fa',
    type: 'request',
    unread: true
  },
  {
    id: 2,
    title: 'Sessione confermata',
    message: 'Maria Rossi ha confermato la sessione di domani',
    time: '1 ora fa',
    type: 'booking',
    unread: true
  },
  {
    id: 3,
    title: 'Nuovo rating ricevuto',
    message: 'Giuseppe ti ha lasciato 5 stelle!',
    time: '3 ore fa',
    type: 'rating',
    unread: false
  }
];

export function TutorHeader() {
  const { user, logout } = useAuthStore();
  const router = useRouter();
  const [showNotifications, setShowNotifications] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  const unreadCount = notifications.filter(n => n.unread).length;

  return (
    <header className="bg-white dark:bg-stone-800 shadow-sm border-b border-stone-200 dark:border-stone-700 sticky top-0 z-30">
      <div className="flex items-center justify-between px-4 py-4 lg:px-6">
        {/* Left: Search & Quick Action */}
        <div className="flex items-center space-x-4 flex-1">
          {/* Search */}
          <div className="relative max-w-md flex-1">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-stone-400" />
            <input
              type="text"
              placeholder="Cerca studenti, sessioni..."
              className="w-full pl-10 pr-4 py-2.5 border border-stone-300 dark:border-stone-600 rounded-lg bg-white dark:bg-stone-700 text-stone-900 dark:text-stone-100 placeholder-stone-500 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition-colors"
            />
          </div>

          {/* Quick Action */}
          <Button
            variant="outline"
            size="default"
            className="hidden sm:flex items-center space-x-2"
          >
            <Plus className="h-4 w-4" />
            <span>Nuova Sessione</span>
          </Button>
        </div>

        {/* Right: Actions */}
        <div className="flex items-center space-x-3">
          {/* Notifications */}
          <div className="relative">
            <button
              onClick={() => setShowNotifications(!showNotifications)}
              className="relative p-2 text-stone-600 dark:text-stone-400 hover:text-stone-900 dark:hover:text-stone-100 hover:bg-stone-100 dark:hover:bg-stone-700 rounded-lg transition-colors"
            >
              <Bell className="h-5 w-5" />
              {unreadCount > 0 && (
                <span className="absolute -top-1 -right-1 h-4 w-4 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-medium">
                  {unreadCount}
                </span>
              )}
            </button>

            {/* Notifications Dropdown */}
            {showNotifications && (
              <div className="absolute right-0 mt-2 w-80 bg-white dark:bg-stone-800 rounded-lg shadow-lg border border-stone-200 dark:border-stone-700 z-50">
                <div className="p-4 border-b border-stone-200 dark:border-stone-700">
                  <div className="flex items-center justify-between">
                    <h3 className="font-semibold text-stone-900 dark:text-stone-100">
                      Notifiche
                    </h3>
                    <button className="text-sm text-amber-600 dark:text-amber-400 hover:text-amber-700">
                      Segna come lette
                    </button>
                  </div>
                </div>
                <div className="max-h-64 overflow-y-auto">
                  {notifications.map((notification) => (
                    <div
                      key={notification.id}
                      className={cn(
                        "p-4 border-b border-stone-100 dark:border-stone-700 hover:bg-stone-50 dark:hover:bg-stone-750 cursor-pointer",
                        notification.unread && "bg-blue-50/50 dark:bg-blue-900/10"
                      )}
                    >
                      <div className="flex items-start space-x-3">
                        <div className={cn(
                          "w-2 h-2 rounded-full mt-2",
                          notification.unread ? "bg-blue-500" : "bg-stone-300 dark:bg-stone-600"
                        )} />
                        <div className="flex-1">
                          <p className="text-sm font-medium text-stone-900 dark:text-stone-100">
                            {notification.title}
                          </p>
                          <p className="text-sm text-stone-600 dark:text-stone-400 mt-1">
                            {notification.message}
                          </p>
                          <p className="text-xs text-stone-500 dark:text-stone-500 mt-1">
                            {notification.time}
                          </p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="p-3 text-center border-t border-stone-200 dark:border-stone-700">
                  <button className="text-sm text-amber-600 dark:text-amber-400 hover:text-amber-700">
                    Vedi tutte le notifiche
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Dark Mode Toggle */}
          <DarkModeToggle />

          {/* Profile Dropdown */}
          <div className="relative">
            <button
              onClick={() => setShowProfileMenu(!showProfileMenu)}
              className="flex items-center space-x-3 p-2 rounded-lg hover:bg-stone-100 dark:hover:bg-stone-700 transition-colors"
            >
              <div className="flex items-center space-x-2">
                <div className="text-right hidden sm:block">
                  <p className="text-sm font-medium text-stone-900 dark:text-stone-100">
                    {user?.name || 'Tutor'}
                  </p>
                  <p className="text-xs text-stone-500 dark:text-stone-400">
                    {user?.roles.includes('tutor') ? 'Tutor' : user?.primaryRole || 'Utente'}
                  </p>
                </div>
                
                {/* Avatar */}
                {user?.avatar ? (
                  <img
                    src={user.avatar}
                    alt={user.name}
                    className="h-8 w-8 rounded-full object-cover ring-2 ring-white dark:ring-stone-700"
                  />
                ) : (
                  <div className="h-8 w-8 rounded-full bg-amber-100 dark:bg-amber-900/20 flex items-center justify-center ring-2 ring-white dark:ring-stone-700">
                    <User className="h-4 w-4 text-amber-600 dark:text-amber-400" />
                  </div>
                )}
                
                <ChevronDown className="h-4 w-4 text-stone-400" />
              </div>
            </button>

            {/* Profile Menu */}
            {showProfileMenu && (
              <div className="absolute right-0 mt-2 w-56 bg-white dark:bg-stone-800 rounded-lg shadow-lg border border-stone-200 dark:border-stone-700 z-50">
                <div className="p-3 border-b border-stone-200 dark:border-stone-700">
                  <p className="font-medium text-stone-900 dark:text-stone-100">
                    {user?.name}
                  </p>
                  <p className="text-sm text-stone-500 dark:text-stone-400">
                    {user?.email}
                  </p>
                </div>
                <div className="py-1">
                  <button
                    onClick={() => router.push('/tutor/profilo')}
                    className="flex items-center w-full px-4 py-2 text-sm text-stone-700 dark:text-stone-300 hover:bg-stone-100 dark:hover:bg-stone-700"
                  >
                    <User className="h-4 w-4 mr-3" />
                    Il Mio Profilo
                  </button>
                  <button
                    onClick={() => router.push('/tutor/impostazioni')}
                    className="flex items-center w-full px-4 py-2 text-sm text-stone-700 dark:text-stone-300 hover:bg-stone-100 dark:hover:bg-stone-700"
                  >
                    <Settings className="h-4 w-4 mr-3" />
                    Impostazioni
                  </button>
                  <button
                    onClick={() => router.push('/tutor/supporto')}
                    className="flex items-center w-full px-4 py-2 text-sm text-stone-700 dark:text-stone-300 hover:bg-stone-100 dark:hover:bg-stone-700"
                  >
                    <HelpCircle className="h-4 w-4 mr-3" />
                    Supporto
                  </button>
                </div>
                <div className="py-1 border-t border-stone-200 dark:border-stone-700">
                  <button
                    onClick={handleLogout}
                    className="flex items-center w-full px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20"
                  >
                    <LogOut className="h-4 w-4 mr-3" />
                    Logout
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Click outside to close dropdowns */}
      {(showNotifications || showProfileMenu) && (
        <div
          className="fixed inset-0 z-20"
          onClick={() => {
            setShowNotifications(false);
            setShowProfileMenu(false);
          }}
        />
      )}
    </header>
  );
} 