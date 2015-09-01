### v0.107 (2015-09-01)
- Add "publish" command, so this can be used with https://apps.sandstorm.io/.
- Fix small bugs:
    - atomically download Sandstorm tar.xz file.
    - remove "wipe" command, since only Drew ever used it.
- LEMP stack fixes:
    - use `mkdir -p` to create sessions directory, to avoid confusing Debian's php package.
- DIY stack fixes:
    - use "-y" in apt-get install examples, to avoid prompting for input.
- Improve debugging:
    - send nginx logs to stderr.
    - stop storing nginx access logs.
- Improve vagrant-spk build process:
    - Use fully-headless Windows package build process.
    - Move stack scripts into their own files for tidiness.

### v0.101 (2015-07-27)
- Create Windows installer; start doing releases.

### v0.100 and earlier
- Change logs were not kept, but you can inspect version history in git.
