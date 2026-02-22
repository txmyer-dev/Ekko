# Plan: Fabric Patterns as Native Claude Code Slash Commands

## Context

Tony has 250 Fabric patterns locally but doesn't want the Fabric CLI (Go binary) as a dependency. The patterns themselves are plain markdown files — the value is in the prompts, not the tooling. This plan removes the CLI dependency entirely and makes every pattern accessible as an individual `/pattern-name` slash command in Claude Code.

**Current state:** Fabric skill exists, already executes patterns natively (reads system.md from disk). CLI is only used for YouTube transcripts (`fabric -y`), URL fetching (`fabric -u`), and upstream sync (`fabric -U`). All three have native replacements available.

---

## Phase 1: Sync Pattern Gap

**13 patterns exist in `~/.config/fabric/patterns/` but not in `~/.claude/skills/Fabric/Patterns/`.**

```bash
rsync -av ~/.config/fabric/patterns/ ~/.claude/skills/Fabric/Patterns/
```

Verify: `ls ~/.claude/skills/Fabric/Patterns/ | wc -l` → 250+

---

## Phase 2: Create Command Generator

**New file:** `~/.claude/skills/Fabric/Tools/GenerateCommands.py`

This Python script scans all patterns and creates a `.md` file in `~/.claude/commands/` for each one. Claude Code's native command system turns each `.md` file into a `/command-name` slash command.

**Template per command file (~6 lines each):**
```markdown
Apply the Fabric `{pattern_name}` pattern to the provided content.

Read the pattern instructions at: ~/.claude/skills/Fabric/Patterns/{pattern_name}/system.md

Apply those instructions to the following input:

$ARGUMENTS
```

**Naming:** Underscores → hyphens (`extract_wisdom` → `/extract-wisdom`). Existing hyphens preserved.

**user.md handling:** 47 patterns have user.md, but only 1 (`suggest_pattern`) has substantial content (>10 lines). Generator checks line count and uses extended template (reads both files) when threshold is met.

**Also creates:** `~/.claude/commands/patterns.md` — master command for `/patterns` (list all) and `/patterns [search term]` (filter).

---

## Phase 3: Refactor ExecutePattern.md

**File:** `~/.claude/skills/Fabric/Workflows/ExecutePattern.md`

**Change:** Remove Step 4 ("Special Cases Requiring Fabric CLI") entirely. Replace with:

- **YouTube URLs:** Use yt-dlp (already at `~/gopath/bin/yt-dlp`):
  ```bash
  ~/gopath/bin/yt-dlp --write-auto-sub --skip-download --sub-format vtt \
    -o /tmp/yt-transcript "$URL" 2>/dev/null
  # Strip VTT formatting to plain text
  ```
- **URL fetching:** Use WebFetch tool (native to Claude Code) — no change needed, already available
- **Error handling "No content" section:** Remove `fabric -y` reference, replace with yt-dlp and WebFetch mentions

---

## Phase 4: Replace UpdatePatterns.md with SyncPatterns.md

**Delete:** `~/.claude/skills/Fabric/Workflows/UpdatePatterns.md`
**Create:** `~/.claude/skills/Fabric/Workflows/SyncPatterns.md`

**New sync approach** (no Fabric CLI):
1. Git sparse-checkout of `patterns/` dir from `danielmiessler/fabric` repo (shallow, minimal bandwidth)
2. Rsync to `~/.config/fabric/patterns/` and `~/.claude/skills/Fabric/Patterns/`
3. Run `GenerateCommands.py` to regenerate all command files
4. Report delta (before/after count)

---

## Phase 5: Update SKILL.md

**File:** `~/.claude/skills/Fabric/SKILL.md`

Changes:
1. **Description:** Bump count to 250, add note about slash commands
2. **Workflow Routing table:** `UpdatePatterns` → `SyncPatterns`
3. **Remove** any "When to Use Fabric CLI Directly" section
4. **Add** note: "Each pattern is also available as `/pattern-name` (hyphens replace underscores)"
5. **Add** changelog entry for 2026-02-17

---

## Phase 6: Create Tools/ Directory

`~/.claude/skills/Fabric/Tools/` doesn't exist (required by SKILLSYSTEM.md). Create it and place `GenerateCommands.py` there.

---

## Files Modified

| File | Action |
|------|--------|
| `~/.claude/skills/Fabric/Workflows/ExecutePattern.md` | Remove Step 4 CLI fallback, add yt-dlp for YouTube |
| `~/.claude/skills/Fabric/Workflows/UpdatePatterns.md` | Delete (replaced by SyncPatterns.md) |
| `~/.claude/skills/Fabric/SKILL.md` | Update routing table, description, remove CLI refs |

## Files Created

| File | Purpose |
|------|---------|
| `~/.claude/commands/` | Directory (250+ .md files) |
| `~/.claude/commands/patterns.md` | Master list/search command |
| `~/.claude/commands/{pattern-name}.md` × 250 | Individual pattern commands |
| `~/.claude/skills/Fabric/Tools/GenerateCommands.py` | Generator script |
| `~/.claude/skills/Fabric/Workflows/SyncPatterns.md` | Git-based pattern sync (replaces UpdatePatterns) |

---

## Verification

1. **Command count:** `ls ~/.claude/commands/*.md | wc -l` → 251 (250 patterns + 1 master)
2. **Spot-check commands:** Verify `/extract-wisdom`, `/summarize`, `/create-threat-model` files exist and have correct paths + `$ARGUMENTS`
3. **Path validation:** Confirm all pattern paths referenced in command files actually exist on disk
4. **No CLI references:** `grep -r 'fabric -' ~/.claude/skills/Fabric/` returns empty
5. **Live test:** Type `/extract-wisdom` with sample text in Claude Code, verify structured output
6. **Live test:** Type `/patterns` to see full list, `/patterns analyze` to search
7. **yt-dlp test:** Verify YouTube transcript extraction works without Fabric CLI

---

## What This Does NOT Do

- Does not delete the `fabric` binary (stays at `~/gopath/bin/fabric` — just not referenced)
- Does not modify `~/.config/fabric/patterns/` source files
- Does not add contextFiles entries in settings.json (commands load on-demand)
- Does not touch Research/Workflows/Fabric.md (that's a separate cleanup if desired)
