# Calypso Architecture and Development

This skill covers working with Calypso, the WordPress.com dashboard, including its two interfaces, component architecture, routing, state management, and development patterns.

## Overview

Calypso is the WordPress.com dashboard built with React/TypeScript using Node 22 and yarn. It has a critical architectural detail: **TWO separate interfaces** with completely different codebases.

## Critical: Two Interface Architecture

| Interface | URL | Code Location | Stack |
|-----------|-----|---------------|-------|
| **Legacy Calypso** | `calypso.localhost:3000` | `client/blocks/`, `client/components/`, `client/my-sites/` | Redux, i18n-calypso, SCSS |
| **New Dashboard** | `my.localhost:3000` | `client/dashboard/` | TanStack Query, @wordpress/i18n, minimal CSS |

**Important:** Changes to one do NOT affect the other. Always clarify which interface when working on Calypso features.

## Repository Structure

### Legacy Interface (`client/`)
- **Components**: `client/components/` — Shared UI components
- **Blocks**: `client/blocks/` — Larger composite components
- **Features**: `client/my-sites/` — Main feature areas (sites, plans, domains, etc.)
- **State**: Redux-based state management with actions/reducers
- **Styling**: SCSS modules and global styles
- **i18n**: `i18n-calypso` for internationalization

### New Dashboard (`client/dashboard/`)
- **Modern stack**: TanStack Query for data, TanStack Router for routing
- **Minimal CSS**: Utility-first approach
- **i18n**: `@wordpress/i18n` (WordPress standard)
- **Components**: Uses `@wordpress/components` where possible

## Development Setup

### Prerequisites
- Node 22.9.0 (use nvm)
- yarn package manager

### Setup Commands
```bash
cd repos/calypso
source ~/.nvm/nvm.sh && nvm use
yarn install
```

### Development Server
```bash
yarn start:debug
# → http://calypso.localhost:3000 (Legacy)
# → http://my.localhost:3000 (New Dashboard)
```

## Component Hierarchy

### Finding Components
1. **First**: Check `@wordpress/components` (from Gutenberg)
2. **Then**: Check `client/components/` for Calypso-specific components
3. **Finally**: Create new components only if nothing exists

### Common Components (`client/components/`)
- Buttons, forms, modals, cards
- Navigation components
- Data display components
- Form validation and input handling

### Blocks (`client/blocks/`)
- Larger composite components
- Feature-specific UI blocks
- Layout components

## State Management

### Legacy Interface (Redux)
- **Actions**: Define user interactions and API calls
- **Reducers**: Update application state
- **Selectors**: Query specific state slices
- **Middleware**: Handle side effects, API calls

### New Dashboard (TanStack Query)
- **Queries**: Fetch and cache server data
- **Mutations**: Update server data
- **Key management**: Coordinate cache invalidation
- **Optimistic updates**: Immediate UI feedback

## Routing

### Legacy Interface
- Custom routing system
- Route definitions in feature directories
- Deep-linking support

### New Dashboard (TanStack Router)
- File-based routing
- Type-safe route parameters
- Automatic code splitting

## Styling Approach

### Legacy Interface
- **SCSS modules**: Component-specific styles
- **Global styles**: Shared design tokens
- **Design system**: Calypso-specific design patterns

### New Dashboard
- **Minimal CSS**: Utility-first approach
- **WordPress components**: Inherits WordPress admin styles
- **Custom properties**: CSS variables for theming

## Integration Points

### WordPress Core Communication
- **REST API**: Primary communication method (`/wp/v2/*` endpoints)
- **Authentication**: OAuth and cookie-based auth
- **Data flow**: API calls → state management → UI updates

### WordPress Components
- Imports from `@wordpress/components`
- Consistent with Gutenberg editor experience
- Shared icons from `@wordpress/icons`

## Development Patterns

### Feature Development
1. Identify which interface (Legacy vs New Dashboard)
2. Follow the appropriate state management pattern
3. Use existing components where possible
4. Maintain consistency with WordPress design patterns

### API Integration
```javascript
// Legacy (Redux)
import { requestSites } from 'calypso/state/sites/actions';

// New Dashboard (TanStack Query)
import { useQuery } from '@tanstack/react-query';
import apiFetch from '@wordpress/api-fetch';
```

### Component Creation
- Follow WordPress component patterns
- Use `@wordpress/components` as the foundation
- Implement responsive design
- Include proper accessibility attributes

## Build and Deployment

### Development Build
```bash
yarn start:debug  # Development server with hot reload
```

### Production Build
```bash
yarn build  # Creates optimized production build
```

### Environment Variables
- Configuration through environment variables
- Different configs for development/production
- API endpoint configuration

## Testing

### Component Testing
- Jest and React Testing Library
- Component unit tests
- Integration tests for features

### E2E Testing
- Playwright for end-to-end tests
- Critical user journey coverage
- Cross-browser testing

## Troubleshooting

### Node Version Issues
Always ensure you're using Node 22:
```bash
source ~/.nvm/nvm.sh && nvm use
```

### Port Conflicts
Calypso uses port 3000. Check for conflicts:
```bash
lsof -ti:3000
```

### Build Issues
Clear cache and reinstall:
```bash
yarn cache clean
rm -rf node_modules
yarn install
```

## Key Files to Reference

- `client/config/index.js` — Configuration management
- `client/lib/wp/` — WordPress API utilities
- `client/state/` — Redux state management (Legacy)
- `client/dashboard/` — New Dashboard implementation
- `package.json` — Dependencies and scripts
- `webpack.config.js` — Build configuration