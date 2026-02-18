# Rapid Prototyping and Scaffolding

This skill covers quick scaffolding techniques, Storybook prototyping workflows, and templates for common patterns across the WordPress ecosystem.

## Overview

Rapid prototyping in the WordPress ecosystem involves leveraging existing components, patterns, and tools to quickly validate ideas and build functional interfaces. This skill focuses on speed and iteration over perfection.

## Prototyping Philosophy

### Speed Over Perfection
- Use existing components before building new ones
- Focus on functionality first, polish later
- Leverage Storybook for isolated component development
- Build incrementally with quick feedback loops

### Validation-Driven Development
- Create clickable prototypes for user testing
- Test interactions and flows early
- Validate assumptions with real users
- Iterate based on feedback

## Quick Scaffolding Templates

### 1. Basic Page Scaffolds

#### Calypso Settings Page Scaffold
```javascript
import { useTranslate } from 'i18n-calypso';
import { Card, Button } from '@automattic/components';
import DocumentHead from 'calypso/components/data/document-head';
import Main from 'calypso/components/main';
import NavigationHeader from 'calypso/components/navigation-header';

const QuickSettingsPage = () => {
  const translate = useTranslate();
  
  return (
    <>
      <DocumentHead title={translate('Quick Settings Prototype')} />
      <NavigationHeader 
        title={translate('Settings')}
        subtitle={translate('Configure your options')}
      />
      <Main wideLayout>
        <Card>
          <h2>{translate('Quick Settings')}</h2>
          <p>{translate('This is a prototype - implement your settings here')}</p>
          
          {/* Quick form placeholder */}
          <div className="form-placeholder">
            <label>Setting Name</label>
            <input type="text" placeholder="Value" />
            <Button primary>{translate('Save')}</Button>
          </div>
        </Card>
      </Main>
    </>
  );
};

export default QuickSettingsPage;
```

#### WordPress Component Prototype
```javascript
import {
  Card,
  CardBody,
  CardHeader,
  Button,
  TextControl,
  ToggleControl,
  Spacer,
} from '@wordpress/components';
import { useState } from '@wordpress/element';
import { __ } from '@wordpress/i18n';

const QuickPrototype = () => {
  const [state, setState] = useState({
    text: '',
    enabled: false,
  });
  
  return (
    <Card>
      <CardHeader>
        <h2>{__('Prototype Component')}</h2>
      </CardHeader>
      <CardBody>
        <TextControl
          label={__('Text Setting')}
          value={state.text}
          onChange={(text) => setState({ ...state, text })}
        />
        
        <Spacer marginTop={4} />
        
        <ToggleControl
          label={__('Enable Feature')}
          checked={state.enabled}
          onChange={(enabled) => setState({ ...state, enabled })}
        />
        
        <Spacer marginTop={6} />
        
        <Button variant="primary">
          {__('Apply Changes')}
        </Button>
        
        {/* Debug state */}
        <details style={{ marginTop: '20px', fontSize: '12px' }}>
          <summary>Debug State</summary>
          <pre>{JSON.stringify(state, null, 2)}</pre>
        </details>
      </CardBody>
    </Card>
  );
};

export default QuickPrototype;
```

### 2. List/Table Scaffolds

