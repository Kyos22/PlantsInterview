--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
Yumi:Add("Systems", ServerScriptService.Systems)
Yumi:Add("Observers", ServerScriptService.Observers)

Yumi:Start()
	:Then(function()
		warn("⭕| Yumi Server loaded!")
	end)
	:Catch(warn)
	:Await()
