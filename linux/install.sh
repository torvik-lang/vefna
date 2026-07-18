#!/usr/bin/env sh
# install.sh - Vefna installer:
#   curl -fsSL https://raw.githubusercontent.com/torvik-lang/vefna/main/linux/install.sh | sh
#
# Installs the prebuilt vefna binary to ~/.vefna/bin and adds it to PATH.
# Pin a version:   VEFNA_VERSION=1.0.0 sh install.sh
# Uninstall:       sh install.sh --uninstall
set -e

INSTALL_DIR="$HOME/.vefna"; BIN_DIR="$INSTALL_DIR/bin"
REPO="https://github.com/torvik-lang/vefna"
ASSET="vefna-linux-x86_64"

dl() { if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"; else wget -qO "$2" "$1"; fi; }

if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed $INSTALL_DIR."
    echo "PATH lines mentioning .vefna/bin in ~/.bashrc / ~/.profile can be deleted by hand."
    exit 0
fi

if [ -n "${VEFNA_VERSION:-}" ]; then
    URL="$REPO/releases/download/v$VEFNA_VERSION/$ASSET"
else
    URL="$REPO/releases/latest/download/$ASSET"
fi

mkdir -p "$BIN_DIR"
echo "-- Downloading vefna ..."
dl "$URL" "$BIN_DIR/vefna"
chmod +x "$BIN_DIR/vefna"

# PATH registration (idempotent), matching the Torvik installer's approach.
PATH_LINE='export PATH="$HOME/.vefna/bin:$PATH"'
for rc in "$HOME/.bashrc" "$HOME/.profile"; do
    if [ -f "$rc" ] && ! grep -qs '\.vefna/bin' "$rc"; then
        printf '\n%s\n' "$PATH_LINE" >> "$rc"
        echo "  PATH added to $rc"
    fi
done

echo ""
"$BIN_DIR/vefna" version
echo "Vefna installed to ~/.vefna/"
echo ">>> Activate in THIS terminal:   . ~/.bashrc    (or open a new terminal)"
echo "    Then:  vefna new mysite"
