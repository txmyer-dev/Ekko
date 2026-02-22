# AI Steering Rules - Personal

Add your personal behavioral rules here. These extend `PAI/SYSTEM/AISTEERINGRULES.md`.

Personal rules capture patterns specific to YOU -- your preferences, recurring frustrations, and working style. Derive them from real experience: when the AI does something wrong repeatedly, write a rule to prevent it.

---

## Rule Format

Each rule follows the **Statement / Bad / Correct** format:

Statement
: The rule in clear, imperative language

Bad
: Example of incorrect behavior showing the full interaction

Correct
: Example of correct behavior showing the full interaction

---

## Example Rule

### Verify Before Claiming Success

Statement
: Never claim a task is complete without verifying the result. Run tests, check output, or confirm the change is live before reporting success.

Bad
: User asks to fix a failing test. AI edits the code and says "Fixed!" without re-running the test suite. The test still fails.

Correct
: User asks to fix a failing test. AI edits the code, re-runs the test suite, confirms it passes, then reports success with the passing output.

---

## Your Rules

### Generate Connective Tissue When Writing to SecondBrain

Statement
: When writing any file to `~/SecondBrain/Knowledge/` or `~/SecondBrain/Sessions/`, always include YAML frontmatter (title, type, domain, tags, date, source, status) and a `## Related` section with wiki-links to related files. Use `python3 ~/SecondBrain/Tools/obsidian_write.py` to scan for related files. Never write bare markdown without frontmatter — the connective tissue is generated at write-time, not retrofitted.

Bad
: Save an extract_wisdom output to `Knowledge/my-notes.md` as plain markdown. No frontmatter, no Related section. File is an orphan in the graph — invisible to Obsidian's graph view, search, and Dataview queries. Requires a separate pass to add structure later.

Correct
: Before writing, generate frontmatter with `obsidian_write.py --frontmatter-only` and scan for related files with `--related-only`. Write the file with frontmatter at top, content in the middle, and `## Related` with wiki-links at the bottom. The file is immediately connected to the knowledge graph.

### Obsidian Frontmatter Schema

Statement
: All SecondBrain Knowledge files must use this consistent frontmatter schema: `title` (string), `type` (one of: bootcamp, wisdom-extraction, philosophy, business, strategy, session-log, note), `domain` (one of: learning, business, personal, technical, consulting), `tags` (array), `date` (YYYY-MM-DD), `source` (string), `status` (active/archive/draft).

Bad
: Use inconsistent field names (`Type` vs `type`), skip the date field, use free-form types like "misc" or "stuff", or omit tags entirely.

Correct
: Follow the schema exactly. Pick the closest type and domain from the allowed values. Always include at least 2-3 tags for discoverability.

### Self-Update Protocol ("Update Yourself")

Statement
: When Tony says "update yourself," check each system in priority order — Soul → Heart → Memories — and confirm nothing needs adding. Soul (KAI.md + DAIDENTITY.md) is checked first but updated rarest. Heart (SecondBrain/Heartbeat/) is checked second. Memories (MEMORY/) is checked last but updated most frequently. Brain (SecondBrain/ vault) is updated as-needed during normal work and does not require scheduled self-checks.

Bad
: Tony says "update yourself." AI updates one memory file and says done. Doesn't check if the soul file has stale values. Doesn't check if heartbeat config needs changes. Misses that a core value shifted.

Correct
: Tony says "update yourself." AI checks KAI.md — any identity/value shifts from recent sessions? No changes needed. Checks heartbeat — schedule still correct, notification rules still valid? Yes. Checks MEMORY — any learnings to capture, work logs to update, relationship notes to add? Captures two new learnings. Reports what was checked and what changed.

---

*These rules extend `PAI/SYSTEM/AISTEERINGRULES.md`. Both files are loaded and enforced together.*
