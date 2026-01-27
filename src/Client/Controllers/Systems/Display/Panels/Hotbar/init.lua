--// Structure
local super = require(script.Parent.BasePanel)
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
setmetatable(module.methods, super.metatable)

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local GuiService = game:GetService("GuiService")

--// Modules
-- local SharedInterfaces = ReplicatedStorage.SharedControllers.Interfaces
local Interfaces = ReplicatedStorage.Controllers.Interfaces
local Shared = ReplicatedStorage.Shared
local Core = Shared.Core
local Packages = ReplicatedStorage.Packages
-- local Libraries = Shared.Lobby.Libraries
---->> Network
-- local Client = require(Shared.Network.Client)Flocal DefaultSource = ReplicatedStorage.Assets.Display

---->> Utils
local Utils = require(Core.Utils)
local DisplayHelper = require(Core.Utils.DisplayHelper)
local Ripple = require(Core.Utils.Ripple)

---->> Libraries
-- local TesterLibrary = require(Libraries.Tester)
-- local ProgressionLibrary = require(Shared.Global.Libraries.Progression)
---->> Observers
-- local ProfileObserver = require(ReplicatedStorage.SharedControllers.Observers.Profile)
---->> Interfaces
local ProfileInterface = require(ReplicatedStorage.Controllers.Interfaces.Profile)
-- local SoundInterface = require(ReplicatedStorage.SharedControllers.Interfaces.Sound)
-- local AudioLib = require(ReplicatedStorage.Shared.Lobby.Libraries.Audio)

--// Constants & Enums
local QUEUE_TIMER_BIND = "QUEUE_TIMER_BIND"

--// References
local Assets = ReplicatedStorage.Assets
local UI = Assets.Display.Hotbar
-- local TemplateFolder = Assets.Display.Templates.Menu
-- local Template = {
-- 	TeleportButton = TemplateFolder.TeleportButton,
-- }

--// Types
type Profile = ProfileInterface.Profile
export type PrivateField = super.PrivateField & {
	profileInitialized: boolean,

	queueTimestamp: number,
}

--// Constructor
local function prototype(self: Type, system: any)
	---->> Public Properties
	self.UI = DisplayHelper:CloneSingleton(UI) :: typeof(UI)

	---->> Private Properties
	-- self._private.queueTimestamp = 0
    -- self.Data = nil
	return self
end

function module.methods.Initialize(self: Type)
	super.methods.Initialize(self)

	-- self.Data = ProfileInterface.GetAsync()
    -- print("selfda",self.Data)
end

--// Private Functions
local Now = Utils.Now
local WrapLemon = super.private.WrapLemon
local WrapDebounce = super.private.WrapDebounce
local WrapHover = super.private.WrapHover

--// Public Functions
function module.methods.RenderCard(self: Type)
    
end


function module.methods.Open(self: Type, isAnimated: boolean?)
	super.methods.Open(self)

end

function module.methods.Close(self: Type, isAnimated: boolean?)
	super.methods.Close(self)

end

--// Destructor
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {}

function module.constructors.new(system: any): Type
	local self = setmetatable(super.new(system) :: any, module.metatable)
	self = prototype(self, system)
	return self :: Type
end

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

export type Type = super.Type & typeof(prototype(...)) & typeof(module.methods)

return module.constructors
