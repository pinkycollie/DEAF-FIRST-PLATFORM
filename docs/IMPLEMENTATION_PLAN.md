# Sign Visual System Implementation Plan

## Phase 1 — Make it Real (MVP, no excuses)

### Directory Structure

```
/sign-visual
  /engine
    stateMachine.ts       # single source of truth for agent state
    eventBus.ts           # emits state changes
  /renderers
    signer-avatar.ts      # stub → video → generative later
    fallback-visual.ts    # icons + motion for low-bandwidth
```

### Rules

- Every agent action MUST emit a state event
- No silent processing
- No hidden waits

### Example Usage

```typescript
stateMachine.emit({
  actor: 'MagicianCore',
  state: 'validating',
  confidence: 0.82,
  requiresUser: false,
});
```

Signer listens to events, not text.

---

## Phase 2 — Wire to Agent Core

### Directory Structure

```
/core/magician-core
  hooks/useSignState.ts
  hooks/useIntentMap.ts
```

### Flow

```
user intent
 → agent reasoning
 → stateMachine update
 → sign renderer
 → (optional) text confirmation
```

Text never leads.  
Sign always reflects truth.

---

## Phase 3 — Deaf Engagement Loop (Governance)

### Directory Structure

```
/governance
  sign-feedback.json
  semantic-overrides.json
```

### Requirements

- Deaf contributors approve semantic mappings
- No auto-updates without sign review
- Versioned sign semantics (breaking changes = major version bump)

---

## Phase 4 — ChatGPT App Store Surface

### File

```
/chatgpt-app
  manifest.json
```

### Capability Declaration

```json
{
  "capabilities": {
    "sign_visual_state": {
      "primary": true,
      "modes": ["realtime", "async", "replay"]
    }
  }
}
```

### Positioning

- Not "accessibility"
- Category: Agent Transparency / Visual Reasoning

---

## Definition of Success

Deaf user can tell:

- what the agent is doing
- when it's unsure
- when action is irreversible

No reading required.  
No guessing required.

---

## Hard Line (non-negotiable)

If an agent cannot expose its state in sign,  
it does not get permission to act.

That's the enforcement layer.

---

## Next Commits

After this lands:

- signer-avatar v0 (static video set)
- state taxonomy freeze
- App Store reviewer notes
