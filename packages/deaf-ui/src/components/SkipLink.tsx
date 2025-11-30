import React, { HTMLAttributes, forwardRef } from 'react';

export interface SkipLinkProps extends HTMLAttributes<HTMLAnchorElement> {
  targetId: string;
  children?: React.ReactNode;
}

export const SkipLink = forwardRef<HTMLAnchorElement, SkipLinkProps>(
  ({ targetId, children = 'Skip to main content', className = '', ...props }, ref) => {
    return (
      <a
        ref={ref}
        href={`#${targetId}`}
        className={`deaf-ui-skip-link ${className}`}
        {...props}
      >
        {children}
      </a>
    );
  }
);

SkipLink.displayName = 'SkipLink';
