#!/bin/sh
## purpose: Initialize the Mijia 720P hack
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Jan Sperling , 2017

if [ ! -d "${LOGDIR}" ]; then
  mkdir -p "${LOGDIR}"
fi

## Config
##################################################################################
if [ -f "${sd_mountdir}/mijia-720p-hack.cfg" ]; then
  . "${sd_mountdir}/mijia-720p-hack.cfg"
fi

if [ "${DISABLE_HACK}" -eq 1 ]; then
  echo "Hack disabled, proceed with default start" | tee -a "${LOGFILE}"
  echo 0 > /tmp/ft_mode
  do_vg_boot
  exit
fi

(
cat << EOF

Running Mijia 720P hack

Mijia 720P hack configuration
  ROOT_PASSWORD=${ROOT_PASSWORD}
  WIFI_SSID=${WIFI_SSID}
  WIFI_PASS=${WIFI_PASS}
  TIMEZONE=${TIMEZONE}
  NTP_SERVER=${NTP_SERVER}
  ENABLE_SYSLOG=${ENABLE_SYSLOG}
  DISABLE_CLOUD=${DISABLE_CLOUD}
  DISABLE_OTA=${DISABLE_OTA}
  ENABLE_TELNETD=${ENABLE_TELNETD}
  ENABLE_SSHD=${ENABLE_SSHD}
  ENABLE_HTTPD=${ENABLE_HTTPD}
  ENABLE_FTPD=${ENABLE_FTPD}
  ENABLE_SAMBA=${ENABLE_SAMBA}
  ENABLE_RTSP=${ENABLE_RTSP}
  RTSP_OPTIONS=${RTSP_OPTIONS}
  SOUND_EN=${SOUND_EN}
EOF

## Syslog
##################################################################################
if [ "${ENABLE_SYSLOG}" -eq 1 ]; then
  /mnt/data/imi/imi_init/_S01logging start
fi

## Make /etc writeable
##################################################################################
if ! [ -d /tmp/etc ]; then
  cp -r /etc /tmp/
fi
if ! mountpoint -q /etc; then
  mount --rbind /tmp/etc /etc
fi

## Prepare restartd.conf
##################################################################################
if ! [ -f /tmp/S99restartd ]; then
  sed 's|/mnt/data/restartd/restartd.conf|/etc/restartd.conf|' /mnt/data/imi/imi_init/S99restartd > /tmp/S99restartd
fi
if ! mount | grep -q /mnt/data/imi/imi_init/S99restartd; then
  mount --bind /tmp/S99restartd /mnt/data/imi/imi_init/S99restartd
fi
if ! [ -f /tmp/etc/restartd.conf.org ] && 
     mountpoint -q /etc; then
  cp /mnt/data/restartd/restartd.conf /tmp/etc/restartd.conf.org
  cp /mnt/data/restartd/restartd.conf /tmp/etc/restartd.conf
fi

## Set time zone
##################################################################################
if [ -n "${TIMEZONE}" ]; then
  echo "Configure time zone"
  rm /tmp/etc/TZ
  echo "${TIMEZONE}" > /tmp/etc/TZ
  export TZ="${TIMEZONE}"
fi

## Set root Password
##################################################################################
if [ -n "${ROOT_PASSWORD}" ]; then
  echo "Setting root password"
  (echo "${ROOT_PASSWORD}"; echo "${ROOT_PASSWORD}") | passwd
  if [ -f "${sd_mountdir}/mijia-720p-hack/bin/smbpasswd" ]; then
    if ! [ -d "${sd_mountdir}/mijia-720p-hack/tmp/samba" ]; then
      mkdir -p "${sd_mountdir}/mijia-720p-hack/tmp/samba"
    fi
    echo "Setting Samba root password"
    (echo "${ROOT_PASS}"; echo "${ROOT_PASS}") | "${sd_mountdir}/mijia-720p-hack/bin/smbpasswd" -a -s
  fi
else
  echo "WARN: root password must be set for SSH and SAMBA"
fi

## WIFI
##################################################################################
sh "${sd_mountdir}/mijia-720p-hack/scripts/configure_wifi"

## Disable Cloud Services and OTA
##################################################################################
if [ "${DISABLE_CLOUD}" -eq 1 ]; then 
  sh "${sd_mountdir}/mijia-720p-hack/scripts/S50disable_cloud" start
  sh "${sd_mountdir}/mijia-720p-hack/scripts/S50disable_ota" start
elif [ "${DISABLE_OTA}" -eq 1 ]; then
  sh "${sd_mountdir}/mijia-720p-hack/scripts/S50disable_ota" start
else
  sh "${sd_mountdir}/mijia-720p-hack/scripts/S50disable_ota" stop
fi

## Start enabled Services
##################################################################################
if ! [ -f /mnt/data/test/boot.sh ]; then
  ln -s ${sd_mountdir}/mijia-720p-hack/scripts/.boot.sh /mnt/data/test/boot.sh
fi

) >> "${LOGFILE}" 2>&1
