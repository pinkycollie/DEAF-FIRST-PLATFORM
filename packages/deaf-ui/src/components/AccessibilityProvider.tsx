import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';

export interface AccessibilityPreferences {
  signLanguage: boolean;
  highContrast: boolean;
  largeText: boolean;
  reducedMotion: boolean;
  screenReader: boolean;
}

interface AccessibilityContextValue {
  preferences: AccessibilityPreferences;
  updatePreference: <K extends keyof AccessibilityPreferences>(
    key: K,
    value: AccessibilityPreferences[K]
  ) => void;
  resetPreferences: () => void;
}

const defaultPreferences: AccessibilityPreferences = {
  signLanguage: false,
  highContrast: false,
  largeText: false,
  reducedMotion: false,
  screenReader: false,
};

const AccessibilityContext = createContext<AccessibilityContextValue | null>(null);

export interface AccessibilityProviderProps {
  children: React.ReactNode;
  defaultPreferences?: Partial<AccessibilityPreferences>;
  storageKey?: string;
}

export function AccessibilityProvider({
  children,
  defaultPreferences: initialPreferences,
  storageKey = 'deaf-ui-accessibility',
}: AccessibilityProviderProps) {
  const [preferences, setPreferences] = useState<AccessibilityPreferences>(() => {
    // Try to load from localStorage
    if (typeof window !== 'undefined') {
      const stored = localStorage.getItem(storageKey);
      if (stored) {
        try {
          return { ...defaultPreferences, ...JSON.parse(stored) };
        } catch (error) {
          // Clear invalid stored data and log warning
          console.warn('Invalid accessibility preferences in localStorage, resetting to defaults:', error);
          localStorage.removeItem(storageKey);
        }
      }
    }
    
    // Check system preferences
    const systemPrefs: Partial<AccessibilityPreferences> = {};
    if (typeof window !== 'undefined') {
      if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        systemPrefs.reducedMotion = true;
      }
      if (window.matchMedia('(prefers-contrast: high)').matches) {
        systemPrefs.highContrast = true;
      }
    }
    
    return { ...defaultPreferences, ...systemPrefs, ...initialPreferences };
  });

  // Persist preferences
  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem(storageKey, JSON.stringify(preferences));
    }
  }, [preferences, storageKey]);

  // Apply preferences to document
  useEffect(() => {
    if (typeof document === 'undefined') return;
    
    const root = document.documentElement;
    
    root.classList.toggle('deaf-ui-high-contrast', preferences.highContrast);
    root.classList.toggle('deaf-ui-large-text', preferences.largeText);
    root.classList.toggle('deaf-ui-reduced-motion', preferences.reducedMotion);
    root.classList.toggle('deaf-ui-sign-language', preferences.signLanguage);
  }, [preferences]);

  const updatePreference = useCallback(
    <K extends keyof AccessibilityPreferences>(key: K, value: AccessibilityPreferences[K]) => {
      setPreferences((prev) => ({ ...prev, [key]: value }));
    },
    []
  );

  const resetPreferences = useCallback(() => {
    setPreferences(defaultPreferences);
  }, []);

  return (
    <AccessibilityContext.Provider value={{ preferences, updatePreference, resetPreferences }}>
      {children}
    </AccessibilityContext.Provider>
  );
}

export function useAccessibility() {
  const context = useContext(AccessibilityContext);
  if (!context) {
    throw new Error('useAccessibility must be used within an AccessibilityProvider');
  }
  return context;
}
