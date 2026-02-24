# Hooks Directory

25 event hooks that fire on Claude Code lifecycle events. Each hook is a TypeScript file executed by Bun.

## Hook Categories

### Session Lifecycle
- **StartupGreeting.hook.ts** — Loads PAI context, displays ASCII banner, sets session identity at session start
- **SessionAutoName.hook.ts** — Auto-names sessions based on first substantive prompt
- **SessionSummary.hook.ts** — Generates session summary on exit

### Algorithm & Format Enforcement
- **FormatReminder.hook.ts** — AI-classifies prompt depth (FULL/ITERATION/MINIMAL) and injects algorithm directive
- **AlgorithmTracker.hook.ts** — Tracks algorithm phase progression for dashboard
- **IntegrityCheck.hook.ts** — Validates algorithm output structure

### Context & Skills
- **LoadContext.hook.ts** — Dynamically loads context files based on prompt content
- **SkillGuard.hook.ts** — Enforces skill invocation before responses when skills match

### Quality & Learning
- **WorkCompletionLearning.hook.ts** — Captures learnings when work completes
- **AgentOutputCapture.hook.ts** — Captures agent outputs for review
- **AgentExecutionGuard.hook.ts** — Guards against unnecessary agent spawning

### User Interaction
- **ExplicitRatingCapture.hook.ts** — Captures explicit 1-10 ratings
- **ImplicitSentimentCapture.hook.ts** — Infers satisfaction from response patterns
- **RatingCapture.hook.ts** — Unified rating capture
- **QuestionAnswered.hook.ts** — Tracks when questions get answered
- **SetQuestionTab.hook.ts** — Sets terminal tab title for question tracking

### Identity & Memory
- **SoulEvolution.hook.ts** — Evolves KAI.md (soul file) based on interactions
- **RelationshipMemory.hook.ts** — Tracks relationship dynamics and notes
- **AutoWorkCreation.hook.ts** — Auto-creates WORK entries for new tasks

### Security & Validation
- **SecurityValidator.hook.ts** — Validates commands for security risks
- **VoiceGate.hook.ts** — Gates voice curls (heartbeat-only mode)
- **StopOrchestrator.hook.ts** — Handles stop/interrupt signals

### UI & Metadata
- **UpdateTabTitle.hook.ts** — Updates terminal tab title based on current work
- **UpdateCounts.hook.ts** — Tracks usage statistics
- **CheckVersion.hook.ts** — Checks for PAI version updates

## Hook Events

Hooks fire on: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Notification`

## Conventions

- All hooks are TypeScript, executed with Bun
- Filename pattern: `{PascalCaseName}.hook.ts`
- Hooks read `settings.json` for configuration
- Hook output goes to stderr (visible in debug mode) or injected as system reminders
