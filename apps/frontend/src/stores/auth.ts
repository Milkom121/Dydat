/**
 * Authentication Store using Zustand
 * Manages user authentication state and API integration
 */

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import api from '@/lib/api';
import { AUTH_ENDPOINTS, STORAGE_KEYS } from '@/constants/api';
import { UserRole } from '@/types/auth';
import type { 
  AuthStore, 
  User, 
  LoginDto, 
  RegisterDto, 
  UpdateProfileDto, 
  ChangePasswordDto,
  AuthResponse,
  UserPermissions
} from '@/types/auth';

// Initial state
const initialState = {
  user: null,
  token: null,
  isLoading: false,
  isAuthenticated: false,
};

// Create the auth store
export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      ...initialState,

      // Login action
      login: async (credentials: LoginDto) => {
        set({ isLoading: true });
        try {
          const response = await api.post<AuthResponse>(AUTH_ENDPOINTS.LOGIN, credentials);
          
          // Store token and user data
          const { token, user } = response;
          
          // Update store state
          set({
            user,
            token,
            isAuthenticated: true,
            isLoading: false,
          });

          // Store in localStorage
          if (typeof window !== 'undefined') {
            localStorage.setItem(STORAGE_KEYS.ACCESS_TOKEN, token);
            localStorage.setItem(STORAGE_KEYS.USER_DATA, JSON.stringify(user));
          }

          console.log('✅ Login successful:', user.email);
        } catch (error) {
          set({ isLoading: false });
          console.error('❌ Login failed:', error);
          throw error;
        }
      },

      // Register action
      register: async (userData: RegisterDto) => {
        set({ isLoading: true });
        try {
          const response = await api.post<AuthResponse>(AUTH_ENDPOINTS.REGISTER, userData);
          
          // Store token and user data
          const { token, user } = response;
          
          // Update store state
          set({
            user,
            token,
            isAuthenticated: true,
            isLoading: false,
          });

          // Store in localStorage
          if (typeof window !== 'undefined') {
            localStorage.setItem(STORAGE_KEYS.ACCESS_TOKEN, token);
            localStorage.setItem(STORAGE_KEYS.USER_DATA, JSON.stringify(user));
          }

          console.log('✅ Registration successful:', user.email);
        } catch (error) {
          set({ isLoading: false });
          console.error('❌ Registration failed:', error);
          throw error;
        }
      },

      // Logout action
      logout: () => {
        // Clear store state
        set(initialState);

        // Clear localStorage
        if (typeof window !== 'undefined') {
          localStorage.removeItem(STORAGE_KEYS.ACCESS_TOKEN);
          localStorage.removeItem(STORAGE_KEYS.REFRESH_TOKEN);
          localStorage.removeItem(STORAGE_KEYS.USER_DATA);
        }

        console.log('✅ Logout successful');
      },

      // Update profile action
      updateProfile: async (data: UpdateProfileDto) => {
        const { user } = get();
        if (!user) throw new Error('User not authenticated');

        set({ isLoading: true });
        try {
          const updatedUser = await api.patch<User>(AUTH_ENDPOINTS.UPDATE_PROFILE, data);
          
          // Update store state
          set({
            user: updatedUser,
            isLoading: false,
          });

          // Update localStorage
          if (typeof window !== 'undefined') {
            localStorage.setItem(STORAGE_KEYS.USER_DATA, JSON.stringify(updatedUser));
          }

          console.log('✅ Profile updated successfully');
        } catch (error) {
          set({ isLoading: false });
          console.error('❌ Profile update failed:', error);
          throw error;
        }
      },

      // Change password action
      changePassword: async (data: ChangePasswordDto) => {
        set({ isLoading: true });
        try {
          await api.post(AUTH_ENDPOINTS.CHANGE_PASSWORD, data);
          set({ isLoading: false });
          console.log('✅ Password changed successfully');
        } catch (error) {
          set({ isLoading: false });
          console.error('❌ Password change failed:', error);
          throw error;
        }
      },

      // Delete account action
      deleteAccount: async () => {
        set({ isLoading: true });
        try {
          await api.delete(AUTH_ENDPOINTS.DELETE_ACCOUNT);
          
          // Clear state and storage after successful deletion
          get().logout();
          console.log('✅ Account deleted successfully');
        } catch (error) {
          set({ isLoading: false });
          console.error('❌ Account deletion failed:', error);
          throw error;
        }
      },

      // Load user from stored token
      loadUserFromToken: () => {
        if (typeof window === 'undefined') return;

        const token = localStorage.getItem(STORAGE_KEYS.ACCESS_TOKEN);
        const userData = localStorage.getItem(STORAGE_KEYS.USER_DATA);

        if (token && userData) {
          try {
            const user = JSON.parse(userData);
            set({
              user,
              token,
              isAuthenticated: true,
            });
            console.log('✅ User loaded from storage:', user.email);
          } catch (error) {
            console.error('❌ Failed to parse stored user data:', error);
            get().logout();
          }
        }
      },

      // Refresh token action (placeholder for future implementation)
      refreshToken: async () => {
        // TODO: Implement refresh token logic when backend supports it
        console.log('🔄 Refresh token not implemented yet');
      },
    }),
    {
      name: 'dydat-auth-store',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

// Helper hook to get user permissions
export const useUserPermissions = (): UserPermissions => {
  const user = useAuthStore((state) => state.user);
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);

  if (!user) {
    return {
      isAuthenticated: false,
      hasRole: () => false,
      hasAnyRole: () => false,
      hasAllRoles: () => false,
      // Corsi
      canCreateCourses: false,
      canEditOwnCourses: false,
      canDeleteOwnCourses: false,
      canPublishCourses: false,
      canAccessPrivateCourses: false,
      canCommissionCourses: false,
      // Tutoring
      canOfferTutoring: false,
      canBookTutoring: false,
      canManageTutoringSessions: false,
      canAccessTutorAnalytics: false,
      // Organizzazione
      canManageOrganization: false,
      canInviteMembers: false,
      canManageMembers: false,
      canAccessOrgAnalytics: false,
      // Sistema
      canAccessAnalytics: false,
      canManageUsers: false,
      canModerateContent: false,
      canAccessAdminPanel: false,
      // Marketplace
      canSellCourses: false,
      canBuyCourses: false,
      canRateAndReview: false,
      canReportContent: false,
    };
  }

  const hasRole = (role: UserRole) => user.roles.includes(role);
  const hasAnyRole = (roles: UserRole[]) => roles.some(role => user.roles.includes(role));
  const hasAllRoles = (roles: UserRole[]) => roles.every(role => user.roles.includes(role));

  return {
    isAuthenticated,
    hasRole,
    hasAnyRole,
    hasAllRoles,
    // Corsi
    canCreateCourses: hasRole('creator') || hasRole('admin'),
    canEditOwnCourses: hasRole('creator') || hasRole('admin'),
    canDeleteOwnCourses: hasRole('creator') || hasRole('admin'),
    canPublishCourses: hasRole('creator') || hasRole('admin'),
    canAccessPrivateCourses: hasRole('member') || hasRole('manager') || hasRole('admin'),
    canCommissionCourses: hasRole('manager') || hasRole('admin'),
    // Tutoring
    canOfferTutoring: hasRole('tutor') || hasRole('admin'),
    canBookTutoring: hasRole('student') || hasRole('member') || hasRole('admin'),
    canManageTutoringSessions: hasRole('tutor') || hasRole('admin'),
    canAccessTutorAnalytics: hasRole('tutor') || hasRole('admin'),
    // Organizzazione
    canManageOrganization: hasRole('manager') || hasRole('admin'),
    canInviteMembers: hasRole('manager') || hasRole('admin'),
    canManageMembers: hasRole('manager') || hasRole('admin'),
    canAccessOrgAnalytics: hasRole('manager') || hasRole('admin'),
    // Sistema
    canAccessAnalytics: hasRole('creator') || hasRole('tutor') || hasRole('manager') || hasRole('admin'),
    canManageUsers: hasRole('admin'),
    canModerateContent: hasRole('admin'),
    canAccessAdminPanel: hasRole('admin'),
    // Marketplace
    canSellCourses: hasRole('creator') || hasRole('admin'),
    canBuyCourses: !hasRole('guest'),
    canRateAndReview: hasRole('student') || hasRole('member') || hasRole('admin'),
    canReportContent: !hasRole('guest'),
  };
};

// Helper hooks for common auth checks
export const useIsAuthenticated = () => useAuthStore((state) => state.isAuthenticated);
export const useCurrentUser = () => useAuthStore((state) => state.user);
export const useAuthLoading = () => useAuthStore((state) => state.isLoading);

// Initialize auth store on client side
if (typeof window !== 'undefined') {
  useAuthStore.getState().loadUserFromToken();
} 