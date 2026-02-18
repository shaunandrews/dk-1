# Component Discovery and Usage

This skill covers finding and using existing components across the WordPress ecosystem, including component lookup tables, priority order, usage examples, and integration patterns.

## Overview

The WordPress ecosystem has a rich collection of reusable components across multiple repositories. Before creating new UI elements, always search for existing components to maintain consistency and reduce duplication.

## Component Search Priority Order

### 1. WordPress Components (@wordpress/components) - HIGHEST PRIORITY
These are the canonical UI components for WordPress. Use these first whenever possible.

**Location**: Gutenberg repository (`packages/components/`)  
**Package**: `@wordpress/components`  
**Documentation**: http://localhost:50240 (Storybook when running `npm run storybook`)  
**Online Docs**: https://wordpress.github.io/gutenberg/

### 2. Automattic Components (@automattic/components) 
Used primarily in Calypso and CIAB. Some overlap with WordPress components but with Calypso-specific styling.

**Location**: Calypso repository (`packages/components/`)  
**Package**: `@automattic/components`  
**Usage**: Calypso, CIAB

### 3. Repository-Specific Components
Each repository has its own component collection for specialized use cases.

**Locations**:
- Calypso: `client/components/`
- Gutenberg: `packages/components/src/`
- Jetpack: `projects/js-packages/components/`
- CIAB: `src/components/`
- Telex: `src/components/`

## Component Lookup Tables

### Form Controls

| Component Need | WordPress Components | Automattic Components | Notes |
|----------------|---------------------|----------------------|-------|
| **Text Input** | `TextControl` | `FormTextInput` | WordPress preferred |
| **Textarea** | `TextareaControl` | `FormTextarea` | WordPress preferred |
| **Select Dropdown** | `SelectControl` | `FormSelect` | WordPress preferred |
| **Toggle Switch** | `ToggleControl` | `FormToggle` | Both widely used |
| **Checkbox** | `CheckboxControl` | `FormCheckbox` | WordPress preferred |
| **Radio Buttons** | `RadioControl` | `FormRadio` | WordPress preferred |
| **Range Slider** | `RangeControl` | `FormRange` | WordPress preferred |
| **Number Input** | `__experimentalNumberControl` | `FormNumberInput` | Use Automattic for stability |

### Layout Components

| Component Need | WordPress Components | Automattic Components | Notes |
|----------------|---------------------|----------------------|-------|
| **Card Layout** | `Card`, `CardBody`, `CardHeader` | `Card` | WordPress more flexible |
| **Panel/Accordion** | `Panel`, `PanelBody`, `PanelHeader` | `FoldableCard` | Different APIs |
| **Flexible Layout** | `Flex`, `FlexItem` | `FormattedHeader` | WordPress preferred |
| **Spacing** | `Spacer` | Manual margins | WordPress preferred |
| **Grid Layout** | CSS Grid utilities | `SectionHeader` | Use CSS Grid |
| **Stack Layout** | `VStack`, `HStack` | Manual flexbox | WordPress preferred |

### Interactive Components

| Component Need | WordPress Components | Automattic Components | Notes |
|----------------|---------------------|----------------------|-------|
| **Button** | `Button` | `Button` | Similar APIs |
| **Icon Button** | `Button` (with `icon` prop) | `Gridicon` + `Button` | WordPress simpler |
| **Modal Dialog** | `Modal` | `Dialog` | WordPress preferred |
| **Popover** | `Popover` | `Popover` | WordPress preferred |
| **Dropdown Menu** | `DropdownMenu` | `SelectDropdown` | Different use cases |
| **Menu Items** | `MenuGroup`, `MenuItem` | `PopoverMenu` | WordPress for menus |
| **Tooltip** | `Tooltip` | `InfoPopover` | WordPress simpler |

### Display Components

| Component Need | WordPress Components | Automattic Components | Notes |
|----------------|---------------------|----------------------|-------|
| **Notice/Alert** | `Notice` | `Notice` | Similar functionality |
| **Loading Spinner** | `Spinner` | `Spinner` | Both available |
| **Icons** | `Icon` + `@wordpress/icons` | `Gridicon` | WordPress has more icons |
| **Avatar** | `Avatar` (experimental) | `Gravatar` | Automattic more mature |
| **Badge** | `Badge` (experimental) | `Badge` | Similar functionality |

