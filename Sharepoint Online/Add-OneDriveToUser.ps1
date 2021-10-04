$userEmail = "user@email.com"
$spoURI = "https://ormat-admin.sharepoint.com"
Connect-SPOService $spoURI
Request-SPOPersonalSite -UserEmails $userEmail -Nowait