Dependencies
============

baker - http://github.com/teran-mckinney/baker

Instructions
============

Boot up a [mfsbsd](http://mfsbsd.vx.sk/) image and tinker, see what interfaces you are given.

Edit configuration files in include/ to be relevant to your environment.

```
./build-ipxer.sh > /tmp/mfsbsd # Pipe through pv if you want size, progress, and duration
# (about an hour later)
dd if=/tmp/mfsbsd of=/dev/usbstick bs=10M
sync
```

And boot it. May not want to run this in conjunction with another DHCP server.
