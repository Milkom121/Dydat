/**
 * Spinner Component - Dydat Design System
 * Loading spinner with variants and dark mode support
 */

import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const spinnerVariants = cva(
  "animate-spin rounded-full border-2 border-solid",
  {
    variants: {
      variant: {
        default: "border-gray-200 dark:border-gray-700 border-t-primary-500",
        primary: "border-primary-200 dark:border-primary-800 border-t-primary-500",
        success: "border-success-200 dark:border-success-800 border-t-success-500",
        warning: "border-warning-200 dark:border-warning-800 border-t-warning-500",
        error: "border-error-200 dark:border-error-800 border-t-error-500",
        white: "border-white/20 border-t-white",
      },
      size: {
        xs: "h-3 w-3 border",
        sm: "h-4 w-4",
        default: "h-6 w-6",
        lg: "h-8 w-8 border-[3px]",
        xl: "h-12 w-12 border-4",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface SpinnerProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof spinnerVariants> {
  label?: string;
}

const Spinner = React.forwardRef<HTMLDivElement, SpinnerProps>(
  ({ className, variant, size, label, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn("inline-block", className)}
        role="status"
        aria-label={label || "Loading"}
        {...props}
      >
        <div className={cn(spinnerVariants({ variant, size }))} />
        {label && <span className="sr-only">{label}</span>}
      </div>
    );
  }
);
Spinner.displayName = "Spinner";

// Loading overlay component
export interface LoadingOverlayProps {
  isLoading: boolean;
  children: React.ReactNode;
  className?: string;
  spinnerSize?: VariantProps<typeof spinnerVariants>["size"];
  message?: string;
}

const LoadingOverlay = React.forwardRef<HTMLDivElement, LoadingOverlayProps>(
  ({ isLoading, children, className, spinnerSize = "lg", message, ...props }, ref) => {
    return (
      <div ref={ref} className={cn("relative", className)} {...props}>
        {children}
        {isLoading && (
          <div className="absolute inset-0 bg-white/80 dark:bg-gray-900/80 backdrop-blur-sm flex items-center justify-center z-50 rounded-lg">
            <div className="text-center">
              <Spinner size={spinnerSize} variant="primary" />
              {message && (
                <p className="mt-4 text-sm text-gray-600 dark:text-gray-300">
                  {message}
                </p>
              )}
            </div>
          </div>
        )}
      </div>
    );
  }
);
LoadingOverlay.displayName = "LoadingOverlay";

// Dots spinner variant
const DotsSpinner = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    size?: "sm" | "default" | "lg";
  }
>(({ className, size = "default", ...props }, ref) => {
  const sizeClasses = {
    sm: "w-1 h-1",
    default: "w-2 h-2",
    lg: "w-3 h-3",
  };

  const dotClass = cn(
    "rounded-full bg-primary-500 animate-pulse",
    sizeClasses[size]
  );

  return (
    <div
      ref={ref}
      className={cn("flex space-x-1", className)}
      role="status"
      aria-label="Loading"
      {...props}
    >
      <div className={cn(dotClass, "animation-delay-0")} />
      <div className={cn(dotClass, "animation-delay-150")} />
      <div className={cn(dotClass, "animation-delay-300")} />
    </div>
  );
});
DotsSpinner.displayName = "DotsSpinner";

export { Spinner, LoadingOverlay, DotsSpinner, spinnerVariants }; 