#!/usr/bin/env bash
# Agrega el repositorio apt de VSCodium para que el launcher codium.desktop
# incluido en el dock exista también en el perfil base.
set -euo pipefail

VSCODIUM_KEY_URL="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg"
VSCODIUM_KEYRING="/usr/share/keyrings/vscodium-archive-keyring.asc"
VSCODIUM_SOURCES="/etc/apt/sources.list.d/vscodium.sources"

echo "[setup-repos/default] Agregando repo apt de VSCodium..."
apt-get install -y --no-install-recommends ca-certificates wget
wget -qO "$VSCODIUM_KEYRING" "$VSCODIUM_KEY_URL"
if [ ! -s "$VSCODIUM_KEYRING" ]; then
    echo "ERROR: la llave GPG de VSCodium se descargó vacía" >&2
    exit 1
fi
cat > "$VSCODIUM_SOURCES" <<EOF
Types: deb
Architectures: amd64 arm64
URIs: https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs
Suites: vscodium
Components: main
Signed-By: $VSCODIUM_KEYRING
EOF
