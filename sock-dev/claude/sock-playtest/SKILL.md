---
name: sock-playtest
description: Playtest, screenshot, or live-edit the Roblox game "Find THE Sock" (Studio place 86617858096194) through the Roblox Studio MCP. Use for any task that edits or checks that place: UI screenshots, station checks, script fixes, audit fixes.
---

# Find THE Sock: playtest workflow

## Hard rules
- NEVER save, publish or revert the place. It has unsaved edits from other sessions.
- Edit scripts only in Edit mode. Stop any running playtest first.
- In every playtest, the first call is the Server one-liner below (DevNoSave).
- No gameplay changes. Dev tools stay Studio-only (SockDev is gated by `RunService:IsStudio()`).
- Keep the console clean. The only known warning is `rbxassetid://203785492`.
- At the end, append a dated entry to `C:\Users\trist\Downloads\Claude\audit-fixes-log.md`.

## Start of session (2 calls)
1. `list_roblox_studios` to get the studio id for place 86617858096194.
2. Read the tail of `audit-fixes-log.md` and `sock-reference.md` (both in `C:\Users\trist\Downloads\Claude`).
   If `ServerStorage.SockDev` is missing, run `sock-dev\install.lua` once in Edit mode.

## Edit mode: change code without pasting whole sources
```lua
local R = require(game.ServerStorage.SockDev.Ref:Clone())
return R.grep("Teleport", "StarterPlayer")                         -- path:line: text
return R.lines("StarterPlayer.StarterPlayerScripts.SockClient.Prompts", 100, 160)
return R.patch("ServerScriptService.SockServer.X", "old exact text", "new text")  -- must match exactly once
return R.patch(path, {{old1,new1},{old2,new2}})
return R.push(path, fullSource)                                    -- only for new or rewritten scripts
return R.dump()                                                    -- regenerate sock-reference.md
```

## Playtest (about 4 calls per screenshot)
1. Start Play.
2. **Server** (always first):
   `local p=game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait(); return game.ServerStorage.DevNoSave:Invoke(p)`
3. **Client**: `local D=_G.D or require(game.ReplicatedStorage.SockDevRuntime.Client); return D.shot("W2Gate")`
   - Press first: `D.shot("W2Gate",{press="Wash"})`. For a short effect use `pressIn=0.6`, so the press lands during the next call.
   - A UI state the game won't reach on its own: `D.fake{like="W2Gate", action="Collect"}` (client-only, AlwaysShow).
   - Misc: `D.prompts()` lists what's near, `D.snap()` prints state, `D.dev("AddCash", 1000)`, `D.reset()`.
4. `screen_capture`. Billboards show up because `D.mirror` copies them into a ScreenGui.
5. Read the console. Anything besides the 203785492 warning is a bug to report.
6. Stop Play.

## A station framed badly
In Play, put the character and camera where they should be, then run `return D.record("W2Gate")`.
Stop Play. In Edit mode run `require(game.ServerStorage.SockDev.Ref:Clone()).upsertStation('<printed line>')`.
From then on, `D.shot("W2Gate")` uses that view.

## Codes
Teleport: L1, L2, Stand, W2, W2Pile, W2Gate, W3, W3Market. Others: FillBag, FastWash, AddCash (see SockClient.DevUI).
Worlds: L1 laundromat, L2 tech room (Workspace.Laundromat2), W2 stone age (World2), W3 Egypt (World3).
