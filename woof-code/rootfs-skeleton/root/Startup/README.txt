Any executable or scripts (or symlink to) placed in this directory
will be executed after the X desktop has loaded.

This is handy if you want something to run automatically.

You can easily create a "symlink" (symbolic link) to an executable.
For example, say that you wanted to run /usr/local/bin/rubix (a game)
everytime Puppy is started. Use ROX-Filer (the file manager) and open
two windows, one on /usr/local/bin, the other on /root/Startup.
Then just drag 'rubix' across and a menu will popup and ask if you want
to copy, move or link, and you choose to link.

Note, if you want to execute something at bootup and prior to X desktop
loading, edit /etc/rc.d/rc.local.


luci-222

Icewm bug with tray icons...

I gather this snuk in in latest woof, the ice package needs slight modification

First, open /usr/share/icewm and delete the blinky and freememapplet executables.

Second, open /root/Startup and delete z-fix-icewm-tray or whatever it is.. (um I already deleted it Wink )

Third, replace /usr/local/sbin/jwmx2 script with the one attached, expand.

That should do it.

Cheers

http://www.murga-linux.com/puppy/viewtopic.php?p=446856&search_id=1785645733#446856
