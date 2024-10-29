@echo off
setlocal
chcp 65001 > nul






:: Vérifie si le script est exécuté en tant qu'administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
	echo Ce script doit être exécuté en tant qu'administrateur.
	pause
	exit /b
)






:: credits
echo #####################
echo ## Auteur: Artax01 ##
echo #####################
echo. 





:: notes
echo ########################################################################################################################
echo ## - Note: Après exécution, vous recevrez encore les mises a jour concernant Windows 10 mais pas celle de Windows 11. ##
echo ## - Ce fichier intervient au niveau de la base de registre et du dossier stockant les mises à jour de Windows.       ##
echo ## - Votre ordinateur redémarrera à la fin de l'exécution du script.                                                  ##
echo ########################################################################################################################
echo.






:consent
set /p CONSENT=Etes vous sur de vouloir continuer ? (Y/N): 


if /i "%CONSENT%" == "N" (
	exit /b
)
if /i not "%CONSENT%" == "Y" (
	goto consent
)


:: Récupération de la version de windows
for /f "tokens=2 delims==" %%i in ('wmic os get version /value') do set "build=%%i"
for /f "tokens=1 delims=." %%i in ("%build%") do set version=%%i
for /f "tokens=3 delims=." %%i in ("%build%") do set buildNum=%%i


:: Vérification de la version de windows
if %version% == 10 (
	if %buildNum% == 18362 (set branch=19H1)
	if %buildNum% == 18363 (set branch=19H2)
	if %buildNum% == 19041 (set branch=20H1)
	if %buildNum% == 19042 (set branch=20H2)
	if %buildNum% == 19043 (set branch=21H1)
	if %buildNum% == 19044 (set branch=21H2)
	if %buildNum% == 19045 (set branch=22H2)
) else (
	echo.
	echo Seulement Windows 10 est supporté.
	pause
	exit /b
)






:: Emplacement des clés et valeurs à créer
set "key=HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
set "value1=ProductVersion"
set "value2=TargetReleaseVersion"
set "value3=TargetReleaseVersionInfo"


echo.
echo Recherche de la clé WindowsUpdate dans la base de registre...


:: Vérification de l'existence de la clé WindowsUpdate dans la base de registre
reg query %key% >nul 2>&1
if %errorlevel% neq 0 (
	echo La clé WindowsUpdate n'existe pas. Création en cours...
	reg add %key%
	echo La clé WindowsUpdate a été créée avec succée.
) else (
	echo La clé WindowsUpdate existe déjà et a été trouvée.
)






echo.
echo Recherche des valeurs dans la clé WindowsUpdate dans la base de registre...


:: Vérification de l'existence de la valeur %value1% dans la clé WindowsUpdate dans la base de registre
reg query %key% /v %value1% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value1% n'existe pas. Création en cours...
	reg add %key% /v %value1% /t REG_SZ /d "Windows 10" /f
	echo La valeur %value1% à été défini sur Windows 10.
) else (
	echo La valeur %value1% existe déjà.
)


:: Vérification de l'existence de la valeur %value2% dans la clé WindowsUpdate dans la base de registre
reg query %key% /v %value2% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value2% n'existe pas. Création en cours...
	reg add %key% /v %value2% /t REG_DWORD /d 1 /f
	echo La valeur %value2% a été défini sur 1.
) else (
	echo La valeur %value2% existe déjà.
)


:: Vérification de l'existence de la valeur %value3% dans la clé WindowsUpdate dans la base de registre
reg query %key% /v %value3% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value3% n'existe pas. Création en cours...
	reg add %key% /v %value3% /t REG_SZ /d "%branch%" /f
	echo La valeur %value3% a été défini sur %branch%.
) else (
	echo La valeur %value3% existe déjà.
)






set "key2=HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
set "value4=NoAutoUpdate"


echo.
echo Recherche de la clé AU dans la base de registre...


reg query %key2% >nul 2>&1
if %errorlevel% neq 0 (
	echo La clé AU n'existe pas. Création en cours...
	reg add %key2%
	echo La clé AU a été créée avec succée.
) else (
	echo La clé AU existe déjà et a été trouvée.
)






:: Vérification de l'existence de la valeur %value4% dans la clé AU dans la base de registre
reg query %key2% /v %value4% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value4% n'existe pas. Création en cours...
	reg add %key2% /v %value4% /t REG_DWORD /d 1 /f
	echo La valeur %value4% à été défini sur 1.
) else (
	echo La valeur %value4% existe déjà.
)






:: suppression du contenu du dossier des mises à jour windows
echo.
echo suppression du contenu du dossier des mises à jour windows
echo Emplacement: "C:\Windows\SoftwareDistribution\Download\"
C:
cd "C:\Windows\SoftwareDistribution\Download\"
del * /F /S /Q






echo.
echo.
echo Opérations terminées
echo.
echo.


echo Votre ordinateur va redémarrer dans 10 secondes...
shutdown /r /t 10 /c "Redémmarage dans 10 secondes de l'ordinateur pour prendre en compte les changements."






endlocal
pause






