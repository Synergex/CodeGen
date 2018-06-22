@echo off

setlocal
pushd %~dp0
echo.
echo Uploading MSI to DOWNLOADS.SYNERGEXPSG.COM...
echo open ftp.synergexpsg.com 21> ftp.tmp
echo steve@synergexpsg.com>> ftp.tmp
echo %SYNPSG_FTP_PASSWORD%>> ftp.tmp
echo bin>> ftp.tmp
echo cd /download.synergexpsg.com>> ftp.tmp
echo put Bin\Release\CodeGen.msi>> ftp.tmp
echo bye>> ftp.tmp

ftp -s:ftp.tmp 1>nul

del /q ftp.tmp

echo Upload process complete

popd
endlocal