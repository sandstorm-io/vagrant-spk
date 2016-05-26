all: dist/innosetup/vagrant-spk-setup.exe

WINE := wine
WINEARGS := WINEDEBUG=-all WINEPREFIX=$$PWD/state/wineprefix

clean:
	rm -f dist/innosetup/vagrant-spk-setup.exe

distclean:
	rm -rf state build vendor dist ../build ../dist vagrant-spk.spec

wine: /usr/bin/wine
	sudo apt-get install wine:i386

vendor:
	mkdir -p vendor

state:
	mkdir -p state

vendor/python.msi: | vendor state/wineprefix
	wget https://www.python.org/ftp/python/2.7.10/python-2.7.10.msi -O vendor/python.msi
	touch vendor/python.msi

vendor/python.msi.installed: | vendor/python.msi
	cp vendor/python.msi vendor/python-tmp.msi
	$(WINEARGS) $(WINE) msiexec /i vendor/python-tmp.msi /qn
	touch vendor/python.msi.installed

state/wineprefix/drive_c/Python27/Scripts/pyinstaller.exe: | vendor/python.msi.installed vendor/pywin32.exe.installed
	$(WINEARGS) $(WINE) 'c:/python27/python.exe' -m pip install pyinstaller==3.1.1

vendor/pywin32.exe: | vendor
	wget http://iweb.dl.sourceforge.net/project/pywin32/pywin32/Build%20219/pywin32-219.win32-py2.7.exe -O vendor/pywin32.exe

vendor/pywin32.exe.installed: | vendor/pywin32.exe
	unzip vendor/pywin32.exe || true
	mv PLATLIB/* SCRIPTS/* state/wineprefix/drive_c/Python27/Lib/site-packages/
	rmdir PLATLIB SCRIPTS
	$(WINEARGS) $(WINE) 'c:/python27/python.exe' state/wineprefix/drive_c/Python27/Lib/site-packages/pywin32_postinstall.py -install
	touch vendor/pywin32.exe.installed

dist/vagrant-spk.exe: ../vagrant-spk | state/wineprefix/drive_c/Python27/Scripts/pyinstaller.exe
	$(WINEARGS) $(WINE) c:/python27/Scripts/pyinstaller -F ../vagrant-spk

vendor/innosetup.exe: | vendor
	wget 'http://www.jrsoftware.org/download.php/is.exe?site=1' -O vendor/innosetup.exe

vendor/innosetup.exe.installed: | state/wineprefix vendor/innosetup.exe
	$(WINEARGS) $(WINE) vendor/innosetup.exe /VERYSILENT
	touch vendor/innosetup.exe.installed

dist/innosetup/vagrant-spk-setup.exe: dist/vagrant-spk.exe | vendor/innosetup.exe.installed vendor/msysgit.7z vendor/msysgit/bin
	# Some WINE installs are seemingly 64-bit but install InnoSetup to Program Files, not
	# Program Files (x86). We work around this with a symlink.
	if [ ! -d 'state/wineprefix/drive_c/Program Files (x86)' ] ; then ln -s 'Program Files' 'state/wineprefix/drive_c/Program Files (x86)' ; fi
	$(WINEARGS) $(WINE) 'c:/program files (x86)/inno setup 5/iscc.exe' windows-installer.iss

vendor/msysgit.7z:
	wget https://github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20150319/PortableGit-1.9.5-preview20150319.7z -O vendor/msysgit.7z

vendor/msysgit/bin:
	mkdir -p vendor/msysgit
	(cd vendor/msysgit ; 7z e -aoa ../msysgit.7z)

state/regdata: | state
	printf '[HKEY_CURRENT_USER\\Software\\Wine\\WineDbg]\n"ShowCrashDialog"=dword:00000000\n' > state/regdata

state/wineprefix: state/regdata
	mkdir -p state/wineprefix
	$(WINEARGS) $(WINE) wineboot
	$(WINEARGS) $(WINE) regedit state/regdata
	touch state/wineprefix
