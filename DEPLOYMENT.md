# BaseAI Deployment Guide

This guide covers deploying BaseAI packages and applications to production environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Build Verification](#build-verification)
- [Package Publishing](#package-publishing)
- [Environment Configuration](#environment-configuration)
- [Deployment Options](#deployment-options)
- [LLM Provider Setup](#llm-provider-setup)
- [Production Best Practices](#production-best-practices)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying BaseAI, ensure you have:

- Node.js >= 18
- pnpm 9.4.0 or later
- Git repository access
- API keys for your chosen LLM provider(s)

## Build Verification

### 1. Install Dependencies

```bash
pnpm install
```

### 2. Build Core Packages

Build only the core packages (recommended for deployment):

```bash
pnpm build:pkgs
```

This builds:
- `@baseai/core` - Core library with pipes, helpers, and React integration
- `baseai` - CLI tool and development server

### 3. Run Type Checking

Verify TypeScript types are correct:

```bash
pnpm type-check
```

### 4. Run Tests

Execute the test suite:

```bash
pnpm test
```

## Package Publishing

### Publishing to npm

BaseAI uses changesets for version management and publishing.

1. **Create a changeset:**
   ```bash
   pnpm changeset
   ```

2. **Version packages:**
   ```bash
   pnpm version-packages
   ```

3. **Build and publish:**
   ```bash
   pnpm release
   ```

### Manual Publishing

For manual publishing:

```bash
# Build packages
pnpm build:pkgs

# Navigate to package directory
cd packages/baseai

# Publish
npm publish
```

## Environment Configuration

### Required Environment Variables

Create a `.env` file in your project root with the following variables:

```bash
# BaseAI Configuration (Production & Local)
LANGBASE_API_KEY=your_langbase_api_key

# LLM Provider API Keys (Local Development Only)
# Add keys for providers you're using
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
GOOGLE_API_KEY=your_google_key
GROQ_API_KEY=your_groq_key
TOGETHER_API_KEY=your_together_key
COHERE_API_KEY=your_cohere_key
FIREWORKS_API_KEY=your_fireworks_key
PERPLEXITY_API_KEY=your_perplexity_key
MISTRAL_API_KEY=your_mistral_key
XAI_API_KEY=your_xai_key
```

### Production vs Development

**Development:**
- Use local `.env` file
- Include all LLM provider keys for local testing
- Enable detailed logging via `baseai.config.ts`

**Production:**
- Use environment variables from your hosting platform
- Use Langbase LLM Keysets for production (more secure)
- Only include LANGBASE_API_KEY
- Disable sensitive data logging

## Deployment Options

### 1. Serverless Deployment (Vercel, Netlify)

BaseAI pipes work seamlessly with serverless functions.

**Vercel Example:**

```typescript
// app/api/chat/route.ts
import { Pipe } from '@baseai/core';
import pipeSummary from '@/baseai/pipes/summary';

export const runtime = 'edge'; // Optional: Use edge runtime

export async function POST(req: Request) {
  const { message } = await req.json();

  const pipe = new Pipe(pipeSummary());
  const { stream } = await pipe.run({
    messages: [{ role: 'user', content: message }],
    stream: true,
  });

  return new Response(stream);
}
```

**Environment Variables:**
- Add `LANGBASE_API_KEY` to Vercel project settings
- For local dev, add other provider keys

### 2. Node.js Server Deployment

Deploy as a traditional Node.js application.

**Example with Express:**

```typescript
import express from 'express';
import { Pipe } from '@baseai/core';
import pipeSummary from './baseai/pipes/summary';

const app = express();
app.use(express.json());

app.post('/api/chat', async (req, res) => {
  const { message } = req.body;

  const pipe = new Pipe(pipeSummary());
  const { stream } = await pipe.run({
    messages: [{ role: 'user', content: message }],
    stream: true,
  });

  stream.pipe(res);
});

app.listen(3000);
```

### 3. Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM node:18-alpine

# Install pnpm
RUN npm install -g pnpm@9.4.0

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages ./packages

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build packages
RUN pnpm build:pkgs

# Copy application code
COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
```

Build and run:

```bash
docker build -t baseai-app .
docker run -p 3000:3000 --env-file .env baseai-app
```

### 4. Platform-Specific Guides

#### AWS Lambda

```typescript
import { Pipe } from '@baseai/core';
import pipeSummary from './baseai/pipes/summary';

export const handler = async (event) => {
  const { message } = JSON.parse(event.body);

  const pipe = new Pipe(pipeSummary());
  const response = await pipe.run({
    messages: [{ role: 'user', content: message }],
    stream: false, // Lambda doesn't support streaming responses by default
  });

  return {
    statusCode: 200,
    body: JSON.stringify(response),
  };
};
```

#### Google Cloud Functions

```typescript
import { Pipe } from '@baseai/core';
import pipeSummary from './baseai/pipes/summary';

export const chat = async (req, res) => {
  const { message } = req.body;

  const pipe = new Pipe(pipeSummary());
  const { stream } = await pipe.run({
    messages: [{ role: 'user', content: message }],
    stream: true,
  });

  stream.pipe(res);
};
```

## LLM Provider Setup

BaseAI supports multiple LLM providers. Configure them in your pipe definitions.

### Supported Providers

| Provider | Model Format | API Key Variable |
|----------|--------------|------------------|
| OpenAI | `openai:gpt-4o-mini` | `OPENAI_API_KEY` |
| Anthropic | `anthropic:claude-3-sonnet-20240229` | `ANTHROPIC_API_KEY` |
| Google | `google:gemini-2.0-flash` | `GOOGLE_API_KEY` |
| Groq | `groq:llama-3-70b-specdec` | `GROQ_API_KEY` |
| Together AI | `together:meta-llama/Llama-3.3-70B-Instruct-Turbo` | `TOGETHER_API_KEY` |
| Cohere | `cohere:command-r-plus` | `COHERE_API_KEY` |
| Fireworks | `fireworks:accounts/fireworks/models/llama-v3p1-70b-instruct` | `FIREWORKS_API_KEY` |
| Perplexity | `perplexity:llama-3.1-sonar-small-128k-online` | `PERPLEXITY_API_KEY` |
| Mistral | `mistral:mistral-large-latest` | `MISTRAL_API_KEY` |
| xAI | `xai:grok-beta` | `XAI_API_KEY` |
| Ollama | `ollama:tinyllama` | Not required (local) |

### Example Pipe Configuration

```typescript
import { PipeI } from '@baseai/core';

const pipeSummary = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'summary',
  description: 'AI Summary agent',
  status: 'public',

  // Choose your provider and model
  model: 'openai:gpt-4o-mini',
  // model: 'anthropic:claude-3-sonnet-20240229',
  // model: 'google:gemini-2.0-flash',

  stream: true,
  json: false,
  store: true,
  moderate: true,

  // Model parameters
  top_p: 1,
  max_tokens: 1000,
  temperature: 0.7,
  presence_penalty: 1,
  frequency_penalty: 1,
  stop: [],

  // Tool configuration
  tool_choice: 'auto',
  parallel_tool_calls: true,

  messages: [
    {
      role: 'system',
      content: 'You are a helpful AI assistant.',
    }
  ],

  variables: [],
  memory: [],
  tools: []
});

export default pipeSummary;
```

### Using Local LLMs with Ollama

For development or on-premise deployments:

1. **Install Ollama:**
   ```bash
   # macOS/Linux
   curl -fsSL https://ollama.com/install.sh | sh

   # Or download from https://ollama.com
   ```

2. **Pull a model:**
   ```bash
   ollama pull tinyllama
   ```

3. **Configure your pipe:**
   ```typescript
   const pipe = (): PipeI => ({
     apiKey: process.env.LANGBASE_API_KEY,
     name: 'local-llm',
     model: 'ollama:tinyllama',
     // ... rest of config
   });
   ```

## Production Best Practices

### Security

1. **Never commit API keys to version control**
   - Use environment variables
   - Add `.env` to `.gitignore`

2. **Use Langbase LLM Keysets in production**
   - More secure than individual API keys
   - Centralized key management
   - Easy rotation

3. **Validate inputs**
   - Sanitize user messages
   - Set reasonable token limits
   - Enable content moderation

### Performance

1. **Enable streaming for better UX**
   ```typescript
   const { stream } = await pipe.run({
     messages: [...],
     stream: true, // Enable streaming
   });
   ```

2. **Use appropriate model sizes**
   - Smaller models (gpt-4o-mini) for simple tasks
   - Larger models (gpt-4o) for complex reasoning

3. **Implement caching**
   - Cache frequent responses
   - Use memory for context retention

### Monitoring

1. **Enable logging in production**
   ```typescript
   // baseai.config.ts
   export const config: BaseAIConfig = {
     log: {
       isEnabled: true,
       logSensitiveData: false, // NEVER true in production
       pipe: true,
       'pipe.completion': true,
       'pipe.request': true,
       'pipe.response': true,
     },
   };
   ```

2. **Track usage and costs**
   - Monitor token usage
   - Set up alerts for high usage
   - Use Langbase dashboard for analytics

### Scaling

1. **Horizontal scaling**
   - Serverless functions auto-scale
   - Deploy multiple instances behind load balancer

2. **Rate limiting**
   - Implement rate limits per user
   - Use queue systems for high traffic

3. **Error handling**
   ```typescript
   try {
     const response = await pipe.run({...});
   } catch (error) {
     console.error('Pipe execution failed:', error);
     // Implement retry logic
     // Fallback to different model
   }
   ```

## Troubleshooting

### Build Issues

**Problem:** `turbo: not found`

```bash
# Solution: Install dependencies first
pnpm install
```

**Problem:** Canvas package fails to install

```
# This is optional and doesn't affect core functionality
# Safe to ignore unless you need canvas rendering
```

### Runtime Issues

**Problem:** `API key not found`

```
# Solution: Ensure environment variables are set
# Check .env file exists and is loaded
# For production, verify platform environment variables
```

**Problem:** `Unsupported model provider`

```
# Solution: Check model format is correct
# Format: provider:model-name
# Example: openai:gpt-4o-mini
```

**Problem:** Streaming not working

```
# Solution: Ensure your deployment platform supports streaming
# Edge runtimes (Vercel Edge, Cloudflare Workers) support streaming
# Traditional serverless may need non-streaming responses
```

### Performance Issues

**Problem:** Slow response times

```
# Solutions:
# 1. Use smaller, faster models
# 2. Reduce max_tokens
# 3. Enable streaming
# 4. Use edge deployments closer to users
```

## Support

- Documentation: https://baseai.dev/docs
- Learn: https://baseai.dev/learn
- Issues: https://github.com/LangbaseInc/baseai/issues
- Security: security@langbase.com

## License

BaseAI is licensed under Apache-2.0. See LICENSE file for details.
