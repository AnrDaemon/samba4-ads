#!/bin/sh

< /proc/uptime read -r _u _i _

#_u=8; _i=7; # Online 0:00:08, 87.50% idle.
tput setaf 2
echo "uptime = $_u
scale = 2; idle = 100 * $_i / uptime

define fmt(x) {
  auto y
  y = length(x) - scale(x)
  if(y < 2) {
    print 0
    if(y < 1) {
      print 0
    }
  }
  return(x)
}

scale = 0

seconds = uptime % 60; tail = (uptime - seconds) / 60
minutes = tail % 60; tail = (tail - minutes) / 60
hours = tail % 24
days = (tail - hours) / 24

print \"Online \"

if(days > 0) {
  print days, \" days, \"
}

print hours, \":\", fmt(minutes), \":\", fmt(seconds), \", \", idle, \"% idle.\\n\"

quit
" | /bin/bc -q
tput sgr0
