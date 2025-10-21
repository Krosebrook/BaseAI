# BaseAI API Reference

Complete API reference for BaseAI core library and CLI.

## Table of Contents

- [Core Library (@baseai/core)](#core-library-baseaicore)
  - [Pipe](#pipe)
  - [Types](#types)
  - [Helpers](#helpers)
- [CLI (baseai)](#cli-baseai)
- [Configuration](#configuration)

---

## Core Library (@baseai/core)

### Installation

```bash
npm install @baseai/core
# or
pnpm add @baseai/core
```

### Pipe

The `Pipe` class is the main interface for running AI agents.

#### Constructor

```typescript
import { Pipe } from '@baseai/core';
import type { PipeI } from '@baseai/core';

const pipeConfig: PipeI = {
  apiKey: string;
  name: string;
  description?: string;
  status: 'public' | 'private';
  model: string;
  stream: boolean;
  json: boolean;
  store: boolean;
  moderate: boolean;
  top_p: number;
  max_tokens: number;
  temperature: number;
  presence_penalty: number;
  frequency_penalty: number;
  stop: string[];
  tool_choice: 'auto' | 'required' | 'none' | { type: 'function'; function: { name: string } };
  parallel_tool_calls: boolean;
  messages: Message[];
  variables: Variable[];
  memory: Memory[];
  tools: Tool[];
};

const pipe = new Pipe(pipeConfig);
```

#### PipeI Interface

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `apiKey` | `string` | Yes | - | Langbase API key |
| `name` | `string` | Yes | - | Unique pipe name |
| `description` | `string` | No | `''` | Pipe description |
| `status` | `'public' \| 'private'` | Yes | - | Pipe visibility |
| `model` | `string` | Yes | - | Model in format `provider:model-name` |
| `stream` | `boolean` | No | `false` | Enable streaming responses |
| `json` | `boolean` | No | `false` | Force JSON output |
| `store` | `boolean` | No | `true` | Store conversation history |
| `moderate` | `boolean` | No | `false` | Enable content moderation |
| `top_p` | `number` | No | `1` | Nucleus sampling (0-1) |
| `max_tokens` | `number` | No | `1000` | Maximum tokens to generate |
| `temperature` | `number` | No | `0.7` | Randomness (0-2) |
| `presence_penalty` | `number` | No | `0` | Penalty for new topics (-2 to 2) |
| `frequency_penalty` | `number` | No | `0` | Penalty for repetition (-2 to 2) |
| `stop` | `string[]` | No | `[]` | Stop sequences |
| `tool_choice` | `string \| object` | No | `'auto'` | How to use tools |
| `parallel_tool_calls` | `boolean` | No | `true` | Allow parallel tool execution |
| `messages` | `Message[]` | Yes | - | System/user messages |
| `variables` | `Variable[]` | No | `[]` | Dynamic variables |
| `memory` | `Memory[]` | No | `[]` | RAG memory sources |
| `tools` | `Tool[]` | No | `[]` | Available tools |

#### Methods

##### run()

Execute the pipe without streaming.

```typescript
async run(options: RunOptions): Promise<RunResponse>
```

**Parameters:**

```typescript
interface RunOptions {
  messages?: Message[];        // Additional messages
  variables?: Variable[];      // Variable values
  threadId?: string;          // Conversation thread ID
  rawResponse?: boolean;      // Include raw HTTP headers
  runTools?: boolean;         // Enable tool execution
  tools?: Tool[];            // Additional tools
  name?: string;             // Override pipe name
  apiKey?: string;           // Override API key
  llmKey?: string;           // Direct LLM API key
}
```

**Returns:**

```typescript
interface RunResponse {
  completion: string;                    // Generated text
  threadId?: string;                    // Thread identifier
  id: string;                           // Response ID
  object: string;                       // Response type
  created: number;                      // Unix timestamp
  model: string;                        // Model used
  choices: ChoiceGenerate[];           // Response choices
  usage: Usage;                         // Token usage
  system_fingerprint: string | null;   // Model fingerprint
  rawResponse?: {                       // Raw HTTP response
    headers: Record<string, string>;
  };
}

interface Usage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
}
```

**Example:**

```typescript
const pipe = new Pipe(pipeConfig);

const response = await pipe.run({
  messages: [
    { role: 'user', content: 'Hello!' }
  ]
});

console.log(response.completion);
console.log(response.usage);
```

##### run() with streaming

Execute the pipe with streaming enabled.

```typescript
async run(options: RunOptionsStream): Promise<RunResponseStream>
```

**Parameters:**

```typescript
interface RunOptionsStream extends RunOptions {
  stream: true;
}
```

**Returns:**

```typescript
interface RunResponseStream {
  stream: ReadableStream<any>;
  threadId: string | null;
  rawResponse?: {
    headers: Record<string, string>;
  };
}
```

**Example:**

```typescript
const { stream } = await pipe.run({
  messages: [
    { role: 'user', content: 'Tell me a story' }
  ],
  stream: true
});

// Use with getRunner helper
import { getRunner } from '@baseai/core';

const runner = getRunner(stream);

runner.on('connect', () => {
  console.log('Stream started');
});

runner.on('content', (content) => {
  process.stdout.write(content);
});

runner.on('end', () => {
  console.log('\nStream ended');
});

runner.on('error', (error) => {
  console.error('Error:', error);
});
```

---

### Types

#### Message

```typescript
interface Message {
  role: MessageRole;
  content: string;
  name?: string;
}

type MessageRole = 'system' | 'user' | 'assistant' | 'tool';
```

**Example:**

```typescript
const messages: Message[] = [
  { role: 'system', content: 'You are a helpful assistant.' },
  { role: 'user', content: 'What is AI?' },
  { role: 'assistant', content: 'AI stands for...' }
];
```

#### Variable

```typescript
interface Variable {
  name: string;
  value: string;
}
```

**Example:**

```typescript
// In pipe config
const pipe: PipeI = {
  // ...
  messages: [
    { role: 'system', content: 'You are {{role}}' }
  ],
  variables: [
    { name: 'role', value: '' }
  ]
};

// At runtime
await pipe.run({
  variables: [
    { name: 'role', value: 'a helpful coding assistant' }
  ]
});
```

#### Memory

```typescript
interface Memory {
  name: string;
}
```

**Example:**

```typescript
const pipe: PipeI = {
  // ...
  memory: [
    { name: 'product-docs' }
  ]
};
```

#### Tool

```typescript
interface Tool {
  run: (...args: any[]) => Promise<any>;
  function: {
    name: string;
    description: string;
    parameters: object;  // JSON Schema
  };
}
```

**Example:**

```typescript
const weatherTool: Tool = {
  async run({ location }: { location: string }) {
    // Fetch weather data
    const weather = await fetchWeather(location);
    return JSON.stringify(weather);
  },
  function: {
    name: 'get_weather',
    description: 'Get current weather for a location',
    parameters: {
      type: 'object',
      properties: {
        location: {
          type: 'string',
          description: 'City name or coordinates'
        }
      },
      required: ['location']
    }
  }
};

const pipe = new Pipe({
  // ...
  tools: [weatherTool],
  tool_choice: 'auto'
});
```

---

### Helpers

#### getRunner()

Convert a ReadableStream to an event-based runner.

```typescript
import { getRunner } from '@baseai/core';

function getRunner(stream: ReadableStream): Runner
```

**Runner Events:**

```typescript
interface Runner {
  on(event: 'connect', callback: () => void): void;
  on(event: 'content', callback: (content: string) => void): void;
  on(event: 'end', callback: () => void): void;
  on(event: 'error', callback: (error: Error) => void): void;
}
```

**Example:**

```typescript
const { stream } = await pipe.run({ stream: true });
const runner = getRunner(stream);

runner.on('connect', () => {
  console.log('Connected');
});

runner.on('content', (chunk) => {
  process.stdout.write(chunk);
});

runner.on('end', () => {
  console.log('Done');
});

runner.on('error', (err) => {
  console.error('Error:', err);
});
```

#### getToolsFromStream()

Extract tool calls from a streaming response.

```typescript
import { getToolsFromStream } from '@baseai/core';

function getToolsFromStream(stream: ReadableStream): Promise<ToolCallResult[]>
```

**Example:**

```typescript
const { stream } = await pipe.run({
  stream: true,
  runTools: true
});

const toolResults = await getToolsFromStream(stream);
console.log('Tools called:', toolResults);
```

---

## CLI (baseai)

### Installation

```bash
# Global
npm install -g baseai

# Local (recommended)
npx baseai@latest
```

### Commands

#### init

Initialize BaseAI in your project.

```bash
npx baseai@latest init
```

Creates:
- `baseai/` directory
- `baseai/baseai.config.ts` configuration file
- `baseai/pipes/` for AI agents
- `baseai/tools/` for custom tools
- `baseai/memory/` for RAG memory

#### dev

Start the local development server.

```bash
npx baseai@latest dev
```

**Options:**
- Starts local server on `http://localhost:9000`
- Hot-reloads on pipe changes
- Provides local model inference

#### pipe

Create a new pipe (AI agent).

```bash
npx baseai@latest pipe
```

**Interactive prompts:**
1. Pipe name
2. Description
3. Model selection
4. Initial configuration

Creates a new file in `baseai/pipes/`.

#### memory

Create a new memory source for RAG.

```bash
npx baseai@latest memory
```

**Interactive prompts:**
1. Memory name
2. Git repository or local path
3. Document selection

Creates:
- Memory configuration in `baseai/memory/`
- Embedding store

#### tool

Create a new tool.

```bash
npx baseai@latest tool
```

**Interactive prompts:**
1. Tool name
2. Description
3. Parameters

Creates a new tool file in `baseai/tools/`.

---

## Configuration

### baseai.config.ts

Project-level configuration.

```typescript
import type { BaseAIConfig } from 'baseai';

export const config: BaseAIConfig = {
  log: {
    isEnabled: boolean;           // Enable logging
    logSensitiveData: boolean;   // Log API keys (dev only!)
    pipe: boolean;               // Log pipe execution
    'pipe.completion': boolean;  // Log completions
    'pipe.request': boolean;     // Log requests
    'pipe.response': boolean;    // Log responses
    tool: boolean;               // Log tool calls
    memory: boolean;             // Log memory queries
  },
  envFilePath: string;           // Path to .env file
  memory: {
    useLocalEmbeddings: boolean; // Use local embeddings
  },
};
```

**Example:**

```typescript
export const config: BaseAIConfig = {
  log: {
    isEnabled: true,
    logSensitiveData: false,  // NEVER true in production
    pipe: true,
    'pipe.completion': true,
    'pipe.request': true,
    'pipe.response': true,
    tool: true,
    memory: true,
  },
  envFilePath: '.env.local',
  memory: {
    useLocalEmbeddings: false,
  },
};
```

---

## Model Providers

### Supported Providers

BaseAI supports 11+ LLM providers:

| Provider | Format | Example |
|----------|--------|---------|
| OpenAI | `openai:model` | `openai:gpt-4o-mini` |
| Anthropic | `anthropic:model` | `anthropic:claude-3-5-sonnet-20241022` |
| Google | `google:model` | `google:gemini-2.0-flash` |
| Groq | `groq:model` | `groq:llama-3.3-70b-versatile` |
| Together AI | `together:model` | `together:meta-llama/Llama-3.3-70B-Instruct-Turbo` |
| Cohere | `cohere:model` | `cohere:command-r-plus` |
| Fireworks | `fireworks:model` | `fireworks:accounts/fireworks/models/llama-v3p1-70b-instruct` |
| Perplexity | `perplexity:model` | `perplexity:llama-3.1-sonar-small-128k-online` |
| Mistral | `mistral:model` | `mistral:mistral-large-latest` |
| xAI | `xai:model` | `xai:grok-beta` |
| Ollama | `ollama:model` | `ollama:llama3.3` |

See [LLM_PROVIDER_SETUP.md](./LLM_PROVIDER_SETUP.md) for detailed setup instructions.

---

## Error Handling

### Common Errors

#### API Key Missing

```typescript
try {
  const pipe = new Pipe(config);
  await pipe.run({...});
} catch (error) {
  if (error.message.includes('API key')) {
    console.error('Set LANGBASE_API_KEY environment variable');
  }
}
```

#### Rate Limit

```typescript
try {
  await pipe.run({...});
} catch (error) {
  if (error.status === 429) {
    // Implement retry with backoff
    await sleep(1000);
    return pipe.run({...});
  }
}
```

#### Model Not Found

```typescript
try {
  const pipe = new Pipe({
    model: 'invalid:model' // ❌
  });
} catch (error) {
  console.error('Invalid model format. Use: provider:model-name');
}
```

---

## Best Practices

### 1. Use TypeScript

Get full type safety and autocomplete:

```typescript
import { Pipe, type PipeI, type Message } from '@baseai/core';

const config: PipeI = {
  // TypeScript will validate all properties
};
```

### 2. Handle Errors

Always wrap pipe calls in try-catch:

```typescript
try {
  const response = await pipe.run({...});
  return response.completion;
} catch (error) {
  console.error('Pipe failed:', error);
  return 'Sorry, I encountered an error.';
}
```

### 3. Use Streaming for Better UX

Stream responses for real-time feedback:

```typescript
const { stream } = await pipe.run({ stream: true });
const runner = getRunner(stream);

runner.on('content', (chunk) => {
  // Update UI in real-time
  updateUI(chunk);
});
```

### 4. Implement Rate Limiting

Prevent abuse and control costs:

```typescript
const limiter = new RateLimiter({ max: 10, window: 60000 });

if (!limiter.check(userId)) {
  throw new Error('Rate limit exceeded');
}

await pipe.run({...});
```

### 5. Validate Inputs

Sanitize user inputs:

```typescript
import { z } from 'zod';

const InputSchema = z.object({
  message: z.string().min(1).max(4000)
});

const { message } = InputSchema.parse(userInput);
await pipe.run({ messages: [{ role: 'user', content: message }] });
```

---

## Examples

### Basic Chat

```typescript
import { Pipe } from '@baseai/core';
import config from './baseai/pipes/chat';

const pipe = new Pipe(config());

const response = await pipe.run({
  messages: [
    { role: 'user', content: 'Hello!' }
  ]
});

console.log(response.completion);
```

### Streaming Chat

```typescript
import { Pipe, getRunner } from '@baseai/core';

const pipe = new Pipe(config());

const { stream } = await pipe.run({
  messages: [{ role: 'user', content: 'Tell me a joke' }],
  stream: true
});

const runner = getRunner(stream);
runner.on('content', chunk => process.stdout.write(chunk));
```

### With Tools

```typescript
const getCurrentTime: Tool = {
  async run() {
    return new Date().toISOString();
  },
  function: {
    name: 'get_current_time',
    description: 'Get the current time',
    parameters: { type: 'object', properties: {} }
  }
};

const pipe = new Pipe({
  ...config,
  tools: [getCurrentTime]
});

const response = await pipe.run({
  messages: [{ role: 'user', content: 'What time is it?' }],
  runTools: true
});
```

### With Memory (RAG)

```typescript
const pipe = new Pipe({
  ...config,
  memory: [
    { name: 'product-docs' }
  ]
});

const response = await pipe.run({
  messages: [
    { role: 'user', content: 'How do I deploy this?' }
  ]
});
```

### With Variables

```typescript
const pipe = new Pipe({
  ...config,
  messages: [
    { role: 'system', content: 'You are {{character}} from {{series}}' }
  ],
  variables: [
    { name: 'character', value: '' },
    { name: 'series', value: '' }
  ]
});

await pipe.run({
  variables: [
    { name: 'character', value: 'Sherlock Holmes' },
    { name: 'series', value: 'BBC Sherlock' }
  ],
  messages: [
    { role: 'user', content: 'Solve this mystery...' }
  ]
});
```

---

## Additional Resources

- [Documentation](https://baseai.dev/docs)
- [Learn BaseAI](https://baseai.dev/learn)
- [Examples](https://github.com/LangbaseInc/baseai/tree/main/examples)
- [Deployment Guide](./DEPLOYMENT.md)
- [LLM Provider Setup](./LLM_PROVIDER_SETUP.md)
- [Security Guide](./SECURITY_GUIDE.md)

---

Last updated: 2025-10-21
