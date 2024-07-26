@echo off

REM #############################
REM           GLOBAL
REM #############################

:000
REM (000)
setlocal EnableDelayedExpansion
set "h1=ECHO # __________________________________________________________________________ #"
set "h2=ECHO #                                                                            #"
set "h3=ECHO # **********                                                      ********** #"
set "h4=ECHO # ************************************************************************** #"
goto :001

:001
REM (001)
%h4%
%h4%
%h3%
ECHO # **********    Computer Answers WDS/MDT Script Launcher Tool     ********** #
ECHO # **********                   12/31/2018 by MC                   ********** #
%h3%
%h4%
%h4%
%h1%
%h2%
CHOICE /C yn /N /M " # Would you like to access the Q/A for this script (y/n)?: " 
IF ERRORLEVEL 2 GOTO :003
IF ERRORLEVEL 1 GOTO :002

:002
REM (002)
%h1%
%h2%
ECHO # Q: What even is this?                                                      #
ECHO # A: It's a script installer that does the post configuration settings for   #
ECHO #    the new, faster, more efficient method of deploying Windows for CA.     #
%h2%
pause
%h1%
%h2%
ECHO # Q: What if I don't want to use it?                                         #
ECHO # A: Well, you don't have to. But you also don't have to use toilet paper.   #
ECHO #    It helps make the slow Winstalls over Flash/Zalman drives obsolete.     #
%h2%
pause
%h1%
%h2%
ECHO # Q: Well, it sounds cool... but I'm more of a horse and buggy kind of guy.  #
ECHO # A: No you're not. You and everyone else wants stuff done faster. Not only  #
ECHO #    will this help you help others, but it'll also make you wonder why the  #
ECHO #    hell you still even use flash drives or the slow MediaCreationToolkit.  #
%h2%
pause
%h1%
%h2%
ECHO # Q: Alright, well... what we have works fine already.                       #
ECHO # A: Keep telling yourself that. MDT not only allows you to save customer's  #
ECHO #    Windows installs and data, it can: replace the underlying Windows OS,   #
ECHO #    save any PC data to the network, capture install images, turn physical  #
ECHO #    disk drives into virtual drives/vmdk/vdi's and can also clone them.     #
ECHO #    Basically, it's like vmware, Macrium, PCMover, and WDS had an orgy.     #
ECHO #    Did I mention it can also do Linux/MacOS/iOS when configured right?     #
%h2%
pause
%h1%
%h2%
ECHO # Q: Well, howcome we've never used it or had it before?                     #
ECHO # A: You did. It was freely available as an upgrade for 8 years. I told the  #
ECHO #    previous CIO and senior WDS tech to look into it but it was not done.   #
ECHO #    Not really my fault, but the first wave of benefits have arrived.       #
%h2%
pause
%h1%
%h2%
ECHO # Q: How do we use it then?                                                  #
ECHO # A: If you know how to use the WDS server, then it's literally going to be  #
ECHO #    the same as it's been for a while... but with some graphical and speed  #
ECHO #    updates. I've made a video that describes how to use it if it confuses  #
ECHO #    anyone. There are different things about this, but if you know how to   #
ECHO #    install over the WDS then the process just has more features.           #
%h2%
pause
%h1%
%h2%
ECHO # Q: What does this post-script file do?                                     #
ECHO # A: It's a Q/A, and a huge helping hand that refines what the WDS/MDT does. #
ECHO #    It has the ability to snap in .msi files and operating system updates,  #
ECHO #    without having to rebuild the images. So if a Windows 10 update comes   #
ECHO #    out, then it's just a matter of downloading that image once. Not taking #
ECHO #    weeks to build a capture image. It makes the process far more modular.  #
%h2%
pause
%h1%
%h2%
ECHO # Q: Sounds a little too good to be true...                                  #
ECHO # A: It's not. You just haven't been given all the tools to use this, until  #
ECHO #    now. It'll make your job a lot easier.                                  #
%h2%
pause
%h1%
%h2%
ECHO #    If you have other questions, you know who to ask. Ready to proceed?     #
%h2%
GOTO :003

