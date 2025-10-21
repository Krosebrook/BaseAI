#!/bin/bash

# Docker Deployment Script for BaseAI
# Builds and runs BaseAI application in Docker

set -e

echo "🐳 BaseAI Docker Deployment Script"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
IMAGE_NAME="baseai-app"
TAG="latest"
PORT=3000
ENV_FILE=".env"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--name IMAGE_NAME] [--tag TAG] [--port PORT] [--env-file FILE] [--build-only]"
            exit 1
            ;;
    esac
done

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found${NC}"
    echo "Install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker found"

# Check for env file
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠${NC}  Environment file $ENV_FILE not found"
    read -p "Continue without environment file? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    ENV_FILE=""
fi

# Build Docker image
echo ""
echo "🔨 Building Docker image: $IMAGE_NAME:$TAG"

docker build -t "$IMAGE_NAME:$TAG" .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Docker image built successfully"
else
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi

# Exit if build-only flag is set
if [ "$BUILD_ONLY" = true ]; then
    echo ""
    echo -e "${GREEN}✅ Build complete (build-only mode)${NC}"
    exit 0
fi

# Stop existing container if running
CONTAINER_NAME="$IMAGE_NAME-container"
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo ""
    echo "🛑 Stopping existing container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
fi

# Run container
echo ""
echo "🚀 Starting container on port $PORT..."

if [ -n "$ENV_FILE" ]; then
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p "$PORT:3000" \
        --env-file "$ENV_FILE" \
        "$IMAGE_NAME:$TAG"
else
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p "$PORT:3000" \
        "$IMAGE_NAME:$TAG"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Container started successfully"
    echo ""
    echo "📝 Container details:"
    echo "  Name: $CONTAINER_NAME"
    echo "  Image: $IMAGE_NAME:$TAG"
    echo "  Port: http://localhost:$PORT"
    echo ""
    echo "View logs with: docker logs -f $CONTAINER_NAME"
    echo "Stop with: docker stop $CONTAINER_NAME"
else
    echo -e "${RED}❌ Failed to start container${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
