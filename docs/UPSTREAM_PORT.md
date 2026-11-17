# Tiny Container upstream port

## Pinned upstream

- Repository: https://github.com/Cateners/tiny_container
- Release: v4.2.2
- Commit: 2723327f00764215f6b4e06658788bb352089667
- License: GPL-3.0
- Matching native bootstrap archive: jniLibs.zip from the v4.2.2 GitHub release.

The Android UI, PRoot process integration, terminal, container manager, AVNC, Termux:X11, audio, and storage integration are inherited from this upstream source. Kali Mini PC applies a new application ID and product label and supplies a Kali rootfs as the built-in container image.

## Why the app source is fetched at build time

The repository keeps a pinned upstream revision and a small set of reproducible port/build scripts rather than duplicating hundreds of upstream source files. The CI workflow checks out the exact pinned commit before applying the product changes. This keeps the upstream attribution clear and makes updating the base an explicit engineering change.

## Kali rootfs flow

1. Download the official Kali NetHunter minimal ARM64 rootfs archive.
2. Verify its checksum against Kali's published SHA256SUMS.
3. Extract it in a temporary build directory.
4. Install XFCE, TigerVNC, DBus, sudo, and terminal packages in an ARM64 build environment.
5. Ensure a kali account with UID/GID 1000 exists.
6. Add the .tiny.yaml profile from this repository.
7. Create rootfs.tar.zst with .tiny.yaml as the first archive entry.
8. Copy it to Tiny Container's app/src/main/assets/rootfs.tar.zst.

Tiny Container already detects this built-in asset and automatically installs it on first launch. This avoids adding a separate installer framework for the first MVP.

## Important limitations

- The first MVP provides Kali ARM64 userspace under PRoot. It is not a bootable phone OS.
- PRoot does not expose kernel capabilities unavailable to the Android app.
- The first desktop frontend is AVNC/VNC. Termux:X11 remains available through the upstream app, but the initial Kali profile enables AVNC by default.
- The initial app label and application ID are changed. Some upstream internal package names remain com.fct.tc4 to avoid an unnecessary mass package rename and preserve native integration compatibility.
- The current APK is a debug build. Release signing and device acceptance testing are separate steps.
