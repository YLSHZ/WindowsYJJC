@echo off
chcp 65001 >nul
title 电脑硬件信息查看工具 - 完整显示版
color 0B
cls
setlocal EnableDelayedExpansion

echo.
echo  ===================================================================
echo              电脑硬件信息查看工具 - 完整显示版
echo  ===================================================================
echo                检测时间: %date% %time:~0,8%
echo                计算机名: %COMPUTERNAME%
echo                用户名:   %USERNAME%
echo.

:: ===================================================================
:: CPU 信息
:: ===================================================================
echo  ===================================================================
echo    [ CPU 处理器信息 ]
echo  ===================================================================
echo.
for /f "tokens=2 delims==" %%a in ('wmic cpu get Name /value 2^>nul ^| find "Name="') do echo    处理器型号:      %%a
for /f "tokens=2 delims==" %%a in ('wmic cpu get Description /value 2^>nul ^| find "Description="') do echo    描述:            %%a
for /f "tokens=2 delims==" %%a in ('wmic cpu get Manufacturer /value 2^>nul ^| find "Manufacturer="') do echo    制造商:          %%a
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfCores /value 2^>nul ^| find "NumberOfCores="') do echo    物理核心数:      %%a 核
for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfLogicalProcessors /value 2^>nul ^| find "NumberOfLogicalProcessors="') do echo    逻辑处理器数:    %%a 线程
for /f "tokens=2 delims==" %%a in ('wmic cpu get MaxClockSpeed /value 2^>nul ^| find "MaxClockSpeed="') do echo    最大频率:        %%a MHz
for /f "tokens=2 delims==" %%a in ('wmic cpu get CurrentClockSpeed /value 2^>nul ^| find "CurrentClockSpeed="') do echo    当前频率:        %%a MHz
for /f "tokens=2 delims==" %%a in ('wmic cpu get L2CacheSize /value 2^>nul ^| find "L2CacheSize="') do echo    L2 缓存:         %%a KB
for /f "tokens=2 delims==" %%a in ('wmic cpu get L3CacheSize /value 2^>nul ^| find "L3CacheSize="') do echo    L3 缓存:         %%a KB
for /f "tokens=2 delims==" %%a in ('wmic cpu get SocketDesignation /value 2^>nul ^| find "SocketDesignation="') do echo    插槽:            %%a
for /f "tokens=2 delims==" %%a in ('wmic cpu get Status /value 2^>nul ^| find "Status="') do echo    状态:            %%a
echo.

:: ===================================================================
:: 显卡信息 - 使用更可靠的方式
:: ===================================================================
echo  ===================================================================
echo    [ 显卡信息 ]
echo  ===================================================================
echo.
echo    检测到的显卡:
echo    ----------------------------------------------------------------
wmic path win32_videocontroller get Name /format:list 2>nul | find "="
echo.
echo    显卡制造商:
echo    ----------------------------------------------------------------
wmic path win32_videocontroller get AdapterCompatibility /format:list 2>nul | find "="
echo.
echo    显存大小:
echo    ----------------------------------------------------------------
wmic path win32_videocontroller get AdapterRAM /format:list 2>nul | find "="
echo.
echo    视频处理器:
echo    ----------------------------------------------------------------
wmic path win32_videocontroller get VideoProcessor /format:list 2>nul | find "="
echo.
echo    驱动版本:
echo    ----------------------------------------------------------------
wmic path win32_videocontroller get DriverVersion /format:list 2>nul | find "="
echo.
echo    分辨率:
echo    ----------------------------------------------------------------
wmic path win32_videocontroller get CurrentHorizontalResolution /format:list 2>nul | find "="
wmic path win32_videocontroller get CurrentVerticalResolution /format:list 2>nul | find "="
echo.

:: ===================================================================
:: 内存信息
:: ===================================================================
echo  ===================================================================
echo    [ 内存信息 ]
echo  ===================================================================
echo.
echo    内存条详情:
echo    ----------------------------------------------------------------
wmic memorychip get Capacity,Speed,Manufacturer,PartNumber /format:table 2>nul
echo.
echo    内存总计:
echo    ----------------------------------------------------------------
wmic computersystem get TotalPhysicalMemory /format:list 2>nul | find "="
wmic os get FreePhysicalMemory /format:list 2>nul | find "="
echo.

