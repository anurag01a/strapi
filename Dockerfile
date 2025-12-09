FROM node:18-alpine

WORKDIR /app

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

COPY . .

EXPOSE 1337

CMD ["npm", "start"]