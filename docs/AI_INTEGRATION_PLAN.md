# Breakout Addiction AI Integration Plan

## Current MVP rule

Breakout Addiction must not ship a public hardcoded AI API key. Internal testing may use a clearly labeled test-only key path, but production users should not manage or see provider secrets.

## Production direction

Production flow:

Breakout app -> Breakout backend/proxy -> AI provider

The backend/proxy should handle:

- provider API keys and billing secrets
- per-user usage limits
- token budgets and fair-use controls
- abuse/rate protection
- safety policy prompts
- model fallback or graceful failure
- billing alerts and kill switches

## User promise

Use "fair-use AI support," not "unlimited AI." AI output consumes tokens. Unlimited public access would mean unlimited provider cost for Breakout.

## Recovery safety

AI support should stay short, practical, and non-shaming. It should avoid sexual content, avoid collecting identifying details, and route crisis moments to emergency or trusted human support.

## MVP implementation guardrails

- Remote AI remains optional.
- Live provider calls are disabled unless feature gates, plan gates, API key gates, and preflight gates all pass.
- System instructions must be attached to live prototype calls.
- Output tokens stay capped for cost and safety.
- User messages should be sanitized before remote processing.
