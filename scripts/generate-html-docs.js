#!/usr/bin/env node

/**
 * Generate HTML Documentation from OpenAPI Specifications
 * 
 * This script generates interactive HTML documentation using Redoc
 * for all MBTQ Universe services.
 */

const fs = require('fs');
const path = require('path');

const SERVICES_DIR = path.join(__dirname, '..', 'services');
const DOCS_OUTPUT_DIR = path.join(__dirname, '..', 'docs', 'html');

const SERVICES = [
  { name: 'deafauth', title: 'DeafAUTH - Identity Cortex' },
  { name: 'pinksync', title: 'PinkSync - Accessibility Engine' },
  { name: 'fibonrose', title: 'Fibonrose - Trust & Blockchain' },
  { name: 'magicians', title: '360Magicians - AI Agent Platform' },
  { name: 'dao', title: 'DAO - Governance' }
];

/**
 * Generate HTML documentation for a single service using Redoc
 */
function generateServiceDoc(service) {
  const specPath = path.join(SERVICES_DIR, service.name, 'openapi', 'openapi.yaml');
  
  if (!fs.existsSync(specPath)) {
    console.warn(`⚠️  Spec not found for ${service.name}: ${specPath}`);
    return null;
  }

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${service.title} - API Documentation</title>
  <meta name="description" content="API documentation for ${service.title} - MBTQ Deaf-First Platform">
  
  <!-- Favicon -->
  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🦻</text></svg>">
  
  <!-- Redoc styles override for accessibility -->
  <style>
    body {
      margin: 0;
      padding: 0;
    }
    
    /* High contrast mode support */
    @media (prefers-contrast: high) {
      .redoc-wrap {
        --primary-color: #0066cc;
        --text-color: #000000;
        --link-color: #0000ee;
      }
    }
    
    /* Dark mode support */
    @media (prefers-color-scheme: dark) {
      body {
        background: #1a1a1a;
      }
    }
    
    /* Focus styles for accessibility */
    *:focus {
      outline: 3px solid #0066cc;
      outline-offset: 2px;
    }
    
    /* Skip to content link */
    .skip-link {
      position: absolute;
      top: -40px;
      left: 0;
      background: #0066cc;
      color: white;
      padding: 8px 16px;
      z-index: 100;
      text-decoration: none;
      font-weight: bold;
    }
    
    .skip-link:focus {
      top: 0;
    }
    
    /* Navigation header */
    .nav-header {
      background: #1a1a2e;
      color: white;
      padding: 12px 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 12px;
    }
    
    .nav-header h1 {
      margin: 0;
      font-size: 1.25rem;
    }
    
    .nav-links {
      display: flex;
      gap: 16px;
      flex-wrap: wrap;
    }
    
    .nav-links a {
      color: #a5d6ff;
      text-decoration: none;
      padding: 4px 8px;
      border-radius: 4px;
      transition: background 0.2s;
    }
    
    .nav-links a:hover,
    .nav-links a:focus {
      background: rgba(255, 255, 255, 0.1);
    }
    
    .nav-links a.active {
      background: rgba(255, 255, 255, 0.2);
      font-weight: bold;
    }
  </style>
</head>
<body>
  <a href="#redoc-container" class="skip-link">Skip to API documentation</a>
  
  <nav class="nav-header" role="navigation" aria-label="Service navigation">
    <h1>MBTQ Universe API Docs</h1>
    <div class="nav-links">
      <a href="deafauth.html" ${service.name === 'deafauth' ? 'class="active" aria-current="page"' : ''}>DeafAUTH</a>
      <a href="pinksync.html" ${service.name === 'pinksync' ? 'class="active" aria-current="page"' : ''}>PinkSync</a>
      <a href="fibonrose.html" ${service.name === 'fibonrose' ? 'class="active" aria-current="page"' : ''}>Fibonrose</a>
      <a href="magicians.html" ${service.name === 'magicians' ? 'class="active" aria-current="page"' : ''}>360Magicians</a>
      <a href="dao.html" ${service.name === 'dao' ? 'class="active" aria-current="page"' : ''}>DAO</a>
      <a href="index.html">Overview</a>
    </div>
  </nav>
  
  <main id="redoc-container">
    <redoc spec-url='../services/${service.name}/openapi/openapi.yaml'
           hide-download-button="false"
           expand-responses="200,201"
           path-in-middle-panel="true"
           native-scrollbars="true"
           theme='{
             "colors": {
               "primary": { "main": "#0066cc" }
             },
             "typography": {
               "fontSize": "16px",
               "fontFamily": "system-ui, -apple-system, sans-serif",
               "headings": {
                 "fontFamily": "system-ui, -apple-system, sans-serif"
               }
             },
             "sidebar": {
               "width": "280px"
             },
             "rightPanel": {
               "backgroundColor": "#1a1a2e"
             }
           }'>
    </redoc>
  </main>
  
  <script src="https://cdn.redoc.ly/redoc/latest/bundles/redoc.standalone.js"></script>
