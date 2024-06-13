Usage:
1. Paste and save your PAT in json.token
2. Export CSV from Jira using "All fields" option, set the delimiter to comma , (this should be the default setting anyway)
3. Rename it to "import.csv" and put it in root folder of the script
4. Make sure you have "work" folder created within the root folder
5. Run the script
6. Make sure to delete files from /work/ if they are no longer needed

Notes:
- if running through powershell: use `.\jct.ps1`
- if running through command prompt (cmd.exe), use `powershell.exe -File jct.ps1`
  	- in case of errors related to script policies, use `powershell.exe -ExecutionPolicy Bypass -File jct.ps1`
- treat PAT like your own password, don't share it with anyone. You can always revoke it through Jira's profile page, if needed

How it works:
1. Scripts imports the attachments links from provided csv
2. Downloads each attachment using curl and PAT auhorization, filesnames are changed to corresponding ticket number
3. Each downloaded file is validated twice:
	1. Keyword validation: attachments are checked if they contain any keyword listed in json.keywords
	2. Timestamp validation: attachments are checked if any row has a timestamp older than current day minus json.days
4. Three lists are created and printed: files containing keywords, files with old dates, and remaining files

Todo:
- might add an option to automatically remove files from work upon completion
