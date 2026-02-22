# ntfy-poll.ps1 — Poll ntfy topic and append new messages to inbox
# Runs at 5 AM and 5 PM daily via Windows Task Scheduler

$Topic = "ekko-6b6c21fbd9a6ca84"
$Server = "https://ntfy.sh"
$InboxFile = "$env:USERPROFILE\SecondBrain\Inbox\ntfy-inbox.md"
$StateFile = "$env:USERPROFILE\.claude\scripts\.ntfy-last-poll"

# Get last poll timestamp (or default to 12h ago)
if (Test-Path $StateFile) {
    $since = Get-Content $StateFile -Raw
    $since = $since.Trim()
} else {
    $since = "12h"
}

# Poll for messages since last check
try {
    $response = Invoke-RestMethod -Uri "$Server/$Topic/json?poll=1&since=$since" -Method Get -ErrorAction Stop
} catch {
    Write-Error "Failed to poll ntfy: $_"
    exit 1
}

# If no messages, exit
if (-not $response) {
    # Save current timestamp for next poll
    [int](Get-Date -UFormat %s) | Out-File -FilePath $StateFile -NoNewline
    exit 0
}

# Ensure inbox file exists with header
if (-not (Test-Path $InboxFile)) {
    "# ntfy Inbox`n`nMessages received via ntfy.`n`n---`n" | Out-File -FilePath $InboxFile -Encoding utf8
}

# Parse and append each message
$messages = $response -split "`n" | Where-Object { $_ -match '"event":"message"' }

foreach ($line in $messages) {
    try {
        $msg = $line | ConvertFrom-Json

        # Skip our own outbound notifications (they have titles starting with "Ekko")
        if ($msg.title -and $msg.title -match "^Ekko") {
            continue
        }

        $timestamp = [DateTimeOffset]::FromUnixTimeSeconds($msg.time).ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss")
        $title = if ($msg.title) { $msg.title } else { "ntfy message" }
        $body = if ($msg.message) { $msg.message } else { "(no content)" }

        $entry = "`n## [$timestamp] $title`n`n$body`n`n---`n"
        Add-Content -Path $InboxFile -Value $entry -Encoding utf8
    } catch {
        continue
    }
}

# Save current timestamp for next poll
[int](Get-Date -UFormat %s) | Out-File -FilePath $StateFile -NoNewline

Write-Host "ntfy poll complete. Messages appended to $InboxFile"
