#!/usr/bin/env bash
# Build the actual React/Vite bundle copied into the DylanOS image.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/installer/dylanos-installer"

for tool in node npm; do
    command -v "$tool" >/dev/null || { echo "Falta herramienta: $tool" >&2; exit 1; }
done
node - <<'NODE'
const [major, minor] = process.versions.node.split(".").map(Number);
const supported = major >= 24 || (major === 22 && minor >= 12) || (major === 20 && minor >= 19);
if (!supported) {
    console.error(`El instalador Vite requiere Node.js 20.19+ o 22.12+; detectado ${process.versions.node}`);
    process.exit(1);
}
NODE

cd "$APP"
npm ci --no-audit --no-fund
npm run build
if [[ ! -s "$APP/dist/index.html" ]]; then
    echo "El build del instalador no generó dist/index.html." >&2
    exit 1
fi
