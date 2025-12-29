# Task 13: Unleash Feature Flag Documentation

## Table of Contents
- [What is Unleash?](#what-is-unleash)
- [Why Use Feature Flags?](#why-use-feature-flags)
- [Unleash Architecture](#unleash-architecture)
- [Setting Up Unleash Locally](#setting-up-unleash-locally)
- [Integrating with React Applications](#integrating-with-react-applications)
- [Feature Flag Strategies](#feature-flag-strategies)
- [Best Practices](#best-practices)

---

## What is Unleash?

**Unleash** is an open-source feature flag management system that allows you to:

- **Toggle features on/off** without code deployments
- **Gradually rollout** new features to users
- **A/B test** different implementations
- **Kill switch** problematic features instantly
- **Target specific users** or user segments

### Key Benefits

| Benefit | Description |
|---------|-------------|
| **Reduced Risk** | Deploy code without activating features |
| **Faster Releases** | Ship code continuously, enable when ready |
| **Easy Rollback** | Disable features without redeployment |
| **User Targeting** | Enable features for specific user groups |
| **Experimentation** | Test different variants with real users |

---

## Why Use Feature Flags?

### Common Use Cases

```
┌─────────────────────────────────────────────────────────────────┐
│                    FEATURE FLAG USE CASES                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🚀 RELEASE TOGGLES                                             │
│     Deploy incomplete features safely                           │
│     Enable when development is complete                         │
│                                                                 │
│  🧪 EXPERIMENT TOGGLES                                          │
│     A/B testing                                                 │
│     Multivariate testing                                        │
│                                                                 │
│  📊 OPS TOGGLES                                                 │
│     Kill switches for system stability                          │
│     Graceful degradation                                        │
│                                                                 │
│  🔐 PERMISSION TOGGLES                                          │
│     Premium features for paying users                           │
│     Beta access for specific groups                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Unleash Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNLEASH ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────────────┐         ┌──────────────────┐            │
│   │   Unleash UI     │◄───────►│  Unleash Server  │            │
│   │   (Dashboard)    │         │     (API)        │            │
│   └──────────────────┘         └────────┬─────────┘            │
│                                         │                       │
│                                         ▼                       │
│                                ┌──────────────────┐            │
│                                │   PostgreSQL     │            │
│                                │   (Database)     │            │
│                                └──────────────────┘            │
│                                         ▲                       │
│                                         │                       │
│   ┌─────────────────────────────────────┼─────────────────────┐│
│   │              CLIENT SDKs            │                     ││
│   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐      ││
│   │  │  React  │  │  Node   │  │  Java   │  │ Python  │      ││
│   │  │   SDK   │  │   SDK   │  │   SDK   │  │   SDK   │      ││
│   │  └─────────┘  └─────────┘  └─────────┘  └─────────┘      ││
│   └───────────────────────────────────────────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Setting Up Unleash Locally

### Option 1: Using Docker Compose (Recommended)

Create `docker-compose.yml`:

```yaml
version: "3.8"

services:
  unleash:
    image: unleashorg/unleash-server:latest
    ports:
      - "4242:4242"
    environment:
      DATABASE_URL: "postgres://postgres:unleash@db:5432/unleash"
      DATABASE_SSL: "false"
      LOG_LEVEL: "debug"
      INIT_ADMIN_API_TOKENS: "*:*.unleash-insecure-api-token"
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: wget --no-verbose --tries=1 --spider http://localhost:4242/health || exit 1
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: unleash
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: unleash
    volumes:
      - unleash_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  unleash_data:
```

### Start Unleash

```bash
# Start the services
docker-compose up -d

# Access Unleash UI
# Open http://localhost:4242 in your browser

# Default credentials:
# Username: admin
# Password: unleash4all
```

### Option 2: Using npm (Development Only)

```bash
# Install Unleash server
npm install -g unleash-server

# Start with in-memory database (for testing only)
unleash-server
```

---

## Integrating with React Applications

### Step 1: Install the React SDK

```bash
# Using npm
npm install @unleash/proxy-client-react

# Using yarn
yarn add @unleash/proxy-client-react
```

### Step 2: Set Up Unleash Provider

Create `src/unleash.js`:

```javascript
import { createRoot } from 'react-dom/client';
import { FlagProvider } from '@unleash/proxy-client-react';
import App from './App';

const config = {
  url: 'http://localhost:4242/api/frontend', // Unleash frontend API
  clientKey: '*:*.unleash-insecure-api-token', // API token
  refreshInterval: 15, // Refresh every 15 seconds
  appName: 'my-react-app',
};

const root = createRoot(document.getElementById('root'));

root.render(
  <FlagProvider config={config}>
    <App />
  </FlagProvider>
);
```

### Step 3: Create Feature Flags in Unleash UI

1. Go to `http://localhost:4242`
2. Login with `admin` / `unleash4all`
3. Navigate to **Feature Toggles** → **Create Feature Toggle**
4. Create a toggle named `newDashboard`

### Step 4: Use Feature Flags in Components

**Using the `useFlag` Hook:**

```jsx
import { useFlag } from '@unleash/proxy-client-react';

function Dashboard() {
  const isNewDashboardEnabled = useFlag('newDashboard');

  return (
    <div>
      {isNewDashboardEnabled ? (
        <NewDashboard />
      ) : (
        <OldDashboard />
      )}
    </div>
  );
}
```

**Using the `useVariant` Hook (for A/B Testing):**

```jsx
import { useVariant } from '@unleash/proxy-client-react';

function PricingPage() {
  const variant = useVariant('pricingExperiment');

  if (variant.name === 'variantA') {
    return <PricingA />;
  } else if (variant.name === 'variantB') {
    return <PricingB />;
  }
  
  return <DefaultPricing />;
}
```

**Using the `useFlagsStatus` Hook:**

```jsx
import { useFlagsStatus } from '@unleash/proxy-client-react';

function App() {
  const { flagsReady, flagsError } = useFlagsStatus();

  if (!flagsReady) {
    return <LoadingSpinner />;
  }

  if (flagsError) {
    return <ErrorMessage>Failed to load feature flags</ErrorMessage>;
  }

  return <MainContent />;
}
```

### Step 5: Complete Example Application

```jsx
// App.jsx
import React from 'react';
import { useFlag, useVariant, useFlagsStatus } from '@unleash/proxy-client-react';
import './App.css';

// Feature: New Navigation
function Navigation() {
  const isNewNavEnabled = useFlag('newNavigation');

  return (
    <nav className={isNewNavEnabled ? 'nav-modern' : 'nav-classic'}>
      <h1>My App</h1>
      {isNewNavEnabled && <span className="badge">New!</span>}
    </nav>
  );
}

// Feature: A/B Test Button Colors
function CTAButton() {
  const variant = useVariant('ctaButtonColor');
  
  const buttonStyle = {
    backgroundColor: variant.payload?.value || '#007bff',
    color: 'white',
    padding: '10px 20px',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer'
  };

  return (
    <button style={buttonStyle}>
      Get Started
    </button>
  );
}

// Feature: Premium Feature Access
function PremiumFeature() {
  const hasPremiumAccess = useFlag('premiumFeatures');

  if (!hasPremiumAccess) {
    return (
      <div className="premium-locked">
        <span>🔒</span>
        <p>Upgrade to Premium to unlock this feature</p>
      </div>
    );
  }

  return (
    <div className="premium-content">
      <h2>Premium Analytics Dashboard</h2>
      {/* Premium content here */}
    </div>
  );
}

// Main App Component
function App() {
  const { flagsReady, flagsError } = useFlagsStatus();

  if (!flagsReady) {
    return (
      <div className="loading">
        <div className="spinner"></div>
        <p>Loading features...</p>
      </div>
    );
  }

  if (flagsError) {
    console.error('Feature flags error:', flagsError);
  }

  return (
    <div className="app">
      <Navigation />
      <main>
        <section className="hero">
          <h1>Welcome to Our App</h1>
          <CTAButton />
        </section>
        <section className="features">
          <PremiumFeature />
        </section>
      </main>
    </div>
  );
}

export default App;
```

---

## Feature Flag Strategies

Unleash provides several activation strategies:

### 1. Default Strategy
Always active when enabled.

### 2. UserIDs Strategy
Enable for specific users only.

```javascript
// In Unleash UI, configure userIds: "user123,user456"

// In React, provide context
<FlagProvider config={{
  ...config,
  context: {
    userId: currentUser.id
  }
}}>
```

### 3. Gradual Rollout
Enable for a percentage of users.

```
┌────────────────────────────────────────────────┐
│          GRADUAL ROLLOUT EXAMPLE               │
├────────────────────────────────────────────────┤
│                                                │
│  Day 1:  [█░░░░░░░░░] 10% of users            │
│  Day 3:  [███░░░░░░░] 30% of users            │
│  Day 7:  [█████░░░░░] 50% of users            │
│  Day 14: [████████░░] 80% of users            │
│  Day 21: [██████████] 100% of users           │
│                                                │
└────────────────────────────────────────────────┘
```

### 4. IPs Strategy
Enable for specific IP addresses.

### 5. Hostname Strategy
Enable based on hostname.

### 6. Custom Strategies
Create your own activation logic.

---

## Best Practices

### Naming Conventions

| Pattern | Example | Use Case |
|---------|---------|----------|
| `feature.[name]` | `feature.newCheckout` | New features |
| `experiment.[name]` | `experiment.pricingTest` | A/B tests |
| `ops.[name]` | `ops.maintenanceMode` | Operational toggles |
| `release.[name]` | `release.v2Dashboard` | Release toggles |

### Flag Lifecycle Management

```
┌─────────────────────────────────────────────────────────────────┐
│                  FEATURE FLAG LIFECYCLE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   CREATE           DEVELOP           RELEASE           RETIRE   │
│      │                │                 │                 │     │
│      ▼                ▼                 ▼                 ▼     │
│   ┌──────┐        ┌──────┐         ┌──────┐         ┌──────┐   │
│   │ OFF  │───────►│ TEST │────────►│  ON  │────────►│REMOVE│   │
│   └──────┘        └──────┘         └──────┘         └──────┘   │
│                                                                 │
│   • Create flag    • Internal       • Gradual        • Remove   │
│   • Add to code      testing          rollout          from UI  │
│   • Keep OFF       • Beta users     • Monitor        • Clean    │
│                                      • Go 100%          code    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Code Organization Tips

1. **Centralize Flag Names**
```javascript
// src/constants/featureFlags.js
export const FLAGS = {
  NEW_DASHBOARD: 'newDashboard',
  PREMIUM_FEATURES: 'premiumFeatures',
  DARK_MODE: 'darkMode',
  BETA_CHECKOUT: 'betaCheckout',
};
```

2. **Create Custom Hooks**
```javascript
// src/hooks/useFeature.js
import { useFlag } from '@unleash/proxy-client-react';
import { FLAGS } from '../constants/featureFlags';

export function useNewDashboard() {
  return useFlag(FLAGS.NEW_DASHBOARD);
}

export function usePremiumFeatures() {
  return useFlag(FLAGS.PREMIUM_FEATURES);
}
```

3. **Handle Loading States**
```javascript
// Always show a loading state while flags are being fetched
const { flagsReady } = useFlagsStatus();
if (!flagsReady) return <Skeleton />;
```

### Security Considerations

- **Never expose sensitive API tokens** in frontend code
- Use **Unleash Proxy** for secure frontend access
- Implement **rate limiting** for flag requests
- **Audit flag changes** for compliance

---

## Quick Reference

### Environment Variables

```bash
# .env.local for React
REACT_APP_UNLEASH_URL=http://localhost:4242/api/frontend
REACT_APP_UNLEASH_CLIENT_KEY=*:*.unleash-insecure-api-token
REACT_APP_UNLEASH_APP_NAME=my-react-app
```

### Useful API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/client/features` | Get all feature toggles |
| `GET /api/admin/features` | Admin API for features |
| `POST /api/admin/features` | Create new feature |
| `GET /health` | Health check endpoint |

---

## Summary

Unleash provides a powerful, open-source solution for feature flag management:

- **Easy Setup**: Docker Compose gets you running in minutes
- **React Integration**: Simple hooks-based API
- **Flexible Strategies**: Multiple targeting options
- **Self-Hosted**: Full control over your data

For production deployments, consider:
- Using **Unleash Proxy** for frontend apps
- Setting up **proper authentication**
- Implementing **flag cleanup workflows**
