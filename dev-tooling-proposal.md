# Find THE Sock: dev tooling proposal (DRAFT)

> **Update:** items 1–6 and the Edit-mode source tools (grep, lines, patch, push) are drafted in `sock-dev/` (see its README). They're not installed and haven't run yet.
>
> **Status: draft, not checked against the place.** This session ran in a cloud
> container. It could not reach Roblox Studio (place 86617858096194) or
> `C:\Users\trist\Downloads\Claude`, so I have not read `audit-fixes-log.md`,
> `SockClient.DevUI` or the DevAction handler yet. The design below comes from
> the pain points in the brief. I will check paths, gating and the numbers once
> I can reach Studio, and nothing gets built until you approve.

Savings are rough figures **per working session**, assuming 3–5 Play restarts
and 5–10 screenshots.

---

## Priority 1: SockDev auto-loaded dev kit (fixes pain points 1, 2, 3, 5)

**Problem:** After every Play start, I run DevNoSave and then paste a long
client harness again. Camera lock, billboard mirroring, prompt presses and fake
prompts are all written again by hand each time.

**One-call tool:** Nothing to paste. Every playtest starts with `_G.D` ready:

| Call | Does |
|---|---|
| `D.setup()` | Idempotent. Checks that DevNoSave ran (asks the server if not), sets `_G.D` and prints `SockDev ready`. Runs on its own at spawn. |
| `D.go("W2Gate")` | Calls DevAction Teleport, then puts the character on the station's saved stand CFrame. |
| `D.frame("W2Gate")` | Locks the camera to the station's saved view. Uses BindToRenderStep at Camera priority + 5. `D.unlock()` releases it. |
| `D.lock(cf)` / `D.unlock()` | Raw camera lock. |
| `D.mirror(on)` | Copies every visible BillboardGui into a ScreenGui at `WorldToViewportPoint(adornee + StudsOffset)` each frame, so screen_capture can see it. `D.mirror(false)` removes the copies. |
| `D.press(path)` | Finds the ProximityPrompt and calls InputHoldBegin, waits HoldDuration + ε, then calls InputHoldEnd. |
| `D.fake{parent=..., text=..., action=...}` | Makes a client-only prompt with Exclusivity = AlwaysShow and returns a cleanup function. |
| `D.shot("W2Gate", {press=..., delay=0.15})` | Does go, frame, mirror and an optional press, waits the delay, then prints `READY` so the capture lands while the effect is on screen. |
| `D.snap()` | Prints one line of state (see Priority 3). |

**Where it lives:**
- `ServerStorage.SockDev.Client` (ModuleScript, the client API) and
  `ServerStorage.SockDev.Stations` (registry, Priority 2). Code in
  ServerStorage **never reaches clients**.
- `ServerScriptService.SockDevBoot` (Script). Its first line is
  `if not RunService:IsStudio() then return end`. In Studio it clones the
  modules into `ReplicatedStorage.SockDevRuntime` and also into each player's
  PlayerScripts as a small LocalScript that does `_G.D = require(...)`. It also
  runs `ServerStorage.DevNoSave:Invoke(player)` on PlayerAdded, so the
  DevNoSave rule holds without a manual step. I will still check it as the
  first call of every playtest.
- On live servers nothing runs: no instances are cloned, no remotes are added
  and gameplay code is untouched.

**Effort:** Medium. About 250–350 lines of Luau, written once in Edit mode.

**Saves:** About 2 calls and 3–6k tokens per restart (DevNoSave plus the
harness paste), so **8–25k tokens and 6–10 calls a session**. Also 1 big
mirror paste and 1–2 camera-lock attempts per screenshot set.

**Risk to check:** DevNoSave on PlayerAdded must run before the first
autosave or load. I will read the SockServer data path before turning this on.
If the order is unsafe, the boot script waits for the profile-loaded signal.

---

## Priority 2: Station viewpoint registry (fixes pain point 4)