:003
REM (003)
%h1%
%h2%
ECHO #           Let's begin. This global tree needs script creds set.            #
%h2%
pause
GOTO :004


:004
REM (004)
%h1%
%h2%
ECHO #  Admin Account Selection                                                   #
%h2%
ECHO #       We need elevated privileges in order for the script to work.         #
ECHO #                  That means server admin priviledges.                      #
%h2%
ECHO #            Default MDT Deployment account is "Administrator"               #
GOTO :005


:005
REM (005)
set g1f=
%h1%
%h2%
SET /P gcred= # (Enter for default) or custom admin username: 
IF "%gcred%" == "" (
set g1f=1
) 
IF "%gcred%" == "Administrator" (
set g1f=1
)
IF "%g1f%"=="1" (
set gcred=Administrator
%h1%
%h2%
ECHO #                        Default account selected.                           #
GOTO :006
)
IF NOT "%_1flag%"=="1" (
%h1%
%h2%
ECHO #             This is a non-default account, and might not work.             #
GOTO :006
)

:006
REM (006)
%h1%
%h2%
ECHO #  Admin Password                                                            #
%h2%
ECHO #                 Default MDT admin P/W is "Iloveca123"                      #
%h2%
GOTO :007


:007
REM (007)
set f01=0
SET /P gpass= " # (Enter for default) or custom admin password: "
IF "%gpass%" == "Iloveca123" (
set f01=1
)
IF "%gpass%" == "" (
set f01=1
)
IF "%f01%"=="1" (
set gpass=Iloveca123
%h2%
%h1%
%h2%
ECHO #                        Default password selected.                          #
GOTO :008
)
IF "%gpass%"=="0" (
GOTO :008
)

:008
REM (008)
%h1%
%h2%
ECHO #  Server Path                                                               #
%h2%
ECHO #  1) Albany                                                                 #
ECHO #  2) Clifton Park                                                           #
ECHO #  3) Schenectady                                                            #
ECHO #  4) Bennington VT                                                          #
ECHO #  5) Brooklyn/Greenpoint                                                    #
ECHO #  6) East Village                                                           #
%h1%
%h2%
CHOICE /N /C:123456 /M " # (1-6): "
IF ERRORLEVEL 6 (
SET _d=man
goto :009
)
IF ERRORLEVEL 5 (
SET _d=bk
goto :009
)
IF ERRORLEVEL 4 (
SET _d=vt
goto :009
)
IF ERRORLEVEL 3 (
SET _d=sch
goto :009
)
IF ERRORLEVEL 2 (
SET _d=cp
goto :009
)
IF ERRORLEVEL 1 (
SET _d=alb
goto :009
)
goto :009

:009
REM (009)
%h1%
%h2%
ECHO #  Script Tree Selection                                                     #
%h2%
ECHO #  1) POST-Install [Updates, Apps, Drivers, License Key, Create User / PW]   #
ECHO #  2) LGPO [Import/Export/Configure GPO Templates for Home/Pro/x86/x64]      #
ECHO #  3) DISM/ImageX [Extract WIM files to slipstream new Windows Updates]      #
%h1%
%h2%
CHOICE /N /C:123 /M " # (1-3): 
IF ERRORLEVEL 3 (goto :299)
IF ERRORLEVEL 2 (goto :199)
IF ERRORLEVEL 1 (goto :099)



:099
REM #############################
REM            1-POST
REM #############################
ECHO #############################
ECHO            1-POST
ECHO #############################
goto :100

:100
REM (100)
set 1OS=
set 1x64=
IF %PROCESSOR_ARCHITECTURE% == x86 (IF NOT DEFINED PROCESSOR_ARCHITEW6432 goto :_winver) 
IF NOT %PROCESSOR_ARCHITECTURE% == x86 (
set 1OS=x64
set 1x64= x64
goto :101
)

:101
REM (101)
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "10.0" (
set 1pf=1
goto :102
)
if "%version%" == "6.3" (
set 1pf=2
goto :102
)
if "%version%" == "6.1" (
set 1pf=3
goto :102
)

:102
REM (102)
if 1pf gtr 1 (
set "pmse=Essentials /silent"
goto :103
)
if 1pf == 1 (
set pmse=/silent
goto :103
)

