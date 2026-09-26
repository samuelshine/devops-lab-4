# syntax=docker/dockerfile:1

# ---- Stage 1: install production dependencies only ----
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# ---- Stage 2: runtime ----
FROM node:22-alpine
LABEL org.opencontainers.image.title="devops-lab-4-api" \
      org.opencontainers.image.source="https://github.com/samuelshine/devops-lab-4" \
      org.opencontainers.image.authors="Samuel Shine"
ENV NODE_ENV=production
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY src ./src
USER node
EXPOSE 3000
CMD ["node", "src/server.js"]
