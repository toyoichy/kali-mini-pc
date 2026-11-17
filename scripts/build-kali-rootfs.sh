#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="${WORK_DIR:-$PWD/.work/kali-rootfs}"
EXTRACT_DIR="$WORK_DIR/extract"
ROOTFS_DIR="$EXTRACT_DIR/kali-arm64"
ARCHIVE_NAME="kali-nethunter-rootfs-minimal-arm64.tar.xz"
BASE_URL="https://kali.download/nethunter-images/current/rootfs"

mkdir -p "$WORK_DIR"
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"

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
tar -xJf "$WORK_DIR/$ARCHIVE_NAME" -C "$EXTRACT_DIR" --no-same-owner --exclude="kali-arm64/dev/*"
mkdir -p "$ROOTFS_DIR/dev/pts" "$ROOTFS_DIR/dev/shm"

echo "[4/7] Installing desktop packages in ARM64 chroot"
docker run --rm --privileged --platform linux/arm64 \
  -v "$ROOTFS_DIR:/mnt/rootfs" \
  kalilinux/kali-rolling:latest \
  bash -euc '
    mount -t proc proc /mnt/rootfs/proc
    mount --rbind /dev /mnt/rootfs/dev
    mount --rbind /sys /mnt/rootfs/sys
    rm -f /mnt/rootfs/etc/resolv.conf
    cp /etc/resolv.conf /mnt/rootfs/etc/resolv.conf
    mkdir -p /mnt/rootfs/tmp /mnt/rootfs/var/tmp
    chmod 1777 /mnt/rootfs/tmp /mnt/rootfs/var/tmp
    chroot /mnt/rootfs /bin/bash -euc "
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y --no-install-recommends \
        kali-linux-core xfce4 xfce4-terminal \
        tigervnc-standalone-server dbus-x11 sudo xterm
      if ! getent group 1000 >/dev/null 2>&1; then
        if getent group kali >/dev/null 2>&1; then
          groupmod --gid 1000 kali
        else
          groupadd --gid 1000 kali
        fi
      fi
      if id kali >/dev/null 2>&1; then
        usermod --uid 1000 --gid 1000 --shell /bin/bash kali
      else
        useradd --create-home --uid 1000 --gid 1000 --shell /bin/bash kali
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

echo "[6/7] Packaging rootfs with an exact .tiny.yaml archive path"
mkdir -p app/src/main/assets
ARCHIVE="$PWD/app/src/main/assets/rootfs.tar.zst"
# GNU tar normally stores paths with a leading "./" when archiving ".".
# Tiny Container extracts the profile by the exact member name ".tiny.yaml",
# so normalize archive member names at creation time.
sudo tar --zstd -cf "$ARCHIVE" \
  --transform='s,^\./,,' \
  -C "$ROOTFS_DIR" .

echo "[7/7] Verifying the packaged Tiny Container profile"
if ! sudo tar --zstd -tf "$ARCHIVE" | grep -Fxq '.tiny.yaml'; then
  echo "ERROR: archive does not contain an exact .tiny.yaml entry" >&2
  sudo tar --zstd -tf "$ARCHIVE" | head -40 >&2
  exit 1
fi
if ! sudo tar --zstd -xOf "$ARCHIVE" .tiny.yaml | grep -Fqx 'code: "kali"'; then
  echo "ERROR: .tiny.yaml is missing the expected Kali container code" >&2
  exit 1
fi
echo "Verified: .tiny.yaml exists at the archive root and identifies code=kali"
ls -lh "$ARCHIVE"
