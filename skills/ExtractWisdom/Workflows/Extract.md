# Extract Workflow

Extract dynamic, content-adaptive wisdom from any content source.

## Input Sources

| Source | Method |
|--------|--------|
| YouTube URL | **yt-dlp** for transcript (NEVER use WebFetch — youtube.com blocks it) |
| Article URL | WebFetch to get content |
| File path | Read the file directly |
| Pasted text | Use directly |

## Execution Steps

### Step 1: Get the Content

**YouTube URLs (youtube.com, youtu.be, m.youtube.com):**
Do NOT attempt WebFetch — it will always fail. Go directly to yt-dlp:
```bash
yt-dlp --write-auto-sub --skip-download --sub-format vtt \
  -o /tmp/yt-transcript "YOUTUBE_URL" 2>/dev/null
sed '/^$/d; /^[0-9]/d; /^NOTE/d; /^WEBVTT/d; /-->/d' /tmp/yt-transcript*.vtt | \
  awk '!seen[$0]++' > /tmp/yt-transcript.txt
```
Then read `/tmp/yt-transcript.txt` for the transcript. Also grab metadata with:
```bash
yt-dlp --print title --print channel --print description --no-download "YOUTUBE_URL"
```

**Article URLs:** Use WebFetch to get content.
**File paths:** Read the file directly.
**Pasted text:** Use directly.

Save to a working file if large.

### Step 2: Deep Read

Read the entire content. Don't extract yet. Notice:
- What domains of wisdom are present?
- What made you stop and think?
- What's genuinely novel vs. commonly known?
- What would {PRINCIPAL.NAME} highlight if he were reading this?
- What quotes land perfectly?

### Step 3: Select Dynamic Sections

Based on your deep read, pick 5-12 section names. Rules:
- Section names must be conversational, not academic
- Each must have at least 3 quality bullets
- Always include "Quotes That Hit Different" if source has quotable moments
- Always include "First-Time Revelations" if genuinely new ideas exist
- Be SPECIFIC — "Agentic Engineering Philosophy" not "Technology Insights"

### Step 4: Extract Per Section

For each section, extract 3-15 bullets. Apply tone rules from SKILL.md:
- 8-20 words, flexible for clarity
- Specific details, not vague summaries
- Speaker's words when they're good
- No hedging language
- Every bullet worth telling someone about

### Step 5: Add Closing Sections

Always append:
1. **One-Sentence Takeaway** (15-20 words)
2. **If You Only Have 2 Minutes** (5-7 essential points)
3. **References & Rabbit Holes** (people, projects, books, tools mentioned)

### Step 6: Quality Check

Run the quality checklist from SKILL.md before delivering.

### Step 7: Output

Present the complete extraction in the format specified in SKILL.md.

### Step 8: Auto-Save to SecondBrain

After presenting output, automatically save to `~/SecondBrain/Knowledge/`:

1. **Determine filename** using SecondBrain naming conventions:
   - Podcast/show: `{Guest}-{ShowAbbrev}{Episode}.md` (MW, DOAC, JRE, HL, IF, LI)
   - YouTube/general: `{Creator}-{Short-Topic}.md`
   - Book/author: `{Author}-{Short-Title}.md`
   - No dates in filename. No pattern name. Title-Case-With-Hyphens.

2. **Check for duplicates** — scan `~/SecondBrain/Knowledge/` for existing file with same source. Warn if found.

3. **Write file** with:
   - YAML frontmatter: title, type (`wisdom-extraction`), domain, tags (2-6 kebab-case), date, source URL, status (`active`)
   - Full extraction output
   - `## Related` section with `[[wiki-links]]` to related existing Knowledge files

4. **Confirm** — state the saved filename and path. No permission needed.
