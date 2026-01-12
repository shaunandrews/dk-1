# Skill: Component Discovery

**Purpose**: Help designers find and use existing UI components across the WordPress ecosystem before creating new ones.

## Priority Order

When a designer asks for a component, search in this order:

1. **@wordpress/components** (Gutenberg) - The canonical component library
2. **Calypso Components** - WordPress.com specific components
3. **@wordpress/icons** - Icon library
4. **Existing patterns** - How similar UIs are built in the codebase

## Quick Lookup Commands

### Find @wordpress/components

```bash
# List all components
ls repos/gutenberg/packages/components/src/

# Search for a specific component
find repos/gutenberg/packages/components/src -name "button" -type d
find repos/gutenberg/packages/components/src -name "*toggle*" -type d

# View component source
cat repos/gutenberg/packages/components/src/button/index.tsx
```

### Find Calypso Components

```bash
# List all Calypso components
ls repos/calypso/client/components/

# Search for component
find repos/calypso/client/components -name "*button*" -type d
find repos/calypso/client/components -name "*card*" -type d
```

### Find Icons

```bash
# List all icons
ls repos/gutenberg/packages/icons/src/library/
```

## Component Categories

### Layout Components

| Need | @wordpress/components | Calypso |
|------|----------------------|---------|
| Container | `Card`, `CardBody` | `Card` |
| Sections | `Panel`, `PanelBody` | `FoldableCard` |
| Grid | `Flex`, `FlexItem` | - |
| Spacing | `Spacer` | - |

### Form Components

| Need | @wordpress/components | Calypso |
|------|----------------------|---------|
| Text input | `TextControl` | `FormTextInput` |
| Textarea | `TextareaControl` | `FormTextarea` |
| Select | `SelectControl` | `FormSelect` |
| Checkbox | `CheckboxControl` | `FormCheckbox` |
| Toggle | `ToggleControl` | `FormToggle` |
| Radio | `RadioControl` | `FormRadio` |
| Range/Slider | `RangeControl` | - |
| Search | `SearchControl` | `Search` |
| Date | `DatePicker`, `DateTimePicker` | `DatePicker` |

### Button & Actions

| Need | @wordpress/components | Calypso |
|------|----------------------|---------|
| Primary button | `Button variant="primary"` | `Button primary` |
| Secondary button | `Button variant="secondary"` | `Button` |
| Destructive | `Button isDestructive` | `Button scary` |
| Button group | `ButtonGroup` | `ButtonGroup` |
| Dropdown | `Dropdown`, `DropdownMenu` | `PopoverMenu` |

### Feedback & Status

| Need | @wordpress/components | Calypso |
|------|----------------------|---------|
| Notice/Alert | `Notice` | `Notice` |
| Loading | `Spinner` | `Spinner` |
| Progress | `ProgressBar` (experimental) | `ProgressBar` |
| Toast | `Snackbar` | - |
| Empty state | - | `EmptyContent` |

### Navigation

| Need | @wordpress/components | Calypso |
|------|----------------------|---------|
| Tabs | `TabPanel` | `SectionNav` |
| Menu | `NavigableMenu` | `VerticalMenu` |
| Pagination | - | `Pagination` |
| Breadcrumbs | - | `Breadcrumb` |

### Overlays

| Need | @wordpress/components | Calypso |
|------|----------------------|---------|
| Modal | `Modal` | `Dialog` |
| Popover | `Popover` | `Popover` |
| Tooltip | `Tooltip` | `Tooltip` |

## Usage Examples

### @wordpress/components Button

```tsx
import { Button } from '@wordpress/components';

// Primary action
<Button variant="primary" onClick={handleSave}>
  Save Changes
</Button>

// Secondary action
<Button variant="secondary" onClick={handleCancel}>
  Cancel
</Button>

// Destructive action
<Button variant="secondary" isDestructive onClick={handleDelete}>
  Delete
</Button>

// With icon
import { Icon, plus } from '@wordpress/icons';
<Button variant="primary">
  <Icon icon={plus} /> Add New
</Button>
```

### @wordpress/components Form

```tsx
import { 
  TextControl, 
  SelectControl, 
  ToggleControl,
  Panel,
  PanelBody 
} from '@wordpress/components';

<Panel>
  <PanelBody title="Settings" initialOpen={true}>
    <TextControl
      label="Site Title"
      value={title}
      onChange={setTitle}
      help="The name of your site"
    />
    
    <SelectControl
      label="Timezone"
      value={timezone}
      options={[
        { label: 'UTC', value: 'UTC' },
        { label: 'New York', value: 'America/New_York' },
      ]}
      onChange={setTimezone}
    />
    
    <ToggleControl
      label="Enable comments"
      checked={commentsEnabled}
      onChange={setCommentsEnabled}
    />
  </PanelBody>
</Panel>
```

### Calypso Card Pattern

```tsx
import Card from 'calypso/components/card';
import FormLabel from 'calypso/components/forms/form-label';
import FormTextInput from 'calypso/components/forms/form-text-input';
import Button from 'calypso/components/button';

<Card>
  <FormLabel htmlFor="site-title">Site Title</FormLabel>
  <FormTextInput
    id="site-title"
    value={title}
    onChange={(e) => setTitle(e.target.value)}
  />
  <Button primary onClick={handleSave}>
    Save
  </Button>
</Card>
```

## Storybook References

### @wordpress/components Storybook

- **Live**: https://wordpress.github.io/gutenberg/?path=/docs/components-introduction--docs
- **Local**: `cd repos/gutenberg && npm run storybook`

Browse by category:
- `/docs/components-button--docs`
- `/docs/components-textcontrol--docs`
- `/docs/components-card--docs`

### Calypso Design System

- **Location**: `repos/calypso/apps/design-system-docs/`

## Search Patterns

When designer asks for something like "I need a toggle switch":

1. Search Gutenberg first:
   ```bash
   grep -r "toggle" repos/gutenberg/packages/components/src --include="*.tsx" -l
   ```

2. Check if used in Calypso:
   ```bash
   grep -r "ToggleControl" repos/calypso/client --include="*.tsx" -l | head -5
   ```

3. Show usage example from codebase:
   ```bash
   grep -A10 "ToggleControl" repos/calypso/client/my-sites/settings/*/index.tsx | head -20
   ```

## Response Template

When designer asks for a component:

1. **Identify the need** - What are they trying to build?
2. **Recommend component** - From @wordpress/components or Calypso
3. **Show import** - Exact import statement
4. **Provide example** - Working code snippet
5. **Link to docs** - Storybook or source file