:103
REM (103)
%h1%
%h2%
ECHO #  Apps / Ninite                                                             #
%h2%
CHOICE /C yn /N /M " # Automatically deploy current OS's app template (y/n)? : " 
IF ERRORLEVEL 2 (
%h2%
ECHO #             Applications will not be updated automatically.                #
set pnin=n
GOTO :104
)
IF ERRORLEVEL 1 (
start \\%_d%\ca\NinitePro.exe /select "Chrome" "K-Lite Codecs" "Flash" "Flash (IE)" "Java" "Silverlight" "Air" "Shockwave" "Reader DC" 

"Malwarebytes" "Teamviewer" "7-Zip" %pmse% jobs\%computername%.txt
%h2%
ECHO #      Apps will be automatically installed to the most recent version.      #
set pnin=y
GOTO :104
)


:104
REM (104)
%h1%
%h2%
ECHO #  Drivers / Snappy Driver Installer                                         #
%h2%
CHOICE /C yn /N /M " # Automatically deploy updated drivers (y/n)? : " 
IF ERRORLEVEL 2 (
%h2%
ECHO #                    The drivers will not be updated.                        #
set "psdi=n"
GOTO :105
)
IF ERRORLEVEL 1 (
%h2%
ECHO #                 The drivers shall be automatically updated.                #
set "psdi=y"
GOTO :105
)

:105
REM (105)
for /f "tokens=*" %%a in ('dir /b /od "%~dp0SDI_%_xOS%*.exe"') do set "SDIEXE=%%a"
if exist \\%_d%\ca\%SDIEXE% (
 start \\%_d%\ca\%SDIEXE%
 pause
 goto :106
)
if not exist \\%_d%\ca\%SDIEXE% (
%h2%
ECHO #                    Snappy Driver Installer wasn't found.                   #
goto :106
)

:106
REM (106)
%h1%
%h2%
ECHO #  Check Product Key                                                         #
%h2%
ECHO #        Product key may have been skipped during system setup, since        #
ECHO #   MDT may have pulled the license during deployment as it's designed to.   #
%h2%
ECHO #       If it was once upgraded from Windows 7/8.1 to Windows 10, then       #
ECHO #          then the key was definitely used, but let's check anyway.         #
%h2%
:107

:107
REM (107)
if 1pf gtr 1 (
slmgr /xpr
goto :108
)
if 1pf == 1 (
start ms-settings:activation
goto :108
)

:108
REM (108)
CHOICE /C yn /N /M " # Is the Windows license activated (y/n)? "
IF ERRORLEVEL 2 (
set pkey=n
%h2%
ECHO #       You should probably fix that before you call this job complete.      #
%h2%
%h1%
GOTO :109
)
IF ERRORLEVEL 1 (
set pkey=y
GOTO :109
)

:109
REM (109)
%h1%
%h2%
ECHO #  Windows Update                                                            #
%h2%
ECHO #           Although this process may have dynamically installed             #
ECHO #           the most up to date version of the operating system,             #
ECHO #                   it may be missing updates it needs.                      #
%h2%
GOTO :110

:110
REM (110)
%h2%
CHOICE /C yn /N /M " # Would you like to automatically run Windows Update (y/n)? "
IF ERRORLEVEL 2 (
set pupd=n
%h2%
ECHO #                       Windows Update check skipped.                        #
GOTO :111
)
IF ERRORLEVEL 1 (
set pupd=y
%h2%
ECHO #  You're smart, you know the customer would come back upset if you didn't.  #
GOTO :111
)

:111
REM (111)
if 1pf == 1 (
start ms-settings:windowsupdate-action
goto :112
)
if 1pf == 2 (
wuauclt.exe /showcheckforupdates
goto :112
)
if 1pf == 3 (
wuauclt.exe /updatenow
goto :112
)
if not 1pf == 1 if not 1pf == 2 if not 1pf == 3 (
%h1%
%h2%
ECHO #          Unsupported/Non-MDT Installed Operating System Detected           #
GOTO :112
)

:112
REM (112)
%h1%
%h2%
ECHO #  Create Username                                                           #
%h2%
ECHO #                 Create the customer's Windows account                      #
GOTO :113

