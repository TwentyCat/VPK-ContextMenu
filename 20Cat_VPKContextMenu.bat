@echo off
title ��20Cat����VPK���ٴ��/���-�Ҽ��˵�����ӹ���         ��ֹ�޸Ķ��η���������ת����ֱ��ת��ԭѹ������
mode con cols=110 lines=28

:: ����׼���׶� ----------------------------------------------------------------------------------------------------
:: ������ԱȨ��
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
 
if '%errorlevel%' NEQ '0' (
	echo.
	echo.
	echo.
    echo 	������ҪȨ�޲�������ʹ�á����ڵ����ġ��û��˻����ơ����ڵ�����ǡ���
    goto UACPrompt
) else ( goto gotAdmin )
 
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
 
    "%temp%\getadmin.vbs"
    exit /B
 
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"

Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(goto PermissionFailed)
Rd "%WinDir%\System32\test_permissions" 2>NUL
goto Preparing

:Preparing
set GCFScapeReg=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GCFScape_is1
set L4D2ToolsReg=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 563
set VPKAssociationReg=HKEY_CLASSES_ROOT\VPKFile\DefaultIcon

:: ����Ƿ��Ѿ�ʹ�ù������ߣ��������û���ж������
REG QUERY HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat 2>NUL
if %errorlevel%==0 goto UnInstall

:: ����Ƿ��Ѱ�װ GCFScape �������� VPK �ļ�
set VPKAssociation_Status=��
for /f "tokens=2*" %%a in ('reg query "%GCFScapeReg%" /v InstallLocation 2^>nul') do set "GCFScapePath=%%b"
set GCFScapePath_1=%GCFScapePath%GCFScape.exe,1

for /f "tokens=2*" %%a in ('reg query "%VPKAssociationReg%" /ve 2^>nul') do set "VPKAssociationReg_1=%%b"
if "%VPKAssociationReg_1%"=="%GCFScapePath_1%" set VPKAssociation_Status=��

:: ����Ƿ��Ѱ�װ Left 4 Dead 2 Authoring Tools
REG QUERY "%L4D2ToolsReg%"
if %errorlevel%==1 goto Warning_L4D2Tools

:: ��ȡ vpk.exe ·��
for /f "tokens=2*" %%a in ('reg query "%L4D2ToolsReg%" /v InstallLocation 2^>nul') do set "L4D2ToolsPath=%%b"
set L4D2Tools="%L4D2ToolsPath%\bin\vpk.exe"
set L4D2App="%L4D2ToolsPath%\left4dead2.exe"

:: �ٴμ������ļ��Ƿ�ȱʧ
if not exist %L4D2Tools% goto Error_L4D2Tools
if not exist %L4D2App% goto Error_L4D2App

:: ����
:Introduction
cls
echo.
echo.
echo 	------   ��ӭʹ��������������ʳ�����Ŀ���(����)�������ϵġ�VPK���ٴ��/������ߡ�  ------
echo.
echo.
echo.
echo 	�� �����߽������㡺�ļ����Ҽ��˵�������ӡ������ VPK �ļ���(��ݼ�Q) ��ѡ��
echo 	�� �����߽������㡺VPK�ļ��Ҽ��˵�������ӡ������ VPK �ļ���(��ݼ�Q) ��ѡ��
echo.
echo 	�� ֧�ֽ�ѡ����ӵ����ļ��и߼��Ҽ��˵���������ס Shift�����Ҽ��ļ��г��ֵĲ˵����������ۼ��
echo 	�� ֧��ж�ء�����ж�أ����ٴ�ʹ�ñ�����
echo.
echo.
echo.
echo 	�� ���� �����𵥶�������bat�ű��ļ�����ֹ�޸Ķ��η���������ת�أ���ֱ��ת��ԭѹ������
echo 	�� ����Steam��ҳ: https://steamcommunity.com/id/20cat ��
echo.
echo.
echo.
echo 	���������������
pause>nul

:: ����׼���׶� ----------------------------------------------------------------------------------------------------



:: ����װ���� ----------------------------------------------------------------------------------------------------

:: ѯ���Ƿ���Ҫ Shift+�Ҽ� �ų��ִ��ѡ�
:Install
set MenuOption=0

cls
echo.
echo.
echo 	VPK �ļ��ѹ��� GCFScape��%VPKAssociation_Status%
echo 	��ǰ VPK �������·��Ϊ��%L4D2Tools%
echo.
echo 				������  ����һ��������Ϣ�Ƿ���ȷ  ������
echo.
echo.
echo 	������Ҫ��
echo.
echo 	- ���ļ����Ҽ��˵���ӡ������ VPK �ļ�����ѡ�
echo 	- �� VPK �ļ��Ҽ��˵���ӡ������ VPK �ļ�����ѡ�
echo.
echo 	��  ����Ҫ��ס Shift ���һ��ļ��вų���ѡ������롺1���س���������ֱ�ӻس�  ��
echo.
echo.
echo.
echo.
echo.
if %VPKAssociation_Status%==�� (echo 	����ʾ�� �� ��װ��Ϻ�˫�� VPK �ļ���Ĭ�ϲ����ǡ������) else (echo.)
echo.
echo.
echo.
set /p MenuOption=���������֣��س��������ʾĬ�ϣ���
if %MenuOption%==0 goto Add_Normal
if %MenuOption%==1 goto Add_Shift
goto ErrorInput
exit

