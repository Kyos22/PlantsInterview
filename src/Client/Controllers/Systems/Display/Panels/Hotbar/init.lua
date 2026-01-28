--// Structure
local super = require(script.Parent.BasePanel)
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
setmetatable(module.methods, super.metatable)

-->> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-->> Modules
local Shared = ReplicatedStorage.Shared
local Core = Shared.Core
local Packages = ReplicatedStorage.Packages
local PLANTS = require(ReplicatedStorage.Shared.Libraries.Plants)

---->> Utils
local Utils = require(Core.Utils)
local DisplayHelper = require(Core.Utils.DisplayHelper)
local Ripple = require(Core.Utils.Ripple)

-->> Refs
local TEMPLATE_HOTBAR = ReplicatedStorage.Assets.Display.Template.Hotbar
local Assets = ReplicatedStorage.Assets
local UI = Assets.Display.Hotbar

---->> Observers
-- local ProfileObserver = require(ReplicatedStorage.SharedControllers.Observers.Profile)

---->> Interfaces
local ProfileInterface = require(ReplicatedStorage.Controllers.Interfaces.Profile)

--// Constants & Enums

-->> Types
type Profile = ProfileInterface.Profile
export type PrivateField = super.PrivateField & {
	profileInitialized: boolean,

	queueTimestamp: number,
}

--// Constructor
local function prototype(self: Type, system: any)
	---->> Public Properties
	self.UI = DisplayHelper:CloneSingleton(UI) :: typeof(UI)
	self.Holder = self.UI.Frame.Holder
	---->> Private Properties
	
	return self
end

function module.methods.Initialize(self: Type)
	super.methods.Initialize(self)

    local _p = self._private
	-- task.wait(2)
    task.spawn(function() -- In-case UI is ahead of Profile
		local profile = ProfileInterface.GetAsync()
		print("profi",profile)
		if _p.profileInitialized then
			return
		end
		_p.profileInitialized = true

		self:RenderCard(profile.Inventory.Plants)
		-- self:UpdateAsProfile(profile)
	end)
	self:Setup()
end

--// Private Functions
local Now = Utils.Now
local WrapLemon = super.private.WrapLemon
local WrapDebounce = super.private.WrapDebounce
local WrapHover = super.private.WrapHover

--// Public Functions
function module.methods.RenderCard(self: Type,plants)
	for key, data in pairs(plants) do
		local plantData = PLANTS.Data[key]
		if not plantData then continue end
		local template = TEMPLATE_HOTBAR.Template:Clone()
		template.Name = key

		local sprite = template.Sprite :: ImageLabel
		local name = template.NamePlant :: TextLabel
		local quantity = template.Quantity :: TextLabel
		local button = template.Hitbox :: TextButton

		sprite.Image = plantData.ImageId
		name.Text = key
		quantity.Text = tostring(data.Quantity)
		template.Parent = self.Holder

		WrapHover(self,template)

		WrapLemon(self, button.Activated, WrapDebounce(self, function()
			print("plant",key)
			self.SelectPlant.Value = key
		end))
	end
end

function module.methods.Setup(self: Type)
	local SelectPlant = Instance.new("StringValue")
	SelectPlant.Name = "SelectPlant"
	SelectPlant.Value = "Corn"
	SelectPlant.Parent = self.UI
	self.SelectPlant = SelectPlant


end

function module.methods.Add(self: Type, plant: string, quantity: number)
	
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
