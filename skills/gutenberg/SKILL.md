---
description: Gutenberg-specific development context
globs: ["repos/gutenberg/**/*", "repos/gutenberg/packages/components/**/*"]
---

# Gutenberg

Block Editor and home to `@wordpress/components`, the primary component library for the WordPress ecosystem.

## Quick Reference

| Aspect | Details |
|--------|---------|
| **Repo Path** | `repos/gutenberg` |
| **Node Version** | 20 (see .nvmrc) |
| **Package Manager** | npm |
| **Language** | JavaScript/TypeScript |
| **Framework** | React |
| **Styling** | SCSS + Emotion CSS-in-JS |
| **State** | @wordpress/data |
| **Dev Server** | `npm run dev` |
| **Storybook** | `npm run storybook:dev` |

## Node Version (CRITICAL)

Gutenberg requires **Node 20**. Before running ANY npm command:

```bash
cd repos/gutenberg
source ~/.nvm/nvm.sh && nvm use
```

This reads the `.nvmrc` file and switches to the correct version. Always include this in your commands:

```bash
# Installing dependencies
cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm ci

# Starting dev server
cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm run dev

# Starting Storybook
cd repos/gutenberg && source ~/.nvm/nvm.sh && nvm use && npm run storybook:dev
```

## Building the Project (REQUIRED)

Gutenberg must be built before running the dev server or Storybook. The initial setup script handles this, but if you've freshly cloned or are having issues:

```bash
cd repos/gutenberg
source ~/.nvm/nvm.sh && nvm use

# Full build (required after fresh clone or major changes)
npm run build

# Then start development
npm run dev
```

**When to rebuild:**
- After fresh clone or pulling major changes
- After switching branches with significant changes
- If you see TypeScript errors about missing modules
- If Storybook or dev server fails to start

For TypeScript build cache issues, see the Troubleshooting section below.

## Key Directories

```
repos/gutenberg/
├── packages/
│   ├── components/       # @wordpress/components (PRIMARY)
│   ├── block-library/    # Core blocks (paragraph, image, etc.)
│   ├── block-editor/     # Editor framework
│   ├── editor/           # Post editor
│   ├── data/             # State management
│   ├── icons/            # @wordpress/icons
│   └── primitives/       # Low-level primitives
├── lib/                  # PHP functionality
├── storybook/            # Component documentation
└── docs/                 # Written documentation
```

## @wordpress/components

This is THE component library for WordPress. Use these components first.

### Essential Components

```javascript
// Layout
import { Card, CardBody, CardHeader, Panel, PanelBody } from '@wordpress/components';

// Forms
import {
  TextControl,
  TextareaControl,
  SelectControl,
  CheckboxControl,
  RadioControl,
  ToggleControl,
  RangeControl
} from '@wordpress/components';

// Buttons & Actions
import { Button, ButtonGroup, Dropdown, DropdownMenu } from '@wordpress/components';

// Feedback
import { Notice, Spinner, Snackbar } from '@wordpress/components';

// Navigation
import { TabPanel, NavigableMenu } from '@wordpress/components';

// Overlays
import { Modal, Popover, Tooltip } from '@wordpress/components';
```

### Component Documentation

- **Storybook**: https://wordpress.github.io/gutenberg/?path=/docs/components-introduction--docs
- **Local Storybook**: `npm run storybook:dev` → http://localhost:50240

### Styling @wordpress/components

Components accept `className` for custom styling:

```javascript
<Button className="my-custom-button" variant="primary">
  Click Me
</Button>
```

```scss
.my-custom-button {
  // Custom styles
}
```

## Key Package Dependencies

### @wordpress/element (React Abstraction Layer)

Components import React hooks and utilities from `@wordpress/element`, NOT from `react` directly. This package re-exports React's API through a WordPress-namespaced module, allowing WordPress to manage the React dependency centrally.

```typescript
/**
 * WordPress dependencies
 */
import { useState, useEffect, useRef, forwardRef, useMemo } from '@wordpress/element';
```

**Never do this** in component source files:

```typescript
// WRONG — don't import React hooks directly
import { useState } from 'react';
```

The exception: `types.ts` files can import types from `react` since types are erased at build time:

```typescript
import type { ReactNode } from 'react';
```

`@wordpress/element` also provides WordPress-specific utilities like `createInterpolateElement`, `Platform`, and `renderToString`.

### Emotion CSS-in-JS

