@echo off
chcp 65001 >nul
title 局域网文件服务器启动器
color 0B
cls
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo     局域网文件服务器启动器
echo ========================================
echo.
echo 请确保本目录包含 index.html 和你要发布的文件
echo.
echo 正在检查 Python 环境...
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未找到 Python，请先安装 Python
    echo 下载地址：https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo Python 环境正常
echo.
echo 获取本机局域网 IP...
set "LAN_IP="
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /C:"IPv4" /C:"IPv4 地址"') do (
    set "line=%%A"
    set "line=!line: =!"
    if not defined LAN_IP set "LAN_IP=!line!"
)
if not defined LAN_IP (
    for /f "tokens=2 delims=[]" %%A in ('ping -n 1 %computername% ^| find "Pinging"') do set "LAN_IP=%%A"
)

if defined LAN_IP (
    echo 本机局域网地址: !LAN_IP!
) else (
    echo 未能自动获取局域网地址，请手动使用 ipconfig 查找 IPv4 地址
)
echo.
echo 启动 HTTP 服务器（端口 8000）...
echo.
if defined LAN_IP (
    echo 其他局域网设备可访问: http://!LAN_IP!:8000
)
echo 本机访问: http://127.0.0.1:8000
echo.
start http://127.0.0.1:8000
echo.
python -m http.server 8000 --bind 0.0.0.0
echo.
echo 服务器已停止
echo 按任意键退出
pause