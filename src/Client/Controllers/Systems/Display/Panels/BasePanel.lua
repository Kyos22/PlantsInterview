--// Structure
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Shared = ReplicatedStorage.Shared
---->> Utils
local Utils = Shared.Core.Utils
local Ripple = require(Utils.Ripple)
---->> Packages
local Packages = ReplicatedStorage.Packages
local LemonSignal = require(Packages.LemonSignal)

--// Constants & Enums

--// Types
export type PrivateField = {
	ripple: { [string]: Ripple.Ripple },
	tween: { [string]: Tween },

	tasks: { [string]: thread },
	connections: { [string]: RBXScriptConnection },
	lemons: { LemonSignal.Signal<> },
}

--// Constructor
local function prototype(self: Type, system: any)
	---->> Public Properties
	self.System = system
	self.UI = nil
	self.Debounce = false

	---->> Private Properties
	self._private = {
		ripple = {},
		tween = {},

		tasks = {},
		connections = {},
		lemons = {},
	} :: PrivateField

	return self
end

function module.methods.Initialize(self: Type) end

--// Private Functions
local function WrapDebounce(self: Type, func)
	return function(...)
		if self.Debounce then
			return
		end
		self.Debounce = true
		func(...)
		self.Debounce = false
	end
end

local function WrapLemon(self: Type, signal, handler)
	local lemon = LemonSignal.wrap(signal):Connect(handler)
	table.insert(self._private.lemons, lemon)
	if self.UI and self.UI.Enabled then
		return
	end
	lemon:Disconnect()
end

local function ResolveLemons(self: Type, isReconnect: boolean)
	local _p = self._private

	if isReconnect then
		for _, lemon in pairs(_p.lemons) do
			lemon:Reconnect()
		end
	else
		for _, lemon in pairs(_p.lemons) do
			lemon:Disconnect()
		end
	end
end

--// Public Functions
function module.methods.Open(self: Type)
	self.UI.Enabled = true
	ResolveLemons(self, true)
end

function module.methods.Close(self: Type)
	self.UI.Enabled = false
	ResolveLemons(self, false)
end

--// APIs
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {
	WrapDebounce = WrapDebounce,
	WrapLemon = WrapLemon,
	ResolveLemons = ResolveLemons,
}

function module.constructors.new(system: any): Type
	local self = setmetatable(prototype({}, system), module.metatable)

	return self :: Type
end

--// Destructor
function module.methods.Destroy(self: Type)
	local _p = self._private
	for _, task_ in pairs(_p.tasks) do
		if coroutine.status(task_) == "suspended" then
			task.cancel(task_)
		else
			task.defer(function()
				task.cancel(task_)
			end)
		end
	end
	for _, connection in pairs(_p.connections) do
		connection:Disconnect()
	end

	local temp = self :: {}
	for k in pairs(temp) do
		temp[k] = nil
	end
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
