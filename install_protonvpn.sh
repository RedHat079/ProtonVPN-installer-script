#!/usr/bin/env bash
#
# ProtonVPN CLI installer for Debian/Ubuntu-based distros (apt/dpkg).
# Based on proton_install_step_by_step.txt
#
# Usage:
#   ./install_protonvpn.sh
#
# The script is idempotent: it can be run again without breaking anything.

set -euo pipefail

REPO_DEB_URL="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb"
REPO_DEB_FILE="protonvpn-stable-release_1.0.8_all.deb"
WORKDIR="$(mktemp -d)"

log()  { printf '\n\033[1;32m[*] %s\033[0m\n' "$1"; }
warn() { printf '\n\033[1;33m[!] %s\033[0m\n' "$1"; }
die()  { printf '\n\033[1;31m[x] %s\033[0m\n' "$1" >&2; exit 1; }

cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

require_root_tools() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        die "This script needs 'sudo' available, or must be run as root."
    fi
}

check_distro() {
    if ! command -v apt >/dev/null 2>&1 || ! command -v dpkg >/dev/null 2>&1; then
        die "This script requires a Debian/Ubuntu-based distro (apt + dpkg). None detected."
    fi
}

check_already_installed() {
    if command -v protonvpn >/dev/null 2>&1; then
        warn "protonvpn is already installed on this system. Continuing to make sure everything is up to date."
        return 0
    fi
    return 1
}

add_proton_repo() {
    if dpkg -l protonvpn-stable-release >/dev/null 2>&1; then
        log "The ProtonVPN repository is already added."
        return 0
    fi

    log "Downloading the ProtonVPN repository package..."
    if ! wget -q -O "$WORKDIR/$REPO_DEB_FILE" "$REPO_DEB_URL"; then
        die "Could not download $REPO_DEB_URL. Check your connection or the URL."
    fi

    log "Adding the ProtonVPN repository (dpkg -i)..."
    $SUDO dpkg -i "$WORKDIR/$REPO_DEB_FILE"
}

install_packages() {
    log "Updating package indexes (apt update)..."
    $SUDO apt update

    log "Installing proton-vpn-cli..."
    $SUDO apt install -y proton-vpn-cli

    log "Installing systemd-resolved..."
    $SUDO apt install -y systemd-resolved
}

enable_systemd_resolved() {
    if command -v systemctl >/dev/null 2>&1; then
        log "Enabling and starting systemd-resolved..."
        $SUDO systemctl enable --now systemd-resolved
    else
        warn "systemctl is not available; skipping automatic systemd-resolved activation."
    fi
}

verify_install() {
    log "Verifying installation..."
    if command -v protonvpn >/dev/null 2>&1; then
        protonvpn --version 2>/dev/null || true
        log "ProtonVPN CLI installed successfully."
    else
        die "protonvpn was not found after installation. Check the previous steps."
    fi
}

print_next_steps() {
    cat <<'EOF'

Installation complete.

Next steps (manual, require your Proton account):

    protonvpn signin <your_username>
    protonvpn connect

EOF
}

main() {
    require_root_tools
    check_distro
    check_already_installed || true
    add_proton_repo
    install_packages
    enable_systemd_resolved
    verify_install
    print_next_steps
}

main "$@"
