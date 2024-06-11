issue: import-csv doesn't allow for columns to have duplicate names

possible solution is to either remove header and reference columns by index?

or rename headers to unique names - if I can confirm that the numbers of columns will always be the same

https://stackoverflow.com/questions/44477546/import-csv-powershell-with-duplicate-column-headers

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv

https://stackoverflow.com/questions/28776973/how-to-extract-one-specific-column-no-header-say-column-2-from-multiple-csv-f

will also try exporting with different delimiters from source

Getting `$curlCommand = "curl -H `"Authorization: Bearer $token`" -o $download_path$filename $link"` to work is too hard, because Authorization in reserved in PS. Had to use Invoke-WebRequest after all
