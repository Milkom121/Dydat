# Stage 1: Build the application
FROM node:20-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /usr/src/app

# Copy all source code
COPY . .

# Install dependencies and build the frontend
# Note: We don't use --prod here because Next.js build needs devDependencies
RUN pnpm install --filter=frontend
RUN pnpm --filter=frontend run build

# Stage 2: Production image
FROM node:20-alpine

WORKDIR /usr/src/app

ENV NODE_ENV=production

# Copy built standalone output, public folder, and static assets from builder
COPY --from=builder /usr/src/app/apps/frontend/.next/standalone ./
COPY --from=builder /usr/src/app/apps/frontend/.next/static ./apps/frontend/.next/static
COPY --from=builder /usr/src/app/apps/frontend/public ./apps/frontend/public

EXPOSE 3000

ENV PORT=3000

CMD ["node", "apps/frontend/server.js"] 