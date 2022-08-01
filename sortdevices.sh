#!/bin/bash

> devices_cisco.css
> devices_juniper.css
> devices_unknown.css

while read p; do
    IFS=',' read -r -a array <<< "${p}"
    case "${array[2]}" in
        *Juniper*|*juniper* )
            echo "${array[0]} - Juniper"
            echo "${p}" >> devices_juniper.css
            ;;
        *Cisco*|*cisco* )
            echo "${array[0]} - Cisco"
            echo "${p}" >> devices_cisco.css
            ;;
        * )
            echo "${array[0]} - Unknown"
            echo "${p}" >> devices_unknown.css
            ;;
    esac

done < devices.css

cat devices_cisco.css | cut -d , -f 4,6,7 | awk '!($0 in a) {a[$0];print}' > cisco_models_versions.css