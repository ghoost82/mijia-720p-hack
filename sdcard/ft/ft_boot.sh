#!/bin/sh
## purpose: Initialize the Mijia 720P hack
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Jan Sperling , 2017

sd_mountdir="/tmp/sd"
LOGDIR="${sd_mountdir}/log"
LOGFILE="${LOGDIR}/ft_boot.log"

do_vg_boot() {
  CONFIG_PARTITION="/gm/config"
  echo "vg boot"
  sh "${CONFIG_PARTITION}/vg_boot.sh" "${CONFIG_PARTITION}"
}

echo "Initialize Mijia 720P hack"

## Find Block device
##################################################################################
mmc_device=""
if [ -b "/dev/mmcblk0p1" ]; then
    mmc_device="/dev/mmcblk0p1"
elif [ -b "/dev/mmcblk0" ]; then
    mmc_device="/dev/mmcblk0"
fi
sd_mountdir="/tmp/sd"


if [ "${mmc_device}" = "" ]; then
  echo "Impossible to find sdcard mounting point."
  do_vg_boot
  exit
fi

## Mount sdcard
##################################################################################
mkdir "${sd_mountdir}"
if ! mount -t vfat "${mmc_device}" "${sd_mountdir}"; then
  echo "Error mounting sdcard."
  do_vg_boot
  exit
fi

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

cat >> "${LOGFILE}" << EOF
Mijia 720P hack configuration
  ROOT_PASSWORD=${ROOT_PASSWORD}
  WIFI_SSID=${WIFI_SSID}
  WIFI_PASS=${WIFI_PASS}
  TIMEZONE=${TIMEZONE}
  NTP_SERVER=${NTP_SERVER}
  ENABLE_SYSLOG=${ENABLE_SYSLOG}
  DISABLE_CLOUD=${DISABLE_CLOUD}
  DISABLE_CLOUD_STREAMING=${DISABLE_CLOUD_STREAMING}
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

(
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
if [ -f "${sd_mountdir}/mijia-720p-hack/scripts/configure_wifi" ]; then
  echo "Configure WiFi"
  sh "${sd_mountdir}/mijia-720p-hack/scripts/configure_wifi"
fi

## Disable Cloud Services, streaming and OTA
##################################################################################
if [ -f "${sd_mountdir}/mijia-720p-hack/scripts/cloud_control" ]; then
  echo "Configure Cloud Services"
  sh "${sd_mountdir}/mijia-720p-hack/scripts/cloud_control"
fi

) >> "${LOGFILE}" 2>&1

## Start enabled Services
##################################################################################
if ! [ -f /mnt/data/test/boot.sh ]; then
  ln -s ${sd_mountdir}/mijia-720p-hack/scripts/.boot.sh /mnt/data/test/boot.sh
fi

## Change Sound files
##################################################################################
#TODO /mnt/data/sound/ 
##TEST echo "/mnt/data/sound/wifi_connected.aac" > /tmp/sound_fifo
#if [ "${SOUND_EN}" -eq 1 ]; then
#  echo "Changing Language to English" >> "${LOGFILE}"
#fi

## Simulate S50gm standard flow
##################################################################################
do_vg_boot

