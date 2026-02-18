# Screen and Page Building

This skill covers creating new screens and pages across the WordPress ecosystem, including Calypso page templates, Gutenberg sidebar/inspector patterns, WordPress Core admin pages, and responsive design patterns.

## Overview

Building screens in the WordPress ecosystem involves understanding the specific patterns and conventions for each platform. This skill provides templates, patterns, and workflows for creating consistent, functional interfaces across Calypso, Gutenberg, and WordPress Core.

## Screen Architecture Patterns

### 1. Calypso Page Patterns

#### Basic Page Template
```javascript
import { useTranslate } from 'i18n-calypso';
import { Card } from '@automattic/components';
import DocumentHead from 'calypso/components/data/document-head';
import Main from 'calypso/components/main';
import NavigationHeader from 'calypso/components/navigation-header';

const MyFeaturePage = () => {
  const translate = useTranslate();
  
  return (
    <>
      <DocumentHead title={translate('My Feature')} />
      <NavigationHeader 
        title={translate('My Feature')}
        subtitle={translate('Manage your feature settings')}
      />
      <Main wideLayout>
        <Card>
          <h2>{translate('Feature Settings')}</h2>
          {/* Page content */}
        </Card>
      </Main>
    </>
  );
};

export default MyFeaturePage;
```

#### Settings Page Template
```javascript
import { useState } from 'react';
import { useTranslate } from 'i18n-calypso';
import { Button, Card, FormToggle } from '@automattic/components';
import QuerySettings from 'calypso/components/data/query-settings';
import { useSelector, useDispatch } from 'react-redux';
import { saveSiteSettings } from 'calypso/state/site-settings/actions';

const SettingsPage = ({ siteId }) => {
  const translate = useTranslate();
  const dispatch = useDispatch();
  
  const settings = useSelector(state => 
    getSiteSettings(state, siteId)
  );
  
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const handleSave = async () => {
    setIsSubmitting(true);
    try {
      await dispatch(saveSiteSettings(siteId, settings));
    } finally {
      setIsSubmitting(false);
    }
  };
  
  return (
    <>
      <QuerySettings siteId={siteId} />
      <Card>
        <form>
          <FormToggle
            checked={settings.myFeatureEnabled}
            onChange={(enabled) => 
              updateSetting('myFeatureEnabled', enabled)
            }
          >
            {translate('Enable My Feature')}
          </FormToggle>
          
          <Button
            primary
            busy={isSubmitting}
            onClick={handleSave}
          >
            {translate('Save Changes')}
          </Button>
        </form>
      </Card>
    </>
  );
};
```

#### List/Table Page Template
```javascript
import { useTranslate } from 'i18n-calypso';
import { Button, Card, DataTable } from '@automattic/components';
import { useInfiniteQuery } from '@tanstack/react-query';
import { fetchItems } from './api';

const ItemListPage = () => {
  const translate = useTranslate();
  
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['items'],
    queryFn: ({ pageParam = 1 }) => fetchItems({ page: pageParam }),
    getNextPageParam: (lastPage) => lastPage.nextPage,
  });
  
  const columns = [
    { key: 'name', title: translate('Name') },
    { key: 'status', title: translate('Status') },
    { key: 'created', title: translate('Created') },
  ];
  
  const items = data?.pages.flatMap(page => page.items) || [];
  
  return (
    <Card>
      <div className="list-header">
        <h2>{translate('Items')}</h2>
        <Button primary>
          {translate('Add New')}
        </Button>
      </div>
      
      <DataTable
        columns={columns}
        data={items}
        onRowClick={(item) => navigate(`/item/${item.id}`)}
      />
      
      {hasNextPage && (
        <Button
          onClick={fetchNextPage}
          busy={isFetchingNextPage}
        >
          {translate('Load More')}
        </Button>
      )}
    </Card>
  );
};
```

### 2. Gutenberg Sidebar/Inspector Patterns

