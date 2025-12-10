# DEAF-FIRST Platform Templates

This directory contains standalone HTML templates that showcase various features and use cases of the DEAF-FIRST Platform.

## Available Templates

### Property Management Template
**File:** `property-management.html`

A comprehensive showcase of the Deaf-First Smart Property Management platform. This template demonstrates:

- **ASL Video Communication** - Real-time sign language video calls with AI-powered translation
- **Visual Alert System** - Smart home integration with visual notifications
- **Automated Rent & Payments** - Payment processing with ASL support
- **Smart Maintenance System** - AI-powered maintenance requests
- **Mobile-First Platform** - Complete property management on mobile devices
- **Community Features** - Building Deaf-friendly communities
- **Landlord Dashboard** - AI-powered analytics and automation
- **Security & Privacy** - DeafAUTH-powered security
- **Regional Sign Language** - Support for ASL, BSL, Auslan, and more

#### Technology Stack Integration
The template showcases integration with:
- asl-ai-app
- asl-ai-engine
- asl-gateway-fastapi
- pinksync/full-stack
- DeafAUTH
- PinkSync
- FibonRose
- 360Magicians

#### Features
- Fully responsive design (desktop, tablet, mobile)
- Modern glassmorphic UI with gradient backgrounds
- Accessible design with proper ARIA labels
- Interactive hover effects and animations
- Complete workflow visualization
- Technology stack overview
- Call-to-action sections

#### How to Use
1. Open the file directly in a web browser
2. Or serve it through a local web server:
   ```bash
   # Using Python
   cd frontend/templates
   python -m http.server 8000
   # Then visit http://localhost:8000/property-management.html
   
   # Using Node.js http-server
   npx http-server frontend/templates
   ```

#### Customization
The template uses CSS variables and can be easily customized by modifying:
- Color schemes (gradient colors)
- Typography (font families and sizes)
- Spacing (padding and margins)
- Feature content (cards, sections)

## Adding New Templates

To add a new template to this directory:

1. Create a new `.html` file with a descriptive name
2. Include complete HTML structure with inline CSS (for portability)
3. Ensure accessibility standards are met (WCAG 2.1 AA)
4. Add responsive design support
5. Update this README with template documentation

## Purpose

These templates serve multiple purposes:
- **Demo/Showcase**: Demonstrate platform capabilities to stakeholders
- **Prototyping**: Quick prototypes for new features or applications
- **Documentation**: Visual documentation of platform features
- **Marketing**: Marketing materials and presentations
- **Testing**: UI/UX testing and user feedback
