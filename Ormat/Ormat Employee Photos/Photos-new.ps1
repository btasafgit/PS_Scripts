<#function set-PhototoAll()
{



    param ( [Parameter(Mandatory=$True)] [ValidateNotNull()] $imageSource,
    [Parameter(Mandatory=$True)] [ValidateNotNull()] $imageTarget,
    [Parameter(Mandatory=$true)][ValidateNotNull()] $quality )
#>
<# TEMP#>
$path = "C:\Users\adori\OneDrive - Ormat\Documents\PS Projects\PS\Ormat Scripts\Projects\Ormat Employee Photos\"
$t = Get-ChildItem "$path\Source" -File
$imageSource = $t[2].FullName
$imageTarget = "$path\Small\New2.jpg"
$quality = 100
<#######>


if (!(Test-Path $imageSource)){throw( "Cannot find the source image")}
if(!([System.IO.Path]::IsPathRooted($imageSource))){throw("please enter a full path for your source path")}
if(!([System.IO.Path]::IsPathRooted($imageTarget))){throw("please enter a full path for your target path")}
if ($quality -lt 0 -or $quality -gt 100){throw( "quality must be between 0 and 100.")}

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$bmp = [System.Drawing.Image]::FromFile($imageSource)

#hardcoded canvas size...
$canvasWidth = 128.0
$canvasHeight = 128.0

#Encoder parameter for image quality
$myEncoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality)
# get codec
$myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}

#compute the final ratio to use
$ratioX = $canvasWidth / $bmp.Width;
$ratioY = $canvasHeight / $bmp.Height;
$ratio = $ratioY
if($ratioX -le $ratioY){
  $ratio = $ratioX
}

#create resized bitmap
$newWidth = [int] ($bmp.Width*$ratio)
$newHeight = [int] ($bmp.Height*$ratio)
$bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
$bmpResized.RotateFlip("Rotate270FlipNone")
$graph = [System.Drawing.Graphics]::FromImage($bmpResized)
[float]$flt = -90
$graph.RotateTransform($flt)
$graph.Clear([System.Drawing.Color]::White)
$graph.DrawImage($bmp,0,0 , $newWidth, $newHeight)

#save to file
$bmpResized.Save($imageTarget,$myImageCodecInfo, $($encoderParams))
$bmp.Dispose()
$graph.Dispose()
$bmpResized.Dispose()

#}

<#
$path = "C:\Users\adori\OneDrive - Ormat\Documents\PS Projects\PS\Ormat Scripts\Projects\Ormat Employee Photos\"
$t = Get-ChildItem "$path\Source" -File
#Small pic
set-PhototoAll -imageSource $t[2].FullName -imageTarget "$path\Small\New2.jpg" -quality 50
#>