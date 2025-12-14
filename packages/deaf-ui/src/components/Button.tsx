import React, { ButtonHTMLAttributes, forwardRef } from 'react';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      children,
      variant = 'primary',
      size = 'md',
      isLoading = false,
      leftIcon,
      rightIcon,
      disabled,
      className = '',
      ...props
    },
    ref
  ) => {
    const baseStyles = `
      deaf-ui-button
      deaf-ui-button--${variant}
      deaf-ui-button--${size}
      ${isLoading ? 'deaf-ui-button--loading' : ''}
      ${className}
    `.trim().replace(/\s+/g, ' ');

    return (
      <button
        ref={ref}
        className={baseStyles}
        disabled={disabled || isLoading}
        aria-busy={isLoading}
        {...props}
      >
        {isLoading && (
          <span className="deaf-ui-button__spinner" aria-hidden="true">
            <svg
              className="deaf-ui-spinner"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <circle
                className="deaf-ui-spinner__track"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="3"
              />
              <path
                className="deaf-ui-spinner__head"
                d="M12 2a10 10 0 0 1 10 10"
                stroke="currentColor"
                strokeWidth="3"
                strokeLinecap="round"
              />
            </svg>
          </span>
        )}
        {!isLoading && leftIcon && (
          <span className="deaf-ui-button__icon deaf-ui-button__icon--left" aria-hidden="true">
            {leftIcon}
          </span>
        )}
        <span className="deaf-ui-button__text">{children}</span>
        {!isLoading && rightIcon && (
          <span className="deaf-ui-button__icon deaf-ui-button__icon--right" aria-hidden="true">
            {rightIcon}
          </span>
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';
