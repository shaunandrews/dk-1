# Gutenberg Block Editor and Components

This skill covers working with the Gutenberg block editor, the `@wordpress/components` library, block development, and component development patterns including Storybook workflows.

## Overview

Gutenberg is the WordPress block editor that provides both the editing experience and a comprehensive component library (`@wordpress/components`) used throughout the WordPress ecosystem including Calypso, WordPress Core admin, and third-party plugins.

## Repository Structure

### Core Areas
- **Blocks**: `packages/block-library/` — Core WordPress blocks
- **Components**: `packages/components/` — Reusable UI component library
- **Block Editor**: `packages/block-editor/` — Block editing interface
- **Compose**: `packages/compose/` — React hooks and utilities
- **Data**: `packages/data/` — State management utilities

### Development Setup

#### Prerequisites
- Node 20 (use nvm)
- npm package manager

#### Setup Commands
```bash
cd repos/gutenberg
source ~/.nvm/nvm.sh && nvm use
npm ci
npm run build  # Required before dev/storybook
```

#### Development Servers
```bash
npm run dev        # → http://localhost:9999 (Gutenberg playground)
npm run storybook  # → http://localhost:50240 (Component library)
```

## Component Library (@wordpress/components)

The `@wordpress/components` package is the definitive UI library for WordPress interfaces. It provides:

### Core Components

#### Form Controls
- `TextControl` — Text input fields
- `TextareaControl` — Multi-line text input
- `SelectControl` — Dropdown select
- `ToggleControl` — Toggle switches
- `CheckboxControl` — Checkboxes
- `RadioControl` — Radio button groups
- `RangeControl` — Number sliders

#### Layout Components
- `Panel` / `PanelBody` / `PanelHeader` — Collapsible sections
- `Card` / `CardBody` / `CardHeader` — Card layouts
- `Flex` / `FlexItem` — Flexible layouts
- `VStack` / `HStack` — Vertical/horizontal stacks
- `Spacer` — Spacing utility

#### Interactive Components
- `Button` — Primary, secondary, tertiary button variants
- `Modal` — Overlay modals
- `Popover` — Positioned popovers
- `Dropdown` — Dropdown menus
- `MenuGroup` / `MenuItem` — Menu components

#### Display Components
- `Notice` — Status messages and alerts
- `Spinner` — Loading indicators
- `Icon` — SVG icon wrapper
- `Tooltip` — Contextual help tooltips

### Component Development Workflow

#### Using Storybook
Storybook provides live component documentation and testing:

1. **Browse components**: http://localhost:50240
2. **See usage examples**: Each component includes code examples
3. **Test variants**: Different props and states
4. **Interactive playground**: Modify props in real-time

#### Component File Structure
```
packages/components/src/button/
├── index.tsx          # Main component
├── types.ts           # TypeScript interfaces
├── stories/index.tsx  # Storybook stories
├── test/index.tsx     # Unit tests
├── style.scss         # Component styles
└── README.md          # Documentation
```

## Block Development

### Block Anatomy
A WordPress block consists of:
- **Edit component**: The editing interface in the editor
- **Save function**: How content is saved to database
- **Attributes**: Block data schema
- **Supports**: Editor features the block supports

### Block Registration
```javascript
import { registerBlockType } from '@wordpress/blocks';
import { useBlockProps } from '@wordpress/block-editor';

registerBlockType('my-plugin/my-block', {
    apiVersion: 3, // Use latest API version
    title: 'My Block',
    category: 'widgets',
    attributes: {
        content: { type: 'string' }
    },
    edit: ({ attributes, setAttributes }) => {
        const blockProps = useBlockProps();
        return (
            <div {...blockProps}>
                {/* Edit interface */}
            </div>
        );
    },
    save: ({ attributes }) => {
        const blockProps = useBlockProps.save();
        return (
            <div {...blockProps}>
                {/* Saved content */}
            </div>
        );
    }
});
```

### Block Controls

#### Inspector Controls (Sidebar)
```javascript
import { InspectorControls } from '@wordpress/block-editor';
import { PanelBody, ToggleControl } from '@wordpress/components';

<InspectorControls>
    <PanelBody title="Settings">
        <ToggleControl
            label="Enable feature"
            checked={attributes.enabled}
            onChange={(enabled) => setAttributes({ enabled })}
        />
    </PanelBody>
</InspectorControls>
```

#### Block Controls (Toolbar)
```javascript
import { BlockControls } from '@wordpress/block-editor';
import { ToolbarGroup, ToolbarButton } from '@wordpress/components';

<BlockControls>
    <ToolbarGroup>
        <ToolbarButton onClick={() => {}}>
            Action
        </ToolbarButton>
    </ToolbarGroup>
</BlockControls>
```

### Rich Text Editing
```javascript
import { RichText } from '@wordpress/block-editor';

<RichText
    tagName="p"
    value={attributes.content}
    onChange={(content) => setAttributes({ content })}
    placeholder="Enter text..."
/>
```