#### Block Inspector Controls
```javascript
import {
  InspectorControls,
  useBlockProps,
  RichText,
} from '@wordpress/block-editor';
import {
  PanelBody,
  ToggleControl,
  RangeControl,
  SelectControl,
  ColorPicker,
} from '@wordpress/components';
import { __ } from '@wordpress/i18n';

const MyBlockEdit = ({ attributes, setAttributes }) => {
  const blockProps = useBlockProps();
  
  return (
    <>
      <InspectorControls>
        <PanelBody title={__('Settings')}>
          <ToggleControl
            label={__('Enable Feature')}
            checked={attributes.featureEnabled}
            onChange={(featureEnabled) => setAttributes({ featureEnabled })}
          />
          
          <RangeControl
            label={__('Size')}
            value={attributes.size}
            onChange={(size) => setAttributes({ size })}
            min={1}
            max={10}
          />
          
          <SelectControl
            label={__('Style')}
            value={attributes.style}
            options={[
              { label: __('Default'), value: 'default' },
              { label: __('Rounded'), value: 'rounded' },
              { label: __('Square'), value: 'square' },
            ]}
            onChange={(style) => setAttributes({ style })}
          />
        </PanelBody>
        
        <PanelBody title={__('Colors')} initialOpen={false}>
          <ColorPicker
            label={__('Background Color')}
            color={attributes.backgroundColor}
            onChangeComplete={(color) => 
              setAttributes({ backgroundColor: color.hex })
            }
          />
        </PanelBody>
      </InspectorControls>
      
      <div {...blockProps}>
        <RichText
          tagName="h3"
          value={attributes.title}
          onChange={(title) => setAttributes({ title })}
          placeholder={__('Enter title...')}
        />
      </div>
    </>
  );
};
```

#### Plugin Sidebar Panel
```javascript
import { registerPlugin } from '@wordpress/plugins';
import { PluginSidebar, PluginSidebarMoreMenuItem } from '@wordpress/edit-post';
import { PanelBody, Button } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

const MyPluginSidebar = () => (
  <>
    <PluginSidebarMoreMenuItem
      target="my-plugin-sidebar"
      icon="admin-plugins"
    >
      {__('My Plugin')}
    </PluginSidebarMoreMenuItem>
    
    <PluginSidebar
      name="my-plugin-sidebar"
      title={__('My Plugin Settings')}
      icon="admin-plugins"
    >
      <PanelBody>
        <h3>{__('Plugin Options')}</h3>
        <Button isPrimary>
          {__('Perform Action')}
        </Button>
      </PanelBody>
    </PluginSidebar>
  </>
);

registerPlugin('my-plugin-sidebar', {
  render: MyPluginSidebar,
});
```

### 3. WordPress Core Admin Page Patterns

#### Basic Admin Page
```php
function my_plugin_admin_page() {
    if (!current_user_can('manage_options')) {
        return;
    }
    
    // Handle form submission
    if (isset($_POST['submit'])) {
        check_admin_referer('my_plugin_settings');
        
        $option_value = sanitize_text_field($_POST['my_option']);
        update_option('my_plugin_option', $option_value);
        
        add_settings_error(
            'my_plugin_messages',
            'my_plugin_message',
            __('Settings Saved', 'my-plugin'),
            'updated'
        );
    }
    
    $option_value = get_option('my_plugin_option', '');
    
    ?>
    <div class="wrap">
        <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
        
        <?php settings_errors('my_plugin_messages'); ?>
        
        <form action="" method="post">
            <?php wp_nonce_field('my_plugin_settings'); ?>
            
            <table class="form-table">
                <tr>
                    <th scope="row">
                        <label for="my_option"><?php _e('My Setting', 'my-plugin'); ?></label>
                    </th>
                    <td>
                        <input 
                            type="text" 
                            id="my_option" 
                            name="my_option" 
                            value="<?php echo esc_attr($option_value); ?>"
                            class="regular-text"
                        />
                    </td>
                </tr>
            </table>
            
            <?php submit_button(); ?>
        </form>
    </div>
    <?php
}
```