#### Quick Data List
```javascript
import { useState } from 'react';
import { Card, Button, TextControl } from '@wordpress/components';
import { __ } from '@wordpress/i18n';

const QuickDataList = () => {
  const [items, setItems] = useState([
    { id: 1, name: 'Sample Item 1', status: 'active' },
    { id: 2, name: 'Sample Item 2', status: 'inactive' },
  ]);
  const [newItem, setNewItem] = useState('');
  
  const addItem = () => {
    if (newItem.trim()) {
      setItems([
        ...items,
        { 
          id: Date.now(), 
          name: newItem, 
          status: 'active' 
        }
      ]);
      setNewItem('');
    }
  };
  
  const removeItem = (id) => {
    setItems(items.filter(item => item.id !== id));
  };
  
  return (
    <Card>
      <div style={{ padding: '20px' }}>
        <h2>{__('Quick List Prototype')}</h2>
        
        {/* Add new item */}
        <div style={{ display: 'flex', gap: '12px', marginBottom: '20px' }}>
          <TextControl
            value={newItem}
            onChange={setNewItem}
            placeholder={__('New item name')}
          />
          <Button variant="primary" onClick={addItem}>
            {__('Add')}
          </Button>
        </div>
        
        {/* Items list */}
        <div>
          {items.map(item => (
            <div 
              key={item.id}
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '12px',
                border: '1px solid #ddd',
                borderRadius: '4px',
                marginBottom: '8px',
              }}
            >
              <span>
                <strong>{item.name}</strong>
                <span style={{ marginLeft: '12px', color: '#666' }}>
                  ({item.status})
                </span>
              </span>
              <Button
                variant="secondary"
                isDestructive
                size="small"
                onClick={() => removeItem(item.id)}
              >
                {__('Remove')}
              </Button>
            </div>
          ))}
        </div>
        
        {items.length === 0 && (
          <p style={{ textAlign: 'center', color: '#666', fontStyle: 'italic' }}>
            {__('No items yet. Add one above!')}
          </p>
        )}
      </div>
    </Card>
  );
};

export default QuickDataList;
```

### 3. Modal/Dialog Scaffolds

#### Quick Modal Pattern
```javascript
import { useState } from 'react';
import {
  Modal,
  Button,
  TextControl,
  TextareaControl,
  VStack,
  HStack,
} from '@wordpress/components';
import { __ } from '@wordpress/i18n';

const QuickModalDemo = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
  });
  
  const handleSave = () => {
    console.log('Saving:', formData);
    // Add actual save logic here
    setIsOpen(false);
  };
  
  const handleClose = () => {
    setFormData({ title: '', description: '' });
    setIsOpen(false);
  };
  
  return (
    <div>
      <Button variant="primary" onClick={() => setIsOpen(true)}>
        {__('Open Modal Prototype')}
      </Button>
      
      {isOpen && (
        <Modal
          title={__('Quick Modal')}
          onRequestClose={handleClose}
          style={{ maxWidth: '500px' }}
        >
          <VStack spacing={4}>
            <TextControl
              label={__('Title')}
              value={formData.title}
              onChange={(title) => setFormData({ ...formData, title })}
              placeholder={__('Enter title...')}
            />
            
            <TextareaControl
              label={__('Description')}
              value={formData.description}
              onChange={(description) => setFormData({ ...formData, description })}
              placeholder={__('Enter description...')}
              rows={4}
            />
            
            <HStack justify="flex-end" spacing={3}>
              <Button variant="tertiary" onClick={handleClose}>
                {__('Cancel')}
              </Button>
              <Button
                variant="primary"
                onClick={handleSave}
                disabled={!formData.title.trim()}
              >
                {__('Save')}
              </Button>
            </HStack>
          </VStack>
        </Modal>
      )}
    </div>
  );
};

export default QuickModalDemo;
```

## Storybook Prototyping Workflow

### 1. Component Story Template

#### Basic Story Structure
```javascript
// ComponentName.stories.js
import { ComponentName } from './ComponentName';

export default {
  title: 'Prototypes/ComponentName',
  component: ComponentName,
  parameters: {
    layout: 'centered',
  },
  argTypes: {
    variant: {
      control: { type: 'select' },
      options: ['primary', 'secondary', 'tertiary'],
    },
    size: {
      control: { type: 'select' },
      options: ['small', 'medium', 'large'],
    },
  },
};

// Default story
export const Default = {
  args: {
    children: 'Prototype Component',
    variant: 'primary',
    size: 'medium',
  },
};

// Variants for testing
export const AllVariants = () => (
  <div style={{ display: 'flex', gap: '12px' }}>
    <ComponentName variant="primary">Primary</ComponentName>
    <ComponentName variant="secondary">Secondary</ComponentName>
    <ComponentName variant="tertiary">Tertiary</ComponentName>
  </div>
);

// Interactive playground
export const Playground = {
  args: {
    children: 'Interactive Prototype',
    variant: 'primary',
    size: 'medium',
    onClick: () => alert('Clicked!'),
  },
};
```

