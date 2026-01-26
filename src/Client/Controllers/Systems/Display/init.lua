--!strict
--// Services
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules

---->> Classes
local BasePanel = require(script.Panels.BasePanel)


local Panels = {	
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



end



return Display
