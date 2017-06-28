#!/bin/sh

test -d '/opt/webmin/scripts/virtualmin/post-handler' && \
  run-parts --report --exit-on-error -- /opt/webmin/scripts/virtualmin/post-handler
