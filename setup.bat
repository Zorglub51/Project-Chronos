@echo off
SET full=[31m
SET p1=[31m
SET p2=[31m
SET p5=[31m
SET p6=[31m
SET p7=[31m
SET p8=[31m
SET p9=[31m
SET p10=[31m
SET TFTP_status=[31m
GOTO check

 
:menu
cls
echo ===================================================================================
echo =                        PCE / TG16 / CGFX Mini tools                             =
echo ===================================================================================
echo =                                                                                 =
echo =   %TFTP_status%Console in recovery (TFTP)[0m                                                    =
echo =   %full%Full Dump[0m                                                                     =
echo =   Partitions dumped : %p1%1[0m %p2%2[0m %p5%5[0m %p6%6[0m %p7%7[0m %p8%8[0m %p9%9[0m %p10%10[0m                                          =
echo =                                                                                 =
echo =      1 - Check USB installation             5 - Restore kernel partition        =
echo =      2 - Enter recovery mode                6 - Restore saves partition         =
echo =      3 - Backup nand and partitions         7 - Restore filesystem partition    =
echo =      4 - Extract files from backup          8 - Restore games partition         =
echo =                                                                                 =
echo =      9 - Inject USB hack                    0 - Exit                            =
echo =                                                                                 =
echo ===================================================================================
echo.
SET /P M=Type command number then press ENTER : 
echo.
IF %M%==1 GOTO check
IF %M%==2 GOTO recovery
IF %M%==3 GOTO backup
IF %M%==4 GOTO extract
IF %M%==5 GOTO restore_kernel
IF %M%==6 GOTO restore_saves
IF %M%==7 GOTO restore_fs
IF %M%==8 GOTO restore_games
IF %M%==9 GOTO inject_hack
IF %M%==0 GOTO end

REM --------------------------------------------------------- CHECK ---------------------------------------------------------
:check
if not exist "BACKUP" mkdir "BACKUP"
if exist "BACKUP\full_nand.bin" (
    for %%A in ("BACKUP\full_nand.bin") do if %%~zA==3909091328 (SET full=[32m) else (SET full=[33m)
) else (SET full=[31m)
if exist "BACKUP\mmcblk0p1" (
    for %%A in ("BACKUP\mmcblk0p1") do if %%~zA==689963008 (SET p1=[32m) else (SET p1=[33m)
) else (SET p1=[31m)
if exist "BACKUP\mmcblk0p2" (
    for %%A in ("BACKUP\mmcblk0p2") do if %%~zA==8388608 (SET p2=[32m) else (SET p2=[33m)
) else (SET p2=[31m)
if exist "BACKUP\mmcblk0p5" (
    for %%A in ("BACKUP\mmcblk0p5") do if %%~zA==2097152 (SET p5=[32m) else (SET p5=[33m)
) else (SET p5=[31m)
if exist "BACKUP\mmcblk0p6" (
    for %%A in ("BACKUP\mmcblk0p6") do if %%~zA==8388608 (SET p6=[32m) else (SET p6=[33m)
) else (SET p6=[31m)
if exist "BACKUP\mmcblk0p7" (
    for %%A in ("BACKUP\mmcblk0p7") do if %%~zA==104857600 (SET p7=[32m) else (SET p7=[33m)
) else (SET p7=[31m)
if exist "BACKUP\mmcblk0p8" (
    for %%A in ("BACKUP\mmcblk0p8") do if %%~zA==704643072 (SET p8=[32m) else (SET p8=[33m)
) else (SET p8=[31m)
if exist "BACKUP\mmcblk0p9" (
    for %%A in ("BACKUP\mmcblk0p9") do if %%~zA==2348810240 (SET p9=[32m) else (SET p9=[33m)
) else (SET p9=[31m)
if exist "BACKUP\mmcblk0p10" (
    for %%A in ("BACKUP\mmcblk0p10") do if %%~zA==4194304 (SET p10=[32m) else (SET p10=[33m)
) else (SET p10=[31m)

REM update TFTP connection status
tools\nand_dump.exe test | findstr /C:"OK"
if %ERRORLEVEL% EQU 0 (
    set TFTP_status=[32m
    
) else (
    set TFTP_status=[31m
)
DEL tmp.txt
GOTO menu

REM --------------------------------------------------------- RECOVERY ---------------------------------------------------------
:recovery
tools\fel4pce.exe
tools\sunxi-fel.exe -v -p write 0x2000 tools\fes1.bin 
tools\sunxi-fel.exe -v -p exe 0x2000
tools\sunxi-fel.exe -v -p write 0x43800000 tools\boot.img.tftp.cpio.xz
tools\sunxi-fel.exe -v -p write 0x47000000 tools\uboot.bin
tools\sunxi-fel.exe -v -p exe 0x47000000
echo Waiting for reboot.
timeout /t 20
GOTO check

REM --------------------------------------------------------- INJECT HACK ---------------------------------------------------------
:inject_hack
if %TFTP_status%==[32m (
    tools\nand_dump.exe restore 6 USB_partitions\mmcblk0p6.mod
    tools\nand_dump.exe restore 7 USB_partitions\mmcblk0p7.mod
) else (
    echo.
    echo Start recovery mode first
    echo.
    pause
) 
GOTO check

REM --------------------------------------------------------- BACKUP ---------------------------------------------------------
:backup
if %TFTP_status%==[32m (
    tools\nand_dump.exe full
    move tools\full_nand.bin BACKUP\
    tools\nand_dump.exe split
    move tools\mmcblk0p1 BACKUP\
    move tools\mmcblk0p2 BACKUP\
    move tools\mmcblk0p5 BACKUP\
    move tools\mmcblk0p6 BACKUP\
    move tools\mmcblk0p7 BACKUP\
    move tools\mmcblk0p8 BACKUP\
    move tools\mmcblk0p9 BACKUP\
    move tools\mmcblk0p10 BACKUP\
) else (
    echo.
    echo Start recovery mode first
    echo.
    pause
)
GOTO check

REM --------------------------------------------------------- RESTORE KERNEL ---------------------------------------------------------
:restore_kernel
if %p6%==[32m (
    if %TFTP_status%==[32m (
        tools\nand_dump.exe restore 6 BACKUP\mmcblk0p6
    ) else (
        echo.
        echo Start recovery mode first
        echo.
        pause
    )
) else (
    echo.
    echo Kernel partition not found : BACKUP\mmcblk0p6
    echo.
    pause
)
GOTO check

REM --------------------------------------------------------- RESTORE SAVES ---------------------------------------------------------
:restore_saves
if %p8%==[32m (
    if %TFTP_status%==[32m (
        tools\nand_dump.exe restore 8 BACKUP\mmcblk0p8
    ) else (
        echo.
        echo Start recovery mode first
        echo.
        pause
    )
) else (
    echo.
    echo Saves partition not found : BACKUP\mmcblk0p8
    echo.
    pause
)
GOTO check

REM --------------------------------------------------------- RESTORE LINUX ---------------------------------------------------------
:restore_fs
if %p7%==[32m (
    if %TFTP_status%==[32m (
        tools\nand_dump.exe restore 7 BACKUP\mmcblk0p7
    ) else (
        echo.
        echo Start recovery mode first
        echo.
        pause
    )
) else (
    echo.
    echo Linux partition not found : BACKUP\mmcblk0p7
    echo.
    pause
)
GOTO check

REM --------------------------------------------------------- RESTORE GAMES ---------------------------------------------------------
:restore_games
if %p9%==[32m (
    if %TFTP_status%==[32m (
        tools\nand_dump.exe restore 9 BACKUP\mmcblk0p9
    ) else (
        echo.
        echo Start recovery mode first
        echo.
        pause
    )
) else (
    echo.
    echo Games partition not found : BACKUP\mmcblk0p9
    echo.
    pause
)
GOTO check

REM --------------------------------------------------------- EXTRACT FILES ---------------------------------------------------------
:extract
if exist "BACKUP\mmcblk0p8" if exist exist "BACKUP\mmcblk0p9" (
    tools\nand_dump.exe extract BACKUP\mmcblk0p8 game\save
    tools\nand_dump.exe extract BACKUP\mmcblk0p9 game
    tools\mabt\MArchiveBatchTool.exe archive extract --codec zstd --seed 8!7ZZnJAr/wfc --keyLength 64 game\alldata.bin game
    DEL game\alldata.bin
    DEL game\alldata.psb.m
    DEL game\alldata.psb
    GOTO check
)
    echo.
    echo Games or saves partition not found : BACKUP\mmcblk0p9, BACKUP\mmcblk0p8
    echo Execute backup first
    pause
GOTO check

REM --------------------------------------------------------- EXIT ---------------------------------------------------------
:end

