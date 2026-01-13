# Prototype

Help the designer quickly scaffold and preview ideas without getting bogged down in setup, configuration, or perfect code.

## Philosophy

- **Speed over perfection** - Get something visual fast
- **Real components** - Use actual UI components, not wireframes
- **Minimal setup** - Skip non-essential configuration
- **Iterate quickly** - Easy to modify and experiment

## Quick Start by Repo

### Calypso Prototype

**Fastest path**: Create a component in an existing section

```bash
# Start dev server
./bin/start.sh calypso
```

**Create prototype component**:

```tsx
// Create: client/my-sites/settings/prototype/index.tsx

import { useState } from 'react';
import { useTranslate } from 'i18n-calypso';
import Main from 'calypso/components/main';
import NavigationHeader from 'calypso/components/navigation-header';
import { 
  Card, 
  CardBody, 
  TextControl, 
  Button,
  ToggleControl 
} from '@wordpress/components';

export default function Prototype() {
  const translate = useTranslate();
  const [value, setValue] = useState('');
  const [enabled, setEnabled] = useState(false);
  
  return (
    <Main className="prototype">
      <NavigationHeader title={translate('Prototype')} />
      
      <Card>
        <CardBody>
          <TextControl
            label="Input"
            value={value}
            onChange={setValue}
          />
          
          <ToggleControl
            label="Toggle"
            checked={enabled}
            onChange={setEnabled}
          />
          
          <Button variant="primary">
            Action
          </Button>
        </CardBody>
      </Card>
    </Main>
  );
}
```

### Gutenberg Storybook Prototype

**Fastest path**: Use Storybook for isolated component prototyping

```bash
./bin/start.sh storybook
```

Create a story file:

```tsx
// packages/components/src/prototype/stories/index.story.js
export default { title: 'Prototype/MyIdea' };

export const Default = () => (
  <div>
    {/* Prototype here */}
  </div>
);
```

### WordPress Admin Prototype

**Fastest path**: Add a menu page

```php
<?php
// Add to a plugin or theme functions.php

add_action('admin_menu', function() {
    add_menu_page(
        'Prototype',
        'Prototype',
        'manage_options',
        'prototype',
        'render_prototype_page',
        'dashicons-art',
        100
    );
});

function render_prototype_page() {
    ?>
    <div class="wrap">
        <h1>Prototype</h1>
        
        <div class="card">
            <h2>Section Title</h2>
            <p>Content goes here.</p>
            <button class="button button-primary">Action</button>
        </div>
    </div>
    <?php
}
```

## Prototype Templates

### Settings Form

```tsx
import { useState } from 'react';
import {
  Card,
  CardBody,
  CardHeader,
  TextControl,
  SelectControl,
  ToggleControl,
  RangeControl,
  Button,
  Notice,
} from '@wordpress/components';

function SettingsPrototype() {
  const [saved, setSaved] = useState(false);
  const [form, setForm] = useState({
    title: '',
    category: 'general',
    enabled: true,
    amount: 50,
  });

  const update = (key, value) => {
    setForm({ ...form, [key]: value });
  };

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <>
      {saved && (
        <Notice status="success" isDismissible={false}>
          Settings saved!
        </Notice>
      )}
      
      <Card>
        <CardHeader>
          <h2>Settings</h2>
        </CardHeader>
        <CardBody>
          <TextControl
            label="Title"
            value={form.title}
            onChange={(v) => update('title', v)}
          />
          
          <SelectControl
            label="Category"
            value={form.category}
            options={[
              { label: 'General', value: 'general' },
              { label: 'Advanced', value: 'advanced' },
              { label: 'Expert', value: 'expert' },
            ]}
            onChange={(v) => update('category', v)}
          />
          
          <ToggleControl
            label="Enable feature"
            checked={form.enabled}
            onChange={(v) => update('enabled', v)}
          />
          
          <RangeControl
            label="Amount"
            value={form.amount}
            onChange={(v) => update('amount', v)}
            min={0}
            max={100}
          />
          
          <Button variant="primary" onClick={handleSave}>
            Save Settings
          </Button>
        </CardBody>
      </Card>
    </>
  );
}
```

