$i=0
$err = @()
$usrList = @()
$debug = $env:dbg
$date = get-date
$daysToChangePass = $env:daysToChange
$whenToNotify = $env:whenToNotifyUsers

$OUs = 'OU=Headquarter,DC=ORMAT,DC=com','OU=Branches,DC=ORMAT,DC=com'
$usrList += $OUs | foreach {Get-ADUser -Properties passwordlastset,mail -filter * -SearchBase $_ |where {$_.Enabled -eq $true}}
<# Mail Settings#>
$from = "noreply@ormat.com"
$subject = "Password expiry notification"
$smtp = "mail2.ormat.com"

foreach($u in $usrList){
try{
    if(([Math]::Abs($daysToChangePass-(((Get-Date) - ($u.passwordlastset))).Days) -le $whenToNotify)){
    try{$changeDate = (($u.PasswordLastSet).AddDays($daysToChangePass)).ToString('dd/MM/yyyy')}
    catch{Write-host -ForegroundColor Red $u.Name}
    $data = @($u.Name,$changeDate) 

      
$html1 = @'
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="x-apple-disable-message-reformatting">
  <title></title>
  <!--[if mso]>
  <noscript>
    <xml>
      <o:OfficeDocumentSettings>
        <o:PixelsPerInch>96</o:PixelsPerInch>
      </o:OfficeDocumentSettings>
    </xml>
  </noscript>
  <![endif]-->
  <style>
    table, td, div, h1, p {font-family: Arial, sans-serif;}
  </style>
</head>
<body style="margin:0;padding:0;">
  <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;background:#ffffff;">
    <tr>
      <td align="center" style="padding:0;">
        <table role="presentation" style="width:605px;border-collapse:collapse;border:1px solid #cccccc;border-spacing:0;text-align:left;">
          <tr>
            <td align="left" style="padding:10px 0 10px 10px;background:#002855;">
              <img src="https://ml.globenewswire.com/Resource/Download/ef187c03-0909-4d69-8c4e-c73e92010ba9?size=2" alt="" width="75" style="height:80px;display:block;" />
            </td>
            <td align="left" width="505" alt="" style="height:auto; padding:10px 0 10px 10px;background:#002855; color: #ffffff; font-size: 30px;">Password expiry notification</td>
          </tr>
          <tr>
            <td colspan="2" style="padding:10px 10px 10px 10px;">
              <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
                <tr>
                  <td style="padding:0 0 10px 0;color:#153643;">
                    <h1 style="font-size:24px;margin:0 0 20px 0;font-family:Arial,sans-serif;">Hello 
'@

# Add Name

$html2 = @'
,</h1>
                    <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;">Your ORMAT.com domain password will expire soon. Please consider changing your password
                            before 
'@
#Add Date

$html3 = @'
.</p>
                    <div>
                      <p style="margin:0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;"><strong>Password requirements:</strong></p>
                        <ul>
                          <li>Minimum 8 characters long</li>
                          <li>Must have three of the following: lowercase, UPPERCASE, symbols, or numbers</li>
                          <li>Must be different from your last five passwords</li>
                        </ul>
                    </div>
                  </td>
                </tr>

                <tr>
                  <td style="padding:0 0 10px 0;color:#153643;">
                    <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;"><strong>If you are currently at Ormat offices or connected via Global Protect:</strong></p>
                    <div>
                        <ol>
                          <li>On your keyboard press CTRL+ALT+DEL</li>
                          <li>Click on &ldquo;Change a password&rdquo;</li>
                          <li>Enter your old password and then enter new password twice</li>
                        </ol>
                    </div>
                  </td>
                </tr>

                <tr>
                  <td style="padding:0 0 10px 0;color:#153643;">
                    <p style="margin:0 0 12px 0;font-size:16px;line-height:24px;font-family:Arial,sans-serif;"><strong>If you are currently outside Ormat offices:</strong></p>
                    <div>
                        <ol>
                          <li>Go to <a href="https://ormat.okta.com/login/default">Okta portal</a></li>
                          <li>Click on <a style="font-weight: bold;">&ldquo;Forgot Password?&rdquo;</a></li>
                          <li>Click on <a style="font-weight: bold;">&ldquo;Password reset&rdquo;</a> and follow the steps</li>
                        </ol>
                    </div>
                  </td>
                </tr>

                <tr>
                  <td style="padding:0 0 36px 0;color:#153643 "> <!--#2dccd3; background:#d22630; -->
                    <p>In case you get stuck please call us and we will be happy to assist you.</p>
                  </td>
                </tr>

                
                <tr>
                  <td style="padding:0;">
                    <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;">
                      <tr>
                        <td style="width:260px;padding:0;vertical-align:top;color:#153643;">
                          <p style="margin:0 0 10px 0;font-size:12px;line-height:20px;font-family:Arial,sans-serif;background-color: #e6e6e6 ;padding-left: 10px;"><strong>Work Hours</strong></p>
                          <p style="margin:0 0 10px 0;font-size:11px;line-height:20px;font-family:Arial,sans-serif;padding-left: 10px;"><strong>IL Helpdesk:</strong> Sunday - Thursday 07:00-18:00<br />All other times please call 65656 (08-932-5656) <br />for urgent assistance.</p>
                          <p style="margin:0 0 10px 0;font-size:11px;line-height:20px;font-family:Arial,sans-serif;padding-left: 10px;"><strong>US Helpdesk:</strong> Monday &ndash; Friday 8:00am-5:00pm. <br />Call 33345 (775-398-4345)</p>
                          <p style="margin:0 0 10px 0;font-size:11px;line-height:20px;font-family:Arial,sans-serif;padding-left: 10px;"><strong>KE Helpdesk:</strong> Monday &ndash; Friday 8:00am-5:00pm.<br />Call 53227</p>
                        </td>
                        <!-- <td style="width:20px;padding:0;font-size:0;line-height:0;">&nbsp;</td> Spacing-->
                        <td style="width:260px;padding:0;vertical-align:top;color:#153643;">
                          <p style="margin:0 0 10px 0;font-size:12px;line-height:20px;font-family:Arial,sans-serif;background-color: #e6e6e6; text-align: right;padding-right: 10px;"><strong>שעות עבודה</strong></p>
                          <p style="margin:0 0 10px 0;font-size:11px;line-height:20px;font-family:Arial,sans-serif; text-align: right;padding-right: 10px;">ימי א-ה 07:00-18:00<br />מחוץ לשעות עבודה, במקרים דחופים נא להתקשר<br />ל65656 (08-932-5656)</p>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td colspan="2" style="padding:30px;background:#002855;">
              <!--
              <table role="presentation" style="width:100%;border-collapse:collapse;border:0;border-spacing:0;font-size:9px;font-family:Arial,sans-serif;">
                <tr>
                  <td style="padding:0;width:50%;" align="left">
                    <p style="margin:0;font-size:14px;line-height:16px;font-family:Arial,sans-serif;color:#2dccd3;">
                      &reg; Someone, Somewhere 2021<br/><a href="http://www.example.com" style="color:#2dccd3;text-decoration:underline;">Unsubscribe</a>
                    </p>
                  </td>
                  <td style="padding:0;width:50%;" align="right">
                    <table role="presentation" style="border-collapse:collapse;border:0;border-spacing:0;">
                      <tr>
                        <td style="padding:0 0 0 10px;width:38px;">
                          <a href="https://www.linkedin.com/company/ormat" style="color:#2dccd3;"><img src="https://assets.codepen.io/210284/tw_1.png" alt="Twitter" width="38" style="height:auto;display:block;border:0;" /></a>
                        </td>
                        <td style="padding:0 0 0 10px;width:38px;">
                          <a href="http://www.facebook.com/" style="color:#2dccd3;"><img src="https://assets.codepen.io/210284/fb_1.png" alt="Facebook" width="38" style="height:auto;display:block;border:0;" /></a>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>-->
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
'@
$body = $html1+$data[0]+$html2+$data[1]+$html3


    #debug email
    if($debug -eq 1)
    {$to = "adori@ormat.com"}
    else{$to = $u.mail}

        # Send email if less than 14 days for password to expire

            Send-MailMessage -Subject $subject -From $from -To $to -SmtpServer $smtp -port 25 -UseSsl -Encoding UTF8 -Body $body -BodyAsHtml;
            Write-host "Email will be send to:"$u.mail ">>>>>> Need to change passowrd: "$changeDate
            $i++
    }#end of if
    }#end of TRY
catch{$err += $u.Name}#end of CATCH
} #End of foreach

Write-host "Users that requires their password change:"$i
$u.Name


Write-host "Users with Error:" $err.count
$err
