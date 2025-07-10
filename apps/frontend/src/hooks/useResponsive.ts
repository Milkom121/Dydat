/**
 * useResponsive Hook
 * Provides responsive utilities for the tutor interface
 */

import { useState, useEffect } from 'react';

export type BreakpointKey = 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';

const breakpoints = {
  xs: 0,
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  '2xl': 1536,
};

export interface ResponsiveState {
  width: number;
  height: number;
  isMobile: boolean;
  isTablet: boolean;
  isDesktop: boolean;
  isLarge: boolean;
  breakpoint: BreakpointKey;
  isBreakpoint: (bp: BreakpointKey) => boolean;
  isAbove: (bp: BreakpointKey) => boolean;
  isBelow: (bp: BreakpointKey) => boolean;
}

export function useResponsive(): ResponsiveState {
  const [windowSize, setWindowSize] = useState({
    width: typeof window !== 'undefined' ? window.innerWidth : 1024,
    height: typeof window !== 'undefined' ? window.innerHeight : 768,
  });

  useEffect(() => {
    if (typeof window === 'undefined') return;

    function handleResize() {
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    }

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const getCurrentBreakpoint = (width: number): BreakpointKey => {
    if (width >= breakpoints['2xl']) return '2xl';
    if (width >= breakpoints.xl) return 'xl';
    if (width >= breakpoints.lg) return 'lg';
    if (width >= breakpoints.md) return 'md';
    if (width >= breakpoints.sm) return 'sm';
    return 'xs';
  };

  const breakpoint = getCurrentBreakpoint(windowSize.width);

  return {
    width: windowSize.width,
    height: windowSize.height,
    isMobile: windowSize.width < breakpoints.md,
    isTablet: windowSize.width >= breakpoints.md && windowSize.width < breakpoints.lg,
    isDesktop: windowSize.width >= breakpoints.lg,
    isLarge: windowSize.width >= breakpoints.xl,
    breakpoint,
    isBreakpoint: (bp: BreakpointKey) => breakpoint === bp,
    isAbove: (bp: BreakpointKey) => windowSize.width >= breakpoints[bp],
    isBelow: (bp: BreakpointKey) => windowSize.width < breakpoints[bp],
  };
}

/**
 * Hook for responsive grid columns
 */
export function useResponsiveGrid() {
  const { isMobile, isTablet, isDesktop } = useResponsive();

  const getGridCols = (mobile: number, tablet: number, desktop: number) => {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  };

  return {
    getGridCols,
    statsGridCols: getGridCols(1, 2, 4), // Stats cards
    contentGridCols: getGridCols(1, 1, 2), // Main content sections
    cardGridCols: getGridCols(1, 2, 3), // Card listings
  };
}

/**
 * Hook for responsive spacing
 */
export function useResponsiveSpacing() {
  const { isMobile, isTablet } = useResponsive();

  return {
    container: isMobile ? 'p-4' : isTablet ? 'p-6' : 'p-8',
    section: isMobile ? 'space-y-4' : isTablet ? 'space-y-6' : 'space-y-8',
    card: isMobile ? 'p-4' : 'p-6',
    gap: isMobile ? 'gap-4' : isTablet ? 'gap-6' : 'gap-8',
  };
} 