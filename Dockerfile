# Dockerfile for Node.js Express App

# Stage 1: Build Stage
FROM node:16-alpine AS builder
WORKDIR /app
# Copy package files and install production dependencies
COPY package.json package-lock.json ./
RUN npm install --production

# Stage 2: Final/Runtime Stage
FROM node:16-alpine
WORKDIR /app
# Copy installed dependencies and application code
COPY --from=builder /app/node_modules ./node_modules
COPY . . 

# Expose the port the Node.js app runs on (often 8080 for the AWS sample)
EXPOSE 8080 

# Define the command to run the application
CMD ["node", "app.js"]
