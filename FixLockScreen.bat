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

echo #################################################################################################################
echo ## Note: Ce script supprime seulement le lien vers le fond d'écran Région Normandie mais il reste présent dans ##
echo ## les fichiers à l'emplacement "C:\Windows\Intune\Lockscreen.jpg"                                             ##
echo #################################################################################################################
echo.

echo ###############################################################
echo ## Ce script supprime deux valeurs dans la base de registre: ##
echo ## - LockScreenImagePath                                     ##
echo ## - LockScreenImageUrl                                      ##
echo ###############################################################
echo.






:consent
set /p CONSENT=Etes vous sur de vouloir continuer ? (Y/N): 


if /i "%CONSENT%" == "N" (
	exit /b
)
if /i not "%CONSENT%" == "Y" (
	goto consent
)





:: Emplacement des valeurs à supprimer
set "key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
set "keyName=PersonalizationCSP"
set "value1=LockScreenImagePath"
set "value2=LockScreenImageUrl"


echo.
echo Recherche de la clé %keyName% dans la base de registre...

:: Vérification de l'existence de la clé %keyName% dans la base de registre
reg query %key% >nul 2>&1
if %errorlevel% neq 0 (
	echo La clé %keyName% n'existe pas. 
	echo Sortie du script en cours...
	pause
	exit /b
) else (
	echo La clé %keyName% existe déjà et a été trouvée.
)






echo.
echo Recherche des valeurs dans la clé %keyName% dans la base de registre...

:: Vérification de l'existence de la valeur %value1% dans la clé %keyName% dans la base de registre
reg query %key% /v %value1% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value1% n'existe pas et ne peut donc pas être supprimée.
) else (
	echo La valeur %value1% existe déjà et vas être supprimer.
	reg delete %key% /v %value1% /f
	echo La valeur %value1% a correctement été supprimé.
	echo Création en cours de la valeur %value1% avec la nouvelle valeur...
	reg add %key% /v %value1% /f
	echo La valeur %value1% a été créée avec succès.
)


:: Vérification de l'existence de la valeur %value2% dans la clé %keyName% dans la base de registre
reg query %key% /v %value2% >nul 2>&1
if %errorlevel% neq 0 (
	echo La valeur %value2% n'existe pas et ne peut donc pas être supprimée.
	pause
	exit /b
) else (
	echo La valeur %value2% existe déjà et vas être supprimer.
	reg delete %key% /v %value2% /f
	echo La valeur %value2% a correctement été supprimé.
	echo Création en cours de la valeur %value2% avec la nouvelle valeur...
	reg add %key% /v %value2% /f
	echo La valeur %value2% a été créée avec succès.
)





echo.
echo.
echo Opérations terminées.
echo.
echo.

echo.
echo Vous pouvez vérifier si cela à fonctionner en appuyant sur les touches windows+L
echo.






:: end
endlocal
pause