#### Complex Story with State
```javascript
import { useState } from 'react';
import { FormPrototype } from './FormPrototype';

export default {
  title: 'Prototypes/Forms/FormPrototype',
  component: FormPrototype,
  decorators: [
    (Story) => (
      <div style={{ maxWidth: '600px', margin: '0 auto' }}>
        <Story />
      </div>
    ),
  ],
};

export const InteractiveForm = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: '',
  });
  
  const [submissions, setSubmissions] = useState([]);
  
  const handleSubmit = (data) => {
    setSubmissions([...submissions, { ...data, id: Date.now() }]);
    setFormData({ name: '', email: '', message: '' });
  };
  
  return (
    <div>
      <h2>Form Prototype</h2>
      <FormPrototype
        formData={formData}
        onChange={setFormData}
        onSubmit={handleSubmit}
      />
      
      {/* Show submissions for testing */}
      {submissions.length > 0 && (
        <div style={{ marginTop: '24px', padding: '16px', background: '#f0f0f0' }}>
          <h3>Submissions ({submissions.length})</h3>
          {submissions.map(submission => (
            <pre key={submission.id} style={{ fontSize: '12px' }}>
              {JSON.stringify(submission, null, 2)}
            </pre>
          ))}
        </div>
      )}
    </div>
  );
};
```

### 2. Rapid Story Creation

#### Story Generator Template
```bash
#!/bin/bash
# create-story.sh - Quick story generator

COMPONENT_NAME=$1
STORY_PATH="stories/${COMPONENT_NAME}.stories.js"

cat > "$STORY_PATH" << EOF
import { ${COMPONENT_NAME} } from '../src/${COMPONENT_NAME}';

export default {
  title: 'Prototypes/${COMPONENT_NAME}',
  component: ${COMPONENT_NAME},
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'Prototype component for testing ${COMPONENT_NAME} functionality.',
      },
    },
  },
};

export const Default = {
  args: {
    // Add default props here
  },
};

export const Variants = () => (
  <div style={{ display: 'flex', gap: '16px', flexDirection: 'column' }}>
    <${COMPONENT_NAME} />
    {/* Add more variants */}
  </div>
);

export const Interactive = () => {
  // Add interactive state here
  return <${COMPONENT_NAME} />;
};
EOF

echo "Created story: $STORY_PATH"
```

## Quick Layout Patterns

### 1. Dashboard Layout Scaffold
```javascript
import { Card, CardBody, CardHeader } from '@wordpress/components';

const DashboardPrototype = () => {
  return (
    <div style={{ display: 'grid', gap: '24px', maxWidth: '1200px' }}>
      {/* Header */}
      <div style={{ gridColumn: '1 / -1' }}>
        <h1>Dashboard Prototype</h1>
        <p>Quick dashboard layout for testing</p>
      </div>
      
      {/* Main content area */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: '2fr 1fr', 
        gap: '24px' 
      }}>
        {/* Main panel */}
        <Card>
          <CardHeader>
            <h2>Main Content</h2>
          </CardHeader>
          <CardBody>
            <p>Primary content area</p>
            {/* Add main content prototype here */}
          </CardBody>
        </Card>
        
        {/* Sidebar */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <Card size="small">
            <CardHeader>
              <h3>Quick Stats</h3>
            </CardHeader>
            <CardBody>
              <div>Stat 1: 123</div>
              <div>Stat 2: 456</div>
            </CardBody>
          </Card>
          
          <Card size="small">
            <CardHeader>
              <h3>Actions</h3>
            </CardHeader>
            <CardBody>
              <button>Action 1</button>
              <button>Action 2</button>
            </CardBody>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default DashboardPrototype;
```

