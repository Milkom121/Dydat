'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/stores/auth';
import { UserRole } from '@/types/auth';
import { Spinner } from '@/components/ui/spinner';

interface TutorAuthGuardProps {
  children: React.ReactNode;
}

export function TutorAuthGuard({ children }: TutorAuthGuardProps) {
  const router = useRouter();
  const { user, isAuthenticated, isLoading, loadUserFromToken } = useAuthStore();

  useEffect(() => {
    // Load user from token if not already loaded
    if (!user && !isLoading) {
      loadUserFromToken();
    }
  }, [user, isLoading, loadUserFromToken]);

  useEffect(() => {
    // Redirect if not authenticated
    if (!isLoading && !isAuthenticated) {
      router.push('/auth/login?redirect=/tutor');
      return;
    }

    // Check if user has tutor role
    if (!isLoading && isAuthenticated && user) {
      const hasPermission = user.roles.includes('tutor' as UserRole) || 
                           user.roles.includes('admin' as UserRole);
      
      if (!hasPermission) {
        router.push('/dashboard?error=tutor_access_required');
        return;
      }
    }
  }, [isLoading, isAuthenticated, user, router]);

  // Show loading spinner while checking authentication
  if (isLoading || !isAuthenticated || !user) {
    return (
      <div className="min-h-screen bg-stone-50 dark:bg-stone-900 flex items-center justify-center">
        <div className="text-center">
          <Spinner size="lg" />
          <p className="mt-4 text-stone-600 dark:text-stone-400">
            Verificando accesso tutor...
          </p>
        </div>
      </div>
    );
  }

  // Check if user has required permissions
  const hasPermission = user.roles.includes('tutor' as UserRole) || 
                       user.roles.includes('admin' as UserRole);

  if (!hasPermission) {
    return (
      <div className="min-h-screen bg-stone-50 dark:bg-stone-900 flex items-center justify-center">
        <div className="text-center max-w-md mx-auto p-6">
          <div className="text-6xl mb-4">🚫</div>
          <h1 className="text-2xl font-bold text-stone-900 dark:text-stone-100 mb-2">
            Accesso Negato
          </h1>
          <p className="text-stone-600 dark:text-stone-400 mb-6">
            Per accedere alla dashboard tutor devi essere registrato come tutor sulla piattaforma.
          </p>
          <button
            onClick={() => router.push('/dashboard')}
            className="bg-amber-600 text-white px-6 py-3 rounded-lg hover:bg-amber-700 transition-colors"
          >
            Torna alla Dashboard
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
} 