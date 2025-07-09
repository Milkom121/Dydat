export type UserRole = 'guest' | 'student' | 'creator' | 'tutor' | 'member' | 'manager' | 'admin';

export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  primaryRole: UserRole;
  roles: UserRole[];
  organizations: Organization[];
  level: number;
  xp: number;
  neurons: number;
  badges: Badge[];
}

export interface Organization {
  id: string;
  name: string;
  type: 'company' | 'institute';
  role: 'member' | 'manager' | 'admin';
  logo?: string;
}

export interface Badge {
  id: string;
  name: string;
  description: string;
  icon: string;
  earnedAt: Date;
}

export interface RolePermissions {
  canCreateCourses: boolean;
  canOfferTutoring: boolean;
  canManageOrganization: boolean;
  canAccessAnalytics: boolean;
  canCommissionCourses: boolean;
  canManageUsers: boolean;
  canAccessPrivateCourses: boolean;
}

export const getRolePermissions = (roles: UserRole[]): RolePermissions => {
  const hasRole = (role: UserRole) => roles.includes(role);
  
  return {
    canCreateCourses: hasRole('creator'),
    canOfferTutoring: hasRole('tutor'),
    canManageOrganization: hasRole('manager') || hasRole('admin'),
    canAccessAnalytics: hasRole('creator') || hasRole('manager') || hasRole('admin'),
    canCommissionCourses: hasRole('admin'),
    canManageUsers: hasRole('admin'),
    canAccessPrivateCourses: hasRole('member') || hasRole('manager') || hasRole('admin')
  };
};

export const getRoleDisplayName = (role: UserRole): string => {
  const roleNames = {
    guest: 'Ospite',
    student: 'Studente',
    creator: 'Creatore',
    tutor: 'Tutor',
    member: 'Membro Team',
    manager: 'Manager',
    admin: 'Amministratore'
  };
  return roleNames[role];
};

export const getRoleColor = (role: UserRole): string => {
  const roleColors = {
    guest: 'from-stone-400 to-stone-500',
    student: 'from-blue-400 to-blue-500',
    creator: 'from-purple-400 to-purple-500',
    tutor: 'from-emerald-400 to-emerald-500',
    member: 'from-amber-400 to-amber-500',
    manager: 'from-orange-400 to-orange-500',
    admin: 'from-red-400 to-red-500'
  };
  return roleColors[role];
};