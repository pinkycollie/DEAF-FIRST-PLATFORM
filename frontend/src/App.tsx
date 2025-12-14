import { useState, useEffect } from 'react';
import './App.css';

interface ServiceStatus {
  name: string;
  icon: string;
  description: string;
  status: 'connected' | 'disconnected' | 'loading';
  features: string[];
}

interface TemplateInfo {
  name: string;
  description: string;
  icon: string;
  features: string[];
}

const templates: TemplateInfo[] = [
  {
    name: 'Basic',
    description: 'Simple SaaS starter with essential features',
    icon: '🚀',
    features: ['React frontend', 'Express backend', 'DeafAUTH', 'Deaf UI components'],
  },
  {
    name: 'Advanced',
    description: 'Full-featured SaaS with all integrations',
    icon: '⚡',
    features: ['Everything in Basic', 'PinkSync real-time', 'FibonRose optimization', 'WebSocket support'],
  },
  {
    name: 'Enterprise',
    description: 'Enterprise-grade SaaS with multi-tenancy',
    icon: '🏢',
    features: ['Everything in Advanced', 'AI Services', 'Multi-tenancy', 'Role-based access control'],
  },
];

function App() {
  const [services, setServices] = useState<ServiceStatus[]>([
    { name: 'DeafAUTH', icon: '🔐', description: 'Accessible authentication service', status: 'loading', features: ['Sign language support', 'Accessible login flows', 'User preferences'] },
    { name: 'PinkSync', icon: '🔄', description: 'Real-time synchronization', status: 'loading', features: ['WebSocket support', 'Channel-based sync', 'Event-driven updates'] },
    { name: 'FibonRose', icon: '📊', description: 'Mathematical optimization', status: 'loading', features: ['Fibonacci algorithms', 'Schedule optimization', 'Golden ratio analysis'] },
    { name: 'Accessibility Nodes', icon: '♿', description: 'Modular accessibility features', status: 'loading', features: ['Sign language API', 'High contrast mode', 'Text simplification'] },
    { name: 'AI Services', icon: '🤖', description: 'AI-powered workflows', status: 'loading', features: ['Content generation', 'Accessibility analysis', 'Natural language processing'] },
  ]);

  const [selectedTemplate, setSelectedTemplate] = useState<string | null>(null);
  const [projectName, setProjectName] = useState('');
  const [generatorCommand, setGeneratorCommand] = useState('');

  useEffect(() => {
    // Simulate checking service status
    const timer = setTimeout(() => {
      setServices((prev) =>
        prev.map((service) => ({
          ...service,
          status: 'connected' as const,
        }))
      );
    }, 1500);

    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    if (selectedTemplate && projectName) {
      const template = selectedTemplate.toLowerCase();
      setGeneratorCommand(
        `npx @deaf-first/generator create ${projectName} --template ${template}`
      );
    } else {
      setGeneratorCommand('');
    }
  }, [selectedTemplate, projectName]);

  return (
    <div className="app">
      <a href="#main-content" className="skip-link">
        Skip to main content
      </a>

      <header className="app-header" role="banner">
        <nav className="nav-container" aria-label="Main navigation">
          <div className="logo">
            <h1>🤟 DEAF-FIRST Platform</h1>
          </div>
          <ul className="nav-links">
            <li><a href="#services" className="nav-link">Services</a></li>
            <li><a href="#templates" className="nav-link">Templates</a></li>
            <li><a href="#generator" className="nav-link">Generator</a></li>
            <li><a href="#docs" className="nav-link">Documentation</a></li>
          </ul>
        </nav>
      </header>

      <main id="main-content" className="app-main" role="main">
        <section className="hero-section" aria-labelledby="hero-title">
          <h2 id="hero-title">Build Accessible SaaS Applications</h2>
          <p className="hero-description">
            A comprehensive platform for creating production-ready, accessibility-first SaaS applications
            with integrated services for authentication, real-time sync, optimization, and AI workflows.
          </p>
          <div className="hero-actions">
            <a href="#generator" className="btn btn-primary">Get Started</a>
            <a href="#docs" className="btn btn-secondary">View Documentation</a>
          </div>
        </section>

        <section id="services" className="services-section" aria-labelledby="services-title">
          <h2 id="services-title">Integrated Services</h2>
          <p className="section-description">
            All services work together seamlessly to provide a complete SaaS infrastructure.
          </p>
          <div className="service-grid" role="list">
            {services.map((service) => (
              <article key={service.name} className="service-card" role="listitem">
                <div className="service-header">
                  <span className="service-icon" aria-hidden="true">{service.icon}</span>
                  <span className={`status-indicator status-${service.status}`} aria-label={`Status: ${service.status}`}>
                    {service.status === 'connected' ? '●' : service.status === 'loading' ? '○' : '○'}
                  </span>
                </div>
                <h3>{service.name}</h3>
                <p>{service.description}</p>
                <ul className="service-features">
                  {service.features.map((feature) => (
                    <li key={feature}>{feature}</li>
                  ))}
                </ul>
              </article>
            ))}
          </div>
        </section>

        <section id="templates" className="templates-section" aria-labelledby="templates-title">
          <h2 id="templates-title">Project Templates</h2>
          <p className="section-description">
            Choose a template that fits your project needs. Each template includes pre-configured
            integrations and best practices.
          </p>
          <div className="template-grid" role="list">
            {templates.map((template) => (
              <article
                key={template.name}
                className={`template-card ${selectedTemplate === template.name ? 'selected' : ''}`}
                role="listitem"
                onClick={() => setSelectedTemplate(template.name)}
                onKeyPress={(e) => e.key === 'Enter' && setSelectedTemplate(template.name)}
                tabIndex={0}
                aria-selected={selectedTemplate === template.name}
              >
                <span className="template-icon" aria-hidden="true">{template.icon}</span>
                <h3>{template.name}</h3>
                <p>{template.description}</p>
                <ul className="template-features">
                  {template.features.map((feature) => (
                    <li key={feature}>✓ {feature}</li>
                  ))}
                </ul>
              </article>
            ))}
          </div>
        </section>

        <section id="generator" className="generator-section" aria-labelledby="generator-title">
          <h2 id="generator-title">Project Generator</h2>
          <p className="section-description">
            Generate a new project with your selected template. The generator creates a complete
            project structure with all necessary configurations.
          </p>
          <div className="generator-form">
            <div className="form-group">
              <label htmlFor="project-name">Project Name</label>
              <input
                id="project-name"
                type="text"
                value={projectName}
                onChange={(e) => setProjectName(e.target.value.replace(/[^a-zA-Z0-9-_]/g, ''))}
                placeholder="my-saas-app"
                aria-describedby="project-name-hint"
              />
              <small id="project-name-hint">Use lowercase letters, numbers, hyphens, or underscores</small>
            </div>

            <div className="form-group">
              <label>Selected Template</label>
              <div className="selected-template">
                {selectedTemplate ? (
                  <span className="template-badge">{selectedTemplate}</span>
                ) : (
                  <span className="placeholder">Select a template above</span>
                )}
              </div>
            </div>

            {generatorCommand && (
              <div className="command-preview">
                <label>Run this command:</label>
                <code className="command-code">{generatorCommand}</code>
                <button
                  className="btn btn-secondary copy-btn"
                  onClick={() => navigator.clipboard.writeText(generatorCommand)}
                  aria-label="Copy command to clipboard"
                >
                  Copy
                </button>
              </div>
            )}

            <div className="generator-steps">
              <h3>Quick Start Steps:</h3>
              <ol>
                <li>Select a template above</li>
                <li>Enter your project name</li>
                <li>Run the generator command</li>
                <li>Follow the generated README</li>
              </ol>
            </div>
          </div>
        </section>

        <section id="docs" className="docs-section" aria-labelledby="docs-title">
          <h2 id="docs-title">Documentation</h2>
          <div className="docs-grid">
            <a href="/docs/quickstart" className="doc-card">
              <span className="doc-icon" aria-hidden="true">📖</span>
              <h3>Quick Start Guide</h3>
              <p>Get started with the DEAF-FIRST Platform in minutes</p>
            </a>
            <a href="/docs/services" className="doc-card">
              <span className="doc-icon" aria-hidden="true">🔧</span>
              <h3>Service Integration</h3>
              <p>Learn how to integrate with DeafAUTH, PinkSync, and more</p>
            </a>
            <a href="/docs/accessibility" className="doc-card">
              <span className="doc-icon" aria-hidden="true">♿</span>
              <h3>Accessibility Guide</h3>
              <p>Best practices for building accessible applications</p>
            </a>
            <a href="/docs/api" className="doc-card">
              <span className="doc-icon" aria-hidden="true">📡</span>
              <h3>API Reference</h3>
              <p>Complete API documentation for all services</p>
            </a>
          </div>
        </section>
      </main>

      <footer className="app-footer" role="contentinfo">
        <div className="footer-content">
          <div className="footer-brand">
            <h4>🤟 DEAF-FIRST Platform</h4>
            <p>Building a more accessible digital world</p>
          </div>
          <div className="footer-links">
            <h4>Resources</h4>
            <ul>
              <li><a href="/docs">Documentation</a></li>
              <li><a href="/api">API Reference</a></li>
              <li><a href="https://github.com/pinkycollie/DEAF-FIRST-PLATFORM">GitHub</a></li>
            </ul>
          </div>
          <div className="footer-links">
            <h4>Services</h4>
            <ul>
              <li><a href="/services/deafauth">DeafAUTH</a></li>
              <li><a href="/services/pinksync">PinkSync</a></li>
              <li><a href="/services/fibonrose">FibonRose</a></li>
            </ul>
          </div>
        </div>
        <div className="footer-bottom">
          <p>© 2024 360 Magicians - DEAF-FIRST Platform v2.0.0</p>
        </div>
import { useState } from 'react';
import './App.css';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div className="app">
      <header className="app-header">
        <h1>DEAF-FIRST Platform</h1>
        <p>Accessible SaaS ecosystem with AI-powered workflows</p>
      </header>
      
      <main className="app-main">
        <section className="services">
          <h2>Available Services</h2>
          <div className="service-grid">
            <div className="service-card">
              <h3>🔐 DeafAUTH</h3>
              <p>Accessible authentication service</p>
            </div>
            <div className="service-card">
              <h3>🔄 PinkSync</h3>
              <p>Real-time synchronization</p>
            </div>
            <div className="service-card">
              <h3>📊 FibonRose</h3>
              <p>Mathematical optimization</p>
            </div>
            <div className="service-card">
              <h3>♿ Accessibility Nodes</h3>
              <p>Modular accessibility features</p>
            </div>
            <div className="service-card">
              <h3>🤖 AI Services</h3>
              <p>AI-powered workflows</p>
            </div>
          </div>
        </section>
        
        <section className="demo">
          <h2>Interactive Demo</h2>
          <button onClick={() => setCount((count) => count + 1)}>
            Count: {count}
          </button>
        </section>
      </main>
      
      <footer className="app-footer">
        <p>© 2024 360 Magicians - DEAF-FIRST Platform v2.0.0</p>
      </footer>
    </div>
  );
}

export default App;
