# Dockerfile
FROM node:18-slim

# Create app directory
WORKDIR /usr/src/app

# 1. Install the @splunk/otel package
RUN npm install @splunk/otel

# 2. Set appropriate permissions
# Since WORKDIR is /usr/src/app, node_modules is located here
RUN chmod -R go+r /usr/src/app/node_modules/@splunk/otel

# Copy the app source
COPY server.js .

# Expose the port
EXPOSE 8080

# 3. Start the app using the -r flag 
CMD [ "node", "-r", "@splunk/otel/instrument", "server.js" ]