## State Management (@wordpress/data)

Gutenberg uses a Redux-like data layer:

### Core Stores
- `core/editor` — Post editor state
- `core/block-editor` — Block editor state  
- `core` — WordPress data (posts, users, etc.)
- `core/preferences` — User preferences

### Using Data
```javascript
import { useSelect, useDispatch } from '@wordpress/data';

// Read data
const { getCurrentPost } = useSelect('core/editor');
const post = getCurrentPost();

// Update data
const { editPost } = useDispatch('core/editor');
editPost({ title: 'New Title' });
```

### Custom Stores
```javascript
import { createReduxStore, register } from '@wordpress/data';

const store = createReduxStore('my-plugin', {
    reducer: myReducer,
    actions: myActions,
    selectors: mySelectors,
});

register(store);
```

## Component Design Patterns

### WordPress Design System
Components follow WordPress design system principles:
- **Consistent spacing**: Based on 8px grid system
- **Typography scale**: Harmonious font sizes
- **Color palette**: WordPress brand colors
- **Accessibility**: WCAG AA compliance

### Responsive Design
```javascript
import { useBreakpointIndex } from '@wordpress/compose';

const MyComponent = () => {
    const breakpointIndex = useBreakpointIndex();
    const isMobile = breakpointIndex < 2;
    
    return (
        <div className={isMobile ? 'mobile-layout' : 'desktop-layout'}>
            {/* Content */}
        </div>
    );
};
```

### Custom Hooks
Common patterns using `@wordpress/compose`:

```javascript
import { useState, useEffect } from 'react';
import { useDebounce } from '@wordpress/compose';

// Debounced state
const [searchTerm, setSearchTerm] = useState('');
const debouncedSearchTerm = useDebounce(searchTerm, 300);

// Previous value tracking
const previousValue = usePrevious(currentValue);

// Media queries
const isMobile = useMediaQuery('(max-width: 600px)');
```

## Build and Development

### Package Scripts
```bash
# Development
npm run dev           # Start development server
npm run storybook     # Start component library

# Building
npm run build         # Build all packages
npm run build:packages # Build just the packages

# Testing
npm test             # Run all tests
npm run test:unit    # Unit tests only
npm run test:e2e     # End-to-end tests
```

### Working with Components

#### Testing Components
```javascript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from '../';

test('button calls onClick when clicked', async () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    await userEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalled();
});
```

#### Creating Custom Components
```javascript
import { Button } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

const MyCustomButton = ({ children, ...props }) => {
    return (
        <Button 
            variant="primary"
            className="my-custom-button"
            {...props}
        >
            {children}
        </Button>
    );
};
```

## Integration with WordPress Core

### Blocks Sync Process
- Gutenberg blocks are developed in this repository
- Stable blocks sync to WordPress Core during release cycles
- Experimental blocks remain in Gutenberg only

### Component Usage
Components are used throughout WordPress:
- **Block Editor**: All editing interfaces
- **WordPress Admin**: Settings pages, user interfaces
- **Themes**: Block theme customization
- **Plugins**: Consistent UI patterns

## Advanced Patterns

### Block Variations
```javascript
import { registerBlockVariation } from '@wordpress/blocks';

registerBlockVariation('core/group', {
    name: 'card-variation',
    title: 'Card',
    attributes: {
        style: { spacing: { padding: '20px' } },
        backgroundColor: 'light-gray'
    }
});
```

### Block Transforms
```javascript
transforms: {
    from: [
        {
            type: 'block',
            blocks: ['core/paragraph'],
            transform: ({ content }) => {
                return createBlock('my-plugin/my-block', { content });
            }
        }
    ]
}
```

### Dynamic Blocks
```javascript
// PHP render callback
function render_my_block($attributes) {
    return '<div>Server-rendered content</div>';
}

// JavaScript registration
registerBlockType('my-plugin/dynamic-block', {
    edit: EditComponent,
    save: () => null, // Dynamic blocks don't save
});
```

## Troubleshooting

### Node Version
Always use Node 20:
```bash
source ~/.nvm/nvm.sh && nvm use
```

### Build Issues
```bash
npm run clean:packages
npm ci
npm run build
```

### wp-env Conflicts
When both WordPress Core and Gutenberg exist, use WordPress Core's wp-env:
```bash
# ✅ Use this
cd repos/wordpress-core && npm run dev

# ❌ Not this (when wordpress-core exists)
cd repos/gutenberg && npm run dev
```

## Key References

- **Storybook**: http://localhost:50240 — Component documentation
- **Block Handbook**: https://developer.wordpress.org/block-editor/
- **Component Reference**: https://wordpress.github.io/gutenberg/
- **GitHub Issues**: https://github.com/WordPress/gutenberg/issues
- **Gutenberg Plugin**: Latest features before Core integration