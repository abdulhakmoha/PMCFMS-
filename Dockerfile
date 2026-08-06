FROM node:20
WORKDIR /app

# Copy package files from backend directory
COPY backend/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the backend files
COPY backend/ .

# Expose port 7860 for Hugging Face
ENV PORT=7860
EXPOSE 7860

# Start the server
CMD ["npm", "start"]