</body>
</html>`;

  return html;
}

/**
 * Generate index page with overview of all services
 */
function generateIndexPage() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>MBTQ Deaf-First Platform - API Documentation</title>
  <meta name="description" content="Complete API documentation for the MBTQ Deaf-First Platform">
  
  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🦻</text></svg>">
  
  <style>
    * {
      box-sizing: border-box;
    }
    
    body {
      font-family: system-ui, -apple-system, sans-serif;
      margin: 0;
      padding: 0;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
      min-height: 100vh;
      color: #e0e0e0;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 40px 20px;
    }
    
    header {
      text-align: center;
      margin-bottom: 60px;
    }
    
    h1 {
      font-size: 3rem;
      margin: 0 0 16px 0;
      background: linear-gradient(90deg, #a5d6ff, #ff7eb3);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
    
    .subtitle {
      font-size: 1.25rem;
      color: #a0a0a0;
      margin: 0;
    }
    
    .services-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 24px;
      margin-bottom: 60px;
    }
    
    .service-card {
      background: rgba(255, 255, 255, 0.05);
      border-radius: 16px;
      padding: 32px;
      text-decoration: none;
      color: inherit;
      transition: transform 0.2s, box-shadow 0.2s;
      border: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .service-card:hover,
    .service-card:focus {
      transform: translateY(-4px);
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
      border-color: rgba(165, 214, 255, 0.3);
    }
    
    .service-card:focus {
      outline: 3px solid #0066cc;
      outline-offset: 2px;
    }
    
    .service-icon {
      font-size: 3rem;
      margin-bottom: 16px;
    }
    
    .service-name {
      font-size: 1.5rem;
      margin: 0 0 8px 0;
      color: #a5d6ff;
    }
    
    .service-description {
      color: #a0a0a0;
      margin: 0 0 16px 0;
      line-height: 1.6;
    }
    
    .service-endpoints {
      font-size: 0.875rem;
      color: #ff7eb3;
    }
    
    .features {
      background: rgba(255, 255, 255, 0.03);
      border-radius: 16px;
      padding: 40px;
      margin-bottom: 40px;
    }
    
    .features h2 {
      margin: 0 0 24px 0;
      color: #a5d6ff;
    }
    
    .features-list {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 16px;
      list-style: none;
      padding: 0;
      margin: 0;
    }
    
    .features-list li {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    
    .features-list li::before {
      content: "✓";
      color: #4ade80;
      font-weight: bold;
    }
    
    footer {
      text-align: center;
      padding: 40px 20px;
      color: #606060;
      border-top: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    footer a {
      color: #a5d6ff;
    }
    
    @media (prefers-contrast: high) {
      body {
        background: #000;
      }
      .service-card {
        border-color: #fff;
      }
    }
    
    @media (max-width: 600px) {
      h1 {
        font-size: 2rem;
      }
      .container {
        padding: 20px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>🦻 MBTQ Deaf-First Platform</h1>
      <p class="subtitle">Complete API Documentation for All Services</p>
    </header>
    
    <main>
      <section class="services-grid" aria-label="Available API services">
        <a href="deafauth.html" class="service-card">
          <div class="service-icon">🔐</div>
          <h2 class="service-name">DeafAUTH</h2>
          <p class="service-description">Identity Cortex - Secure authentication system designed with deaf-first principles.</p>
          <span class="service-endpoints">4 endpoints</span>
        </a>
        
        <a href="pinksync.html" class="service-card">
          <div class="service-icon">💗</div>
          <h2 class="service-name">PinkSync</h2>
          <p class="service-description">Accessibility Engine - Real-time accessibility preference synchronization.</p>
          <span class="service-endpoints">3 endpoints</span>
        </a>
        
        <a href="fibonrose.html" class="service-card">
          <div class="service-icon">⛓️</div>
          <h2 class="service-name">Fibonrose</h2>
          <p class="service-description">Trust & Blockchain - Decentralized trust verification and recording.</p>
          <span class="service-endpoints">3 endpoints</span>
        </a>
        
        <a href="magicians.html" class="service-card">
          <div class="service-icon">🧙</div>
          <h2 class="service-name">360Magicians</h2>
          <p class="service-description">AI Agent Platform - Comprehensive AI agents for automation and assistance.</p>
          <span class="service-endpoints">62 endpoints</span>
        </a>
        
        <a href="dao.html" class="service-card">
          <div class="service-icon">🏛️</div>
          <h2 class="service-name">DAO</h2>
          <p class="service-description">Governance - Decentralized governance and community management.</p>
          <span class="service-endpoints">3 endpoints</span>
        </a>
      </section>
      
      <section class="features">
        <h2>Platform Features</h2>
        <ul class="features-list">
          <li>OpenAPI 3.1.0 specifications</li>
          <li>Unified JWT authentication</li>
          <li>Real-time accessibility sync</li>
          <li>AI-powered assistance</li>
          <li>Blockchain verification</li>
          <li>Decentralized governance</li>
          <li>TypeScript & Python SDKs</li>
          <li>Comprehensive testing</li>
        </ul>
      </section>
    </main>
    
    <footer>
      <p>
        <a href="../README.md">README</a> · 
        <a href="../SDK.md">SDK Guide</a> · 
        <a href="ARCHITECTURE.md">Architecture</a> · 
        <a href="FETCH-API-EXAMPLES.md">Fetch API Examples</a>
      </p>
      <p>MBTQ Universe - Deaf-First Platform</p>
    </footer>
  </div>
</body>
</html>`;
}

/**
 * Main function to generate all documentation
 */
function main() {
  console.log('🚀 Generating HTML Documentation...\n');
  
  // Create output directory
  if (!fs.existsSync(DOCS_OUTPUT_DIR)) {
    fs.mkdirSync(DOCS_OUTPUT_DIR, { recursive: true });
  }
  
  // Generate index page
  const indexHtml = generateIndexPage();
  const indexPath = path.join(DOCS_OUTPUT_DIR, 'index.html');
  fs.writeFileSync(indexPath, indexHtml);
  console.log('✅ Generated: index.html');
  
  // Generate service documentation pages
  for (const service of SERVICES) {
    const html = generateServiceDoc(service);
    if (html) {
      const outputPath = path.join(DOCS_OUTPUT_DIR, `${service.name}.html`);
      fs.writeFileSync(outputPath, html);
      console.log(`✅ Generated: ${service.name}.html`);
    }
  }
  
  console.log('\n📁 Documentation generated in:', DOCS_OUTPUT_DIR);
  console.log('\n📖 To view the documentation:');
  console.log('   1. Open docs/html/index.html in a browser');
  console.log('   2. Or run: npx serve docs/html');
}

main();
