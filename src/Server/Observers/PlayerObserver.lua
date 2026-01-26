--!strict
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local SignalModule = require(ReplicatedStorage.Packages.Signal)
local Template = require(ServerScriptService.Systems.Profile.Template)
--// Type
type Signal = typeof(SignalModule.new())
--// Constants
local Event = {
	Loaded = "Loaded",
}
--// Type
export type SendEventArgs = {
	Player: Player,
	Data: Template.Profile,
    Amount: number,
    Type: string,
}
--// Variable
local eventCache: {
	[string]: Signal,
} = {}

--
export type Type = {
	Event: typeof(Event),
} & Yumi.Observer

local module: Type = {} :: any

do --init
	table.freeze(Event)
	for _, event in pairs(Event) do
		eventCache[event] = SignalModule.new()
	end
end

--// Yumi
module.Event = Event
module._Setup = function() end
module.Subscribe = function(event: string, callback: any)
	if not eventCache[event] or not callback then
		return nil
	end
	if typeof(callback) ~= "function" then
		return nil
	end
	local conn = eventCache[event]:Connect(callback)
	return conn
end
module.Fire = function(event: string, args: any, isDefered: boolean?)
	if not eventCache[event] then
		return nil
	end
	if isDefered then
		eventCache[event]:FireDeferred(args)
	else
		eventCache[event]:Fire(args)
	end
end
return module
