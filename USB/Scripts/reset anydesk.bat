@echo off
cd %appdata%\anydesk
del ad.trace
cd c:\\programdata\anydesk
del ad_svc.trace
del service.conf
del system.conf
exit