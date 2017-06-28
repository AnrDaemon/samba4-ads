#!/bin/sh

PREFIX=/usr

~/subversion/configure --prefix=$PREFIX \
  --oldincludedir=$PREFIX/include \
  --disable-mod-activation \
  --with-apache-libexecdir=/usr/lib/apache2/modules \
  --without-berkeley-db \
  --with-gnome-keyring \
  --without-kwallet \
  --with-editor=/usr/bin/nano \
  --without-jdk \
  --without-jikes \
  --without-swig
