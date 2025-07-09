import { useState, useEffect } from 'react';
import { User, UserRole, getRolePermissions, RolePermissions } from '../types/roles';

// Mock user data - in a real app this would come from authentication context
const mockUser: User = {
  id: '1',
  name: 'Marco Rossi',
  email: 'marco.rossi@email.com',
  avatar: 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop',
  primaryRole: 'student',
  roles: ['student', 'creator', 'tutor'],
  organizations: [
    {
      id: '1',
      name: 'TechCorp Italia',
      type: 'company',
      role: 'member',
      logo: 'https://images.pexels.com/photos/267350/pexels-photo-267350.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&fit=crop'
    }
  ],
  level: 12,
  xp: 2850,
  neurons: 1250,
  badges: [
    {
      id: '1',
      name: 'Primo Corso Completato',
      description: 'Hai completato il tuo primo corso!',
      icon: '🎓',
      earnedAt: new Date('2024-01-15')
    },
    {
      id: '2',
      name: 'Creatore Emergente',
      description: 'Hai pubblicato il tuo primo corso',
      icon: '🚀',
      earnedAt: new Date('2024-02-20')
    }
  ]
};

export const useUserRoles = () => {
  const [user, setUser] = useState<User | null>(null);
  const [currentRole, setCurrentRole] = useState<UserRole>('student');
  const [permissions, setPermissions] = useState<RolePermissions>(getRolePermissions([]));
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Simulate loading user data
    setIsLoading(true);
    setUser(mockUser);
    setCurrentRole(mockUser.primaryRole);
    setPermissions(getRolePermissions(mockUser.roles));
    setIsLoading(false);
    console.log('User loaded:', mockUser);
  }, []);

  const switchRole = (role: UserRole) => {
    if (user && user.roles.includes(role)) {
      console.log('Switching from', currentRole, 'to', role);
      setCurrentRole(role);
      // Permissions stay the same since they're based on all user roles
      setPermissions(getRolePermissions(user.roles));
    }
  };

  const hasRole = (role: UserRole): boolean => {
    return user?.roles.includes(role) || false;
  };

  const hasPermission = (permission: keyof RolePermissions): boolean => {
    return permissions[permission];
  };

  return {
    user,
    currentRole,
    permissions,
    isLoading,
    switchRole,
    hasRole,
    hasPermission,
    availableRoles: user?.roles || []
  };
};