# Kali Mini PC — Technical Architecture

## 1. Product definition

Kali Mini PC is an Android host application that manages a Kali Linux ARM64 userspace environment. It is not a replacement Android OS and does not require root or bootloader unlocking.

The app offers two front ends over one Linux runtime:

- **Mobile mode:** touch-first navigation, terminal, file browser, package status, and session controls.
- **Desktop mode:** XFCE session displayed inside the app, with optional keyboard/mouse support and a full-screen layout.

## 2. Runtime layers

```text
Android application (Kotlin)
├── Mobile UI / Desktop UI switch
├── Runtime manager
│   ├── Download manager (resume + progress)
│   ├── SHA-256 verification
│   ├── Safe archive extraction
│   ├── Install / start / stop / repair
│   └── Storage and diagnostics
├── Terminal session controller
├── Desktop display controller
└── App-private data
    ├── bootstrap/       (Android-side ARM64 tools)
    ├── rootfs/kali/     (Kali ARM64 root filesystem)
    ├── downloads/       (temporary verified downloads)
    └── sessions/        (runtime state and logs)

Android kernel
└── PRoot userspace translation
    └── Kali Linux ARM64
        ├── shell + core utilities
        ├── APT
        ├── XFCE (desktop profile)
        └── optional user-installed packages
```

## 3. Runtime strategy

### Phase 1: PRoot proof of concept

Use an ARM64 PRoot binary and the minimum required Android-side bootstrap utilities. The runtime must be launched by the APK using app-private paths; users should not need to open Termux.

PRoot is userspace emulation of filesystem/process views, not real root. It cannot provide kernel capabilities that Android has not exposed to the app.

### Phase 2: Kali rootfs installation

- Select a supported official Kali ARM64 rootfs/distribution source.
- Pin the release and architecture in a versioned manifest.
- Download with resumable transfers.
- Verify a trusted SHA-256 checksum before extraction.
- Extract into a staging directory, validate expected files, then atomically promote to the active rootfs.
- Never execute scripts from an unverified archive.
- Keep rootfs data outside the APK so app updates do not redownload it.

The exact official image URL and checksum format must be verified against current Kali publishing metadata before implementing the downloader.

### Phase 3: Terminal

Provide an in-app terminal connected to a managed shell process. The terminal must support process lifecycle, input/output streaming, resize, cancellation, and clean shutdown. Avoid shell command concatenation with untrusted UI input; pass validated arguments or use controlled scripts.

### Phase 4: Desktop

Evaluate and pin a graphical stack for Android ARM64. Candidate architecture is an integrated X server/display component plus XFCE inside Kali. Before choosing dependencies, audit their licenses, Android API compatibility, maintenance status, and packaging requirements.

Desktop mode must support start/stop, resolution and scaling, touch gestures, external keyboard and mouse, and clipboard integration where supported.

### Phase 5: Mobile mode

Mobile mode is a native Android UI, not a second Linux desktop. It provides quick access to terminal, files, packages, runtime status, and settings. Both modes use the same rootfs and session manager.

## 4. Android app modules

Suggested package structure:

- app/ui/ — mobile and desktop mode navigation.
- runtime/api/ — runtime contracts and state models.
- runtime/install/ — download, checksum, extraction, migration.
- runtime/process/ — PRoot and shell process lifecycle.
- runtime/terminal/ — terminal session adapter.
- runtime/desktop/ — display server and XFCE session adapter.
- storage/ — app-private paths and storage accounting.
- security/ — archive validation, checksum policy, command validation.
- diagnostics/ — logs and support bundle.

## 5. Security requirements

- No root requirement and no bootloader modification.
- Rootfs remains in app-private storage by default.
- Validate archive paths to prevent path traversal during extraction.
- Verify all downloaded binary assets and rootfs metadata.
- No fixed secrets in source code.
- Bind local display/control services to loopback unless a user explicitly enables a secured external connection.
- Do not expose Android shared storage to Kali by default.
- Clearly label the environment as rootless and explain unavailable kernel-level features.
- Do not ship offensive tooling enabled by default; users install packages intentionally and must use them lawfully.

## 6. Performance and device constraints

The first target is ARM64 Android. Rootfs and XFCE consume significant storage and memory. The installer should offer a minimal base profile first, then optional desktop packages. Do not bundle the full Kali rootfs inside the APK.

Initial validation should measure download and extraction time, idle and active RAM use, terminal responsiveness, desktop frame rate and touch latency, battery use, thermal behavior, and stop/restart reliability under Android background restrictions.

## 7. Implementation milestones

1. Android project scaffold and CI debug build.
2. Mobile UI shell and mode switch.
3. Runtime abstraction and storage layout.
4. ARM64 PRoot bootstrap proof of concept.
5. Verified Kali rootfs installer.
6. Managed terminal sessions.
7. XFCE desktop display integration.
8. Package manager and diagnostics.
9. Device testing and signed release process.

## 8. Reference projects

- Tiny Container: https://github.com/Cateners/tiny_container
- PRoot-Distro: https://github.com/termux/proot-distro
- Termux:X11: https://github.com/termux/termux-x11
- Kali NetHunter: https://www.kali.org/docs/nethunter/nethunter-rootless/

These are references, not claims of compatibility or permission to copy code without observing each project's license.
