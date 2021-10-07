$USERS=import-csv c:\book1.csv
FOREACH ($i in $USERS)
{
Get-Mailbox $i.name |fl name,EmailAddresses
}