:113
REM (113)
%h2%
SET /P user= # Username: 
IF "%user%" == "" (
%h2%
ECHO #                  The username can not be left blank.                       #
GOTO :114
) ELSE ( 
%h2%
ECHO # Username has been set as "%user%" . . . 
GOTO :114

:114
REM (114)
CHOICE /C yn /N /M " # Is it spelled correctly (y/n)? "
%h2%
IF ERRORLEVEL 2 (GOTO :1p8a)
IF ERRORLEVEL 1 (
%h2%
ECHO #                         Username confirmed.                                #
%h2%
GOTO :115
)

:115
REM (115)
%h1%
%h2%
ECHO #  Customer's Password                                                       #
%h2%
CHOICE /C yn /N /M " # Set a user password (y/n)? "
IF ERRORLEVEL 2 (
%h1%
%h2%
ECHO #                        User password disabled.                             #
set pass=*n/a*
set _pwflag=0
GOTO :116
)
IF ERRORLEVEL 1 (
%h1%
%h2%
ECHO #                       User password will be set.                           #
set _pwflag=1
GOTO :116
)

:116
REM (116)
%h2%
SET /P _pass= # Enter a password: 
IF "%pass%" == "" (
%h1%
%h2%
ECHO #                 Password flag set, but wasn't entered.                     #
GOTO :117
) ELSE (
%h1%
%h2%
ECHO #                           User password set.                               #
GOTO :117
)

:117
REM (117)
%h1%
%h2%
CHOICE /C yn /N /M " # Confirm that [%user%/%pass%] is correct (y/n) "
IF ERRORLEVEL 2 (
%h1%
%h2%
ECHO #                       Clearing password and flag.                          #
GOTO :118
)
IF ERRORLEVEL 1 (
%h1%
%h2%
ECHO #                        Creating user account now.                          #
%h2%
GOTO :118
)

:118
REM (118)
start \\%_d%\ca\CA-OEM.exe
CHOICE /C br /N /M " # Use the 'B'lue or 'R'ed CA-Theme (B/R)?
IF ERRORLEVEL 2 (
"\\%_d%\ca\Windows OEM Themes Packs\CA Blue.themepack"
goto :119
)
IF ERRORLEVEL 1 (
"\\%_d%\ca\Windows OEM Themes Packs\CA Red.themepack"
goto :119
)

:119
REM (119)
IF NOT %_pwflag% == 1 (
net user /add %_user%
net localgroup administrators /add %_user%
goto :120
)
IF %_pwflag% == 1 (
net user /add %_user% %_pass%
net localgroup administrators /add %_user%
goto :120
)

:120
REM (120)
%h1%
%h2%
ECHO #  Confirmation                                                              #
%h2%
ECHO #  These last couple of steps will finalize settings and generate the final  #
ECHO #                             profile settings.                              #
%h2%
GOTO :121

:121
REM (121)
%h2%
CHOICE /C dha /N /M " # Disable/hide/allow the default admin account (h/d/a)? "
IF ERRORLEVEL 3 (
set _disadmin=Allowed
%h2%
ECHO #    This option will allow the account to remain, and will be seen by the   #
ECHO #    customer, which may or may not be desirable. This will however, allow   #
ECHO #          easier entry into the system should it become compromised.        #
GOTO :122
) 
IF ERRORLEVEL 2 (
set _disadmin=Hidden
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v Administrator /t REG_DWORD /d 0
%h2%
ECHO #               The administrator account has been hidden.                   #
GOTO :122
) 
IF ERRORLEVEL 1 (
net user administrator /active:no
set _disadmin=Disabled
%h2%
ECHO #               The administrator account has been disabled.                 #
GOTO :122
)

:122
REM (122)
%h1%
%h2%
ECHO #  Summary                                                                   #
pause
%h1%
%h2%
ECHO # Post-Install script used with the following credentials                    #
ECHO # [%_d%\ca\postinstall.bat->global.bat]
ECHo # [%gcred%\%gpass%]
%h2%
ECHO # Installed Ninite: [%pnin%]
ECHO # Installed %SDIEXE%: [%psdi%]
ECHO # Windows Activated: [%pkey%]  
ECHO # Windows Updated: [%pupd%] 
%h2%
ECHO # Created the customer's credentials:                                        #
ECHO # [%user%\%pass%]
%h2%
ECHO # Status of the MDT deployment admin account:                                #
ECHO # [%padm%]
%h1%
%h2%
CHOICE /C yn /N /M " # Does all of this look good to you (y/n)? 
IF ERRORLEVEL 2 (
%h1%
%h2%
ECHO #           Press *any* key to reset the post script variables . . .         #
%h1%
%h2%
pause
set "pnin="
set "psdi="
set "pkey="
set "user="
set "pass="
set "padm="
set "pmse="
GOTO :100
)
IF ERRORLEVEL 1 (
%h1%
%h2%
ECHO #   Post Install script complete.                                            #
%h1%
pause
GOTO :123
)

:123
REM (123)
CHOICE /N /C:rx /M " # Return to global config or exit (r/x) ?
IF ERRORLEVEL 2 (goto :exit)
IF ERRORLEVEL 1 (goto :global)

:199
REM #############################
REM           2-LGPO
REM #############################
ECHO #############################
ECHO           2-LGPO
ECHO #############################
goto :200

:200
REM (200)
set lgp1=\ca\lgpo\
set lgp2=\deploy\templates\
goto :201

:201
REM (201)
set _os=
for /f "tokens=4-5 delims=. " %%i in ('ver') do set lgp3=%%i.%%j
if "%lgp3%"=="10.0" (
set _os=Win10
set _startflag=1
goto :202
) 
if "%lgp3%"=="6.3" (
set _os=Win81
set _startflag=1
goto :202
)
if "%lgp3%"=="6.1" (
set _os=Win7
set _startflag=0
goto :202
)
if not "%lgp3%" == "10.0" if not "%lgp3%"=="6.3" if not "%lgp3%"=="6.1"
set _os=ServerXPVista
goto :202
)

