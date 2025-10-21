# Testing Guide

Comprehensive testing guide for BaseAI development.

## Quick Start

Run all tests:

```bash
pnpm test
```

Or use the automated test setup script:

```bash
./scripts/test-setup.sh
```

## Test Structure

BaseAI uses Vitest for testing across different environments.

### Test Environments

1. **Node.js Tests** (`vitest.node.config.js`)
   - Server-side functionality
   - Pipe execution
   - Tool integration
   - Memory (RAG) operations

2. **Edge Tests** (`vitest.edge.config.js`)
   - Edge runtime compatibility
   - Streaming responses
   - Lightweight operations

3. **React Tests** (`vitest.ui.react.config.js`)
   - React hooks
   - UI components
   - Client-side integration

## Running Tests

### All Tests

```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm test:node:watch
pnpm test:edge:watch
pnpm test:ui:react:watch
```

### Specific Test Suites

```bash
# Node.js tests only
pnpm test:node

# Edge runtime tests
pnpm test:edge

# React UI tests
pnpm test:ui:react
```

### Single Test File

```bash
# Run specific test file
pnpm vitest run path/to/test.test.ts

# Watch mode for specific file
pnpm vitest watch path/to/test.test.ts
```

## Writing Tests

### Test File Naming

- Unit tests: `*.test.ts`
- Integration tests: `*.integration.test.ts`
- E2E tests: `*.e2e.test.ts`

### Example: Pipe Test

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { Pipe } from '../pipes';
import type { PipeI } from '../../types/pipes';

describe('Pipe', () => {
  let pipe: Pipe;
  let config: PipeI;

  beforeAll(() => {
    config = {
      apiKey: process.env.LANGBASE_API_KEY!,
      name: 'test-pipe',
      description: 'Test pipe',
      status: 'public',
      model: 'openai:gpt-4o-mini',
      stream: false,
      json: false,
      store: false,
      moderate: false,
      top_p: 1,
      max_tokens: 100,
      temperature: 0.7,
      presence_penalty: 0,
      frequency_penalty: 0,
      stop: [],
      tool_choice: 'auto',
      parallel_tool_calls: false,
      messages: [
        { role: 'system', content: 'You are a helpful assistant.' }
      ],
      variables: [],
      memory: [],
      tools: []
    };

    pipe = new Pipe(config);
  });

  it('should create a pipe instance', () => {
    expect(pipe).toBeDefined();
    expect(pipe).toBeInstanceOf(Pipe);
  });

  it('should run successfully', async () => {
    const response = await pipe.run({
      messages: [
        { role: 'user', content: 'Say "test"' }
      ]
    });

    expect(response).toBeDefined();
    expect(response.completion).toBeDefined();
    expect(typeof response.completion).toBe('string');
  });

  it('should handle streaming', async () => {
    const { stream } = await pipe.run({
      messages: [
        { role: 'user', content: 'Count to 3' }
      ],
      stream: true
    });

    expect(stream).toBeDefined();
    expect(stream).toBeInstanceOf(ReadableStream);
  });

  it('should respect max_tokens', async () => {
    const shortPipe = new Pipe({
      ...config,
      max_tokens: 10
    });

    const response = await shortPipe.run({
      messages: [
        { role: 'user', content: 'Write a long story' }
      ]
    });

    expect(response.usage.completion_tokens).toBeLessThanOrEqual(10);
  });
});
```

### Example: Tool Test

```typescript
import { describe, it, expect } from 'vitest';
import { Pipe } from '../pipes';
import type { Tool } from '../../types/tools';

describe('Pipe with Tools', () => {
  const mockTool: Tool = {
    async run({ input }: { input: string }) {
      return `Processed: ${input}`;
    },
    function: {
      name: 'process_text',
      description: 'Process text input',
      parameters: {
        type: 'object',
        properties: {
          input: {
            type: 'string',
            description: 'Text to process'
          }
        },
        required: ['input']
      }
    }
  };

  it('should execute tools', async () => {
    const pipe = new Pipe({
      // ... config
      tools: [mockTool]
    });

    const response = await pipe.run({
      messages: [
        { role: 'user', content: 'Process this: hello world' }
      ],
      runTools: true
    });

    expect(response).toBeDefined();
  });
});
```

### Example: Memory (RAG) Test

```typescript
import { describe, it, expect } from 'vitest';
import { Pipe } from '../pipes';

describe('Pipe with Memory', () => {
  it('should use memory context', async () => {
    const pipe = new Pipe({
      // ... config
      memory: [
        { name: 'test-docs' }
      ]
    });

    const response = await pipe.run({
      messages: [
        { role: 'user', content: 'What do the docs say about deployment?' }
      ]
    });

    expect(response.completion).toBeDefined();
    // Should include context from memory
  });
});
```

## Mocking

### Mock API Responses

```typescript
import { vi } from 'vitest';

// Mock fetch
global.fetch = vi.fn(() =>
  Promise.resolve({
    ok: true,
    json: async () => ({
      completion: 'Mocked response',
      usage: { total_tokens: 10 }
    })
  })
) as any;
```

### Mock Environment Variables

```typescript
import { beforeEach, afterEach } from 'vitest';

