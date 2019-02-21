#!/usr/bin/env php
<?php
/**
* $Id: histpurge.php 961 2018-12-05 21:33:09Z anrdaemon $
*/

$histfile = $_SERVER['HOME'] . '/.bash_history';

try
{
  $hist = preg_split('/\r?\n/', file_get_contents($histfile), -1, PREG_SPLIT_NO_EMPTY);
}
catch (Exception $e)
{
  exit(0);
}

$hnew = array();

foreach($hist as $oline)
{
  $hline = trim(preg_replace(array(
      '/\|\s*(less|more)\s*$/',
      '/^\s*sudo(\s+(-[Esi]|-u\s+[\w\-]+|\w+\=\S+))*/'
    ), '', $oline));
  $hkey = array_search(trim($oline), $hnew);
  if(false === $hkey)
  {
    $hkey = array_search($hline, $hnew);
  }
  if(false !== $hkey)
  {
    unset($hnew[$hkey]);
  }

  if(preg_match("#-?-(help|version)\\b#i", $hline) or
    preg_match("#^(head|
      aa-(complain|enforce)|
      a2(en|dis)\\S+|
      apache\\d?ctl|
      ((invoke|update)-rc|/etc/init)\\.d|service|
      ifconfig(\\s+-a)?$|ip\\s+a$|ifup|ifdown|
      apropos|
      (b?z)?cat|
      cd|
      ch(grp|mod|own)|
      d2u|
      d[fu]|
      dig|
      dmesg|
      exit|
      fdisk|
      fg|
      file|
      grep|
      info|
      kill(all)?|
      less|
      ln|
      ls(hw|pci|usb)?|
      man|
      messages|
      m[cv]|
      mkdir|
      nano|
      netstat|
      nslookup|
      passwd|
      ping|
      ps|
      rm|
      set|
      shutdown|
      smbldap-useradd|
      smbpasswd|
      tar|
      testparm|
      top|
      touch|
      trace\\S+|
      umount|
      uname|
      uptime|
      wbinfo|
      which|
      tail)\\b#x", trim($hline)))
  {
    continue;
  }
  $hnew[] = trim($oline);
}

if(!empty($hnew))
  file_put_contents($histfile, implode("\n", $hnew) . "\n");
