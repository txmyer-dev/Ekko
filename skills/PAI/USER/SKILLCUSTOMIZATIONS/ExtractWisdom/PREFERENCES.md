# ExtractWisdom — User Preferences

## Auto-Save to SecondBrain (MANDATORY)

After every extraction, **automatically save the output** to `~/SecondBrain/Knowledge/` without asking. This is not optional.

### Naming Convention

Follow SecondBrain file naming rules:

| Content Type | Pattern | Example |
|---|---|---|
| Podcast/show episode | `{Guest}-{ShowAbbrev}{Episode}.md` | `Alex-Hormozi-MW610.md` |
| YouTube video (own channel) | `{Creator}-{Short-Topic}.md` | `Jack-Roberts-NotebookLM-SuperPower.md` |
| Book/author | `{Author}-{Short-Title}.md` | `Derek-Sivers-Philosophy-Notes.md` |
| Article/general | `{Source}-{Short-Topic}.md` | `Cole-Medin-OpenClaw.md` |

**Show abbreviations:** MW (Modern Wisdom), DOAC (Diary of a CEO), JRE (Joe Rogan Experience), HL (Huberman Lab), IF (Impact Theory), LI (Lex Fridman)

### Frontmatter (Required)

```yaml
---
title: "{Speaker/Author} - {Content Title}"
type: wisdom-extraction
domain: <learning|business|personal|technical>
tags: [<2-6 kebab-case tags, primary topic first>]
date: <YYYY-MM-DD>
source: "<URL or descriptive name>"
status: active
---
```

### Related Section (Required)

End every file with a `## Related` section containing `[[wiki-links]]` to existing SecondBrain files. Scan `~/SecondBrain/Knowledge/` filenames to find related content by topic, speaker, or domain.

### Deduplication

Before writing, check if a file for the same source already exists in `~/SecondBrain/Knowledge/`. If it does, warn the user and ask whether to overwrite or skip.

### Confirmation

After saving, state the filename and path. No need to ask permission — just save and report.
