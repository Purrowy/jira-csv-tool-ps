Write-Host "Essa"
$csvFile = "$PSScriptRoot\import.csv"

# Issue here: csv exported from jira contain columns with duplicate names

# Imports the file content and removes header row before being converted back to csv
Get-Content $csvFile | ConvertFrom-String -Delimiter "," | select -Skip 1 | ConvertTo-Csv

# Trying to import just one column thru pipeline doesn't work cause import-csv needs to run first anyway
# Import-Csv $csvFile | select asdasd