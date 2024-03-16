### v1.2 (2024-03-16)
- Updated base image to Debian Bookworm.
- Configured MySQL stacks to only initialize the database once.
- Removed legacy node6 stack.
- Updated meteor stack to use the latest meteor-spk.

### v1.1.2 (2023-11-01)
- Updated Windows build to Python 3.11.6.
- Updated base image to Debian Bullseye.
- Updated golang stack to use the latest Go.
- Updated node stack to use new installation script.
- Updated uwsgi stack to Python 3.
- Configured stacks with Nginx or MySQL to rotate log files by default. (Thanks @zenhack)
- Fix issue with synced folder which can cause Sandstorm to fail on boot. (Thanks @troyjfarrell)
- Fix issue with upgrading Virtualbox Guest Additions causing startup to hang.
- Fix `upgradevm` command. (Thanks @zenhack)
- Fix link to running server in terminal. (Thanks @zenhack)
- Exclude Vagrant log files in gitignore. (Thanks @zenhack)

### v1.1.1 (2021-04-19)
- Updated Windows build to Python 3.8.9.
- No longer includes ssh.exe in Windows release.

### v1.1 (2021-04-10)
- Upgraded vagrant-spk to Python 3.x. (Thanks @troyjfarrell)
- Upgraded base image to Debian Buster.
- Displays URL of test URL in the CLI. (Thanks @zdb999)
- Blocks client-side third party content by default.
- Fix edge case in packing spk to a different volume. (Thanks @zenhack)
- Various stack upgrades and improvements. (Thanks @zenhack)
- Cleaned up release process significantly. (Thanks @paulproteus and @zenhack)

### v1.0 (2020-02-16)
- Changed vagrant-spk's preferred port to 6090 to avoid conflicting with Sandstorm.
- Added `upgradevm` command to upgrade to latest compatible VM.
- Updated Node stack to Node 10, and fixed legacy Node 6 stack. (Thanks @curbengh)
- Fixed detection of VM configurations that do not work with vagrant-spk.
- Fixed bugs preventing `enter-grain` from working. (Thanks @abliss and @zenhack)
- Fixed bug causing VM to allocate too little RAM on Windows.

### v0.236 (2018-07-08)
- Updated multiple stacks for compatibility with Debian stretch.
- Added `listkeys` command to show which app keys are in your keyring.
- Added ability to check vagrant-spk version with `--version`.
- Fix bug where `curl` cannot be downloaded.
- Fix bug caused by Vagrant version 2.0.3 and later.

### v0.230 (2018-03-17)
- Now using Debian Contrib base image rather than a custom image.
- Fixed various bitrot.
- Other fixes, see git history.

### v0.186 (2016-09-21)
- BUG FIX:
  - All stacks embedding MySQL now use `/var/tmp` for temporary storage. Thanks
    @FiloSottile for reporting a Piwik issue that enabled us to notice this problem
    and fix it for all future packages. Note that newly-created apps in these platform
    stacks (`lemp`, `uwsgi`) will clear the `/var/tmp` directory every time the grain
    starts.

### v0.165 (2016-06-07)
- BUG FIXES:
  - `vagrant-spk enter-grain` was basically 100% broken in v0.164, with some extra breakage on
     Windows. This release fixes that. Huge thanks to @ocdtrekkie for testing, to find the
     bugs.

### v0.164 (2016-05-27)
- New features:
    - Add "vagrant-spk enter-grain" so developers can get a shell within a running grain.
      Thanks @zarvox for extensive review.
- BUG FIXES:
    - Update example to refer to `vm` where necessary. Thanks @pgrm.
    - Update libvirt README to refer to `vm` where necessary. Thanks @techtonik.

### v0.161 (2016-05-02)
- BUG FIX:
    - Fix typo in deprecation warning when running: `vagrant-spk global-status`.
- Usability refinement:
    - Going forward, pipe `curl` output through `cat` so that it is
      more aggressively buffered and Vagrant shows it on one line.
      See: #158

### v0.159 (2016-04-22)
- BUG FIX:
    - "vagrant-spk setupvm" would reliably crash on Windows 10, and
      perhaps other Windows systems. Bug reported by hexx on IRC;
      fixed by Drew Fisher. Thanks to hexx for the report.

### v0.155 (2016-03-28)
- Two big user-facing changes:
    - Vagrant commands operate via "vagrant-spk vm {{commandName}}" now.
      For details: https://groups.google.com/forum/#!msg/sandstorm-dev/cuSNJ3IsP6I/26PzwiX4AgAJ
    - Use a .sandstorm/service-config/ directory for daemon config files,
      rather than asking users to monkey with /etc in a pseudo-deterministic
      fashion.
