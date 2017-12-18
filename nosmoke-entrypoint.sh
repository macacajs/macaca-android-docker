#!/bin/bash

cnpm i -g macaca-cli
cnpm i -g macaca-android
cnpm i macaca-electron -g
cnpm i nosmoke -g
macaca -v
macaca doctor

# Deprecated

if [[ $EMULATOR == "" ]]; then
    EMULATOR="android-23"
    echo "Using default emulator $EMULATOR"
fi

if [[ $ARCH == "" ]]; then
    ARCH="x86"
    echo "Using default arch $ARCH"
fi
echo EMULATOR  = "Requested API: ${EMULATOR} (${ARCH}) emulator."
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 $1
fi

# Run sshd
/usr/sbin/sshd

# Detect ip and forward ADB ports outside to outside interface
ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
socat tcp-listen:5037,bind=$ip,fork tcp:127.0.0.1:5037 &
socat tcp-listen:5554,bind=$ip,fork tcp:127.0.0.1:5554 &
socat tcp-listen:5555,bind=$ip,fork tcp:127.0.0.1:5555 &

# Set up and run emulator
if [[ $ARCH == *"x86"* ]]
then 
    EMU="x86"
else
    EMU="arm"
fi

echo "no" | android create avd -f -n test -t ${EMULATOR} --abi default/${ARCH}
/usr/local/android-sdk/tools/mksdcard -l sd 128M /sdcard

# Run Macaca In Background
macaca server &

# Run NoSmoke
if [ $# -eq 0 ]
then
nosmoke -s
elif [ $# -eq 1
then
nosmoke -s -c "$1"
elif [ $# -eq 2 ]
then
nosmoke -s -c "$1" -h "$2"
elif [ $# -eq 3 ]
then
nosmoke -s -c "$1" -h "$2" -u "$3"
fi
