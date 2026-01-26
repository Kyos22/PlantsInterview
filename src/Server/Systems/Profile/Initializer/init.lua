local Template = require(script.Parent.Template)
return function(player: Player, data: Template.Profile)
	for _, moduleScript in pairs(script:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			module(player, data)
		end
	end
end
