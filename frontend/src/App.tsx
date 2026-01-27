import { useState } from 'react';
import './App.css';

function App() {
  const [selectedService, setSelectedService] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState('overview');

  const services = [
    {
      id: 'deafauth',
      name: 'DeafAUTH',
      icon: '🔐',
      description: 'Accessible authentication service',
      features: ['JWT Authentication', 'User Preferences', 'MCP Server Support', 'Accessible Flows'],
      color: '#667eea',
    },
    {
      id: 'pinksync',
      name: 'PinkSync',
      icon: '🔄',
      description: 'Real-time synchronization',
      features: ['WebSocket Support', 'Redis Pub/Sub', 'Event-Driven', 'Real-time Updates'],
      color: '#f093fb',
    },
    {
      id: 'fibonrose',
      name: 'FibonRose',
      icon: '📊',
      description: 'Mathematical optimization',
      features: ['Fibonacci Scheduling', 'Performance Analytics', 'Optimization Algorithms', 'MCP Integration'],
      color: '#4facfe',
    },
    {
      id: 'accessibility',
      name: 'Accessibility Nodes',
      icon: '♿',
      description: 'Modular accessibility features',
      features: ['Sign Language Support', 'Visual Enhancements', 'Screen Reader Optimized', 'WCAG Compliant'],
      color: '#43e97b',
    },
    {
      id: 'ai',
      name: 'AI Services',
      icon: '🤖',
      description: 'AI-powered workflows',
      features: ['Natural Language Processing', 'Sign Language Generation', 'Workflow Automation', 'OpenAI Integration'],
      color: '#fa709a',
    },
  ];

  const features = [
    { icon: '🎨', title: 'Modern UI', description: 'Cutting-edge design system' },
    { icon: '♿', title: 'Accessibility First', description: 'WCAG 2.1 AAA compliant' },
    { icon: '🚀', title: 'High Performance', description: 'Optimized for speed' },
    { icon: '🔒', title: 'Secure', description: 'Enterprise-grade security' },
    { icon: '📱', title: 'Responsive', description: 'Works on all devices' },
    { icon: '🌐', title: 'Multi-language', description: 'International support' },
  ];

  const architectureNodes = [
    { id: 'frontend', name: 'Frontend', tech: 'React 18', color: '#667eea', layer: 1 },
    { id: 'backend', name: 'Backend API', tech: 'Express', color: '#764ba2', layer: 2 },
    { id: 'deafauth', name: 'DeafAUTH', tech: 'Auth Service', color: '#f093fb', layer: 3 },
    { id: 'pinksync', name: 'PinkSync', tech: 'Real-time Sync', color: '#4facfe', layer: 3 },
    { id: 'fibonrose', name: 'FibonRose', tech: 'Optimization', color: '#43e97b', layer: 3 },
    { id: 'accessibility', name: 'A11Y Nodes', tech: 'Accessibility', color: '#fa709a', layer: 3 },
    { id: 'ai', name: 'AI Services', tech: 'AI Workflows', color: '#fee140', layer: 3 },
  ];

  const handleServiceClick = (serviceId: string) => {
    setSelectedService(selectedService === serviceId ? null : serviceId);
  };

  const handleGetStarted = () => {
    window.open('https://github.com/pinkycollie/DEAF-FIRST-PLATFORM', '_blank', 'noopener,noreferrer');
  };

  const handleViewDocs = () => {
    window.open('https://github.com/pinkycollie/DEAF-FIRST-PLATFORM#readme', '_blank', 'noopener,noreferrer');
  };

  const handleLiveDemo = () => {
    setActiveTab('features');
  };

  return (
    <div className="app">
      {/* Hero Section */}
      <header className="app-header">
        <div className="hero-content">
          <h1 className="hero-title">DEAF-FIRST Platform</h1>
          <p className="hero-subtitle">Accessible SaaS ecosystem with AI-powered workflows</p>
          <p className="hero-description">
            A comprehensive platform designed with accessibility as the primary focus,
            featuring multiple integrated services for modern deaf-first applications.
          </p>
          <div className="hero-actions">
            <button className="btn btn-primary" onClick={handleGetStarted}>
              <span className="btn-icon">🚀</span>
              Get Started
            </button>
            <button className="btn btn-secondary" onClick={handleViewDocs}>
              <span className="btn-icon">📚</span>
              Documentation
            </button>
            <button className="btn btn-accent" onClick={handleLiveDemo}>
              <span className="btn-icon">✨</span>
              Explore Features
            </button>
          </div>
        </div>
      </header>
      
      <main className="app-main">
        {/* Navigation Tabs */}
        <nav className="tabs">
          <button 
            className={`tab ${activeTab === 'overview' ? 'active' : ''}`}
            onClick={() => setActiveTab('overview')}
          >
            Overview
          </button>
          <button 
            className={`tab ${activeTab === 'services' ? 'active' : ''}`}
            onClick={() => setActiveTab('services')}
          >
            Services
          </button>
          <button 
            className={`tab ${activeTab === 'features' ? 'active' : ''}`}
            onClick={() => setActiveTab('features')}
          >
            Features
          </button>
        </nav>

        {/* Overview Tab */}
        {activeTab === 'overview' && (
          <section className="overview-section">
            <div className="stats-grid">
              <div className="stat-card">
                <div className="stat-value">5</div>
                <div className="stat-label">Microservices</div>
              </div>
              <div className="stat-card">
                <div className="stat-value">100%</div>
                <div className="stat-label">Accessible</div>
              </div>
              <div className="stat-card">
                <div className="stat-value">MCP</div>
                <div className="stat-label">Server Support</div>
              </div>
              <div className="stat-card">
                <div className="stat-value">v2.0</div>
                <div className="stat-label">Production Ready</div>
              </div>
            </div>

            <div className="architecture-diagram">
              <h2>System Architecture</h2>
              <div className="architecture-visual">
                {architectureNodes.map((node) => (
                  <div
                    key={node.id}
                    className="architecture-node"
                    style={{
                      borderColor: node.color,
                      ['--node-color' as any]: node.color,
                    }}
                  >
                    <div className="node-name">{node.name}</div>
                    <div className="node-tech">{node.tech}</div>
                  </div>
                ))}
              </div>
            </div>

            <div className="tech-stack">
              <h2>Technology Stack</h2>
              <div className="tech-badges">
                <span className="tech-badge">React 18</span>
                <span className="tech-badge">TypeScript</span>
                <span className="tech-badge">Node.js</span>
                <span className="tech-badge">PostgreSQL</span>
                <span className="tech-badge">Redis</span>
                <span className="tech-badge">WebSocket</span>
                <span className="tech-badge">Express</span>
                <span className="tech-badge">Vite</span>
                <span className="tech-badge">Docker</span>
                <span className="tech-badge">MCP Protocol</span>
              </div>
            </div>
          </section>
        )}

        {/* Services Tab */}
        {activeTab === 'services' && (
          <section className="services">
            <h2>Available Services</h2>
            <div className="service-grid">
              {services.map((service) => (
                <div
                  key={service.id}
                  className={`service-card ${selectedService === service.id ? 'selected' : ''}`}
                  onClick={() => handleServiceClick(service.id)}
                  style={{ borderColor: service.color }}
                >
                  <div className="service-icon" style={{ color: service.color }}>
                    {service.icon}
                  </div>
                  <h3>{service.name}</h3>
                  <p>{service.description}</p>
                  {selectedService === service.id && (
                    <div className="service-features">
                      <h4>Features:</h4>
                      <ul>
                        {service.features.map((feature, index) => (
                          <li key={index}>✓ {feature}</li>
                        ))}
                      </ul>
                      <button className="btn-small">Learn More</button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Features Tab */}
        {activeTab === 'features' && (
          <section className="features">
            <h2>Platform Features</h2>
            <div className="features-grid">
              {features.map((feature, index) => (
                <div key={index} className="feature-card">
                  <div className="feature-icon">{feature.icon}</div>
                  <h3>{feature.title}</h3>
                  <p>{feature.description}</p>
                </div>
              ))}
            </div>

            <div className="cta-section">
              <h2>Ready to Get Started?</h2>
              <p>Deploy your accessible SaaS platform today</p>
              <div className="cta-actions">
                <button className="btn btn-large btn-primary" onClick={handleGetStarted}>
                  Start Building Now
                </button>
                <button className="btn btn-large btn-outline" onClick={handleViewDocs}>
                  Read Documentation
                </button>
              </div>
            </div>
          </section>
        )}
      </main>
      
      <footer className="app-footer">
        <div className="footer-content">
          <div className="footer-section">
            <h3>DEAF-FIRST Platform</h3>
            <p>Built by 360 Magicians</p>
          </div>
          <div className="footer-section">
            <h4>Quick Links</h4>
            <a href="https://github.com/pinkycollie/DEAF-FIRST-PLATFORM">GitHub</a>
            <a href="https://github.com/pinkycollie/DEAF-FIRST-PLATFORM#readme">Documentation</a>
            <a href="https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/blob/main/LICENSE">License</a>
          </div>
          <div className="footer-section">
            <h4>Services</h4>
            <a href="#deafauth">DeafAUTH</a>
            <a href="#pinksync">PinkSync</a>
            <a href="#fibonrose">FibonRose</a>
          </div>
        </div>
        <div className="footer-bottom">
          <p>© 2024 360 Magicians - DEAF-FIRST Platform v2.0.0 | MIT License</p>
        </div>
      </footer>
    </div>
  );
}

export default App;
