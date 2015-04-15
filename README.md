# vagrant-spk

`vagrant-spk` is a tool designed to help app developers package apps for [Sandstorm](https://sandstorm.io).

Example usage:

    git clone git://github.com/zarvox/vagrant-spk
    git clone git://github.com/paulproteus/php-app-to-package-for-sandstorm
    export PATH=$(pwd)/vagrant-spk:$PATH
    cd php-app-to-package-for-sandstorm
    vagrant-spk setupvm lemp
    vagrant-spk up
    vagrant-spk init
    # edit .sandstorm/sandstorm-pkgdef.capnp in your editor of choice
    vagrant-spk dev
    # visit http://localhost:6080 in a web browser
    # log in as Alice, the admin account
    # launch an instance of the example app, play around with it
    # then, press Ctrl-C to stop the tracing vagrant-spk dev
    vagrant-spk pack example.spk
    # You now have an .spk file.  Yay!
