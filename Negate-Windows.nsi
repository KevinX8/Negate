############################################################################################
#      NSIS Installation Script created by NSIS Quick Setup Script Generator v1.09.18
#               Entirely Edited with NullSoft Scriptable Installation System                
#              by Vlasis K. Barkas aka Red Wine red_wine@freemail.gr Sep 2006               
############################################################################################

!define APP_NAME "Negate"
!define COMP_NAME "KevinX8"
!define WEB_SITE "https://vancedapp.com"
!define VERSION "0.1.0.0"
!define COPYRIGHT "Paulis Gributs    2023"
!define DESCRIPTION "Application"
!define INSTALLER_NAME ".\build\windows\setup.exe"
!define MAIN_APP_EXE "negate.exe"
!define INSTALL_TYPE "SetShellVarContext current"
!define REG_ROOT "HKCU"
!define REG_APP_PATH "Software\Microsoft\Windows\CurrentVersion\App Paths\${MAIN_APP_EXE}"
!define UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}  "

!define REG_START_MENU "Start Menu Folder"

var SM_Folder

######################################################################

VIProductVersion  "${VERSION}"
VIAddVersionKey "ProductName"  "${APP_NAME}"
VIAddVersionKey "CompanyName"  "${COMP_NAME}"
VIAddVersionKey "LegalCopyright"  "${COPYRIGHT}"
VIAddVersionKey "FileDescription"  "${DESCRIPTION}"
VIAddVersionKey "FileVersion"  "${VERSION}"

######################################################################

SetCompressor LZMA
Name "${APP_NAME}"
Caption "${APP_NAME}"
OutFile "${INSTALLER_NAME}"
BrandingText "${APP_NAME}"
XPStyle on
InstallDirRegKey "${REG_ROOT}" "${REG_APP_PATH}" ""
InstallDir "$PROGRAMFILES\Negate"

######################################################################

!include "MUI.nsh"

!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING

!insertmacro MUI_PAGE_WELCOME

!ifdef LICENSE_TXT
!insertmacro MUI_PAGE_LICENSE "${LICENSE_TXT}"
!endif

!insertmacro MUI_PAGE_DIRECTORY

!ifdef REG_START_MENU
!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Negate"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${REG_ROOT}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${UNINSTALL_PATH}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${REG_START_MENU}"
!insertmacro MUI_PAGE_STARTMENU Application $SM_Folder
!endif

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN "$INSTDIR\${MAIN_APP_EXE}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM

!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

######################################################################

Section -MainProgram
${INSTALL_TYPE}
SetOverwrite ifnewer
SetOutPath "$INSTDIR"
File ".\build\windows\runner\Release\bitsdojo_window_windows_plugin.lib"
File ".\build\windows\runner\Release\file_saver_plugin.dll"
File ".\build\windows\runner\Release\url_launcher_windows_plugin.dll"
File ".\build\windows\runner\Release\dynamic_color_plugin.dll"
File ".\build\windows\runner\Release\flutter_windows.dll"
File ".\build\windows\runner\Release\negate.exe"
File ".\build\windows\runner\Release\negate.exp"
File ".\build\windows\runner\Release\negate.lib"
File ".\build\windows\runner\Release\permission_handler_windows_plugin.dll"
File ".\build\windows\runner\Release\sqlite3.dll"
File ".\build\windows\runner\Release\sqlite3_flutter_libs_plugin.dll"
File ".\build\windows\runner\Release\system_tray_plugin.dll"
SetOutPath "$INSTDIR\data"
File ".\build\windows\runner\Release\data\app.so"
File ".\build\windows\runner\Release\data\icudtl.dat"
SetOutPath "$INSTDIR\data\flutter_assets"
File ".\build\windows\runner\Release\data\flutter_assets\AssetManifest.json"
File ".\build\windows\runner\Release\data\flutter_assets\FontManifest.json"
File ".\build\windows\runner\Release\data\flutter_assets\NOTICES.Z"
SetOutPath "$INSTDIR\data\flutter_assets\shaders"
File ".\build\windows\runner\Release\data\flutter_assets\shaders\ink_sparkle.frag"
SetOutPath "$INSTDIR\data\flutter_assets\packages\cupertino_icons\assets"
File ".\build\windows\runner\Release\data\flutter_assets\packages\cupertino_icons\assets\CupertinoIcons.ttf"
SetOutPath "$INSTDIR\data\flutter_assets\fonts"
File ".\build\windows\runner\Release\data\flutter_assets\fonts\MaterialIcons-Regular.otf"
SetOutPath "$INSTDIR\data\flutter_assets\assets"
File ".\build\windows\runner\Release\data\flutter_assets\assets\app_icon.ico"
File ".\build\windows\runner\Release\data\flutter_assets\assets\text_classification.tflite"
File ".\build\windows\runner\Release\data\flutter_assets\assets\text_classification_vocab.txt"
SetOutPath "$INSTDIR\blobs"
File ".\build\windows\runner\Release\blobs\libtensorflowlite_c-win.dll"
SectionEnd

