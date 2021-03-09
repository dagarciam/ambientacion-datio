[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$HADOOP_HOME = "C:\hadoop"
$M2_HOME = "C:\maven"
$M2_VERSION = "3.6.3"
$JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_281"


$DOWNLOAD_DIR = "${env:USERPROFILE}\Downloads"
$RSA_KEY_FILENAME = "${env:USERPROFILE}/.ssh/id_rsa"
$SETTINGS_DIR = "${env:USERPROFILE}\.m2\"
$SETTINGS_FILE = "${env:USERPROFILE}\.m2\settings.xml"
$JAVA_EXE = "$DOWNLOAD_DIR\jdk-windows-x64.exe"
$GIT_EXE = "$DOWNLOAD_DIR\Git-2.30.0.2-64-bit.exe"
$INTELLIJ_EXE = "$DOWNLOAD_DIR\ideaIC-2020.3.2.exe"
$INTELLIJ_CONFIG = "$DOWNLOAD_DIR\silent-intellij.config"
$SUBLIME_TEXT = "$DOWNLOAD_DIR\Sublime_Text_Build_3211_x64_Setup.exe"

New-Item -ItemType Directory -Force -Path "$HADOOP_HOME\bin"
New-Item -ItemType Directory -Force -Path $M2_HOME
New-Item -ItemType Directory -Force -Path $SETTINGS_DIR

$wc = New-Object net.webclient

$wc.Downloadfile("https://github.com/steveloughran/winutils/raw/master/hadoop-2.7.1/bin/winutils.exe", "$HADOOP_HOME\bin\winutils.exe")
$wc.Downloadfile("https://downloads.apache.org/maven/maven-3/$M2_VERSION/binaries/apache-maven-$M2_VERSION-bin.zip", "$M2_HOME\apache-maven-$M2_VERSION-bin.zip")
$wc.Downloadfile("https://github.com/git-for-windows/git/releases/download/v2.30.0.windows.2/Git-2.30.0.2-64-bit.exe", $GIT_EXE)
$wc.Downloadfile("https://www.googleapis.com/drive/v3/files/1--SiVicvWF3WV76RK5H_5fH2sZD798VP?alt=media&key=AIzaSyBbCveZFfm17wJVX_EBRT-D1o8pyVl9kFY", $JAVA_EXE)
$wc.Downloadfile("https://download.jetbrains.com/idea/ideaIC-2020.3.2.exe", $INTELLIJ_EXE)
$wc.Downloadfile("https://www.googleapis.com/drive/v3/files/1HtO8_ZL5FME39E8KMS0NYgjTrP4NYacv?alt=media&key=AIzaSyBbCveZFfm17wJVX_EBRT-D1o8pyVl9kFY", $INTELLIJ_CONFIG)
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
$wc.Downloadfile("https://www.googleapis.com/drive/v3/files/1oxFyilHpVy8rbQRtIS031nXf9rbwllt3?alt=media&key=AIzaSyBbCveZFfm17wJVX_EBRT-D1o8pyVl9kFY", $SETTINGS_FILE)
(Get-Content -path $SETTINGS_FILE -Raw) -replace 'BBVA_USERNAME', ($CONTRACTOR_EMAIL.Split("@")[0]) | Out-File -FilePath $SETTINGS_FILE
(Get-Content -path $SETTINGS_FILE -Raw) -replace 'ARTIFACTORY_API_KEY', $ARTIFACTORY_API_KEY | Out-File -FilePath $SETTINGS_FILE
[Console]::WriteLine("Bien hecho!")
Read-Host  "presiona ENTER para finalizar..."
Start-Process "microsoft-edge:https://globaldevtools.bbva.com/bitbucket/projects/WJEEW/repos/wjeew_datio_developer_cert_exercises/browse"
