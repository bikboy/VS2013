Compare-Object  -referenceobject $( Get-ADGroupMember IMBCallCenter  |Get-ADUser -pr enabled |Where-Object{$_.enabled -like "true"}
)    -differenceobject  $( Get-ADGroupMember imbinetlimitedgatelaccess  |Get-ADUser -pr enabled |Where-Object{$_.enabled -like "true"}
)  -IncludeEqual  -ExcludeDifferent 
