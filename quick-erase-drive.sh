#!/bin/bash

###############################################################################
#
#  PURPOSE:  This script's purpose is to restore a drive to "new" from
#            the perspective of the Windows installer
#
#  AUTHOR:   John Lucas
#  CREATED ON:  2016-12-07
#
##############################


#check if user supplied command line argument
if [ -z "$1" ]
  then
    echo "Usage:  $0 /dev/sd[?]"
    exit 1
fi


# Now, we know we have data, so lets assign it to a variable
DOOMEDDRIVE=$1


# Check if device is writable by current user
if [ ! -w "${DOOMEDDRIVE}" ]
  then
    printf "\n"
    printf "\n"
    echo -e "    \e[105m  Looks like ${DOOMEDDRIVE} is NOT writable!!  \e[0m"
    printf "\n"
    exit 2
fi

# Check to see if anythign on this drive is mounted via the mount command
ISMOUNTED=`mount | grep ${DOOMEDDRIVE} | wc -L`
if [ "${ISMOUNTED}" != "0" ]; then
  echo "Looks like ${DOOMEDDRIVE} is mounted:"
  mount | grep ${DOOMEDDRIVE}
  exit 3
fi


######################################
# Print Warning
clear
printf "\n"
printf "\n"
printf "\n"
printf "\n"
echo -n -e "    "
echo -n -e "\e[101m   WARNING   \e[0m     "
echo -n -e "\e[5m\e[101m   WARNING   \e[0m     "
echo -n -e "\e[101m   WARNING   \e[0m     "
echo -n -e "\e[5m\e[101m   WARNING   \e[0m     "
echo -n -e "\e[101m   WARNING   \e[0m     "
printf "\n"
printf "\n"
echo -e "You are about to destroy data on:  \e[104m${DOOMEDDRIVE}\e[0m"
printf "\n"
echo "This will cause the drive to be unusable!!"
printf "\n"
echo "(We will be writing zeros to the first 200MB and last 2MB of the drive)"
printf "\n"
printf "\n"
echo -n "To continue, type YES (in caps) and enter:  "
read CONFIRM

if [ "${CONFIRM}" != "YES" ]; then
  echo "Did not receive a YES from user...terminating now"
  exit 4
fi


# User has confirmed that things look good, lets destroy some data!  YeHaw!
#echo "DATA DELETED"

#echo -n "Unmounting all partitions for ${DOOMEDDRIVE}:"
#umount ${DOOMEDDRIVE}*

echo -n "Deleting 200MB of data from beginning of drive now"
dd if=/dev/zero of=${DOOMEDDRIVE} bs=2048k count=100
echo "...done."

echo -n "Deleting last 2MB of data at end of drive now"
dd bs=512 if=/dev/zero of=${DOOMEDDRIVE} count=2048 seek=$((`blockdev --getsz ${DOOMEDDRIVE}` - 2048))
echo "...done."

printf "\n"
echo -e "\e[101mHealth of drive:\e[0m"
smartctl -a ${DOOMEDDRIVE} | grep -E 'Reallocated_Sector_Ct|Error|Uncorrectable|Model|Rotation|Serial|Power_On_Hours'

exit 0