- Docs improvements: Add a libvirt README to GitHub.
- Usability refinements:
    - Network performance: Use PCNet-Fast III by default for virtual machines.
    - Error handling: exit(1) when specifying no stack to setupvm.
    - Interactive docs: 'vagrant-spk setupvm' now prints a list of known stacks.
    - Error handling: Stop crashing when user forgets filename for 'vagrant-spk publish'.
    - Default 'setup.sh' tells users they might need to re-run 'provision'.
    - Default apt configuration will retry on failure.
    - Provide a .sandstorm/.gitignore to avoid users committing useless cruft.
    - Support 'vagrant-spk keygen -- -q' for use by scripts.
    - Vagrantfile: Stop mounting '/vagrant' - this is a duplicate of /opt/app.
    - Python stack: install git by default, since pip/requirements.txt might need it.
    - Add PHP & sqlite stack, to minimize bloat for PHP apps that don't need MySQL.
    - Use 'rm -f' and 'ln -sf' for idempotence.
    - Set 'gzip off;' by default, to work around a Sandstorm bug that results
      in meaningless gobbledy-gook on error pages.

### v0.139 (2016-01-13)
- New features:
    - Add nodejs stack by @mnutt.
    - Add `vagrant-spk verify` command by @zarvox.
- BUG FIXES:
    - In PHP configuration file, use semicolon as comment marker, not hash sign.
      If you run into PHP errors related to this problem, you may need to
      re-generate your `.sandstorm/*.sh` scripts, and destroy & recreate your
      Vagrant box. Thanks to @ndarilek for finding.

### v0.137 (2015-12-16)
- BREAKING CHANGE: Every Sandstorm app MUST change one line in `.sandstorm/Vagrantfile`.
    - **Change required**: Every app must edit `.sandstorm/Vagrantfile`. Find the line containing:
        - `config.vm.box = "debian/jessie64"` and replace it with
        - `config.vm.box = "sandstorm/debian-jessie64"`
    - Problem: Debian's official Vagrant base box (aka `debian/jessie64`) has stopped
      supporting VirtualBox file sharing. Specifically, version 8.2.2 of their base box
      made this change. This will result in sadness for `vagrant-spk` users: anyone who
      runs `vagrant-spk up` on a new system will get version 8.2.2 of the `debian/jessie64`
      base box, resulting in non-working VirtualBox file sharing, resulting in apps that
      fail to build. If you've run `vagrant box update`, you may have also downloaded version
      8.2.2 of `debian/jessie64`, triggering the problem.
    - Solution: Sandstorm.io now maintains a
      [separate Vagrant base box](https://atlas.hashicorp.com/sandstorm/boxes/debian-jessie64)
      (called `sandstorm/debian-jessie64`) which does support VirtualBox file sharing.
      For now, this is a bit-for-bit copy of the most recent `debian/jessie64` base box
      that **did** support file sharing. Since Sandstorm now controls the base box, it is
      safe to run `vagrant box update` once you have changed to our base box.
- Update `vagrant-spk up` to check for the above problem and inform people on
  how to fix it. Update auto-generated `Vagrantfile` accordingly as well.
- For freshly-created Meteor apps, be a little less quiet so that people can
  understand how their package build is progressing.
- (EXPERIMENTAL) Improvements to automatic Meteor app packaging, aka
  `vagrant-spk auto meteor`:
    - Automatically switch Google Fonts from HTTP to HTTPS.
    - Open `.meteor/` files in append mode, to avoid overwriting them.
    - Add more newlines when editing `.meteor/` files.

### v0.130 (2015-11-04)
- (EXPERIMENTAL) vagrant-spk auto meteor improvements:
    - Automatically switch (some) HTTP resource references to HTTPS.
    - Add kentonv:accounts-sandstorm to generated packages.
    - Use git repo name to infer package name.
    - Store git repo URL in the package metadata.
- Meteor stack: Use `meteor-spk` version 0.1.8. This fixes a bug where
  niscudb => Mongo 3 migrations would sometimes fail. If your app has
  `PACKAGE=meteor-spk-0.1.7` in `.sandstorm/setup.sh`, **and** if it
  ever had a previous version, then you should migrate to
  `PACKAGE=meteor-spk-0.1.8` and do `vagrant-spk destroy` to flush the
  cached meteor-spk package version in any packaging VMs.

### v0.125 (2015-10-22)
- Provide a SANDSTORM=1 environment variable so apps can decide if they are
  running in Sandstorm, through a check at runtime.
- Make the Meteor stack less verbose.
- Avoid Vagrant's scary red colorization of stderr.
- More useful help text; thanks @pwais.
- By default, don't limit max body size for inbound HTTP messages in stacks
  that use nginx. This fixes a problem where apps generated by vagrant-spk
  could not accept large (>1MB) file uploads.
- Upgrade meteor stack to meteor-spk 0.1.7, which results in Meteor apps
  getting MongoDB 3.x.
- Make better VM names in VirtualBox, based on the path of the directory
  containing .sandstorm/ (typically the name of the app) and the current
  time (to avoid conflicts).
- Provide more RAM & CPU on Windows-based vagrant-spk VMs, similar to how
  we calculate this on Linux.
- Add experimental "auto" command, for automatic packaging of Meteor apps.

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
