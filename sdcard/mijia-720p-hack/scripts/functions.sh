#!/bin/sh

## purpose: some basic functions
## license: GPLv3+, http://www.gnu.org/licenses/gpl-3.0.html
## author: Jan Sperling, 2018

sd_mountdir="/tmp/sd"
LOGDIR="${sd_mountdir}/log"
BASECFG="${sd_mountdir}/mijia-720p-hack.cfg"
MIJIACTRL="${sd_mountdir}/mijia-720p-hack/bin/mijia_ctrl"
if [ -f "${BASECFG}" ]; then
  . "${BASECFG}"
fi

# Creates /tmp/disable-binary
create_disable_binary() {
    if [ ! -f /tmp/disable-binary ]; then
    cat > /tmp/disable-binary << EOF
#!/bin/sh
echo "\$0 disabled with mijia-720p-hack"
EOF
    chmod +x /tmp/disable-binary
  fi
}

# Disable binary and optionally delete it from restartd.conf
disable_binary() {
  binary="$1"
  restart="$2"
  create_disable_binary
  echo "Disabling ${1##*/}"
  if pgrep "${binary}" >/dev/null; then
    pkill "${binary}"
  fi
  if ! mount | grep -q "${binary}"; then
    mount --bind /tmp/disable-binary "${binary}"
  fi
  # update restartd.conf
  if [ -n "${restart}" ] &&
     [ -f /tmp/etc/restartd.conf ] &&
     grep -q ^"${restart} " /tmp/etc/restartd.conf; then
    sed -i "/^${restart} /d" /tmp/etc/restartd.conf
  fi
}

# Enable binary and optionally add it to restartd.conf
enable_binary() {
  binary="$1"
  restart="$2"
  if mount|grep -q "${binary}"; then
    umount "${binary}"
  fi
  # update restartd.conf
  if [ -n "${restart}" ] &&
     [ -f /tmp/etc/restartd.conf ] &&
     ! grep -q ^"${restart} " /tmp/etc/restartd.conf; then
    grep ^"${restart} " /tmp/etc/restartd.conf.org >> /tmp/etc/restartd.conf
  fi
}

# Print start-stop-daemon return status
ok_fail() {
  if [ "$1" = 0 ]; then
    echo "OK" 
  else
    echo "FAIL"
  fi
}

# Start daemon
start_daemon() {
  echo "Starting ${DESC}"
  start-stop-daemon --start --quiet --oknodo \
                    --exec "${DAEMON}" -- ${DAEMON_OPTS}
  RC="$?"
  ok_fail "${RC}"
  return "${RC}"
}

# Start a process as background daemon
start_daemon_background() {
  echo "Starting ${DESC}"
  start-stop-daemon --start --quiet --oknodo \
                    --pidfile "${PIDFILE}" --make-pidfile --background \
                    --exec "${DAEMON}" -- ${DAEMON_OPTS}
  RC="$?"
  ok_fail "${RC}"
  return "${RC}"
}

# Stop daemon
stop_daemon() {
  echo "Stopping ${DESC}"
  start-stop-daemon --stop --quiet --oknodo \
                    --pidfile "${PIDFILE}"
  RC="$?"
  ok_fail "${RC}"
  return "${RC}"
}

# Stop background daemon
stop_daemon_background() {
  if stop_daemon; then 
    if [ -f "${PIDFILE}" ]; then
      rm "${PIDFILE}"
    fi
  fi
  return "${RC}"
}

# Status of a daemon
status_daemon() {
  pid="$(cat "${PIDFILE}" 2>/dev/null)"
  if [ "${pid}" ]; then
    if kill -0 "${pid}" >/dev/null 2>/dev/null; then
      echo "${DESC} is running with PID: ${pid}"
      RC="0"
    else
      echo "${DESC} is dead"
      RC="1"
    fi
  else
    echo "${DESC} is not running"
    RC="3"
  fi
  return "${RC}"
}

