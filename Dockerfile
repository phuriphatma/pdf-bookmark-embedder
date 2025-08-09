FROM python:3.9-slim

WORKDIR /app

# Install system dependencies including Node.js
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy package.json and package-lock.json
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy source code
COPY . .

# Build the frontend
RUN npm run build

# Remove node_modules to reduce image size (optional)
# RUN rm -rf node_modules

# Expose port
EXPOSE 8081

# Start the server
CMD ["python", "server/bookmark_server_clean.py"]
