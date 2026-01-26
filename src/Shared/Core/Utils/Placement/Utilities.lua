--!strict
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Utilities = {}

Utilities.Fade = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

Utilities.Errors = {
	["1"] = "Code 1 - You're trying to activate placement too fast.",
	["2"] = "Code 2 - The object that the model is moving on is not scaled correctly.",
	["3"] = "Code 3 - Invalid callback function.",
	["4"] = "Code 4 - Grid size is too close to the plot size. Lower the grid size.",
	["5"] = "Code 5 - Cannot find a surface to place on. Please make sure one is available.",
}

Utilities.States = {
	"Movement",
	"Placing",
	"Colliding",
	"Inactive",
	"Out-of-Range",
}

Utilities.Distance = function(item: Instance | Vector3, providedSource: (Instance | Vector3)?): number
	local distance = 0
	local source: Vector3?

	if providedSource then
		if typeof(providedSource) == "Vector3" then
			source = providedSource
		elseif providedSource:IsA("BasePart") then
			source = providedSource.Position
		elseif providedSource:IsA("Model") then
			source = providedSource:GetPivot().Position
		end
	end

	if not source then
		local character = Player.Character
		if not character then
			return distance
		end

		source = character:GetPivot().Position
	end

	if source then
		if typeof(item) == "Vector3" then
			distance = (item - source).Magnitude
		elseif item:IsA("BasePart") then
			distance = (item.Position - source).Magnitude
		elseif item:IsA("Model") then
			distance = (item:GetPivot().Position - source).Magnitude
		end
	end

	return distance
end

Utilities.Color = function(instance: Instance, color3: Color3)
	if instance:IsA("SelectionBox") then
		instance.Color3 = color3
	elseif instance:IsA("BasePart") then
		instance.Color = color3
	elseif instance:IsA("Highlight") then
		instance.OutlineColor = color3
	end
end

return Utilities
