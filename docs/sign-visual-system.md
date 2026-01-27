# Sign Visual System

## Purpose

Provide sign language as a primary interaction layer for agentic systems.
Not translation.
State + intent visualization.

## Core Principle

Sign visuals reflect system state, not just output text.

Text = optional  
Sign = authoritative

## Directory Structure

```
/sign-visual
  /components
    SignerPanel.tsx        # persistent, dockable
    StateIndicator.tsx     # listening | processing | deciding | executing | error
    ConfidenceCue.tsx      # certainty / uncertainty / warning
  /states
    idle.json
    listening.json
    processing.json
    validating.json
    executing.json
    completed.json
    error.json
  /semantics
    intent.map.json        # user intent → sign semantic
    system.map.json        # system action → sign semantic
  /providers
    realtime.ts            # live agent state stream
    playback.ts            # async / replay
```

## Sign Rendering Rules

- No word-for-word translation
- Use semantic chunks
- Always expose:
  - what the system is doing
  - why it paused
  - what it needs next

## Integration Points

- MagicianCore → invokes SignerPanel by default
- Validator → switches to "deciding / warning" state
- Compliance → high-visibility caution semantics
- Errors → explicit, non-ambiguous signing (no silent fails)

## Accessibility Contract

- Sign panel never hidden behind modals
- User controls size, speed, replay
- Works async-first (no forced realtime)

## Definition of Done

- Deaf user understands system state without reading text
- No action happens without a visible sign state
- System silence is never ambiguous

## Non-Goals

- Not subtitles
- Not decorative avatars
- Not post-hoc translation

## Philosophy

If the system thinks, it signs.  
If it cannot sign, it should not act.
