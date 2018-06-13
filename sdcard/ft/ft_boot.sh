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
  echo "Impossible to find sdcard mounting point. Do normal boot."
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

## Execute custom code
##################################################################################
if [ ! -f "${sd_mountdir}/mijia-720p-hack/scripts/.ft_boot.sh" ];then
  echo "Error starting ft_boot.sh. Do normal boot."
  do_vg_boot
  exit
else
  . "${sd_mountdir}/mijia-720p-hack/scripts/.ft_boot.sh"
fi

## Simulate S50gm standard flow
##################################################################################
do_vg_boot

