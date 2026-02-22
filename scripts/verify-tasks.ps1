Get-ScheduledTask -TaskPath '\PAI\' | ForEach-Object {
    Write-Host "$($_.TaskName):"
    Write-Host "  WakeToRun: $($_.Settings.WakeToRun)"
    Write-Host "  StartWhenAvailable: $($_.Settings.StartWhenAvailable)"
    Write-Host "  DisallowStartOnBatteries: $($_.Settings.DisallowStartIfOnBatteries)"
    Write-Host "  StopOnBatteries: $($_.Settings.StopIfGoingOnBatteries)"
    Write-Host ""
}