## Component Usage Examples

### WordPress Components (@wordpress/components)

#### Basic Form Layout
```javascript
import {
  Card,
  CardBody,
  CardHeader,
  TextControl,
  SelectControl,
  ToggleControl,
  Button,
  Spacer,
} from '@wordpress/components';
import { useState } from '@wordpress/element';
import { __ } from '@wordpress/i18n';

const MySettingsForm = () => {
  const [settings, setSettings] = useState({
    title: '',
    category: 'general',
    enabled: false,
  });
  
  return (
    <Card>
      <CardHeader>
        <h2>{__('Settings')}</h2>
      </CardHeader>
      <CardBody>
        <TextControl
          label={__('Title')}
          value={settings.title}
          onChange={(title) => setSettings({ ...settings, title })}
          help={__('Enter a descriptive title')}
        />
        
        <Spacer marginTop={4} />
        
        <SelectControl
          label={__('Category')}
          value={settings.category}
          options={[
            { label: __('General'), value: 'general' },
            { label: __('Advanced'), value: 'advanced' },
          ]}
          onChange={(category) => setSettings({ ...settings, category })}
        />
        
        <Spacer marginTop={4} />
        
        <ToggleControl
          label={__('Enable Feature')}
          checked={settings.enabled}
          onChange={(enabled) => setSettings({ ...settings, enabled })}
        />
        
        <Spacer marginTop={6} />
        
        <Button variant="primary">
          {__('Save Settings')}
        </Button>
      </CardBody>
    </Card>
  );
};
```

#### Modal with Form
```javascript
import {
  Modal,
  Button,
  TextControl,
  TextareaControl,
  VStack,
} from '@wordpress/components';
import { useState } from '@wordpress/element';
import { __ } from '@wordpress/i18n';

const CreateItemModal = ({ isOpen, onClose, onCreate }) => {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
  });
  
  const handleCreate = () => {
    onCreate(formData);
    setFormData({ name: '', description: '' });
    onClose();
  };
  
  if (!isOpen) return null;
  
  return (
    <Modal
      title={__('Create New Item')}
      onRequestClose={onClose}
      style={{ maxWidth: '500px' }}
    >
      <VStack spacing={4}>
        <TextControl
          label={__('Name')}
          value={formData.name}
          onChange={(name) => setFormData({ ...formData, name })}
        />
        
        <TextareaControl
          label={__('Description')}
          value={formData.description}
          onChange={(description) => setFormData({ ...formData, description })}
          rows={4}
        />
        
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
          <Button variant="tertiary" onClick={onClose}>
            {__('Cancel')}
          </Button>
          <Button
            variant="primary"
            onClick={handleCreate}
            disabled={!formData.name.trim()}
          >
            {__('Create')}
          </Button>
        </div>
      </VStack>
    </Modal>
  );
};
```

### Automattic Components (Calypso)

#### Calypso Card Layout
```javascript
import { Card, Button } from '@automattic/components';
import { useTranslate } from 'i18n-calypso';

const CalypsoCard = ({ title, description, onAction }) => {
  const translate = useTranslate();
  
  return (
    <Card>
      <div className="card-header">
        <h3>{title}</h3>
        <Button primary compact onClick={onAction}>
          {translate('Configure')}
        </Button>
      </div>
      <div className="card-content">
        <p>{description}</p>
      </div>
    </Card>
  );
};
```

