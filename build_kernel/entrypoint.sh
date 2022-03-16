#!/bin/bash
set -eo pipefail

cd '/aurbuilder'


printf '::group::Download latest TKG release\n'
curl -fsSL 'https://github.com/Frogging-Family/linux-tkg/archive/refs/heads/master.tar.gz' | tar --strip=1 -xvzf-
printf '::endgroup::\n'


printf '::group::Patching TKG configuration\n'
patch --verbose -ignore-whitespace -p1 < '/github/workspace/tkg.patch' || (cat customization.cfg.rej; exit 1)

# Use tmpfs if we have >=16GB tmpfs
if [ "$(df --output='size' /tmp | awk 'END{print $1}')" -gt 16463899 ]; then
  patch --verbose --ignore-whitespace -p1 < '/github/workspace/tkg-tmpfs.patch'
fi

grep '_version=' ./customization.cfg
sed -i "s/_version=\"\"/_version=\"${1}\"" ./customization.cfg
grep '_version=' ./customization.cfg
printf '::endgroup::\n'


# Build
printf '::group::Updating pacman caches\n'
sudo pacman -Syy
printf '::endgroup::\n::group::Building kernel\n'
makepkg -fs --noconfirm
printf '::endgroup::\n'

printf '::group::Creating checksums\n'
# Deal with artifacts
for FILE in *'.pkg.tar.zst'; do
  sha256sum "${FILE}" | tee "${FILE}.sha256sum"
  sudo mv -v "${FILE}"* '/github/workspace'
done
printf '::endgroup::\n'