### 2. Settings Page Layout
```javascript
import { 
  Card, 
  CardBody, 
  CardHeader,
  TabPanel,
  Button,
  ToggleControl,
  TextControl,
  Spacer,
} from '@wordpress/components';
import { __ } from '@wordpress/i18n';

const SettingsPrototype = () => {
  const tabs = [
    {
      name: 'general',
      title: __('General'),
      content: (
        <div>
          <TextControl
            label={__('Site Title')}
            placeholder={__('Enter site title')}
          />
          <Spacer marginTop={4} />
          <ToggleControl
            label={__('Enable Feature')}
            help={__('Turn this feature on or off')}
          />
        </div>
      ),
    },
    {
      name: 'advanced',
      title: __('Advanced'),
      content: (
        <div>
          <p>{__('Advanced settings go here')}</p>
          <ToggleControl
            label={__('Debug Mode')}
            help={__('Enable debug logging')}
          />
        </div>
      ),
    },
  ];
  
  return (
    <div style={{ maxWidth: '800px' }}>
      <Card>
        <CardHeader>
          <h1>{__('Settings Prototype')}</h1>
        </CardHeader>
        <CardBody>
          <TabPanel tabs={tabs}>
            {(tab) => (
              <div style={{ padding: '16px 0' }}>
                {tab.content}
                <Spacer marginTop={6} />
                <Button variant="primary">
                  {__('Save Changes')}
                </Button>
              </div>
            )}
          </TabPanel>
        </CardBody>
      </Card>
    </div>
  );
};

export default SettingsPrototype;
```

## Interactive Prototype Patterns

### 1. State Management Prototype
```javascript
import { useReducer } from 'react';
import { Button, Notice } from '@wordpress/components';

const initialState = {
  items: [],
  loading: false,
  error: null,
  selectedItems: [],
};

const reducer = (state, action) => {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_ITEMS':
      return { ...state, items: action.payload, loading: false };
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    case 'ADD_ITEM':
      return { 
        ...state, 
        items: [...state.items, action.payload] 
      };
    case 'TOGGLE_SELECTION':
      const itemId = action.payload;
      const isSelected = state.selectedItems.includes(itemId);
      return {
        ...state,
        selectedItems: isSelected 
          ? state.selectedItems.filter(id => id !== itemId)
          : [...state.selectedItems, itemId]
      };
    case 'CLEAR_SELECTION':
      return { ...state, selectedItems: [] };
    default:
      return state;
  }
};

const StatePrototype = () => {
  const [state, dispatch] = useReducer(reducer, initialState);
  
  const simulateLoad = () => {
    dispatch({ type: 'SET_LOADING', payload: true });
    
    setTimeout(() => {
      const mockItems = [
        { id: 1, name: 'Item 1', status: 'active' },
        { id: 2, name: 'Item 2', status: 'inactive' },
        { id: 3, name: 'Item 3', status: 'active' },
      ];
      dispatch({ type: 'SET_ITEMS', payload: mockItems });
    }, 1000);
  };
  
  return (
    <div>
      <h2>State Management Prototype</h2>
      
      {state.error && (
        <Notice status="error" isDismissible={false}>
          {state.error}
        </Notice>
      )}
      
      <div style={{ marginBottom: '16px' }}>
        <Button 
          variant="primary" 
          onClick={simulateLoad}
          isBusy={state.loading}
        >
          Load Items
        </Button>
        
        {state.selectedItems.length > 0 && (
          <Button
            variant="secondary"
            onClick={() => dispatch({ type: 'CLEAR_SELECTION' })}
            style={{ marginLeft: '8px' }}
          >
            Clear Selection ({state.selectedItems.length})
          </Button>
        )}
      </div>
      
      {state.items.length > 0 && (
        <div>
          <h3>Items:</h3>
          {state.items.map(item => (
            <div 
              key={item.id}
              style={{
                padding: '8px 12px',
                border: '1px solid #ddd',
                borderRadius: '4px',
                marginBottom: '4px',
                backgroundColor: state.selectedItems.includes(item.id) 
                  ? '#e7f3ff' 
                  : 'white',
                cursor: 'pointer',
              }}
              onClick={() => dispatch({ 
                type: 'TOGGLE_SELECTION', 
                payload: item.id 
              })}
            >
              <strong>{item.name}</strong> - {item.status}
            </div>
          ))}
        </div>
      )}
      
      {/* Debug state */}
      <details style={{ marginTop: '20px', fontSize: '12px' }}>
        <summary>Debug State</summary>
        <pre>{JSON.stringify(state, null, 2)}</pre>
      </details>
    </div>
  );
};

export default StatePrototype;
```