#### Form with Validation
```javascript
import { FormButton, FormTextInput, FormSelect } from '@automattic/components';
import { useFormState } from 'calypso/lib/form-state';

const CalypsoForm = ({ onSubmit }) => {
  const [form, setForm] = useFormState({
    initialFields: {
      email: '',
      plan: 'personal',
    },
    validatorFunction: (fieldValues, onComplete) => {
      const errors = {};
      
      if (!fieldValues.email) {
        errors.email = 'Email is required';
      }
      
      onComplete(null, errors);
    },
  });
  
  return (
    <div className="form-wrapper">
      <FormTextInput
        name="email"
        type="email"
        placeholder="Enter your email"
        value={form.getFieldValue('email')}
        onChange={setForm}
        isError={form.isFieldInvalid('email')}
      />
      
      <FormSelect
        name="plan"
        value={form.getFieldValue('plan')}
        onChange={setForm}
      >
        <option value="personal">Personal</option>
        <option value="premium">Premium</option>
        <option value="business">Business</option>
      </FormSelect>
      
      <FormButton
        type="submit"
        disabled={!form.isValid()}
        onClick={() => onSubmit(form.getAllFieldValues())}
      >
        Submit
      </FormButton>
    </div>
  );
};
```

## Repository-Specific Components

### Calypso Components (client/components/)

#### Common Calypso Components
```javascript
// Navigation
import NavigationHeader from 'calypso/components/navigation-header';
import SectionNav from 'calypso/components/section-nav';
import NavTabs from 'calypso/components/section-nav/tabs';

// Data Components
import QuerySites from 'calypso/components/data/query-sites';
import QuerySettings from 'calypso/components/data/query-settings';

// UI Components
import Main from 'calypso/components/main';
import SidebarNavigation from 'calypso/components/sidebar-navigation';
import FormattedHeader from 'calypso/components/formatted-header';
import PromoSection from 'calypso/components/promo-section';

const CalypsoPage = ({ siteId }) => {
  return (
    <>
      <QuerySites />
      <QuerySettings siteId={siteId} />
      
      <NavigationHeader 
        title="Page Title"
        subtitle="Page description"
      />
      
      <Main wideLayout>
        <SectionNav>
          <NavTabs>
            <NavItem path="/path1">Tab 1</NavItem>
            <NavItem path="/path2">Tab 2</NavItem>
          </NavTabs>
        </SectionNav>
        
        {/* Page content */}
      </Main>
    </>
  );
};
```

### Jetpack Components

#### Jetpack Dashboard Components
```javascript
// From projects/js-packages/components/
import { AdminPage, Container, Col, H3 } from '@automattic/jetpack-components';
import { ExternalLink, Button } from '@wordpress/components';

const JetpackFeaturePage = () => {
  return (
    <AdminPage>
      <Container fluid>
        <Col>
          <H3>Feature Settings</H3>
          <p>Configure your Jetpack feature here.</p>
          
          <Button variant="primary">
            Save Changes
          </Button>
          
          <ExternalLink href="https://jetpack.com/support">
            Learn More
          </ExternalLink>
        </Col>
      </Container>
    </AdminPage>
  );
};
```

## Icon Systems

### WordPress Icons (@wordpress/icons)
```javascript
import { Icon, check, close, edit, trash } from '@wordpress/icons';

const IconExamples = () => (
  <div>
    <Icon icon={check} size={24} />
    <Icon icon={close} size={24} />
    <Icon icon={edit} size={20} />
    <Icon icon={trash} size={20} />
  </div>
);
```

**Available Icons**: https://wordpress.github.io/gutenberg/?path=/story/icons-icon--library

### Gridicons (Automattic)
```javascript
import Gridicon from 'calypso/components/gridicon';

const GridiconExamples = () => (
  <div>
    <Gridicon icon="checkmark" size={24} />
    <Gridicon icon="cross" size={24} />
    <Gridicon icon="pencil" size={20} />
    <Gridicon icon="trash" size={20} />
  </div>
);
```

**Available Icons**: https://automattic.github.io/gridicons/

## Component Discovery Workflow

### 1. Search Strategy
```bash
# Search in WordPress Components
cd repos/gutenberg/packages/components/src
find . -name "*.js" -o -name "*.tsx" | grep -i [component-name]

# Search in Calypso Components  
cd repos/calypso/client/components
find . -name "*.jsx" | grep -i [component-name]

# Search for usage examples
cd repos/calypso
grep -r "import.*Button" client/ | head -5
```

