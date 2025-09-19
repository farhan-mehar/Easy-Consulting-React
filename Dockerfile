# Use a lightweight Node.js base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy only package files first to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the app
COPY . .

# Build the React app
RUN npm run build

# Install serve globally to serve static files
RUN npm install -g serve

# Expose the port your app will run on
EXPOSE 3000

# Start the app
CMD ["serve", "-s", "build", "-l", "3000"]