# Check for daemon executable
check_daemon_bin() {
  binary="$1"
  description="$2"
  if [ ! -x "${binary}" ]; then
    echo "Could not find ${description} binary"
    exit 1
  fi
}

# get NVRAM variable
get_nvram() {
  variable="$1"
  /usr/sbin/nvram get "${variable}" | xargs
}

# Save NVRAM variable
set_nvram() {
  variable="$1"
  value="$2"
  if [ "$(get_nvram "${variable}")" != "${value}" ]; then
    /usr/sbin/nvram set ${variable}="${value}"; RC="$((RC|$?))"
    #/usr/sbin/nvram commit; RC="$((RC|$?))"
  fi
  return "${RC}"
}

# Get ISP328 values 
get_isp328() {
  variable="$1"
  echo r ${variable} > /proc/isp328/command
  cat /proc/isp328/command
}

# Set ISP328 values 
set_isp328() {
  variable="$1"
  value="$2"
  echo w ${variable} ${value} > /proc/isp328/command; RC="$((RC|$?))"
  return "${RC}"
}

# Read a value from a GPIO pin
get_gpio(){
  pin="$1"
  cat /sys/class/gpio/gpio${pin}/value
}

# Write a value to GPIO pin
set_gpio() {
  pin="$1"
  value="$2"
  echo "${value}" > /sys/class/gpio/gpio${pin}/value; RC="$((RC|$?))"
  return "${RC}"
}

# Set config value in basecfg
set_basecfg() {
  variable="$1"
  value="$2"
  if egrep -q "^[[:space:]]*${variable}=(|\")${value}(|\"[[:space:]]*)$" "${BASECFG}"; then
    RC="0"
  elif grep -q "^[[:space:]]*${variable}=" "${BASECFG}"; then
    sed -i -e "/^[[:space:]]*${variable}=/ s/=.*/=\"${value}\"/" "${BASECFG}"; RC="$((RC|$?))"
  else
    echo "${variable}=\"${value}\"" >> "${BASECFG}"; RC="$((RC|$?))"
  fi
  return "${RC}"
}

# Control the blue LED
blue_led(){
  #if ! [ -x "${MIJIACTRL}" ]; then
  #  echo "could not find ${MIJIACTRL}"
  #  return 1
  #fi
  case "$1" in
    on)
      #${MIJIACTRL} LEDSTATUS 0 0; RC="${?}"
      /mnt/data/miot/ledctl 0 50 0 0 0 2 > /dev/null; RC="$((RC|$?))"
      ;;
    off)
      #${MIJIACTRL} LEDSTATUS 0 1; RC="${?}"
      /mnt/data/miot/ledctl 0 50 1 0 0 2 > /dev/null; RC="$((RC|$?))"
      ;;
    blink)
      #${MIJIACTRL} LEDSTATUS 0 2; RC="${?}"
      /mnt/data/miot/ledctl 0 50 2 0 0 2 > /dev/null; RC="$((RC|$?))"
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac
  return "${RC}"
}

# Control the yellow LED
yellow_led(){
  #if ! [ -x "${MIJIACTRL}" ]; then
  #  echo "could not find ${MIJIACTRL}"
  #  return 1
  #fi
  case "$1" in
    on)
      #${MIJIACTRL} LEDSTATUS 1 0; RC="${?}"
      /mnt/data/miot/ledctl 1 50 0 0 0 2 > /dev/null; RC="$((RC|$?))"
      ;;
    off)
      #${MIJIACTRL} LEDSTATUS 1 1; RC="${?}"
      /mnt/data/miot/ledctl 1 50 1 0 0 2 > /dev/null; RC="$((RC|$?))"
      ;;
    blink)
      #${MIJIACTRL} LEDSTATUS 1 2; RC="${?}"
      /mnt/data/miot/ledctl 1 50 2 0 0 2 > /dev/null; RC="$((RC|$?))"
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac
  return "${RC}"
}

