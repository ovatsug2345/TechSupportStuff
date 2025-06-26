for /f "tokens=1-2 delims=:" %%a in ('ipconfig^|find "Gateway"') do set ip=%%b
set ip=%ip:~1%
echo %ip%
start http://%ip%
pause