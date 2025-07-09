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
  Settings
} from 'lucide-react';
import { useUserRoles } from '../../hooks/useUserRoles';
import { User as UserIcon } from 'lucide-react';

interface SidebarProps {
  isCollapsed: boolean;
  currentPath: string;
  onNavigate: (path: string) => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ 
  isCollapsed, 
  currentPath, 
  onNavigate 
}) => {
  const { hasPermission, user } = useUserRoles();

  // Base navigation items available to all authenticated users
  const baseNavigationItems = [
    { icon: Home, label: 'Dashboard', path: '/dashboard' },
    { icon: UserIcon, label: 'Il Mio Profilo', path: '/profile' },
    { icon: BookOpen, label: 'Catalogo Corsi', path: '/catalog' },
    { icon: GraduationCap, label: 'I Miei Corsi', path: '/my-courses' },
    { 
      icon: Layers, 
      label: 'Suite di Apprendimento', 
      path: '/learning-suite',
      hasSubmenu: true,
      submenu: [
        { label: 'Canvas', path: '/learning-suite/canvas' },
        { label: 'Flashcard', path: '/learning-suite/flashcards' },
        { label: 'AI Companion', path: '/learning-suite/ai-companion' }
      ]
    },
    { icon: Users, label: 'Mercatino', path: '/marketplace' }
  ];

  // Role-specific navigation items
  const roleSpecificItems = [
    // Creator-specific items
    ...(hasPermission('canCreateCourses') ? [
      { icon: PenTool, label: 'Studio di Creazione', path: '/create' },
      { icon: BarChart3, label: 'Analytics Corsi', path: '/analytics' }
    ] : []),
    
    // Organization-specific items
    ...(hasPermission('canManageOrganization') || user?.organizations.length ? [
      { icon: Building, label: 'Le Mie Organizzazioni', path: '/organizations' }
    ] : []),
    
    // Tutor-specific items
    ...(hasPermission('canOfferTutoring') ? [
      { icon: MessageSquare, label: 'Sessioni Tutoraggio', path: '/tutoring' }
    ] : [])
  ];

  const navigationItems = [...baseNavigationItems, ...roleSpecificItems];

  return (
    <aside className={`fixed left-0 top-16 bottom-0 z-40 bg-white dark:bg-stone-900 border-r border-stone-200 dark:border-stone-800 transition-all duration-300 ${
      isCollapsed ? 'w-16' : 'w-64'
    }`}>
      <nav className="p-4 space-y-1">
        {navigationItems.map((item) => (
          <div key={item.path}>
            <button
              onClick={() => onNavigate(item.path)}
              className={`w-full flex items-center space-x-3 p-3 rounded-lg transition-colors ${
                currentPath === item.path 
                  ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300' 
                  : 'text-stone-600 dark:text-stone-400 hover:bg-stone-100 dark:hover:bg-stone-800'
              }`}
            >
              <item.icon className="w-5 h-5 flex-shrink-0" />
              {!isCollapsed && (
                <>
                  <span className="flex-1 text-left">{item.label}</span>
                  {item.hasSubmenu && (
                    <ChevronRight className="w-4 h-4" />
                  )}
                </>
              )}
            </button>
            
            {item.hasSubmenu && !isCollapsed && currentPath.startsWith(item.path) && (
              <div className="ml-8 mt-2 space-y-1">
                {item.submenu?.map((subItem) => (
                  <button
                    key={subItem.path}
                    onClick={() => onNavigate(subItem.path)}
                    className={`w-full text-left p-2 rounded-md text-sm transition-colors ${
                      currentPath === subItem.path
                        ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300'
                        : 'text-stone-500 dark:text-stone-500 hover:bg-stone-100 dark:hover:bg-stone-800'
                    }`}
                  >
                    {subItem.label}
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
        
        {/* Settings at bottom */}
        {!isCollapsed && (
          <div className="absolute bottom-4 left-4 right-4">
            <button
              onClick={() => onNavigate('/settings')}
              className={`w-full flex items-center space-x-3 p-3 rounded-lg transition-colors ${
                currentPath === '/settings'
                  ? 'bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-300'
                  : 'text-stone-600 dark:text-stone-400 hover:bg-stone-100 dark:hover:bg-stone-800'
              }`}
            >
              <Settings className="w-5 h-5 flex-shrink-0" />
              <span className="flex-1 text-left">Impostazioni</span>
            </button>
          </div>
        )}
      </nav>
    </aside>
  );
};