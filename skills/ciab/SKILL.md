# CIAB (Commerce in a Box) Development

This skill covers working with CIAB, Automattic's internal commerce admin tool, including its SPA architecture, route system, components, state management, and integration patterns.

## Overview

CIAB (Commerce in a Box) is an internal Automattic tool that provides a React-based Single Page Application (SPA) replacement for WordPress admin interfaces. It's built with React/TypeScript, Node 22, and pnpm, and requires Automattic access.

**Note**: This is a private repository requiring Automattic access. The content here assumes authorized access to the codebase.

## Repository Structure

### Core Architecture
```
ciab/
├── src/                  # Main source code
│   ├── components/       # Reusable React components
│   ├── pages/           # Route-based page components
│   ├── hooks/           # Custom React hooks
│   ├── utils/           # Utility functions
│   └── api/             # API integration layer
├── public/              # Static assets
├── build/               # Built application
└── wp-admin/            # WordPress integration
```

### Development Setup

#### Prerequisites
- Node 22 (use nvm)
- pnpm package manager
- Composer for PHP dependencies
- Automattic access credentials
- Docker Desktop (for local WordPress environment)

#### Setup Commands
```bash
cd repos/ciab
source ~/.nvm/nvm.sh && nvm use
pnpm install
composer install
```

#### Development Server
```bash
pnpm dev  # → http://localhost:9001/wp-admin/
```

## SPA Architecture

### Route Auto-Discovery
CIAB implements an intelligent route system that automatically discovers and renders appropriate admin pages:

```javascript
// Route detection patterns
const routes = {
  '/wp-admin/admin.php?page=commerce': CommerceMainPage,
  '/wp-admin/admin.php?page=orders': OrdersPage,
  '/wp-admin/admin.php?page=products': ProductsPage,
  '/wp-admin/users.php': UsersPage,
};

// Auto-discovery based on URL patterns
const autoRoute = (pathname, search) => {
  const fullPath = `${pathname}${search}`;
  return routes[fullPath] || detectPageFromQuery(search);
};
```

### TanStack Router Integration
CIAB uses TanStack Router for client-side routing:

```javascript
import { Router, Route, RootRoute } from '@tanstack/react-router';

const rootRoute = new RootRoute({
  component: AppLayout,
});

const commerceRoute = new Route({
  getParentRoute: () => rootRoute,
  path: '/commerce',
  component: CommerceMainPage,
});

const router = new Router({
  routeTree: rootRoute.addChildren([commerceRoute]),
});
```

### WordPress Admin Integration
CIAB seamlessly replaces WordPress admin pages:

```php
// PHP integration hook
add_action( 'admin_enqueue_scripts', function( $hook_suffix ) {
    if ( ciab_should_replace_page( $hook_suffix ) ) {
        // Dequeue WordPress admin assets
        wp_dequeue_script( 'wp-admin' );
        
        // Enqueue CIAB SPA
        wp_enqueue_script( 'ciab-app', CIAB_URL . '/build/app.js', [], CIAB_VERSION );
        wp_enqueue_style( 'ciab-app', CIAB_URL . '/build/app.css', [], CIAB_VERSION );
    }
} );
```

## Component Architecture

### Design System Integration
CIAB uses `@automattic/design-system` for consistent UI components:

```javascript
import {
  Card,
  CardBody,
  CardHeader,
  Button,
  FormControl,
  Stack,
} from '@automattic/design-system';

const MyPage = () => (
  <Card>
    <CardHeader>
      <h2>Page Title</h2>
    </CardHeader>
    <CardBody>
      <Stack spacing={4}>
        <FormControl label="Setting Name">
          <input type="text" />
        </FormControl>
        <Button variant="primary">Save Changes</Button>
      </Stack>
    </CardBody>
  </Card>
);
```

### Page Components
Each admin page is a React component:

```javascript
import { useEffect } from 'react';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import { PageLayout } from '../components/PageLayout';

const OrdersPage = () => {
  useDocumentTitle('Orders');
  
  return (
    <PageLayout title="Orders" breadcrumb={['Commerce', 'Orders']}>
      <OrdersList />
      <OrdersFilters />
    </PageLayout>
  );
};

export default OrdersPage;
```

### Reusable Components

#### Data Tables
```javascript
import { DataTable } from '../components/DataTable';

const OrdersList = () => {
  const columns = [
    { key: 'id', title: 'Order ID' },
    { key: 'customer', title: 'Customer' },
    { key: 'total', title: 'Total', render: value => `$${value}` },
    { key: 'status', title: 'Status', render: value => <StatusBadge status={value} /> },
  ];

  return (
    <DataTable
      columns={columns}
      data={orders}
      onRowClick={handleOrderClick}
      pagination={{ pageSize: 20 }}
    />
  );
};
```

