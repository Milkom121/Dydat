'use client';

import { useState, useEffect } from 'react';
import { TutorSidebar } from './TutorSidebar';
import { TutorHeader } from './TutorHeader';
import { cn } from '@/lib/utils';

interface TutorLayoutProps {
  children: React.ReactNode;
}

export function TutorLayout({ children }: TutorLayoutProps) {
  const [isMobile, setIsMobile] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  useEffect(() => {
    const checkScreenSize = () => {
      setIsMobile(window.innerWidth < 1024);
      // Auto-collapse sidebar on medium screens
      if (window.innerWidth < 1280) {
        setSidebarCollapsed(true);
      } else {
        setSidebarCollapsed(false);
      }
    };

    // Check on mount
    checkScreenSize();

    // Listen for resize
    window.addEventListener('resize', checkScreenSize);
    return () => window.removeEventListener('resize', checkScreenSize);
  }, []);

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-stone-900">
      <div className="flex">
        {/* Sidebar */}
        <TutorSidebar />
        
        {/* Main Content */}
        <div className={cn(
          "flex-1 transition-all duration-300 ease-in-out",
          "lg:ml-64" // Always account for sidebar on large screens
        )}>
          <TutorHeader />
          
          {/* Content Area */}
          <main className={cn(
            "transition-all duration-300",
            // Responsive padding
            "p-4 sm:p-6 lg:p-8",
            // Max width for very large screens
            "max-w-full"
          )}>
            {/* Content wrapper with responsive grid */}
            <div className="w-full">
              {children}
            </div>
          </main>
        </div>
      </div>
    </div>
  );
} 