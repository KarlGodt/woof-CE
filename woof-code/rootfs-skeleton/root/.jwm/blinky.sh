#!/bin/sh
(pidof blinkydelayed >/dev/null 2>/dev/null || blinkydelayed -bg "#4D525B")