describe('Environment Tests', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = {
      ...originalEnv,
      LANGBASE_API_KEY: 'test-key',
      OPENAI_API_KEY: 'test-openai-key'
    };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it('should use environment variables', () => {
    expect(process.env.LANGBASE_API_KEY).toBe('test-key');
  });
});
```

## Code Coverage

### Generate Coverage Report

```bash
# Run tests with coverage
pnpm vitest --coverage

# Open coverage report in browser
open coverage/index.html
```

### Coverage Configuration

Add to `vitest.config.js`:

```javascript
export default {
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'dist/',
        '**/*.test.ts',
        '**/*.config.ts'
      ],
      lines: 80,
      functions: 80,
      branches: 80,
      statements: 80
    }
  }
};
```

## Integration Testing

### Testing with Real APIs

```typescript
import { describe, it, expect } from 'vitest';

// Mark tests that use real APIs
describe('Integration: OpenAI', () => {
  it.skipIf(!process.env.OPENAI_API_KEY)(
    'should call real OpenAI API',
    async () => {
      const pipe = new Pipe({
        apiKey: process.env.LANGBASE_API_KEY!,
        model: 'openai:gpt-4o-mini',
        // ... config
      });

      const response = await pipe.run({
        messages: [{ role: 'user', content: 'Hi' }]
      });

      expect(response.completion).toBeTruthy();
    },
    { timeout: 30000 } // Longer timeout for real API
  );
});
```

## Performance Testing

```typescript
import { describe, it, expect } from 'vitest';

describe('Performance', () => {
  it('should respond within 5 seconds', async () => {
    const start = Date.now();

    const pipe = new Pipe(config);
    await pipe.run({
      messages: [{ role: 'user', content: 'Quick question' }]
    });

    const duration = Date.now() - start;
    expect(duration).toBeLessThan(5000);
  }, { timeout: 10000 });
});
```

## Snapshot Testing

```typescript
import { describe, it, expect } from 'vitest';

describe('Snapshot Tests', () => {
  it('should match pipe config snapshot', () => {
    const config = {
      name: 'test-pipe',
      model: 'openai:gpt-4o-mini',
      // ... config
    };

    expect(config).toMatchSnapshot();
  });
});
```

## Continuous Integration

Tests run automatically on:
- Push to main/develop branches
- Pull requests
- Pre-release builds

See `.github/workflows/ci.yml` for CI configuration.

### Local CI Simulation

Run the same checks as CI:

```bash
./scripts/test-setup.sh
```

This runs:
1. Build packages
2. ESLint
3. Prettier check
4. TypeScript type check
5. All test suites
6. Publint

## Test Best Practices

### 1. Test Isolation

Each test should be independent:

```typescript
// ✅ Good - isolated
it('should add item', () => {
  const list = [];
  list.push('item');
  expect(list).toHaveLength(1);
});

// ❌ Bad - depends on previous state
let sharedList = [];
it('should add item', () => {
  sharedList.push('item');
  expect(sharedList).toHaveLength(1);
});
```

### 2. Clear Test Names

```typescript
// ✅ Good - descriptive
it('should return error when API key is missing', () => {});

// ❌ Bad - vague
it('should work', () => {});
```

### 3. Arrange-Act-Assert Pattern

```typescript
it('should calculate total tokens', () => {
  // Arrange
  const usage = { prompt_tokens: 10, completion_tokens: 20 };

  // Act
  const total = usage.prompt_tokens + usage.completion_tokens;

  // Assert
  expect(total).toBe(30);
});
```

### 4. Test Edge Cases

```typescript
describe('Validation', () => {
  it('should handle empty input', () => {});
  it('should handle null input', () => {});
  it('should handle very long input', () => {});
  it('should handle special characters', () => {});
});
```

### 5. Use Meaningful Assertions

```typescript
// ✅ Good - specific
expect(response.completion).toContain('hello');
expect(response.usage.total_tokens).toBeGreaterThan(0);

// ❌ Bad - vague
expect(response).toBeTruthy();
```

## Debugging Tests

### Run Single Test

```bash
pnpm vitest run -t "should create pipe"
```

### Debug in VS Code

Add to `.vscode/launch.json`:

```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Vitest",
  "runtimeExecutable": "pnpm",
  "runtimeArgs": ["vitest", "run"],
  "console": "integratedTerminal"
}
```

### Verbose Output

```bash
pnpm vitest run --reporter=verbose
```

## Common Testing Patterns

### Testing Async Functions

```typescript
it('should handle async operations', async () => {
  const result = await asyncFunction();
  expect(result).toBeDefined();
});
```

### Testing Error Handling

```typescript
it('should throw error for invalid input', async () => {
  await expect(pipe.run({ messages: [] }))
    .rejects
    .toThrow('Messages required');
});
```

### Testing Streaming

```typescript
it('should stream responses', async () => {
  const { stream } = await pipe.run({ stream: true });

  const reader = stream.getReader();
  const { value, done } = await reader.read();

  expect(value).toBeDefined();
  expect(done).toBe(false);
});
```

## Resources

- [Vitest Documentation](https://vitest.dev/)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [BaseAI Examples](../examples/)

---

For issues or questions about testing, visit:
https://github.com/LangbaseInc/baseai/issues
