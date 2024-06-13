$source_csv = "$PSScriptRoot\import.csv"
$json = Get-Content .\settings.json | ConvertFrom-Json

# Issue: csv exported from jira contains columns with duplicate names. This replaces column names with numbers
$imported_csv = Import-Csv $source_csv -Header (1..33) | Select-Object -Skip 1

# Issue: csv exported from jira has three values inside one data cell under target column, and jira ignores chosen delimiter option during export. 
# This removes the unnecessary parts and overwrites the cell with target link only
foreach ($row in $imported_csv) {
    $temp = $row."33" -split ";"
    $row."33" = $temp[3]    
}

# Prepares a list of attachments to download. Column names are hardcoded
$target_list = @()
$target_columns = $imported_csv | Select-Object -Property "2", "33"

foreach($row in $target_columns) {
    $target_list += $row
}

# $target_list

# Downloads listed attachments and changes filename to ticket number
$errors = @()
$error_check = $false
$download_path = "$PSScriptRoot\work\"

foreach ($ticket in $target_list) {
    $link = $ticket."33"
    $filename = $ticket."2"
    $token = $json.token
    
    $headers = @{
        Authorization = "Bearer $token"
    }

     try {        
        Invoke-WebRequest -Uri $link -Headers $headers -Outfile $download_path$filename
        Write-Host "Downloaded $filename"
    } catch {
        Write-Host "Could not download $filename"
        $errors += $filename
        $error_check = $true
    }
}

# List downloaded files
$files = Get-ChildItem -Path .\work | Select-Object -ExpandProperty Name

# Keyword validation
Write-host "Keyword validation"
$files_with_keywords = @()

foreach ($file in $files) {
    Write-Host -NoNewline "."
    $csv = Import-Csv -Path .\work\$file -Header (1)
    $found = $false
    foreach ($row in $csv) {
        if ($found) {break}

        foreach ($keyword in $json.keywords) {
            if ($found) {break}

            if ($row -like "*$keyword*") {             
                $files_with_keywords += $file
                $found = $true
                break
            }
        }
    }
}

Write-Host ""
Write-Host ("Tickets with exception keywords: " + $files_with_keywords)

# Timestamp validation
Write-Host "Timestamp validation"
$minimum_date = (Get-Date).AddDays(-$json.days)
Write-host ("Minimum date set to: " + $minimum_date.ToString($json.timestampFormat))
$files_old = @()

foreach ($file in $files) {
    Write-Host -NoNewline "."
    $csv = Import-Csv -Path .\work\$file -Header (1)
    $found = $false
    foreach ($row in $csv) {
        if ($found) {break}

        # Extracts date from downloaded csv and converts it to required format for comparision
        $timestamp = $row."1".Substring(0, 15)        
        $date = [datetime]::ParseExact($timestamp, $json.timestampFormat, $null)
        
        if ($date -lt $minimum_date) {
            $files_old += $file
            $found = $true
            break
        }
    }
}

Write-Host ""
Write-Host ("Tickets with old files: " + $files_old)

# Prints list of files that were not downloaded, if any
if ($error_check) {
    Write-Host ("Could not download and validate the following files: " + $errors -join '", "')
}

# Prints list of remaining files
$remaining_files = $files | Where-Object { $files_old -notcontains $_ -and $files_with_keywords -notcontains $_ }
$jql = 'Key in ("' + ($remaining_files -join '", "') + '")'
Write-Host "Remaining files:"
$jql