:202
REM (202)
set lgp3=%_os%
set lgp4=\\%_d%
set lgp5=%lgp4%%lgp1%
set lgp6=%lgp4%%lgp2%%_os%
%h1%
%h2%
ECHO #   This option is asking whether the local policy has been configured yet.  #
%h2%
CHOICE /N /C:ynu /M " # Is there a currently set GPO (y/n)? [Press "u" if unsure]
IF ERRORLEVEL 3 (goto :203)
IF ERRORLEVEL 2 (goto :204)
IF ERRORLEVEL 1 (goto :205)

:203
REM (203)
if exist %windir%\System32\gpedit.msc (
start gpedit.msc
pause
goto :205
)
if not exist %windir%\system32\gpedit.msc (
goto :204
)

:204
REM (204)
CHOICE /N /C:ynu /M " # Press 'Y' to install gpedit.msc and make policy changes. 'N' to skip
IF ERRORLEVEL 2 (
start %lgp5%gpedit.exe
%h2%
ECHO # Please allow time to install gpedit.msc to change GPO template             # 
%h2%
pause
%h2%
ECHO # Running gpedit.msc to change the GPO template                              # 
%h2%
start gpedit.msc
pause
)
IF ERRORLEVEL 1 (goto :205)

:205
REM (205)
if _startflag == 0 (goto :208)
if _startflag == 1 (goto :206)

:206
REM (206)
set lgp7=Start\start-%_os%.xml
set lgp8=%lgp6%%lgp7%
if not exist %lgp8% (
ECHO # %lgp8% not found. You should export the current layout.
goto :207
)
if exist %lgp8% (
ECHO # %lgp8% was found for the Start/Taskbar layout. 
goto :207
)

:207
REM (207)
CHOICE /N /C:eib /M " # Export/Import/Bypass %lgp8% template (e/i/b)?
IF ERRORLEVEL 3 (
ECHO # Bypassing....
set _startflag=0
goto :208
)
IF ERRORLEVEL 2 (
ECHO # Importing Start Layout                                                     #
call powershell Import-StartLayout -LayoutPath "%lgp8%" -MountPath "%Systemdrive%\."
goto :208
)
IF ERRORLEVEL 1 (
ECHO # Exporting Start Layout                                                     #
call powershell Export-StartLayout -LayoutPath "%lgp6%\%lgp7%" -As xml
goto :208
)

