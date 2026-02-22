# Plan: Add MS Teams Notifications to Heartbeat

## Context
Tony wants Microsoft Teams as a notification channel in the heartbeat system. The heartbeat (`~/SecondBrain/Heartbeat/heartbeat.py`, 713 lines) already has voice, Discord, and email channels routed through `notify_all()`. Teams uses the Power Automate Workflows webhook (classic Incoming Webhooks retired 12/31/2025).

## Prerequisites (Tony does first)
1. **Create Workflows-based webhook in Teams:**
   - Open Teams → navigate to target channel
   - Click `...` next to channel name → **Workflows**
   - Select **"Post to a channel when a webhook request is received"** template
   - Name it "Ekko Heartbeat", authenticate with your Microsoft account
   - Confirm Team and Channel → **Add workflow**
   - **Copy the generated webhook URL** (format: `https://prod-XX.REGION.logic.azure.com:443/workflows/...`)
2. **Provide the webhook URL** so I can add it to `.env`

## Changes (3 files)

### File 1: `~/.claude/.env`
Add one line:
```
TEAMS_WEBHOOK_URL="https://xxxxx.webhook.office.com/webhookb2/..."
```

### File 2: `~/SecondBrain/Heartbeat/heartbeat.py`

**Change A — Config var (line 45 area, after DISCORD_WEBHOOK_URL):**
```python
TEAMS_WEBHOOK_URL = os.environ.get("TEAMS_WEBHOOK_URL", "")
```

**Change B — New function (after `notify_discord()` at line 576, before Notification Router):**
```python
# ── Teams Notification ──────────────────────────────────────────────

def notify_teams(message: str) -> bool:
    """Send a message to Microsoft Teams via Workflows webhook (Adaptive Card)."""
    if not TEAMS_WEBHOOK_URL:
        return False

    try:
        resp = httpx.post(
            TEAMS_WEBHOOK_URL,
            json={
                "type": "message",
                "attachments": [{
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "contentUrl": None,
                    "content": {
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "type": "AdaptiveCard",
                        "version": "1.4",
                        "body": [
                            {
                                "type": "TextBlock",
                                "text": "Ekko Heartbeat",
                                "weight": "Bolder",
                                "size": "Medium",
                            },
                            {
                                "type": "TextBlock",
                                "text": message,
                                "wrap": True,
                            },
                        ],
                    },
                }],
            },
            timeout=30.0,
        )
        # Workflows returns 202 Accepted (not 200)
        success = resp.status_code == 202
        # 429 rate limit comes in response body, not status code
        if "429" in resp.text:
            log("Teams webhook rate limited")
            return False
        if success:
            log("Teams notification sent")
        else:
            log(f"Teams webhook error: {resp.status_code}")
        return success
    except Exception as e:
        log(f"Teams notification failed: {e}")
        return False
```

**Change C — Update `notify_all()` (lines 597-618):**
- Add `"teams"` to default channels: `channels = ["voice", "discord", "teams"]`
- Add Teams routing in the for-loop:
  ```python
  elif channel == "teams":
      results["teams"] = notify_teams(message)
  ```
- Update docstring options to include `"teams"`

### File 3: `~/.claude/projects/-home-txmyer/memory/MEMORY.md`
- Add `TEAMS_WEBHOOK_URL` to notification docs
- Update notify_all default channels: voice + discord + teams

## Verification
1. Add `TEAMS_WEBHOOK_URL` to `.env` with Tony's Workflows webhook URL
2. Curl test the webhook directly:
   ```bash
   source ~/.claude/.env && curl -s -o /dev/null -w "%{http_code}" -X POST "$TEAMS_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d '{"type":"message","attachments":[{"contentType":"application/vnd.microsoft.card.adaptive","contentUrl":null,"content":{"type":"AdaptiveCard","version":"1.4","body":[{"type":"TextBlock","text":"Test from Ekko heartbeat","wrap":true}]}}]}'
   ```
   Expected: HTTP **202** (Accepted)
3. Confirm message appears in Teams channel
4. Run heartbeat: `python3 ~/SecondBrain/Heartbeat/heartbeat.py`
5. Check log: `cat ~/SecondBrain/Sessions/$(date +%Y-%m-%d)-heartbeat.md | grep Teams`
6. Verify voice and Discord still fire (existing channels unaffected)

## Key Technical Notes
- **Workflows webhook returns 202 Accepted** (not 200 like old connectors)
- **429 rate limits appear in response body**, not as HTTP status code — must parse text
- **Adaptive Card v1.4** (not 1.5+ which has Teams rendering bugs)
- **Rate limits:** 4 req/sec, 100/hour, 1800/day per channel — heartbeat at 90min intervals is well within limits
- **Workflow ownership:** If creator leaves org, flow stops — assign co-owner in Power Automate portal
