#!/bin/bash

> devices.css
> devicelist_good

DEVICES_BAD=$(cat devicelist_bad)
ROCOMMUNITY="ROCOMMUNITY"
RWCOMMUNITY="RWCOMMUNITY"

DOMAINNAME="your.domain.name"

while read p; do
    unset SYSNAME
    unset VENDOR
    unset FIRMWARE
    unset SERIAL
    unset MODEL
    unset BOOTIMG

    DEVICE_BAD=$(echo "$DEVICES_BAD" | grep -w "${p}")
    if [[ "$DEVICE_BAD" == "" ]];
    then
        SYSNAME_STRING=$(snmpget ${p} -On -c $RWCOMMUNITY -v2c .1.3.6.1.2.1.1.5.0 | sed 's/.*STRING: //g' | sed 's/"//g' | sed -n '1p')
        SYSVEND_STRING=$(snmpget ${p} -On -c $RWCOMMUNITY -v2c .1.3.6.1.2.1.1.1.0 | sed 's/.*STRING: //g' | sed 's/"//g' | sed -n '1p')
        if [[ "$SYSNAME_STRING" == "" && "$SYSVEND_STRING" == "" ]];
        then
            echo "${p} not answered on RW-community, trying with RO-community"
            SYSNAME_STRING=$(snmpget ${p} -On -c $ROCOMMUNITY -v2c .1.3.6.1.2.1.1.5.0 | sed 's/.*STRING: //g' | sed 's/"//g' | sed -n '1p')
            SYSVEND_STRING=$(snmpget ${p} -On -c $ROCOMMUNITY -v2c .1.3.6.1.2.1.1.1.0 | sed 's/.*STRING: //g' | sed 's/"//g' | sed -n '1p')
        fi
        if [[ "$SYSNAME_STRING" == "" && "$SYSVEND_STRING" == "" ]];
        then
            echo "${p} not answered on RO-community"
            echo "${p}" >> devicelist_bad
        else
            SYSNAME=$(echo "$SYSNAME_STRING" | sed "s/$DOMAINNAME//g")

            VENDOR=$(echo "${SYSVEND_STRING}" | sed 's/ \r//g'  | sed 's/\r//g' | cut -d , -f 1)

            if [[ "$VENDOR" == "Juniper Networks" ]];
            then
                SERIAL=$(snmpwalk ${p} -On -c $RWCOMMUNITY -v2c .1.3.6.1.4.1.2636.3.1.8.1.7 | grep "STRING" | grep -v "BUILTIN" | sed 's/.*STRING: //g' | sed 's/ //g' |sed 's/"//g' | awk '!($0 in a) {a[$0];print}' | tr '\n' ';')
                FIRMWARE=$(echo "${SYSVEND_STRING}" | sed 's/ \r//g'  | sed 's/\r//g' | sed 's/.*JUNOS //' | cut -d , -f 1)
            fi

            if [[ "$VENDOR" == "Cisco IOS Software" ]];
            then
                SERIAL=$(snmpwalk ${p} -On -c $RWCOMMUNITY -v2c .1.3.6.1.2.1.47.1.1.1.1.11 | grep "STRING" | grep -v "BUILTIN" | sed 's/.*STRING: //g' | sed 's/ //g' | sed 's/"//g' | awk '!($0 in a) {a[$0];print}' | tr '\n' ';')
                MODEL=$(snmpwalk ${p} -On -c $RWCOMMUNITY -v2c 1.3.6.1.2.1.47.1.1.1.1.13 | grep "STRING:" | sed 's/.*STRING: //g' | sed 's/ //g' | sed 's/"//g' | sed -n '1p')
                BOOTIMG=$(snmpwalk ${p} -On -c $RWCOMMUNITY -v2c .1.3.6.1.2.1.16.19.6.0 | grep "STRING:" | sed 's/.*STRING: //g' | sed 's/.*://g'  | sed 's/.*\///g' | sed 's/ //g' | sed 's/"//g' | sed -n '1p')
                FIRMWARE=$(echo "${SYSVEND_STRING}" | sed 's/ \r//g'  | sed 's/\r//g' | sed 's/.*Version //' | cut -d , -f 1)
            fi

            echo "${p},$SYSNAME,$VENDOR,$FIRMWARE,$SERIAL,$MODEL,$BOOTIMG"
            echo "${p},$SYSNAME,$VENDOR,$FIRMWARE,$SERIAL,$MODEL,$BOOTIMG" >> devices.css
            echo "${p}" >> devicelist_good
        fi
    else
        echo "${p} - device is badlisted. Skip"
    fi

done < <(cat devicelist | grep -v "#")
