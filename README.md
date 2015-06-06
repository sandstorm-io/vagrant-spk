# vagrant-spk

`vagrant-spk` is a tool designed to help app developers package apps for [Sandstorm](https://sandstorm.io).

See also https://github.com/sandstorm-io/sandstorm/wiki/Porting-an-app-with-vagrant-spk for more details.

## Example usage:

    git clone git://github.com/zarvox/vagrant-spk
    git clone git://github.com/paulproteus/php-app-to-package-for-sandstorm
    export PATH=$(pwd)/vagrant-spk:$PATH
    cd php-app-to-package-for-sandstorm
    vagrant-spk setupvm lemp
    vagrant-spk up
    vagrant-spk init
    # edit .sandstorm/sandstorm-pkgdef.capnp in your editor of choice
    vagrant-spk dev
    # visit http://local.sandstorm.io:6080 in a web browser
    # log in as Alice, the admin account
    # launch an instance of the example app, play around with it
    # then, press Ctrl-C to stop the tracing vagrant-spk dev
    vagrant-spk pack example.spk
    # You now have an .spk file.  Yay!
    # Verify it works by going to http://local.sandstorm.io:6080,
    # select "My Files" -> "Upload an app", select your .spk file,
    # upload it, install it, and create a new instance of your app.

## What the files are for
```vagrant-spk```will create a ```.sandstorm/```folder in your repo and setup some files.

### global-setup.sh
This installs Sandstorm using the bundled installer. You should not be required to change that.

### setup.sh
This script runs when you setup the VM by ```vagrant-spk up``` the first time and does the stack-specific and app-specific setup. At the beginning all required packages are installed. For example php, mysql, node, nginx and so on. Please keep in mind things you do here will not be done again when running ```vagrant-spk dev``` or starting a grain. If you apply changes here you will have to destroy your VM and rebuild it again.

### build.sh 
This script runs always when you are running ```vagrant-spk dev``` to test your current code in dev mode. Usually you put things here which can change and need an update. Examples can be:
- ```composer`` to install or update php dependencies 
- ```npm install``` to install or update npm dependencies
- ```bower install``` to install or update npm dependencies
- ```gulp``` to build static assets

### launcher.sh
This script will be run every time an instance of your app - aka grain - starts in Sandstorm. Typically you are building folder structures in ```/var``` here as this is the only writable place when your grain is running. You also can check your database here e.g. if it is initially setup when a new grain is created or to check if a database update must be applied after you updated your app and an existing grain is opened.

### sandstorm-files.list
This file is generated after leaving the dev mode and contains a list of all used files. See https://github.com/sandstorm-io/sandstorm/wiki/Porting-an-app-with-vagrant-spk

### sandstorm-pkgdef.capnp
See https://github.com/sandstorm-io/sandstorm/wiki/Porting-an-app-with-vagrant-spk

### Vagrantfile
See https://github.com/sandstorm-io/sandstorm/wiki/Porting-an-app-with-vagrant-spk

## Example setups

### Default setup 
Repo: https://github.com/paulproteus/php-app-to-package-for-sandstorm

This example shows how to setup a php + mysql app.

setup.sh
php and mysql packages are installed 

build.sh
composer is installed and updated

### Paperwork (php, mysql, composer, npm)
Repo: https://github.com/JamborJan/paperwork

setup.sh
Besides php and mysql also node and npm packages are installed. Npm packages are also installed here.  

build.sh
composer is installed and updated. npm and bower dependencies are installed for new or updated for existing grains. Gulp will be run to build static assets.

launcher.sh
The storage folders for the notes are created in /var/storage and symlinked to the place where paperwork expects them to be. Also the default database is setup when a grain is created.