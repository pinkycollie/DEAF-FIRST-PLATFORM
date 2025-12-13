# GitHub Pages Setup Guide

## Overview

This repository is configured with a modern, cutting-edge showcase interface that automatically deploys to GitHub Pages using GitHub Actions.

## Features

✨ **Modern Interface**
- Responsive design that works on all devices
- Smooth animations and transitions
- Interactive tabbed navigation
- Expandable service cards with detailed features

♿ **Accessibility First**
- WCAG 2.1 compliant
- Optimized for screen readers
- Keyboard navigation support
- Reduced motion support

🚀 **Production Ready**
- Optimized build with Vite
- Automated deployment via GitHub Actions
- All options/buttons ready for production use

## Quick Start

### Enable GitHub Pages

1. Go to your repository settings
2. Navigate to **Settings** → **Pages**
3. Under **Build and deployment**, select:
   - **Source**: GitHub Actions
4. The site will automatically deploy on every push to the `main` branch

### Manual Deployment

To manually trigger a deployment:

1. Go to the **Actions** tab in your repository
2. Select the **Deploy to GitHub Pages** workflow
3. Click **Run workflow** → **Run workflow**

## Local Development

### Run Development Server

```bash
# Install dependencies
npm install

# Start dev server
npm run dev:frontend
```

The development server will start at `http://localhost:5173/DEAF-FIRST-PLATFORM/`

### Build for Production

```bash
# Build the frontend
npm run build --workspace=frontend
```

The production build will be generated in `frontend/dist/`

### Preview Production Build

```bash
# Preview the production build locally
cd frontend
npm run preview
```

## Interface Features

### Hero Section
- **Get Started** button - Links to GitHub repository
- **Documentation** button - Links to README
- **Explore Features** button - Toggle feature display

### Navigation Tabs
1. **Overview** - Platform statistics and technology stack
2. **Services** - Interactive cards for all 5 microservices
3. **Features** - Platform features and call-to-action

### Interactive Service Cards
Click on any service card to reveal:
- ✓ Feature list
- Learn More button
- Detailed information

Available services:
- 🔐 **DeafAUTH** - Accessible authentication service
- 🔄 **PinkSync** - Real-time synchronization
- 📊 **FibonRose** - Mathematical optimization
- ♿ **Accessibility Nodes** - Modular accessibility features
- 🤖 **AI Services** - AI-powered workflows

## Deployment Configuration

### Vite Configuration
The `frontend/vite.config.ts` is configured with:
- Base path: `/DEAF-FIRST-PLATFORM/` (for GitHub Pages)
- Output directory: `dist/`
- Asset directory: `assets/`

### GitHub Actions Workflow
Located at `.github/workflows/deploy.yml`:
- Triggers on push to `main` branch
- Can be manually triggered
- Builds the frontend
- Deploys to GitHub Pages

## Customization

### Update Base Path
If your repository name changes, update the base path in `frontend/vite.config.ts`:

```typescript
export default defineConfig({
  base: '/YOUR-REPO-NAME/',
  // ... other config
});
```

### Modify Content
- **Hero content**: Edit `frontend/src/App.tsx` (lines 50-75)
- **Services**: Edit the `services` array in `App.tsx` (lines 8-44)
- **Styling**: Modify `frontend/src/App.css` and `index.css`

## Technology Stack

- **React 18** - Modern UI framework
- **TypeScript** - Type-safe development
- **Vite** - Lightning-fast build tool
- **GitHub Actions** - Automated deployment
- **GitHub Pages** - Free static hosting

## Troubleshooting

### Site Not Loading
1. Check that GitHub Pages is enabled in repository settings
2. Verify the workflow ran successfully in the Actions tab
3. Ensure the base path matches your repository name

### Broken Styles
- Verify the base path is correct in `vite.config.ts`
- Check that all assets are being served from the correct path

### Build Fails
- Ensure all dependencies are installed: `npm install`
- Check TypeScript errors: `npm run type-check --workspace=frontend`
- Review the workflow logs in the Actions tab

## Production Deployment Checklist

✅ All buttons and options are functional
✅ Responsive design tested on multiple devices
✅ Accessibility features verified
✅ Build process tested and working
✅ GitHub Actions workflow configured
✅ GitHub Pages enabled in repository settings

## Support

For issues or questions:
- Open an issue in the GitHub repository
- Review the main [README.md](./README.md)
- Check the [QUICKSTART.md](./QUICKSTART.md) guide

---

Built with ❤️ by 360 Magicians
