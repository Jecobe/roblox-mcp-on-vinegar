# roblox-mcp-on-vinegar

Lets Claude Code (or any other MCP client) on Linux control Roblox Studio running under [Vinegar](https://vinegarhq.org).

Roblox Studio comes with its own MCP server, `StudioMCP.exe`. It's a Windows program, so it needs Wine to run on Linux. `roblox-studio-mcp` is a small shell script that finds the newest `StudioMCP.exe` that Vinegar installed and runs it with Vinegar's own Wine (kombucha) in Studio's Wine prefix. The MCP client talks to it over stdio.

This repo only contains the launcher script. It doesn't include or change any Roblox files.

## Requirements

- Roblox Studio installed and launched at least once through Vinegar
- An MCP client, such as Claude Code

## Install

One command (no clone needed):

```sh
curl -fsSL https://raw.githubusercontent.com/Jecobe/roblox-mcp-on-vinegar/main/install.sh | sh
```

Or clone the repo and run the installer:

```sh
git clone https://github.com/Jecobe/roblox-mcp-on-vinegar
cd roblox-mcp-on-vinegar
./install.sh
```

The installer:
- copies the launcher to `~/.local/bin/roblox-studio-mcp`
- finds Vinegar's Studio install. Native and Flatpak Vinegar both work with nothing extra to set up.
- registers the `Roblox_Studio` MCP server with Claude Code at user scope, replacing an older registration of the same name

Running it again updates the install. `./install.sh --uninstall` removes the launcher and the MCP server. To choose the Vinegar folder yourself, set `VINEGAR_DIR` before running the installer.

### Manual install

```sh
install -Dm755 roblox-studio-mcp ~/.local/bin/roblox-studio-mcp
claude mcp add -s user Roblox_Studio -- ~/.local/bin/roblox-studio-mcp
```

If you only have Flatpak Vinegar, add `-e VINEGAR_DIR="$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar"` before the `--`.

For other clients, set the command to `~/.local/bin/roblox-studio-mcp` with stdio transport and no arguments.

## Enable the MCP server in Studio

In Studio, open **Assistant → … → Manage MCP Servers** and turn on **Enable Studio as MCP server**.

Studio must be open, with this setting on, while the client is connected.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `WS host connection error: Connection refused` | Turn on **Enable Studio as MCP server** in Studio (see above), and make sure Studio is open. |
| `StudioMCP.exe not found under …/versions` | Launch Studio through Vinegar once so it downloads Studio, or set `VINEGAR_DIR` to the right folder. |
| `Server's protocol version is not supported` | Studio hasn't finished loading yet. Wait for it to load, then reconnect (`/mcp` in Claude Code). |

To test the server without a client, run `roblox-studio-mcp` in a terminal and paste a JSON-RPC `initialize` request. If it's working, a JSON response comes back.
