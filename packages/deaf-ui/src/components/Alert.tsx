import React, { HTMLAttributes, createContext, useContext, useId, forwardRef, useState, useCallback } from 'react';

interface AlertContextValue {
  isVisible: boolean;
  dismiss: () => void;
}

const AlertContext = createContext<AlertContextValue | null>(null);

export interface AlertProps extends HTMLAttributes<HTMLDivElement> {
  variant?: 'info' | 'success' | 'warning' | 'error';
  title?: string;
  dismissible?: boolean;
  icon?: React.ReactNode;
  onDismiss?: () => void;
}

export const Alert = forwardRef<HTMLDivElement, AlertProps>(
  (
    {
      children,
      variant = 'info',
      title,
      dismissible = false,
      icon,
      onDismiss,
      className = '',
      ...props
    },
    ref
  ) => {
    const [isVisible, setIsVisible] = useState(true);
    const titleId = useId();

    const dismiss = useCallback(() => {
      setIsVisible(false);
      onDismiss?.();
    }, [onDismiss]);

    if (!isVisible) return null;

    const defaultIcons: Record<string, string> = {
      info: 'ℹ️',
      success: '✅',
      warning: '⚠️',
      error: '❌',
    };

    return (
      <AlertContext.Provider value={{ isVisible, dismiss }}>
        <div
          ref={ref}
          role="alert"
          aria-labelledby={title ? titleId : undefined}
          className={`deaf-ui-alert deaf-ui-alert--${variant} ${className}`}
          {...props}
        >
          <span className="deaf-ui-alert__icon" aria-hidden="true">
            {icon || defaultIcons[variant]}
          </span>
          <div className="deaf-ui-alert__content">
            {title && (
              <h4 id={titleId} className="deaf-ui-alert__title">
                {title}
              </h4>
            )}
            <div className="deaf-ui-alert__message">{children}</div>
          </div>
          {dismissible && (
            <button
              type="button"
              className="deaf-ui-alert__dismiss"
              onClick={dismiss}
              aria-label="Dismiss alert"
            >
              ✕
            </button>
          )}
        </div>
      </AlertContext.Provider>
    );
  }
);

Alert.displayName = 'Alert';

export function useAlert() {
  const context = useContext(AlertContext);
  if (!context) {
    throw new Error('useAlert must be used within an Alert component');
  }
  return context;
}