#### Settings API Page
```php
class My_Plugin_Settings {
    public function __construct() {
        add_action('admin_menu', [$this, 'add_admin_page']);
        add_action('admin_init', [$this, 'register_settings']);
    }
    
    public function add_admin_page() {
        add_options_page(
            __('My Plugin Settings', 'my-plugin'),
            __('My Plugin', 'my-plugin'),
            'manage_options',
            'my-plugin-settings',
            [$this, 'render_admin_page']
        );
    }
    
    public function register_settings() {
        // Register setting
        register_setting('my_plugin_group', 'my_plugin_options', [
            'sanitize_callback' => [$this, 'sanitize_options']
        ]);
        
        // Add section
        add_settings_section(
            'my_plugin_section',
            __('Main Settings', 'my-plugin'),
            [$this, 'section_callback'],
            'my-plugin-settings'
        );
        
        // Add fields
        add_settings_field(
            'enable_feature',
            __('Enable Feature', 'my-plugin'),
            [$this, 'checkbox_field_callback'],
            'my-plugin-settings',
            'my_plugin_section',
            ['field' => 'enable_feature']
        );
    }
    
    public function render_admin_page() {
        ?>
        <div class="wrap">
            <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
            
            <form action="options.php" method="post">
                <?php
                settings_fields('my_plugin_group');
                do_settings_sections('my-plugin-settings');
                submit_button();
                ?>
            </form>
        </div>
        <?php
    }
    
    public function checkbox_field_callback($args) {
        $options = get_option('my_plugin_options', []);
        $field = $args['field'];
        $value = isset($options[$field]) ? $options[$field] : 0;
        
        printf(
            '<input type="checkbox" id="%s" name="my_plugin_options[%s]" value="1" %s />',
            esc_attr($field),
            esc_attr($field),
            checked(1, $value, false)
        );
    }
}

new My_Plugin_Settings();
```

## Responsive Design Patterns

### Mobile-First Approach

#### Calypso Responsive Utilities
```scss
// Use Calypso's responsive mixins
.my-component {
  padding: 16px;
  
  @include breakpoint-deprecated( '>660px' ) {
    padding: 24px;
  }
  
  @include breakpoint-deprecated( '>960px' ) {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
  }
}
```

#### WordPress Components Responsive
```javascript
import { useBreakpointIndex } from '@wordpress/compose';

const ResponsiveComponent = () => {
  const breakpointIndex = useBreakpointIndex();
  const isMobile = breakpointIndex < 2; // < 768px
  const isTablet = breakpointIndex === 2; // 768px - 1079px
  const isDesktop = breakpointIndex > 2; // > 1080px
  
  return (
    <div className={`
      responsive-component
      ${isMobile ? 'is-mobile' : ''}
      ${isTablet ? 'is-tablet' : ''}
      ${isDesktop ? 'is-desktop' : ''}
    `}>
      {isMobile ? <MobileLayout /> : <DesktopLayout />}
    </div>
  );
};
```

#### CSS Grid Responsive Patterns
```css
/* Mobile-first grid layout */
.content-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: 1fr;
}

/* Tablet */
@media (min-width: 768px) {
  .content-grid {
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .content-grid {
    grid-template-columns: 1fr 2fr 1fr;
    gap: 2rem;
  }
}
```

## Component Composition Patterns

### Higher-Order Components

#### With Loading States
```javascript
const withLoadingState = (WrappedComponent) => {
  return ({ isLoading, ...props }) => {
    if (isLoading) {
      return <Spinner />;
    }
    
    return <WrappedComponent {...props} />;
  };
};

const MyPageWithLoading = withLoadingState(MyPage);
```

#### With Error Boundaries
```javascript
import { Component } from 'react';

class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }
  
  static getDerivedStateFromError(error) {
    return { hasError: true };
  }
  
  componentDidCatch(error, errorInfo) {
    console.error('Error boundary caught error:', error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return (
        <Card>
          <h2>Something went wrong.</h2>
          <Button onClick={() => window.location.reload()}>
            Reload Page
          </Button>
        </Card>
      );
    }
    
    return this.props.children;
  }
}
```

## Navigation and Routing Patterns

### Calypso Navigation
```javascript
import { useNavigate } from 'calypso/lib/navigate';
import { addQueryArgs } from 'calypso/lib/url';

const NavigationExample = ({ siteId }) => {
  const navigate = useNavigate();
  
  const handleNavigation = (path, query = {}) => {
    const url = addQueryArgs(query, path);
    navigate(url);
  };
  
  return (
    <nav>
      <Button onClick={() => handleNavigation(`/settings/${siteId}`)}>
        Settings
      </Button>
      <Button onClick={() => handleNavigation(`/posts/${siteId}`, { status: 'draft' })}>
        Draft Posts
      </Button>
    </nav>
  );
};
```

