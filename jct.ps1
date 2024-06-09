Write-Host "Essa"
$source_csv = "$PSScriptRoot\import.csv"
$fixed_source_csv = "$PSScriptRoot\fixed.csv"

# Issue: imported csv from Jira ignores chosen delimiter option and forces its default ; inside data rows
# Solution: replace each forced delimiter with correct one before doing anything else with the file
$imported_content = Get-Content $source_csv
$fixed_content = $imported_content -replace ';', ','
Set-Content -Path $fixed_source_csv -Value $fixed_content

# Issue here: csv exported from jira contain columns with duplicate names
# Trying to import just one column thru pipeline doesn't work cause import-csv needs to run first anyway
# Import-Csv $csvFile | select asdasd
# This works, but number of columns has to be hardcoded. Might be easier to select them later, if they are being indexed by number
$imported_csv = Import-Csv $fixed_source_csv -Header (1..6) | Select-Object -Skip 1

# Prepares a list of attachments to download
$target_list = @()
$target_columns = $imported_csv | Select-Object -Property "1", "6"

foreach($row in $target_columns) {
    $target_list += $row
}

Write-Host $target_list

# Download listed attachments and save them under ticket's number
$download_path = "$PSScriptRoot\work\"
foreach ($ticket in $target_list) {
    $link = $ticket."6"
    $filename = $ticket."1"

    Write-Host $link

     try {
        Invoke-WebRequest -Uri $link -OutFile $download_path$filename
        Write-Host "done"
    } catch {
        Write-Host "failed"
    }
}