#!/bin/bash

export PATH=$ANDROID_HOME/platform-tools:$PATH

start_emulator() {
  emulator -avd test -no-audio -no-window -memory 2048 -netfast -cpu-delay 0&# -no-boot-anim -gpu off &
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
  source ~/.nvm/nvm.sh
  nvm install 4
  nvm use 4
}

npm_install() {
  npm install
}

show_info() {
  java -version
  android list targets
}

download_and_extract() {
  if [ -n "$CI_BUILD_REPO" ]; then
    git clone $CI_BUILD_REPO /src
  else
    curl -o /tmp/src.tar.gz $SOURCE_CODE_URL
    tar -C /src -xvf /tmp/src.tar.gz
  fi
}

main() {
  download_and_extract
  show_info
  start_xvfb
  start_emulator
  wait_for_emulator
  press_menu_key
}

main
exec "$@"
