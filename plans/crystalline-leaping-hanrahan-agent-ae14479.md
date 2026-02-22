# Microsoft Teams Workflows Webhook - Complete Research Report

## Research Summary

The classic "Incoming Webhook" connector (Office 365 Connector) was deprecated starting August 2024, with new connector creation blocked. The retirement deadline has been extended to **March 31, 2026** (some sources say April 30, 2026). The replacement is **Power Automate Workflows** using the "When a Teams webhook request is received" trigger.

---

## 1. How to Create a Workflows-Based Webhook in Teams (Step-by-Step)

### Method 1: Using Templates (Recommended - Fastest)

1. Open Microsoft Teams
2. Navigate to the **channel** where you want webhook notifications
3. Click **More options** (three dots) next to the channel name
4. Select **Workflows**
5. Find and select the template: **"Post to a channel when a webhook request is received"**
   - Alternative templates available: "Send webhook alerts to a channel", "Send webhook alerts to a chat"
6. Change the workflow name if desired (give it a descriptive name)
7. Authenticate with your Microsoft account (click "Switch account" if needed)
8. Click **Next**
9. Select the **Team** and **Channel** for notifications (auto-populated if started from that channel)
10. Click **Add workflow**
11. **Copy the generated webhook URL** from the confirmation dialog -- save it securely
12. Click **Done**

### Method 2: Creating from Scratch (More Control)

1. Open the **Workflows** app from the Teams left sidebar
2. Go to the **Create** tab
3. Select **Create from blank**
4. Search for trigger: **"When a Teams webhook request is received"**
5. Choose authentication type:
   - **Anyone** (unauthenticated -- simplest, like the old webhook)
   - **Any user in tenant** (requires Azure AD auth)
   - **Specific users in tenant** (most restrictive)
6. Click **New step**
7. Choose action: **"Post card in chat or channel"** (from Teams connector)
8. Configure the action:
   - Select "Post in" dropdown -> Channel
   - Select Team and Channel
9. **Save** the workflow
10. Copy the **HTTP POST URL** from the webhook trigger box

### How to Find Your Webhook URL Later

1. Open the **Workflows** app in Teams
2. Select your workflow
3. Click **Edit**
4. Expand the **"When a Teams webhook request is received"** trigger
5. The URL is displayed there -- copy it

---

## 2. HTTP POST Format -- Exact Specification

### URL Structure

**Old (deprecated):**
```
https://your-org.webhook.office.com/webhookb2/GUID@GUID/IncomingWebhook/TOKEN/GUID
```

**New (Workflows):**
```
https://prod-XX.REGION.logic.azure.com:443/workflows/WORKFLOW_ID/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=SIGNATURE
```

Key differences:
- Domain is `*.logic.azure.com` (Azure Logic Apps infrastructure) instead of `webhook.office.com`
- Uses port 443 explicitly
- Includes API version, signature, and trigger path parameters
- The URL is significantly longer

**IMPORTANT NOTE (Nov 2025):** Microsoft announced that `logic.azure.com` URLs will be migrated to a new URL format. Starting November 30, 2025, connections using `logic.azure.com` URLs may need updating. Check your workflow for the current URL.

### Headers

```
Content-Type: application/json
```

No other headers required when using "Anyone" authentication. No Bearer token needed (unlike some Power Automate triggers).

### JSON Body -- Adaptive Card Format (RECOMMENDED)

The Workflows webhook expects the Adaptive Card wrapped in a **message envelope**:

```json
{
  "type": "message",
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "contentUrl": null,
      "content": {
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "type": "AdaptiveCard",
        "version": "1.4",
        "body": [
          {
            "type": "TextBlock",
            "text": "Hello from your webhook!",
            "size": "Medium",
            "weight": "Bolder"
          },
          {
            "type": "TextBlock",
            "text": "This is the message body.",
            "wrap": true
          }
        ]
      }
    }
  ]
}
```

**Critical format requirements:**
- The outer `"type"` MUST be `"message"` (not `"AdaptiveCard"`)
- The card goes inside `attachments[0].content`
- `contentType` MUST be `"application/vnd.microsoft.card.adaptive"`
- `contentUrl` should be `null`
- Use Adaptive Card version **1.4 or lower** (1.5+ has compatibility issues with Teams)

### Response Code

- **202 Accepted** -- The request was received and will be processed
- This is different from the old webhook which returned **200 OK** with a body of `1`
- A 202 does NOT guarantee the card was posted successfully (the workflow may still fail during processing)

---

## 3. Key Differences from the Old Incoming Webhook