# Control the infrared LED
ir_led(){
  if ! [ -x "${MIJIACTRL}" ]; then
    echo "could not find ${MIJIACTRL}"
    return 1
  fi
  case "$1" in
    on)
      ${MIJIACTRL} IRLED 255 > /dev/null; RC="$((RC|$?))"
      ;;
    off)
      ${MIJIACTRL} IRLED 0 > /dev/null; RC="$((RC|$?))"
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac
  return "${RC}"
}

# Control the infrared filter
ir_cut(){
  #if ! [ -x "${MIJIACTRL}" ]; then
  #  echo "could not find ${MIJIACTRL}"
  #  return 1
  #fi
  case "$1" in
    on)
      #${MIJIACTRL} IRCUT 1; RC="$((RC|$?))"
      set_gpio 14 1; RC="$((RC|$?))"
      set_gpio 15 0; RC="$((RC|$?))"
      echo 1 > /var/run/ircut
      ;;
    off)
      #${MIJIACTRL} IRCUT 0; RC="$((RC|$?))"
      set_gpio 14 0; RC="$((RC|$?))"
      set_gpio 15 1; RC="$((RC|$?))"
      echo 0 > /var/run/ircut
      ;;
    status)
      status="$(cat /var/run/ircut 2>/dev/null || get_gpio 14)"
      cat << EOF
{
  "ir_cut": "${status}"
}
EOF
      if [ -n "${status}" ]; then
        RC="0"
      else
        RC="1"
      fi
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac
  return "${RC}"
}

# Control the night mode
night_mode(){
  #if ! [ -x "${MIJIACTRL}" ]; then
  #  echo "could not find ${MIJIACTRL}"
  #  return 1
  #fi
  case "$1" in
    on)
      ir_led on; RC="$((RC|$?))"
      ir_cut off; RC="$((RC|$?))"
      #${MIJIACTRL} DAYNIGHT 1; RC="$((RC|$?))"
      set_isp328 daynight 1; RC="$((RC|$?))"
      ;;
    off)
      ir_led off; RC="$((RC|$?))"
      ir_cut on; RC="$((RC|$?))"
      #${MIJIACTRL} DAYNIGHT 0; RC="$((RC|$?))"
      set_isp328 daynight 0; RC="$((RC|$?))"
      ;;
    status)
      status="$(get_isp328 daynight)"
      cat << EOF
{
  "night_mode": "${status}"
}
EOF
      if [ -n "${status}" ]; then
        RC="0"
      else
        RC="1"
      fi
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac
  return "${RC}"
}

# Controll flip mode
flip() {
  case "$1" in
    on)
      set_isp328 flip 1; RC="$((RC|$?))"
      ;;
    off)
      set_isp328 flip 0; RC="$((RC|$?))"
      ;;
    status)
      status="$(get_isp328 flip)"
      cat << EOF
{
  "flip": "${status}"
}
EOF
      if [ -n "${status}" ]; then
        RC="0"
      else
        RC="1"
      fi
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac
  return "${RC}"
}

# Controll mirror mode
mirror() {
  case "$1" in
    on)
      set_isp328 mirror 1; RC="$((RC|$?))"
      ;;
    off)
      set_isp328 mirror 0; RC="$((RC|$?))"
      ;;
    status)
      status="$(get_isp328 mirror)"
      cat << EOF
{
  "mirror": "${status}"
}
EOF
      if [ -n "${status}" ]; then
        RC="0"
      else
        RC="1"
      fi
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac
  return "${RC}"
}

