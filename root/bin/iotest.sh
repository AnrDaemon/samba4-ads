#!/bin/sh
printf '/dev/zero I/O:\n'
sync; dd if=/dev/zero of=/tempfile bs=1M count=1024 conv=fsync; sync; dd if=/tempfile of=/dev/null bs=1M; rm /tempfile
printf '/dev/urandom I/O:\n'
sync; dd if=/dev/urandom of=/tempfile bs=1M count=1024 conv=fsync; sync; dd if=/tempfile of=/dev/null bs=1M; rm /tempfile