**Problem:** Putting the character and camera in front of a station is trial
and error, because the model's LookVector often points at its back.

**One-call tool:** `D.go(name)` and `D.frame(name)` read the registry.
`D.record("W2Gate")` prints the current character and camera CFrames as a
ready-to-paste registry line, so each viewpoint is set up once and then reused
forever.

**Where it lives:** A ModuleScript table in `ServerStorage.SockDev.Stations`,
one table for all stations:
`{ W2Gate = { tp="W2Gate", stand=CFrame, cam=CFrame, prompt="World2.Gate.Prompt", fov=60 } }`.
I chose a table over attributes or CFrameValues on the station models because
it is one file, adds nothing to Workspace and is simple to diff.

**Effort:** Low for the code. Recording costs 1 call per station once, about
15–25 stations across L1, L2, W2 and W3.

**Saves:** **3–8 calls per station shot**, and the shots come out consistent
between sessions.

---

## Priority 3: State snapshot (helps with pain point 7)

**Problem:** Checking cash, bag, world, unlocks and timers takes several reads.

**One-call tool:** `D.snap()` returns one line such as
`cash=1200 bag=8/10 world=W2 unlocks=[L2,W2] wash=idle`.

**Where it lives:** On the client, from replicated leaderstats and attributes.
If some state lives only on the server, I add a `"Snapshot"` case to the
existing DevAction handler, gated the same way as the other dev actions. It
only reads.

**Effort:** Low.

**Saves:** **2–5 calls per check.**

---

## Priority 4: Local reference doc, generated (fixes pain point 7)

**Problem:** Every session starts by rereading the world layout, prompt
positions, remote names and DevAction codes.

**One-call tool:** `D.dump()` (or one execute_luau call in Edit mode) prints
Markdown covering worlds, root models, all ProximityPrompts (path, ActionText,
HoldDuration), Remotes, DevAction codes and registry stations. I save it as
`C:\Users\trist\Downloads\Claude\sock-reference.md`, and the same call
regenerates it after changes.

**Effort:** Low.

**Saves:** **5–15 calls and 10–30k tokens** at the start of a session.

---

## Priority 5: `sock-playtest` Claude skill (all pain points)

**Problem:** I work out the workflow and the rules again each chat.

**Tool:** A `~/.claude/skills/sock-playtest/SKILL.md` on your PC with these
steps:
1. `list_roblox_studios` to get the id.
2. Stop any playtest.
3. Edit only in Edit mode.
4. Start Play.
5. Server: confirm DevNoSave.
6. Client: `D.shot(x)`, then screen_capture.
7. Read the console and ignore only `203785492`.
8. Stop.

Hard rules sit at the top: never save, publish or revert; no gameplay changes.

**Effort:** Low. **Saves:** about 2–4k tokens of planning, and it prevents
rule slips.

---

## Priority 6: Memory pointer

A `CLAUDE.md` in `C:\Users\trist\Downloads\Claude` with about 10 lines. It
points to the skill, the reference doc, `_G.D` and the log, and repeats the
no-save rule. **Effort:** trivial.

---

## Pain point 6 (editing scripts mid-Play): partly fixable

Scripts that are running can't be safely swapped during Play. What helps:
- Because of Priority 1, a restart is cheap (Stop → edit → Play → `D.shot`),
  so the rebuild cost goes away.
- `D.reload("Theme")` can re-require a fresh clone of a **pure** client module
  during Play, for quick visual tweaks. It doesn't apply to stateful modules.
  Effort: low. I'd only build it if you want it.
- Big source pushes still use `ScriptEditorService:UpdateSourceAsync`. A small
  Edit-mode helper `SockDev.Edit.push(path, src)` keeps each call short.

---

## Recommended build order

**1 + 2 + 5 + 6** gives about 80% of the savings. Add 3 and 4 next. Add
`D.reload` only on request.
