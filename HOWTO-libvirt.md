# Using vagrant-spk with libvirt

If you're running on Linux, you have the option of using `vagrant-spk` with Vagrant's libvirt
backend.  Some developers have performance or reliability issues with VirtualBox and prefer to use
libvirt.

Some caveats:

* `libvirt` is not the default Vagrant backend, and is nowhere near as widely used as the VirtualBox
  backend.  Things may break, either in Vagrant, `libvirt`, or in `vagrant-spk`.
* You will have to do some additional up-front configuration, which may be annoying/burdensome.

That said, Drew (@zarvox) uses the libvirt backend for all of his vagrant-spk work, and would prefer
that it work for people in general, so if you're so inclined, try it out, and file bugs if you hit
issues.  Thanks!


## Install libvirt/libvirtd/virt-manager

On Fedora, this would be:

```bash
sudo dnf install virt-manager libvirt libvirt-daemon
```

On Debian/Ubuntu:

```
sudo apt-get install libvirt-daemon-system virt-manager
```


## Install vagrant

Fedora:

```bash
sudo dnf install vagrant
```


## Install vagrant-libvirt

Fedora:

```bash
sudo dnf install vagrant-libvirt
```


## Disable sandboxing of your VM/SELinux enforcement

This is necessary to allow mounting shared folders from your user's home directory (or wherever the
app you're developing is located) read-write, and getting the correct permissions out the other
side.

Fedora: edit `/etc/libvirt/qemu.conf` and set the following keys (there are comment blocks for each
in the default config):

```
security_driver = "none"
user = "root"
group = "root"
dynamic_ownership = 0
clear_emulator_capabilities = 0
```

* The first key says "disable SELinux enforcement".
* The second and third say "run qemu-kvm as root", which is needed so that the process has
  `CAP_DAC_OVERRIDE` and can create files owned by your user account.
* The fourth key says "don't change files to be owned by root".  We want files owned by your user
  account, by and large.
* The fifth key says "don't drop `CAP_DAC_OVERRIDE`".  Linux has a curious feature which allows
  processes running as root to drop certain privileges.  However, in this case, we need the one
  that allows you to read/modify/write files owned by other users (namely, the user you are doing
  development as).


## Install vagrant-mutate and import a box

We need the `vagrant-mutate` plugin to import a box originally packaged for VirtualBox, convert it
to the libvirt disk image format, and register it as the equivalent box name for Vagrant to use it.

### Install build dependencies:

Fedora:

```bash
sudo dnf install qemu-img libvirt-devel ruby-libvirt ruby-devel
```

### Install the plugin:

```bash
vagrant plugin install mutate
```

### Import the VirtualBox box:

```bash
vagrant box add sandstorm/debian-jessie64
```

### Produce an appropriate box for usage with libvirt:

```bash
vagrant mutate sandstorm/debian-jessie64 libvirt
```


## Set libvirt default provider

Fedora users can skip this step.

To make sure `vagrant` knows to use the libvirt backend for managing VMs, you'll need to set an
environment variable:

```bash
export VAGRANT_DEFAULT_PROVIDER=libvirt
```

You'll probably want to put the above line in your `$HOME/.bashrc` so you don't have to type it every time
you open a shell that you use `vagrant-spk` in.


## Use vagrant-spk with libvirt

Now, whenever you use vagrant-spk, vagrant should attempt to use the libvirt backend when creating VMs. :)

If you have an app where vagrant-spk previously created a VirtualBox VM, vagrant will continue to interact
with that VM until you run `vagrant-spk vm destroy`, after which the next `vagrant-spk vm up` should create a libvirt VM.

## Optional: PolicyKit rule for quality-of-life improvement

Under the hood, libvirt uses PolicyKit to check if your user is authorized to make changes to
libvirt-managed VMs.  If you are on a single-user machine, probably you don't want to have to
enter your password or root's password every time you want to bring a VM up or down.

To that end, you can whitelist your user for all libvirt actions by writing a PolicyKit rule
and placing it in the appropriate folder for your system.  For example, on Fedora, for a user
named `zarvox`, you'd create (as root) a file `/etc/polkit-1/rules.d/10-libvirt-zarvox.rules` with
the contents:

```javascript
polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" && subject.user == "zarvox") {
        return "yes";
    }
});
```

and then restart polkitd:

```bash
sudo systemctl restart polkit.service
```
