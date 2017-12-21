#!/bin/sh
## purpose: Start enabled services and stop with LED blinking
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Jan Sperling , 2017

sd_mountdir="/tmp/sd"
if [ -f "${sd_mountdir}/mijia-720p-hack.cfg" ]; then
  . "${sd_mountdir}/mijia-720p-hack.cfg"
fi

## Start enabled services
if [ "${ENABLE_TELNETD}" -eq 1 ]; then
  /mnt/data/imi/imi_init/_S50telnet start
  if ! grep -q telnetd /tmp/restartd.conf; then
    echo "telnetd \"/usr/sbin/telnetd\" \"/mnt/data/imi/imi_init/_S50telnet restart\" \"/bin/echo 'telnetd is running'\"" >> /tmp/etc/restartd.conf
    if pgrep /mnt/data/restartd/restartd > /dev/null; then  
      /mnt/data/imi/imi_init/S99restartd restart    
    fi  
  fi
fi
if [ "${ENABLE_SSHD}" -eq 1 ]; then
  ${sd_mountdir}/mijia-720p-hack/scripts/S99dropbear start
fi
if [ "${ENABLE_HTTPD}" -eq 1 ]; then
  ${sd_mountdir}/mijia-720p-hack/scripts/S99lighttpd start
fi
if [ "${ENABLE_FTPD}" -eq 1 ]; then
  ${sd_mountdir}/mijia-720p-hack/scripts/S99ftpd start
fi
if [ "${ENABLE_SAMBA}" -eq 1 ]; then
  ${sd_mountdir}/mijia-720p-hack/scripts/S99samba start
fi
if [ "${ENABLE_RTSP}" -eq 1 ]; then
  ${sd_mountdir}/mijia-720p-hack/scripts/S99rtsp start
fi

## Sync time
/usr/sbin/ntpd -q -p "${NTP_SERVER}"


## LED blue: 0, red: 1, set blue.
if [ "$(/usr/sbin/nvram get light)" = "on" ]; then
  /mnt/data/miot/ledctl 0 80 0 0 0 2
else
  /mnt/data/miot/ledctl 0 0 1 0 0 2
fi
/mnt/data/miot/ledctl 1 0 1 0 0 2

## Put our bins into PATH
if [ -d "${sd_mountdir}/mijia-720p-hack/bin" ] &&
   ! mountpoint -q /tmp/sd/ft; then
  mount --rbind "${sd_mountdir}/mijia-720p-hack/bin" /tmp/sd/ft
fi

## Cleanup
if [ -f /mnt/data/test/boot.sh ]; then
  rm /mnt/data/test/boot.sh
fi


