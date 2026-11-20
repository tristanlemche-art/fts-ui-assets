# SockDev: Studio-only dev kit for Find THE Sock

**Status:** draft, written without Studio access. It hasn't run yet, so the first install includes a test pass.

## What's here
| File | Goes to | Purpose |
|---|---|---|
| `src/SockDevBoot.server.lua` | `ServerScriptService.SockDevBoot` | Returns at once unless `RunService:IsStudio()`. In Studio it copies the kit to `ReplicatedStorage.SockDevRuntime`, runs DevNoSave for each player after spawn, and gives each player a loader. |
| `src/Client.lua` | `ServerStorage.SockDev.Client` | `_G.D`: shot, go, frame, lock, mirror, press, fake, record, snap, prompts, dev, reset. |
| `src/Stations.lua` | `ServerStorage.SockDev.Stations` | Station viewpoint registry. The installer keeps an existing copy. |
| `src/Ref.lua` | `ServerStorage.SockDev.Ref` | Edit-mode grep, lines, patch, push, upsertStation and dump (reference markdown). |
| `src/Loader.client.lua` | `ServerStorage.SockDev.Loader` | Template copied into PlayerGui in Studio. |
| `install.lua` / `uninstall.lua` | — | One execute_luau paste in Edit mode. Rebuild with `python3 build_install.py`. |
| `claude/sock-playtest/SKILL.md` | `C:\Users\trist\.claude\skills\sock-playtest\SKILL.md` | The workflow and rules. |
| `claude/CLAUDE.md` | `C:\Users\trist\Downloads\Claude\CLAUDE.md` | Memory pointer. |

## Why real players are unaffected
- Everything sits in ServerStorage and ServerScriptService. ServerStorage never replicates to clients.
- The boot script's first statement is `if not RunService:IsStudio() then return end`. Live servers create nothing, so there are no runtime instances and no remote.
- No existing script is edited. SockDev only calls the existing DevAction and DevNoSave.
- To switch it off without uninstalling: `ServerStorage.SockDev:SetAttribute("Enabled", false)`. To skip auto DevNoSave: set the `AutoNoSave` attribute to false.

## First install (when you're at Studio)
1. In Edit mode, run `install.lua` with execute_luau. If the payload is too big, push each file with `Ref.push`.
2. Copy `claude/` into place (see the table above).
3. Playtest once: Server DevNoSave, then client `return _G.D and _G.D.help()`, then `D.shot("W2Gate")`, then `screen_capture`.
4. Things to check on that first run:
   - DevAction argument order (`D.tp`) against `SockClient.DevUI`.
   - That DevNoSave after spawn is the same timing as before.
   - Whether `_G.D` from the LocalScript is visible to execute_luau. If it isn't, the `require(...)` fallback gives the same API.
   - Whether the game's custom prompt UI is a BillboardGui in PlayerGui (mirror covers it) or the CoreGui default (not capturable).
5. Record a viewpoint for each station with `D.record` and `Ref.upsertStation`.
6. Generate `sock-reference.md` with `Ref.dump()`.
7. Log the install in `audit-fixes-log.md`.