### 2. Storybook Exploration
```bash
# Start Gutenberg Storybook
cd repos/gutenberg
npm run storybook
# Visit http://localhost:50240

# Browse component categories:
# - Actions (Button, ToolbarButton, etc.)
# - Data Entry (TextControl, SelectControl, etc.)
# - Layout (Card, Flex, Spacer, etc.)
# - Navigation (TabPanel, MenuItem, etc.)
```

### 3. Documentation Check
```javascript
// Most WordPress components have JSDoc comments
/**
 * Button component with various style variants.
 *
 * @param {Object} props - Component props
 * @param {string} props.variant - Button variant: 'primary', 'secondary', 'tertiary'
 * @param {boolean} props.isSmall - Whether button should be small
 * @param {Function} props.onClick - Click handler
 */
```

## Integration Patterns

### Cross-Repository Component Usage

#### Using WordPress Components in Calypso
```javascript
// Import WordPress components in Calypso
import { Card, CardBody, Button } from '@wordpress/components';
import { useTranslate } from 'i18n-calypso';

// Mix with Calypso utilities
const MixedComponent = () => {
  const translate = useTranslate();
  
  return (
    <Card>
      <CardBody>
        <h2>{translate('Settings')}</h2>
        <Button variant="primary">
          {translate('Save')}
        </Button>
      </CardBody>
    </Card>
  );
};
```

#### Using Calypso Components in Custom Projects
```javascript
// Must handle i18n context
import { I18nProvider } from '@automattic/i18n-utils';
import { Button, Card } from '@automattic/components';

const AppWithCalypsoComponents = () => (
  <I18nProvider>
    <Card>
      <Button primary>Action</Button>
    </Card>
  </I18nProvider>
);
```

## Styling and Theming

### WordPress Component Styling
```javascript
// WordPress components inherit WordPress admin styles
import { Card, CardBody } from '@wordpress/components';

// Add custom CSS classes
const StyledCard = () => (
  <Card className="my-custom-card">
    <CardBody>
      {/* Content automatically inherits WordPress styling */}
    </CardBody>
  </Card>
);
```

### Calypso Component Styling
```scss
// Calypso components use SCSS modules
.my-component {
  .card {
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  
  .button {
    &.is-primary {
      background: var(--color-primary);
    }
  }
}
```

## Performance Considerations

### Bundle Size Impact
```javascript
// ✅ Good: Import only what you need
import { Button, Card } from '@wordpress/components';

// ❌ Bad: Import entire library
import * as components from '@wordpress/components';
```

### Tree Shaking
```javascript
// Ensure proper tree shaking
import { Button } from '@wordpress/components'; // ✅
import Button from '@wordpress/components/build/button'; // ✅ Even better

// Avoid default imports that prevent tree shaking
import components from '@wordpress/components'; // ❌
```

## Testing Component Integration

### Testing WordPress Components
```javascript
import { render, screen } from '@testing-library/react';
import { Button } from '@wordpress/components';

test('WordPress Button renders correctly', () => {
  render(<Button variant="primary">Click me</Button>);
  
  const button = screen.getByRole('button');
  expect(button).toHaveClass('is-primary');
  expect(button).toHaveTextContent('Click me');
});
```

### Testing Calypso Components
```javascript
import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import { Button } from '@automattic/components';

test('Calypso Button with Redux context', () => {
  render(
    <Provider store={mockStore}>
      <Button primary>Submit</Button>
    </Provider>
  );
  
  expect(screen.getByRole('button')).toHaveClass('is-primary');
});
```

## Component Discovery Checklist

Before creating a new component, check:

- [ ] **WordPress Components** - Search Storybook and documentation
- [ ] **Automattic Components** - Check Calypso component library
- [ ] **Repository Components** - Search specific repo component directories
- [ ] **Similar Functionality** - Look for components with similar purpose
- [ ] **Accessibility** - Ensure chosen component supports ARIA patterns
- [ ] **Mobile Support** - Verify responsive behavior
- [ ] **Styling** - Check if component fits visual design requirements
- [ ] **Bundle Size** - Consider impact on JavaScript bundle
- [ ] **Browser Support** - Ensure compatibility with target browsers

This systematic approach to component discovery ensures consistency, reduces duplication, and leverages the collective work of the WordPress ecosystem.