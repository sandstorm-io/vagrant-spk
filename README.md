# vagrant-spk

`vagrant-spk` is a tool designed to help app developers package apps for [Sandstorm](https://sandstorm.io).

## Example usage:

    git clone git://github.com/sandstorm-io/vagrant-spk
    git clone git://github.com/sandstorm-io/php-app-to-package-for-sandstorm
    export PATH=$(pwd)/vagrant-spk:$PATH
    cd php-app-to-package-for-sandstorm
    vagrant-spk setupvm lemp
    vagrant-spk vm up
    vagrant-spk init
    # edit .sandstorm/sandstorm-pkgdef.capnp in your editor of choice
    vagrant-spk dev
    # visit http://local.sandstorm.io:6090 in a web browser
    # log in as Alice, the admin account
    # launch an instance of the example app, play around with it
    # then, press Ctrl-C to stop the tracing vagrant-spk dev
    vagrant-spk pack example.spk
    # You now have an .spk file.  Yay!
    # Verify it works by going to http://local.sandstorm.io:6090,
    # select "My Files" -> "Upload an app", select your .spk file,
    # upload it, install it, and create a new instance of your app.

## What the files are for

`vagrant-spk` will create a `.sandstorm/` folder in your repo and set up some
files with some defaults for your app stack.  You will likely need to modify
some of these to adapt their behavior to make the most sense for your app.

See the [vagrant-spk docs on customizing your
package](https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/)
for full details.

## Example apps

See the [example app listing in the vagrant-spk
documentation.](https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#example-setups)