:: һ���û�ѡ����ӵ��Ҽ��˵�
:Add_Normal
:: 1���� left4dead2\bin �����������ƴ���ű�
set AdvVPKBatPath="%L4D2ToolsPath%\bin\vpk_20Cat.bat"
if exist %AdvVPKBatPath% (del /q %AdvVPKBatPath%)

set Line0=^@echo off
set Line1=set INPUT=%%1
set Line2=set NAME="%%~d1%%~p1%%~n1.vpk"
set Line3=set NAME1="%%~n1.vpk"
set Line4=set PRODIR=%L4D2Tools%
set Line5=%%PRODIR%% %%INPUT%%
set Line6=rename %%NAME%% %%NAME1%%

echo %Line0%>>%AdvVPKBatPath%
echo %Line1%>>%AdvVPKBatPath%
echo %Line2%>>%AdvVPKBatPath%
echo %Line3%>>%AdvVPKBatPath%
echo %Line4%>>%AdvVPKBatPath%
echo %Line5%>>%AdvVPKBatPath%
echo %Line6%>>%AdvVPKBatPath%

:: 2�����ע�����
set Icon_Reg=\"%L4D2ToolsPath%\left4dead2.exe\",0
set AdvVPKBat_Reg=\"%L4D2ToolsPath%\bin\vpk_20Cat.bat\" \"%%1\"
set VPK_Reg=\"%L4D2ToolsPath%\bin\vpk.exe\" \"%%1\"

REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /ve /d "����� VPK �ļ�(&Q)"
::REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Extended
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v NoWorkingDirectory
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat\command /ve /d "%AdvVPKBat_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /ve /d "����� VPK �ļ�(&Q)"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat\command /ve /d "%VPK_Reg%"
REG ADD HKEY_CLASSES_ROOT\.vpk /ve /d "VPKFile" /f

if not exist %AdvVPKBatPath% goto ProgramFailed
if %VPKAssociation_Status%==�� goto Success_1_WithoutGCFScape
goto Success_1

:: �����û�ѡ����ӵ�Shift�Ҽ��˵�
:Add_Shift
:: 1���� left4dead2\bin �����������ƴ���ű�
set AdvVPKBatPath="%L4D2ToolsPath%\bin\vpk_20Cat.bat"
if exist %AdvVPKBatPath% (del /q %AdvVPKBatPath%)

set Line0=^@echo off
set Line1=set INPUT=%%1
set Line2=set NAME="%%~d1%%~p1%%~n1.vpk"
set Line3=set NAME1="%%~n1.vpk"
set Line4=set PRODIR=%L4D2Tools%
set Line5=%%PRODIR%% %%INPUT%%
set Line6=rename %%NAME%% %%NAME1%%

echo %Line0%>>%AdvVPKBatPath%
echo %Line1%>>%AdvVPKBatPath%
echo %Line2%>>%AdvVPKBatPath%
echo %Line3%>>%AdvVPKBatPath%
echo %Line4%>>%AdvVPKBatPath%
echo %Line5%>>%AdvVPKBatPath%
echo %Line6%>>%AdvVPKBatPath%

:: 2�����ע�����
set Icon_Reg=\"%L4D2ToolsPath%\left4dead2.exe\",0
set AdvVPKBat_Reg=\"%L4D2ToolsPath%\bin\vpk_20Cat.bat\" \"%%1\"
set VPK_Reg=\"%L4D2ToolsPath%\bin\vpk.exe\" \"%%1\"

REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /ve /d "����� VPK �ļ�(&Q)"
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Extended
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v NoWorkingDirectory
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat\command /ve /d "%AdvVPKBat_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /ve /d "����� VPK �ļ�(&Q)"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat\command /ve /d "%VPK_Reg%"
REG ADD HKEY_CLASSES_ROOT\.vpk /ve /d "VPKFile" /f

if not exist %AdvVPKBatPath% goto ProgramFailed
if %VPKAssociation_Status%==�� goto Success_2_WithoutGCFScape
goto Success_2

:Success_1
cls
echo.
echo.
echo 	��ϲ�㣬��װ��ɣ�
echo.
echo.
echo.
echo 	��������ԣ�
echo.
echo 	�� �һ����ļ��С����ٰ��¼��̡�Q�������ɴ�� VPK
echo 	�� �һ���vpk �ļ������ٰ��¼��̡�Q�������ɽ�� VPK
echo.
echo 	PS��ͬʱѡ�ж�����ļ���/VPK���������������/�����
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit

