/**
 * @fileoverview Hook per la gestione del dark mode
 * Gestisce il tema dell'applicazione con persistenza e preferenze sistema
 */

import { useState, useEffect } from 'react';

/**
 * Hook per la gestione del dark mode
 * Integra localStorage e preferenze di sistema
 */
export const useDarkMode = () => {
  // Inizializziamo con false per evitare hydration mismatch
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isHydrated, setIsHydrated] = useState(false);

  // Hydration: carica la preferenza effettiva dopo il mount
  useEffect(() => {
    if (typeof window !== 'undefined') {
      // Controlla prima il localStorage
      const savedMode = localStorage.getItem('darkMode');
      if (savedMode !== null) {
        setIsDarkMode(savedMode === 'true');
      } else {
        // Se non c'è una preferenza salvata, usa quella del sistema
        setIsDarkMode(window.matchMedia('(prefers-color-scheme: dark)').matches);
      }
      setIsHydrated(true);
    }
  }, []);

  useEffect(() => {
    if (!isHydrated) return;
    
    const root = window.document.documentElement;
    
    if (isDarkMode) {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    
    // Salva la preferenza nel localStorage
    localStorage.setItem('darkMode', isDarkMode.toString());
  }, [isDarkMode, isHydrated]);

  // Ascolta i cambiamenti delle preferenze di sistema
  useEffect(() => {
    if (!isHydrated) return;
    
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = (e: MediaQueryListEvent) => {
      // Aggiorna solo se non c'è una preferenza esplicita salvata
      const savedMode = localStorage.getItem('darkMode');
      if (savedMode === null) {
        setIsDarkMode(e.matches);
      }
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, [isHydrated]);

  const toggleDarkMode = () => {
    setIsDarkMode(!isDarkMode);
  };

  const setDarkMode = (enabled: boolean) => {
    setIsDarkMode(enabled);
  };

  const resetToSystem = () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('darkMode');
      const systemPreference = window.matchMedia('(prefers-color-scheme: dark)').matches;
      setIsDarkMode(systemPreference);
    }
  };

  return {
    isDarkMode,
    toggleDarkMode,
    setDarkMode,
    resetToSystem,
    isHydrated
  };
}; 