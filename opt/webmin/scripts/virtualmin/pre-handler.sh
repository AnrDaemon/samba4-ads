#!/bin/sh

test -d '/opt/webmin/scripts/virtualmin/pre-handler' && \
  run-parts --report --exit-on-error -- /opt/webmin/scripts/virtualmin/pre-handler
