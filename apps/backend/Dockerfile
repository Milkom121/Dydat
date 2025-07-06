# Stage 1: Build the application
FROM node:20-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /usr/src/app

# Copy all source code
COPY . .

# Install dependencies and build the backend
RUN pnpm install --filter=backend --prod
RUN pnpm --filter=backend run build

# Stage 2: Create the production image
FROM node:20-alpine

WORKDIR /usr/src/app

# Copy built files and dependencies from the builder stage
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/apps/backend/node_modules ./apps/backend/node_modules

# Copy the specific package.json for runtime
COPY --from=builder /usr/src/app/apps/backend/package.json .

EXPOSE 3001
CMD ["node", "dist/apps/backend/main.js"] 