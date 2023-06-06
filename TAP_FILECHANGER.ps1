param (
    [string]$file
)

# Function to display ASCII art banner
function Show-Banner {
    Write-Host @"
 _____  _    ____
|_   _|/ \  |  _ \
  | | / _ \ | |_) |
  | |/ ___ \|  __/
  |_/_/   \_\_|

 _____ ___ _     _____ ____ _   _    _    _   _  ____ _____ ____
|  ___|_ _| |   | ____/ ___| | | |  / \  | \ | |/ ___| ____|  _ \
| |_   | || |   |  _|| |   | |_| | / _ \ |  \| | |  _|  _| | |_) |
|  _|  | || |___| |__| |___|  _  |/ ___ \| |\  | |_| | |___|  _ <
|_|   |___|_____|_____\____|_| |_/_/   \_\_| \_|\____|_____|_| \_\

__   _____  _   _ ____
\ \ / / _ \| | | |  _ \
 \ V / | | | | | | |_) |
  | || |_| | |_| |  _ <
  |_| \___/ \___/|_| \_\

 _     ___ _____ _____ ____ _   _    _    _   _  ____ _____ ____
| |   |_ _|  ___| ____/ ___| | | |  / \  | \ | |/ ___| ____|  _ \
| |    | || |_  |  _|| |   | |_| | / _ \ |  \| | |  _|  _| | |_) |
| |___ | ||  _| | |__| |___|  _  |/ ___ \| |\  | |_| | |___|  _ <
|_____|___|_|   |_____\____|_| |_/_/   \_\_| \_|\____|_____|_| \_\
"@
}

# Function to display ASCII art line
function Show-Line {
    param (
        [int]$Length = 40,
        [char]$Character = '-'
    )
    $line = (New-Object Text.StringBuilder).Append($Character, $Length).ToString()
    Write-Host $line
    Write-Host
}

# Function to update and display the summary of changes
function Update-Summary {
    Show-Frame -Text "Summary of Changes"
    Write-Host ("| {0,-20} | {1,-20} | {2,-15} |" -f "Replace What", "Replace With", "Change Count")
    Write-Host (('+' + ('=' * 22) + '+' + ('=' * 22) + '+' + ('=' * 17)))
    foreach ($change in $changes) {
        Write-Host ("| {0,-20} | {1,-20} | {2,-15} |" -f $change['ReplaceWhat'], $change['ReplaceWith'], $change['ChangeCount'])
    }
    Write-Host (('+' + ('=' * 22) + '+' + ('=' * 22) + '+' + ('=' * 17)))
    Write-Host
}

# Function to display ASCII art frame
function Show-Frame {
    param (
        [string]$Text
    )
    $line = '+' + ('=' * 22) + '+'
    Write-Host $line
    Write-Host ("| {0,-40} |" -f $Text)
    Write-Host $line
}

# Main script logic
Clear-Host
Show-Banner

# Check if the file path is provided
if ([string]::IsNullOrEmpty($file)) {
    Show-Banner
    Write-Host "Please provide the path to the file using the -file parameter."
    return
}

# Check if the file exists
if (-not (Test-Path -Path $file -PathType Leaf)) {
    Show-Banner
    Write-Host "File not found: $file"
    return
}

# Read the content of the file
$originalContent = Get-Content -Path $file -Raw

# Initialize the changes array
$changes = @()

# Prompt for replacement strings
while ($true) {
    $replaceWhat = Read-Host "Enter the text to replace (leave blank to stop):"
    if ([string]::IsNullOrWhiteSpace($replaceWhat)) {
        break
    }

    $replaceWith = Read-Host "Enter the replacement text:"

    $changeCount = ([regex]::Matches($originalContent, [regex]::Escape($replaceWhat))).Count

    $change = @{
        'ReplaceWhat' = $replaceWhat
        'ReplaceWith' = $replaceWith
        'ChangeCount' = $changeCount
    }

    $changes += $change
}

# Show summary of changes
Update-Summary

# Confirm if the user wants to proceed with the changes
$confirmation = Read-Host "Are you sure you want to proceed with the changes? (Y/N)"
if ($confirmation -ne 'Y') {
    Show-Banner
    Write-Host "Operation cancelled by the user."
    return
}

# Perform the replacements in the content
foreach ($change in $changes) {
    $originalContent = $originalContent -replace [regex]::Escape($change['ReplaceWhat']), $change['ReplaceWith']
}

# Generate the output file path
$folderPath = Split-Path -Path $file
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$outputFileName = "output_$timestamp.txt"
$outputFilePath = Join-Path -Path $folderPath -ChildPath $outputFileName

# Save the modified content to the output file
$originalContent | Out-File -FilePath $outputFilePath -Encoding UTF8

# Display the output file path
Show-Line
Write-Host "The changes have been saved to the output file: $outputFilePath"

# Calculate and display the total change count
$changeCount = 0
foreach ($change in $changes) {
    $changeCount += $change['ChangeCount']
}
Write-Host "Total change count: $changeCount"
