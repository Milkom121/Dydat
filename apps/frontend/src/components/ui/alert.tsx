/**
 * Alert Component - Dydat Design System
 * Alert notifications with variants and dark mode support
 */

import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { 
  CheckCircle, 
  AlertTriangle, 
  AlertCircle, 
  Info, 
  X 
} from "lucide-react";

const alertVariants = cva(
  "relative w-full rounded-lg border px-4 py-3 text-sm transition-all duration-200",
  {
    variants: {
      variant: {
        default: 
          "bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700 text-gray-900 dark:text-gray-100",
        success: 
          "bg-success-50 dark:bg-success-950 border-success-200 dark:border-success-800 text-success-800 dark:text-success-200",
        warning: 
          "bg-warning-50 dark:bg-warning-950 border-warning-200 dark:border-warning-800 text-warning-800 dark:text-warning-200",
        error: 
          "bg-error-50 dark:bg-error-950 border-error-200 dark:border-error-800 text-error-800 dark:text-error-200",
        info: 
          "bg-blue-50 dark:bg-blue-950 border-blue-200 dark:border-blue-800 text-blue-800 dark:text-blue-200",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
);

const getIcon = (variant: string) => {
  const iconProps = { className: "h-4 w-4" };
  
  switch (variant) {
    case "success":
      return <CheckCircle {...iconProps} />;
    case "warning":
      return <AlertTriangle {...iconProps} />;
    case "error":
      return <AlertCircle {...iconProps} />;
    case "info":
      return <Info {...iconProps} />;
    default:
      return <Info {...iconProps} />;
  }
};

export interface AlertProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof alertVariants> {
  title?: string;
  dismissible?: boolean;
  onDismiss?: () => void;
  icon?: React.ReactNode;
  showIcon?: boolean;
}

const Alert = React.forwardRef<HTMLDivElement, AlertProps>(
  ({ 
    className, 
    variant = "default", 
    title,
    dismissible = false,
    onDismiss,
    icon,
    showIcon = true,
    children,
    ...props 
  }, ref) => {
    const [isVisible, setIsVisible] = React.useState(true);

    const handleDismiss = () => {
      setIsVisible(false);
      onDismiss?.();
    };

    if (!isVisible) return null;

    return (
      <div
        ref={ref}
        role="alert"
        className={cn(alertVariants({ variant }), className)}
        {...props}
      >
        <div className="flex items-start space-x-3">
          {showIcon && (
            <div className="flex-shrink-0 mt-0.5">
              {icon || getIcon(variant || "default")}
            </div>
          )}
          
          <div className="flex-1 min-w-0">
            {title && (
              <h4 className="font-medium mb-1">
                {title}
              </h4>
            )}
            <div className="text-sm">
              {children}
            </div>
          </div>
          
          {dismissible && (
            <button
              onClick={handleDismiss}
              className="flex-shrink-0 ml-auto -mx-1.5 -my-1.5 rounded-lg p-1.5 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              aria-label="Dismiss alert"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
      </div>
    );
  }
);
Alert.displayName = "Alert";

const AlertTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h5
    ref={ref}
    className={cn("mb-1 font-medium leading-none tracking-tight", className)}
    {...props}
  />
));
AlertTitle.displayName = "AlertTitle";

const AlertDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("text-sm [&_p]:leading-relaxed", className)}
    {...props}
  />
));
AlertDescription.displayName = "AlertDescription";

export { Alert, AlertTitle, AlertDescription, alertVariants }; 