### 2. API Simulation Prototype
```javascript
import { useState, useEffect } from 'react';
import { Button, Card, Spinner } from '@wordpress/components';

// Mock API functions
const mockAPI = {
  fetchData: (delay = 1000) => 
    new Promise(resolve => 
      setTimeout(() => resolve([
        { id: 1, title: 'First Item', description: 'Description 1' },
        { id: 2, title: 'Second Item', description: 'Description 2' },
        { id: 3, title: 'Third Item', description: 'Description 3' },
      ]), delay)
    ),
    
  createItem: (item, delay = 500) =>
    new Promise(resolve =>
      setTimeout(() => resolve({
        ...item,
        id: Date.now(),
        createdAt: new Date().toISOString(),
      }), delay)
    ),
};

const APIPrototype = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [creating, setCreating] = useState(false);
  
  const loadData = async () => {
    setLoading(true);
    try {
      const items = await mockAPI.fetchData();
      setData(items);
    } catch (error) {
      console.error('Failed to load:', error);
    } finally {
      setLoading(false);
    }
  };
  
  const createItem = async () => {
    setCreating(true);
    try {
      const newItem = await mockAPI.createItem({
        title: `New Item ${data.length + 1}`,
        description: `Generated at ${new Date().toLocaleTimeString()}`,
      });
      setData([...data, newItem]);
    } catch (error) {
      console.error('Failed to create:', error);
    } finally {
      setCreating(false);
    }
  };
  
  useEffect(() => {
    loadData();
  }, []);
  
  return (
    <Card>
      <div style={{ padding: '20px' }}>
        <h2>API Simulation Prototype</h2>
        
        <div style={{ marginBottom: '16px' }}>
          <Button 
            variant="primary" 
            onClick={loadData}
            isBusy={loading}
          >
            Refresh Data
          </Button>
          
          <Button
            variant="secondary"
            onClick={createItem}
            isBusy={creating}
            style={{ marginLeft: '8px' }}
          >
            Add Item
          </Button>
        </div>
        
        {loading ? (
          <div style={{ textAlign: 'center', padding: '40px' }}>
            <Spinner />
            <p>Loading data...</p>
          </div>
        ) : (
          <div>
            <p>Total items: {data.length}</p>
            
            {data.map(item => (
              <div
                key={item.id}
                style={{
                  padding: '12px',
                  border: '1px solid #ddd',
                  borderRadius: '4px',
                  marginBottom: '8px',
                }}
              >
                <h4>{item.title}</h4>
                <p>{item.description}</p>
                {item.createdAt && (
                  <small style={{ color: '#666' }}>
                    Created: {new Date(item.createdAt).toLocaleString()}
                  </small>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </Card>
  );
};

export default APIPrototype;
```

## Prototype Testing Utilities

### 1. Debug Panel Component
```javascript
import { useState } from 'react';
import { Button, Card } from '@wordpress/components';

const DebugPanel = ({ data, label = 'Debug Data' }) => {
  const [isOpen, setIsOpen] = useState(false);
  
  return (
    <Card 
      size="small" 
      style={{ 
        position: 'fixed', 
        bottom: '20px', 
        right: '20px',
        zIndex: 9999,
        minWidth: '300px',
        maxHeight: isOpen ? '400px' : 'auto',
        overflow: 'auto',
        backgroundColor: '#f0f0f0',
      }}
    >
      <div style={{ padding: '12px' }}>
        <Button
          variant="tertiary"
          size="small"
          onClick={() => setIsOpen(!isOpen)}
        >
          {label} {isOpen ? '▼' : '▶'}
        </Button>
        
        {isOpen && (
          <div style={{ marginTop: '8px' }}>
            <pre style={{ 
              fontSize: '11px', 
              overflow: 'auto',
              maxHeight: '300px',
            }}>
              {JSON.stringify(data, null, 2)}
            </pre>
          </div>
        )}
      </div>
    </Card>
  );
};

export default DebugPanel;
```

