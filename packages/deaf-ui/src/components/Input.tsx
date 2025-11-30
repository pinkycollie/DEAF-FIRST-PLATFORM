import React, { InputHTMLAttributes, forwardRef, useId } from 'react';

export interface InputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, 'size'> {
  label?: string;
  helperText?: string;
  error?: string;
  size?: 'sm' | 'md' | 'lg';
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  (
    {
      label,
      helperText,
      error,
      size = 'md',
      leftIcon,
      rightIcon,
      className = '',
      id,
      ...props
    },
    ref
  ) => {
    const generatedId = useId();
    const inputId = id || generatedId;
    const helperId = `${inputId}-helper`;
    const errorId = `${inputId}-error`;

    const hasError = Boolean(error);

    return (
      <div className={`deaf-ui-input-wrapper ${className}`}>
        {label && (
          <label htmlFor={inputId} className="deaf-ui-input__label">
            {label}
            {props.required && (
              <span className="deaf-ui-input__required" aria-hidden="true">
                *
              </span>
            )}
          </label>
        )}
        <div className={`deaf-ui-input-container deaf-ui-input-container--${size} ${hasError ? 'deaf-ui-input-container--error' : ''}`}>
          {leftIcon && (
            <span className="deaf-ui-input__icon deaf-ui-input__icon--left" aria-hidden="true">
              {leftIcon}
            </span>
          )}
          <input
            ref={ref}
            id={inputId}
            className={`deaf-ui-input deaf-ui-input--${size}`}
            aria-invalid={hasError}
            aria-describedby={
              [helperText && helperId, error && errorId].filter(Boolean).join(' ') || undefined
            }
            {...props}
          />
          {rightIcon && (
            <span className="deaf-ui-input__icon deaf-ui-input__icon--right" aria-hidden="true">
              {rightIcon}
            </span>
          )}
        </div>
        {helperText && !error && (
          <p id={helperId} className="deaf-ui-input__helper">
            {helperText}
          </p>
        )}
        {error && (
          <p id={errorId} className="deaf-ui-input__error" role="alert">
            {error}
          </p>
        )}
      </div>
    );
  }
);

Input.displayName = 'Input';