:208
REM (208)
%h1%
%h2%
cd %USERPROFILE%\Desktop
%h2%
ECHO # Setting directory to the current user's desktop                            #
%h2%
xcopy %lgp5%lgpo.exe %USERPROFILE%\Desktop
%h2%
ECHO # Copied lgpo.exe utility to the users desktop                               #
%h2%
CHOICE /N /C:ei /M " # Are you exporting or importing the Local GPO (e/i)?
IF ERRORLEVEL 2 (
lgpo /b %lgp6%
%h2%
ECHO #  Exporting the local group policy                                          #
%h2%
goto :209
)
IF ERRORLEVEL 1 (
lgpo /g %lgp6%
%h2%
ECHO #  Importing the local group policy                                          #
%h2%
goto :209

:209
REM (209)
del %USERPROFILE%\Desktop\lgpo.exe /q
%h2%
ECHO # The local GPO has been copied to %lgp6%
%h2%
%h1%
goto :210

:210
REM (210)
%h2%
CHOICE /N /C:rx /M " Return to main script or exit (r/x)?
IF ERRORLEVEL 2 (goto :exit)
IF ERRORLEVEL 1 (goto :global)

:299
REM #############################
REM           3-DISM
REM #############################
ECHO #############################
ECHO           3-DISM
ECHO #############################
goto :300

:300
REM (300)
set 300a=
set 3007=
set 3008=
set 300x=
set dismn=
%h1%
%h2%
ECHO # DISM Image Selection
%h2%
CHOICE /N /C:A78XN /m " # Select which Windows image(s) [(A)ll/(7)/(8)/10(X)/(N)one]?
IF ERRORLEVEL 5 (
goto :322)
IF ERRORLEVEL 4 (
set 300x=1
goto :x/321)
IF ERRORLEVEL 3 (
set 3008=1
goto :8/320)
IF ERRORLEVEL 2 (
set dism7=1
goto :8/319)
IF ERRORLEVEL 1 (
set 300a=1
goto :all/318)

:300
REM (300)
%h1%
%h2%
ECHO # It is recommended that you use one with good performance, or skip
ECHO # this process altogether and rely on downloading the synchronized
ECHO # updates stored on a cloud drive. To perform the slipstreams on your
ECHO # own, this tool will do the heavy lifting for you. You could also 
ECHO # make task sequences in MDT that install the updates to the images,
ECHO # but this will increase your deployment times and number of reboots.
%h2%
pause
%h2%
ECHO # Designate a workstation to perform DISM extractions & injections.
%h2%
ECHO # Example: (no slashes) "ts1"
%h2%
SET /P dhost= # (Press enter for "%_d%", not ideal): 
%h2%
goto :301

:301
REM (301)
if "%dhost%" == "" ( 
set %dhost% == %_d% 
goto :302
)
if %dhost% == %_d% (goto :302)
if not "%dhost%" == "" if not "%dhost% == %_d% (goto :302)

:302
REM (302)
%h2%
ECHO \\%dhost% will be used, but you may require another set of credentials.
%h2%
%h1%
%h2%
ECHO # The default domain account "Administrator", which is used to install
ECHO # WDS/MDT, may not work on the machine you're targeting unless you used
ECHO # the deployment server to reimage it with the MDT tools. If you have
ECHO # not reinstalled the operating system on the target machine using MDT,
ECHO # do not use the default "Administrator" account, it will not work.
%h2%
CHOICE /N /C:yn /M " Use MDT defaults (y/n)?
if errorlevel 2 ( goto :303 )
if errorlevel 1 ( 
%h2%
set dcred=Administrator
set dpass=Iloveca123
ECHO # Default account used.
%h2%
goto :3 )

:303
REM (303)
%h2%
set /p dcred= " Enter the username: 
%h2%
goto :304

:304
REM (304)
%h2%
set /p dpass= " Enter the password: 
%h2%
goto :305

:305
REM (305)
if "%dcred%" == "" ( 
ECHO Non-default selected, but no username was entered.
%h2%
goto :303
)
if "%dpass%" == "" ( 
ECHO Non-default selected, but no password was entered.
%h2%
goto :304
)
if not "%dcred%" == "" if not "%dpass% == "" (goto :306)

:306
REM (306)
%h1%
%h2%
ECHO Preparing a cmdkey to access \\%dhost%
cmdkey /add:%dhost% /user:%dcred% /pass:%dpass%
%h2%
\\%dhost%
%h2%
goto :307
)

