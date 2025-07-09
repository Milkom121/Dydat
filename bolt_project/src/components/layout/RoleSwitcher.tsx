import React, { useState } from 'react';
import { ChevronDown, User, Crown, GraduationCap, Users, Building, Zap } from 'lucide-react';
import { UserRole, getRoleDisplayName, getRoleColor } from '../../types/roles';
import { useUserRoles } from '../../hooks/useUserRoles';

export const RoleSwitcher: React.FC = () => {
  const { user, currentRole, availableRoles, switchRole } = useUserRoles();
  const [isOpen, setIsOpen] = useState(false);

  if (!user || availableRoles.length <= 1) return null;

  const getRoleIcon = (role: UserRole) => {
    const icons = {
      guest: User,
      student: GraduationCap,
      creator: Zap,
      tutor: Users,
      member: Building,
      manager: Crown,
      admin: Crown
    };
    return icons[role];
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center space-x-3 px-4 py-2 bg-white/90 dark:bg-stone-800/90 backdrop-blur-sm border border-stone-200/50 dark:border-stone-700/50 rounded-xl hover:bg-white dark:hover:bg-stone-800 transition-all duration-200 shadow-sm"
      >
        <div className={`p-2 rounded-lg bg-gradient-to-r ${getRoleColor(currentRole)}`}>
          {React.createElement(getRoleIcon(currentRole), { 
            className: "w-4 h-4 text-white" 
          })}
        </div>
        <div className="text-left">
          <div className="text-sm font-medium text-stone-900 dark:text-stone-100">
            {getRoleDisplayName(currentRole)}
          </div>
          <div className="text-xs text-stone-500 dark:text-stone-500">
            Cambia ruolo
          </div>
        </div>
        <ChevronDown className={`w-4 h-4 text-stone-500 transition-transform duration-200 ${
          isOpen ? 'rotate-180' : ''
        }`} />
      </button>

      {isOpen && (
        <>
          <div 
            className="fixed inset-0 z-40" 
            onClick={() => setIsOpen(false)}
          />
          <div className="absolute top-full left-0 mt-2 w-64 bg-white/95 dark:bg-stone-900/95 backdrop-blur-sm border border-stone-200/50 dark:border-stone-800/50 rounded-2xl shadow-xl z-50 overflow-hidden">
            <div className="p-4 border-b border-stone-200/50 dark:border-stone-800/50">
              <h3 className="font-semibold text-stone-900 dark:text-stone-100 mb-1">
                I Tuoi Ruoli
              </h3>
              <p className="text-xs text-stone-500 dark:text-stone-500">
                Seleziona il ruolo attivo per accedere alle funzionalità specifiche
              </p>
            </div>
            
            <div className="p-2">
              {availableRoles.map((role) => {
                const Icon = getRoleIcon(role);
                const isActive = role === currentRole;
                
                return (
                  <button
                    key={role}
                    onClick={() => {
                      switchRole(role);
                      setIsOpen(false);
                    }}
                    className={`w-full flex items-center space-x-3 p-3 rounded-xl transition-all duration-200 ${
                      isActive
                        ? 'bg-gradient-to-r from-amber-50 to-orange-50 dark:from-amber-900/20 dark:to-orange-900/20 border-2 border-amber-200 dark:border-amber-700'
                        : 'hover:bg-stone-50 dark:hover:bg-stone-800/50'
                    }`}
                  >
                    <div className={`p-2 rounded-lg bg-gradient-to-r ${getRoleColor(role)} ${
                      isActive ? 'shadow-lg' : ''
                    }`}>
                      <Icon className="w-4 h-4 text-white" />
                    </div>
                    <div className="flex-1 text-left">
                      <div className={`font-medium ${
                        isActive 
                          ? 'text-amber-700 dark:text-amber-300' 
                          : 'text-stone-900 dark:text-stone-100'
                      }`}>
                        {getRoleDisplayName(role)}
                      </div>
                      <div className="text-xs text-stone-500 dark:text-stone-500">
                        {role === 'student' && 'Accesso base alla piattaforma'}
                        {role === 'creator' && 'Crea e pubblica corsi'}
                        {role === 'tutor' && 'Offri tutoraggio nel mercatino'}
                        {role === 'member' && 'Membro di organizzazione'}
                        {role === 'manager' && 'Gestisci team e progetti'}
                        {role === 'admin' && 'Controllo completo organizzazione'}
                      </div>
                    </div>
                    {isActive && (
                      <div className="w-2 h-2 bg-gradient-to-r from-amber-400 to-orange-500 rounded-full"></div>
                    )}
                  </button>
                );
              })}
            </div>

            {user.organizations.length > 0 && (
              <>
                <div className="border-t border-stone-200/50 dark:border-stone-800/50 p-4">
                  <h4 className="font-medium text-stone-900 dark:text-stone-100 mb-3 text-sm">
                    Le Tue Organizzazioni
                  </h4>
                  <div className="space-y-2">
                    {user.organizations.map((org) => (
                      <div key={org.id} className="flex items-center space-x-3 p-2 rounded-lg bg-stone-50/50 dark:bg-stone-800/50">
                        <img 
                          src={org.logo} 
                          alt={org.name}
                          className="w-8 h-8 rounded-lg object-cover"
                        />
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-medium text-stone-900 dark:text-stone-100 truncate">
                            {org.name}
                          </div>
                          <div className="text-xs text-stone-500 dark:text-stone-500">
                            {getRoleDisplayName(org.role)}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </>
            )}
          </div>
        </>
      )}
    </div>
  );
};