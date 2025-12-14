import { HTMLAttributes, forwardRef } from 'react';

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  variant?: 'elevated' | 'outlined' | 'filled';
  padding?: 'none' | 'sm' | 'md' | 'lg';
  interactive?: boolean;
}

export const Card = forwardRef<HTMLDivElement, CardProps>(
  (
    {
      children,
      variant = 'elevated',
      padding = 'md',
      interactive = false,
      className = '',
      ...props
    },
    ref
  ) => {
    const baseStyles = `
      deaf-ui-card
      deaf-ui-card--${variant}
      deaf-ui-card--padding-${padding}
      ${interactive ? 'deaf-ui-card--interactive' : ''}
      ${className}
    `.trim().replace(/\s+/g, ' ');

    return (
      <div ref={ref} className={baseStyles} {...props}>
        {children}
      </div>
    );
  }
);

Card.displayName = 'Card';

export interface CardHeaderProps extends HTMLAttributes<HTMLDivElement> {}

export const CardHeader = forwardRef<HTMLDivElement, CardHeaderProps>(
  ({ children, className = '', ...props }, ref) => (
    <div ref={ref} className={`deaf-ui-card__header ${className}`} {...props}>
      {children}
    </div>
  )
);

CardHeader.displayName = 'CardHeader';

export interface CardTitleProps extends HTMLAttributes<HTMLHeadingElement> {
  as?: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6';
}

export const CardTitle = forwardRef<HTMLHeadingElement, CardTitleProps>(
  ({ children, as: Component = 'h3', className = '', ...props }, ref) => (
    <Component ref={ref} className={`deaf-ui-card__title ${className}`} {...props}>
      {children}
    </Component>
  )
);

CardTitle.displayName = 'CardTitle';

export interface CardContentProps extends HTMLAttributes<HTMLDivElement> {}

export const CardContent = forwardRef<HTMLDivElement, CardContentProps>(
  ({ children, className = '', ...props }, ref) => (
    <div ref={ref} className={`deaf-ui-card__content ${className}`} {...props}>
      {children}
    </div>
  )
);

CardContent.displayName = 'CardContent';

export interface CardFooterProps extends HTMLAttributes<HTMLDivElement> {}

export const CardFooter = forwardRef<HTMLDivElement, CardFooterProps>(
  ({ children, className = '', ...props }, ref) => (
    <div ref={ref} className={`deaf-ui-card__footer ${className}`} {...props}>
      {children}
    </div>
  )
);

CardFooter.displayName = 'CardFooter';
