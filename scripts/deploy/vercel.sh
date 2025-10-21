#!/bin/bash

# Vercel Deployment Script for BaseAI
# This script helps deploy BaseAI applications to Vercel

set -e

echo "🚀 BaseAI Vercel Deployment Script"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo -e "${RED}❌ Vercel CLI not found${NC}"
    echo "Install it with: npm install -g vercel"
    exit 1
fi

echo -e "${GREEN}✓${NC} Vercel CLI found"

# Check if this is a BaseAI project
if [ ! -d "baseai" ]; then
    echo -e "${YELLOW}⚠${NC}  baseai/ directory not found. Is this a BaseAI project?"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build check
echo ""
echo "📦 Building packages..."
if pnpm build:pkgs 2>/dev/null || npm run build 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Build successful"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Environment variables check
echo ""
echo "🔐 Checking environment variables..."

ENV_VARS=(
    "LANGBASE_API_KEY"
)

MISSING_VARS=()

for var in "${ENV_VARS[@]}"; do
    if vercel env ls production 2>/dev/null | grep -q "$var"; then
        echo -e "${GREEN}✓${NC} $var is set"
    else
        echo -e "${YELLOW}⚠${NC}  $var is not set in Vercel"
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -ne 0 ]; then
    echo ""
    echo -e "${YELLOW}Missing environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo "Set them with:"
    echo "  vercel env add LANGBASE_API_KEY production"
    read -p "Continue deployment? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Deploy
echo ""
echo "🚀 Deploying to Vercel..."

if [ "$1" == "--prod" ]; then
    echo "Deploying to production..."
    vercel --prod
else
    echo "Deploying to preview..."
    vercel
fi

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
