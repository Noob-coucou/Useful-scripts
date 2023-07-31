function Get-FolderSize {
    param([string]$Path)

    $size = Get-ChildItem -Recurse $Path | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum
    [PSCustomObject]@{
        FolderName = (Get-Item $Path).Name
        Size = $size.Sum
    }
}

$folderList = Get-ChildItem | ForEach-Object {
    if ($_.PSIsContainer) {
        Get-FolderSize $_.FullName
    }
    else {
        [PSCustomObject]@{
            FolderName = $_.Name
            Size = $_.Length
        }
    }
} | Sort-Object -Property Size -Descending

# Convert and display folder sizes with appropriate units (GB, MB, KB)
$formattedList = $folderList | ForEach-Object {
    $sizeInBytes = $_.Size
    $sizeInKB = "{0:N2}" -f ($sizeInBytes / 1KB)
    $sizeInMB = "{0:N2}" -f ($sizeInBytes / 1MB)
    $sizeInGB = "{0:N2}" -f ($sizeInBytes / 1GB)

    if ($sizeInGB -ge 1) {
        [PSCustomObject]@{
            FolderName = $_.FolderName
            Size = "$sizeInGB GB"
        }
    }
    elseif ($sizeInMB -ge 1) {
        [PSCustomObject]@{
            FolderName = $_.FolderName
            Size = "$sizeInMB MB"
        }
    }
    else {
        [PSCustomObject]@{
            FolderName = $_.FolderName
            Size = "$sizeInKB KB"
        }
    }
}

# Format and display folder sizes with proper alignment
$formattedList | Format-Table -AutoSize

# Add Pause functionality
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
