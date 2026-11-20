-- SockDevBoot (ServerScriptService). Studio-only dev tooling for Claude playtests.
-- On live servers this returns on the first line: nothing is cloned, no remote is made.
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end

local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local src = SS:FindFirstChild("SockDev")
if not src or src:GetAttribute("Enabled") == false then
	return
end

local rt = Instance.new("Folder")
rt.Name = "SockDevRuntime"
for _, name in { "Ref", "Stations", "Client" } do
	local m = src:FindFirstChild(name)
	if m then
		m:Clone().Parent = rt
	end
end
local rf = Instance.new("RemoteFunction")
rf.Name = "Server"
rf.Parent = rt
rt.Parent = RS

-- DevNoSave (SockServer.Dev) answers "no session" until the player's data has loaded,
-- and may not exist yet when this script starts. Only a real "saving off" reply counts.
local NOSAVE_OK = "saving off for this session"
local function noSave(p, timeout)
	local key = "NoSave_" .. p.UserId
	if rt:GetAttribute(key) then
		return true
	end
	local t0 = os.clock()
	repeat
		local bf = SS:FindFirstChild("DevNoSave")
		if bf and p.Parent then
			local ok, res = pcall(bf.Invoke, bf, p)
			if ok and res == NOSAVE_OK then
				rt:SetAttribute(key, true)
				return true
			end
		end
		if not p.Parent then
			return false
		end
		task.wait(0.25)
	until os.clock() - t0 > (timeout or 0)
	return false
end

rf.OnServerInvoke = function(p, action)
	if action == "NoSave" then
		return noSave(p)
	end
	return nil
end

local loader = src:FindFirstChild("Loader")
local function onPlayer(p)
	if src:GetAttribute("AutoNoSave") ~= false then
		task.spawn(function()
			-- Same timing as the manual step used to have: after the character exists.
			if not p.Character then
				p.CharacterAdded:Wait()
			end
			if not noSave(p, 30) then
				warn("[SockDev] auto DevNoSave did not confirm for " .. p.Name .. "; run it by hand")
			end
		end)
	end
	if loader then
		local pg = p:WaitForChild("PlayerGui", 15)
		if pg and not pg:FindFirstChild("SockDevLoader") then
			local g = Instance.new("ScreenGui")
			g.Name = "SockDevLoader"
			g.ResetOnSpawn = false
			local ls = loader:Clone()
			ls.Enabled = true
			ls.Parent = g
			g.Parent = pg
		end
	end
end

Players.PlayerAdded:Connect(function(p)
	onPlayer(p)
end)
for _, p in Players:GetPlayers() do
	task.spawn(onPlayer, p)
end
