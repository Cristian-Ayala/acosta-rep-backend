# Stage 1: Build the application
FROM node:alpine AS builder

WORKDIR /usr/app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy the rest of the application source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Create a minimal image with only the dist files
FROM node:alpine

WORKDIR /usr/app

# Copy only necessary files from the previous stage
COPY --from=builder /usr/app/dist ./dist
COPY --from=builder /usr/app/package.json ./

# Install only production dependencies (if any)
RUN npm install --omit=dev

# Set environment variable if needed
# ENV NODE_ENV=production

# Define the command to start the application
CMD ["npm", "run", "start:prod"]