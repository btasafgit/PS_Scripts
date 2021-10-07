#Add missing details from HR file

$usrs = Get-ADUser btasaf -Properties Company, Department, employeeID, employeeNumber, givenName, mail, mobile, `
Office ,title, sn,telephoneNumber,adminDescription,adminDisplayName, samAccountName, manager, otherMobile,otherPager

foreach($usr in $usrs)
{
    #initialize variables
    Clear-Variable mngrObj
    Clear-Variable mngr
    Clear-Variable usrGivenName
    Clear-Variable usrSN
    Clear-Variable usrEmployeeID
    Clear-Variable usrEmployeeNum
    Clear-Variable usrStartWork
    Clear-Variable usrEndWork
    Clear-Variable usrCompany
    Clear-Variable usrDepartment
    Clear-Variable usrOffice
    Clear-Variable usrMail
    Clear-Variable usrMobile
    Clear-Variable usrTitle
    Clear-Variable usrPhone
    Clear-Variable usrHebGivenName
    Clear-Variable usrHebSN
    Clear-Variable usrUsername

    #Settings Manager details
    $mngrObj = get-aduser $usr.Manager -Properties adminDescription,adminDisplayName
    $mngr = $mngrObj.adminDisplayName + " " + $mngrObj.adminDescription 
    
    #שם פרטי אנגלית
    $usrGivenName = $usr.GivenName
    #שם משפחה אנגלית
    $usrSN = $usr.sn
    #תעודת זהות
    $usrEmployeeID = $usr.EmployeeID
    #מספר עובד
    $usrEmployeeNum = $usrEmployeeNum
    #תאריך תחילת עבודה
    $usrStartWork = $usr.otherMobile
    #תאריך סיום עבודה
    $usrEndWork = $usr.otherPager.Value
    #חטיבה
    $usrCompany = $usr.Company
    #מחלקה
    $usrDepartment = $usr.Department
    #תת מחלקה
    $usrOffice = $usr.Office
    #כתובת דואר אלקטרוני
    $usrMail = $usr.mail
    #מספר נייד
    $usrMobile = $usr.mobile
    #תפקיד
    $usrTitle = $usr.Title
    #מספר טלפון
    $usrPhone = $usr.telephoneNumber
    #שם עברית
    $usrHebGivenName = $usr.adminDisplayName
    #שם אנגלית
    $usrHebSN = $usr.adminDescription
    #שם משתמש
    $usrUsername = $usr.SamAccountName



}