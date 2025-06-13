FROM node:18-alpine

WORKDIR /app

# Install dependencies only when needed
COPY ./package*.json ./frontend/
RUN cd frontend && npm install

# Copy the rest of the application
COPY . ./frontend/

# Expose ports for the app and for debugging
EXPOSE 3000 9229

# Command to run the development server with debugging enabled
CMD ["sh", "-c", "npm run dev:docker"]