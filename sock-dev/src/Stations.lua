-- SockDev station / viewpoint registry (Studio only, lives in ServerStorage).
--   tp     = DevAction "Teleport" code (optional)
--   stand  = {x, y, z, yawDeg}           character root CFrame after teleport (optional)
--   cam    = {px, py, pz, tx, ty, tz}    camera position + look-at point (optional)
--   fov    = camera FieldOfView for the shot (optional)
--   prompt = Workspace-relative path to the station's main ProximityPrompt (optional)
-- An entry without stand/cam falls back to auto: face and frame the nearest prompt.
-- Fill in entries with D.record("Name") in Play, then in Edit mode run:
--   require(game.ServerStorage.SockDev.Ref:Clone()).upsertStation('<printed line>')
return {
	-- @stations-begin
	["L1"] = { tp = "L1" },
	["L2"] = { tp = "L2" },
	["Stand"] = { tp = "Stand" },
	["W2"] = { tp = "W2" },
	["W2Pile"] = { tp = "W2Pile" },
	["W2Gate"] = { tp = "W2Gate" },
	["W3"] = { tp = "W3" },
	["W3Market"] = { tp = "W3Market" },
	-- @stations-end
}
