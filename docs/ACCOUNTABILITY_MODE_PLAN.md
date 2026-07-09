# Breakout Addiction Accountability Mode Plan

## Purpose

Accountability Mode lets the recovery user invite a trusted person into a limited, read-only support role without giving them full access to the private app.

## Core principle

Support, not surveillance.

The recovery user chooses what is shared. The accountability partner only sees the approved read-only summary.

## Access roles

### Recovery User

- Full private app access
- Can create/edit/delete logs
- Can manage passcodes
- Can enable or disable Accountability Mode
- Can choose what the partner can see

### Accountability Partner

- Separate login/passcode
- Read-only access
- Can view only approved accountability summary
- Cannot edit/delete logs
- Cannot access AI chat history by default
- Cannot access backend/API/provider settings
- Cannot change privacy settings
- Cannot unlock the full app

## MVP local-device version

The first version should work locally on the same device:

- App opens to role choice when locked
- Recovery User uses main passcode
- Accountability Partner uses separate accountability passcode
- Partner opens a limited Accountability Summary screen

No backend account system is required for MVP.

## Future remote version

A later paid/premium version may allow a partner to view shared summaries from their own device. That requires:

- backend accounts
- invite flow
- authenticated partner access
- cloud sync
- revocation controls
- privacy policy updates
- account deletion/export controls

## Share scopes

Possible user-controlled share scopes:

- recovery progress / streak
- recent urges
- relapse events
- victory events
- mood trends
- risk windows
- recovery plan
- reasons to stop
- support-needed flag

Private notes and AI chat history should stay off by default.

## Safety rules

- Accountability Mode must be opt-in.
- It must be easy to disable.
- The app must clearly show when Accountability Mode is enabled.
- Partner access must be read-only.
- Partner access must never reveal API keys, provider settings, dev screens, or app-lock settings.
- Partner access should not show full private notes unless the recovery user explicitly enables that scope.
- Partner access should not show AI chat history in the MVP.

## Suggested user-facing copy

Let someone support you without giving them your whole private world.

Choose what your accountability partner can see. You stay in control.
