---
title: "Extract Wisdom: Agentic Workflows 6-Hour Course"
source: https://www.youtube.com/watch?v=MxyRjL7NG18
author: Nick (LeftClick.ai)
duration: 5h 41m
extracted: 2026-02-14
type: extract_wisdom
tags: [agentic-workflows, AI, business, automation, consulting]
pending_move: ~/SecondBrain/Knowledge/ (F: drive not mounted)
---

# Extract Wisdom: Agentic Workflows 6-Hour Course (2026)

**Speaker:** Nick — built two AI-based service agencies to $160K/month combined revenue. Consulted for billion-dollar businesses with AI. Runs LeftClick.ai (B2B AI growth agency).

---

## ONE-SENTENCE SUMMARY

A practitioner's complete framework for building business-grade agentic workflows — from IDE setup through the DO framework, self-annealing, cloud deployment, and multi-agent parallelization — focused on generating real revenue, not demos.

---

## IDEAS

1. Agentic workflows have the potential to bring about one of the largest wealth transfers in human history.
2. Anti-gravity (Google's VS Code fork) abstracts away file management so you just communicate with the model.
3. The DO framework (Directive, Orchestration, Execution) reduces AI error rates to 2-3% by separating natural language instructions from deterministic code.
4. Stochasticity reduction works like bowling guardrails — constraining the AI's possible outputs to keep it on track.
5. Models perform worse as context window size increases because retrieval accuracy declines with more tokens.
6. Information density per token matters more than prompt length — compressing prompts improves output quality.
7. MCP servers are like USB-C for AI — a universal adapter standard for tool interoperability.
8. Self-annealing transforms agents from brittle automations into resilient systems that strengthen with every error.
9. Steering at the beginning of a workflow has the highest ROI because variability compounds over time.
10. Exploring multiple workflow approaches in parallel using separate agent instances searches the solution space 10x faster than sequential exploration.
11. Voice transcription (200 WPM) + speed reading output (300-1000 WPM) creates 4x bandwidth increase over typing.
12. Running 5 parallel agent instances costs mere dollars but saves days of iteration.
13. Event-driven workflows eliminate manual triggering and allow work to happen outside business hours.
14. Cloud workflows remove the LLM from the loop to eliminate stochasticity and liability.
15. Sub-agents isolate context pollution by doing messy work in separate spaces and returning only relevant findings.
16. Reviewer sub-agents provide fresh eyes without bias from the building process.
17. Human involvement should be determined by magnitude of outcome and sensitivity to quality, not by default.
18. Cold email has an uncanny valley effect where small quality improvements create disproportionate impact.
19. Agents often need motivation in addition to decisions — simply asking them to research can break them out of loops.
20. The interface to everything is now just a text box.

## INSIGHTS

1. The power of agentic workflows comes from making AI deterministic through structure, not from making it more intelligent.
2. Error probabilities multiply across steps (99.9% per step = 36% after 1000 steps), making fewer steps exponentially more reliable.
3. Agents behave like employees: self-annealed ones are star performers who escalate rarely; those without are blockers.
4. The cost of exploring multiple approaches is effectively free compared to the cost of going down the wrong path.
5. Prompts are now the moat, not code; the quality of your system prompt determines the quality of your autonomous agent.
6. Models grow rather than being built, making their behavior more like natural phenomena to be tested than systems to be engineered.
7. Context window pollution follows a predictable curve where performance increases with initial context then degrades with accumulation.
8. Stochasticity is an asset during development but a liability in production, requiring different architectures for each phase.
9. Two to four parallel agents is the practical limit before human attention becomes the bottleneck.
10. The bottleneck in agentic workflows is rarely the automation itself but understanding what to automate in the first place.
11. The distinction between building workflows (one-time cost) and using workflows (recurring ROI) determines long-term leverage.
12. Watching workflows execute builds irreplaceable intuition about AI reasoning — the most important skill for the AI economy.

## QUOTES

1. "Agentic workflows have the potential to bring about what I think is one of the largest wealth transfers in human history."
2. "When you do not constrain the outputs of LLMs, they're really unpredictable. They'll try anything and when they fail, they fail spectacularly."
3. "It's like asking them to invent a new dish every time versus just giving somebody a recipe."
4. "Self-annealing allows the models to become more resilient. Every time something breaks, it's a feature, not a bug."
5. "You don't need to know how to code at all. You just need to know how to explain what it is that you want."
6. "The interface to everything is now just a text box."
7. "You would not believe how much money on the internet is available for the taking if you just know how to connect APIs."
8. "I plan for graceful recovery, not perfect prevention."
9. "The more steps you put in an AI's hands, the more chances for errors. Error rates multiply."
10. "Feeling busy is not the same thing as actually being busy. Feeling productive is not the same thing as being productive."
11. "If I don't do the foundational fundamental things that I promise people I will do, then why the hell am I entitled to their money?"
12. "Models these days are more grown than they are built, so it's very much like a natural phenomenon that we are testing."
13. "Architects design buildings all the time, but it's very rare that they actually live in the buildings they design. Your agent is the architect and your cloud workflow is the building."
14. "At the end of the day, this thing can basically be your terminal for life."
15. "The definition of insane is going to change pretty quickly as these models get more and more intelligent."

## HABITS

1. Always use descriptive file names for directives so agents can understand workflow purpose from the filename.
2. Store all API keys in a single .env file — never hardcode credentials.
3. Ask the model for 3-5 approaches before building, then compare outputs to select the best.
4. Watch workflows execute end-to-end for the first 10-15 runs to build intuition about model reasoning.
5. Use voice transcription for all prompting — 200 WPM input vs 50-70 WPM typing (3-4x faster).
6. Copy API docs directly into context rather than having the model search for them.
7. Only optimize workflows when you can achieve 10x improvement (time, cost, or accuracy).
8. Test workflows immediately after creation to trigger self-annealing before production use.
9. Limit parallel agent instances to 3-4 to prevent attention fragmentation.
10. Use dedicated Slack/Discord channel for cloud workflow logs — maintain visibility without constant monitoring.

## FACTS

1. Nick built two AI agencies to $160K/month combined revenue.
2. DO framework achieves 2-3% error rates on business functions.
3. A 5-server MCP setup (10 tools each) consumes 15,000 tokens before any work begins (300 tokens per tool definition).
4. GPT-3.5 accuracy drops from 75% (5 docs) to under 60% (20 docs) in context.
5. At 99.9% accuracy per step, reliability drops to 36% after 1000 operations.
6. Average typing: 50-70 WPM. Speaking: 150-200 WPM. Reading: 300-1000 WPM.
7. Modal gives $5 free credits — speaker used 4 cents in 2-3 weeks of intensive use.
8. Anthropic testing showed Opus with sub-agents outperformed single-agent Opus by over 90% on research tasks.
9. Word-to-token conversion: approximately words x (1/0.7).
10. MCP tools consume ~8.2% of context window even for simple integrations.

## REFERENCES

### Frameworks & Methodologies
- **DO Framework** (Directive, Orchestration, Execution) — Nick's core framework
- **Claude Skills** — Anthropic's built-in directive system
- **MCP** (Model Context Protocol) — universal AI tool adapter standard
- **Self-Annealing** — agents auto-fixing errors and documenting solutions

### Tools & Platforms
- Anti-gravity (Google VS Code fork), VS Code, Cursor, Claude Code (IDEs)
- Modal.com, Trigger.dev (serverless infrastructure)
- n8n, Make.com, Zapier (workflow automation)
- ClickUp (CRM/project management)
- Apollo, Hunter.io, AnyMailFinder, Phantom Buster (lead gen/enrichment)
- PandaDoc (proposals), Fireflies (transcription)
- Instantly (cold email), Canva (design)
- Vain (LinkedIn scraping), Tube Lab API (YouTube data)

### AI Models Referenced
- Claude Opus 4.5 (Anthropic)
- Gemini (Google)
- GPT-5.2, GPT-O5-20B, GPT-O1-20B (OpenAI)

### Communities
- LeftClick.ai (Nick's B2B AI agency)
- Maker School (Nick's 90-day program)
- Make Money with Make (Nick's community)

## RECOMMENDATIONS

1. Use DO framework (directives + executions) for business automation — separation of concerns is what makes it reliable.
2. Keep directives in natural language with zero code so non-technical staff can read and improve workflows.
3. Build atomic execution scripts that do one thing well — reuse across multiple directives.
4. Add self-annealing to system prompts: diagnose errors, fix them, update scripts, try hard before escalating.
5. Start with MCP for rapid prototyping, build custom execution scripts for production (avoid token bloat).
6. Deploy to Modal as scheduled triggers or webhooks when workflows need to run unattended.
7. Build 3 workflow variations simultaneously using separate agents — pick the best, not the first.
8. Create reviewer sub-agents to check quality with fresh eyes after building.
9. Set safety guardrails: confirm before high-cost API calls, never modify credentials, log all self-modifications.
10. Only automate things that make a bottom-line difference to the business — don't automate for the sake of automating.

---

## PAI RELEVANCE

**Direct applications to our work:**
- DO framework maps closely to PAI's skills/hooks architecture (directives = skills, executions = hooks/tools)
- Self-annealing is something we should formalize in PAI — agents that fix and document their own failures
- Sub-agent parallelization validates our fan-out composition pattern
- The insight about prompts being the moat (not code) reinforces why the Algorithm and ISC system matters
- Voice-first input (200 WPM) is something to explore for Tony's workflow
- Cloud deployment via Modal ($5 free) could replace or supplement our VPS for scheduled workflows
- Error probability multiplication (99.9% per step = 36% at 1000 steps) is a key design principle for our pipelines
- Nick's $160K/month from AI agencies validates the consulting path Tony is building toward
