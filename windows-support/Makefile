all: dist/innosetup/vagrant-spk-setup.exe

wine: /usr/bin/wine
	sudo apt-get install wine:i386

state:
	mkdir -p

state/wineprefix:
	mkdir -p state/wineprefix
	WINEPREFIX=$$PWD/state/wineprefix WINEARCH=win32 wine wineboot

vendor:
	mkdir -p vendor

vendor/python.msi: vendor | state/wineprefix
	wget https://www.python.org/ftp/python/2.7.10/python-2.7.10.msi -O vendor/python.msi
	touch vendor/python.msi

vendor/python.msi.installed: | vendor/python.msi
	cp vendor/python.msi vendor/python-tmp.msi
	WINEPREFIX=$$PWD/state/wineprefix WINEARCH=win32 wine msiexec /i vendor/python-tmp.msi
	touch vendor/python.msi.installed

state/wineprefix/drive_c/Python27/Scripts/pyinstaller.exe: | vendor/python.msi.installed vendor/pywin32.exe.installed
	WINEPREFIX=$$PWD/state/wineprefix WINEARCH=win32 wine 'c:/python27/python.exe' -m pip install pyinstaller

vendor/pywin32.exe: | vendor
	wget http://iweb.dl.sourceforge.net/project/pywin32/pywin32/Build%20219/pywin32-219.win32-py2.7.exe -O vendor/pywin32.exe

vendor/pywin32.exe.installed: | vendor/pywin32.exe
	WINEPREFIX=$$PWD/state/wineprefix WINEARCH=win32 wine vendor/pywin32.exe
	touch vendor/pywin32.exe.installed

dist/vagrant-spk.exe: ../vagrant-spk | state/wineprefix/drive_c/Python27/Scripts/pyinstaller.exe
	WINEPREFIX=$$PWD/state/wineprefix WINEARCH=win32 wine c:/python27/Scripts/pyinstaller -F ../vagrant-spk

vendor/innosetup.exe: | vendor
	wget 'http://www.jrsoftware.org/download.php/is.exe?site=1' -O vendor/innosetup.exe

vendor/innosetup.exe.installed: | state/wineprefix vendor/innosetup.exe
	WINEPREFIX=$$PWD/state/wineprefix WINEARCH=win32 wine vendor/innosetup.exe
	touch vendor/innosetup.exe.installed

dist/innosetup/vagrant-spk-setup.exe: dist/vagrant-spk.exe | vendor/innosetup.exe.installed
	WINEPREFIX=$$PWD/state/wineprefix WINEARCH=win32 wine 'c:/program files/inno setup 5/iscc.exe' windows-installer.iss

vendor/msysgit.7z:
	wget https://github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20150319/PortableGit-1.9.5-preview20150319.7z -O vendor/msysgit.7z

vendor/msysgit/bin:
	mkdir -p vendor/msysgit
	(cd vendor/msysgit ; 7z e -aoa ../msysgit.7z)
