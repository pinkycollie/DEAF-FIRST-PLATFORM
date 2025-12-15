# Contributing to DEAF-FIRST Platform

Thank you for your interest in contributing to the DEAF-FIRST Platform! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Accessibility Requirements](#accessibility-requirements)
- [Documentation](#documentation)

## Code of Conduct

This project is committed to providing a welcoming and inclusive environment for all contributors. We expect all participants to:

- Be respectful and considerate
- Focus on accessibility and inclusive design
- Provide constructive feedback
- Accept constructive criticism gracefully
- Prioritize the needs of deaf and hard-of-hearing users

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js**: >= 20.0.0
- **npm**: >= 10.0.0
- **PostgreSQL**: 14+ (for backend development)
- **Redis**: 7+ (for PinkSync development)
- **Git**: Latest version

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/DEAF-FIRST-PLATFORM.git
   cd DEAF-FIRST-PLATFORM
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/pinkycollie/DEAF-FIRST-PLATFORM.git
   ```

### Install Dependencies

```bash
npm install
```

This will install all dependencies for the root workspace and all service workspaces.

### Environment Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your local configuration:
   - Database credentials
   - Redis connection
   - API keys (OpenAI, etc.)
   - JWT secrets

### Running Locally

Start all services in development mode:
```bash
npm run dev
```

Or run individual services:
```bash
npm run dev:frontend    # Frontend only
npm run dev:backend     # Backend only
npm run dev:deafauth    # DeafAUTH only
npm run dev:pinksync    # PinkSync only
npm run dev:fibonrose   # FibonRose only
npm run dev:a11y        # Accessibility nodes only
```

## Development Workflow

### Create a Feature Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or updates
- `chore/` - Maintenance tasks

### Make Your Changes

1. Make your changes in the appropriate workspace(s)
2. Follow the [Code Standards](#code-standards)
3. Write or update tests as needed
4. Update documentation if required

### Test Your Changes

Before committing, ensure all checks pass:

```bash
# Run linting
npm run lint

# Run type checking
npm run type-check

# Run tests
npm run test

# Format code
npm run format
```

### Commit Your Changes

We use conventional commits for clear commit messages:

```bash
git add .
git commit -m "feat(service): add new feature description"
```

See [Commit Guidelines](#commit-guidelines) for more details.

## Code Standards

### TypeScript Style Guide

- Use TypeScript for all new code
- Enable strict mode in `tsconfig.json`
- Define explicit types (avoid `any`)
- Use interfaces for object shapes
- Use enums for fixed sets of values

#### Example:

```typescript
// Good
interface UserPreferences {
  signLanguage: boolean;
  highContrast: boolean;
  fontSize: 'small' | 'medium' | 'large';
}

function updatePreferences(userId: string, prefs: UserPreferences): Promise<void> {
  // Implementation
}

// Avoid
function updatePreferences(userId: any, prefs: any) {
  // Implementation
}
```

### Code Formatting

We use Prettier for consistent code formatting:

- **Indentation**: 2 spaces
- **Quotes**: Single quotes
- **Semicolons**: Yes
- **Line length**: 100 characters
- **Trailing commas**: ES5

Configuration is in `.prettierrc.json`.

### Linting

We use ESLint for code quality:

- Follow the existing ESLint configuration
- Fix all linting errors before committing
- Address warnings when possible

### File Organization

```
workspace/
├── src/
│   ├── index.ts           # Entry point
│   ├── routes/            # API routes
│   ├── controllers/       # Route controllers
│   ├── services/          # Business logic
│   ├── models/            # Data models
│   ├── types/             # TypeScript types
│   ├── utils/             # Utility functions
│   └── __tests__/         # Tests
├── package.json
└── tsconfig.json
```

### Naming Conventions

- **Files**: kebab-case (e.g., `user-service.ts`)
- **Classes**: PascalCase (e.g., `UserService`)
- **Functions**: camelCase (e.g., `getUserProfile`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- **Interfaces**: PascalCase with 'I' prefix optional (e.g., `UserData` or `IUserData`)

## Testing Guidelines

### Test Coverage

We strive for high test coverage:

- **Unit Tests**: Test individual functions and classes
- **Integration Tests**: Test service interactions
- **E2E Tests**: Test complete user workflows (frontend)

### Writing Tests

Use Vitest for unit and integration tests:

```typescript
import { describe, it, expect } from 'vitest';
import { calculateFibonacci } from './math-utils';

describe('calculateFibonacci', () => {
  it('should return correct Fibonacci number', () => {
    expect(calculateFibonacci(0)).toBe(0);
    expect(calculateFibonacci(1)).toBe(1);
    expect(calculateFibonacci(10)).toBe(55);
  });

  it('should handle negative input', () => {
    expect(() => calculateFibonacci(-1)).toThrow();
  });
});
```

### Running Tests

```bash
# Run all tests
npm run test

# Run tests in watch mode
npm run test -- --watch

# Run tests for specific workspace
npm run test --workspace=backend

# Run E2E tests
npm run test:e2e
```

## Commit Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Maintenance tasks
- **ci**: CI/CD changes

### Scopes

Use the workspace or service name:
- `frontend`
- `backend`
- `deafauth`
- `pinksync`
- `fibonrose`
- `accessibility`
- `ai`
- `docs`
- `deps`

### Examples

```bash
feat(frontend): add sign language toggle button

fix(deafauth): correct JWT expiration validation

docs(readme): update installation instructions

chore(deps): update TypeScript to 5.7.2
```

## Pull Request Process

### Before Submitting

1. **Update your branch** with the latest from upstream:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Ensure all checks pass**:
   ```bash
   npm run lint
   npm run type-check
   npm run test
   npm run build
   ```

3. **Update documentation** if needed

4. **Add/update tests** for your changes

### Submitting a PR

1. Push your branch to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. Go to the GitHub repository and create a Pull Request

3. Fill out the PR template:
   - **Title**: Clear, descriptive title following commit conventions
   - **Description**: Explain what and why
   - **Related Issues**: Link any related issues
   - **Screenshots**: For UI changes
   - **Testing**: Describe how you tested

4. Request review from maintainers

### PR Review Process

- Maintainers will review your PR
- Address any requested changes
- Keep the PR updated with main branch
- Once approved, a maintainer will merge your PR

### PR Checklist

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests passing
- [ ] No new warnings
- [ ] Accessibility requirements met

## Accessibility Requirements

### WCAG 2.1 Level AAA Compliance

All contributions must maintain or improve accessibility:

1. **Semantic HTML**: Use proper HTML5 elements
2. **ARIA Labels**: Add appropriate ARIA attributes
3. **Keyboard Navigation**: All features accessible via keyboard
4. **Color Contrast**: Maintain WCAG AAA contrast ratios
5. **Screen Reader**: Test with screen readers
6. **Sign Language Support**: Consider sign language users
7. **Reduced Motion**: Respect `prefers-reduced-motion`

### Testing Accessibility

```bash
# Manual testing
- Test with keyboard only (Tab, Enter, Escape)
- Test with screen reader (NVDA, JAWS, VoiceOver)
- Test with high contrast mode
- Test with browser zoom at 200%

# Automated testing
npm run test:a11y  # (when implemented)
```

### Accessibility Checklist

- [ ] Keyboard accessible
- [ ] Screen reader friendly
- [ ] Proper heading hierarchy
- [ ] Alt text for images
- [ ] Form labels present
- [ ] Color contrast sufficient
- [ ] Focus indicators visible
- [ ] Error messages clear
- [ ] Reduced motion respected

## Documentation

### Code Documentation

- Add JSDoc comments for public APIs
- Document complex algorithms
- Explain non-obvious decisions
- Keep comments up-to-date

Example:
```typescript
/**
 * Calculates optimal resource allocation using Fibonacci-based scheduling.
 * 
 * @param resources - Available resources to allocate
 * @param tasks - Tasks requiring resource allocation
 * @returns Optimized allocation map
 * @throws {Error} If resources are insufficient
 */
export function optimizeAllocation(
  resources: Resource[],
  tasks: Task[]
): AllocationMap {
  // Implementation
}
```

### README Updates

Update relevant README files when:
- Adding new features
- Changing APIs
- Modifying configuration
- Adding dependencies

### Architecture Documentation

Update `ARCHITECTURE.md` when making architectural changes:
- New services
- Modified data flows
- Changed integrations
- Updated deployment strategies

## Getting Help

### Resources

- **Documentation**: Check the `/docs` folder
- **Architecture**: See [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Quick Start**: See [QUICKSTART.md](./QUICKSTART.md)
- **GitHub Issues**: Browse or create issues
- **Discussions**: Use GitHub Discussions for questions

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and general discussion
- **Pull Requests**: Code review and collaboration

## Recognition

Contributors will be:
- Listed in the project's contributors section
- Mentioned in release notes
- Recognized in the project README

Thank you for contributing to making the web more accessible!

---

**Questions?** Open an issue or start a discussion on GitHub.

**Found a security issue?** See [SECURITY.md](./SECURITY.md) for reporting procedures.