| Feature | Old Incoming Webhook | New Workflows Webhook |
|---------|---------------------|----------------------|
| **URL domain** | `*.webhook.office.com` | `*.logic.azure.com` |
| **Payload format** | MessageCard OR Adaptive Card (wrapped) | **Adaptive Cards ONLY** (wrapped in message envelope) |
| **MessageCard support** | Yes (native) | No (must convert to Adaptive Card). Microsoft said December 2025 would bring messageCard support, but verify current status. |
| **Simple text** | `{"text": "Hello"}` worked | Must use full Adaptive Card JSON |
| **Response code** | 200 OK (body: `1`) | 202 Accepted |
| **Authentication options** | None (URL is the secret) | Anyone / Tenant users / Specific users |
| **Private channels** | Supported | **Cannot post as flow bot**; can post "on behalf of a user" |
| **Ownership** | Tied to channel | **Tied to a specific user** (the workflow owner) |
| **Setup location** | Channel settings > Connectors | Workflows app or channel context menu |
| **Rate limiting** | 4 req/sec, then throttled | Same 4 req/sec for the connector, plus Power Automate platform limits |
| **Card version** | Any | Must use version 1.4 or lower |

### Does It Accept the Same Adaptive Card JSON Payload?

**Almost, but not exactly.** The old webhook accepted Adaptive Cards in the same `type: message` / `attachments` wrapper format. So if you were already sending Adaptive Cards (not MessageCards), your payload format is compatible. However:

- If you were sending `{"text": "simple message"}` -- that will NOT work
- If you were sending MessageCard format (`@type: MessageCard`) -- that will NOT work
- You must use the full `type: message` + `attachments` wrapper

---

## 4. Limitations and Gotchas

### Private Channels
- **Workflows app CANNOT post to private channels as a flow bot**
- It CAN post to private channels **on behalf of a user** (the workflow owner must be a member of the private channel)
- Microsoft indicated December 2025 would bring private/shared channel support -- verify current status

### Rate Limits
Teams connector rate limits (apply to the channel):

| Time Window | Max Requests |
|------------|-------------|
| 1 second | 4 |
| 30 seconds | 60 |
| 1 hour | 100 |
| 2 hours | 150 |
| 24 hours | 1,800 |

Power Automate platform limits (apply to the workflow):
- **Low profile** (M365/free plans): 10,000 requests/24hr
- **Medium profile** (Premium): 200,000 requests/24hr
- Concurrent inbound calls: ~1,000
- Invoke calls per 5 min: 4,500 (Low) / 45,000 (others)

### Max Payload Size
- **28 KB** maximum message size (Teams limit, not Power Automate)
- Power Automate itself allows up to 100 MB, but the Teams connector enforces 28 KB
- Exceeding 28 KB returns an error

### Other Gotchas
1. **Orphan flows**: If the workflow owner leaves the org, the flow becomes orphaned and stops working. Assign co-owners.
2. **Default environment only**: Workflows can only be created in the default Power Platform environment
3. **No third-party connectors**: No DataDog, Jenkins, etc. integration like old O365 connectors had
4. **Throttling returns 429 in response body**, not as HTTP status code. You must read the response body to detect throttling:
   ```
   "Microsoft Teams endpoint returned HTTP error 429"
   ```
5. **Flow suspension**: If the workflow consistently fails for 14 days or is throttled for 14 days, Power Automate automatically disables it
6. **No `Action.Submit`**: Adaptive Cards sent via webhook do NOT support `Action.Submit`. Use `Action.OpenUrl`, `Action.ShowCard`, or `Action.ToggleVisibility` instead.

---

## 5. Minimal Python Example Using httpx

```python
import httpx
import json

# Your Workflows webhook URL (from Teams > Workflows setup)
TEAMS_WEBHOOK_URL = "https://prod-XX.westus.logic.azure.com:443/workflows/YOUR_WORKFLOW_ID/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=YOUR_SIGNATURE"


def send_teams_message(title: str, message: str, webhook_url: str = TEAMS_WEBHOOK_URL) -> bool:
    """
    Send a message to Microsoft Teams via Workflows webhook.

    Args:
        title: Card title (bold header)
        message: Card body text
        webhook_url: The Workflows webhook URL

    Returns:
        True if accepted (202), False otherwise
    """
    payload = {
        "type": "message",
        "attachments": [
            {
                "contentType": "application/vnd.microsoft.card.adaptive",
                "contentUrl": None,
                "content": {
                    "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                    "type": "AdaptiveCard",
                    "version": "1.4",
                    "body": [
                        {
                            "type": "TextBlock",
                            "text": title,
                            "size": "Medium",
                            "weight": "Bolder",
                            "wrap": True
                        },
                        {
                            "type": "TextBlock",
                            "text": message,
                            "wrap": True
                        }
                    ]
                }
            }
        ]
    }

    try:
        response = httpx.post(
            webhook_url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30.0
        )

        # Workflows returns 202 Accepted on success
        if response.status_code == 202:
            return True

        # Check for throttling in response body
        if "429" in response.text:
            print(f"Rate limited. Retry after backoff.")
            return False

        print(f"Unexpected response: {response.status_code} - {response.text}")
        return False

    except httpx.TimeoutException:
        print("Request timed out")
        return False
    except httpx.HTTPError as e:
        print(f"HTTP error: {e}")
        return False


def send_teams_card_with_facts(
    title: str,
    facts: dict[str, str],
    webhook_url: str = TEAMS_WEBHOOK_URL
) -> bool:
    """
    Send a richer Adaptive Card with key-value facts.
    Useful for heartbeat notifications, alerts, etc.

    Args:
        title: Card title
        facts: Dict of label->value pairs to display
        webhook_url: The Workflows webhook URL

    Returns:
        True if accepted (202), False otherwise
    """
    fact_items = [
        {
            "type": "ColumnSet",
            "columns": [
                {
                    "type": "Column",
                    "width": "auto",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": f"**{key}:**",
                            "wrap": True
                        }
                    ]
                },
                {
                    "type": "Column",
                    "width": "stretch",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": value,
                            "wrap": True
                        }
                    ]
                }
            ]
        }
        for key, value in facts.items()
    ]

    payload = {
        "type": "message",
        "attachments": [
            {
                "contentType": "application/vnd.microsoft.card.adaptive",
                "contentUrl": None,
                "content": {
                    "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                    "type": "AdaptiveCard",
                    "version": "1.4",
                    "body": [
                        {
                            "type": "TextBlock",
                            "text": title,
                            "size": "Medium",
                            "weight": "Bolder",
                            "wrap": True,
                            "separator": True
                        },
                        *fact_items
                    ]
                }
            }
        ]
    }

    try:
        response = httpx.post(
            webhook_url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30.0
        )
        return response.status_code == 202
    except Exception as e:
        print(f"Failed to send Teams card: {e}")
        return False


# --- Usage Examples ---

if __name__ == "__main__":
    # Simple message
    send_teams_message(
        title="PAI Heartbeat",
        message="All systems operational. Next check in 90 minutes."
    )

    # Rich card with facts
    send_teams_card_with_facts(
        title="Ekko Status Report",
        facts={
            "Status": "Online",
            "Uptime": "47 hours",
            "Tasks Completed": "12",
            "Next Heartbeat": "11:30 AM ET"
        }
    )
```

