# Script Ambientación DATIO v0.2.1 para Windows 10

## ¿Qué hace este Script?
* Descarga de **Apache Hadoop winutils** en el directorio `C:\hadoop\bin\winutils.exe`
* Descarga de **Apache Maven 3.6.3** en el directorio `C:\maven\`
* Instalación de **GIT 2.30.0.2**
* Ayuda para la descarga e Instalación de **JDK 8uXXX** (desde Oracle)
* Instalación de **IntelliJ Idea Community Edition 2020.3.2**
* Instalación de **Sublime Text build 3211**
* Seteo de variables de entorno `JAVA_HOME`, `HADOOP_HOME`, `M2_HOME` y modificación de la variable `PATH`
* Auxilio en la creación de llave pública `~\.ssh\id_rsa.pub` para conexión a **Bitbucket**
* Auxilio en la Creación de archivo `~\.m2\settings.xml` para conexión a **Artifactory**

## Requisitos
* Cuenta BBVA
* Windows 10
* Microsoft Edge

## Ejecución
1. Abrir PowerShell con permisos de Administrador
2. Habilitar la ejecución de Scripts ejecutando el siguiente comando 
```powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```
3. Ejecutar el script
```powershell
.\ambientacion.ps1
```
4. Edite el archivo de texto colocando TRUE o FALSE a los pasos que desea ejecutar por ejemplo para omitir la instalación de HADOOP WINUTILS y GIT el archivo deberá verse así: 
```
INSTALL_JDK=TRUE
INSTALL_HADOOP_WINUTILS=FALSE
INSTALL_MAVEN=TRUE
INSTALL_GIT=FALSE
INSTALL_INTELLIJ=TRUE
INSTALL_SUBLIME=TRUE
```
5. A lo largo del proceso esté atento a la consola, le solicitará información y le indicará los pasos que debe realizar de forma manual.