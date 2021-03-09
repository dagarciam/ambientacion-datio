[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$SCRIPT_VERSION = "0.2.0"

$HADOOP_HOME = "C:\hadoop"
$M2_HOME = "C:\maven"
$M2_VERSION = "3.6.3"

$ORACLE_JDK_URI = 'https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html'

$DOWNLOAD_DIR = "${env:USERPROFILE}\Downloads"
$RSA_KEY_FILENAME = "${env:USERPROFILE}/.ssh/id_rsa"
$SETTINGS_DIR = "${env:USERPROFILE}\.m2\"
$SETTINGS_FILE = "${env:USERPROFILE}\.m2\settings.xml"
$GIT_EXE = "$DOWNLOAD_DIR\Git-2.30.0.2-64-bit.exe"
$INTELLIJ_EXE = "$DOWNLOAD_DIR\ideaIC-2020.3.2.exe"
$INTELLIJ_CONFIG = "$DOWNLOAD_DIR\silent-intellij.config"
$SUBLIME_TEXT = "$DOWNLOAD_DIR\Sublime_Text_Build_3211_x64_Setup.exe"
$raw = (Invoke-WebRequest -Uri $ORACLE_JDK_URI).RawContent
$JAVA_FILE =  $raw.Split([Environment]::NewLine) | ForEach-Object { If ($_ -imatch "data-file='.*(jdk-.*-windows-x64.exe)'"){ $Matches[1] } }
$JAVA_VERSION =  $raw.Split([Environment]::NewLine) | ForEach-Object { If ($_ -imatch "data-file='.*jdk-8u(.*)-windows-x64.exe'"){ $Matches[1] } }
$JAVA_EXE = "$DOWNLOAD_DIR\$JAVA_FILE"
$JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_$JAVA_VERSION"

[Console]::WriteLine("Descarga el archivo $JAVA_FILE en el directorio: $DOWNLOAD_DIR")
[Console]::WriteLine("Deberas aceptar los terminos y condiciones de uso además de iniciar sesión con una cuenta Oracle (si no la tienes puedes crear una).")
Read-Host "Presiona ENTER Para comenzar"
Start-Process "microsoft-edge:$ORACLE_JDK_URI"
Read-Host 'Cuando la descarga haya concluido presiona ENTER'

New-Item -ItemType Directory -Force -Path "$HADOOP_HOME\bin"
New-Item -ItemType Directory -Force -Path $M2_HOME
New-Item -ItemType Directory -Force -Path $SETTINGS_DIR

$wc = New-Object net.webclient
$wc.Downloadfile("https://github.com/steveloughran/winutils/raw/master/hadoop-2.7.1/bin/winutils.exe", "$HADOOP_HOME\bin\winutils.exe")
$wc.Downloadfile("https://downloads.apache.org/maven/maven-3/$M2_VERSION/binaries/apache-maven-$M2_VERSION-bin.zip", "$M2_HOME\apache-maven-$M2_VERSION-bin.zip")
$wc.Downloadfile("https://github.com/git-for-windows/git/releases/download/v2.30.0.windows.2/Git-2.30.0.2-64-bit.exe", $GIT_EXE)
$wc.Downloadfile("https://download.jetbrains.com/idea/ideaIC-2020.3.2.exe", $INTELLIJ_EXE)
$wc.Downloadfile("https://raw.githubusercontent.com/dagarciam/ambientacion-datio/$SCRIPT_VERSION/resources/silent-intellij.config", $INTELLIJ_CONFIG)
$wc.Downloadfile("https://download.sublimetext.com/Sublime%20Text%20Build%203211%20x64%20Setup.exe", $SUBLIME_TEXT)

Add-Type -assembly "system.io.compression.filesystem"
[System.IO.Compression.ZipFile]::ExtractToDirectory("$M2_HOME\apache-maven-$M2_VERSION-bin.zip", "$M2_HOME")

Start-Process -Wait -FilePath $JAVA_EXE -ArgumentList "/s" -PassThru
Start-Process -Wait -FilePath $GIT_EXE -ArgumentList "/SILENT" -PassThru
Start-Process -Wait -FilePath $INTELLIJ_EXE -ArgumentList "/S /CONFIG=$INTELLIJ_CONFIG" -PassThru
Start-Process -Wait -FilePath $SUBLIME_TEXT -ArgumentList "/VERYSILENT /NORESTART /TASKS=contextentry" -PassThru


[System.Environment]::SetEnvironmentVariable('JAVA_HOME',"$JAVA_HOME",[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('HADOOP_HOME',$HADOOP_HOME,[System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('M2_HOME',"$M2_HOME\apache-maven-$M2_VERSION",[System.EnvironmentVariableTarget]::User)
$PATH = [System.Environment]::GetEnvironmentVariable('PATH','User') 
$PATH = "$PATH;%M2_HOME%\bin;%JAVA_HOME%\bin;%HADOOP_HOME\bin%"
[System.Environment]::SetEnvironmentVariable('PATH',$PATH,[System.EnvironmentVariableTarget]::User)

Start-Process "microsoft-edge:https://globaldevtools.bbva.com"
[Console]::WriteLine("Inicia sesión en el navegador con las credenciales de tu cuenta bbva")
Read-Host 'Cuando lo hayas hecho presiona ENTER...'
Start-Process "microsoft-edge:https://globaldevtools.bbva.com/artifactory/webapp/#/profile"
$ARTIFACTORY_API_KEY = Read-Host 'API-KEY'
$CONTRACTOR_EMAIL = Read-Host 'Correo BBVA (ejemplo-> danieladan.garcia.contractor@bbva.com)'

if (Test-Path $RSA_KEY_FILENAME) {
    Remove-Item "$RSA_KEY_FILENAME*"
}
ssh-keygen -t rsa -m pem -C $CONTRACTOR_EMAIL -f $RSA_KEY_FILENAME -q -N """"
Get-Content "$RSA_KEY_FILENAME.pub"
Start-Process "microsoft-edge:https://globaldevtools.bbva.com/bitbucket/plugins/servlet/ssh/account/keys"
Read-Host  "Agrega la llave, cuando lo hayas hecho presiona ENTER..."
$wc.Downloadfile("https://raw.githubusercontent.com/dagarciam/ambientacion-datio/$SCRIPT_VERSION/resources/settings_MX.xml", $SETTINGS_FILE)
(Get-Content -path $SETTINGS_FILE -Raw) -replace 'BBVA_USERNAME', ($CONTRACTOR_EMAIL.Split("@")[0]) | Out-File -FilePath $SETTINGS_FILE
(Get-Content -path $SETTINGS_FILE -Raw) -replace 'ARTIFACTORY_API_KEY', $ARTIFACTORY_API_KEY | Out-File -FilePath $SETTINGS_FILE
[Console]::WriteLine("Bien hecho!")
Read-Host  "presiona ENTER para finalizar..."
Start-Process "microsoft-edge:https://globaldevtools.bbva.com/bitbucket/projects/WJEEW/repos/wjeew_datio_developer_cert_exercises/browse"
