#!/bin/bash
#
# To allow users in the video group to change the brightness, a udev rule such as the following can be used
# /etc/udev/rules.d/backlight.rules
# ```
# ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video $sys$devpath/brightness", RUN+="/bin/chmod g+w $sys$devpath/brightness"
# ```
# Referenced from https://wiki.archlinux.org/title/backlight

_BACKLIGHT_DIR="/sys/class/backlight"

if [[ ${#} -ne 1 ]]; then
    echo "Usage: ${0} +NUM|-NUM|NUM"
    exit 1
fi
_first_char=${1:0:1}

_backlight_handler=$(ls ${_BACKLIGHT_DIR})

if [[ -z ${_backlight_handler} ]]; then
    echo "No backlight handler found"
    exit 1
fi

_backlight_max=$(cat ${_BACKLIGHT_DIR}/${_backlight_handler}/max_brightness)
_backlight_current=$(cat ${_BACKLIGHT_DIR}/${_backlight_handler}/brightness)

if [[ -z ${_backlight_max} ]] || [[ -z ${_backlight_current} ]]; then
    echo "No backlight max or current value found"
    exit 1
fi

if [[ ${1} == "show" ]]; then
    echo "Current: ${_backlight_current}/${_backlight_max}"
    exit 0
fi

case ${_first_char} in
    +)
        _number=${1:1}
        _backlight_new=$(( ${_backlight_current} + ${_number} ))
        ;;
    -)
        _number=${1:1}
        _backlight_new=$(( ${_backlight_current} - ${_number} ))
        ;;
    *)
        _number=${1}
        if [[ ${_number} =~ ^[0-9]+$ ]]; then
            _backlight_new=${_number}
        else
            echo "Invalid argument: ${_number}"
            exit 1
        fi
esac

if [[ ${_backlight_new} -gt ${_backlight_max} ]]; then
    _backlight_new=${_backlight_max}
elif [[ ${_backlight_new} -lt 0 ]]; then
    _backlight_new=0
fi

# For debugging
# echo "Backlight handler brightness path: ${_BACKLIGHT_DIR}/${_backlight_handler}/brightness"
# echo "Backlight current value: ${_backlight_current}"
# echo "Backlight max value: ${_backlight_max}"
# echo "Backlight new value: ${_backlight_new}"
# Modify the backlight value
echo "${_backlight_new}" > ${_BACKLIGHT_DIR}/${_backlight_handler}/brightness