Alongside SCSS, `@wordpress/components` uses Emotion for dynamic and computed styles. The package depends on `@emotion/styled`, `@emotion/react`, `@emotion/css`, `@emotion/cache`, `@emotion/serialize`, and `@emotion/utils`.

**Common patterns:**

```typescript
// Styled components (most common)
import styled from '@emotion/styled';

const StyledWrapper = styled.div`
	padding: ${ CONFIG.controlPaddingX }px;
`;

// css() for dynamic style objects
import { css } from '@emotion/react';

const dynamicStyle = css`
	color: ${ isActive ? 'blue' : 'gray' };
`;
```

Style files using Emotion are typically named `styles.ts` (not `.scss`), sitting alongside the component's `index.tsx`. The Storybook Vite config includes `jsxImportSource: '@emotion/react'` and the `@emotion/babel-plugin` for proper JSX transformation.

### Ariakit (Accessibility Foundation)

Many interactive components are built on `@ariakit/react` (^0.4.15), which provides accessible primitives for tabs, tooltips, composite widgets, disclosure, radio groups, and custom selects.

```typescript
// Typical namespace import pattern
import * as Ariakit from '@ariakit/react';

// Used for: Tabs, Tooltip, Composite, Disclosure, RadioGroup,
// CustomSelectControl, ToggleGroupControl, Toolbar
```

For testing, `@ariakit/test` provides interaction helpers that properly simulate user events with accessibility semantics:

```typescript
import { press, click, hover, sleep, type, waitFor } from '@ariakit/test';

// These replace manual DOM events — they handle focus, keyboard,
// and aria state transitions correctly
await press.Tab();
await click( screen.getByRole( 'tab', { name: 'Settings' } ) );
```

### @wordpress/compose (Hooks & Utilities)

A utility package providing commonly used hooks and higher-order components. Used heavily across `@wordpress/components` internals.

**Key hooks:**

```typescript
import {
	useInstanceId,      // Generate unique IDs for form elements
	useMergeRefs,       // Combine multiple refs into one
	useDebounce,        // Debounced value/callback
	useThrottle,        // Throttled callback
	usePrevious,        // Track previous value
	useReducedMotion,   // Respect prefers-reduced-motion
	useResizeObserver,  // Track element dimensions
	useViewportMatch,   // Media query matching
	useCopyToClipboard, // Clipboard API wrapper
	useMediaQuery,      // Raw media query hook
} from '@wordpress/compose';
```

---

## Developing @wordpress/components

This guide covers the patterns and conventions for developing components in `@wordpress/components`, including file structure, Storybook stories, documentation, and testing.

### Component File Structure

Each component lives in its own directory under `packages/components/src/`:

```
packages/components/src/my-component/
├── index.tsx           # Main component implementation
├── types.ts            # TypeScript type definitions
├── style.scss          # Component styles
├── README.md           # Documentation
├── stories/
│   └── index.story.tsx # Storybook stories
└── test/
    └── index.tsx       # Unit tests
```

### TypeScript Types (`types.ts`)

Define prop types with complete JSDoc comments. These comments power IDE tooltips and can be used for auto-generated documentation.

```typescript
/**
 * External dependencies
 */
import type { ReactNode } from 'react';

export type MyComponentProps = {
	/**
	 * Description of what this prop does. Include details about behavior
	 * and edge cases.
	 */
	label: ReactNode;
	/**
	 * Description with default value noted.
	 *
	 * @default 'start'
	 */
	position?: 'start' | 'end';
	/**
	 * Callback function description. Explain what triggers it and
	 * what the parameters represent.
	 */
	onChange: ( value: boolean ) => void;
};
```

#### Key conventions:
- Use `ReactNode` for content that can be text, elements, or components
- Document `@default` values in JSDoc
- Use union types (`'start' | 'end'`) instead of generic strings for constrained values
- Prefer logical values (`'start' | 'end'`) over physical values (`'left' | 'right'`) for RTL support

### Styling (`style.scss`)

Use SCSS with Gutenberg's design tokens:

```scss
@use "@wordpress/base-styles/variables" as *;
@use "../other-component/style" as other;

.components-my-component {
	// Use grid units for spacing
	padding: $grid-unit-10;
	margin-block-end: $grid-unit-15;

	// Reference other component variables
	line-height: other.$some-height;

	// BEM-style modifiers
	&.is-active {
		// Active state styles
	}

	&__label {
		// Child element styles
	}
}
```

