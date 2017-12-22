#!/bin/bash

macaca -v
macaca doctor

# Run sshd
/usr/sbin/sshd

# Detect ip and forward ADB ports outside to outside interface
ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

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