:Success_2
cls
echo.
echo.
echo 	��ϲ�㣬��װ��ɣ�
echo.
echo.
echo.
echo 	��������ԣ�
echo.
echo 	�� ��ס Shift ���һ����ļ��С����ٰ��¼��̡�Q�������ɴ�� VPK
echo 	�� �һ���VPK �ļ������ٰ��¼��̡�Q�������ɽ�� VPK
echo.
echo 	PS��ͬʱѡ�ж�����ļ���/VPK���������������/�����
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit

:Success_1_WithoutGCFScape
cls
echo.
echo.
echo 	��ϲ�㣬��װ��ɣ�
echo.
echo.
echo.
echo 	��������ԣ�
echo.
echo 	�� �һ����ļ��С����ٰ��¼��̡�Q�������ɴ�� VPK
echo 	�� �һ���vpk �ļ������ٰ��¼��̡�Q�������ɽ�� VPK
echo 	���� ֱ��˫����vpk �ļ�����Ҳ�ɽ�� VPK
echo.
echo.
echo 	PS��ͬʱѡ�ж�����ļ���/VPK���������������/�����
echo.
echo.
echo 	��������˳�����
pause>nul
exit

:Success_2_WithoutGCFScape
cls
echo.
echo.
echo 	��ϲ�㣬��װ��ɣ�
echo.
echo.
echo.
echo 	��������ԣ�
echo.
echo 	�� ��ס Shift ���һ����ļ��С����ٰ��¼��̡�Q�������ɴ�� VPK
echo 	�� �һ���VPK �ļ������ٰ��¼��̡�Q�������ɽ�� VPK
echo 	���� ֱ��˫����vpk �ļ�����Ҳ�ɽ�� VPK
echo.
echo.
echo 	PS��ͬʱѡ�ж�����ļ���/VPK���������������/�����
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit
:: ����װ���� ----------------------------------------------------------------------------------------------------



:: ����ж������ ----------------------------------------------------------------------------------------------------
:UnInstall
cls
echo.
echo.
echo 	��⵽���Ѿ���װ���������Ƿ���Ҫж���أ�
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	�������ȷ��ж�ء���
pause>nul
goto UnInstall_Confirmed
exit

:: ȷ��ж��
:UnInstall_Confirmed
for /f "tokens=2*" %%a in ('reg query "%L4D2ToolsReg%" /v InstallLocation 2^>nul') do set "L4D2ToolsPath=%%b"
del /s "%L4D2ToolsPath%\bin\vpk_20Cat.bat"
REG DELETE HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /f
REG DELETE HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /f
cls
echo.
echo.
echo 	ж����ɡ�
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit
:: ����ж������ ----------------------------------------------------------------------------------------------------



:: ���������� ----------------------------------------------------------------------------------------------------

:: �û��������
:ErrorInput
cls
echo.
echo.
echo 	emm����������˰ɣ����������롭��
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	����������ء���
pause>nul
goto Install
exit

:: ��ʾδ��װ L4D2 Authoring Tools
:Warning_L4D2Tools
cls
echo.
echo.
echo 	��δ��װ L4D2 Authoring Tools��
echo.
echo 	��� Steam --- (���Ͻ�)�� --- (�����˵�)���� --- �ҵ� L4D2 Authoring Tools ��˫����װ��
echo.
echo.
echo 	PS�������߲�֧����ɫ�� VPK ������ߡ�
echo.
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit

:: ��ʾ L4D2 Authoring Tools ����ȱʧ
:Error_L4D2Tools
cls
echo.
echo.
echo 	L4D2 Authoring Tools �������𻵣������°�װ��
echo.
echo 	��� Steam --- (���Ͻ�)�� --- (�����˵�)���� --- 
echo 	�ҵ� L4D2 Authoring Tools --- �һ���ж�ء��������°�װ��
echo.
echo.
echo.
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit

:: ��ʾ L4D2 Authoring Tools ����װ·�����ܲ�����Ϸ��Ŀ¼
:Error_L4D2App
cls
echo.
echo.
echo 	�Ҳ�����Ϸ���������Ȱ�װ������2���ٰ�װ��L4D2 Authoring Tools��
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit

:PermissionFailed
cls
echo.
echo.
echo 	��������Ҫ������ԱȨ�ޡ��ſ�����ʹ�ã�
echo.
echo 	�롺�һ������������ļ���ѡ���Թ���Ա������С���
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	��������˳�����
Rd "%WinDir%\System32\test_permissions" 2>NUL
pause>nul
exit

:ProgramFailed
::��������
for /f "tokens=2*" %%a in ('reg query "%L4D2ToolsReg%" /v InstallLocation 2^>nul') do set "L4D2ToolsPath=%%b"
del /s "%L4D2ToolsPath%\bin\vpk_20Cat.bat"
REG DELETE HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /f
REG DELETE HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /f
cls
echo.
echo.
echo 	����� BUG �ˣ�û�гɹ��������ƴ�����ߡ�
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	��������˳�����
pause>nul
exit

:: ���������� ----------------------------------------------------------------------------------------------------