/**
 * @fileoverview Hook per la gestione dei ruoli utente
 * Gestisce autenticazione, ruoli, permessi e cambio ruolo
 */

import { useState, useEffect } from 'react';
import { User, UserRole, getRolePermissions, RolePermissions } from '../types/auth';

// Mock user data - in produzione verrebbe da context di autenticazione
const mockUser: User = {
  id: '1',
  name: 'Marco Rossi',
  email: 'marco.rossi@dydat.com',
  avatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
  bio: 'Appassionato di tecnologia e apprendimento continuo. Creatore di corsi e tutor esperto in sviluppo web.',
  location: 'Milano, Italia',
  website: 'https://marcorossi.dev',
  
  // Sistema ruoli
  primaryRole: 'student',
  roles: ['student', 'creator', 'tutor'],
  
  // Organizzazioni
  organizations: [
    {
      id: '1',
      name: 'TechCorp Italia',
      type: 'company',
      role: 'member',
      logo: 'https://images.pexels.com/photos/267350/pexels-photo-267350.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      description: 'Azienda leader nel settore tecnologico',
      website: 'https://techcorp.it',
      createdAt: new Date('2023-01-15'),
      updatedAt: new Date('2024-01-15')
    },
    {
      id: '2',
      name: 'Università Statale Milano',
      type: 'institute',
      role: 'manager',
      logo: 'https://images.pexels.com/photos/256490/pexels-photo-256490.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
      description: 'Istituto di alta formazione',
      website: 'https://unimi.it',
      createdAt: new Date('2023-06-01'),
      updatedAt: new Date('2024-01-15')
    }
  ],
  
  // Sistema gamification
  level: 12,
  xp: 2850,
  neurons: 1250,
  badges: [
    {
      id: '1',
      name: 'Primo Corso Completato',
      description: 'Hai completato il tuo primo corso!',
      icon: '🎓',
      category: 'learning',
      rarity: 'common',
      xpReward: 100,
      earnedAt: new Date('2024-01-15')
    },
    {
      id: '2',
      name: 'Creatore Emergente',
      description: 'Hai pubblicato il tuo primo corso',
      icon: '🚀',
      category: 'teaching',
      rarity: 'uncommon',
      xpReward: 250,
      earnedAt: new Date('2024-02-20')
    },
    {
      id: '3',
      name: 'Tutor Esperto',
      description: 'Hai completato 50 sessioni di tutoring',
      icon: '👨‍🏫',
      category: 'teaching',
      rarity: 'rare',
      xpReward: 500,
      earnedAt: new Date('2024-03-10')
    }
  ],
  
  // Preferenze (mock)
  preferences: {
    theme: 'system',
    language: 'it',
    notifications: {
      email: true,
      push: true,
      courseUpdates: true,
      tutoringReminders: true,
      achievementAlerts: true,
      marketplaceUpdates: false
    },
    privacy: {
      profileVisibility: 'public',
      showEmail: false,
      showLocation: true,
      showLearningProgress: true
    },
    learning: {
      difficultyLevel: 'intermediate',
      learningStyle: 'visual',
      studyReminders: true,
      autoPlayVideos: true,
      subtitles: true
    }
  },
  
  // Metadata
  isEmailVerified: true,
  isActive: true,
  lastLoginAt: new Date('2024-01-15T10:30:00'),
  createdAt: new Date('2023-01-15'),
  updatedAt: new Date('2024-01-15')
};

/**
 * Hook per la gestione dei ruoli utente
 */
