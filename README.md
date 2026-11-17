# Kali Mini PC

Kali Mini PC is a new Android APK built from the open-source Tiny Container project, adapted to ship and automatically install a Kali Linux ARM64 root filesystem.

The goal is to preserve Tiny Container's working Linux runtime and Android integrations rather than reimplementing them:

- ARM64 PRoot runtime and bootstrap
- Container import/install/management
- Integrated terminal
- AVNC and Termux:X11 graphical frontends
- Audio and microphone forwarding
- Storage/file access integrations

## Kali system image

The first target image is Kali Linux ARM64 with XFCE and TigerVNC. The build pipeline obtains the official Kali NetHunter minimal ARM64 root filesystem, verifies its SHA-256 checksum, installs the desktop packages in an ARM64 build environment, adds the Tiny Container .tiny.yaml profile, and packages it as rootfs.tar.zst.

The APK's existing first-launch built-in-rootfs flow installs that image into app-private storage. The root filesystem is not mixed with Android and does not replace Android.

## Device and privilege model

- Android ARM64 (arm64-v8a)
- Rootless PRoot; no root and no bootloader unlock required
- No Termux app required for normal use
- PRoot does not provide real kernel root privileges. Wi-Fi monitor mode, packet injection, HID gadget features, and other kernel-dependent NetHunter features are not promised.

## Build

The build workflow checks out the pinned Tiny Container upstream source, applies Kali Mini PC branding, downloads the matching prebuilt ARM64 JNI libraries, builds the Kali root filesystem, and produces a debug APK.

Run the Android CI workflow from GitHub Actions. The APK is published as the kali-mini-pc-debug artifact.

See:
- docs/UPSTREAM_PORT.md
- scripts/kali.tiny.yaml
- scripts/build-kali-rootfs.sh

## Upstream and license

This project is based on Cateners/tiny_container, Copyright (C) 2026 Caten Hu, licensed under GPL-3.0. The upstream source and its license notices are retained in the build. The build is pinned to Tiny Container v4.2.2 so the source matches its published jniLibs.zip release asset.

Kali Linux is a trademark of Offensive Security. Kali Mini PC is an independent community project and is not an official Kali or Offensive Security product.
