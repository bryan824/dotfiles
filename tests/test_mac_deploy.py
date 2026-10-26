"""Check native mise first-run behavior in disposable homes, without installing tools.

Run with: uv run --no-project tests/test_mac_deploy.py -v
The clone tests use this repository's committed configuration, not a network remote.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MISE = shutil.which("mise")
GIT = shutil.which("git")
AGE_KEYGEN = shutil.which("age-keygen")
ROLES = {
    "work": ["desktop", "dev"],
    "bryan": ["desktop", "dev", "backup", "bryan"],
    "irene": ["desktop", "backup", "irene"],
}
BASE_TARGETS = {
    "~/.zshenv", "~/.config/bat", "~/.config/ripgrep", "~/.config/rustfmt",
    "~/.config/git/ignore", "~/.config/starship.toml", "~/.local/bin/up.sh",
    "~/.config/mise", "~/.config/git/config", "~/.config/zsh/80_host.zsh",
    "~/.config/zsh", "~/.config/nvim", "~/.config/nvim/nvim-pack-lock.json",
}
DESKTOP_TARGETS = {
    "~/.config/television", "~/.config/kitty", "~/.config/kitty/current-theme.conf",
}
DEV_TARGETS = {"~/.config/zed/settings.json", "~/.config/k9s", "~/.config/k9s/config.yaml"}
BACKUP_TARGETS = {"~/.rclone_excludes.txt", "~/.kopiaignore", "~/.local/bin/kopia-nightly.sh"}


@unittest.skipUnless(sys.platform == "darwin" and MISE and GIT, "Requires macOS, mise, and Git")
class NativeFirstRunTests(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(prefix="mise-first-run-test-")
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.home = self.root / "home"
        self.repo = self.home / ".dotfiles"
        self.config = self.home / ".config/mise"
        self.config.mkdir(parents=True)
        self.local = '[vars]\ngit_name = "Fixture"\ngit_email = "fixture@invalid"\n'
        (self.config / "config.local.toml").write_text(self.local)
        self.env = {
            "HOME": str(self.home),
            "PATH": "/usr/bin:/bin:/usr/sbin:/sbin",
            "MISE_CONFIG_DIR": str(self.config),
            "MISE_SYSTEM_CONFIG_DIR": str(self.root / "system"),
            "MISE_DATA_DIR": str(self.root / "data"),
            "MISE_STATE_DIR": str(self.root / "state"),
            "MISE_CACHE_DIR": str(self.root / "cache"),
            "MISE_OFFLINE": "true",
            "MISE_COLOR": "0",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
        }
        self.select_role("work")

    def select_role(self, role):
        self.layers = ROLES[role]
        self.rc = "env = " + json.dumps(self.layers) + "\n"
        (self.config / "miserc.toml").write_text(self.rc)
        self.env["MISE_ENV"] = ",".join(self.layers)

    def mise(self, *args, cwd=None, env=None, input=None):
        return subprocess.run(
            [MISE, "-C", str(cwd or self.home), *args],
            env=self.env if env is None else env, input=input,
            text=True, capture_output=True, timeout=60, check=False,
        )

    def succeeds(self, *args, **kwargs):
        result = self.mise(*args, **kwargs)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def bootstrap_from(self, *flags):
        return self.mise(
            "bootstrap", "--from", ROOT.as_uri(), "--from-dir", str(self.repo),
            "--only", "dotfiles", *flags,
        )

    def copy_source(self, trust=True):
        files = subprocess.run(
            [GIT, "-C", str(ROOT), "ls-files", "-z"],
            check=True, capture_output=True,
        ).stdout.decode().split("\0")
        for relative in filter(None, files):
            target = self.repo / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / relative, target, follow_symlinks=False)
        self.assertFalse((self.repo / ".git").exists())
        if trust:
            self.succeeds("trust", "--all", cwd=self.repo)

    def assert_deployed(self, targets):
        result = self.succeeds("dot", "status", "--json")
        files = json.loads(result.stdout)["files"]
        self.assertEqual({entry["target"] for entry in files}, targets)
        self.assertTrue(all(entry["state"] == "applied" for entry in files), files)
        self.assertTrue((self.config / "config.toml").is_symlink())
        self.assertFalse(self.config.is_symlink())
        for filename, expected in (("miserc.toml", self.rc), ("config.local.toml", self.local)):
            path = self.config / filename
            self.assertFalse(path.is_symlink())
            self.assertEqual(path.read_text(), expected)
            self.assertFalse((self.repo / ".config/mise" / filename).exists())
        self.assertIn("name = Fixture", (self.home / ".config/git/config").read_text())
        self.assertFalse((self.root / "data/installs").exists())
        self.assertFalse((self.home / "Library/LaunchAgents").exists())

    def test_new_checkout_dry_run_only_previews_clone(self):
        result = self.bootstrap_from("--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("clone", result.stdout + result.stderr)
        self.assertFalse(self.repo.exists())
        self.assertFalse((self.config / "config.toml").exists())
        self.assertFalse((self.home / ".zshenv").exists())

    def test_work_mac_bootstraps_without_manual_config_link_and_reruns(self):
        result = self.bootstrap_from("--yes")
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = BASE_TARGETS | DESKTOP_TARGETS | DEV_TARGETS
        self.assert_deployed(expected)
        self.assertTrue((self.repo / ".git").is_dir())
        self.succeeds("bootstrap", "--only", "dotfiles", "--yes")
        self.assert_deployed(expected)
        # The effective layer list remains set in miserc when the process omits it.
        env = dict(self.env)
        del env["MISE_ENV"]
        result = self.succeeds("config", "ls", "--json", env=env)
        names = {Path(entry["path"]).name for entry in json.loads(result.stdout)}
        self.assertIn("config.desktop.toml", names)
        self.assertIn("config.dev.toml", names)
        self.assertNotIn("config.backup.toml", names)
        self.assertNotIn("config.bryan.toml", names)

    def test_irene_files_only_source_previews_applies_and_reruns(self):
        self.select_role("irene")
        self.copy_source()
        self.succeeds("dot", "diff", cwd=self.repo)
        self.succeeds("bootstrap", "--only", "dotfiles", "--dry-run", cwd=self.repo)
        self.assertFalse((self.config / "config.toml").exists())
        self.succeeds("bootstrap", "--only", "dotfiles", "--yes", cwd=self.repo)
        expected = BASE_TARGETS | DESKTOP_TARGETS | BACKUP_TARGETS
        self.assert_deployed(expected)
        self.succeeds("bootstrap", "--only", "dotfiles", "--yes")
        self.assert_deployed(expected)
        self.assertFalse((self.repo / ".git").exists())

    @unittest.skipUnless(AGE_KEYGEN, "Requires the already-configured age-keygen CLI")
    def test_bryan_with_synthetic_age_identity_deploys_all_layers(self):
        self.select_role("bryan")
        self.copy_source(trust=False)
        key = self.config / "age.txt"
        subprocess.run(
            [AGE_KEYGEN, "-o", str(key)], env=self.env,
            check=True, capture_output=True,
        )
        recipient = subprocess.run(
            [AGE_KEYGEN, "-y", str(key)], env=self.env,
            check=True, capture_output=True, text=True,
        ).stdout.strip()
        path = self.repo / ".config/mise/config.bryan.toml"
        lines = path.read_text().splitlines()
        token_lines = [i for i, line in enumerate(lines) if line.startswith("IPINFO_TOKEN = ")]
        self.assertEqual(len(token_lines), 1)
        del lines[token_lines[0]]
        path.write_text("\n".join(lines) + "\n")
        self.succeeds("trust", "--all", cwd=self.repo)
        self.succeeds(
            "set", "--file", str(path), "--age-encrypt", "--age-recipient", recipient,
            "--stdin", "IPINFO_TOKEN", cwd=self.repo, input="synthetic fixture value\n",
        )
        self.succeeds("dot", "diff", cwd=self.repo)
        self.succeeds("bootstrap", "--only", "dotfiles", "--yes", cwd=self.repo)
        expected = BASE_TARGETS | DESKTOP_TARGETS | DEV_TARGETS | BACKUP_TARGETS
        self.assert_deployed(expected)
        self.succeeds("bootstrap", "--only", "dotfiles", "--yes")
        self.assert_deployed(expected)
        self.assertEqual(key.stat().st_mode & 0o777, 0o600)
        self.assertFalse((self.repo / ".config/mise/age.txt").exists())

    def test_bryan_missing_age_identity_stops_before_dotfile_deployment(self):
        self.select_role("bryan")
        result = self.bootstrap_from("--yes")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Failed to decrypt IPINFO_TOKEN", result.stderr)
        self.assertIn("No age identities", result.stderr)
        self.assertFalse((self.config / "age.txt").exists())
        self.assertFalse((self.config / "config.toml").exists())
        self.assertFalse((self.home / ".zshenv").exists())
        self.assertFalse((self.root / "data/installs").exists())
        self.assertFalse((self.home / "Library/LaunchAgents").exists())

    def test_first_run_preview_rejects_regular_file_blocking_a_symlink(self):
        self.copy_source()
        target = self.home / ".zshenv"
        target.write_text("local work\n")
        result = self.mise("bootstrap", "--only", "dotfiles", "--dry-run", cwd=self.repo)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("refusing to overwrite", result.stderr)
        self.assertEqual(target.read_text(), "local work\n")
        self.assertFalse((self.config / "config.toml").exists())


if __name__ == "__main__":
    unittest.main()