export const useUserRoles = () => {
  const [user, setUser] = useState<User | null>(null);
  const [currentRole, setCurrentRole] = useState<UserRole>('student');
  const [permissions, setPermissions] = useState<RolePermissions>(getRolePermissions([]));
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simula il caricamento dei dati utente
    const loadUser = async () => {
      setIsLoading(true);
      
      try {
        // Simula una chiamata API
        await new Promise(resolve => setTimeout(resolve, 500));
        
        setUser(mockUser);
        setCurrentRole(mockUser.primaryRole);
        setPermissions(getRolePermissions(mockUser.roles));
        
        console.log('User loaded:', mockUser);
        console.log('Permissions:', getRolePermissions(mockUser.roles));
      } catch (error) {
        console.error('Error loading user:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadUser();
  }, []);

  useEffect(() => {
    // Carica la preferenza del ruolo selezionato dall'utente
    if (typeof window !== 'undefined') {
      const savedRole = localStorage.getItem('selectedRole');
      if (savedRole && user?.roles.includes(savedRole as UserRole)) {
        setCurrentRole(savedRole as UserRole);
        setPermissions(getRolePermissions(user.roles));
      }
    }
  }, [user]);

  /**
   * Cambia il ruolo attivo dell'utente
   */
  const switchRole = (role: UserRole) => {
    if (user && user.roles.includes(role)) {
      console.log('Switching from', currentRole, 'to', role);
      setCurrentRole(role);
      
      // I permessi rimangono gli stessi perché sono basati su tutti i ruoli dell'utente
      setPermissions(getRolePermissions(user.roles));
      
      // In produzione, qui si potrebbe salvare la preferenza
      // Uso un useEffect separato per evitare hydration issues
      if (typeof window !== 'undefined') {
        localStorage.setItem('selectedRole', role);
      }
    } else {
      console.warn('User does not have role:', role);
    }
  };

  /**
   * Controlla se l'utente ha un ruolo specifico
   */
  const hasRole = (role: UserRole): boolean => {
    return user?.roles.includes(role) || false;
  };

  /**
   * Controlla se l'utente ha un permesso specifico
   */
  const hasPermission = (permission: keyof RolePermissions): boolean => {
    return permissions[permission];
  };

  /**
   * Ottiene i ruoli disponibili per l'utente
   */
  const getAvailableRoles = (): UserRole[] => {
    return user?.roles || [];
  };

  /**
   * Controlla se l'utente è membro di un'organizzazione
   */
  const isOrganizationMember = (organizationId?: string): boolean => {
    if (!user?.organizations.length) return false;
    
    if (organizationId) {
      return user.organizations.some(org => org.id === organizationId);
    }
    
    return user.organizations.length > 0;
  };

  /**
   * Ottiene il ruolo dell'utente in un'organizzazione specifica
   */
  const getOrganizationRole = (organizationId: string): 'member' | 'manager' | 'admin' | null => {
    const org = user?.organizations.find(org => org.id === organizationId);
    return org?.role || null;
  };

  /**
   * Calcola il progresso verso il prossimo livello
   */
  const getLevelProgress = (): { current: number; next: number; progress: number } => {
    if (!user) return { current: 0, next: 0, progress: 0 };
    
    const xpPerLevel = 250; // XP necessari per livello
    const currentLevelXp = (user.level - 1) * xpPerLevel;
    const nextLevelXp = user.level * xpPerLevel;
    const progress = ((user.xp - currentLevelXp) / xpPerLevel) * 100;
    
    return {
      current: user.level,
      next: user.level + 1,
      progress: Math.min(progress, 100)
    };
  };

  /**
   * Aggiorna le preferenze utente
   */
  const updatePreferences = (preferences: Partial<typeof mockUser.preferences>) => {
    if (!user) return;
    
    const updatedUser = {
      ...user,
      preferences: {
        ...user.preferences,
        ...preferences
      }
    };
    
    setUser(updatedUser);
    
    // In produzione, qui si farebbe una chiamata API
    console.log('Preferences updated:', preferences);
  };

  /**
   * Logout dell'utente
   */
  const logout = () => {
    setUser(null);
    setCurrentRole('guest');
    setPermissions(getRolePermissions([]));
    localStorage.removeItem('selectedRole');
    
    // In produzione, qui si farebbe il logout dal server
    console.log('User logged out');
  };

  return {
    // Stato
    user,
    currentRole,
    permissions,
    isLoading,
    
    // Funzioni ruoli
    switchRole,
    hasRole,
    hasPermission,
    availableRoles: getAvailableRoles(),
    
    // Funzioni organizzazioni
    isOrganizationMember,
    getOrganizationRole,
    
    // Funzioni gamification
    getLevelProgress,
    
    // Funzioni preferenze
    updatePreferences,
    
    // Funzioni autenticazione
    logout
  };
}; 