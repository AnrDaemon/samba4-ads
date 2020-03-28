#!/bin/sh

for folder in INBOX OUTBOX SENT TRASH; do
    for x in cur new tmp; do
        mkdir --parents "$HOME/.mail/$folder/$x"
    done
done
