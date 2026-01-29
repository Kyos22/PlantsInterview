--!strict
--// Services
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules

---->> Classes
local BasePanel = require(script.Panels.BasePanel)

-->> Panels
local Hotbar = require(script.Panels.Hotbar)
local Menu = require(script.Panels.Menu)
local Inventory = require(script.Panels.Inventory)


local Panels = {
	Hotbar = Hotbar,
	Menu = Menu,
	Inventory = Inventory,
}

--// Constants & Enums
-- local DEBUGGING = true
--// Variables
local PanelData: {
	Main: {[BasePanel.Type]: boolean},
	Sub: {[BasePanel.Type]: boolean},
	Misc: {[BasePanel.Type]: boolean},
} = {Main = {}, Sub = {}, Misc = {}}
--// Types
export type APIsType = {
	Switch: (source: any?, target: string) -> (),

	Hotbar : {
		Instance: Hotbar.Type,
		GetInstance: () -> Hotbar.Type,
		Open: () -> (),
		Close: () -> (),
	},
	Menu : {
		Instance: Menu.Type,
		GetInstance: () -> Menu.Type,
		Open: () -> (),
		Close: () -> (),
	},
	Inventory : {
		Instance: Inventory.Type,
		GetInstance: () -> Inventory.Type,
		Open: () -> (),
		Close: () -> (),
	},
}

export type Type = {
	_Start: (self: Type) -> (),
	_Setup: (self: Type) -> (),
} & APIsType

--// System
local Display = {} :: Type

function Display:_Setup()
	--// CoreGui
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)

	for name, display in pairs(Panels) do
		task.spawn(function()
			local success, response = pcall(function()
				-- print(`[Display] Start Initializing > {name}`)
				local instance = display.new(self)
				print("insta",instance)
				instance:Initialize()
				Display[name].Instance = instance

				print(`[Display] Initialized > {name}`)
			end)

			if not success then
				warn(`[Display] Failed to Initialize: {name} // Reason: {response}`)
			end
		end)
	end

	--// Selection item
end

function Display:_Start()
	while not Display.Hotbar.Instance do
		task.wait()
	end
	Display.Hotbar.Open()
	Display.Menu.Open()
end

-->> APIs
Display.Switch = function(source: any?, _target: string, hasTransition: boolean?)
	print("target",_target)
	local target = Display[_target]
	if not target then
		warn(`Display: {_target} not found!`)
		return
	end
	
	-- if hasTransition then
	-- 	Display.Transition.Open(true)
	-- end

	-- if source then
	-- 	source:Close()
	-- end
	print("toi day roi",target)
	target:Open()

	-- if hasTransition then
	-- 	Display.Transition.Close(true)
	-- end
end

---->> Hotbar
Display.Hotbar = {} :: any
Display.Hotbar.Instance = function()
	return Display.Hotbar.Instance
end
Display.Hotbar.GetInstance = function()
	return Display.Hotbar.Instance
end
Display.Hotbar.Open = function()
	Display.Hotbar.Instance:Open()
end
Display.Hotbar.Close = function()
	Display.Hotbar.Instance:Close()
end

---->> Hotbar
Display.Menu = {} :: any
Display.Menu.Instance = function()
	return Display.Menu.Instance
end
Display.Menu.GetInstance = function()
	return Display.Menu.Instance
end
Display.Menu.Open = function()
	Display.Menu.Instance:Open()
end
Display.Menu.Close = function()
	Display.Menu.Instance:Close()
end

---->> Inventory
Display.Inventory = {} :: any
Display.Inventory.Instance = function()
	return Display.Inventory.Instance
end
Display.Inventory.GetInstance = function()
	return Display.Inventory.Instance
end
Display.Inventory.Open = function()
	Display.Inventory.Instance:Open()
end
Display.Inventory.Close = function()
	Display.Inventory.Instance:Close()
end

return Display
