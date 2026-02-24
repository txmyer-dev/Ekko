# Agents Directory

12 built-in agent personas, each defined as a Markdown file with identity, expertise, and behavioral instructions.

## Agent Roster

| Agent | Role | When Used |
|-------|------|-----------|
| **Algorithm** | ISC specialist, evolving ideal state criteria | `subagent_type=Algorithm` — ISC pressure testing, criteria discovery |
| **Architect** | System design, constitutional principles, feature specs | `subagent_type=Architect` — design decisions, domain mapping |
| **Engineer** | TDD implementation, Fortune 10 standards | `subagent_type=Engineer` — building and implementing code |
| **Designer** | UX/UI, Figma, shadcn/ui, accessibility | `subagent_type=Designer` — user interface work |
| **Artist** | Visual content, prompt engineering, image generation | `subagent_type=Artist` — called by Media skill workflows |
| **Intern** | 176-IQ generalist, high-agency problem solver | `subagent_type=Intern` — complex multi-faceted problems |
| **Pentester** | Offensive security, vulnerability assessment | `subagent_type=Pentester` — called by WebAssessment skill |
| **QATester** | Browser-automation validation, Gate 4 of Five Gates | `subagent_type=QATester` — mandatory before claiming web work complete |
| **ClaudeResearcher** | WebSearch-based academic research | `subagent_type=ClaudeResearcher` — called by Research skill |
| **GeminiResearcher** | Google Gemini multi-perspective research | `subagent_type=GeminiResearcher` — called by Research skill |
| **CodexResearcher** | Multi-model technical archaeology (O3, GPT-5, GPT-4) | `subagent_type=CodexResearcher` — called by Research skill |
| **GrokResearcher** | Contrarian fact-based research via xAI Grok | `subagent_type=GrokResearcher` — called by Research skill |

## Key Conventions

- Built-in agents use their name as `subagent_type` directly (e.g., `Task(subagent_type="Engineer")`)
- Custom agents (created via ComposeAgent) MUST use `subagent_type="general-purpose"` — never a built-in name
- Agent files are Markdown with persona frontmatter (name, voice_settings, color, expertise)
- Research agents are invoked through the Research skill, not directly
