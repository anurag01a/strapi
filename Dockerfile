FROM node:20-alpine AS base
WORKDIR /workspace

# Install small build dependencies for native modules
RUN apk add --no-cache python3 make g++

# Copy package metadata to leverage caching
COPY package.json yarn.lock ./

# Install dependencies (prefer yarn when lockfile present)
RUN if [ -f yarn.lock ]; then \
      yarn install --frozen-lockfile --production=false; \
    else \
      npm ci; \
    fi

FROM base AS build
WORKDIR /workspace
COPY . .

# Build example app if available
WORKDIR /workspace/examples/getstarted
RUN if [ -f package.json ]; then \
      if [ -f yarn.lock ]; then yarn build || true; else npm run build --if-present || true; fi; \
    fi

FROM node:20-alpine AS runtime
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Pull installed modules and built assets from earlier stages
COPY --from=base /workspace/node_modules ./node_modules
COPY --from=build /workspace/examples/getstarted ./examples/getstarted

ENV NODE_ENV=development
ENV PORT=1337

EXPOSE 1337

USER appuser
CMD ["node", "./examples/getstarted/server.js"]