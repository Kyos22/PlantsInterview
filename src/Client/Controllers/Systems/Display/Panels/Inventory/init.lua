

--// Structure
local super = require(script.Parent.BasePanel)
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
setmetatable(module.methods, super.metatable)

-->> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
local TEMPLATE = ReplicatedStorage.Assets.Display.Template.Inventory
local Assets = ReplicatedStorage.Assets
local UI = Assets.Display.Inventory

---->> Interfaces
local ProfileInterface = require(ReplicatedStorage.Controllers.Interfaces.Profile)
local Client = require(ReplicatedStorage.Shared.Network.Client)

--// Types
type PlantSlot = {
    Template: Frame, 
    Quantity: number,
}

type PlantInventory = {
    [string]: PlantSlot
}

export type Type = super.Type & typeof(prototype(...)) & typeof(module.methods)

--// Constructor
local function prototype(self: Type, system: any)
    self.UI = DisplayHelper:CloneSingleton(UI) :: typeof(UI)
    self.Main = self.UI.Main :: Frame
    self.Holder = self.Main.Frame.Holder :: ScrollingFrame
    self.CloseButton = self.Main.CloseButton.Hitbox :: TextButton

    self.PlantInventory = {} :: PlantInventory
    self.Data = nil 
    
    return self
end

function module.methods.Initialize(self: Type)
    super.methods.Initialize(self)
    local _p = self._private

    task.spawn(function()
        local profile = ProfileInterface.GetAsync()
        if _p.profileInitialized then return end
        _p.profileInitialized = true
        
        self.Data = profile
        self:RenderCard() 
    end)

    self:RenderButton()

	Client.Garden.Harvest.On(function(plant:string, quantity:number)
		print("harvest",plant,quantity)
		self:Add(plant, quantity)
	end)

end

--// Private Functions
local WrapLemon = super.private.WrapLemon
local WrapDebounce = super.private.WrapDebounce

function module.methods.UpdateOrCreateInfo(self: Type, plantName: string, quantity: number)
    local plantLib = PLANTS.Data[plantName]
    if not plantLib then return end

    local slot = self.PlantInventory[plantName]
    local template

    if not slot then
        template = TEMPLATE.Template:Clone()
        template.Name = plantName
        template.Visible = true
        template.Parent = self.Holder

        self.PlantInventory[plantName] = {
            Template = template,
            Quantity = quantity
        }

        local sprite = template.Sprite :: ImageLabel
        local hitbox = template.Hitbox :: TextButton
        
        local hover = Ripple.new({
            function() sprite.UIScale.Scale = 1 end,
            TweenService:Create(sprite.UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), { Scale = 1.1 }),
        }, false)
        
        local unhover = Ripple.new({
            TweenService:Create(sprite.UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), { Scale = 1 }),
        }, false)

        WrapLemon(self, hitbox.MouseEnter, function() hover:Play() end)
        WrapLemon(self, hitbox.MouseLeave, function() unhover:Play() end)
        WrapLemon(self, hitbox.Activated, WrapDebounce(self, function()
            print("Selected plant in inventory:", plantName)
        end))
    else
        template = slot.Template
        slot.Quantity = quantity
    end

    template.Sprite.Image = plantLib.ImageId
    template.NamePlant.Text = plantName
    template.Quantity.Text = tostring(quantity)
    
    template.Visible = quantity > 0
end

--// Public Functions

function module.methods.RenderButton(self: Type)
   WrapLemon(self, self.CloseButton.Activated, WrapDebounce(self, function()
       self:Close()
   end))
end

function module.methods.RenderCard(self: Type)
    if not self.Data or not self.Data.Inventory.Plants then return end
    
    for plant, data in pairs(self.Data.Inventory.Plants) do
        self:UpdateOrCreateInfo(plant, data.Quantity)
    end
	print("PlantInventory",self.PlantInventory)
end

function module.methods.Add(self: Type, plant: string, quantity: number)
    if not plant or type(plant) ~= "string" then return end
    
    local currentQuantity = 0
    if self.PlantInventory[plant] then
        currentQuantity = self.PlantInventory[plant].Quantity
    end
    
    local newTotal = currentQuantity + quantity
    
    self:UpdateOrCreateInfo(plant, newTotal)
    
    print(string.format("Updated %s: %d -> %d", plant, currentQuantity, newTotal))
end

function module.methods.Open(self: Type, isAnimated: boolean?)
    super.methods.Open(self)
    self.UI.Enabled = true
end

function module.methods.Close(self: Type, isAnimated: boolean?)
    super.methods.Close(self)
end

function module.methods.Destroy(self: Type)
    for k, v in pairs(self.PlantInventory) do
        if v.Template then v.Template:Destroy() end
        self.PlantInventory[k] = nil
    end
    
    super.methods.Destroy(self)
end

--// Constructor Registration
module.constructors.new = function(system: any): Type
    local self = setmetatable(super.new(system) :: any, module.metatable)
    self = prototype(self, system)
    return self :: Type
end

return module.constructors
