# Kali Mini PC

An Android application project for running **Kali Linux ARM64** in a managed, rootless Linux environment.

Kali Mini PC aims to provide the experience of a small Linux computer on Android, with two interfaces:

- **Mobile mode** — touch-first launcher, terminal, files, and runtime controls.
- **Desktop mode** — XFCE desktop in a resizable/full-screen display.

## Project goals

- No root and no bootloader unlock required.
- No Termux app required for normal operation.
- Install and manage the Kali root filesystem from inside the APK.
- Keep Linux rootfs in app-private storage, separate from the APK.
- Verify downloaded runtime assets and rootfs metadata before installation.
- Provide clear start/stop, storage, and diagnostics controls.
- Keep Android as the host operating system.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the technical design and implementation phases.

The initial runtime design uses an Android-managed ARM64 PRoot environment. Desktop mode will use an integrated graphical display stack. The exact X server / VNC integration will be selected after dependency and licensing validation.

## Current status

**Early development — UI and build scaffold first.**

The repository currently contains the project plan and initial Android application scaffold. The Kali installer, PRoot runtime, XFCE desktop, and managed Linux sessions are not yet implemented. Do not treat current builds as a working Kali environment.

## Device target

- Android ARM64 devices (arm64-v8a).
- Initial testing target: Infinix Note 50 Pro (Android 16).
- Rootless operation; kernel-level features such as monitor mode or packet injection are not promised.

## Security notes

- Kali runs inside a userspace environment; PRoot does **not** grant real root or kernel privileges.
- Only install rootfs and runtime assets from trusted, verified sources.
- The app must not execute arbitrary boot scripts from untrusted container metadata.
- Network services should bind to loopback by default.
- App-private storage is the default location for the root filesystem.

## Legal and attribution

Kali Linux is a trademark of Offensive Security. This project is independent and is not an official Kali Linux or Offensive Security product.

Tiny Container is used as an architectural reference. No Tiny Container source files are copied into this repository at this stage. Any future reuse or adaptation of GPL-licensed code must preserve applicable licenses, copyright notices, and source-distribution obligations. Third-party components will be documented before release.

## License

The project is intended to be distributed under **GPL-3.0-or-later**. The complete license text will be included before the first public source release.
