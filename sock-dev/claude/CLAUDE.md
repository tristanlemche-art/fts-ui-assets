# Find THE Sock (Roblox place 86617858096194)
- Before any Studio work, use the `sock-playtest` skill. It has the rules and the 4-call screenshot loop.
- Rules: never save, publish or revert the place. Edit only in Edit mode. In every playtest, run DevNoSave on the Server first. No gameplay changes. Keep the console clean (the only allowed warning is rbxassetid://203785492).
- Dev kit: `_G.D` in client Play (`D.help()`). `require(game.ServerStorage.SockDev.Ref:Clone())` in Edit mode for grep, lines, patch, push and dump.
- Layout, prompts and remotes: `sock-reference.md` in this folder (regenerate with `Ref.dump()`).
- Log every change at the end of `audit-fixes-log.md`.
- Installer and source: the `sock-dev/` folder of the GitHub repo fts-ui-assets.