#### CSS class naming:
- Root: `.components-{component-name}`
- Children: `.components-{component-name}__{element}`
- Modifiers: `.is-{state}` (e.g., `.is-disabled`, `.is-active`)

### Adding a New Prop

When adding a new prop to an existing component:

1. **Update `types.ts`** - Add the prop with JSDoc comment and `@default` if applicable
2. **Update `index.tsx`** - Implement the prop with default value in destructuring
3. **Update `style.scss`** - Add any necessary styles
4. **Update `stories/index.story.tsx`** - Add argType and new stories demonstrating the prop
5. **Update `README.md`** - Document in both Design guidelines and Props sections
6. **Update `test/index.tsx`** - Add tests for default and custom values
7. **Rebuild types** - Run `npx tsc --build packages/components`

---

## Storybook Stories (`stories/index.story.tsx`)

Stories provide interactive documentation and visual testing.

```typescript
/**
 * External dependencies
 */
import type { Meta, StoryFn } from '@storybook/react-vite';

/**
 * WordPress dependencies
 */
import { useState } from '@wordpress/element';

/**
 * Internal dependencies
 */
import MyComponent from '..';

const meta: Meta< typeof MyComponent > = {
	title: 'Components/Category/MyComponent',
	id: 'components-mycomponent',
	component: MyComponent,
	argTypes: {
		// Disable controls for managed state
		checked: { control: false },
		// Use text input for string props
		label: { control: { type: 'text' } },
		// Use radio for union types
		position: {
			control: { type: 'radio' },
			options: [ 'start', 'end' ],
		},
		// Capture callbacks as actions
		onChange: { action: 'onChange' },
	},
	parameters: {
		controls: { expanded: true },
		docs: { canvas: { sourceState: 'shown' } },
	},
};
export default meta;

// Template for stateful components
const Template: StoryFn< typeof MyComponent > = ( { onChange, ...props } ) => {
	const [ value, setValue ] = useState( false );
	return (
		<MyComponent
			{ ...props }
			checked={ value }
			onChange={ ( newValue ) => {
				setValue( newValue );
				onChange( newValue );
			} }
		/>
	);
};

// Default story
export const Default = Template.bind( {} );
Default.args = {
	label: 'My label',
};

// Variant stories
export const WithPosition = Template.bind( {} );
WithPosition.args = {
	...Default.args,
	position: 'end',
};
```

### Story naming conventions:
- `Default` - Basic usage with minimal props
- `With{Feature}` - Demonstrates a specific prop or feature
- `{State}` - Shows a specific state (e.g., `Disabled`, `Loading`)

### Storybook commands:
```bash
cd repos/gutenberg

# Start Storybook (includes dev build)
npm run storybook:dev

# Storybook runs at http://localhost:50240
```

---

## Documentation (`README.md`)

Follow the established pattern for form controls:

```markdown
# ComponentName

Brief description of what the component does.

![Screenshot or diagram](https://example.com/image.png)

## Design guidelines

### Usage

#### When to use this component

- Bullet points for use cases
- When to prefer this over alternatives

![](https://example.com/do-example.png)

**Do**
Description of correct usage.

![](https://example.com/dont-example.png)

**Don't**
Description of incorrect usage.

### Behavior

Describe how the component behaves when interacted with.

## Development guidelines

### Usage

\`\`\`jsx
import { useState } from 'react';
import { ComponentName } from '@wordpress/components';

const MyComponent = () => {
	const [ value, setValue ] = useState( false );

	return (
		<ComponentName
			label="Example"
			checked={ value }
			onChange={ setValue }
		/>
	);
};
\`\`\`

### Props

The component accepts the following props:

#### \`propName\`: \`PropType\`

Description of what the prop does.

- Required: Yes/No
- Default: \`value\` (if applicable)

## Related components

- Link to similar or related components with brief explanation
```

### Documentation checklist:
- [ ] Opening description
- [ ] Screenshot/diagram (if available)
- [ ] Design guidelines with Do/Don't examples
- [ ] Code example showing typical usage
- [ ] All props documented with types
- [ ] Related components section

---

## Unit Tests (`test/index.tsx`)

Use React Testing Library patterns:

