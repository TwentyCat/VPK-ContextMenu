@echo off
title 【20Cat】《VPK极速打包/解包-右键菜单》添加工具         禁止修改二次发布。若需转载请直接转载原压缩包。
mode con cols=110 lines=28

:: 程序准备阶段 ----------------------------------------------------------------------------------------------------
:: 检查管理员权限
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
 
if '%errorlevel%' NEQ '0' (
	echo.
	echo.
	echo.
    echo 	程序需要权限才能正常使用。请在弹出的『用户账户控制』窗口点击『是』。
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

:: 检查是否已经使用过本工具，并引导用户到卸载流程
REG QUERY HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat 2>NUL
if %errorlevel%==0 goto UnInstall

:: 检查是否已安装 GCFScape 并关联了 VPK 文件
set VPKAssociation_Status=否
for /f "tokens=2*" %%a in ('reg query "%GCFScapeReg%" /v InstallLocation 2^>nul') do set "GCFScapePath=%%b"
set GCFScapePath_1=%GCFScapePath%GCFScape.exe,1

for /f "tokens=2*" %%a in ('reg query "%VPKAssociationReg%" /ve 2^>nul') do set "VPKAssociationReg_1=%%b"
if "%VPKAssociationReg_1%"=="%GCFScapePath_1%" set VPKAssociation_Status=是

:: 检查是否已安装 Left 4 Dead 2 Authoring Tools
REG QUERY "%L4D2ToolsReg%"
if %errorlevel%==1 goto Warning_L4D2Tools

:: 获取 vpk.exe 路径
for /f "tokens=2*" %%a in ('reg query "%L4D2ToolsReg%" /v InstallLocation 2^>nul') do set "L4D2ToolsPath=%%b"
set L4D2Tools="%L4D2ToolsPath%\bin\vpk.exe"
set L4D2App="%L4D2ToolsPath%\left4dead2.exe"

:: 再次检查必须文件是否缺失
if not exist %L4D2Tools% goto Error_L4D2Tools
if not exist %L4D2App% goto Error_L4D2App

:: 介绍
:Introduction
cls
echo.
echo.
echo 	------   欢迎使用由嘤喵废寝忘食、精心开发(划掉)几个晚上的《VPK快速打包/解包工具》  ------
echo.
echo.
echo.
echo 	① 本工具将会在你『文件夹右键菜单』中添加『打包成 VPK 文件』(快捷键Q) 的选项
echo 	② 本工具将会在你『VPK文件右键菜单』中添加『解包该 VPK 文件』(快捷键Q) 的选项
echo.
echo 	③ 支持将选项添加到『文件夹高级右键菜单』，即按住 Shift，再右键文件夹出现的菜单，更加美观简洁
echo 	④ 支持卸载。若需卸载，请再次使用本工具
echo.
echo.
echo.
echo 	【 声明 】请勿单独传播本bat脚本文件，禁止修改二次发布。若需转载，请直接转载原压缩包。
echo 	【 作者Steam主页: https://steamcommunity.com/id/20cat 】
echo.
echo.
echo.
echo 	按任意键继续……
pause>nul

:: 程序准备阶段 ----------------------------------------------------------------------------------------------------



:: 程序安装流程 ----------------------------------------------------------------------------------------------------

:: 询问是否需要 Shift+右键 才出现打包选项？
:Install
set MenuOption=0

cls
echo.
echo.
echo 	VPK 文件已关联 GCFScape：%VPKAssociation_Status%
echo 	当前 VPK 打包工具路径为：%L4D2Tools%
echo.
echo 				↑↑↑  请喵一眼以上信息是否正确  ↑↑↑
echo.
echo.
echo 	本程序将要：
echo.
echo 	- 在文件夹右键菜单添加『打包成 VPK 文件』的选项。
echo 	- 在 VPK 文件右键菜单添加『解包该 VPK 文件』的选项。
echo.
echo 	【  若想要按住 Shift 键右击文件夹才出现选项，请输入『1』回车。否则请直接回车  】
echo.
echo.
echo.
echo.
echo.
if %VPKAssociation_Status%==否 (echo 	【提示】 → 安装完毕后双击 VPK 文件的默认操作是『解包』) else (echo.)
echo.
echo.
echo.
set /p MenuOption=请输入数字（回车不输入表示默认）：
if %MenuOption%==0 goto Add_Normal
if %MenuOption%==1 goto Add_Shift
goto ErrorInput
exit

:: 一、用户选择添加到右键菜单
:Add_Normal
:: 1、在 left4dead2\bin 生成嘤喵自制打包脚本
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

:: 2、添加注册表项
set Icon_Reg=\"%L4D2ToolsPath%\left4dead2.exe\",0
set AdvVPKBat_Reg=\"%L4D2ToolsPath%\bin\vpk_20Cat.bat\" \"%%1\"
set VPK_Reg=\"%L4D2ToolsPath%\bin\vpk.exe\" \"%%1\"

REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /ve /d "打包成 VPK 文件(&Q)"
::REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Extended
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v NoWorkingDirectory
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat\command /ve /d "%AdvVPKBat_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /ve /d "解包该 VPK 文件(&Q)"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat\command /ve /d "%VPK_Reg%"
REG ADD HKEY_CLASSES_ROOT\.vpk /ve /d "VPKFile" /f

if not exist %AdvVPKBatPath% goto ProgramFailed
if %VPKAssociation_Status%==否 goto Success_1_WithoutGCFScape
goto Success_1

:: 二、用户选择添加到Shift右键菜单
:Add_Shift
:: 1、在 left4dead2\bin 生成嘤喵自制打包脚本
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

:: 2、添加注册表项
set Icon_Reg=\"%L4D2ToolsPath%\left4dead2.exe\",0
set AdvVPKBat_Reg=\"%L4D2ToolsPath%\bin\vpk_20Cat.bat\" \"%%1\"
set VPK_Reg=\"%L4D2ToolsPath%\bin\vpk.exe\" \"%%1\"

REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /ve /d "打包成 VPK 文件(&Q)"
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Extended
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v NoWorkingDirectory
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat\command /ve /d "%AdvVPKBat_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /ve /d "解包该 VPK 文件(&Q)"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /v Icon /d "%Icon_Reg%"
REG ADD HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat\command /ve /d "%VPK_Reg%"
REG ADD HKEY_CLASSES_ROOT\.vpk /ve /d "VPKFile" /f

if not exist %AdvVPKBatPath% goto ProgramFailed
if %VPKAssociation_Status%==否 goto Success_2_WithoutGCFScape
goto Success_2

:Success_1
cls
echo.
echo.
echo 	恭喜你，安装完成！
echo.
echo.
echo.
echo 	现在你可以：
echo.
echo 	① 右击『文件夹』，再按下键盘『Q』，即可打包 VPK
echo 	② 右击『vpk 文件』，再按下键盘『Q』，即可解包 VPK
echo.
echo 	PS：同时选中多个『文件夹/VPK』则是批量『打包/解包』
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit

:Success_2
cls
echo.
echo.
echo 	恭喜你，安装完成！
echo.
echo.
echo.
echo 	现在你可以：
echo.
echo 	① 按住 Shift 并右击『文件夹』，再按下键盘『Q』，即可打包 VPK
echo 	② 右击『VPK 文件』，再按下键盘『Q』，即可解包 VPK
echo.
echo 	PS：同时选中多个『文件夹/VPK』则是批量『打包/解包』
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit

:Success_1_WithoutGCFScape
cls
echo.
echo.
echo 	恭喜你，安装完成！
echo.
echo.
echo.
echo 	现在你可以：
echo.
echo 	① 右击『文件夹』，再按下键盘『Q』，即可打包 VPK
echo 	② 右击『vpk 文件』，再按下键盘『Q』，即可解包 VPK
echo 	或者 直接双击『vpk 文件』，也可解包 VPK
echo.
echo.
echo 	PS：同时选中多个『文件夹/VPK』则是批量『打包/解包』
echo.
echo.
echo 	按任意键退出……
pause>nul
exit

:Success_2_WithoutGCFScape
cls
echo.
echo.
echo 	恭喜你，安装完成！
echo.
echo.
echo.
echo 	现在你可以：
echo.
echo 	① 按住 Shift 并右击『文件夹』，再按下键盘『Q』，即可打包 VPK
echo 	② 右击『VPK 文件』，再按下键盘『Q』，即可解包 VPK
echo 	或者 直接双击『vpk 文件』，也可解包 VPK
echo.
echo.
echo 	PS：同时选中多个『文件夹/VPK』则是批量『打包/解包』
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit
:: 程序安装流程 ----------------------------------------------------------------------------------------------------



:: 程序卸载流程 ----------------------------------------------------------------------------------------------------
:UnInstall
cls
echo.
echo.
echo 	检测到你已经安装过，请问是否想要卸载呢？
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	按任意键确认卸载……
pause>nul
goto UnInstall_Confirmed
exit

:: 确认卸载
:UnInstall_Confirmed
for /f "tokens=2*" %%a in ('reg query "%L4D2ToolsReg%" /v InstallLocation 2^>nul') do set "L4D2ToolsPath=%%b"
del /s "%L4D2ToolsPath%\bin\vpk_20Cat.bat"
REG DELETE HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /f
REG DELETE HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /f
cls
echo.
echo.
echo 	卸载完成。
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit
:: 程序卸载流程 ----------------------------------------------------------------------------------------------------



:: 程序出错诊断 ----------------------------------------------------------------------------------------------------

:: 用户输入错误
:ErrorInput
cls
echo.
echo.
echo 	emm……你输错了吧，请重新输入……
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	按任意键返回……
pause>nul
goto Install
exit

:: 提示未安装 L4D2 Authoring Tools
:Warning_L4D2Tools
cls
echo.
echo.
echo 	尚未安装 L4D2 Authoring Tools。
echo.
echo 	请打开 Steam --- (左上角)库 --- (下拉菜单)工具 --- 找到 L4D2 Authoring Tools 并双击安装。
echo.
echo.
echo 	PS：本工具不支持绿色版 VPK 打包工具。
echo.
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit

:: 提示 L4D2 Authoring Tools 程序缺失
:Error_L4D2Tools
cls
echo.
echo.
echo 	L4D2 Authoring Tools 可能已损坏，请重新安装。
echo.
echo 	请打开 Steam --- (左上角)库 --- (下拉菜单)工具 --- 
echo 	找到 L4D2 Authoring Tools --- 右击『卸载』并『重新安装』
echo.
echo.
echo.
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit

:: 提示 L4D2 Authoring Tools 所安装路径可能不是游戏根目录
:Error_L4D2App
cls
echo.
echo.
echo 	找不到游戏主程序，请先安装『求生2』再安装『L4D2 Authoring Tools』
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit

:PermissionFailed
cls
echo.
echo.
echo 	本工具需要『管理员权限』才可正常使用！
echo.
echo 	请『右击』此批处理文件，选择『以管理员身份运行』。
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	按任意键退出……
Rd "%WinDir%\System32\test_permissions" 2>NUL
pause>nul
exit

:ProgramFailed
::撤销更改
for /f "tokens=2*" %%a in ('reg query "%L4D2ToolsReg%" /v InstallLocation 2^>nul') do set "L4D2ToolsPath=%%b"
del /s "%L4D2ToolsPath%\bin\vpk_20Cat.bat"
REG DELETE HKEY_CLASSES_ROOT\Folder\shell\Pack2Vpk_20Cat /f
REG DELETE HKEY_CLASSES_ROOT\VPKFile\shell\UnPackVpk_20Cat /f
cls
echo.
echo.
echo 	程序出 BUG 了，没有成功生成自制打包工具。
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 	按任意键退出……
pause>nul
exit

:: 程序出错诊断 ----------------------------------------------------------------------------------------------------