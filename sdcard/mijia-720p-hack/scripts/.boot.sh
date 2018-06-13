#!/bin/sh
## purpose: Start enabled services and stop with LED blinking
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Jan Sperling , 2017

sd_mountdir="/tmp/sd"
if [ -r "${sd_mountdir}/mijia-720p-hack/scripts/functions.sh" ]; then
  . "${sd_mountdir}/mijia-720p-hack/scripts/functions.sh"
else
  echo "Unable to load basic functions"
  exit 1
fi

LOGFILE="${LOGDIR}/ft_boot.log"

(
echo "Executing /mnt/data/test/boot.sh"

## Put our bins into PATH
if [ -d "${sd_mountdir}/mijia-720p-hack/bin" ] &&
   ! mountpoint -q /tmp/sd/ft; then
  mount --rbind "${sd_mountdir}/mijia-720p-hack/bin" /tmp/sd/ft
fi

## Start enabled services
if [ "${ENABLE_TELNETD}" -eq 1 ]; then
  /mnt/data/imi/imi_init/_S50telnet start
  if ! grep -q telnetd /tmp/etc/restartd.conf; then
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

#Starting serices in non cloud configuration
if [ "${DISABLE_CLOUD}" -eq 1 ]; then
  night_mode="$(get_nvram night_mode)"
  echo "Starting motor calibration"
  motor calibrate
  echo "Done"
  case $night_mode in
    0)
      ${sd_mountdir}/mijia-720p-hack/scripts/S99auto_night_mode start
      ;;
    1)
      night_mode off
      ;;
    2)
      night_mode on
      ;;
  esac
  if [ "$(/usr/sbin/nvram get light)" = "on" ]; then
    blue_led on
  else
    blue_led off
  fi
  yellow_led off
fi

## Sync time
/usr/sbin/ntpd -q -p "${NTP_SERVER}"

## Cleanup
if [ -f /mnt/data/test/boot.sh ]; then
  rm /mnt/data/test/boot.sh
fi

) >> "${LOGFILE}" 2>&1
