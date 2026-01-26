--!nocheck
local ServerScriptService = game:GetService("ServerScriptService")

local Template = require(ServerScriptService.Systems.Data.Template)

return function(player: Player, data: Template.Profile)
	if data.Model.Outside.Restaurant.Owned["House_1"] and data.Model.Inside.Restaurant.Floor.Size == "4_4" then
		return
	end
	data.Model.Outside.Restaurant.Owned = {
		["House_1"] = true,
	}
	data.Model.Outside.Restaurant.Equipped = "House_1"

	data.Model.Inside.Restaurant.Floor.Size = "4_4"
	data.Model.Inside.Restaurant.Floor.Texture = "Wood"
	data.Model.Inside.Restaurant.Wall.Texture = "Brick"
	data.Model.Inside.Restaurant.Door.Equipped = "Door_Default"

	data.Model.Inside.Restaurant.Floor.ListOwned = {
		["Wood"] = true,
	}
	data.Model.Inside.Restaurant.Wall.ListOwned = {
		["Brick"] = true,
	}
	data.Model.Inside.Restaurant.Door.ListOwned = {
		["Door_Default"] = true,
	}
	print("data", data)
	return true
end