### 2. Prototype Wrapper
```javascript
import { useState } from 'react';
import DebugPanel from './DebugPanel';

const PrototypeWrapper = ({ 
  children, 
  title,
  debugData,
  showDebug = true,
  maxWidth = '1200px' 
}) => {
  const [debugOpen, setDebugOpen] = useState(false);
  
  return (
    <div style={{ 
      maxWidth, 
      margin: '0 auto', 
      padding: '20px',
      position: 'relative' 
    }}>
      {title && (
        <div style={{ 
          marginBottom: '24px',
          paddingBottom: '12px',
          borderBottom: '2px solid #ddd' 
        }}>
          <h1 style={{ margin: 0, color: '#0073aa' }}>
            🚧 {title} (Prototype)
          </h1>
        </div>
      )}
      
      {children}
      
      {showDebug && debugData && (
        <DebugPanel data={debugData} label="Prototype Debug" />
      )}
    </div>
  );
};

export default PrototypeWrapper;
```

## Prototyping Best Practices

### 1. Start with User Goals
```javascript
// Define user stories in component comments
/**
 * USER STORY: As a site admin, I want to quickly toggle features
 * so that I can experiment with different configurations.
 * 
 * ACCEPTANCE CRITERIA:
 * - Toggle switches are clearly labeled
 * - Changes are saved immediately
 * - Visual feedback shows current state
 * - Undo option is available
 */
const FeatureTogglePrototype = () => {
  // Implementation here...
};
```

### 2. Build in Feedback Mechanisms
```javascript
const PrototypeWithFeedback = () => {
  const [feedback, setFeedback] = useState('');
  
  const sendFeedback = () => {
    console.log('Prototype feedback:', feedback);
    // In real implementation: send to analytics or feedback system
    alert('Feedback recorded! Thank you.');
    setFeedback('');
  };
  
  return (
    <div>
      {/* Main prototype content */}
      
      {/* Feedback panel */}
      <div style={{
        position: 'fixed',
        bottom: '20px',
        left: '20px',
        backgroundColor: '#fff',
        border: '1px solid #ddd',
        borderRadius: '4px',
        padding: '12px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
      }}>
        <h4 style={{ margin: '0 0 8px 0' }}>💭 Prototype Feedback</h4>
        <textarea
          value={feedback}
          onChange={(e) => setFeedback(e.target.value)}
          placeholder="How does this prototype work for you?"
          rows={3}
          style={{ width: '200px', marginBottom: '8px' }}
        />
        <Button
          size="small"
          variant="primary"
          onClick={sendFeedback}
          disabled={!feedback.trim()}
        >
          Send Feedback
        </Button>
      </div>
    </div>
  );
};
```

### 3. Version Your Prototypes
```javascript
const PROTOTYPE_VERSION = '0.2.1';
const PROTOTYPE_CHANGES = [
  'Added bulk actions',
  'Improved mobile layout',
  'Fixed search functionality',
];

const VersionedPrototype = () => {
  return (
    <div>
      <div style={{ 
        backgroundColor: '#fff3cd', 
        padding: '8px 12px',
        marginBottom: '16px',
        borderRadius: '4px',
      }}>
        <small>
          <strong>Prototype v{PROTOTYPE_VERSION}</strong>
          <details style={{ marginTop: '4px' }}>
            <summary>Recent changes</summary>
            <ul style={{ margin: '8px 0' }}>
              {PROTOTYPE_CHANGES.map(change => (
                <li key={change}>{change}</li>
              ))}
            </ul>
          </details>
        </small>
      </div>
      
      {/* Prototype content */}
    </div>
  );
};
```

This rapid prototyping approach allows for quick iteration and validation of ideas before committing to full implementation, ensuring that the final product meets user needs and expectations.