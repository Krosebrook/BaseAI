#!/bin/bash

# Test Setup Script for BaseAI
# Sets up test environment and runs all tests

set -e

echo "🧪 BaseAI Test Setup"
echo "===================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    pnpm install
fi

# Build packages first (required for tests)
echo ""
echo "🔨 Building packages..."
pnpm build:pkgs

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Build successful"

# Run linting
echo ""
echo "🔍 Running ESLint..."
pnpm lint || echo -e "${YELLOW}⚠  Linting issues found${NC}"

# Run Prettier check
echo ""
echo "💅 Checking code formatting..."
pnpm prettier-check || echo -e "${YELLOW}⚠  Formatting issues found${NC}"

# Run type checking
echo ""
echo "📝 Running TypeScript type check..."
pnpm type-check

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Type check failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Type check passed"

# Run tests
echo ""
echo "🧪 Running tests..."
pnpm test

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Tests failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} All tests passed"

# Run publint
echo ""
echo "📋 Running publint..."
pnpm publint || echo -e "${YELLOW}⚠  Publint issues found${NC}"

echo ""
echo -e "${GREEN}✅ All checks complete!${NC}"
