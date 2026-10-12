#!/bin/sh
# Install the roblox-studio-mcp launcher and register it with Claude Code.
#   ./install.sh               install (or update)
#   ./install.sh --uninstall   remove
# Also works piped from curl; the launcher is then downloaded from GitHub.
set -eu

REPO_RAW="https://raw.githubusercontent.com/Jecobe/roblox-mcp-on-vinegar/main"
NAME="Roblox_Studio"
BIN="$HOME/.local/bin/roblox-studio-mcp"
NATIVE="$HOME/.local/share/vinegar"
FLATPAK="$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar"

have() { command -v "$1" >/dev/null 2>&1; }
has_studio() { ls "$1"/versions/*/StudioMCP.exe >/dev/null 2>&1; }

if [ "${1:-}" = "--uninstall" ]; then
    have claude && claude mcp remove -s user "$NAME" >/dev/null 2>&1 || true
    rm -f "$BIN"
    echo "Removed $BIN and the $NAME MCP server."
    exit 0
fi

# Install the launcher: use the copy next to this script, else download it.
SRC="$(dirname "$0")/roblox-studio-mcp"
mkdir -p "$(dirname "$BIN")"
if [ -f "$SRC" ]; then
    install -m755 "$SRC" "$BIN"
else
    curl -fsSL "$REPO_RAW/roblox-studio-mcp" -o "$BIN"
    chmod 755 "$BIN"
fi
echo "Installed $BIN"

# Find Vinegar's Studio install, preferring native over Flatpak.
VINEGAR_DIR="${VINEGAR_DIR:-}"
if [ -z "$VINEGAR_DIR" ]; then
    if has_studio "$NATIVE"; then VINEGAR_DIR="$NATIVE"
    elif has_studio "$FLATPAK"; then VINEGAR_DIR="$FLATPAK"
    else
        echo "warning: no StudioMCP.exe found; launch Studio through Vinegar once, then re-run this." >&2
        VINEGAR_DIR="$NATIVE"
    fi
fi
echo "Using Vinegar at $VINEGAR_DIR"

if have claude; then
    claude mcp remove -s user "$NAME" >/dev/null 2>&1 || true
    if [ "$VINEGAR_DIR" = "$NATIVE" ]; then
        claude mcp add -s user "$NAME" -- "$BIN"
    else
        claude mcp add -s user "$NAME" -e VINEGAR_DIR="$VINEGAR_DIR" -- "$BIN"
    fi
else
    echo "Claude Code not found; point your MCP client at $BIN (stdio)."
    [ "$VINEGAR_DIR" = "$NATIVE" ] || echo "  and set VINEGAR_DIR=$VINEGAR_DIR"
fi

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "note: ~/.local/bin is not on your PATH (only matters for running it by hand)." ;; esac

echo
echo "Last step: in Studio, open Assistant -> ... -> Manage MCP Servers and turn on"
echo "\"Enable Studio as MCP server\". Then restart Claude Code or run /mcp."
