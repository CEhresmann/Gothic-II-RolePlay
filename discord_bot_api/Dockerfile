# Use the official Node.js image.
# https://hub.docker.com/_/node
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
# Use --only=production to install only production dependencies
RUN npm install --only=production

# Copy the application source code
COPY . .

# Expose the port on which the API is running
EXPOSE 3000

# Command to run the application
CMD [ "node", "index.js" ]
