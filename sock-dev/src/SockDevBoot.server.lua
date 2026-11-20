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

local function noSave(p)
	local bf = SS:FindFirstChild("DevNoSave")
	if not bf then
		return false
	end
	local ok = pcall(function()
		return bf:Invoke(p)
	end)
	if ok then
		rt:SetAttribute("NoSave_" .. p.UserId, true)
	end
	return ok
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
			noSave(p)
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
