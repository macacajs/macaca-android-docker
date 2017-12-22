#!/bin/bash

export CHROMEDRIVER_CDNURL=https://npm.taobao.org/mirrors/
export ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/

RUN cnpm i -g macaca-cli
RUN cnpm i -g macaca-android
RUN cnpm i -g nosmoke
RUN macaca -v
RUN macaca doctor

echo "y" | android update sdk -a --no-ui --filter sys-img-x86_64-android-23,Android-23
echo "no" | android create avd -f -n test -t android-23 --abi default/x86_64
emulator64-x86 -avd test -noaudio -no-window  -verbose -qemu &

adb kill-server
adb start-server
adb devices

git clone https://github.com/macaca-sample/sample-nodejs.git
cd sample-nodejs
make travis-android
