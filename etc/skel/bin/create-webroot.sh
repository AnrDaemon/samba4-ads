#!/bin/sh

for directory in htdocs logs tmp/sessions; do
    mkdir --parents "$HOME/$directory"
done
