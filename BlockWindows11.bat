@echo off
setlocal
chcp 65001 > nul


net session >nul 2>&1
if %errorlevel% neq 0 (
	echo Ce script doit être exécuté en tant qu'administrateur.
	pause
	exit /b
)
 

echo Note: Après exécution, vous recevrez encore les mises a jour concernant Windows 10 mais pas celle de Windows 11.
echo Ce fichier intervient au niveau de la base de registre et de l'éditeur de stratégie de groupe locale.
echo.


:consent_1
set /p CONSENT=Etes vous sur de vouloir continuer ? (Y/N): 


if /i "%CONSENT%" == "N" (
	exit
)
if /i not "%CONSENT%" == "Y" (
	goto consent_1
)


for /f "tokens=2 delims==" %%i in ('wmic os get version /value') do set "build=%%i"
for /f "tokens=1 delims=." %%i in ("%build%") do set version=%%i
for /f "tokens=3 delims=." %%i in ("%build%") do set buildNum=%%i


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
	exit
)


set "key=HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
set "value1=ProductVersion"
set "value2=TargetReleaseVersion"
set "value3=TargetReleaseVersionInfo"


echo.
echo Recherche de la clé dans la base de registre...


reg query %key% >nul 2>&1
if %errorlevel% neq 0 (
	echo.
	echo La clé WindowsUpdate n'existe pas. Création en cours...
	reg add %key%
	echo La clé WindowsUpdate a été créée avec succée.
) else (
	echo La clé WindowsUpdate a été trouvée.
)

echo.
echo Recherche des valeurs dans la clé WindowsUpdate dans la base de registre...


reg query %key% /v %value1% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value1% n'existe pas. Création en cours...
	reg add %key% /v %value1% /t REG_SZ /d "Windows 10" /f
	echo La valeur %value1% à été défini sur Windows 10.
) else (
	echo La valeur %value1% existe déjà.
)


reg query %key% /v %value2% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value2% n'existe pas. Création en cours...
	reg add %key% /v %value2% /t REG_DWORD /d 1 /f
	echo La valeur %value2% a été défini sur 1.
) else (
	echo La valeur %value2% existe déjà.
)


reg query %key% /v %value3% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value3% n'existe pas. Création en cours...
	reg add %key% /v %value3% /t REG_SZ /d "%branch%" /f
	echo La valeur %value3% a été défini sur %branch%.
) else (
	echo La valeur %value3% existe déjà.
)


echo.
echo Opérations terminées
echo.
echo Mise a jour des stratégies de groupe locale...
echo.

gpupdate /force >nul 2>&1
if %errorlevel% neq 0 (
	echo La mise à jour des stratégies de groupe locale à échoué.
) else (
	echo La mise a jour des stratégies de groupe locale à réussi.
)
echo.
echo.

echo Si vous n'avez constaté aucune erreur veuillez redémarrer votre PC pour que les changements prennent effet
echo sinon ce n'est pas nécéssaire.
echo.


endlocal
pause






