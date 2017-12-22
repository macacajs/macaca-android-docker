#!/bin/bash

install_node() {
    git clone https://github.com/creationix/nvm.git --depth=1 ~/.nvm
    source ~/.nvm/nvm.sh
    nvm install 7
    nvm use 7
}

install_macaca() {
    export CHROMEDRIVER_CDNURL=https://npm.taobao.org/mirrors/
    export ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/

    npm install -g cnpm --registry=https://registry.npm.taobao.org
    cnpm i -g macaca-cli
    cnpm i -g macaca-android
    macaca -v
    macaca doctor
}

install_emulator() {
    android list targets
    echo "y" | android update sdk -a --no-ui --filter sys-img-x86_64-android-23,Android-23
    echo "no" | android create avd -f -n test -t android-23 --abi default/x86_64
    emulator64-x86 -avd test -noaudio -no-window  -verbose -qemu &
}

wait_for_emulator() {
    echo "Waiting for emulator to start..."

    bootanim=""
    failcounter=0
    until [[ "$bootanim" =~ "stopped" ]]; do
    bootanim=`adb -e shell getprop init.svc.bootanim 2>&1`
    if [[ "$bootanim" =~ "not found" ]]; then
        let "failcounter += 1"
        if [[ $failcounter -gt 3 ]]; then
            echo "  Failed to start emulator"
            exit 1
        fi
    fi
    sleep 1
    done

    echo "emulator started"
}

refresh_adb() {
    adb kill-server
    adb start-server
    adb devices
}

press_menu_key() {
    adb shell input keyevent 82 &
}

start_test() {
    git clone https://github.com/macaca-sample/sample-nodejs.git
    cd sample-nodejs
    make travis-android
}

main() {
    install_node
    install_macaca
    install_emulator
    wait_for_emulator
    refresh_adb
    press_menu_key
    start_test
}

main

exec "$@"