#### Form Components
```javascript
import { useForm } from 'react-hook-form';
import { FormField } from '../components/FormField';

const ProductForm = () => {
  const { register, handleSubmit, formState: { errors } } = useForm();

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <FormField 
        label="Product Name"
        error={errors.name}
        {...register('name', { required: 'Name is required' })}
      />
      <FormField 
        label="Price"
        type="number"
        error={errors.price}
        {...register('price', { required: 'Price is required' })}
      />
    </form>
  );
};
```

## State Management

### React Query Integration
CIAB uses React Query (TanStack Query) for server state:

```javascript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../api';

const useOrders = (filters = {}) => {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => api.orders.list(filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

const useUpdateOrder = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }) => api.orders.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['orders']);
    },
  });
};
```

### Local State Management
```javascript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useAppStore = create(
  persist(
    (set, get) => ({
      sidebarCollapsed: false,
      currentView: 'list',
      filters: {},
      
      toggleSidebar: () => set(state => ({ 
        sidebarCollapsed: !state.sidebarCollapsed 
      })),
      
      setView: (view) => set({ currentView: view }),
      
      updateFilters: (newFilters) => set(state => ({
        filters: { ...state.filters, ...newFilters }
      })),
    }),
    {
      name: 'ciab-app-state',
      partialize: (state) => ({ 
        sidebarCollapsed: state.sidebarCollapsed,
        currentView: state.currentView,
      }),
    }
  )
);
```

## API Integration

### WordPress REST API
CIAB integrates with WordPress and WooCommerce REST APIs:

```javascript
import apiFetch from '@wordpress/api-fetch';

class OrdersAPI {
  static async list(params = {}) {
    const queryString = new URLSearchParams(params).toString();
    return apiFetch({
      path: `/wc/v3/orders?${queryString}`,
      method: 'GET',
    });
  }
  
  static async get(id) {
    return apiFetch({
      path: `/wc/v3/orders/${id}`,
      method: 'GET',
    });
  }
  
  static async update(id, data) {
    return apiFetch({
      path: `/wc/v3/orders/${id}`,
      method: 'PUT',
      data,
    });
  }
}
```

### Custom API Endpoints
```javascript
// Custom CIAB endpoints
class CIABApi {
  static async getDashboardStats() {
    return apiFetch({
      path: '/ciab/v1/dashboard/stats',
      method: 'GET',
    });
  }
  
  static async exportData(type, filters) {
    return apiFetch({
      path: '/ciab/v1/export',
      method: 'POST',
      data: { type, filters },
    });
  }
}
```

## Development Patterns

### Page Composition
```javascript
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import { PageSkeleton } from '../components/PageSkeleton';
import { ErrorFallback } from '../components/ErrorFallback';

const PageWrapper = ({ children }) => (
  <ErrorBoundary FallbackComponent={ErrorFallback}>
    <Suspense fallback={<PageSkeleton />}>
      {children}
    </Suspense>
  </ErrorBoundary>
);
```

### Custom Hooks
```javascript
// Data fetching hook
export const useOrderData = (orderId) => {
  const { data: order, isLoading } = useQuery({
    queryKey: ['order', orderId],
    queryFn: () => OrdersAPI.get(orderId),
    enabled: !!orderId,
  });
  
  const { data: orderItems } = useQuery({
    queryKey: ['order-items', orderId],
    queryFn: () => OrdersAPI.getItems(orderId),
    enabled: !!orderId,
  });
  
  return {
    order,
    orderItems,
    isLoading,
  };
};

// UI state hook
export const usePageActions = () => {
  const [selectedItems, setSelectedItems] = useState([]);
  const [bulkAction, setBulkAction] = useState('');
  
  const clearSelection = useCallback(() => {
    setSelectedItems([]);
    setBulkAction('');
  }, []);
  
  return {
    selectedItems,
    setSelectedItems,
    bulkAction,
    setBulkAction,
    clearSelection,
  };
};
```

### Navigation Integration
```javascript
import { useNavigate, useLocation } from '@tanstack/react-router';

const NavigationMenu = () => {
  const navigate = useNavigate();
  const location = useLocation();
  
  const menuItems = [
    { path: '/commerce/orders', label: 'Orders', icon: 'receipt' },
    { path: '/commerce/products', label: 'Products', icon: 'package' },
    { path: '/commerce/customers', label: 'Customers', icon: 'users' },
  ];
  
  return (
    <nav>
      {menuItems.map(item => (
        <button
          key={item.path}
          className={location.pathname === item.path ? 'active' : ''}
          onClick={() => navigate({ to: item.path })}
        >
          <Icon name={item.icon} />
          {item.label}
        </button>
      ))}
    </nav>
  );
};
```

## WordPress Integration

### Admin Menu Replacement
```php
// Replace WordPress admin menus with CIAB pages
function ciab_modify_admin_menu() {
    // Remove original WooCommerce menus
    remove_menu_page( 'woocommerce' );
    
    // Add CIAB menu items that trigger SPA routes
    add_menu_page(
        'Commerce',
        'Commerce',
        'manage_woocommerce',
        'commerce',
        'ciab_render_spa_page',
        'dashicons-store',
        56
    );
    
    add_submenu_page(
        'commerce',
        'Orders',
        'Orders',
        'manage_woocommerce',
        'commerce-orders',
        'ciab_render_spa_page'
    );
}
add_action( 'admin_menu', 'ciab_modify_admin_menu' );
```