```typescript
/**
 * External dependencies
 */
import { render, screen } from '@testing-library/react';

/**
 * Internal dependencies
 */
import MyComponent from '..';

describe( 'MyComponent', () => {
	it( 'should render with label', () => {
		render( <MyComponent label="Test" onChange={ () => {} } /> );
		expect( screen.getByText( 'Test' ) ).toBeInTheDocument();
	} );

	it( 'should call onChange when clicked', () => {
		const onChange = jest.fn();
		render( <MyComponent label="Test" onChange={ onChange } /> );

		screen.getByRole( 'checkbox' ).click();
		expect( onChange ).toHaveBeenCalledWith( true );
	} );

	describe( 'propName', () => {
		it( 'should handle default value', () => {
			// Test default behavior
		} );

		it( 'should handle custom value', () => {
			// Test with prop set
		} );
	} );
} );
```

### Real-World Test Patterns

Tests in the codebase use `@testing-library/react` alongside `@ariakit/test` for interaction simulation and `jest.mock` for isolating dependencies. Here's the actual pattern from `button/test/index.tsx`:

```typescript
/**
 * External dependencies
 */
import { render, screen } from '@testing-library/react';

/**
 * WordPress dependencies
 */
import { createRef, forwardRef } from '@wordpress/element';
import { plusCircle } from '@wordpress/icons';

/**
 * Internal dependencies
 */
import _Button from '..';
import { press } from '@ariakit/test';

// Mock sibling components to isolate the unit under test
jest.mock( '../../icon', () => () => <div data-testid="test-icon" /> );

describe( 'Button', () => {
	it( 'should render with variant class', () => {
		render( <Button variant="primary" /> );
		expect( screen.getByRole( 'button' ) ).toHaveClass( 'is-primary' );
	} );
} );
```

**Key patterns to follow:**
- `jest.mock()` for sibling components (icons, tooltips) to keep tests focused
- `screen.getByRole()` over `getByTestId` — prefer accessible queries
- `@ariakit/test` helpers (`press`, `click`, `hover`) for interaction testing instead of raw `fireEvent`
- Import from `@wordpress/element`, not `react` directly

### Test commands:
```bash
cd repos/gutenberg

# Run all unit tests
npm run test-unit

# Run tests for specific component
npm run test-unit -- --testPathPattern=toggle-control

# Run tests in watch mode
npm run test-unit -- --watch
```

---

## @wordpress/icons

Icon library with 200+ icons [[memory:5195297]]:

```javascript
import { Icon, wordpress, plus, settings, trash } from '@wordpress/icons';

// Basic usage - Icon only accepts icon and size props
<Icon icon={wordpress} size={24} />

// Styling must be done via CSS, not inline styles
// Wrap in container and target SVG:
<span className="my-icon-wrapper">
  <Icon icon={settings} />
</span>
```

```scss
.my-icon-wrapper svg {
  fill: var(--wp-admin-theme-color);
}
```

## Block Development

### Block Structure

```
packages/block-library/src/my-block/
├── block.json          # Block metadata
├── edit.js             # Editor component
├── save.js             # Frontend output
├── index.js            # Registration
├── style.scss          # Frontend styles
└── editor.scss         # Editor-only styles
```

### Basic Block Template

```javascript
// block.json
{
  "apiVersion": 3,
  "name": "core/my-block",
  "title": "My Block",
  "category": "common",
  "icon": "smiley",
  "attributes": {
    "content": { "type": "string" }
  }
}

// edit.js
import { useBlockProps, RichText } from '@wordpress/block-editor';

export default function Edit({ attributes, setAttributes }) {
  return (
    <div {...useBlockProps()}>
      <RichText
        value={attributes.content}
        onChange={(content) => setAttributes({ content })}
      />
    </div>
  );
}
```

## State Management (@wordpress/data)

### Using Stores

```javascript
import { useSelect, useDispatch } from '@wordpress/data';
import { store as coreStore } from '@wordpress/core-data';
import { store as editorStore } from '@wordpress/editor';

function MyComponent() {
  // Reading data
  const postTitle = useSelect(
    (select) => select(editorStore).getEditedPostAttribute('title'),
    []
  );

  // Dispatching actions
  const { editPost } = useDispatch(editorStore);

  const updateTitle = (title) => {
    editPost({ title });
  };
}
```

### Core Stores

- `@wordpress/core-data` - Entities (posts, users, settings)
- `@wordpress/editor` - Post editor state
- `@wordpress/block-editor` - Block manipulation
- `@wordpress/notices` - User notifications

## Block Editor Components

For building block UIs:

```javascript
import {
  RichText,
  InnerBlocks,
  MediaUpload,
  MediaUploadCheck,
  InspectorControls,
  BlockControls,
  useBlockProps
} from '@wordpress/block-editor';
```

## Dev Commands

**CRITICAL:** Before running `npm run dev` in gutenberg, check if `repos/wordpress-core` exists. If it does, do NOT start gutenberg's wp-env. Use `npm run storybook:dev` for component development instead, and use wordpress-core's `npm run dev` for the WordPress environment.

```bash
cd repos/gutenberg

# Start development (ONLY if wordpress-core repo doesn't exist)
npm run dev

# Build
npm run build

# Storybook (use this for component work when wordpress-core exists)
npm run storybook:dev

# Tests
npm run test-unit

# Lint
npm run lint
```

| Task | Command |
|------|---------|
| Start Storybook | `npm run storybook:dev` |
| Run tests | `npm run test-unit -- --testPathPattern={component}` |
| Rebuild types | `npx tsc --build packages/components` |
| Lint | `npm run lint` |
| Type check | `npx tsc --build` |

## Build Output Structure

Each package produces up to four build directories:

| Directory | Contents | Entry point |
|-----------|----------|-------------|
| `build/` | CommonJS modules (`.cjs`) | `"main"` in package.json |
| `build-module/` | ES modules (`.mjs`) | `"module"` in package.json |
| `build-style/` | Compiled CSS from SCSS | Referenced via `"sideEffects"` |
| `build-types/` | TypeScript declaration files (`.d.ts`) | `"types"` in package.json |

These directories are generated by `npm run build` and are required before dev or Storybook can run. If any are missing or stale, you'll see module resolution errors.

## Icon Library Build (IMPORTANT)

The `@wordpress/icons` package has a generated module. Its `src/index.ts` exports from `./library`, which is **generated at build time**:

```typescript
// packages/icons/src/index.ts
export { default as Icon } from './icon';
// The ./library module is generated upon building this package.
export * from './library';
```

If you see errors about missing icon exports, the icons package hasn't been built yet. Run:

```bash
cd repos/gutenberg && npm run build
```

## Design Tokens (`@wordpress/base-styles`)

The `packages/base-styles/` package provides SCSS variables used across all components. Import them in component `.scss` files:

```scss
@use "@wordpress/base-styles/variables" as *;
@use "@wordpress/base-styles/colors" as colors;
@use "@wordpress/base-styles/breakpoints" as *;
@use "@wordpress/base-styles/z-index" as *;
```

### Grid System (8px base unit)

```scss
$grid-unit: 8px;
$grid-unit-05: 4px;    $grid-unit-10: 8px;
$grid-unit-15: 12px;   $grid-unit-20: 16px;
$grid-unit-30: 24px;   $grid-unit-40: 32px;
$grid-unit-50: 40px;   $grid-unit-60: 48px;
```

### Typography Scale

```scss
$font-size-x-small: 11px;   $font-size-small: 12px;
$font-size-medium: 13px;    $font-size-large: 15px;
$font-size-x-large: 20px;   $font-size-2x-large: 32px;
```

### Radius Scale

```scss
$radius-x-small: 1px;   // Nested elements (buttons inside inputs)
$radius-small: 2px;     // Most primitives
$radius-medium: 4px;    // Containers with smaller padding
$radius-large: 8px;     // Containers with larger padding
$radius-full: 9999px;   // Pills
$radius-round: 50%;     // Circles
```

### Colors

