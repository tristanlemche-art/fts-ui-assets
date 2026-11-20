-- Removes SockDev from the place (Edit mode). Never saves.
assert(not game:GetService("RunService"):IsRunning(), "stop the playtest first")
local n = 0
for _, i in { game.ServerStorage:FindFirstChild("SockDev") or false, game.ServerScriptService:FindFirstChild("SockDevBoot") or false } do
	if i then i:Destroy(); n += 1 end
end
return "SockDev removed (" .. n .. " instances)"
