# roblox-studio-mcp-vinegar

Lets Claude Code (or any other MCP client) on Linux control Roblox Studio running under [Vinegar](https://vinegarhq.org).

Roblox Studio comes with its own MCP server, `StudioMCP.exe`. It's a Windows program, so it needs Wine to run on Linux. `roblox-studio-mcp` is a small shell script that finds the newest `StudioMCP.exe` that Vinegar installed and runs it with Vinegar's own Wine (kombucha) in Studio's Wine prefix. The MCP client talks to it over stdio.

This repo only contains the launcher script. It doesn't include or change any Roblox files.

## Requirements

- Roblox Studio installed and launched at least once through Vinegar
- An MCP client, such as Claude Code

## Install

```sh
install -Dm755 roblox-studio-mcp ~/.local/bin/roblox-studio-mcp
```

Register it with Claude Code:

```sh
claude mcp add -s user Roblox_Studio ~/.local/bin/roblox-studio-mcp
```

For other clients, set the command to `~/.local/bin/roblox-studio-mcp` with stdio transport and no arguments.

## Enable the MCP server in Studio

In Studio, open **Assistant → … → Manage MCP Servers** and turn on **Enable Studio as MCP server**.

Studio must be open, with this setting on, while the client is connected.

## Flatpak Vinegar

The script reads from `~/.local/share/vinegar` by default. If you installed Vinegar through Flatpak, set `VINEGAR_DIR` to the Flatpak data folder:

```sh
claude mcp add -s user -e VINEGAR_DIR="$HOME/.var/app/org.vinegarhq.Vinegar/data/vinegar" \
  Roblox_Studio ~/.local/bin/roblox-studio-mcp
```

If both native and Flatpak Vinegar are installed, you can keep the default. The MCP server connects to Studio over localhost, so it can still reach a Studio that was launched from the Flatpak.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `WS host connection error: Connection refused` | Turn on **Enable Studio as MCP server** in Studio (see above), and make sure Studio is open. |
| `StudioMCP.exe not found under …/versions` | Launch Studio through Vinegar once so it downloads Studio, or set `VINEGAR_DIR` to the right folder. |
| `Server's protocol version is not supported` | Studio hasn't finished loading yet. Wait for it to load, then reconnect (`/mcp` in Claude Code). |
| Black or missing 3D view in screenshots | Set `renderer = "DXVK"` under `[studio]` in Vinegar's `config.toml`. Also keep the Studio window focused, because Studio pauses 3D rendering when it isn't focused. |

To test the server without a client, run `roblox-studio-mcp` in a terminal and paste a JSON-RPC `initialize` request. If it's working, a JSON response comes back.
