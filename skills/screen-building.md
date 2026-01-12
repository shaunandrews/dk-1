# Skill: Screen Building

**Purpose**: Help designers create new pages, views, and screens across the WordPress ecosystem.

## Where Screens Live

| Type | Location | Framework |
|------|----------|-----------|
| Calypso pages | `repos/calypso/client/my-sites/` | React + TypeScript |
| Calypso sections | `repos/calypso/client/` subdirs | React + TypeScript |
| Gutenberg editor | `repos/gutenberg/packages/editor/` | React |
| Block settings | `repos/gutenberg/packages/block-editor/` | React |
| WP Admin pages | `repos/wordpress-core/src/wp-admin/` | PHP |
| WP Settings | `repos/wordpress-core/src/wp-admin/options-*.php` | PHP |

## Calypso Screen Templates

### Basic Page Template

```tsx
// repos/calypso/client/my-sites/[section]/[page]/index.tsx

import { useTranslate } from 'i18n-calypso';
import Main from 'calypso/components/main';
import NavigationHeader from 'calypso/components/navigation-header';
import { Card } from '@wordpress/components';

export default function MyNewPage() {
  const translate = useTranslate();
  
  return (
    <Main className="my-new-page">
      <NavigationHeader
        title={translate('Page Title')}
        subtitle={translate('Brief description of this page')}
      />
      
      <Card>
        {/* Page content goes here */}
      </Card>
    </Main>
  );
}
```

### Settings Page Template

```tsx
// repos/calypso/client/my-sites/settings/[setting]/index.tsx

import { useTranslate } from 'i18n-calypso';
import { useState } from 'react';
import Main from 'calypso/components/main';
import NavigationHeader from 'calypso/components/navigation-header';
import { 
  Card, 
  CardBody,
  TextControl,
  ToggleControl,
  Button 
} from '@wordpress/components';

export default function MySettingsPage() {
  const translate = useTranslate();
  const [setting, setSetting] = useState('');
  const [enabled, setEnabled] = useState(false);
  
  const handleSave = async () => {
    // Save logic here
  };
  
  return (
    <Main className="my-settings-page">
      <NavigationHeader
        title={translate('My Settings')}
      />
      
      <Card>
        <CardBody>
          <TextControl
            label={translate('Setting Name')}
            value={setting}
            onChange={setSetting}
          />
          
          <ToggleControl
            label={translate('Enable Feature')}
            checked={enabled}
            onChange={setEnabled}
          />
          
          <Button variant="primary" onClick={handleSave}>
            {translate('Save Settings')}
          </Button>
        </CardBody>
      </Card>
    </Main>
  );
}
```

### List Page Template

```tsx
// repos/calypso/client/my-sites/[section]/list/index.tsx

import { useTranslate } from 'i18n-calypso';
import Main from 'calypso/components/main';
import NavigationHeader from 'calypso/components/navigation-header';
import { Card, CardBody, Button } from '@wordpress/components';
import { plus } from '@wordpress/icons';

export default function MyListPage({ items }) {
  const translate = useTranslate();
  
  return (
    <Main className="my-list-page">
      <NavigationHeader
        title={translate('My Items')}
      >
        <Button variant="primary" icon={plus}>
          {translate('Add New')}
        </Button>
      </NavigationHeader>
      
      {items.length === 0 ? (
        <EmptyState />
      ) : (
        items.map(item => (
          <Card key={item.id}>
            <CardBody>
              <h3>{item.title}</h3>
              <p>{item.description}</p>
            </CardBody>
          </Card>
        ))
      )}
    </Main>
  );
}

function EmptyState() {
  const translate = useTranslate();
  return (
    <Card>
      <CardBody>
        <p>{translate('No items yet. Create your first one!')}</p>
      </CardBody>
    </Card>
  );
}
```

## Calypso Page Structure

### File Organization

```
client/my-sites/settings/my-feature/
├── index.tsx           # Main page component
├── style.scss          # Page styles
├── controller.tsx      # Route controller (if needed)
├── types.ts            # TypeScript types
└── components/         # Page-specific components
    ├── header.tsx
    └── form.tsx
```

### Styles Template

```scss
// style.scss
.my-feature-page {
  .card {
    margin-bottom: 16px;
  }
  
  .form-section {
    margin-bottom: 24px;
    
    &:last-child {
      margin-bottom: 0;
    }
  }
}
```