:: ===================================================================
:: 磁盘信息
:: ===================================================================
echo  ===================================================================
echo    [ 磁盘信息 ]
echo  ===================================================================
echo.
echo    逻辑磁盘详情:
echo    ----------------------------------------------------------------
for /f "skip=1 tokens=1,2,3,4" %%a in ('wmic logicaldisk where DriveType^=3 get DeviceID^,FileSystem^,Size^,FreeSpace 2^>nul') do (
    if "%%a"=="" goto :DiskSkip
    if "%%a"=="DeviceID" goto :DiskSkip
    echo.
    echo    磁盘 %%a\
    echo      文件系统:  %%b
    set "size=%%c"
    set "free=%%d"
    set "size=!size: =!"
    set "free=!free: =!"
    if defined size (
        set /a sizeGB=!size:~0,-9! 2>nul
        if not defined sizeGB set sizeGB=0
        if !sizeGB! GTR 0 (
            echo      总容量:    !sizeGB! GB
        ) else (
            set /a sizeMB=!size! / 1024 / 1024 2>nul
            echo      总容量:    !sizeMB! MB
        )
    )
    if defined free (
        set /a freeGB=!free:~0,-9! 2>nul
        if not defined freeGB set freeGB=0
        if !freeGB! GTR 0 (
            echo      可用空间:  !freeGB! GB
        ) else (
            set /a freeMB=!free! / 1024 / 1024 2>nul
            echo      可用空间:  !freeMB! MB
        )
    )
    if defined size if defined free (
        set /a usedGB=!sizeGB!-!freeGB! 2>nul
        if not defined usedGB set usedGB=0
        if !usedGB! GTR 0 (
            echo      已用空间:  !usedGB! GB
            set /a pct=!usedGB!*100/!sizeGB! 2>nul
            echo      使用率:    !pct! %%
        ) else (
            set /a usedMB=!sizeMB!-!freeMB! 2>nul
            if !usedMB! GTR 0 (
                echo      已用空间:  !usedMB! MB
                set /a pct=!usedMB!*100/!sizeMB! 2>nul
                echo      使用率:    !pct! %%
            )
        )
    )
)
:DiskSkip
echo.
echo    ----------------------------------------------------------------
echo    物理磁盘:
echo    ----------------------------------------------------------------
wmic diskdrive get Model,Size,InterfaceType,Status /format:table 2>nul
echo.

:: ===================================================================
:: 主板信息
:: ===================================================================
echo  ===================================================================
echo    [ 主板信息 ]
echo  ===================================================================
echo.
echo    主板:
echo    ----------------------------------------------------------------
wmic baseboard get Manufacturer,Product,Version,SerialNumber /format:list 2>nul | find "="
echo.
echo    BIOS:
echo    ----------------------------------------------------------------
wmic bios get Manufacturer,Name,Version,ReleaseDate /format:list 2>nul | find "="
echo.

:: ===================================================================
:: 网络信息
:: ===================================================================
echo  ===================================================================
echo    [ 网络信息 ]
echo  ===================================================================
echo.
echo    系统信息:
echo      计算机名: %COMPUTERNAME%
echo      用户名:   %USERNAME%
echo.
echo    网卡信息:
echo    ----------------------------------------------------------------
wmic nicconfig where IPEnabled=True get Description,MACAddress,IPAddress /format:table 2>nul
echo.

:: ===================================================================
:: 操作系统信息
:: ===================================================================
echo  ===================================================================
echo    [ 操作系统信息 ]
echo  ===================================================================
echo.
wmic os get Caption,Version,OSArchitecture,LastBootUpTime /format:list 2>nul | find "="
echo.

:: ===================================================================
:: 电池信息
:: ===================================================================
echo  ===================================================================
echo    [ 电池信息 ]
echo  ===================================================================
echo.
wmic battery get Name,EstimatedChargeRemaining,BatteryStatus 2>nul | find "=" >nul
if %errorlevel%==0 (
    wmic battery get Name,EstimatedChargeRemaining,BatteryStatus /format:table 2>nul
) else (
    echo    未检测到电池（可能是台式机）
)
echo.

echo  ===================================================================
echo                       检测完成!
echo  ===================================================================
echo.
pause
