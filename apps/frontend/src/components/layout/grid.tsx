/**
 * Grid Component - Dydat Design System
 * Responsive grid system with configurable columns and gaps
 */

'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { cva, type VariantProps } from 'class-variance-authority';

const gridVariants = cva(
  'grid w-full',
  {
    variants: {
      cols: {
        1: 'grid-cols-1',
        2: 'grid-cols-2',
        3: 'grid-cols-3',
        4: 'grid-cols-4',
        5: 'grid-cols-5',
        6: 'grid-cols-6',
        7: 'grid-cols-7',
        8: 'grid-cols-8',
        9: 'grid-cols-9',
        10: 'grid-cols-10',
        11: 'grid-cols-11',
        12: 'grid-cols-12',
        none: 'grid-cols-none',
      },
      gap: {
        0: 'gap-0',
        1: 'gap-1',
        2: 'gap-2',
        3: 'gap-3',
        4: 'gap-4',
        5: 'gap-5',
        6: 'gap-6',
        7: 'gap-7',
        8: 'gap-8',
        10: 'gap-10',
        12: 'gap-12',
        16: 'gap-16',
        20: 'gap-20',
        24: 'gap-24',
      },
      rows: {
        1: 'grid-rows-1',
        2: 'grid-rows-2',
        3: 'grid-rows-3',
        4: 'grid-rows-4',
        5: 'grid-rows-5',
        6: 'grid-rows-6',
        none: 'grid-rows-none',
      },
    },
    defaultVariants: {
      cols: 1,
      gap: 4,
      rows: 'none',
    },
  }
);

interface GridProps 
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof gridVariants> {
  as?: React.ElementType;
  // Responsive breakpoints
  sm?: VariantProps<typeof gridVariants>['cols'];
  md?: VariantProps<typeof gridVariants>['cols'];
  lg?: VariantProps<typeof gridVariants>['cols'];
  xl?: VariantProps<typeof gridVariants>['cols'];
  '2xl'?: VariantProps<typeof gridVariants>['cols'];
}

const Grid = React.forwardRef<HTMLDivElement, GridProps>(
  ({ 
    className, 
    cols, 
    gap, 
    rows, 
    sm, 
    md, 
    lg, 
    xl, 
    '2xl': xl2,
    as: Component = 'div', 
    ...props 
  }, ref) => {
    // Build responsive classes
    const responsiveClasses = [
      sm && `sm:grid-cols-${sm}`,
      md && `md:grid-cols-${md}`,
      lg && `lg:grid-cols-${lg}`,
      xl && `xl:grid-cols-${xl}`,
      xl2 && `2xl:grid-cols-${xl2}`,
    ].filter(Boolean).join(' ');

    return (
      <Component
        className={cn(
          gridVariants({ cols, gap, rows }),
          responsiveClasses,
          className
        )}
        ref={ref}
        {...props}
      />
    );
  }
);

Grid.displayName = 'Grid';

// Grid Item Component
interface GridItemProps extends React.HTMLAttributes<HTMLDivElement> {
  as?: React.ElementType;
  span?: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 'full';
  start?: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 'auto';
  end?: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 'auto';
  rowSpan?: 1 | 2 | 3 | 4 | 5 | 6 | 'full';
  rowStart?: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 'auto';
  rowEnd?: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 'auto';
}

const GridItem = React.forwardRef<HTMLDivElement, GridItemProps>(
  ({ 
    className, 
    span, 
    start, 
    end, 
    rowSpan, 
    rowStart, 
    rowEnd,
    as: Component = 'div', 
    ...props 
  }, ref) => {
    const spanClasses = [
      span && (span === 'full' ? 'col-span-full' : `col-span-${span}`),
      start && (start === 'auto' ? 'col-start-auto' : `col-start-${start}`),
      end && (end === 'auto' ? 'col-end-auto' : `col-end-${end}`),
      rowSpan && (rowSpan === 'full' ? 'row-span-full' : `row-span-${rowSpan}`),
      rowStart && (rowStart === 'auto' ? 'row-start-auto' : `row-start-${rowStart}`),
      rowEnd && (rowEnd === 'auto' ? 'row-end-auto' : `row-end-${rowEnd}`),
    ].filter(Boolean).join(' ');

    return (
      <Component
        className={cn(spanClasses, className)}
        ref={ref}
        {...props}
      />
    );
  }
);

GridItem.displayName = 'GridItem';

export { Grid, GridItem, gridVariants };
export type { GridProps, GridItemProps }; 