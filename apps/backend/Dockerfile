# Stage 1: Builder
# This stage installs all dependencies and builds the source code.
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copy root dependency management files first
COPY package.json pnpm-lock.yaml ./
# Then copy the package.json for the specific app
COPY apps/backend/package.json ./apps/backend/

# Install dependencies, including devDependencies for the build.
RUN npm install -g pnpm && pnpm install --filter backend

# Copy the rest of the source code
COPY . .

# Build the specific 'backend' workspace.
RUN pnpm --filter backend build


# Stage 2: Production
# This is the final, minimal image.
FROM node:20-alpine

# Set the working directory for the final application
WORKDIR /usr/src/app/backend

# Set the environment to production
ENV NODE_ENV production

# Create a clean node_modules with only production dependencies
COPY package.json pnpm-lock.yaml ./
COPY apps/backend/package.json ./package.json
RUN npm install -g pnpm && pnpm install --prod

# Copy the built application from the 'builder' stage
COPY --from=builder /usr/src/app/apps/backend/dist ./dist

# Expose the port the app runs on
EXPOSE 3001

# Command to run the application from the correct directory
CMD [ "node", "dist/main.js" ] 