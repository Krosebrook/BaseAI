# Deployment Scripts

Automated deployment scripts for BaseAI applications.

## Available Scripts

### Vercel Deployment

Deploy to Vercel with automated checks.

```bash
# Preview deployment
./scripts/deploy/vercel.sh

# Production deployment
./scripts/deploy/vercel.sh --prod
```

**Prerequisites:**
- Vercel CLI installed: `npm install -g vercel`
- Vercel account configured: `vercel login`

**Environment Variables:**
Set in Vercel dashboard or via CLI:
```bash
vercel env add LANGBASE_API_KEY production
```

---

### Docker Deployment

Build and run BaseAI in Docker containers.

```bash
# Build and run
./scripts/deploy/docker.sh

# Custom configuration
./scripts/deploy/docker.sh \
  --name my-app \
  --tag v1.0.0 \
  --port 8080 \
  --env-file .env.production

# Build only (no run)
./scripts/deploy/docker.sh --build-only
```

**Options:**
- `--name IMAGE_NAME` - Docker image name (default: baseai-app)
- `--tag TAG` - Image tag (default: latest)
- `--port PORT` - Host port (default: 3000)
- `--env-file FILE` - Environment file (default: .env)
- `--build-only` - Build without running

**Prerequisites:**
- Docker installed: https://docs.docker.com/get-docker/

---

### AWS Lambda Deployment

Package and deploy to AWS Lambda.

```bash
./scripts/deploy/aws-lambda.sh
```

**Prerequisites:**
- AWS CLI installed: https://aws.amazon.com/cli/
- AWS credentials configured: `aws configure`
- IAM role for Lambda with appropriate permissions

**What it does:**
1. Builds packages
2. Creates deployment package
3. Creates/updates Lambda function
4. Sets environment variables

**Test your function:**
```bash
aws lambda invoke \
  --function-name baseai-function \
  --region us-east-1 \
  --payload '{"body":"{\"message\":\"Hello\"}"}' \
  response.json

cat response.json
```

---

## Creating Custom Deployment Scripts

You can create custom deployment scripts for other platforms:

```bash
#!/bin/bash

set -e

echo "🚀 Custom Deployment Script"

# Build packages
pnpm build:pkgs

# Your deployment logic here
# ...

echo "✅ Deployment complete!"
```

### Tips for Custom Scripts

1. **Always build first:**
   ```bash
   pnpm build:pkgs
   ```

2. **Check environment variables:**
   ```bash
   if [ -z "$LANGBASE_API_KEY" ]; then
       echo "❌ LANGBASE_API_KEY not set"
       exit 1
   fi
   ```

3. **Use error handling:**
   ```bash
   set -e  # Exit on error
   trap 'echo "❌ Deployment failed"' ERR
   ```

4. **Provide feedback:**
   ```bash
   echo "✓ Step completed"
   echo "❌ Step failed"
   echo "⚠  Warning message"
   ```

---

## Platform-Specific Guides

### Netlify

```bash
# netlify.toml
[build]
  command = "pnpm build:pkgs"
  publish = "dist"

[build.environment]
  NODE_VERSION = "18"

# Deploy
netlify deploy --prod
```

### Railway

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```

### Google Cloud Run

```bash
# Build container
gcloud builds submit --tag gcr.io/PROJECT_ID/baseai

# Deploy
gcloud run deploy baseai \
  --image gcr.io/PROJECT_ID/baseai \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Azure Functions

```bash
# Install Azure Functions Core Tools
npm install -g azure-functions-core-tools@4

# Create function app
func init --worker-runtime node

# Deploy
func azure functionapp publish <APP_NAME>
```

---

## Dockerfile Reference

The Docker deployment uses this Dockerfile:

```dockerfile
FROM node:18-alpine

RUN npm install -g pnpm@9.4.0

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages ./packages

RUN pnpm install --frozen-lockfile
RUN pnpm build:pkgs

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
```

---

## Troubleshooting

### Build Failures

**Issue:** Build fails with missing dependencies

**Solution:**
```bash
rm -rf node_modules
rm -rf pnpm-lock.yaml
pnpm install
```

### Environment Variable Issues

**Issue:** API keys not found in production

**Solution:**
- Verify variables are set in platform dashboard
- Check variable names match exactly
- Ensure variables are set for correct environment (production/preview)

### Memory Issues

**Issue:** Lambda/Function runs out of memory

**Solution:**
- Increase memory allocation
- For Lambda: `--memory-size 1024`
- Optimize code to reduce memory usage

### Timeout Issues

**Issue:** Function times out

**Solution:**
- Increase timeout limit
- For Lambda: `--timeout 60`
- Use streaming responses for long operations

---

## Security Best Practices

1. **Never commit secrets:**
   ```bash
   # .gitignore
   .env
   .env.local
   .env.*.local
   *.key
   ```

2. **Use platform secret management:**
   - AWS Secrets Manager
   - Vercel Environment Variables
   - Docker Secrets

3. **Rotate keys regularly:**
   ```bash
   # Update production keys
   vercel env add LANGBASE_API_KEY production
   ```

4. **Limit permissions:**
   - Use least-privilege IAM roles
   - Restrict API access by IP if possible

---

## Support

For deployment help:
- Documentation: https://baseai.dev/docs
- Deployment Guide: ../../DEPLOYMENT.md
- Issues: https://github.com/LangbaseInc/baseai/issues
