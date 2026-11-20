-- SockDev loader (template in ServerStorage; SockDevBoot copies it into PlayerGui in Studio only).
local rt = game:GetService("ReplicatedStorage"):WaitForChild("SockDevRuntime", 15)
if not rt then
	return
end
require(rt:WaitForChild("Client")).setup()
