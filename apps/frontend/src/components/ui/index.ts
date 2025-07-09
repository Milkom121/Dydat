/**
 * Dydat UI Components - Design System Exports
 * Central export file for all UI components
 */

// Base Components
export { Button, buttonVariants } from './button';
export type { ButtonProps } from './button';

export { Input, inputVariants } from './input';
export type { InputProps } from './input';

export { 
  Card, 
  CardHeader, 
  CardFooter, 
  CardTitle, 
  CardDescription, 
  CardContent,
  cardVariants 
} from './card';
export type { CardProps } from './card';

export { Alert, AlertTitle, AlertDescription, alertVariants } from './alert';
export type { AlertProps } from './alert';

export {
  Modal,
  ModalPortal,
  ModalOverlay,
  ModalTrigger,
  ModalClose,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalTitle,
  ModalDescription,
} from './modal';

export { Spinner, LoadingOverlay, DotsSpinner, spinnerVariants } from './spinner';
export type { SpinnerProps, LoadingOverlayProps } from './spinner';

// Theme Components
export { DarkModeToggle, DarkModeToggleCompact } from './dark-mode-toggle'; 