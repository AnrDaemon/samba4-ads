#!/bin/sh
find $1 -name "*.php" -exec grep -lP "\b((shell_)?exec|system|eval|passthru|popen|pcntl_exec)\b|\`" \{\} \;
