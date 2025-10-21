# Security Guide for BaseAI

This guide covers security best practices when developing and deploying AI applications with BaseAI.

## Table of Contents

- [API Key Management](#api-key-management)
- [Environment Variables](#environment-variables)
- [Production Security](#production-security)
- [Content Moderation](#content-moderation)
- [Rate Limiting](#rate-limiting)
- [Input Validation](#input-validation)
- [Data Privacy](#data-privacy)
- [Secure Communication](#secure-communication)
- [Dependency Security](#dependency-security)
- [Reporting Security Issues](#reporting-security-issues)

## API Key Management

### Never Commit API Keys

**DO NOT** commit API keys to version control:

```bash
# Always add .env files to .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".env.*.local" >> .gitignore
```

### Use Environment Variables

Store API keys in environment variables:

```bash
# .env (never commit this file)
LANGBASE_API_KEY=your_key_here
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
```

Load them securely in your application:

```typescript
import 'dotenv/config';

// ✅ Good - Server-side only
const apiKey = process.env.LANGBASE_API_KEY;

// ❌ Bad - Never expose in client-side code
// <script>const key = "sk-..."</script>
```

### Rotate API Keys Regularly

1. Generate new API keys periodically
2. Update environment variables in your deployment platform
3. Revoke old keys after successful rotation
4. Monitor for any unauthorized usage

### Use Langbase LLM Keysets (Recommended)

For production, use Langbase LLM Keysets instead of individual provider keys:

**Benefits:**
- Centralized key management
- Easy rotation without code changes
- Access control and auditing
- Usage monitoring

**Setup:**
1. Go to [Langbase Keysets](https://langbase.com/docs/features/keysets)
2. Add your LLM provider keys
3. Only expose `LANGBASE_API_KEY` in your application

## Environment Variables

### Server-Side Only

API keys must NEVER be exposed to the client:

```typescript
// ✅ Good - Server-side API route
// app/api/chat/route.ts
import { Pipe } from '@baseai/core';
import pipe from '@/baseai/pipes/summary';

export async function POST(req: Request) {
  // API key is only used server-side
  const p = new Pipe(pipe());
  return p.run({...});
}
```

```typescript
// ❌ Bad - Client-side component
// components/Chat.tsx
'use client';
import { Pipe } from '@baseai/core';

export function Chat() {
  // NEVER do this - exposes API key to browser
  const pipe = new Pipe({
    apiKey: process.env.LANGBASE_API_KEY // ❌ WRONG
  });
}
```

### Platform-Specific Configuration

#### Vercel
```bash
# Add via Vercel Dashboard or CLI
vercel env add LANGBASE_API_KEY production
```

#### Netlify
```bash
# netlify.toml
[build.environment]
  NODE_VERSION = "18"

# Add secrets via Netlify Dashboard
```

#### AWS Lambda
```bash
# Use AWS Secrets Manager or Parameter Store
aws secretsmanager create-secret \
  --name /baseai/api-keys \
  --secret-string '{"LANGBASE_API_KEY":"your_key"}'
```

#### Docker
```bash
# Use Docker secrets or environment files
docker run --env-file .env.production myapp
```

## Production Security

### Disable Sensitive Logging

Never log sensitive data in production:

```typescript
// baseai.config.ts
export const config: BaseAIConfig = {
  log: {
    isEnabled: true,
    logSensitiveData: false, // ✅ Always false in production
    pipe: true,
    'pipe.completion': true,
    'pipe.request': false, // ❌ Don't log full requests
    'pipe.response': false, // ❌ Don't log full responses
  },
};
```

### Use HTTPS Only

Always use HTTPS in production:

```typescript
// Redirect HTTP to HTTPS
if (process.env.NODE_ENV === 'production' && !req.secure) {
  return res.redirect(301, `https://${req.headers.host}${req.url}`);
}
```

### Set Security Headers

```typescript
// Next.js example (next.config.js)
module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on'
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN'
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block'
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin'
          }
        ]
      }
    ];
  }
};
```

## Content Moderation

Enable content moderation to filter harmful content:

```typescript
const pipe = (): PipeI => ({
  // ...
  moderate: true, // ✅ Enable moderation
  // ...
});
```

Implement custom moderation:

```typescript
import { Pipe } from '@baseai/core';

async function moderateContent(content: string): Promise<boolean> {
  // Implement your moderation logic
  const blockedWords = ['spam', 'abuse', ...];
  return !blockedWords.some(word => content.toLowerCase().includes(word));
}

export async function POST(req: Request) {
  const { message } = await req.json();

  // Validate input
  if (!await moderateContent(message)) {
    return Response.json(
      { error: 'Content violates our policies' },
      { status: 400 }
    );
  }

  // Continue with pipe
  const pipe = new Pipe(myPipe());
  return pipe.run({ messages: [{ role: 'user', content: message }] });
}
```

## Rate Limiting

Implement rate limiting to prevent abuse:

```typescript
// Using Vercel Rate Limiting
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '1 m'), // 10 requests per minute
});

export async function POST(req: Request) {
  const ip = req.headers.get('x-forwarded-for') ?? 'unknown';
  const { success } = await ratelimit.limit(ip);

  if (!success) {
    return Response.json(
      { error: 'Too many requests' },
      { status: 429 }
    );
  }

  // Continue with request
}
```

Simple in-memory rate limiting:

```typescript
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

function rateLimit(identifier: string, maxRequests: number, windowMs: number): boolean {
  const now = Date.now();
  const userLimit = rateLimitMap.get(identifier);

  if (!userLimit || now > userLimit.resetTime) {
    rateLimitMap.set(identifier, { count: 1, resetTime: now + windowMs });
    return true;
  }

  if (userLimit.count >= maxRequests) {
    return false;
  }

  userLimit.count++;
  return true;
}
```

## Input Validation

Always validate and sanitize user input:

```typescript
import { z } from 'zod';

const MessageSchema = z.object({
  message: z.string()
    .min(1, 'Message is required')
    .max(4000, 'Message too long')
    .trim(),
  userId: z.string().uuid().optional(),
});

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { message, userId } = MessageSchema.parse(body);

    // Safe to use validated input
    const pipe = new Pipe(myPipe());
    return pipe.run({
      messages: [{ role: 'user', content: message }]
    });
  } catch (error) {
    return Response.json(
      { error: 'Invalid input' },
      { status: 400 }
    );
  }
}
```

### Prevent Prompt Injection

Sanitize user input to prevent prompt injection attacks:

```typescript
function sanitizePrompt(input: string): string {
  // Remove potential injection attempts
  return input
    .replace(/\[INST\]/gi, '')
    .replace(/\[\/INST\]/gi, '')
    .replace(/<<SYS>>/gi, '')
    .replace(/<\/SYS>>/gi, '')
    .trim();
}

