/**
 * @fileoverview Componente RoleSwitcher
 * Permette all'utente di cambiare ruolo attivo con dropdown elegante
 */

'use client';

import React, { useState } from 'react';
import { ChevronDown, Check, User, PenTool, GraduationCap, Users, Building, Settings, Crown } from 'lucide-react';
import { useUserRoles } from '../../hooks/useUserRoles';
import { UserRole, getRoleDisplayName, getRoleColor, getRoleDescription } from '../../types/auth';

/**
 * Componente per il cambio ruolo utente
 */
export const RoleSwitcher: React.FC = () => {
  const { currentRole, availableRoles, switchRole, user } = useUserRoles();
  const [isOpen, setIsOpen] = useState(false);

  if (!user || availableRoles.length <= 1) {
    return null;
  }

  /**
   * Ottiene l'icona per il ruolo
   */
  const getRoleIcon = (role: UserRole) => {
    const iconMap = {
      guest: User,
      student: GraduationCap,
      creator: PenTool,
      tutor: Users,
      member: Building,
      manager: Settings,
      admin: Crown
    };
    return iconMap[role] || User;
  };

  /**
   * Gestisce il cambio ruolo
   */
  const handleRoleChange = (role: UserRole) => {
    switchRole(role);
    setIsOpen(false);
  };

  const CurrentRoleIcon = getRoleIcon(currentRole);

  return (
    <div className="relative">
      {/* Trigger Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center space-x-2 px-3 py-2 rounded-lg bg-stone-50 dark:bg-stone-800 hover:bg-stone-100 dark:hover:bg-stone-700 transition-colors border border-stone-200 dark:border-stone-700 focus-visible"
        aria-label="Switch role"
      >
        <div className={`w-6 h-6 rounded-full bg-gradient-to-r ${getRoleColor(currentRole)} flex items-center justify-center`}>
          <CurrentRoleIcon className="w-3 h-3 text-white" />
        </div>
        <span className="text-sm font-medium text-stone-900 dark:text-stone-100 hidden sm:block">
          {getRoleDisplayName(currentRole)}
        </span>
        <ChevronDown className={`w-4 h-4 text-stone-600 dark:text-stone-400 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
      </button>

      {/* Dropdown Menu */}
      {isOpen && (
        <>
          {/* Overlay */}
          <div 
            className="fixed inset-0 z-40" 
            onClick={() => setIsOpen(false)}
          />
          
          {/* Dropdown Content */}
          <div className="absolute right-0 top-full mt-2 w-72 bg-white dark:bg-stone-900 rounded-xl shadow-strong border border-stone-200 dark:border-stone-800 py-2 z-50">
            <div className="px-4 py-2 border-b border-stone-200 dark:border-stone-800">
              <h3 className="font-semibold text-stone-900 dark:text-stone-100 text-sm">
                Cambia Ruolo
              </h3>
              <p className="text-xs text-stone-600 dark:text-stone-400 mt-1">
                Seleziona il ruolo con cui vuoi operare
              </p>
            </div>
            
            <div className="py-2">
              {availableRoles.map((role) => {
                const RoleIcon = getRoleIcon(role);
                const isSelected = role === currentRole;
                
                return (
                  <button
                    key={role}
                    onClick={() => handleRoleChange(role)}
                    className={`w-full px-4 py-3 flex items-center space-x-3 hover:bg-stone-50 dark:hover:bg-stone-800 transition-colors ${
                      isSelected ? 'bg-amber-50 dark:bg-amber-900/20' : ''
                    }`}
                  >
                    <div className={`w-8 h-8 rounded-full bg-gradient-to-r ${getRoleColor(role)} flex items-center justify-center flex-shrink-0`}>
                      <RoleIcon className="w-4 h-4 text-white" />
                    </div>
                    
                    <div className="flex-1 text-left">
                      <div className="flex items-center justify-between">
                        <span className={`text-sm font-medium ${
                          isSelected 
                            ? 'text-amber-700 dark:text-amber-300' 
                            : 'text-stone-900 dark:text-stone-100'
                        }`}>
                          {getRoleDisplayName(role)}
                        </span>
                        {isSelected && (
                          <Check className="w-4 h-4 text-amber-600 dark:text-amber-400" />
                        )}
                      </div>
                      <p className="text-xs text-stone-600 dark:text-stone-400 mt-1">
                        {getRoleDescription(role)}
                      </p>
                    </div>
                  </button>
                );
              })}
            </div>
            
            {/* Role Info */}
            <div className="px-4 py-2 border-t border-stone-200 dark:border-stone-800">
              <div className="flex items-center space-x-2 text-xs text-stone-600 dark:text-stone-400">
                <div className={`w-3 h-3 rounded-full bg-gradient-to-r ${getRoleColor(currentRole)}`} />
                <span>
                  Ruolo attivo: <span className="font-medium">{getRoleDisplayName(currentRole)}</span>
                </span>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}; 