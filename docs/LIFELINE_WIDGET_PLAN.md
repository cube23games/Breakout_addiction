# Breakout Addiction Lifeline Widget Plan

## Purpose

The Lifeline Widget gives the user a discreet, fast-access support point from the Android home screen before an urge becomes harder to interrupt.

## Core principle

Fast help, private wording.

The widget should never expose sensitive addiction language by default.

## Default mode: Discreet Mode

Default widget copy should be neutral:

- Breakout
- You still have a choice.
- Take 60 seconds.
- Open Rescue.

Avoid default text such as:

- porn addiction
- relapse
- urge streak
- accountability alert
- AI chat
- high-risk browsing

## Optional Recovery Mode

Recovery Mode may show more recovery-specific details only if the user chooses it.

Possible fields:

- current focus
- next risk window
- daily encouragement
- Rescue button
- Quick Log button
- Reasons button

## Widget sizes

### Small

- App name
- one supportive line
- Rescue action

### Medium

- supportive line
- Rescue action
- Quick Log action
- optional next risk window

### Large

- daily focus
- Rescue
- Quick Log
- Reasons
- optional support reminder

## Tap actions

The MVP widget should deep link to:

- Rescue
- Recovery Event Log / Quick Log
- Reasons to Stop
- Home

## Privacy rules

- Discreet Mode is default.
- No sensitive log counts by default.
- No relapse counts by default.
- No AI chat content.
- No accountability partner details.
- No full trusted contact information.
- No backend/API/provider wording.

## Android implementation reality

A real Android home screen widget is not the same as the current in-app Widget Preview.

A real widget will require native Android app widget provider files, manifest declarations, layouts, and a Flutter/native data bridge.

Because Breakout currently creates Android platform folders in CI when missing, native widget work needs a platform strategy first:

- commit Android platform files, or
- re-apply native widget files in CI every build.

## Recommended implementation path

1. Keep Widget Preview as an in-app design/demo surface.
2. Create the Lifeline Widget plan and privacy rules.
3. Decide Android platform file strategy.
4. Add native Android widget provider files.
5. Add deep links to Rescue / Log / Reasons.
6. Add widget state sharing.
7. Verify AAB still builds.

## Suggested user-facing copy

Breakout Lifeline Widget

A discreet home-screen shortcut for moments when you need help fast.
