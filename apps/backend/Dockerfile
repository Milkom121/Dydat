# Stage 1: Build the application
FROM node:20-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /usr/src/app

# Copy all source code
COPY . .

# Install dependencies and build the backend
RUN pnpm install --filter=backend
RUN pnpm --filter=backend run build

# Stage 2: Create the production image
FROM node:20-alpine

RUN npm install -g pnpm
WORKDIR /usr/src/app

# Copy only the files needed for production dependencies
COPY package.json pnpm-lock.yaml ./
COPY apps/backend/package.json ./apps/backend/

# Install only production dependencies
RUN pnpm install --filter=backend --prod

# Copy the built application from the builder stage
COPY --from=builder /usr/src/app/dist ./dist

EXPOSE 3001
CMD ["node", "dist/apps/backend/main.js"] 