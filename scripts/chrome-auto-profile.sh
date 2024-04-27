#!/bin/bash

# This script will detect given chrome user name and select the corresponding 
# profile to open the chrome browser.

_LOCAL_STATE_FILE="/home/${USER}/.config/google-chrome/Local State"
_CHROME_EXECUTABLE="/usr/bin/google-chrome"

if [[ ${#} -ne 1 ]]; then
    echo "Usage: ${0} <chrome-user-name>"
    exit 1
fi

_user_name=${1}
_profile_name=$(jq -r --arg _un "${_user_name}" '.profile.info_cache | to_entries[] | select(.value.user_name == $_un).key' < "${_LOCAL_STATE_FILE}")

# echo "profile name: ${_profile_name}"
${_CHROME_EXECUTABLE} --profile-directory="${_profile_name}" &