const pipe = new Pipe({
  // ...
  messages: [
    { role: 'system', content: 'You are a helpful assistant.' },
    { role: 'user', content: sanitizePrompt(userMessage) }
  ]
});
```

## Data Privacy

### GDPR Compliance

Respect user privacy and data regulations:

```typescript
const pipe = (): PipeI => ({
  // ...
  store: false, // Don't store messages if handling PII
  // ...
});
```

### Data Retention

Implement data retention policies:

```typescript
// Delete old chat histories
async function cleanupOldData() {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  await db.chatHistory.deleteMany({
    where: {
      createdAt: {
        lt: thirtyDaysAgo
      }
    }
  });
}
```

### Anonymize Data

Remove or hash PII before logging:

```typescript
function anonymize(data: any) {
  return {
    ...data,
    email: data.email ? hashEmail(data.email) : undefined,
    ip: data.ip ? hashIP(data.ip) : undefined,
    userId: data.userId ? hash(data.userId) : undefined,
  };
}

// Log anonymized data
console.log('Request:', anonymize(requestData));
```

## Secure Communication

### Implement Authentication

```typescript
import { getServerSession } from 'next-auth';

export async function POST(req: Request) {
  const session = await getServerSession();

  if (!session) {
    return Response.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }

  // User is authenticated
  const pipe = new Pipe(myPipe());
  return pipe.run({...});
}
```

### CORS Configuration

```typescript
// Restrict CORS to your domain
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['https://yourdomain.com'],
  credentials: true,
};
```

### Token Limits

Set reasonable token limits to prevent abuse and control costs:

```typescript
const pipe = (): PipeI => ({
  // ...
  max_tokens: 1000, // Reasonable limit
  // ...
});
```

## Dependency Security

### Regular Updates

Keep dependencies updated:

```bash
# Check for vulnerabilities
pnpm audit

# Update dependencies
pnpm update

# Check for outdated packages
pnpm outdated
```

### Automated Security Scanning

Use Dependabot (already configured in `.github/dependabot.yml`):

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

### Review Dependencies

Before adding new dependencies:

1. Check npm download stats
2. Review GitHub repository activity
3. Check for known vulnerabilities
4. Review license compatibility

## Security Checklist

### Development

- [ ] API keys in environment variables, not code
- [ ] `.env` files in `.gitignore`
- [ ] Input validation on all user inputs
- [ ] Content moderation enabled
- [ ] Sensitive data logging disabled

### Pre-Production

- [ ] Security headers configured
- [ ] HTTPS enforced
- [ ] Rate limiting implemented
- [ ] Authentication/authorization in place
- [ ] Dependencies updated and scanned

### Production

- [ ] API keys rotated
- [ ] Monitoring and alerting configured
- [ ] Error logging without sensitive data
- [ ] Data retention policies implemented
- [ ] Incident response plan documented

## Reporting Security Issues

If you discover a security vulnerability in BaseAI:

**DO NOT** open a public GitHub issue.

**Email:** security@langbase.com

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will:
- Acknowledge receipt within 24 hours
- Provide regular updates
- Credit you in the fix (if desired)

## Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP LLM Security](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## Additional Reading

- [Langbase Security](https://langbase.com/security)
- [BaseAI Documentation](https://baseai.dev/docs)
- [API Security Best Practices](https://baseai.dev/docs/security)

---

Last updated: 2025-10-21