### WordPress Admin Navigation
```php
function my_plugin_admin_menu() {
    // Main menu page
    add_menu_page(
        __('My Plugin', 'my-plugin'),
        __('My Plugin', 'my-plugin'),
        'manage_options',
        'my-plugin',
        'my_plugin_main_page',
        'dashicons-admin-generic',
        30
    );
    
    // Submenu pages
    add_submenu_page(
        'my-plugin',
        __('Settings', 'my-plugin'),
        __('Settings', 'my-plugin'),
        'manage_options',
        'my-plugin-settings',
        'my_plugin_settings_page'
    );
    
    add_submenu_page(
        'my-plugin',
        __('Tools', 'my-plugin'),
        __('Tools', 'my-plugin'),
        'manage_options',
        'my-plugin-tools',
        'my_plugin_tools_page'
    );
}
add_action('admin_menu', 'my_plugin_admin_menu');
```

## Form Patterns and Validation

### Calypso Form Handling
```javascript
import { useFormState } from 'calypso/lib/form-state';
import { Card, FormTextInput, FormButton } from '@automattic/components';

const MyForm = ({ onSubmit }) => {
  const [form, setForm] = useFormState({
    initialFields: {
      name: '',
      email: '',
    },
    validatorFunction: (fieldValues, onComplete) => {
      const errors = {};
      
      if (!fieldValues.name) {
        errors.name = 'Name is required';
      }
      
      if (!fieldValues.email || !isValidEmail(fieldValues.email)) {
        errors.email = 'Valid email is required';
      }
      
      onComplete(null, errors);
    },
  });
  
  const handleSubmit = (event) => {
    event.preventDefault();
    
    if (!form.isValid()) {
      return;
    }
    
    onSubmit(form.getAllFieldValues());
  };
  
  return (
    <Card>
      <form onSubmit={handleSubmit}>
        <FormTextInput
          name="name"
          value={form.getFieldValue('name')}
          onChange={setForm}
          isError={form.isFieldInvalid('name')}
          placeholder="Your name"
        />
        
        <FormTextInput
          name="email"
          type="email"
          value={form.getFieldValue('email')}
          onChange={setForm}
          isError={form.isFieldInvalid('email')}
          placeholder="your.email@example.com"
        />
        
        <FormButton
          type="submit"
          disabled={form.isSubmitting()}
        >
          Submit
        </FormButton>
      </form>
    </Card>
  );
};
```

## Performance Optimization Patterns

### Code Splitting
```javascript
import { lazy, Suspense } from 'react';
import { Spinner } from '@automattic/components';

// Lazy load heavy components
const HeavyComponent = lazy(() => import('./HeavyComponent'));

const MyPage = () => {
  return (
    <div>
      <h1>My Page</h1>
      <Suspense fallback={<Spinner />}>
        <HeavyComponent />
      </Suspense>
    </div>
  );
};
```

### Memoization
```javascript
import { memo, useMemo } from 'react';

const ExpensiveComponent = memo(({ data, filters }) => {
  const processedData = useMemo(() => {
    return data.filter(filters.filterFunction)
               .sort(filters.sortFunction);
  }, [data, filters]);
  
  return (
    <div>
      {processedData.map(item => (
        <ItemComponent key={item.id} item={item} />
      ))}
    </div>
  );
});
```

## Testing Patterns

### Component Testing
```javascript
import { render, screen, fireEvent } from '@testing-library/react';
import { MyComponent } from '../MyComponent';

describe('MyComponent', () => {
  test('renders with correct title', () => {
    render(<MyComponent title="Test Title" />);
    expect(screen.getByText('Test Title')).toBeInTheDocument();
  });
  
  test('handles button click', () => {
    const handleClick = jest.fn();
    render(<MyComponent onButtonClick={handleClick} />);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalled();
  });
  
  test('shows loading state', () => {
    render(<MyComponent isLoading={true} />);
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });
});
```

## Accessibility Patterns

### ARIA Labels and Roles
```javascript
const AccessibleComponent = () => {
  return (
    <div role="main" aria-labelledby="page-title">
      <h1 id="page-title">Page Title</h1>
      
      <button
        aria-describedby="button-help"
        onClick={handleAction}
      >
        Action Button
      </button>
      <div id="button-help" className="screen-reader-text">
        This button performs the main action
      </div>
      
      <form role="form" aria-label="Contact form">
        <label htmlFor="email">Email Address</label>
        <input
          id="email"
          type="email"
          aria-required="true"
          aria-describedby="email-error"
        />
        <div id="email-error" role="alert">
          {emailError}
        </div>
      </form>
    </div>
  );
};
```

These patterns provide the foundation for building consistent, accessible, and performant screens across the WordPress ecosystem. Always consider the specific platform conventions and user experience patterns when implementing new interfaces.