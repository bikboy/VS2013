#Get-ADUser -Filter 'enabled -eq $true' | where {$_.name -like "*a"} | select name

Get-ADUser -Filter 'enabled -eq $true' | where {$_.name -like "*a"} | Group-Object givenname 

