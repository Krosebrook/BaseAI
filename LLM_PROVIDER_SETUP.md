# LLM Provider Configuration Guide

Complete guide to setting up and configuring different LLM providers with BaseAI.

## Quick Start

1. Copy the environment template:
   ```bash
   cp .env.baseai.example .env
   ```

2. Add your API keys to `.env`

3. Configure your pipe with the desired provider and model

## Provider Setup

### OpenAI

**Get API Key:** https://platform.openai.com/api-keys

**Environment Variable:**
```bash
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
import { PipeI } from '@baseai/core';

const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'openai-chat',
  description: 'Chat with OpenAI GPT models',
  model: 'openai:gpt-4o-mini', // or gpt-4o, gpt-4-turbo, gpt-3.5-turbo
  stream: true,
  max_tokens: 1000,
  temperature: 0.7,
  top_p: 1,
  presence_penalty: 0,
  frequency_penalty: 0,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `openai:gpt-4o` - Most capable, multimodal
- `openai:gpt-4o-mini` - Fast and affordable
- `openai:gpt-4-turbo` - Optimized GPT-4
- `openai:gpt-3.5-turbo` - Fast, cost-effective

**API Configuration:**
- Base URL: `https://api.openai.com/v1`
- Auth: `Authorization: Bearer {API_KEY}`

---

### Anthropic (Claude)

**Get API Key:** https://console.anthropic.com/settings/keys

**Environment Variable:**
```bash
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'claude-chat',
  description: 'Chat with Claude',
  model: 'anthropic:claude-3-5-sonnet-20241022',
  stream: true,
  max_tokens: 4096,
  temperature: 1,
  top_p: 1,
  messages: [
    { role: 'system', content: 'You are Claude, a helpful AI assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `anthropic:claude-3-5-sonnet-20241022` - Best balance of intelligence and speed
- `anthropic:claude-3-5-haiku-20241022` - Fastest, most compact
- `anthropic:claude-3-opus-20240229` - Most powerful for complex tasks
- `anthropic:claude-3-sonnet-20240229` - Balanced performance

**API Configuration:**
- Base URL: `https://api.anthropic.com/v1`
- Auth: `X-API-Key: {API_KEY}`
- Version: `anthropic-version: 2023-06-01`

---

### Google Generative AI (Gemini)

**Get API Key:** https://ai.google.dev/

**Environment Variable:**
```bash
GOOGLE_API_KEY=AIzaSyxxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'gemini-chat',
  description: 'Chat with Google Gemini',
  model: 'google:gemini-2.0-flash',
  stream: true,
  max_tokens: 2048,
  temperature: 0.9,
  top_p: 1,
  messages: [
    { role: 'system', content: 'You are a helpful AI assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `google:gemini-2.0-flash` - Latest, fast and capable
- `google:gemini-1.5-pro` - Advanced reasoning
- `google:gemini-1.5-flash` - Fast responses

**API Configuration:**
- Base URL: `https://generativelanguage.googleapis.com/v1beta`
- Auth: API key in URL query parameter

---

### Groq

**Get API Key:** https://console.groq.com/keys

**Environment Variable:**
```bash
GROQ_API_KEY=gsk_xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'groq-chat',
  description: 'Ultra-fast inference with Groq',
  model: 'groq:llama-3.3-70b-versatile',
  stream: true,
  max_tokens: 1000,
  temperature: 0.7,
  top_p: 1,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `groq:llama-3.3-70b-versatile` - Latest Llama 3.3
- `groq:llama-3.1-70b-versatile` - Llama 3.1 70B
- `groq:mixtral-8x7b-32768` - Mixtral MoE
- `groq:gemma2-9b-it` - Google's Gemma 2

**Features:**
- Extremely fast inference (500+ tokens/sec)
- Low latency
- OpenAI-compatible API

**API Configuration:**
- Base URL: `https://api.groq.com/openai/v1`
- Auth: `Authorization: Bearer {API_KEY}`

---

### Together AI

**Get API Key:** https://api.together.xyz/settings/api-keys

**Environment Variable:**
```bash
TOGETHER_API_KEY=xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'together-chat',
  description: 'Chat with Together AI models',
  model: 'together:meta-llama/Llama-3.3-70B-Instruct-Turbo',
  stream: true,
  max_tokens: 2048,
  temperature: 0.7,
  top_p: 0.9,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `together:meta-llama/Llama-3.3-70B-Instruct-Turbo` - Latest Llama
- `together:meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo` - Llama 3.1
- `together:mistralai/Mixtral-8x7B-Instruct-v0.1` - Mixtral
- `together:Qwen/Qwen2.5-72B-Instruct-Turbo` - Qwen 2.5

**API Configuration:**
- Base URL: `https://api.together.xyz`
- Auth: `Authorization: Bearer {API_KEY}`