### Asset Loading Strategy
```php
function ciab_enqueue_assets( $hook_suffix ) {
    $ciab_pages = ['commerce', 'commerce-orders', 'commerce-products'];
    
    if ( in_array( $hook_suffix, $ciab_pages ) ) {
        // Disable WordPress admin styles/scripts
        wp_deregister_style( 'wp-admin' );
        wp_deregister_script( 'wp-admin' );
        
        // Load CIAB application
        wp_enqueue_script(
            'ciab-app',
            CIAB_URL . '/build/app.js',
            ['wp-api-fetch', 'wp-i18n'],
            CIAB_VERSION,
            true
        );
        
        wp_enqueue_style(
            'ciab-app',
            CIAB_URL . '/build/app.css',
            [],
            CIAB_VERSION
        );
        
        // Pass configuration to JavaScript
        wp_localize_script( 'ciab-app', 'ciabConfig', [
            'apiUrl' => rest_url(),
            'nonce' => wp_create_nonce( 'wp_rest' ),
            'currentUser' => wp_get_current_user(),
        ] );
    }
}
add_action( 'admin_enqueue_scripts', 'ciab_enqueue_assets' );
```

## Performance Optimization

### Code Splitting
```javascript
import { lazy } from 'react';

// Lazy load heavy components
const OrdersPage = lazy(() => import('./pages/OrdersPage'));
const ProductsPage = lazy(() => import('./pages/ProductsPage'));
const CustomersPage = lazy(() => import('./pages/CustomersPage'));

// Route-based code splitting
const routes = [
  {
    path: '/orders',
    component: OrdersPage,
  },
  {
    path: '/products',
    component: ProductsPage,
  },
];
```

### Data Optimization
```javascript
// Optimized queries with React Query
const useOrdersOptimized = (filters) => {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: ({ pageParam = 1 }) => OrdersAPI.list({ 
      ...filters, 
      page: pageParam,
      per_page: 50,
    }),
    staleTime: 2 * 60 * 1000, // 2 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
    keepPreviousData: true,
  });
};

// Prefetch related data
const prefetchOrderDetails = (orderId) => {
  queryClient.prefetchQuery({
    queryKey: ['order', orderId],
    queryFn: () => OrdersAPI.get(orderId),
  });
};
```

## Testing Strategies

### Component Testing
```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { OrdersList } from '../OrdersList';

const createTestQueryClient = () => new QueryClient({
  defaultOptions: { queries: { retry: false } },
});

const renderWithProviders = (ui) => {
  const queryClient = createTestQueryClient();
  return render(
    <QueryClientProvider client={queryClient}>
      {ui}
    </QueryClientProvider>
  );
};

test('displays orders list', async () => {
  renderWithProviders(<OrdersList />);
  
  await waitFor(() => {
    expect(screen.getByText('Order #1001')).toBeInTheDocument();
  });
});
```

### E2E Testing
```javascript
import { test, expect } from '@playwright/test';

test('can navigate to orders page', async ({ page }) => {
  await page.goto('/wp-admin/admin.php?page=commerce');
  
  // Click orders menu item
  await page.click('text=Orders');
  
  // Should show orders table
  await expect(page.locator('[data-testid=orders-table]')).toBeVisible();
});
```

## Build and Deployment

### Development Build
```bash
pnpm dev          # Start development server with hot reload
pnpm build:dev    # Build for development
```

### Production Build
```bash
pnpm build        # Build for production
pnpm build:analyze # Build with bundle analysis
```

### Deployment Process
1. Build production assets
2. Version assets with content hash
3. Deploy to Automattic infrastructure
4. Update WordPress plugin with new asset URLs

## Troubleshooting

### Node Version Issues
Ensure Node 22:
```bash
source ~/.nvm/nvm.sh && nvm use
```

### Build Problems
```bash
# Clear cache and reinstall
rm -rf node_modules pnpm-lock.yaml
pnpm install
pnpm build
```

### WordPress Integration Issues
- Check admin menu hooks are firing
- Verify asset URLs are correct
- Ensure REST API endpoints are accessible
- Check user capabilities for CIAB pages

## Security Considerations

### Authentication Integration
CIAB respects WordPress authentication and capabilities:

```javascript
// Check user permissions before rendering admin features
const canManageOrders = currentUser.capabilities.manage_woocommerce;

if (!canManageOrders) {
  return <PermissionDenied />;
}
```

### API Security
All API calls respect WordPress nonces and permissions:

```javascript
// API calls include security headers
apiFetch({
  path: '/wc/v3/orders',
  headers: {
    'X-WP-Nonce': wpApiSettings.nonce,
  },
});
```

## Key Development Resources

- Internal Automattic documentation
- `@automattic/design-system` component library
- WooCommerce REST API documentation
- React Query best practices
- TanStack Router guides