### List with Actions

```tsx
import { useState } from 'react';
import {
  Card,
  CardBody,
  Button,
  ButtonGroup,
  SearchControl,
  CheckboxControl,
} from '@wordpress/components';
import { Icon, edit, trash, plus } from '@wordpress/icons';

function ListPrototype() {
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState([]);
  
  const items = [
    { id: 1, title: 'Item One', status: 'active' },
    { id: 2, title: 'Item Two', status: 'draft' },
    { id: 3, title: 'Item Three', status: 'active' },
  ];

  const filtered = items.filter(item =>
    item.title.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 16 }}>
        <SearchControl
          value={search}
          onChange={setSearch}
          placeholder="Search..."
        />
        <Button variant="primary">
          <Icon icon={plus} /> Add New
        </Button>
      </div>

      {filtered.map(item => (
        <Card key={item.id} style={{ marginBottom: 8 }}>
          <CardBody style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <CheckboxControl
              checked={selected.includes(item.id)}
              onChange={(checked) => {
                setSelected(checked 
                  ? [...selected, item.id]
                  : selected.filter(id => id !== item.id)
                );
              }}
            />
            <div style={{ flex: 1 }}>
              <strong>{item.title}</strong>
              <span style={{ marginLeft: 8, opacity: 0.6 }}>{item.status}</span>
            </div>
            <ButtonGroup>
              <Button icon={edit} label="Edit" />
              <Button icon={trash} label="Delete" isDestructive />
            </ButtonGroup>
          </CardBody>
        </Card>
      ))}
    </>
  );
}
```

### Modal Dialog

```tsx
import { useState } from 'react';
import {
  Button,
  Modal,
  TextControl,
  TextareaControl,
} from '@wordpress/components';

function ModalPrototype() {
  const [isOpen, setIsOpen] = useState(false);
  const [form, setForm] = useState({ title: '', description: '' });

  return (
    <>
      <Button variant="primary" onClick={() => setIsOpen(true)}>
        Open Modal
      </Button>

      {isOpen && (
        <Modal
          title="Add New Item"
          onRequestClose={() => setIsOpen(false)}
        >
          <TextControl
            label="Title"
            value={form.title}
            onChange={(title) => setForm({ ...form, title })}
          />
          
          <TextareaControl
            label="Description"
            value={form.description}
            onChange={(description) => setForm({ ...form, description })}
          />
          
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 16 }}>
            <Button variant="secondary" onClick={() => setIsOpen(false)}>
              Cancel
            </Button>
            <Button variant="primary" onClick={() => setIsOpen(false)}>
              Save
            </Button>
          </div>
        </Modal>
      )}
    </>
  );
}
```

## Tips for Fast Prototyping

### 1. Start with Storybook

Gutenberg's Storybook is great for isolated component prototyping:

```bash
./bin/start.sh storybook
```

### 2. Copy Existing Patterns

Find similar UI in the codebase and copy it:

```bash
# Find settings pages in Calypso
ls repos/calypso/client/my-sites/settings/

# Find similar blocks in Gutenberg
ls repos/gutenberg/packages/block-library/src/
```

### 3. Use Browser DevTools

- Edit styles live in Elements panel
- Test responsive with device toolbar
- Mock API responses in Network panel

### 4. Skip Non-Essential Steps

For prototypes, skip:
- Unit tests
- i18n (use plain strings)
- TypeScript types (use `any` if needed)
- Perfect accessibility
- Error handling

Add these later when the design is validated.

## Response Pattern

When designer asks to prototype something:

1. **Clarify the goal** - What are we testing?
2. **Choose fastest path** - Storybook, component, or page?
3. **Provide complete code** - Copy-paste ready
4. **Show how to preview** - Dev server command + URL
5. **Offer iteration help** - "Want to try X instead?"
