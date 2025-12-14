import { HTMLAttributes, forwardRef } from 'react';

export interface BadgeProps extends HTMLAttributes<HTMLSpanElement> {
  variant?: 'default' | 'primary' | 'secondary' | 'success' | 'warning' | 'error';
  size?: 'sm' | 'md' | 'lg';
}

export const Badge = forwardRef<HTMLSpanElement, BadgeProps>(
  ({ children, variant = 'default', size = 'md', className = '', ...props }, ref) => {
    return (
      <span
        ref={ref}
        className={`deaf-ui-badge deaf-ui-badge--${variant} deaf-ui-badge--${size} ${className}`}
        {...props}
      >
        {children}
      </span>
    );
  }
);

Badge.displayName = 'Badge';