## Gutenberg Screen Patterns

### Settings Panel (Sidebar)

```tsx
// For block editor sidebars
import { PluginSidebar, PluginSidebarMoreMenuItem } from '@wordpress/edit-post';
import { PanelBody, TextControl, ToggleControl } from '@wordpress/components';
import { cog } from '@wordpress/icons';

function MyPluginSidebar() {
  return (
    <>
      <PluginSidebarMoreMenuItem target="my-sidebar">
        My Settings
      </PluginSidebarMoreMenuItem>
      
      <PluginSidebar
        name="my-sidebar"
        title="My Settings"
        icon={cog}
      >
        <PanelBody title="Options" initialOpen={true}>
          <TextControl
            label="Option 1"
            value={value}
            onChange={setValue}
          />
        </PanelBody>
      </PluginSidebar>
    </>
  );
}
```

### Block Inspector Controls

```tsx
// Block sidebar settings
import { InspectorControls } from '@wordpress/block-editor';
import { PanelBody, RangeControl, ColorPalette } from '@wordpress/components';

function Edit({ attributes, setAttributes }) {
  return (
    <>
      <InspectorControls>
        <PanelBody title="Settings">
          <RangeControl
            label="Columns"
            value={attributes.columns}
            onChange={(columns) => setAttributes({ columns })}
            min={1}
            max={4}
          />
        </PanelBody>
      </InspectorControls>
      
      <div>
        {/* Block content */}
      </div>
    </>
  );
}
```

## WordPress Admin Screen Templates

### Basic Admin Page (PHP)

```php
<?php
// repos/wordpress-core/src/wp-admin/my-page.php

/** WordPress Administration Bootstrap */
require_once __DIR__ . '/admin.php';

if (!current_user_can('manage_options')) {
    wp_die(__('Sorry, you are not allowed to access this page.'));
}

$title = __('My Page');

require_once ABSPATH . 'wp-admin/admin-header.php';
?>

<div class="wrap">
    <h1><?php echo esc_html($title); ?></h1>
    
    <div class="card">
        <h2><?php _e('Section Title'); ?></h2>
        <p><?php _e('Description text goes here.'); ?></p>
    </div>
</div>

<?php
require_once ABSPATH . 'wp-admin/admin-footer.php';
```

### Settings Page (PHP)

```php
<?php
// Register settings page
add_action('admin_menu', function() {
    add_options_page(
        __('My Settings'),      // Page title
        __('My Settings'),      // Menu title
        'manage_options',        // Capability
        'my-settings',          // Menu slug
        'my_settings_page'      // Callback
    );
});

// Register settings
add_action('admin_init', function() {
    register_setting('my_settings_group', 'my_option');
    
    add_settings_section(
        'my_section',
        __('General Settings'),
        '__return_null',
        'my-settings'
    );
    
    add_settings_field(
        'my_field',
        __('My Field'),
        'my_field_render',
        'my-settings',
        'my_section'
    );
});

function my_field_render() {
    $value = get_option('my_option');
    ?>
    <input type="text" name="my_option" value="<?php echo esc_attr($value); ?>">
    <?php
}

function my_settings_page() {
    ?>
    <div class="wrap">
        <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
        
        <form method="post" action="options.php">
            <?php
            settings_fields('my_settings_group');
            do_settings_sections('my-settings');
            submit_button();
            ?>
        </form>
    </div>
    <?php
}
```

## Common Page Layouts

### Two-Column Layout

```tsx
// Calypso
<Main className="two-column-page">
  <div className="two-column-page__sidebar">
    {/* Navigation or filters */}
  </div>
  <div className="two-column-page__content">
    {/* Main content */}
  </div>
</Main>
```

### Tabbed Page

```tsx
import { TabPanel } from '@wordpress/components';

<TabPanel
  tabs={[
    { name: 'general', title: 'General' },
    { name: 'advanced', title: 'Advanced' },
  ]}
>
  {(tab) => (
    <div>
      {tab.name === 'general' && <GeneralSettings />}
      {tab.name === 'advanced' && <AdvancedSettings />}
    </div>
  )}
</TabPanel>
```

## Response Pattern

When a designer asks to build a screen:

1. **Clarify the context** - Which repo? What type of page?
2. **Identify similar pages** - Show existing patterns
3. **Provide template** - Full working code
4. **Show file location** - Where to put the file
5. **Explain next steps** - Routing, testing, etc.
