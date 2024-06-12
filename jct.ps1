Write-Host "Essa"
$source_csv = "$PSScriptRoot\import.csv"
$fixed_source_csv = "$PSScriptRoot\fixed.csv"

# Import values from provided json file
$json = Get-Content .\settings.json | ConvertFrom-Json

# Issue: imported csv from Jira ignores chosen delimiter option and forces its default ; inside data rows
# Solution: replace each forced delimiter with correct one before doing anything else with the file
$imported_content = Get-Content $source_csv
$fixed_content = $imported_content -replace ';', ','
Set-Content -Path $fixed_source_csv -Value $fixed_content

# Issue here: csv exported from jira contain columns with duplicate names
# Trying to import just one column thru pipeline doesn't work cause import-csv needs to run first anyway
# Import-Csv $csvFile | select asdasd
# This works, but number of columns has to be hardcoded. Might be easier to select them later, if they are being indexed by number
$imported_csv = Import-Csv $fixed_source_csv -Header (1..36) | Select-Object -Skip 1

# Prepares a list of attachments to download
$target_list = @()
$target_columns = $imported_csv | Select-Object -Property "2", "36"

foreach($row in $target_columns) {
    $target_list += $row
}

# Write-Host $target_list

# Download listed attachments and save them under ticket's number
<# $download_path = "$PSScriptRoot\work\"
foreach ($ticket in $target_list) {
    $link = $ticket."36"
    $filename = $ticket."2"
    $token = "xyz"
    $output = "$download_path$filename"
    # $curlCommand = "curl -H `"Authorization: Bearer $token`" -o $download_path$filename $link"
    $headers = @{
        Authorization = "Bearer $token"
    }

     try {
        # Write-Host $curlCommand
        Invoke-WebRequest -Uri $link -Headers $headers -Outfile $download_path$filename
        Write-Host "done"
    } catch {
        Write-Host "failed"
    }
} #>

# CSV analysis
# List downloaded files
$files = Get-ChildItem -Path .\work | Select-Object -ExpandProperty Name
# Write-Host $files

<# # Join data from all csv together and assign filename to each row
$full_data = @()
foreach ($file in $files) {
    $csv = Import-Csv -Path .\work\$file -Header (1)
    foreach ($row in $csv) {
        $full_data += [PSCustomObject]@{ Filename = $file; Path = $row."1" }
    }
}

# $full_data

# $keywords = $json.keywords
# $keywords #>

$files_with_keywords = @()

foreach ($file in $files) {
    $csv = Import-Csv -Path .\work\$file -Header (1)
    $found = $false
    foreach ($row in $csv) {
        if ($found) {break}

        foreach ($keyword in $json.keywords) {
            if ($found) {break}
            if ($row -like "*$keyword*") {                
                write-host "$keyword found in $file"
                $files_with_keywords += $file
                $found = $true
                break
            }
        }
    }
}

$files_with_keywords