:307
REM (307)
%h1%
%h2%
ECHO # Locate network share in %dhost% that has RWX permissions.
ECHO # There may not be one if you haven't made adjustments for file sharing.
%h2%
ECHO # You can say "Y"es there's a share and enter it, "N"o the share has
ECHO # not been set if you would like to cancel this operation.
%h2%
ECHO #             Powershell access will be an option soon.
%h2%
CHOICE /N /C:yns /M " # Yes/No (y/n)?
IF ERRORLEVEL 2 (goto :309)
IF ERRORLEVEL 1 (goto :3d1i)

:308
REM (308)
%h2%
SET /P dunct= " Enter the share name: 
%h2%
ECHO # Changing directory to the share you've provided.
%h2%
pushd \\%dhost%\%dunct%
%h2%
ECHO # If this command was successful, then you'll see some folders generate. #
md %cd%DISM >nul
set dpath=%cd%DISM
:309

:309
REM (309)
for %%a in (7 8 10) do (
  for /l %%b in (1,1,4) do (
    ECHO Debug: md "%dpath%\%%a\%%a.%%b"
    md "%dpath%\%%a\%%a.%%b" >nul
  )
)
set "d7a=%dpath%\7"
set "d7b=%dpath%\7\7.1"
set "d7c=%dpath%\7\7.2"
set "d7d=%dpath%\7\7.3"
set "d7e=%dpath%\7\7.4"
set "d8a=%dpath%\8"
set "d8b=%dpath%\8\8.1"
set "d8c=%dpath%\8\8.2"
set "d8d=%dpath%\8\8.3"
set "d8e=%dpath%\8\8.4"
set "dxa=%dpath%\10"
set "dxb=%dpath%\10\10.1"
set "dxc=%dpath%\10\10.2"
set "dxd=%dpath%\10\10.3"
set "dxe=%dpath%\10\10.4"
goto :310

:310
REM (310)
if not exist %d7a%.wim (
xcopy %dserv%\7\7.wim %d7a%
)
if not exist %d8a%.wim" (
xcopy %dserv%\8\8.wim %d8a%
)
ECHO %_3dxa%
if not exist %dxa%.wim (
xcopy %dserv%\10\10.wim %dxa%
)
goto :311

