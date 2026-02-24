# Skills Directory

45+ skill domains, each in its own subdirectory. Skills provide domain-specific sub-algorithms invoked via the `Skill` tool.

## Skill Structure

Each skill directory contains:
- `SKILL.md` — Main skill definition (triggers, workflows, instructions)
- `Workflows/` — Step-by-step workflow files referenced by SKILL.md
- `Patterns/` — Fabric pattern files (for Fabric-based skills)
- `Components/` — Reusable pieces assembled by build tools
- `Tools/` — TypeScript utilities used by the skill

## Core PAI Skills

| Skill | Purpose |
|-------|---------|
| **PAI** | Core system — the Algorithm, ISC, PRD, steering rules, identity, memory system |
| **ExtractWisdom** | Dynamic content extraction from videos, podcasts, articles |
| **Fabric** | 259 Fabric patterns — analysis, extraction, summarization, creation |
| **Browser** | Debug-first browser automation with Playwright |
| **CodeReview** | Anti-sycophantic code review |
| **Council** | Multi-agent structured debate |
| **RedTeam** | 32-agent adversarial analysis |
| **Agents** | Dynamic agent composition via ComposeAgent |

## Frequently Modified

- `PAI/SKILL.md` — Algorithm definition (generated from Components/ by CreateDynamicCore.ts)
- `PAI/USER/` — User customizations (steering rules, writing style, skill overrides)
- `ExtractWisdom/` — Extraction patterns and preferences
- `Fabric/Patterns/` — 259 pattern directories, each with system.md

## Key Conventions

- Skills are invoked by name via `Skill` tool, not by reading files directly
- `skill-index.json` at repo root maps skill names to triggers for capability audit
- User customizations go in `PAI/USER/SKILLCUSTOMIZATIONS/{SkillName}/`
- Skills reference `settings.json` for identity config (names, voice, timezone)