# Calibrate and control the motor
motor(){
  if ! [ -x "${MIJIACTRL}" ]; then
    echo "could not find ${MIJIACTRL}"
    return 1
  fi
  #Motor will not move if PWM is in use
  if [ "${DISABLE_CLOUD}" -eq 0 ]; then
    echo "motor only supported while  cloud is disabled"
    return 1
  elif [ "$1" = "up" ] || [ "$1" = "down" ] ||
       [ "$1" = "left" ] || [ "$1" = "right" ] || 
       [ "$1" = "calibrate" ]; then
    ${sd_mountdir}/mijia-720p-hack/scripts/S99auto_night_mode stop > /dev/null; RC="$((RC|$?))"
  fi
  ptz_x="$(get_nvram ptz-x)"
  ptz_y="$(get_nvram ptz-y)"
  if [ "${ptz_y}" -gt 15 ]; then
    set_nvram ptz-y 15; RC="$((RC|$?))"
  fi
  if [ "${ptz_y}" -lt 0 ]; then
    set_nvram ptz-y 0; RC="$((RC|$?))"
  fi
  if [ "${ptz_x}" -gt 31 ]; then
    set_nvram ptz-y 31; RC="$((RC|$?))"
  fi
  if [ "${ptz_x}" -lt 0 ]; then
    set_nvram ptz-y 0; RC="$((RC|$?))"
  fi
  case "$1" in
    up)
      if [ "${ptz_y}" -lt 15 ]; then
        ${MIJIACTRL} MOVE 0 +1 > /dev/null; RC="$((RC|$?))"
        set_nvram ptz-y $((ptz_y+1)); RC="$((RC|$?))"
      fi
      ;;
    down)
      if [ "${ptz_y}" -ge 0 ]; then
        ${MIJIACTRL} MOVE 0 -1 > /dev/null; RC="$((RC|$?))"
        set_nvram ptz-y $((ptz_y-1)); RC="$((RC|$?))"
      fi
      ;;
    left)
      if [ "${ptz_x}" -lt 31 ]; then
        ${MIJIACTRL} MOVE +1 0 > /dev/null; RC="$((RC|$?))"
        set_nvram ptz-y $((ptz_x+1)); RC="$((RC|$?))"
      fi
      ;;
    right)
      if [ "${ptz_x}" -ge 0 ]; then
        ${MIJIACTRL} MOVE -1 0 > /dev/null; RC="$((RC|$?))"
        set_nvram ptz-y $((ptz_x-1)); RC="$((RC|$?))"
      fi
      ;;
    calibrate)
      ${MIJIACTRL} MOVE +31 +15 > /dev/null; RC="$((RC|$?))"
      sleep 1
      ${MIJIACTRL} MOVE -31 -15 > /dev/null; RC="$((RC|$?))"
      sleep 1
      ${MIJIACTRL} MOVE +"${ptz_x}" +"${ptz_y}" > /dev/null; RC="$((RC|$?))"
      sleep 3
      ;;
    status)
      status="$(${MIJIACTRL} MOVE 0 0  2> /dev/null | tr ',' '\n')"
      vpos="$(echo "${status}" | awk -F'=' '/VPOS/ {print $2}')"
      hpos="$(echo "${status}" | awk -F'=' '/HPOS/ {print $2}')"
      cat << EOF
{
  "motor":
  { "horizontal": 
    { "nvram": "${ptz_x}",
      "HPOS": "${hpos}"
    },
    "vertical":
    {
      "nvram": "${ptz_y}",
      "VPOS": "${vpos}"
    }
  }
}
EOF
      if [ -n "${ptz_x}" ] && [ -n "${ptz_y}" ] &&
         [ -n "${hpos}" ] && [ -n "${vpos}" ]; then
        RC="0"
      else
        RC="1"
      fi
      ;;
    *)
      echo "Option $1 not supported"
      RC="1"
      ;;
  esac

  #Restart auto_night_mode if necessary
  if [ "$1" = "up" ] || [ "$1" = "down" ] ||
     [ "$1" = "left" ] || [ "$1" = "right" ] ||
     [ "$1" = "calibrate" ]; then
    if [ "$(get_nvram night_mode)" -eq 0 ]; then
      ${sd_mountdir}/mijia-720p-hack/scripts/S99auto_night_mode start > /dev/null; RC="$((RC|$?))"
    fi
  fi
  return "${RC}"
}


if [ ! -d /var/run ]; then 
  mkdir -p /var/run 
fi 

