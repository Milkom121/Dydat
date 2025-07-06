# Stage 1: Build the application
FROM node:20-alpine AS builder

# Install pnpm and copy source code
RUN npm install -g pnpm
WORKDIR /usr/src/app
COPY . .

# Install ALL dependencies (dev included) and build the application
RUN pnpm install
RUN pnpm --filter=backend run build

# Prune dev dependencies for the entire monorepo
RUN pnpm prune --prod

# Stage 2: Create the final production image
FROM node:20-alpine
WORKDIR /usr/src/app

# Copy the pruned node_modules and the built application from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/apps/backend/dist ./dist
COPY --from=builder /usr/src/app/package.json ./package.json
COPY --from=builder /usr/src/app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /usr/src/app/apps/backend/package.json ./apps/backend/package.json

EXPOSE 3001
CMD ["node", "dist/main.js"] 