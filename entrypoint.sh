#!/bin/bash
set -eo pipefail

cd '/aurbuilder'

curl -fsSL 'https://github.com/Frogging-Family/linux-tkg/archive/refs/heads/master.tar.gz' | tar --strip=1 -xzf-

patch -p1 < '/github/workspace/tkg.patch'
# Use tmpfs if we have >=16GB tmpfs
if [ "$(df --output='size' /tmp | awk 'END{print $1}')" -gt 16463899 ]; then
  patch -p1 < '/github/workspace/tkg-tmpfs.patch'
fi

# Build
makepkg -fs --noconfirm

# Deal with artifacts
for FILE in *'.pkg.tar.zst'; do
  sha256sum "${FILE}" > "${FILE}.sha256sum"
  sudo mv "${FILE}"* '/github/workspace'
done
