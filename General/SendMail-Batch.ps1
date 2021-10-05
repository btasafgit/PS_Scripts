$fl = Import-Csv "C:\Users\adori\OneDrive - Ormat\Documents\PS Projects\Powershell\file.csv"
$fl.Length
$batch = 60 #How many email to Send per batch
$suspend = 2 # How long to suspend email sending
$from = "BatchMail@ormat.com"
$smtp = "mail2.ormat.com"

for($i=0; $i -le $fl.Length ;$i+=$batch)
{
    for($b=$i;$b -lt $i+$batch;$b++){
        #Write-Host "B="$b
        #Write-Host "i="$i
        #Write-Host $fl[$b].to"|"$fl[$b].data
        $html = @'
        <!DOCTYPE html>
        <html lang="en">
        
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta http-equiv="Content-Type" content="text/html">
            <style>
                html,
                body {
                    margin: 0 auto !important;
                    padding: 0 !important;
                    height: 100% !important;
                    width: 100% !important;
                }
        
                
        
                table {
                    border-collapse: collapse;
                }
        
                /* Stop Outlook from adding extra spacing to tables. */
                table,
                td {
                    mso-table-lspace: 0pt !important;
                    mso-table-rspace: 0pt !important;
                }
        
                /* Use a better rendering method when resizing images in Outlook IE. */
                img {
        
                    -ms-interpolation-mode: bicubic;
        
                }
            </style>
        </head>
        
        <body style="font-family: Arial, sans-serif">
            <div>
                <table style="width: 600px; table-layout:fixed; ">
                    <tr style="height: 85px; background-color: #002854;">
                        <td style="/*padding: 0px;*/ width: 100px;">
                            <img src="https://www.ormat.com/en/ormat_logo_RGB_blue.gif"></img>
                        </td>
                        <td style="/*padding: 0px;*/">
                            <a style="/*padding-top: 10px; padding: 10px;*/ color: white;  text-align: center;  font-size: 30px;">Password
                                Expiry Notification</a>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="padding-left: 10px">
                            <p>
                            <h1>Hello {0},</h1>
        
                            <div>
                                <p>Your ORMAT.com domain password will expire soon. Please consider changing your password
                                    before (XXX).
                                <p>Password requirements: </p>
                                <ul>
                                    <li>VAR0: {0}</li>
                                    <li>VAR1: {1}</li>
                                    <li>VAR2: {2}</li>
                                </ul>
                                </p>
                            </div>
        
                            <p>
                                <a style="font-weight: 600">If your currently at ORMAT offices:</a>
                            <ol type="A">
                                <li>On your keyboard press CTRL+ALT+DEL</li>
                                <li>Click on “Change a password”</li>
                                <li>Type your old password and then your new password twice</li>
                            </ol>
                            </p>
        
                            <p>
                            <p style="font-weight: 600">If your currently outside ORMAT offices:</p>
                            <ol type="A">
                                <li>Go to <a style="font-weight: 700" href="https://ormat.okta.com/login/default">Okta
                                        portal</a></li>
                                <li>Click on <a style="font-weight: 700">“Forgot Password?”</a></li>
                                <li>Click on <a style="font-weight: 700">“Password reset”</a> and follow the steps</li>
                            </ol>
                            In case you get stuck please call us and we will be happy to assist you.
                            </p>
                        </td>
                    </tr>
                </table>
                
            </div>
        </body>
        
        </html>
'@ -f $fl[$b].Name,$fl[$b].data,$fl[$b].data2

    Send-MailMessage -BodyAsHtml -Subject "Update Ormat data" -Body $html -From $from -To $fl[$b].to -SmtpServer $smtp -port 25 -UseSsl -Encoding utf8
    }
    Write-Host "========="
     Start-Sleep $suspend
    
}


