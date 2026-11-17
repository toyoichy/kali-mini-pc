#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="\${WORK_DIR:-$PWD/.work/kali-rootfs}"
ROOTFS_DIR="$WORK_DIR/rootfs"
ARCHIVE_NAME="kali-nethunter-rootfs-minimal-arm64.tar.xz"
BASE_URL="https://kali.download/nethunter-images/current/rootfs"

mkdir -p "$WORK_DIR"
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"

echo "[1/7] Downloading official Kali ARM64 minimal rootfs"
curl --fail --location --retry 5 --retry-all-errors "$BASE_URL/$ARCHIVE_NAME" -o "$WORK_DIR/$ARCHIVE_NAME"
curl --fail --location --retry 5 --retry-all-errors "$BASE_URL/SHA256SUMS" -o "$WORK_DIR/SHA256SUMS"

echo "[2/7] Verifying Kali checksum"
EXPECTED="$(awk -v file="$ARCHIVE_NAME" '$2 == file || $2 == "*" file {print $1; exit}' "$WORK_DIR/SHA256SUMS")"
if [[ -z "$EXPECTED" ]]; then
  echo "Could not find $ARCHIVE_NAME in official SHA256SUMS" >&2
  exit 1
fi
printf '%s  %s\n' "$EXPECTED" "$WORK_DIR/$ARCHIVE_NAME" | sha256sum --check -

echo "[3/7] Extracting Kali rootfs"
tar -xJf "$WORK_DIR/$ARCHIVE_NAME" -C "$ROOTFS_DIR" --no-same-owner

echo "[4/7] Installing desktop packages in ARM64 chroot"
docker run --rm --privileged --platform linux/arm64 \
  -v "$ROOTFS_DIR:/mnt/rootfs" \
  kalilinux/kali-rolling:latest \
  bash -euc '
    mount -t proc proc /mnt/rootfs/proc
    mount --rbind /dev /mnt/rootfs/dev
    mount --rbind /sys /mnt/rootfs/sys
    cp /etc/resolv.conf /mnt/rootfs/etc/resolv.conf
    chroot /mnt/rootfs /bin/bash -euc "
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y --no-install-recommends \
        kali-linux-core xfce4 xfce4-terminal \
        tigervnc-standalone-server dbus-x11 sudo xterm
      getent group 1000 >/dev/null 2>&1 || groupadd --gid 1000 kali
      if ! id kali >/dev/null 2>&1; then
        useradd --create-home --uid 1000 --gid 1000 --shell /bin/bash kali
      else
        usermod --uid 1000 --gid 1000 --shell /bin/bash kali
      fi
      mkdir -p /etc/sudoers.d /home/kali/.vnc
      printf \"kali ALL=(ALL:ALL) NOPASSWD:ALL\\\\n\" > /etc/sudoers.d/90-kali-mini-pc
      chmod 0440 /etc/sudoers.d/90-kali-mini-pc
      cat > /home/kali/.vnc/xstartup <<EOF
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec dbus-launch --exit-with-session startxfce4
EOF
      chmod 0755 /home/kali/.vnc/xstartup
      chown -R 1000:1000 /home/kali
      apt-get clean
      rm -rf /var/lib/apt/lists/*
    "
    umount -R /mnt/rootfs/dev || true
    umount /mnt/rootfs/proc || true
  '

echo "[5/7] Adding Tiny Container Kali profile"
install -m 0644 scripts/kali.tiny.yaml "$ROOTFS_DIR/.tiny.yaml"

echo "[6/7] Packaging rootfs (profile first for Tiny Container detection)"
mkdir -p app/src/main/assets
tar --zstd -cf app/src/main/assets/rootfs.tar.zst -C "$ROOTFS_DIR" .tiny.yaml .
echo "[7/7] Rootfs package ready"
ls -lh app/src/main/assets/rootfs.tar.zst
