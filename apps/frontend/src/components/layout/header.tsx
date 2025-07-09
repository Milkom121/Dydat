/**
 * Header Component - Dydat Design System
 * Main navigation header with authentication and dark mode support
 */

'use client';

import * as React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/utils';
import { useAuthStore, useIsAuthenticated, useCurrentUser } from '@/stores/auth';
import { UserRole } from '@/types/auth';
import { 
  Button, 
  Modal, 
  ModalTrigger, 
  ModalContent, 
  ModalHeader, 
  ModalTitle, 
  ModalDescription, 
  ModalFooter 
} from '@/components/ui';
import { DarkModeToggle } from '@/components/ui/dark-mode-toggle';
import { 
  User, 
  LogOut, 
  Settings, 
  BookOpen, 
  Users, 
  BarChart3, 
  Menu, 
  X,
  GraduationCap,
  Sparkles
} from 'lucide-react';
import { useState } from 'react';

interface HeaderProps {
  className?: string;
  variant?: 'default' | 'transparent' | 'glass';
}

const Header = React.forwardRef<HTMLElement, HeaderProps>(
  ({ className, variant = 'default' }, ref) => {
    const pathname = usePathname();
    const isAuthenticated = useIsAuthenticated();
    const user = useCurrentUser();
    const logout = useAuthStore(state => state.logout);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
    const [showLogoutModal, setShowLogoutModal] = useState(false);

    const headerVariants = {
      default: "bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800",
      transparent: "bg-transparent",
      glass: "glass border-b border-white/10 dark:border-gray-800/50"
    };

    const navigation = [
      { name: 'Home', href: '/', icon: GraduationCap },
      { name: 'Corsi', href: '/courses', icon: BookOpen },
      { name: 'Community', href: '/community', icon: Users },
      { name: 'Leaderboard', href: '/leaderboard', icon: BarChart3 },
    ];

    const userNavigation = [
      { name: 'Profilo', href: '/profile', icon: User },
      { name: 'Impostazioni', href: '/settings', icon: Settings },
    ];

    const handleLogout = async () => {
      await logout();
      setShowLogoutModal(false);
    };

    const isActivePath = (path: string) => {
      if (path === '/') return pathname === '/';
      return pathname.startsWith(path);
    };

    return (
      <header 
        ref={ref}
        className={cn(
          "sticky top-0 z-50 w-full transition-all duration-200",
          headerVariants[variant],
          className
        )}
      >
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <div className="flex items-center">
              <Link href="/" className="flex items-center space-x-2 group">
                <div className="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center group-hover:scale-110 transition-transform">
                  <span className="text-white font-bold text-sm">D</span>
                </div>
                <span className="text-xl font-bold text-gray-900 dark:text-white">
                  Dydat
                </span>
                <Sparkles className="w-4 h-4 text-primary-500 animate-pulse" />
              </Link>
            </div>

            {/* Desktop Navigation */}
            <nav className="hidden md:flex items-center space-x-1">
              {navigation.map((item) => {
                const Icon = item.icon;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={cn(
                      "flex items-center space-x-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors",
                      isActivePath(item.href)
                        ? "bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300"
                        : "text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-white"
                    )}
                  >
                    <Icon className="w-4 h-4" />
                    <span>{item.name}</span>
                  </Link>
                );
              })}
            </nav>

            {/* User Menu & Actions */}
            <div className="flex items-center space-x-4">
              <DarkModeToggle />
              
              {isAuthenticated && user ? (
                <div className="flex items-center space-x-3">
                  {/* User Avatar & Menu */}
                  <div className="relative group">
                    <button className="flex items-center space-x-2 p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors">
                      <div className="w-8 h-8 bg-gradient-primary rounded-full flex items-center justify-center">
                        <span className="text-white font-semibold text-sm">
                          {user.firstName.charAt(0)}{user.lastName.charAt(0)}
                        </span>
                      </div>
                      <div className="hidden sm:block text-left">
                        <div className="text-sm font-medium text-gray-900 dark:text-white">
                          {user.firstName}
                        </div>
                        <div className="text-xs text-gray-500 dark:text-gray-400">
                          {user.role === UserRole.STUDENT && 'Studente'}
                          {user.role === UserRole.CREATOR && 'Creator'}
                          {user.role === UserRole.ADMIN && 'Admin'}
                        </div>
                      </div>
                    </button>
                    
                    {/* Dropdown Menu */}
                    <div className="absolute right-0 mt-2 w-48 bg-white dark:bg-gray-800 rounded-lg shadow-strong border border-gray-200 dark:border-gray-700 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                      <div className="py-2">
                        {userNavigation.map((item) => {
                          const Icon = item.icon;
                          return (
                            <Link
                              key={item.name}
                              href={item.href}
                              className="flex items-center space-x-2 px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                            >
                              <Icon className="w-4 h-4" />
                              <span>{item.name}</span>
                            </Link>
                          );
                        })}
                        <hr className="my-2 border-gray-200 dark:border-gray-700" />
                        <button
                          onClick={() => setShowLogoutModal(true)}
                          className="flex items-center space-x-2 w-full px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-950"
                        >
                          <LogOut className="w-4 h-4" />
                          <span>Logout</span>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="flex items-center space-x-2">
                  <Link href="/auth/login">
                    <Button variant="ghost" size="sm">
                      Accedi
                    </Button>
                  </Link>
                  <Link href="/auth/register">
                    <Button size="sm">
                      Registrati
                    </Button>
                  </Link>
                </div>
              )}

              {/* Mobile Menu Button */}
              <button
                onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                className="md:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
              >
                {isMobileMenuOpen ? (
                  <X className="w-5 h-5" />
                ) : (
                  <Menu className="w-5 h-5" />
                )}
              </button>
            </div>
          </div>

          {/* Mobile Menu */}
          {isMobileMenuOpen && (
            <div className="md:hidden border-t border-gray-200 dark:border-gray-800 py-4">
              <nav className="space-y-2">
                {navigation.map((item) => {
                  const Icon = item.icon;
                  return (
                    <Link
                      key={item.name}
                      href={item.href}
                      onClick={() => setIsMobileMenuOpen(false)}
                      className={cn(
                        "flex items-center space-x-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors",
                        isActivePath(item.href)
                          ? "bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300"
                          : "text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800"
                      )}
                    >
                      <Icon className="w-5 h-5" />
                      <span>{item.name}</span>
                    </Link>
                  );
                })}
              </nav>
            </div>
          )}
        </div>

        {/* Logout Confirmation Modal */}
        <Modal open={showLogoutModal} onOpenChange={setShowLogoutModal}>
          <ModalContent>
            <ModalHeader>
              <ModalTitle>Conferma Logout</ModalTitle>
              <ModalDescription>
                Sei sicuro di voler uscire dal tuo account?
              </ModalDescription>
            </ModalHeader>
            <ModalFooter>
              <Button 
                variant="secondary" 
                onClick={() => setShowLogoutModal(false)}
              >
                Annulla
              </Button>
              <Button 
                variant="error" 
                onClick={handleLogout}
              >
                Logout
              </Button>
            </ModalFooter>
          </ModalContent>
        </Modal>
      </header>
    );
  }
);

Header.displayName = 'Header';

export { Header };
export type { HeaderProps }; 