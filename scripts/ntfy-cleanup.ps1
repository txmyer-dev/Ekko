# ntfy-cleanup.ps1 — Archive and clear ntfy inbox daily
# Runs at 6 AM daily via Windows Task Scheduler

$InboxFile = "$env:USERPROFILE\SecondBrain\Inbox\ntfy-inbox.md"
$ArchiveDir = "$env:USERPROFILE\SecondBrain\Inbox\Archive"
$Date = Get-Date -Format "yyyyMMdd"
$ArchiveFile = "$ArchiveDir\ntfy-inbox-archive-$Date.md"

# If inbox doesn't exist or is empty, nothing to do
if (-not (Test-Path $InboxFile)) {
    Write-Host "No inbox file found. Nothing to archive."
    exit 0
}

$content = Get-Content $InboxFile -Raw
if (-not $content -or $content.Trim().Length -lt 50) {
    Write-Host "Inbox is empty or has only the header. Skipping."
    exit 0
}

# Ensure archive directory exists
if (-not (Test-Path $ArchiveDir)) {
    New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
}

# If archive file for today already exists, append to it
if (Test-Path $ArchiveFile) {
    Add-Content -Path $ArchiveFile -Value "`n`n---`n`n# Appended $(Get-Date -Format 'HH:mm:ss')`n`n$content" -Encoding utf8
} else {
    Copy-Item -Path $InboxFile -Destination $ArchiveFile -Force
}

# Reset inbox with fresh header
$header = "# ntfy Inbox`n`nMessages received via ntfy.`n`n---`n"
$header | Out-File -FilePath $InboxFile -Encoding utf8 -Force

Write-Host "Inbox archived to $ArchiveFile and cleared."
