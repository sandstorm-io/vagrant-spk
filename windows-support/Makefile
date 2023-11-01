all: dist/innosetup/vagrant-spk-setup.exe

WINE := wine
WINEARGS := WINEDEBUG=-all WINEPREFIX=$$PWD/state/wineprefix

clean:
	rm -f dist/innosetup/vagrant-spk-setup.exe

distclean:
	rm -rf state build vendor dist ../build ../dist vagrant-spk.spec

wine: /usr/bin/wine
	sudo apt-get install wine wine32

vendor:
	mkdir -p vendor

state:
	mkdir -p state

vendor/python.exe: | vendor state/wineprefix
	wget https://www.python.org/ftp/python/3.11.6/python-3.11.6.exe -O vendor/python.exe
	touch vendor/python.exe

vendor/python.exe.installed: | vendor/python.exe
	cp vendor/python.exe vendor/python-tmp.exe
	$(WINEARGS) $(WINE) vendor/python-tmp.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 AssociateFiles=0 Shortcuts=0
	touch vendor/python.exe.installed

state/pyinstaller.installed: | vendor/python.exe.installed
	$(WINEARGS) $(WINE) 'c:/Program Files (x86)/Python311-32/python.exe' -m pip install pyinstaller
	touch state/pyinstaller.installed

dist/vagrant-spk.exe: ../vagrant-spk | state/pyinstaller.installed
	$(WINEARGS) $(WINE) 'c:/Program Files (x86)/Python311-32/Scripts/pyinstaller.exe' -F ../vagrant-spk

vendor/innosetup.exe: | vendor
	wget 'http://www.jrsoftware.org/download.php/is.exe?site=1' -O vendor/innosetup.exe

vendor/innosetup.exe.installed: | state/wineprefix vendor/innosetup.exe
	$(WINEARGS) $(WINE) vendor/innosetup.exe /SP- /VERYSILENT /SUPPRESSMSGBOXES /ALLUSERS /NOICONS
	touch vendor/innosetup.exe.installed

state/version.iss: ../vagrant-spk
	../vagrant-spk --version | sed -e 's,vagrant-spk ,,' | xargs printf '#define MyAppVersion "%s"\n' > state/version.iss

dist/innosetup/vagrant-spk-setup.exe: dist/vagrant-spk.exe | vendor/innosetup.exe.installed state/version.iss
	# Some WINE installs are seemingly 64-bit but install InnoSetup to Program Files, not
	# Program Files (x86). We work around this with a symlink.
	if [ ! -d 'state/wineprefix/drive_c/Program Files (x86)' ] ; then ln -s 'Program Files' 'state/wineprefix/drive_c/Program Files (x86)' ; fi
	$(WINEARGS) $(WINE) 'c:/program files (x86)/inno setup 6/iscc.exe' windows-installer.iss

state/regdata: | state
	printf 'Windows Registry Editor Version 5.00\n\n[HKEY_CURRENT_USER\\Software\\Wine\\WineDbg]\n"ShowCrashDialog"=dword:00000000\n\n[HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows NT\\CurrentVersion]\n"CurrentVersion"="10.0"\n\n' > state/regdata

state/wineprefix: state/regdata
	mkdir -p state/wineprefix
	$(WINEARGS) $(WINE) wineboot
	$(WINEARGS) $(WINE) regedit /S state/regdata
	touch state/wineprefix
