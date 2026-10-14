# ProtonVPN CLI Installer (Debian/Ubuntu)

A small, idempotent bash script that automates the official Proton VPN CLI
installation steps for Debian/Ubuntu-based distributions, based on
[Proton's own install guide](https://protonvpn.com/support/cli-debian-ubuntu).

Instead of copy-pasting six separate commands (and risking a broken state
if one of them fails or is run twice), this script does it in one shot,
checks your system first, and fails with a clear message if something
isn't right.

## What it does

1. Checks that the system uses `apt`/`dpkg` (Debian/Ubuntu-based).
2. Downloads Proton's repository package and adds it via `dpkg`
   (skipped if already added).
3. Runs `apt update`.
4. Installs `proton-vpn-cli` and `systemd-resolved`.
5. Enables and starts the `systemd-resolved` service.
6. Verifies that the `protonvpn` command is available.
7. Prints the next manual steps (sign-in and connect require your own
   Proton account, so they are not automated).

Safe to run more than once — it detects what's already installed/configured
and skips those steps.

## Requirements

- A Debian or Ubuntu-based Linux distribution (`apt` + `dpkg`).
- `sudo` privileges (or run as root).
- `wget`.

## Usage

```bash
chmod +x install_protonvpn.sh
./install_protonvpn.sh
```

After installation finishes, sign in and connect manually:

```bash
protonvpn signin <your_username>
protonvpn connect
```

## Notes

- This script only automates installation. It never asks for or stores
  your Proton credentials.
- Tested on Debian/Ubuntu-based systems. Not officially supported on
  Ubuntu Server or Raspbian (per Proton's own guide).

## License

MIT
