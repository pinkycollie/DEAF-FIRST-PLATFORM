import React from 'react';
import { useAccessibility } from './AccessibilityProvider';

export interface AccessibilityToolbarProps {
  position?: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
  className?: string;
}

export function AccessibilityToolbar({
  position = 'bottom-right',
  className = '',
}: AccessibilityToolbarProps) {
  const { preferences, updatePreference } = useAccessibility();
  const [isOpen, setIsOpen] = React.useState(false);

  return (
    <div className={`deaf-ui-a11y-toolbar deaf-ui-a11y-toolbar--${position} ${className}`}>
      <button
        type="button"
        className="deaf-ui-a11y-toolbar__toggle"
        onClick={() => setIsOpen(!isOpen)}
        aria-expanded={isOpen}
        aria-label="Accessibility settings"
      >
        <span aria-hidden="true">♿</span>
      </button>
      
      {isOpen && (
        <div className="deaf-ui-a11y-toolbar__panel" role="dialog" aria-label="Accessibility preferences">
          <h3 className="deaf-ui-a11y-toolbar__title">Accessibility</h3>
          
          <div className="deaf-ui-a11y-toolbar__options">
            <label className="deaf-ui-a11y-toolbar__option">
              <input
                type="checkbox"
                checked={preferences.signLanguage}
                onChange={(e) => updatePreference('signLanguage', e.target.checked)}
              />
              <span>🤟 Sign Language</span>
            </label>
            
            <label className="deaf-ui-a11y-toolbar__option">
              <input
                type="checkbox"
                checked={preferences.highContrast}
                onChange={(e) => updatePreference('highContrast', e.target.checked)}
              />
              <span>🔲 High Contrast</span>
            </label>
            
            <label className="deaf-ui-a11y-toolbar__option">
              <input
                type="checkbox"
                checked={preferences.largeText}
                onChange={(e) => updatePreference('largeText', e.target.checked)}
              />
              <span>🔤 Large Text</span>
            </label>
            
            <label className="deaf-ui-a11y-toolbar__option">
              <input
                type="checkbox"
                checked={preferences.reducedMotion}
                onChange={(e) => updatePreference('reducedMotion', e.target.checked)}
              />
              <span>⏸️ Reduced Motion</span>
            </label>
          </div>
        </div>
      )}
    </div>
  );
}
