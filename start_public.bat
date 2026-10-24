@echo off
chcp 65001 >nul
title Raspisanie server
cd /d "%~dp0"
set PORT=8765
if not exist cloudflared.exe (
  echo  File cloudflared.exe not found next to this file.
  pause
  goto :eof
)
taskkill /im cloudflared.exe /f >nul 2>&1
timeout /t 2 /nobreak >nul
del tunnel.log >nul 2>&1
start "Tunnel (do not close)" /min cloudflared.exe tunnel --protocol http2 --edge-ip-version 4 --logfile tunnel.log --url http://localhost:%PORT%
echo.
echo  Waiting for public link, up to a minute...
powershell -NoProfile -Command "$u=$null; for($i=0;$i -lt 60 -and -not $u;$i++){Start-Sleep 1; try{$t=Get-Content tunnel.log -Raw -ErrorAction Stop; if($t -match 'https://[a-z0-9-]+\.trycloudflare\.com'){$u=$Matches[0]}}catch{}}; if($u){$l=$u+'/index.html'; Set-Clipboard $l; Write-Host ''; Write-Host '  PUBLIC LINK (already copied to clipboard, just paste it):'; Write-Host ('  '+$l) -ForegroundColor Green}else{Write-Host '  Link not found. Check tunnel.log'}"
echo.
echo  Local link for the hall: http://localhost:%PORT%/index.html
echo  Leave this window open.
echo.
where python >nul 2>&1 && (python -m http.server %PORT% --bind 0.0.0.0) || (py -m http.server %PORT% --bind 0.0.0.0)
taskkill /im cloudflared.exe /f >nul 2>&1
pause
