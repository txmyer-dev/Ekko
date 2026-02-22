---
title: PAI Client Setup Guide
type: business
domain: consulting
tags:
  - path-b
  - client-deliverable
  - setup-guide
  - revenue
  - pai
  - onboarding
date: 2026-02-15
source: Internal — built from live system audit
status: active
---

# PAI Client Setup Guide

> **What this builds:** A Personal AI system that manages your tasks, reads your email, monitors your calendar, briefs you on a schedule, and sends you notifications — all running locally on your machine with AI at the center.

> **Time to complete:** 60-90 minutes (core setup) | 30 min additional for optional features

> **Skill level:** Comfortable copy-pasting terminal commands. Your consultant (that's me) walks you through everything.

---

## Table of Contents

1. [What You're Getting](#1-what-youre-getting)
2. [Prerequisites](#2-prerequisites)
3. [API Keys Checklist](#3-api-keys-checklist)
4. [Core Installation — Claude Code + PAI](#4-core-installation)
5. [Configuration — Make It Yours](#5-configuration)
6. [MCP Integrations — Connect Your Tools](#6-mcp-integrations)
7. [Heartbeat — Automated Check-Ins](#7-heartbeat-system)
8. [Notification Channels](#8-notification-channels)
9. [Optional: Voice Server (ElevenLabs TTS)](#9-optional-voice-server)
10. [Optional: Second Brain (Obsidian)](#10-optional-second-brain)
11. [Verification Checklist](#11-verification-checklist)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. What You're Getting

After setup, your Personal AI will:

- **Manage tasks** — connected to Todoist, creates/completes/searches tasks by voice or text
- **Check your email** — reads Gmail via IMAP, surfaces what matters
- **Monitor your calendar** — knows what's coming up today/this week
- **Brief you on a schedule** — every 90 minutes, a heartbeat checks tasks/email/calendar and sends you a summary
- **Notify you** — via Discord, push notifications (ntfy.sh), and optionally voice (text-to-speech)
- **Remember context** — maintains a memory system across sessions
- **Run 31 specialized skills** — from research to security to creative thinking
- **Use The Algorithm** — a structured problem-solving framework for every request

**What it looks like day-to-day:**
- You open your terminal, start Claude Code, and your AI greets you by name
- Every 90 minutes you get a Discord message: "You have 3 tasks due today. 2 new emails. Meeting at 3pm."
- You say "add a task to call the dentist tomorrow" and it's in Todoist
- You say "what happened in security this week" and it researches and summarizes
- You say "help me write this proposal" and it uses structured thinking to produce a quality draft

---

## 2. Prerequisites

### Required Software

Install these in order. Commands are for **Ubuntu/WSL2**. macOS alternatives noted where different.

#### 2.1 Git

```bash
# Ubuntu/WSL2
sudo apt update && sudo apt install -y git

# macOS (comes with Xcode CLI tools)
xcode-select --install
```

Verify: `git --version` → should show `2.x.x`

#### 2.2 Node.js + npm

```bash
# Ubuntu/WSL2 — via NodeSource (LTS)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# macOS
brew install node
```

Verify: `node --version` → should show `v22.x.x` or higher
Verify: `npm --version` → should show `10.x.x` or higher

#### 2.3 Bun (JavaScript/TypeScript runtime)

```bash
# All platforms
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc   # or: source ~/.zshrc on macOS
```

Verify: `bun --version` → should show `1.x.x`

#### 2.4 Python 3.12+

```bash
# Ubuntu/WSL2
sudo apt install -y python3 python3-pip python3-venv

# macOS
brew install python@3.12
```

Verify: `python3 --version` → should show `3.12.x` or higher

#### 2.5 uv (Python package manager — fast pip replacement)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

Verify: `uv --version`

#### 2.6 Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

Verify: `claude --version` → should show `2.x.x (Claude Code)`

> **Note:** Claude Code requires an Anthropic account with an active subscription (Max plan) OR API credits. Sign up at [console.anthropic.com](https://console.anthropic.com).

#### 2.7 mpv (media player — for voice playback, optional)

```bash
# Ubuntu/WSL2
sudo apt install -y mpv

# macOS
brew install mpv
```

---

### Prerequisites Summary Checklist

| Tool | Command to Verify | Expected |
|------|------------------|----------|
| Git | `git --version` | 2.x+ |
| Node.js | `node --version` | 22.x+ |
| npm | `npm --version` | 10.x+ |
| Bun | `bun --version` | 1.x+ |
| Python | `python3 --version` | 3.12+ |
| uv | `uv --version` | any |
| Claude Code | `claude --version` | 2.x+ |
| mpv | `mpv --version` | any (optional) |

---

## 3. API Keys Checklist

Create these accounts and generate API keys **before** starting installation. Store them somewhere safe — you'll paste them into a `.env` file during setup.

### Required (Core Functionality)

| Service | What It Does | Free Tier | Sign Up URL | Key Name |
|---------|-------------|-----------|-------------|----------|
| **Anthropic** | Powers Claude Code (the AI brain) | No — requires Max plan ($20/mo) or API credits | [console.anthropic.com](https://console.anthropic.com) | *(handled by Claude Code login)* |
| **Todoist** | Task management | Yes — free tier works | [todoist.com/app](https://todoist.com) → Settings → Integrations → Developer → API token | `TODOIST_API_TOKEN` |

### Required for Heartbeat (Automated Check-Ins)

| Service | What It Does | Free Tier | Sign Up URL | Key Name |
|---------|-------------|-----------|-------------|----------|
| **Gmail App Password** | Email monitoring via IMAP | Yes | [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords) (requires 2FA enabled) | `EKKO_EMAIL`, `EKKO_EMAIL_PASSWORD` |
| **Google Calendar** | Calendar monitoring | Yes | Google Calendar → Settings → [your calendar] → Secret address in iCal format | `EKKO_CALENDAR_URL` |
| **Discord Webhook** | Notification delivery | Yes | Discord → Server Settings → Integrations → Webhooks → New Webhook → Copy URL | `DISCORD_WEBHOOK_URL` |

### Recommended (Enhanced Features)

| Service | What It Does | Free Tier | Sign Up URL | Key Name |
|---------|-------------|-----------|-------------|----------|
| **Notion** | Second brain / knowledge base | Yes — free tier works | [notion.so/my-integrations](https://www.notion.so/my-integrations) → New integration → Internal | `NOTION_TOKEN` |
| **ntfy.sh** | Push notifications to phone | Yes — no account needed | [ntfy.sh](https://ntfy.sh) — just pick a unique topic name | *(configured in settings.json)* |

### Optional (Premium Features)

| Service | What It Does | Free Tier | Sign Up URL | Key Name |
|---------|-------------|-----------|-------------|----------|
| **ElevenLabs** | Voice synthesis (text-to-speech) | Yes — 10,000 chars/month | [elevenlabs.io](https://elevenlabs.io) → API Keys | `ELEVENLABS_API_KEY`, `ELEVENLABS_VOICE_ID` |
| **Hostinger** | VPS for hosting workflows | No — starts ~$5/mo | [hostinger.com](https://hostinger.com) | `HOSTINGER_API_TOKEN` |
| **AbuseIPDB** | IP reputation checking | Yes — 1,000 checks/day | [abuseipdb.com/account/api](https://www.abuseipdb.com/account/api) | `ABUSEIPDB_API_KEY` |
| **URLhaus** | Malware URL checking | Yes | [urlhaus-api.abuse.ch](https://urlhaus-api.abuse.ch/) | `URLHAUS_API_KEY` |

### API Keys You Do NOT Need

These are used in the reference system but clients typically skip:
- `FINNHUB_API_KEY` — stock data (skip unless finance-focused)
- `GNEWS_API_KEY` — news API (dead free tier, use NewsData.io if needed)
- `SENDGRID_API_KEY` — email sending (dead free tier, use Brevo if needed)
- `TOMBA_API_KEY` — email finder (niche OSINT use)
- `APIFY_TOKEN` — web scraping (advanced use only)

---

## 4. Core Installation

### Step 1: Clone the PAI Repository

```bash
cd ~
git clone https://github.com/txmyer-dev/Eko.git Eko-repo
```

### Step 2: Run the Installer

```bash
cd ~/Eko-repo
bun run INSTALL.ts
```

The installer wizard will:
- Ask for your **name** (used in greetings and responses)
- Ask for your **timezone** (e.g., `America/New_York`, `America/Los_Angeles`)
- Ask for your **AI assistant's name** (default: PAI — pick whatever you want)
- Set up the `~/.claude/` directory with all skills, hooks, and configurations
- Create a `.env` template for your API keys

### Step 3: Add Your API Keys

```bash
nano ~/.claude/.env
```

Paste your keys in this format (no spaces around `=`, quote values with spaces):

```env
TODOIST_API_TOKEN=your_token_here
EKKO_EMAIL=your_email@gmail.com
EKKO_EMAIL_PASSWORD=your_app_password_here
EKKO_IMAP_SERVER=imap.gmail.com
EKKO_CALENDAR_URL=https://calendar.google.com/calendar/ical/YOUR_CALENDAR/basic.ics
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK
NOTION_TOKEN=ntn_your_token_here
```

> **CRITICAL:** No leading spaces. No trailing spaces. Values with special characters should be quoted with double quotes.

### Step 4: First Launch

```bash
claude
```

Your AI should greet you by name and display the PAI banner. If it does — core installation is complete.

---

## 5. Configuration

### settings.json — The Control Center

Located at `~/.claude/settings.json`. The installer creates this, but here's what to customize:

#### Your Identity

```json
{
  "principal": {
    "name": "YOUR_NAME",
    "timezone": "America/New_York"
  }
}
```

#### Your AI's Identity

```json
{
  "daidentity": {
    "name": "YOUR_AI_NAME",
    "fullName": "YOUR_AI_NAME - Personal AI Infrastructure",
    "displayName": "YOUR_AI_NAME",
    "color": "#3B82F6"
  }
}
```

#### Environment Variables

```json
{
  "env": {
    "PAI_DIR": "/home/YOUR_USERNAME/.claude",
    "PROJECTS_DIR": "~/Projects",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "80000",
    "BASH_DEFAULT_TIMEOUT_MS": "600000"
  }
}
```

> **PAI_DIR** must be an absolute path (not `~`). Use `/home/username/.claude` on Linux/WSL or `/Users/username/.claude` on macOS.

---

## 6. MCP Integrations

MCP (Model Context Protocol) servers connect your AI to external services. These are configured in Claude Code's MCP settings.

### Todoist (Task Management)

Add to your Claude Code MCP configuration:

```json
{
  "mcpServers": {
    "Todoist": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/claude-code-todoist-mcp"],
      "env": {
        "TODOIST_API_TOKEN": "your_token_here"
      }
    }
  }
}
```

**What it enables:** "Add a task," "What's due today?", "Complete the dentist task," "Show my projects"

### Notion (Knowledge Base)

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/claude-code-notion-mcp"],
      "env": {
        "NOTION_TOKEN": "your_token_here"
      }
    }
  }
}
```

**What it enables:** Search pages, create pages, manage databases, store knowledge

### Other Available MCPs

| MCP | Purpose | Install |
|-----|---------|---------|
| GitHub | PR management, issues, code review | Built into Claude Code |
| Hostinger | VPS/hosting management | `@anthropic-ai/claude-code-hostinger-mcp` |
| Custom | Any API you want to connect | Build your own with the MCP SDK |

---

## 7. Heartbeat System

The Heartbeat is your AI's proactive check-in. Every 90 minutes, it:
1. Checks your Todoist tasks (due today, overdue)
2. Reads your email (new unread messages)
3. Checks your calendar (upcoming events)
4. Gets the weather, a stoic quote, and top Hacker News story
5. Sends you a summary via Discord (and optionally voice)

### Step 1: Install Python Dependencies

```bash
pip install httpx
```

### Step 2: Create the Heartbeat Script

Create the file at `~/heartbeat/heartbeat.py`. The script:
- Loads API keys from `~/.claude/.env`
- Calls Todoist API v1 for tasks
- Connects to Gmail via IMAP for email
- Parses Google Calendar iCal feed
- Fetches weather from Open-Meteo (free, no key)
- Posts summary to Discord webhook
- Optionally speaks via Voice Server

> **Your consultant will provide the heartbeat script customized to your setup during your session.**

### Step 3: Create the Runner Script

Create `~/heartbeat/run-heartbeat.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
python3 heartbeat.py
```

```bash
chmod +x ~/heartbeat/run-heartbeat.sh
```

### Step 4: Schedule with Cron

```bash
crontab -e
```

Add these lines (adjust times to your schedule — this runs every 90 min from 10 AM to 1 AM EST):

```cron
# PAI Heartbeat — every 90 min (your active hours)
0 10,13,16,19,22 * * *   /home/YOUR_USER/heartbeat/run-heartbeat.sh >> /home/YOUR_USER/heartbeat/heartbeat.log 2>&1
30 11,14,17,20,23 * * *  /home/YOUR_USER/heartbeat/run-heartbeat.sh >> /home/YOUR_USER/heartbeat/heartbeat.log 2>&1
0 1 * * *                /home/YOUR_USER/heartbeat/run-heartbeat.sh >> /home/YOUR_USER/heartbeat/heartbeat.log 2>&1
```

### Step 5: Test It

```bash
~/heartbeat/run-heartbeat.sh
```

You should receive a Discord notification within 30 seconds.

---

## 8. Notification Channels

### Discord (Recommended — Primary Channel)

1. Create a Discord server (or use an existing one)
2. Go to Server Settings → Integrations → Webhooks
3. Create a new webhook, copy the URL
4. Add to `~/.claude/.env`:

```env
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN
```

**Test it:**
```bash
curl -X POST "$DISCORD_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "PAI notification test!"}'
```

### ntfy.sh (Phone Push Notifications)

1. Install the ntfy app on your phone ([Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy) / [iOS](https://apps.apple.com/app/ntfy/id1625396347))
2. Pick a unique topic name (e.g., `your-name-pai-abc123`)
3. Subscribe to that topic in the app
4. Configure in `~/.claude/settings.json`:

```json
{
  "notifications": {
    "ntfy": {
      "enabled": true,
      "topic": "your-unique-topic-name",
      "server": "ntfy.sh"
    }
  }
}
```

**Test it:**
```bash
curl -d "PAI test notification" ntfy.sh/your-unique-topic-name
```

### Email (For Summaries/Reports)

Email notifications use the same Gmail account configured for IMAP. The heartbeat can send email digests. Configure:

```env
EKKO_EMAIL=your_email@gmail.com
EKKO_EMAIL_PASSWORD=your_app_password
TONY_EMAIL=your_personal_email@example.com
```

---

## 9. Optional: Voice Server (ElevenLabs TTS)

> **Skip this section** if you don't want voice responses. Everything works without it.

The Voice Server is a lightweight FastAPI proxy that converts text to speech using ElevenLabs and plays it through your speakers.

### Prerequisites

- ElevenLabs account with API key
- A voice ID (browse voices at [elevenlabs.io/voices](https://elevenlabs.io/app/voice-library))
- mpv installed (see Prerequisites section)
- Python packages: `fastapi`, `uvicorn`, `httpx`

### Step 1: Install Dependencies

```bash
pip install fastapi uvicorn httpx
```

### Step 2: Add Keys to .env

```env
ELEVENLABS_API_KEY=your_key_here
ELEVENLABS_VOICE_ID=your_voice_id_here
```

### Step 3: Set Up the Voice Server

The Voice Server lives at `~/.claude/VoiceServer/`. It's included in the PAI installation. To start it:

```bash
~/.claude/VoiceServer/start.sh
```

Or set it up as a systemd user service for auto-start:

```bash
# Create service file
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/pai-voice.service << 'EOF'
[Unit]
Description=PAI Voice Server
After=network.target

[Service]
Type=simple
WorkingDirectory=%h/.claude/VoiceServer
ExecStart=/usr/bin/python3 %h/.claude/VoiceServer/server.py
Restart=on-failure
RestartSec=5
Environment=HOME=%h

[Install]
WantedBy=default.target
EOF

# Enable and start
systemctl --user daemon-reload
systemctl --user enable pai-voice.service
systemctl --user start pai-voice.service
loginctl enable-linger $USER
```

### Step 4: Verify

```bash
curl http://localhost:8888/health
```

Should return a health check response.

### Step 5: Configure Voice in settings.json

```json
{
  "daidentity": {
    "voiceId": "your_elevenlabs_voice_id",
    "voice": {
      "stability": 0.35,
      "similarity_boost": 0.8,
      "style": 0.9,
      "speed": 1.1,
      "use_speaker_boost": true,
      "volume": 0.8
    }
  }
}
```

---

## 10. Optional: Second Brain (Obsidian)

> **Skip this section** if you're fine with the built-in memory system. The AI remembers things across sessions by default.

For a persistent, searchable knowledge base, set up an Obsidian vault:

### Step 1: Install Obsidian

Download from [obsidian.md](https://obsidian.md) (free for personal use).

### Step 2: Create Vault Structure

```bash
mkdir -p ~/SecondBrain/{Inbox,Memory,Knowledge,Sessions,Heartbeat,Skills,Templates,Tools}
```

### Step 3: Open in Obsidian

Point Obsidian at `~/SecondBrain/` (or the Windows path if using WSL).

### What Goes Where

| Folder | Purpose |
|--------|---------|
| `Inbox/` | Quick captures, unsorted notes |
| `Memory/` | System memory files (identity, preferences) |
| `Knowledge/` | Long-form knowledge, extractions, learnings |
| `Sessions/` | Session logs, heartbeat logs |
| `Templates/` | Note templates for consistency |

---

## 11. Verification Checklist

Run through these after setup to confirm everything works:

### Core System

- [ ] `claude --version` returns version number
- [ ] `claude` launches and greets you by name
- [ ] "What's my name?" → responds with your name
- [ ] "What skills do you have?" → lists 31 skills

### API Connections

- [ ] "What are my Todoist tasks for today?" → shows tasks
- [ ] "Add a test task called 'PAI setup complete'" → creates task in Todoist
- [ ] "Delete the 'PAI setup complete' task" → removes it

### Heartbeat

- [ ] `~/heartbeat/run-heartbeat.sh` completes without errors
- [ ] Discord notification received with task/email/calendar summary
- [ ] `crontab -l` shows the heartbeat schedule

### Notifications

- [ ] Discord webhook test message received
- [ ] ntfy.sh test notification received on phone (if configured)

### Voice (Optional)

- [ ] `curl http://localhost:8888/health` returns OK
- [ ] Voice plays through speakers when AI responds

---

## 12. Troubleshooting

### "claude: command not found"

```bash
npm install -g @anthropic-ai/claude-code
# Then restart your terminal
```

### "bun: command not found"

```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

### Heartbeat not sending notifications

1. Check the log: `tail -20 ~/heartbeat/heartbeat.log`
2. Verify Discord webhook: `curl -X POST "$DISCORD_WEBHOOK_URL" -H "Content-Type: application/json" -d '{"content":"test"}'`
3. Verify Todoist token: `curl -s -H "Authorization: Bearer YOUR_TOKEN" https://api.todoist.com/api/v1/tasks | head -100`
4. Verify Gmail app password works (try logging in manually first)

### Voice not working

1. Check voice server: `systemctl --user status pai-voice.service`
2. Check ElevenLabs key: `curl -H "xi-api-key: YOUR_KEY" https://api.elevenlabs.io/v1/user`
3. Check mpv: `echo "test" | mpv --no-video -`
4. Check audio output: `pactl info` (PulseAudio/PipeWire)

### .env values not loading

- No spaces around `=`
- No leading whitespace on any line
- Quote values containing spaces: `MY_VAR="value with spaces"`
- Restart Claude Code after editing .env

### MCP server not connecting

- Restart Claude Code completely (exit and relaunch)
- Check `~/.claude/settings.local.json` for MCP permissions
- Verify the API token is correct by testing it with curl

---

## What's Next?

After your system is running:

1. **Use it daily** — the more you use it, the better it gets (memory improves)
2. **Customize skills** — ask "Create a new skill for [your use case]"
3. **Tune your heartbeat** — adjust the schedule, add/remove data sources
4. **Explore The Algorithm** — say "Use the full algorithm to help me with [complex problem]"

---

*Built with PAI v2.5 | Setup guide by Felaniam LLC*
*Questions? Contact your PAI consultant.*

## Related

- [[PAI-Complete-Guide]] — Full PAI system documentation
- [[PAI-Expansion-Plan]] — Infrastructure expansion roadmap
- [[CrowbarCrew-Business-Plan]] — Business planning context
- [[Infrastructure-Design-3-Device-Setup]] — Multi-device architecture
- [[Bootcamp-Session-5-Systems-Team-Leverage]] — Systems and leverage thinking