######################################################################

Section -Icons_Reg
SetOutPath "$INSTDIR"
WriteUninstaller "$INSTDIR\uninstall.exe"

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
CreateDirectory "$SMPROGRAMS\$SM_Folder"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$SMPROGRAMS\$SM_Folder\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "Negate" "$INSTDIR\${MAIN_APP_EXE}"

!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!insertmacro MUI_STARTMENU_WRITE_END
!endif

!ifndef REG_START_MENU
CreateDirectory "$SMPROGRAMS\Negate"
CreateShortCut "$SMPROGRAMS\Negate\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${MAIN_APP_EXE}"
CreateShortCut "$SMPROGRAMS\Negate\Uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe"

!ifdef WEB_SITE
WriteIniStr "$INSTDIR\${APP_NAME} website.url" "InternetShortcut" "URL" "${WEB_SITE}"
CreateShortCut "$SMPROGRAMS\Negate\${APP_NAME} Website.lnk" "$INSTDIR\${APP_NAME} website.url"
!endif
!endif

WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayName" "${APP_NAME}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "UninstallString" "$INSTDIR\uninstall.exe"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayIcon" "$INSTDIR\${MAIN_APP_EXE}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "DisplayVersion" "${VERSION}"
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "Publisher" "${COMP_NAME}"

!ifdef WEB_SITE
WriteRegStr ${REG_ROOT} "${UNINSTALL_PATH}"  "URLInfoAbout" "${WEB_SITE}"
!endif
SectionEnd

######################################################################

Section Uninstall
${INSTALL_TYPE}
Delete "$INSTDIR\bitsdojo_window_windows_plugin.lib"
Delete "$INSTDIR\file_saver_plugin.dll"
Delete "$INSTDIR\flutter_windows.dll"
Delete "$INSTDIR\negate.exe"
Delete "$INSTDIR\negate.exp"
Delete "$INSTDIR\negate.lib"
Delete "$INSTDIR\permission_handler_windows_plugin.dll"
Delete "$INSTDIR\sqlite3.dll"
Delete "$INSTDIR\sqlite3_flutter_libs_plugin.dll"
Delete "$INSTDIR\system_tray_plugin.dll"
Delete "$INSTDIR\data\app.so"
Delete "$INSTDIR\data\icudtl.dat"
Delete "$INSTDIR\data\flutter_assets\AssetManifest.json"
Delete "$INSTDIR\data\flutter_assets\FontManifest.json"
Delete "$INSTDIR\data\flutter_assets\NOTICES.Z"
Delete "$INSTDIR\data\flutter_assets\shaders\ink_sparkle.frag"
Delete "$INSTDIR\data\flutter_assets\packages\cupertino_icons\assets\CupertinoIcons.ttf"
Delete "$INSTDIR\data\flutter_assets\fonts\MaterialIcons-Regular.otf"
Delete "$INSTDIR\data\flutter_assets\assets\app_icon.ico"
Delete "$INSTDIR\data\flutter_assets\assets\text_classification.tflite"
Delete "$INSTDIR\data\flutter_assets\assets\text_classification_vocab.txt"
Delete "$INSTDIR\blobs\libtensorflowlite_c-win.dll"
 
RmDir "$INSTDIR\blobs"
RmDir "$INSTDIR\data\flutter_assets\assets"
RmDir "$INSTDIR\data\flutter_assets\fonts"
RmDir "$INSTDIR\data\flutter_assets\packages\cupertino_icons\assets"
RmDir "$INSTDIR\data\flutter_assets\shaders"
RmDir "$INSTDIR\data\flutter_assets"
RmDir "$INSTDIR\data"
 
Delete "$INSTDIR\uninstall.exe"
!ifdef WEB_SITE
Delete "$INSTDIR\${APP_NAME} website.url"
!endif

RmDir "$INSTDIR"

!ifdef REG_START_MENU
!insertmacro MUI_STARTMENU_GETFOLDER "Application" $SM_Folder
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME}.lnk"
Delete "$SMPROGRAMS\$SM_Folder\Uninstall ${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\$SM_Folder\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\$SM_Folder"
!endif

!ifndef REG_START_MENU
Delete "$SMPROGRAMS\Negate\${APP_NAME}.lnk"
Delete "$SMPROGRAMS\Negate\Uninstall ${APP_NAME}.lnk"
!ifdef WEB_SITE
Delete "$SMPROGRAMS\Negate\${APP_NAME} Website.lnk"
!endif
Delete "$DESKTOP\${APP_NAME}.lnk"

RmDir "$SMPROGRAMS\Negate"
!endif

DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "Negate"
SectionEnd

######################################################################

