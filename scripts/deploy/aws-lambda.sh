#!/bin/bash

# AWS Lambda Deployment Script for BaseAI
# Packages and deploys BaseAI as Lambda function

set -e

echo "☁️  BaseAI AWS Lambda Deployment Script"
echo "========================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
FUNCTION_NAME="baseai-function"
RUNTIME="nodejs18.x"
HANDLER="index.handler"
REGION="us-east-1"
MEMORY=512
TIMEOUT=30

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found${NC}"
    echo "Install it from: https://aws.amazon.com/cli/"
    exit 1
fi

echo -e "${GREEN}✓${NC} AWS CLI found"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo "Configure with: aws configure"
    exit 1
fi

echo -e "${GREEN}✓${NC} AWS credentials configured"

# Build packages
echo ""
echo "📦 Building packages..."
pnpm build:pkgs

# Create deployment package
echo ""
echo "📦 Creating deployment package..."

TEMP_DIR=$(mktemp -d)
echo "Using temp directory: $TEMP_DIR"

# Copy necessary files
cp -r packages/baseai/dist "$TEMP_DIR/"
cp -r packages/core/dist "$TEMP_DIR/core"
cp -r node_modules "$TEMP_DIR/" 2>/dev/null || echo "Skipping node_modules"

# Create handler if it doesn't exist
if [ ! -f "lambda-handler.js" ]; then
    echo ""
    echo "Creating example Lambda handler..."
    cat > "$TEMP_DIR/index.js" << 'EOF'
const { Pipe } = require('./dist/index.js');

exports.handler = async (event) => {
    try {
        const { message } = JSON.parse(event.body);

        // Configure your pipe
        const pipeConfig = {
            apiKey: process.env.LANGBASE_API_KEY,
            name: 'lambda-pipe',
            model: 'openai:gpt-4o-mini',
            messages: [
                { role: 'system', content: 'You are a helpful assistant.' }
            ]
        };

        const pipe = new Pipe(pipeConfig);
        const response = await pipe.run({
            messages: [{ role: 'user', content: message }],
            stream: false
        });

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                completion: response.completion,
                usage: response.usage
            })
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message })
        };
    }
};
EOF
else
    cp lambda-handler.js "$TEMP_DIR/index.js"
fi

# Create zip file
cd "$TEMP_DIR"
zip -q -r function.zip .
cd - > /dev/null

echo -e "${GREEN}✓${NC} Deployment package created"

# Check if function exists
if aws lambda get-function --function-name "$FUNCTION_NAME" --region "$REGION" &> /dev/null; then
    echo ""
    echo "📝 Updating existing function..."

    aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://$TEMP_DIR/function.zip" \
        --region "$REGION"

    echo -e "${GREEN}✓${NC} Function updated"
else
    echo ""
    echo "📝 Creating new function..."

    # You'll need to create an IAM role first
    echo -e "${YELLOW}⚠${NC}  Make sure you have created an IAM role for Lambda"
    read -p "Enter IAM role ARN: " ROLE_ARN

    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime "$RUNTIME" \
        --role "$ROLE_ARN" \
        --handler "$HANDLER" \
        --zip-file "fileb://$TEMP_DIR/function.zip" \
        --memory-size "$MEMORY" \
        --timeout "$TIMEOUT" \
        --region "$REGION"

    echo -e "${GREEN}✓${NC} Function created"
fi

# Set environment variables
echo ""
echo "🔐 Setting environment variables..."

read -p "Enter LANGBASE_API_KEY: " -s LANGBASE_KEY
echo

aws lambda update-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --environment "Variables={LANGBASE_API_KEY=$LANGBASE_KEY}" \
    --region "$REGION" \
    > /dev/null

echo -e "${GREEN}✓${NC} Environment variables set"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "Test your function with:"
echo "aws lambda invoke --function-name $FUNCTION_NAME --region $REGION response.json"
