# Stage 1: Build the React application
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the application for production
RUN npm run build

# Stage 2: Serve the application using Nginx
FROM nginx:1.25-alpine

# Copy the static assets from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Create a new configuration file that serves the static files and handles SPA routing
# This redirects all 404s to index.html, allowing React Router to handle the routing
RUN echo 'server {\n    listen 80;\n    root /usr/share/nginx/html;\n    index index.html;\n    location / {\n        try_files $uri $uri/ /index.html;\n    }\n}' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# The base Nginx image already has a CMD to start the server, so we don't need to specify it.
# CMD ["nginx", "-g", "daemon off;"]