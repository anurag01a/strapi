FROM node:20-alpine
WORKDIR /app

# Install runtime deps only (no build deps) in this compact example image
RUN apk add --no-cache tini

# Copy package files and install production dependencies only
COPY package.json package-lock.json* yarn.lock* ./
RUN if [ -f yarn.lock ]; then \
      yarn install --production --frozen-lockfile; \
    else \
      npm ci --only=production; \
    fi

# Copy application sources
COPY . .

ENV PORT=1337
ENV NODE_ENV=development

EXPOSE 1337

CMD ["/sbin/tini", "--", "node", "server.js"]