---

### Cohere

**Get API Key:** https://dashboard.cohere.com/api-keys

**Environment Variable:**
```bash
COHERE_API_KEY=xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'cohere-chat',
  description: 'Chat with Cohere models',
  model: 'cohere:command-r-plus',
  stream: true,
  max_tokens: 1000,
  temperature: 0.7,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `cohere:command-r-plus` - Most capable
- `cohere:command-r` - Balanced performance
- `cohere:command-light` - Fast and efficient

**API Configuration:**
- Base URL: `https://api.cohere.ai/v1`
- Auth: `Authorization: Bearer {API_KEY}`

---

### Fireworks AI

**Get API Key:** https://fireworks.ai/api-keys

**Environment Variable:**
```bash
FIREWORKS_API_KEY=fw_xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'fireworks-chat',
  description: 'Fast inference with Fireworks',
  model: 'fireworks:accounts/fireworks/models/llama-v3p1-70b-instruct',
  stream: true,
  max_tokens: 2048,
  temperature: 0.7,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `fireworks:accounts/fireworks/models/llama-v3p1-70b-instruct`
- `fireworks:accounts/fireworks/models/mixtral-8x7b-instruct`

**API Configuration:**
- OpenAI-compatible API
- Fast inference speeds

---

### Perplexity

**Get API Key:** https://www.perplexity.ai/settings/api

**Environment Variable:**
```bash
PERPLEXITY_API_KEY=pplx-xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'perplexity-chat',
  description: 'Chat with online Perplexity models',
  model: 'perplexity:llama-3.1-sonar-small-128k-online',
  stream: true,
  max_tokens: 1000,
  temperature: 0.7,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `perplexity:llama-3.1-sonar-small-128k-online` - Fast with web search
- `perplexity:llama-3.1-sonar-large-128k-online` - More capable with web search
- `perplexity:llama-3.1-sonar-small-128k-chat` - Standard chat
- `perplexity:llama-3.1-sonar-large-128k-chat` - Advanced chat

**Special Features:**
- Online models have real-time web search
- Chat models are standard LLM responses

---

### Mistral AI

**Get API Key:** https://console.mistral.ai/api-keys/

**Environment Variable:**
```bash
MISTRAL_API_KEY=xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'mistral-chat',
  description: 'Chat with Mistral models',
  model: 'mistral:mistral-large-latest',
  stream: true,
  max_tokens: 2048,
  temperature: 0.7,
  top_p: 1,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `mistral:mistral-large-latest` - Most capable
- `mistral:mistral-medium-latest` - Balanced
- `mistral:mistral-small-latest` - Fast and efficient
- `mistral:codestral-latest` - Optimized for code

**API Configuration:**
- Base URL: `https://api.mistral.ai/v1`
- Auth: `Authorization: Bearer {API_KEY}`

---

### xAI (Grok)

**Get API Key:** https://console.x.ai/

**Environment Variable:**
```bash
XAI_API_KEY=xai-xxxxxxxxxxxxx
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'grok-chat',
  description: 'Chat with Grok',
  model: 'xai:grok-beta',
  stream: true,
  max_tokens: 2048,
  temperature: 0.7,
  messages: [
    { role: 'system', content: 'You are Grok, a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `xai:grok-beta` - Latest Grok model

---

### Ollama (Local LLMs)

**Setup:** https://ollama.com

**No API Key Required** - Runs locally

**Installation:**
```bash
# macOS/Linux
curl -fsSL https://ollama.com/install.sh | sh

# Windows
# Download from https://ollama.com/download
```

**Pull a Model:**
```bash
ollama pull tinyllama
ollama pull llama3.3
ollama pull phi4
ollama pull qwen2.5
```

**Pipe Configuration:**
```typescript
const pipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY,
  name: 'local-llm',
  description: 'Chat with local Ollama model',
  model: 'ollama:llama3.3',
  stream: true,
  max_tokens: 2048,
  temperature: 0.7,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ],
  tools: [],
  memory: []
});
```

**Popular Models:**
- `ollama:llama3.3` - Latest Llama (7B, 70B)
- `ollama:phi4` - Microsoft Phi-4
- `ollama:qwen2.5` - Alibaba's Qwen
- `ollama:mistral` - Mistral 7B
- `ollama:tinyllama` - Tiny 1.1B model for testing

**Custom Ollama Host:**
```typescript
// If Ollama runs on custom host/port
const pipe = (): PipeI => ({
  // ... other config
  model: 'ollama:llama3.3',
  // Custom host handled by BaseAI automatically
});
```

**API Configuration:**
- Default: `http://localhost:11434`
- OpenAI-compatible API at `/v1/chat/completions`

