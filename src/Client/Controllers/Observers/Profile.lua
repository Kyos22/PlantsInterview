--!strict
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local SignalModule = require(ReplicatedStorage.Packages.Signal)
local Template = require(ReplicatedStorage.Shared.Libraries.Profile.Template)
--// Type
type Signal = typeof(SignalModule.new())
--// Constants
local Event = {
	Updated = "Updated",
}
--// Type
export type UpdatedEventArgs = {
	Data: Template.Profile,
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