### Minimal curl Example (for quick testing)

```bash
curl -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "message",
    "attachments": [
      {
        "contentType": "application/vnd.microsoft.card.adaptive",
        "contentUrl": null,
        "content": {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.4",
          "body": [
            {
              "type": "TextBlock",
              "text": "Test from curl",
              "weight": "Bolder"
            }
          ]
        }
      }
    ]
  }'
```

Expected response: HTTP 202 with empty or minimal body.

---

## 6. Strategic Considerations for PAI Integration

### Second-Order Effects to Consider

1. **Workflow ownership = single point of failure.** If the Microsoft account that created the workflow gets disabled, ALL notifications stop. Always assign a co-owner.

2. **The URL IS the authentication** (when using "Anyone" mode). Treat it like a secret. Store in `.env`, never commit to git.

3. **Rate limits are per-channel, not per-webhook.** If you have multiple systems posting to the same channel, they share the 4 req/sec and 1,800 req/day limits.

4. **Migration window is closing.** March/April 2026 is the hard deadline. Any existing O365 connector webhooks will stop working after that.

5. **Power Automate licensing matters.** The "Low" performance profile (free/M365 plans) has significantly lower throughput limits. For PAI's heartbeat usage (every 90 min), this is more than adequate.

### Recommended Implementation for PAI

- Store webhook URL in `~/.claude/.env` as `TEAMS_WEBHOOK_URL`
- Add Teams as a channel in the `notify_all()` router alongside Discord and voice
- Use Adaptive Card version 1.4
- Implement exponential backoff for 429 responses
- Use the simple `send_teams_message()` function for heartbeat notifications
- Use `send_teams_card_with_facts()` for richer status reports

---

## Sources

- [Create incoming webhooks with Workflows for Microsoft Teams - Microsoft Support](https://support.microsoft.com/en-us/office/create-incoming-webhooks-with-workflows-for-microsoft-teams-8ae491c7-0394-4861-ba59-055e33f75498)
- [Create an Incoming Webhook - Teams | Microsoft Learn](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)
- [Create & Send Actionable Messages - Teams | Microsoft Learn](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/connectors-using)
- [Retirement of Office 365 connectors within Microsoft Teams - Microsoft 365 Developer Blog](https://devblogs.microsoft.com/microsoft365dev/retirement-of-office-365-connectors-within-microsoft-teams/)
- [Migrate Teams Incoming Webhooks to Workflows (Power Automate) - Heusser.pro](https://heusser.pro/p/migrate-teams-office-365-connectors-to-workflows-8p40yq7jfebm/)
- [Sending messages to Microsoft Teams using workflows via webhook - Simon Scholz](https://simonscholz.dev/tutorials/microsoft-teams-messages-webhook-workflow/)
- [Limits of automated, scheduled, and instant flows - Power Automate | Microsoft Learn](https://learn.microsoft.com/en-us/power-automate/limits-and-config)
- [Simple Workflow to Replace Teams Incoming Webhooks | Microsoft Community Hub](https://techcommunity.microsoft.com/discussions/teamsdeveloper/simple-workflow-to-replace-teams-incoming-webhooks/4225270)
- [MC1181996 - Migration update for Office 365 connectors retirement](https://mc.merill.net/message/MC1181996)
