/**
 * @fileoverview Componente Sidebar
 * Sidebar collassabile con navigazione dinamica basata sui ruoli
 */

'use client';

import React from 'react';
import { 
  Home, 
  BookOpen, 
  GraduationCap, 
  Layers, 
  Users, 
  Building, 
  PenTool,
  ChevronRight,
  BarChart3,
  MessageSquare,
  Settings,
  User as UserIcon,
  Calendar,
  Star,
  Zap,
  Trophy
} from 'lucide-react';
import { useUserRoles } from '../../hooks/useUserRoles';

interface SidebarProps {
  isCollapsed: boolean;
  currentPath: string;
  onNavigate: (path: string) => void;
}

/**
 * Componente Sidebar per la navigazione principale
 */
export const Sidebar: React.FC<SidebarProps> = ({ 
  isCollapsed, 
  currentPath, 
  onNavigate 
}) => {
  const { hasPermission, user, currentRole } = useUserRoles();

  // Elementi di navigazione base disponibili a tutti gli utenti autenticati
  const baseNavigationItems = [
    { 
      icon: Home, 
      label: 'Dashboard', 
      path: '/dashboard',
      description: 'Panoramica generale e statistiche'
    },
    { 
      icon: UserIcon, 
      label: 'Il Mio Profilo', 
      path: '/profile',
      description: 'Gestisci il tuo profilo e preferenze'
    },
    { 
      icon: BookOpen, 
      label: 'Catalogo Corsi', 
      path: '/catalog',
      description: 'Esplora tutti i corsi disponibili'
    },
    { 
      icon: GraduationCap, 
      label: 'I Miei Corsi', 
      path: '/my-courses',
      description: 'Corsi a cui sei iscritto'
    },
    { 
      icon: Layers, 
      label: 'Suite di Apprendimento', 
      path: '/learning-suite',
      description: 'Strumenti avanzati per l\'apprendimento',
      hasSubmenu: true,
      submenu: [
        { label: 'Canvas', path: '/learning-suite/canvas', icon: PenTool },
        { label: 'Flashcard', path: '/learning-suite/flashcards', icon: Zap },
        { label: 'AI Companion', path: '/learning-suite/ai-companion', icon: Star }
      ]
    },
    { 
      icon: Users, 
      label: 'Mercatino', 
      path: '/marketplace',
      description: 'Trova tutor e servizi di apprendimento'
    }
  ];

  // Elementi di navigazione specifici per ruolo
  const roleSpecificItems = [
    // Elementi per Creator
    ...(hasPermission('canCreateCourses') ? [
      { 
        icon: PenTool, 
        label: 'Studio di Creazione', 
        path: '/create',
        description: 'Crea e gestisci i tuoi corsi'
      },
      { 
        icon: BarChart3, 
        label: 'Analytics Corsi', 
        path: '/analytics',
        description: 'Statistiche e performance dei tuoi corsi'
      }
    ] : []),
    
    // Elementi per Organizzazioni
    ...(hasPermission('canManageOrganization') || user?.organizations.length ? [
      { 
        icon: Building, 
        label: 'Le Mie Organizzazioni', 
        path: '/organizations',
        description: 'Gestisci le tue organizzazioni'
      }
    ] : []),
    
    // Elementi per Tutor
    ...(hasPermission('canOfferTutoring') ? [
      { 
        icon: MessageSquare, 
        label: 'Sessioni Tutoraggio', 
        path: '/tutoring',
        description: 'Gestisci le tue sessioni di tutoring',
        hasSubmenu: true,
        submenu: [
          { label: 'Dashboard', path: '/tutoring/dashboard', icon: Home },
          { label: 'Studenti', path: '/tutoring/students', icon: Users },
          { label: 'Calendario', path: '/tutoring/calendar', icon: Calendar },
          { label: 'Richieste', path: '/tutoring/requests', icon: MessageSquare }
        ]
      }
    ] : []),
    
    // Elementi per Gamification
    { 
      icon: Trophy, 
      label: 'Achievements', 
      path: '/achievements',
      description: 'I tuoi badge e traguardi'
    }
  ];

  const navigationItems = [...baseNavigationItems, ...roleSpecificItems];

  /**
   * Controlla se un path è attivo
   */
  const isActive = (path: string) => {
    if (path === '/dashboard') return currentPath === '/dashboard';
    return currentPath.startsWith(path);
  };

  /**
   * Controlla se un submenu è attivo
   */
  const isSubmenuActive = (item: any) => {
    return item.hasSubmenu && item.submenu?.some((subItem: any) => currentPath.startsWith(subItem.path));
  };

  return (
    <aside className={`fixed left-0 top-16 bottom-0 z-40 bg-white dark:bg-stone-900 border-r border-stone-200 dark:border-stone-800 transition-all duration-300 ${
      isCollapsed ? 'w-16' : 'w-64'
    }`}>
      <nav className="p-4 space-y-1 h-full overflow-y-auto scrollbar-hide">
        {/* User Info quando non collassato */}
        {!isCollapsed && user && (
          <div className="mb-6 p-3 bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20 rounded-lg border border-amber-200/50 dark:border-amber-800/50">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-full overflow-hidden">
                {user.avatar ? (
                  <img 
                    src={user.avatar} 
                    alt={user.name}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full bg-gradient-to-r from-dydat-amber to-dydat-orange flex items-center justify-center">
                    <UserIcon className="w-5 h-5 text-white" />
                  </div>
                )}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-stone-900 dark:text-stone-100 truncate">
                  {user.name}
                </p>
                <p className="text-xs text-amber-600 dark:text-amber-400 truncate">
                  Livello {user.level} • {user.neurons} Neuroni
                </p>
              </div>
            </div>
          </div>
        )}

        {/* Navigation Items */}
        {navigationItems.map((item) => (
          <div key={item.path}>
            <button
              onClick={() => onNavigate(item.path)}
              className={`w-full flex items-center space-x-3 p-3 rounded-lg transition-all duration-200 group ${
                isActive(item.path) || isSubmenuActive(item)
                  ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300 shadow-sm' 
                  : 'text-stone-600 dark:text-stone-400 hover:bg-stone-100 dark:hover:bg-stone-800 hover:text-stone-900 dark:hover:text-stone-100'
              }`}
              title={isCollapsed ? item.label : undefined}
            >
              <item.icon className="w-5 h-5 flex-shrink-0" />
              {!isCollapsed && (
                <>
                  <div className="flex-1 text-left">
                    <span className="block text-sm font-medium">{item.label}</span>
                    {item.description && (
                      <span className="block text-xs opacity-75 mt-0.5">
                        {item.description}
                      </span>
                    )}
                  </div>
                  {item.hasSubmenu && (
                    <ChevronRight className={`w-4 h-4 transition-transform ${
                      isSubmenuActive(item) ? 'rotate-90' : ''
                    }`} />
                  )}
                </>
              )}
            </button>
            
            {/* Submenu */}
            {item.hasSubmenu && !isCollapsed && isSubmenuActive(item) && (
              <div className="ml-8 mt-2 space-y-1">
                {item.submenu?.map((subItem: any) => (
                  <button
                    key={subItem.path}
                    onClick={() => onNavigate(subItem.path)}
                    className={`w-full flex items-center space-x-3 p-2 rounded-md text-sm transition-colors ${
                      isActive(subItem.path)
                        ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300'
                        : 'text-stone-500 dark:text-stone-500 hover:bg-stone-100 dark:hover:bg-stone-800 hover:text-stone-900 dark:hover:text-stone-100'
                    }`}
                  >
                    <subItem.icon className="w-4 h-4" />
                    <span>{subItem.label}</span>
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
        
        {/* Settings at bottom */}
        <div className="absolute bottom-4 left-4 right-4">
          <button
            onClick={() => onNavigate('/settings')}
            className={`w-full flex items-center space-x-3 p-3 rounded-lg transition-colors ${
              isActive('/settings')
                ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300'
                : 'text-stone-600 dark:text-stone-400 hover:bg-stone-100 dark:hover:bg-stone-800 hover:text-stone-900 dark:hover:text-stone-100'
            }`}
            title={isCollapsed ? 'Impostazioni' : undefined}
          >
            <Settings className="w-5 h-5 flex-shrink-0" />
            {!isCollapsed && (
              <span className="flex-1 text-left text-sm font-medium">Impostazioni</span>
            )}
          </button>
        </div>
      </nav>
    </aside>
  );
}; 