Defined in `_colors.scss`. Key grays: `$gray-900` (#1e1e1e) through `$gray-100` (#f0f0f0). Alert colors: `$alert-yellow`, `$alert-red`, `$alert-green`.

### Breakpoints

```scss
$break-small: 600px;    $break-medium: 782px;
$break-large: 960px;    $break-xlarge: 1080px;
$break-wide: 1280px;    $break-huge: 1440px;
```

### Z-Index

Centralized in `_z-index.scss` as a `$z-layers` map. Use the `z-index()` function rather than raw values:

```scss
@use "@wordpress/base-styles/z-index" as *;

.my-component {
	z-index: z-index( ".components-popover" ); // 1000000
}
```

## Workspace Structure

The monorepo contains **123+ packages** under `packages/`, all linked as `file:` dependencies in each other's `package.json`. This means changes to one package are immediately available to others without publishing, but it also means a full `npm run build` is required after cloning so that `build/`, `build-module/`, and `build-types/` directories exist for cross-package resolution.

## WordPressComponentProps Type

A utility type used throughout `@wordpress/components` to merge custom props with HTML element props while supporting polymorphism via `as`:

```typescript
import type { WordPressComponentProps } from '../context';

// Merges BadgeProps with <span> HTML attributes, no polymorphism
type Props = WordPressComponentProps< BadgeProps, 'span', false >;

// With polymorphism (default) — component accepts `as` prop
type Props = WordPressComponentProps< GridProps, 'div' >;
```

Defined in `packages/components/src/context/wordpress-component.ts`. The three type parameters are:
1. **P** — The component's own prop types
2. **T** — The HTML element to inherit attributes from (`'div'`, `'span'`, `'button'`, etc.)
3. **IsPolymorphic** — Whether the `as` prop is accepted (defaults to `true`)

## Dev Workflow Details

`npm run dev` runs `bin/dev.mjs`, which orchestrates a multi-step build:

1. Clean packages
2. Build all workspaces
3. Generate worker placeholders
4. Validate TypeScript version
5. Build TypeScript types (`tsc --build`)
6. Check type declaration files
7. Build vendor files
8. Start watch mode (TypeScript compiler + package builder in parallel)

Once the initial build completes, a `.dev-ready` marker file is written to the repo root. The `storybook:dev` script uses `wait-on .dev-ready` to delay Storybook startup until the build is ready:

```json
"storybook:dev": "concurrently \"npm run dev\" \"wait-on .dev-ready && npm run --workspace @wordpress/storybook storybook:dev\""
```

This means `npm run storybook:dev` runs BOTH the dev build and Storybook concurrently — you don't need to run `npm run dev` separately.

## Vite Storybook Configuration

Storybook uses Vite (`@storybook/react-vite`) with a custom config in `storybook/main.ts`. Key details:

- **Emotion integration**: The Vite React plugin is configured with `jsxImportSource: '@emotion/react'` and `@emotion/babel-plugin`, so Emotion's `css` prop works in stories without extra setup.
- **JS-as-JSX loader**: A custom Vite plugin transforms `.js` files through esbuild with `loader: 'jsx'`, since many Gutenberg source files use JSX in plain `.js` files.
- **Stories sourced from multiple packages**: components, block-editor, icons, dataviews, fields, theme, ui, and more.

## Troubleshooting

### TypeScript Build Errors ("Cannot find module '@wordpress/...'")

If `npm run dev` or `npm run storybook:dev` fails with TypeScript errors like:

```
error TS2307: Cannot find module '@wordpress/icons' or its corresponding type declarations
error TS6305: Output file '...' has not been built from source file '...'
```

This is caused by stale TypeScript build cache. Fix it by cleaning and rebuilding:

```bash
cd repos/gutenberg
source ~/.nvm/nvm.sh && nvm use

# Clean all TypeScript build artifacts
rm -rf packages/*/tsconfig.tsbuildinfo
rm -rf packages/*/build-types

# Rebuild TypeScript (may need to run twice if dependency order issues)
npx tsc --build

# If still failing on a specific package (e.g., @wordpress/theme), build it first:
npx tsc --build packages/theme
npx tsc --build

# Then start dev/storybook
npm run storybook:dev
```

**Root cause**: The monorepo uses TypeScript project references. When build artifacts get out of sync (e.g., after git operations, failed builds, or switching branches), TypeScript can't resolve inter-package dependencies correctly.

## PHP Integration

Gutenberg has PHP components in `lib/`:

```
lib/
├── blocks.php              # Block registration
├── block-patterns.php      # Pattern registration
├── client-assets.php       # Asset enqueuing
└── experimental/           # Experimental features
```

## Git Workflow (CRITICAL)

**Before making any code changes in this repo, ALWAYS:**

1. **Checkout trunk and pull latest:**
   ```bash
   cd repos/gutenberg
   git checkout trunk
   git pull origin trunk
   ```

2. **Create a feature branch:**
   ```bash
   git checkout -b feature/descriptive-name
   ```

3. **Ensure correct Node version:**
   ```bash
   source ~/.nvm/nvm.sh && nvm use  # Uses .nvmrc
   npm install
   ```

4. **Then make your changes**

Never work directly on trunk. Always create a feature branch first.

## AI Context Files

Read `AGENTS.md` for additional AI-specific guidance.
