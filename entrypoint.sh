#!/bin/bash

export PATH=$ANDROID_HOME/platform-tools:$PATH

start_emulator() {
  emulator -avd test -no-audio -no-window -memory 2048 -netfast -cpu-delay 0 -no-boot-anim -no-accel &
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

press_menu_key() {
  adb shell input keyevent 82 &
}

start_xvfb() {
  Xvfb :99 -ac -screen 0 1024x768x8 &
}

prepare_node() {
  git clone https://github.com/creationix/nvm.git --depth=1 ~/.nvm
  source ~/.nvm/nvm.sh
  nvm install 7
  nvm use 7
}

npm_install() {
  npm install
}

show_info() {
  java -version
  android list targets
}

main() {
  show_info
  start_xvfb
  prepare_node
  start_emulator
  wait_for_emulator
  press_menu_key
}

main
exec "$@"
