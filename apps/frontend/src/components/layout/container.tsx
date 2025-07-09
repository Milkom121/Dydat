/**
 * Container Component - Dydat Design System
 * Responsive container with max-width constraints and padding options
 */

'use client';

import * as React from 'react';
import { cn } from '@/lib/utils';
import { cva, type VariantProps } from 'class-variance-authority';

const containerVariants = cva(
  'mx-auto w-full',
  {
    variants: {
      size: {
        sm: 'max-w-screen-sm',
        md: 'max-w-screen-md',
        lg: 'max-w-screen-lg',
        xl: 'max-w-screen-xl',
        '2xl': 'max-w-screen-2xl',
        '3xl': 'max-w-[1600px]',
        '4xl': 'max-w-[1800px]',
        full: 'max-w-full',
        none: 'max-w-none',
      },
      padding: {
        none: 'px-0',
        sm: 'px-4 sm:px-6',
        md: 'px-4 sm:px-6 lg:px-8',
        lg: 'px-6 sm:px-8 lg:px-12',
        xl: 'px-8 sm:px-12 lg:px-16',
      },
      centered: {
        true: 'mx-auto',
        false: 'ml-0 mr-0',
      },
    },
    defaultVariants: {
      size: 'xl',
      padding: 'md',
      centered: true,
    },
  }
);

interface ContainerProps 
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof containerVariants> {
  as?: React.ElementType;
}

const Container = React.forwardRef<HTMLDivElement, ContainerProps>(
  ({ className, size, padding, centered, as: Component = 'div', ...props }, ref) => {
    return (
      <Component
        className={cn(containerVariants({ size, padding, centered, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);

Container.displayName = 'Container';

export { Container, containerVariants };
export type { ContainerProps }; 