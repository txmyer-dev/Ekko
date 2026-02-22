$taskNames = @('NtfyPoll-5AM', 'NtfyPoll-5PM', 'NtfyInboxCleanup')

foreach ($name in $taskNames) {
    $task = Get-ScheduledTask -TaskName $name -TaskPath '\PAI\' -ErrorAction Stop
    $settings = $task.Settings
    $settings.WakeToRun = $true
    $settings.StartWhenAvailable = $true
    $settings.DisallowStartIfOnBatteries = $false
    $settings.StopIfGoingOnBatteries = $false
    Set-ScheduledTask -TaskPath '\PAI\' -TaskName $name -Settings $settings
    Write-Host "OK: $name updated successfully"
}
