"""Verify the default dock's VSCodium launcher resolves to an installed app."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
LAYOUT = ROOT / "themes/lookandfeel/org.dylanos.crimson/contents/layouts/org.kde.plasma.desktop-layout.js"


class DockLauncherTest(unittest.TestCase):
    def test_vscode_compatible_launcher_has_a_real_default_package(self):
        layout = LAYOUT.read_text(encoding="utf-8")
        self.assertIn('"applications:codium.desktop"', layout)
        self.assertNotIn('"applications:code.desktop"', layout)

        default_packages = (ROOT / "packages/default/packages.list").read_text(encoding="utf-8")
        packages = [line.strip() for line in default_packages.splitlines()
                    if line.strip() and not line.lstrip().startswith("#")]
        self.assertIn("codium", packages)

        repo_setup = (ROOT / "packages/default/setup-repos.sh").read_text(encoding="utf-8")
        self.assertIn("vscodium-deb-rpm-repo/debs", repo_setup)
        self.assertIn("Signed-By: $VSCODIUM_KEYRING", repo_setup)


if __name__ == "__main__":
    unittest.main()
