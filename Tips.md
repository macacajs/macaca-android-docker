
# Docker For Android (Tips)

## 0. Start container
```
docker run --privileged  --cap-add=ALL  --entrypoint=/bin/bash --name #Your Container Name# -p 5037:5037 -it macacajs/nosmoke-android:#latest version#
```

## 1. Check and install android emulator

- check which sdk and abi you can install:

```
android list targets
```
- select and install an specific emulator:

```
echo "y" | android update sdk -a --no-ui --filter sys-img-x86_64-android-23,Android-23
```


## 2. Image acceleration

For linux env with CPU architecture of x86, you have to checkout the tips given by [this](https://developer.android.com/studio/run/emulator-acceleration.html) and check whether KVM is available and supported with your CPU

```
kvm-ok
```

if your kvm setting is disabled by your host OS, turn it on by rebooting your host OS and enable VT via BIOS setup.
[check this](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/virtualization/sect-virtualization-troubleshooting-enabling_intel_vt_and_amd_v_virtualization_hardware_extensions_in_bios)

## 3. Start Emulator
create avd:

```
echo "no" | android create avd -f -n test -t android-23 --abi default/x86_64
```

start emulator:

```
emulator64-x86 -avd test -noaudio -no-window  -verbose -qemu &
```

## 4. Check ADB status
```
adb kill-server
adb start-server
adb devices
```
