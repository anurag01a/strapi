# Task 15: Docker Image Size Reduction

## Table of Contents
- [Introduction](#introduction)
- [Why Image Size Matters](#why-image-size-matters)
- [Cost Impact Analysis](#cost-impact-analysis)
- [Image Size Reduction Techniques](#image-size-reduction-techniques)
- [Multi-Stage Builds](#multi-stage-builds)
- [Optimizing Dockerfiles](#optimizing-dockerfiles)
- [Tools for Image Analysis](#tools-for-image-analysis)
- [Best Practices](#best-practices)

---

## Introduction

**Docker image size** directly impacts deployment speed, storage costs, and security attack surface. Reducing image size is a critical optimization for production deployments.

### Key Metrics

| Metric | Impact |
|--------|--------|
| **Image Pull Time** | Larger images = slower deployments |
| **Registry Storage** | More versions = higher storage costs |
| **Network Bandwidth** | Larger transfers = higher egress costs |
| **Attack Surface** | More packages = more vulnerabilities |
| **Container Startup** | Larger images = slower cold starts |

---

## Why Image Size Matters

```
┌─────────────────────────────────────────────────────────────────┐
│                  IMAGE SIZE IMPACT AREAS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ⚡ DEPLOYMENT SPEED                                            │
│     • Faster image pulls = quicker scaling                      │
│     • Reduced rollout time for updates                          │
│     • Faster recovery from failures                             │
│                                                                 │
│  💰 COST REDUCTION                                              │
│     • Lower ECR/Registry storage costs                          │
│     • Reduced data transfer charges                             │
│     • Optimized Fargate/ECS resource usage                      │
│                                                                 │
│  🔒 SECURITY                                                    │
│     • Fewer packages = smaller attack surface                   │
│     • Less CVEs to patch and monitor                            │
│     • Easier compliance auditing                                │
│                                                                 │
│  📦 RESOURCE EFFICIENCY                                         │
│     • Less disk I/O during container startup                    │
│     • Better cache utilization                                  │
│     • More containers per host                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Real-World Size Comparison

| Base Image | Size | Use Case |
|------------|------|----------|
| `node:20` | ~1.1 GB | Full Node.js with Debian |
| `node:20-slim` | ~250 MB | Minimal Debian variant |
| `node:20-alpine` | ~140 MB | Alpine Linux based |
| `distroless/nodejs` | ~120 MB | Google's minimal runtime |
| Custom multi-stage | ~50-80 MB | Production optimized |

---

## Cost Impact Analysis

### Storage Costs (AWS ECR Example)

```
┌─────────────────────────────────────────────────────────────────┐
│               MONTHLY COST COMPARISON                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Scenario: 50 image versions, updated daily                     │
│                                                                 │
│  ┌────────────────┬───────────┬───────────┬────────────┐       │
│  │ Image Size     │ Storage   │ ECR Cost  │ Annual     │       │
│  ├────────────────┼───────────┼───────────┼────────────┤       │
│  │ 1 GB (Large)   │ 50 GB     │ $5.00/mo  │ $60/year   │       │
│  │ 250 MB (Slim)  │ 12.5 GB   │ $1.25/mo  │ $15/year   │       │
│  │ 100 MB (Alpine)│ 5 GB      │ $0.50/mo  │ $6/year    │       │
│  └────────────────┴───────────┴───────────┴────────────┘       │
│                                                                 │
│  ECR Pricing: $0.10/GB/month                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Transfer Costs

| Scenario | Large Image (1GB) | Optimized (100MB) | Savings |
|----------|-------------------|-------------------|---------|
| 100 deployments/month | $9.00 | $0.90 | 90% |
| Cross-region pulls | $18.00 | $1.80 | 90% |
| CI/CD pipeline (500 builds) | $45.00 | $4.50 | 90% |

### ECS Fargate Impact

```
┌─────────────────────────────────────────────────────────────────┐
│              FARGATE COLD START COMPARISON                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Large Image (1GB):                                             │
│  ├── Image Pull: ~30-60 seconds                                 │
│  ├── Container Start: ~5 seconds                                │
│  └── Total: ~35-65 seconds                                      │
│                                                                 │
│  Optimized Image (100MB):                                       │
│  ├── Image Pull: ~5-10 seconds                                  │
│  ├── Container Start: ~3 seconds                                │
│  └── Total: ~8-13 seconds                                       │
│                                                                 │
│  Impact: 5-6x faster scaling during traffic spikes              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Image Size Reduction Techniques

### 1. Choose the Right Base Image

```dockerfile
# ❌ Bad: Full Debian-based Node.js (~1.1GB)
FROM node:20

# ✅ Better: Slim variant (~250MB)
FROM node:20-slim

# ✅ Best: Alpine variant (~140MB)
FROM node:20-alpine
```

### 2. Use Multi-Stage Builds

See [Multi-Stage Builds](#multi-stage-builds) section for detailed examples.

### 3. Minimize Layers

```dockerfile
# ❌ Bad: Multiple RUN commands create multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean

# ✅ Good: Combine RUN commands into single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### 4. Clean Up in Same Layer

```dockerfile
# ❌ Bad: Cleanup in separate layer doesn't reduce size
RUN apk add --no-cache python3 make g++
RUN yarn install --frozen-lockfile
RUN apk del python3 make g++  # This doesn't help!

# ✅ Good: Cleanup in same layer
RUN apk add --no-cache --virtual .build-deps python3 make g++ && \
    yarn install --frozen-lockfile && \
    apk del .build-deps
```

### 5. Use .dockerignore

```
# .dockerignore
node_modules
dist
build
.cache
.env
*.log
.git
.github
tests
docs
*.md
```

### 6. Install Production Dependencies Only

```dockerfile
# ❌ Bad: Installs dev dependencies
RUN npm install

# ✅ Good: Production dependencies only
RUN npm ci --only=production
```

---

## Multi-Stage Builds

Multi-stage builds allow you to use multiple FROM statements, separating build and runtime environments.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  MULTI-STAGE BUILD FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              STAGE 1: BUILD (node:alpine)                 │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │ • Full Node.js + npm                               │  │   │
│  │  │ • Build tools (python, make, g++)                  │  │   │
│  │  │ • All dependencies (dev + prod)                    │  │   │
│  │  │ • Source code compilation                          │  │   │
│  │  │ • TypeScript transpilation                         │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  │                      Size: ~500MB                         │   │
│  └────────────────────────────┬─────────────────────────────┘   │
│                               │                                  │
│                               │ Copy only built artifacts        │
│                               ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │             STAGE 2: PRODUCTION (alpine)                  │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │ • Minimal runtime only                             │  │   │
│  │  │ • Production dependencies only                     │  │   │
│  │  │ • Compiled application                             │  │   │
│  │  │ • No build tools                                   │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  │                      Size: ~80MB                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Basic Multi-Stage Example

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps python3 make g++

# Install all dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy source and build
COPY . .
RUN yarn build

# Remove dev dependencies
RUN yarn install --production --frozen-lockfile

# Stage 2: Production
FROM node:20-alpine AS production

WORKDIR /app

# Copy only what we need
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Use non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S strapi -u 1001 && \
    chown -R strapi:nodejs /app

USER strapi

EXPOSE 1337
CMD ["node", "dist/server.js"]
```

### Advanced: Strapi Production Dockerfile

```dockerfile
# =============================================================================
# Stage 1: Dependencies (cache layer)
# =============================================================================
FROM node:20-alpine AS deps

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    python3 \
    make \
    g++ \
    libc6-compat

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# =============================================================================
# Stage 2: Builder
# =============================================================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
RUN yarn build

# =============================================================================
# Stage 3: Production Runtime
# =============================================================================
FROM node:20-alpine AS runner

WORKDIR /app

# Install runtime dependencies only
RUN apk add --no-cache tini

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 strapi

# Copy built application
COPY --from=builder --chown=strapi:nodejs /app/dist ./dist
COPY --from=builder --chown=strapi:nodejs /app/package.json ./

# Install production dependencies only
RUN yarn install --production --frozen-lockfile && \
    yarn cache clean

USER strapi

EXPOSE 1337
ENV NODE_ENV=production

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/server.js"]
```

---

## Optimizing Dockerfiles

### Layer Ordering (Cache Optimization)

```dockerfile
# ✅ Optimal ordering: least changing → most changing

# 1. Base image (rarely changes)
FROM node:20-alpine

# 2. System dependencies (occasionally changes)
RUN apk add --no-cache tini

# 3. Package files (changes when dependencies update)
COPY package.json yarn.lock ./

# 4. Install dependencies (cached unless package files change)
RUN yarn install --frozen-lockfile

# 5. Application code (changes frequently)
COPY . .

# 6. Build step
RUN yarn build
```

### Environment-Specific Optimizations

```dockerfile
# Development: Full tooling, live reload
FROM node:20-alpine AS development
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
CMD ["yarn", "develop"]

# Production: Minimal, optimized
FROM node:20-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]

# Test: Includes test frameworks
FROM development AS test
RUN yarn test
```

---

## Tools for Image Analysis

### 1. Docker Image History

```bash
# View layers and sizes
docker history <image-name>

# Example output:
IMAGE          CREATED       SIZE      COMMAND
abc123         1 min ago     5.2MB     COPY . .
def456         1 min ago     120MB     yarn install
ghi789         2 min ago     0B        WORKDIR /app
jkl012         1 week ago    140MB     node:20-alpine
```

### 2. Dive (Layer Analysis Tool)

```bash
# Install dive
# macOS: brew install dive
# Linux: https://github.com/wagoodman/dive

# Analyze image
dive <image-name>

# CI mode (fails if efficiency < threshold)
CI=true dive <image-name> --ci-config=.dive-ci.yml
```

### 3. Docker Scout (Vulnerability + Size)

```bash
# Analyze image for vulnerabilities and recommendations
docker scout cves <image-name>
docker scout recommendations <image-name>
```

### 4. Container-diff

```bash
# Compare two images
container-diff diff <image1> <image2> --type=size
```

### Size Comparison Script

```bash
#!/bin/bash
# compare-image-sizes.sh

echo "Image Size Comparison"
echo "===================="

# Before optimization
docker build -t myapp:before -f Dockerfile.before .
BEFORE=$(docker inspect myapp:before --format='{{.Size}}')

# After optimization
docker build -t myapp:after -f Dockerfile.after .
AFTER=$(docker inspect myapp:after --format='{{.Size}}')

# Calculate reduction
REDUCTION=$(echo "scale=2; (($BEFORE - $AFTER) / $BEFORE) * 100" | bc)

echo "Before: $(numfmt --to=iec-i --suffix=B $BEFORE)"
echo "After:  $(numfmt --to=iec-i --suffix=B $AFTER)"
echo "Reduction: ${REDUCTION}%"
```

---

## Best Practices

### Dockerfile Best Practices

| Practice | Description |
|----------|-------------|
| **Use Alpine Base** | 5-10x smaller than Debian-based images |
| **Multi-Stage Builds** | Separate build and runtime environments |
| **Minimal Layers** | Combine RUN commands where logical |
| **Cleanup in Same Layer** | Remove build deps in same RUN command |
| **Production Dependencies** | Use `--only=production` or `--production` |
| **Non-Root User** | Security best practice, no size impact |
| **Use .dockerignore** | Prevent unnecessary files from entering context |

### CI/CD Integration

```yaml
# GitHub Actions workflow with image size check
name: Docker Build

on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Check image size
        run: |
          SIZE=$(docker inspect myapp:${{ github.sha }} --format='{{.Size}}')
          MAX_SIZE=209715200  # 200MB in bytes
          if [ $SIZE -gt $MAX_SIZE ]; then
            echo "Image size ($SIZE bytes) exceeds limit ($MAX_SIZE bytes)"
            exit 1
          fi
          echo "Image size: $(numfmt --to=iec-i --suffix=B $SIZE)"

      - name: Analyze with Dive
        uses: MartinHeinz/dive-action@v0.1.3
        with:
          image: myapp:${{ github.sha }}
          config-file: .dive-ci.yml
```

### Size Monitoring Dashboard

```
┌─────────────────────────────────────────────────────────────────┐
│              IMAGE SIZE MONITORING CHECKLIST                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ☐ Set size budget (e.g., max 200MB for production)            │
│  ☐ Add size check to CI pipeline                                │
│  ☐ Track size trends over time                                  │
│  ☐ Alert on size increases > 10%                                │
│  ☐ Review dependencies monthly                                  │
│  ☐ Run vulnerability scans weekly                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Quick Reference Commands

```bash
# Image Analysis
docker images                           # List images with sizes
docker history <image>                  # View layer breakdown
docker inspect <image> --format='{{.Size}}'  # Get exact size in bytes
dive <image>                            # Interactive layer analysis

# Building Optimized Images
docker build --target production .      # Build specific stage
docker build --no-cache .               # Fresh build (no cache)
docker build --squash .                 # Squash layers (experimental)

# Cleanup
docker image prune                      # Remove unused images
docker system prune -a                  # Remove all unused data
docker builder prune                    # Clear build cache

# Multi-Stage Specific
docker build --target builder -t myapp:build .   # Build up to stage
docker build --target runner -t myapp:prod .     # Final production image

# Size Comparison
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

---

## Summary

Docker image size reduction is critical for:

- **Cost Savings**: Lower storage, transfer, and compute costs
- **Performance**: Faster deployments and scaling
- **Security**: Reduced attack surface and fewer vulnerabilities

### Key Takeaways

| Technique | Potential Reduction |
|-----------|---------------------|
| Alpine Base Image | 60-80% |
| Multi-Stage Builds | 50-70% |
| Production Dependencies | 30-50% |
| Proper .dockerignore | 10-30% |
| Layer Optimization | 5-15% |

### Recommended Approach

1. **Start with Alpine** base images
2. **Implement multi-stage** builds for any compiled code
3. **Use .dockerignore** to exclude unnecessary files
4. **Install only production** dependencies in final stage
5. **Monitor size** in CI/CD pipeline
6. **Regularly audit** dependencies and remove unused packages

For production ECS/Fargate deployments, combining these techniques can reduce image sizes by **70-90%**, leading to significant cost savings and faster deployments.
