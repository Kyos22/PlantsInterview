--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = require(ReplicatedStorage.Shared.Network.Server)
return function(player: Player, profile)
	Server.Update_Resource.Fire(player, "Money", 0, profile.Balance.Money)
	Server.Update_Resource.Fire(player, "Gold", 0, profile.Balance.Gold)
	Server.Update_Resource.Fire(player, "Exp", 0, profile.Balance.Exp)
	Server.Update_Resource.Fire(player, "FamousPoint", 0, profile.Balance.FamousPoint)
end
