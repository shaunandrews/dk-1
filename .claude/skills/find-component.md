---
name: find-component
description: Find existing UI components across WordPress ecosystem before creating new ones
---

# Design Kit: Find Component

This skill helps you find and recommend existing UI components from `@wordpress/components` (Gutenberg) or Calypso before creating new components.

## Priority Order

Always search in this order:

1. **@wordpress/components** (Gutenberg) - The canonical component library
2. **Calypso Components** - WordPress.com specific components
3. **@wordpress/icons** - Icon library
4. **Existing patterns** - How similar UIs are built in the codebase

## Execution Steps

### Step 1: Identify the Need

Ask clarifying questions if needed:
- What is the component for? (form, layout, navigation, feedback)
- What interaction does it need? (click, toggle, select, input)
- Are there any specific requirements? (styling, behavior, accessibility)

### Step 2: Search @wordpress/components First

Search in this order:

**For forms**: TextControl, TextareaControl, SelectControl, CheckboxControl, ToggleControl, RadioControl, RangeControl, SearchControl

**For layout**: Card, CardBody, Panel, PanelBody, Flex, FlexItem, Spacer

**For buttons**: Button, ButtonGroup, Dropdown, DropdownMenu

**For feedback**: Notice, Spinner, ProgressBar, Snackbar

**For navigation**: TabPanel, NavigableMenu

**For overlays**: Modal, Popover, Tooltip

Use the Grep tool to find examples in the codebase:
```bash
# Search for component usage
Grep pattern: "from '@wordpress/components'" path: repos/calypso/client/
```

### Step 3: Check Calypso Components (if @wordpress/components doesn't have it)

Look in `repos/calypso/client/components/`:
```bash
# List available Calypso components
Glob pattern: repos/calypso/client/components/*/
```

Common Calypso-specific components:
- FoldableCard (collapsible sections)
- EmptyContent (empty states)
- SectionNav (tabbed navigation)
- Pagination
- Search

### Step 4: Provide Usage Example

Always include:
1. **Import statement** - Exact import with package name
2. **Basic usage** - Minimal working example
3. **Props** - Common/useful props
4. **Link to docs** - Storybook or source location

Example response format:
```markdown
I found the perfect component for this: `Button` from @wordpress/components.

**Import:**
\`\`\`tsx
import { Button } from '@wordpress/components';
\`\`\`

**Usage:**
\`\`\`tsx
<Button variant="primary" onClick={handleClick}>
  Save Changes
</Button>
\`\`\`

**Common variants:**
- `variant="primary"` - Primary action
- `variant="secondary"` - Secondary action
- `isDestructive` - Destructive actions

**Documentation:**
- Storybook: https://wordpress.github.io/gutenberg/?path=/docs/components-button--docs
- Or run: `./bin/start.sh storybook`
```

### Step 5: Show Real Examples from Codebase

Search for actual usage in the Design Kit repos:
```bash
# Find examples of the component being used
Grep pattern: "<Button" output_mode: "content" path: repos/calypso/client/ head_limit: 5
```

Share 1-2 relevant examples from the codebase showing the component in context.

## Quick Reference Table

| Need | @wordpress/components | Calypso Alternative |
|------|----------------------|---------------------|
| Text input | TextControl | FormTextInput |
| Dropdown | SelectControl | FormSelect |
| Toggle switch | ToggleControl | FormToggle |
| Checkbox | CheckboxControl | FormCheckbox |
| Button | Button | Button |
| Card/Panel | Card, Panel | Card |
| Modal | Modal | Dialog |
| Notice/Alert | Notice | Notice |
| Tabs | TabPanel | SectionNav |
| Empty state | - | EmptyContent |

## Common Mistakes to Avoid

❌ **Don't**: Create a custom component without checking @wordpress/components first
❌ **Don't**: Import from Calypso when @wordpress/components has the same component
❌ **Don't**: Use deprecated Calypso components when WordPress equivalents exist

✅ **Do**: Always check @wordpress/components first
✅ **Do**: Use Storybook to see component variations
✅ **Do**: Search the codebase for real usage examples

## Calypso Dashboard Exception

When working in `repos/calypso/client/dashboard/`, prefer @wordpress/components over Calypso components:

- Dashboard uses @wordpress/components as the primary UI library
- Avoid importing from `calypso/components` in dashboard code
- Use minimal CSS (dashboard prefers WordPress component styling)

## Resources

- **Gutenberg Storybook**: https://wordpress.github.io/gutenberg/?path=/docs/components-introduction--docs
- **Local Storybook**: `./bin/start.sh storybook` → http://localhost:50240
- **Calypso Design System**: `repos/calypso/apps/design-system-docs/`
- **Source Code**: `repos/gutenberg/packages/components/src/`