:311
REM (311)
if not exist %d7b%\7.1.wim (
Dism /Export-Image /SourceImageFile:%d7a%\7.wim /SourceIndex:1 /DestinationImageFile:%d7b%\7.1.wim
if not exist %d7c%\7.2.wim (
Dism /Export-Image /SourceImageFile:%d7a%\7.wim /SourceIndex:2 /DestinationImageFile:%d7c%\7.2.wim
if not exist %d7d%\7.3.wim (
Dism /Export-Image /SourceImageFile:%d7a%\7.wim /SourceIndex:3 /DestinationImageFile:%d7d%\7.3.wim
if not exist %d7e%\7.4.wim (
Dism /Export-Image /SourceImageFile:%d7a%\7.wim /SourceIndex:4 /DestinationImageFile:%d7e%\7.4.wim
goto :312

:312
REM (312)
if not exist %d8b%\8.1.wim (
Dism /Export-Image /SourceImageFile:%d8a%\8.wim /SourceIndex:1 /DestinationImageFile:%d8b%\8.1.wim
if not exist %d8c%\8.2.wim (
Dism /Export-Image /SourceImageFile:%d8a%\8.wim /SourceIndex:2 /DestinationImageFile:%d8c%\8.2.wim
if not exist %d8d%\8.3.wim (
Dism /Export-Image /SourceImageFile:%d8a%\8.wim /SourceIndex:3 /DestinationImageFile:%d8d%\8.3.wim
if not exist %d8e%\8.4.wim (
Dism /Export-Image /SourceImageFile:%d8a%\8.wim /SourceIndex:4 /DestinationImageFile:%d8e%\8.4.wim
goto :313

:313
REM (313)
if not exist %dxb%\10.1.wim (
Dism /Export-Image /SourceImageFile:%dxa%\10.wim /SourceIndex:1 /DestinationImageFile:%dxb%\10.1.wim
if not exist %dxc%\10.2.wim (
Dism /Export-Image /SourceImageFile:%dxa%\10.wim /SourceIndex:2 /DestinationImageFile:%dxc%\10.2.wim
if not exist %dxd%\10.3.wim (
Dism /Export-Image /SourceImageFile:%dxa%\10.wim /SourceIndex:3 /DestinationImageFile:%dxd%\10.3.wim
if not exist %dxe%\10.4.wim (
Dism /Export-Image /SourceImageFile:%dxa%\10.wim /SourceIndex:4 /DestinationImageFile:%dxe%\10.4.wim
goto :314

:314
REM (314)
set dosx=x86
IF %PROCESSOR_ARCHITECTURE% == x86 (IF NOT DEFINED PROCESSOR_ARCHITEW6432 goto :_3d1g) 
IF %PROCESSOR_ARCHITECTURE% == x64 (
set dosx=x64
goto :316
)

:315
REM (315)
if not exist %dpath%\Dism++%dosx%.exe (
%systemroot%\Program Files\7-Zip\7z.exe x %_d%\ca\dism\dism++.zip -ao %dpath%
start dism++%dosx%.exe
pause
:316

:318
REM (318)
cmd.exe /k "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"
goto :319

:319
if 
imagex.exe /export %d7b%\7.1.wim 1 %d7a%\7.wim “Windows 7 Home (x86)” /compress maximum
imagex.exe /export %d7c%\7.2.wim 1 %d7a%\7.wim “Windows 7 Pro (x86)” /compress maximum
imagex.exe /export %d7d%\7.3.wim 1 %d7a%\7.wim “Windows 7 Home (x64)” /compress maximum
imagex.exe /export %d7e%\7.4.wim 1 %d7a%\7.wim “Windows 7 Pro (x64)” /compress maximum
%h2%
xcopy %d7a%\7.wim %dserv%\7\7.wim /y
ECHO # 7.wim has been copied.
if not disma=1 (goto:319)



:320
imagex.exe /export %d8b%\8.1.wim 1 %d8a%\8.wim “Windows 8 Home (x86)” /compress maximum
imagex.exe /export %d8c%\8.2.wim 1 %d8a%\8.wim “Windows 8 Pro (x86)” /compress maximum
imagex.exe /export %d8d%\8.3.wim 1 %d8a%\8.wim “Windows 8 Home (x64)” /compress maximum
imagex.exe /export %d8e%\8.4.wim 1 %d8a%\8.wim “Windows 8 Pro (x64)” /compress maximum
%h2%
xcopy %d8a%\8.wim %dserv%\8\8.wim /y
ECHO # 8.wim has been copied.
%h2%
goto :3d1i

:321
imagex.exe /export %dxb%\10.1.wim 1 %dxa%\10.wim “Windows 10 Home (x86)” /compress maximum
imagex.exe /export %dxc%\10.2.wim 1 %dxa%\10.wim “Windows 10 Pro (x86)” /compress maximum
imagex.exe /export %dxd%\10.3.wim 1 %dxa%\10.wim “Windows 10 Home (x64)” /compress maximum
imagex.exe /export %dxe%\10.4.wim 1 %dxa%\10.wim “Windows 10 Pro (x64)” /compress maximum
%h2%
xcopy %dxa%\10.wim %dserv%\10\10.wim /y
ECHO # 10.wim has been copied.
%h2%
goto :3d1i

:322
%h2%
CHOICE /N /C:rx /M " Return to main script or exit (r/x)?
IF ERRORLEVEL 2 (goto :323)
IF ERRORLEVEL 1 (goto :global)

:3dend
exit
