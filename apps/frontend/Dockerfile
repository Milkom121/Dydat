# Stage 1: Builder
# This stage installs all dependencies and builds the source code.
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copy root dependency management files first
COPY package.json pnpm-lock.yaml ./
# Then copy the package.json for the specific app
COPY apps/frontend/package.json ./apps/frontend/

# Install dependencies for the frontend workspace, including devDependencies.
RUN npm install -g pnpm && pnpm install --filter frontend

# Copy the rest of the source code
COPY . .

# Build the specific 'frontend' workspace.
# This will generate the .next/standalone folder
RUN pnpm --filter frontend build


# Stage 2: Production
# This is the final, minimal image using the standalone output.
FROM node:20-alpine

WORKDIR /usr/src/app

# Set the environment to production
ENV NODE_ENV production
# Set the correct port
ENV PORT 3000

# Copy the standalone output from the builder stage
COPY --from=builder /usr/src/app/apps/frontend/.next/standalone ./
# Copy the static assets from the builder stage
COPY --from=builder /usr/src/app/apps/frontend/.next/static ./.next/static

# The standalone output includes a server.js file that starts the app
CMD ["node", "server.js"] 