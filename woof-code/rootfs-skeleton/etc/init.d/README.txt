These scripts are executed at bootup and shutdown to start and stop services.
An example of this is in the openoffice_jre-6 PET package (Java Runtime Environment
package that was supplied with OpenOffice).

Puppy does not have runlevels (basically because Busybox doesn't, at least that
was the original reason). Normal Linux distros would have a list of services to
start for each runlevel, but apart from not having runlevels Puppy also only
runs a very minimum essential set of services. Probably most users would not
understand the concept of starting and stopping runlevels and would never want
to do it anyway.

As Puppy just runs the minimum required services, not requiring any user
intervention, Puppy does not have any services management.
At bootup, the /etc/rc.d/rc.services script will run all scripts found in
/etc/init.d/, with the commandline parameter 'start'.
At shutdown, the /etc/rc.d/rc.shutdown script will run all scripts found in
/etc/init.d/, with the commandline parameter 'stop'.

Note that /etc/rc.d/init.d is a symlink to /etc/init.d

Note, the scripts in /etc/init.d/ can have any name, but must have their executable
flag set. Any file that does not the the 'x' flag set will be ignored.
