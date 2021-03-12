[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# CONSTANTS
$scriptVersion = "0.2.1"
$mavenVersion = "3.6.3"
$intellijVersion = "2020.3.2"
$gitVersion = "2.30.2"
$sublimeTextVersion = "3211"
${browser} = "microsoft-edge"
$configFileName = "ambientacion.config"
$mavenSettingsFileName = "settings.xml"
$intellijConfigFileName = "silent-intellij.config"
$intellijFileName = "ideaIC-$intellijVersion.exe"
$gitFileName = "Git-$gitVersion-64-bit.exe"
$winUtilsFileName = "winutils.exe"
$mavenFileName = "apache-maven-$mavenVersion-bin.zip"
$sublimeTextFileName = "Sublime Text Build $sublimeTextVersion x64 Setup.exe"
$githubRepository = "dagarciam/ambientacion-datio/"
$binSufix = "bin\"
$resources = "resources"
$bbvaUserNameString = "BBVA_USERNAME"
$artifactoryAPIKeyString = "ARTIFACTORY_API_KEY"
$javaHomeString = "JAVA_HOME"
$hadoopHomeString = "HADOOP_HOME"
$m2HomeString = "M2_HOME"
$pathString = "PATH"

# URLS
$oraclejdkuri = 'https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html'
$githubRaw = "https://raw.github.com/"
$githubWinutils = "https://github.com/steveloughran/winutils/raw/master/hadoop-2.7.1/bin/winutils.exe"
$githubConfigFile = "$githubRaw$githubRepository$scriptVersion/$resources/$configFileName"
$githubSettingsFile = "$githubRaw$githubRepository$scriptVersion/$resources/$mavenSettingsFileName"
$githubIntellijConfigFile = "$githubRaw$githubRepository$scriptVersion/$resources/$intellijConfigFileName"
$intellijUrl = "https://download.jetbrains.com/idea/$intellijFileName"
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v$gitVersion.windows.2/$gitFileName"
$mavenUrl = "https://downloads.apache.org/maven/maven-3/$mavenVersion/binaries/$mavenFileName"
$sublimeTextUrl = "https://download.sublimetext.com/$sublimeTextFileName"
$globalDevToolsUrl = "https://globaldevtools.bbva.com/"
$artifactoryProfileUril = "${globalDevToolsUrl}artifactory/webapp/#/profile"
$bitbucketKeysUrl = "${globalDevToolsUrl}bitbucket/plugins/servlet/ssh/account/keys"
$bitbucketProcessingRepository = "${globalDevToolsUrl}/bitbucket/projects/WJEEW/repos/wjeew_datio_developer_cert_exercises/browse"

# PATHS
$mavenHome = "C:\maven\"
$hadoopHome = "C:\hadoop\"
$downloadPath = "${env:USERPROFILE}\Downloads\"
$rsaKeyFileName = "${env:USERPROFILE}/.ssh/id_rsa"
$rsaKeyPubFileName = "$rsaKeyFileName.pub"
$mavenUserPath = "${env:USERPROFILE}\.m2\"
$hadoopBinPath = "$hadoopHome$binSufix"
$configFileDowloadPath = "$downloadPath$configFileName"
$mavenDownloadSettingsPath = "$mavenUserPath$mavenSettingsFileName"
$gitDownloadPath = "$downloadPath$gitFileName"
$intellijDownloadConfigPath = "$downloadPath$intellijConfigFileName"
$hadoopDownloadPath = "$hadoopBinPath$winUtilsFileName"
$mavenDownloadPath = "$downloadPath$mavenFileName"
$sublimeTextDownloadPath = "$downloadPath$sublimeTextFileName"

# SETTINGS
[bool]$installJDK=0
[bool]$installHadoop=0
[bool]$installMaven=0
[bool]$installGit=0
[bool]$installIntellij=0
[bool]$installSublimeText=0

$wc = New-Object net.webclient
$wc.Downloadfile($githubConfigFile, $configFileDowloadPath)
Start-Process notepad $configFileDowloadPath -Wait

(Get-Content $configFileDowloadPath).split([Environment]::NewLine) | ForEach-Object { 
    If ($_ -imatch "INSTALL_JDK=(.*)"){If($Matches[1] = "TRUE"){$installJDK = 1}}
    If ($_ -imatch "INSTALL_HADOOP_WINUTILS=(.*)"){If($Matches[1] = "TRUE"){$installHadoop = 1}}
    If ($_ -imatch "INSTALL_MAVEN=(.*)"){If($Matches[1] = "TRUE"){$installMaven = 1}}
    If ($_ -imatch "INSTALL_GIT=(.*)"){If($Matches[1] = "TRUE"){$installGit = 1}}
    If ($_ -imatch "INSTALL_INTELLIJ=(.*)"){If($Matches[1] = "TRUE"){$installIntellij = 1}}
    If ($_ -imatch "INSTALL_SUBLIME_TEXT=(.*)"){If($Matches[1] = "TRUE"){$installSublimeText = 1}}
}

# UPDATE ENV VAR Function
Function updateEnviromentVar($envVar, $newValue) {
    $oldValue = [System.Environment]::GetEnvironmentVariable($envVar)
    $path = [System.Environment]::GetEnvironmentVariable($pathString)
    $newPath = ""
    If($oldValue){
        If(Read-Host "Desea actualizar la variable JAVA_HOME de '$oldValue' a '$newValue' ? (s/n)" == "s"){
            $path.Split(";") | ForEach-Object {
                If($_ -imatch "$oldValue$binSufix"){
                    $newPath = "$newPath%$envVar%$binSufix;"
                }Else{
                    $newPath = "$newPath$_;"
                }
            }
            [System.Environment]::SetEnvironmentVariable($envVar,$newValue,[System.EnvironmentVariableTarget]::User)
            [System.Environment]::SetEnvironmentVariable($pathString,$newPath,[System.EnvironmentVariableTarget]::User)
        }
    }Else{
        [System.Environment]::SetEnvironmentVariable($envVar,$newValue,[System.EnvironmentVariableTarget]::User)
        [System.Environment]::SetEnvironmentVariable($pathString,"$path%$envVar%$binSufix;",[System.EnvironmentVariableTarget]::User)
    }   
}

# JDK
If($installJDK){
    $raw = (Invoke-WebRequest -Uri $oraclejdkuri -UseBasicParsing).RawContent
    $jdkFileName =  $raw.Split([Environment]::NewLine) | ForEach-Object { If ($_ -imatch "data-file='.*(jdk-.*-windows-x64.exe)'"){ $Matches[1] } }
    $jdkVersion =  $raw.Split([Environment]::NewLine) | ForEach-Object { If ($_ -imatch "data-file='.*jdk-8u(.*)-windows-x64.exe'"){ $Matches[1] } }
    $jdkDownloadPath = "$downloadPAth$jdkFileName"
    $javaHome = "C:\Program Files\Java\jdk1.8.0_$jdkVersion\"
    [Console]::WriteLine("Descarga el archivo $jdkFileName en el directorio: $jdkDownloadPath")
    [Console]::WriteLine("Deberas aceptar los terminos y condiciones de uso además de iniciar sesión con una cuenta Oracle (si no la tienes puedes crear una).")
    Read-Host "Presiona ENTER Para comenzar"
    Start-Process "${browser}:$oraclejdkuri"
    Read-Host 'Cuando la descarga haya concluido presiona ENTER'
    Start-Process -Wait -FilePath $jdkDownloadPath -ArgumentList "/s" -PassThru
    updateEnviromentVar($javaHomeString, $javaHome)   
}

# HADOOP
If($installHadoop){
    New-Item -ItemType Directory -Force -Path $hadoopBinPath
    $wc.Downloadfile($githubWinutils, $hadoopDownloadPath)
    updateEnviromentVar($hadoopHomeString, $hadoopHome)
}

# MAVEN
If($installMaven){
    Start-Process "${browser}:$globalDevToolsUrl"
    [Console]::WriteLine("Inicia sesión en el navegador con las credenciales de tu cuenta bbva")
    Read-Host 'Cuando lo hayas hecho presiona ENTER...'
    Start-Process "${browser}:$artifactoryProfileUril"
    $artifactoryAPIKey = Read-Host 'API-KEY'
    $contractorEmail = Read-Host 'Correo BBVA (ejemplo-> danieladan.garcia.contractor@bbva.com)'
    New-Item -ItemType Directory -Force -Path $mavenHome
    New-Item -ItemType Directory -Force -Path $mavenUserPath
    $wc.Downloadfile($mavenUrl, $mavenDownloadPath)
    Add-Type -assembly "system.io.compression.filesystem"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($mavenDownloadPath, $mavenHome)
    $wc.Downloadfile($githubSettingsFile, $mavenDownloadSettingsPath)
    (Get-Content -path $mavenDownloadSettingsPath -Raw) -replace $bbvaUserNameString, ($contractorEmail.Split("@")[0]) | Out-File -FilePath $mavenDownloadSettingsPath
    (Get-Content -path $mavenDownloadSettingsPath -Raw) -replace $artifactoryAPIKeyString, $artifactoryAPIKey | Out-File -FilePath $mavenDownloadSettingsPath
    updateEnviromentVar($m2HomeString,$mavenHome)
}

# GIT
If($installGit){
    $wc.Downloadfile($gitUrl, $gitDownloadPath)
    Start-Process -Wait -FilePath $gitDownloadPath -ArgumentList "/SILENT" -PassThru
}

# INTELLIJ
If($installIntellij){
    $wc.Downloadfile($intellijUrl, $intellijDownloadPath)
    $wc.Downloadfile($githubIntellijConfigFile, $intellijDownloadConfigPath)
    Start-Process -Wait -FilePath $intellijDownloadPath -ArgumentList "/S /CONFIG=$intellijDownloadConfigPath" -PassThru
}

# SUBLIMETEXT
If($installSublimeText){
    $wc.Downloadfile($sublimeTextUrl, $sublimeTextDownloadPath)
    Start-Process -Wait -FilePath $sublimeTextDownloadPath -ArgumentList "/VERYSILENT /NORESTART /TASKS=contextentry" -PassThru
}

# RSA KEYS
if (Test-Path $rsaKeyPubFileName) {
    If(Read-Host "El archivo $rsaKeyPubFileName existe desea sobreescribirlo? (s/n)" == "s"){
        Remove-Item $rsaKeyFileName
        Remove-Item $rsaKeyPubFileName
        ssh-keygen -t rsa -m pem -C $contractorEmail -f $rsaKeyFileName -q -N """"
    }
}Else{
    ssh-keygen -t rsa -m pem -C $contractorEmail -f $rsaKeyFileName -q -N """"
}

Get-Content $rsaKeyPubFileName
Start-Process "${browser}:$bitbucketKeysUrl"
Read-Host  "Agrega la llave, cuando lo hayas hecho presiona ENTER..."
[Console]::WriteLine("Bien hecho!")
Read-Host  "presiona ENTER para finalizar..."
Start-Process "${browser}:$bitbucketProcessingRepository"
