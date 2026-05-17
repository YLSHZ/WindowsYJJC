@echo off
chcp 65001 >nul
echo ========================================
echo     本地文件服务器启动器
echo ========================================
echo.
echo 正在检查Python环境...

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：未找到Python，请先安装Python
    echo 下载地址：https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo Python环境正常
echo.
echo 启动HTTP服务器（端口8000）...
echo.
echo 访问方式：
echo   - 在浏览器中打开：http://127.0.0.1:8000
echo   - 或直接点击下面的链接：
echo.
start http://127.0.0.1:8000

echo.
python -m http.server 8000
echo.
echo 服务器已停止
echo 按任意键退出
pause