---

## Environment Setup

### Development (.env)

```bash
# Langbase API Key (required)
LANGBASE_API_KEY=your_langbase_key

# Add only the providers you're using
OPENAI_API_KEY=sk-proj-xxxxx
ANTHROPIC_API_KEY=sk-ant-xxxxx
GOOGLE_API_KEY=AIzaSyxxxxx
GROQ_API_KEY=gsk_xxxxx
TOGETHER_API_KEY=xxxxx
COHERE_API_KEY=xxxxx
FIREWORKS_API_KEY=fw_xxxxx
PERPLEXITY_API_KEY=pplx-xxxxx
MISTRAL_API_KEY=xxxxx
XAI_API_KEY=xai-xxxxx
```

### Production

For production deployments:

1. **Use Langbase LLM Keysets** (recommended)
   - More secure
   - Centralized management
   - Easy key rotation
   - Only need `LANGBASE_API_KEY`

2. **Or use platform environment variables**
   - Set in Vercel/Netlify/AWS dashboard
   - Never commit to version control

---

## Provider Comparison

| Provider | Speed | Cost | Context | Best For |
|----------|-------|------|---------|----------|
| OpenAI GPT-4o | Fast | Medium | 128K | General purpose |
| OpenAI GPT-4o-mini | Very Fast | Low | 128K | Simple tasks |
| Claude 3.5 Sonnet | Fast | Medium | 200K | Complex reasoning |
| Claude 3.5 Haiku | Very Fast | Low | 200K | Fast responses |
| Gemini 2.0 Flash | Very Fast | Low | 1M | Long context |
| Groq Llama 3.3 | Ultra Fast | Low | 128K | Speed critical |
| Together AI | Fast | Low | Varies | Open source |
| Perplexity Online | Fast | Medium | 128K | Web-connected |
| Ollama | Fast | Free | Varies | Local/private |

---

## Model Selection Guide

### For Production Apps
- **Primary:** `openai:gpt-4o-mini` - Best balance
- **Fallback:** `anthropic:claude-3-5-haiku-20241022`

### For Complex Tasks
- **Primary:** `anthropic:claude-3-5-sonnet-20241022`
- **Alternative:** `openai:gpt-4o`

### For Speed
- **Primary:** `groq:llama-3.3-70b-versatile`
- **Alternative:** `google:gemini-2.0-flash`

### For Cost Optimization
- **Primary:** `groq:llama-3.3-70b-versatile` (free tier)
- **Alternative:** `ollama:llama3.3` (local, free)

### For Privacy/Local
- **Primary:** `ollama:llama3.3`
- **Alternative:** `ollama:phi4`

### For Web Search
- **Primary:** `perplexity:llama-3.1-sonar-small-128k-online`

---

## Testing Your Setup

Create a test file `test-provider.ts`:

```typescript
import 'dotenv/config';
import { Pipe } from '@baseai/core';
import { PipeI } from '@baseai/core';

const testPipe = (): PipeI => ({
  apiKey: process.env.LANGBASE_API_KEY!,
  name: 'test',
  model: 'openai:gpt-4o-mini', // Change to test different providers
  stream: false,
  max_tokens: 50,
  temperature: 0.7,
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' }
  ]
});

async function main() {
  const pipe = new Pipe(testPipe());
  const response = await pipe.run({
    messages: [{ role: 'user', content: 'Hello! Just testing the API.' }]
  });
  console.log('Success!', response);
}

main();
```

Run:
```bash
npx baseai@latest dev  # In one terminal
npx tsx test-provider.ts  # In another terminal
```

---

## Troubleshooting

### API Key Not Found
```
Error: API key not found for provider
```
**Solution:** Ensure environment variable is set and `.env` file is loaded.

### Invalid Model Name
```
Error: Unsupported model provider
```
**Solution:** Check model format is `provider:model-name`.

### Rate Limit Errors
**Solution:**
- Upgrade your provider plan
- Implement retry logic
- Use multiple providers with fallback

### Streaming Issues
**Solution:**
- Ensure platform supports streaming responses
- Use `stream: false` for non-streaming platforms

---

## Next Steps

1. Choose your provider(s)
2. Get API key(s)
3. Add to `.env` file
4. Create a pipe with your model
5. Start building!

For more information:
- BaseAI Documentation: https://baseai.dev/docs
- Pipe Guide: https://baseai.dev/docs/pipe/quickstart
- Memory (RAG): https://baseai.dev/docs/memory/quickstart
