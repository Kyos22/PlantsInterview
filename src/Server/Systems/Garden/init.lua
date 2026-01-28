--!strict
-->> Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-->> Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local Profile = require(ServerScriptService.Systems.Profile)
local CONSTANT = require(ReplicatedStorage.Shared.CONSTANT)
local Server = require(ReplicatedStorage.Shared.Network.Server)
local Business = require(ServerScriptService.Systems.Garden.Business)
local Plants = require(ServerScriptService.Systems.Plants)

-->> Inputs
local OUTSIDE = workspace:WaitForChild("OUTSIDE") :: Folder
local RNG = Random.new()
local Assets = ReplicatedStorage.Shared.Assets
local Garden = Assets.Models.Garden.Garden :: Model
export type APIsType = {
    Assign: (player: Player) -> (Business.Type)?,
    Garden: { [Player]: Business.Type },

}

local module = {} :: APIsType & Yumi.System


--// APIs
module._Setup = function()
    module.Garden = {}

    Server.Preload.On(function(player: Player)
		local totalTries: number = 0
		local profile = Profile.GetAsync(player, false, false)

		if not profile then
			return false
		end

		local restaurant = module.Assign(player)
		totalTries = 0
		if not restaurant then
			repeat
				task.wait(0.1)
				totalTries += 1
                restaurant = module.Assign(player)
			until restaurant or totalTries > 100

			if not restaurant then
				player:Kick("Failed to assign restaurant! Please rejoin.")
				return false
			end
		end

		if not restaurant then
			return false
		end

		return true
	end)
end

module._Start = function()
    Server.Garden.Sow.On(function(player:Player,plant, pos)
        print("dd",plant,pos)
		if module.Garden[player] then
			local garden = module.Garden[player]
			garden:Grid(pos.cx,pos.cz,plant)
		end
    end)
end

function module.Assign(player: Player)
	local profile = Profile.GetAsync(player, false, false)
	if not profile then
		return
	end
	
	local modelInside: Model
	local modelOutside: Model

	local outsideSlots = OUTSIDE:GetChildren()

	-- Pick a random unowned slot
	local availableSlots = {}
	for _, s in ipairs(outsideSlots) do
		if not s:GetAttribute(CONSTANT.PLAYER.ATTRIBUTE._OWNER) then
			local slotId = tonumber(s.Name) :: number
			table.insert(availableSlots, slotId)
		end
	end

	if #availableSlots == 0 then
		return -- no available slots
	end

	local randomIndex = RNG:NextInteger(1, #availableSlots)
	local slot = availableSlots[randomIndex]

	local outsidePart = OUTSIDE:WaitForChild(tostring(slot)) :: BasePart

	-- save reference
	if outsidePart and outsidePart:IsA("Part") then
		player:AddReplicationFocus(outsidePart)
		outsidePart:SetAttribute(CONSTANT.PLAYER.ATTRIBUTE._OWNER, player.UserId)

		-- Players.CharacterAutoLoads = true
		local character: Model
		task.spawn(function()
			-- local name = profile.Model.Outside.Restaurant.Equipped
			-- local model = Buildings:WaitForChild(name) :: Model
			if Garden and Garden:IsA("Model") then
				local clone = Garden:Clone()
				clone.Parent = outsidePart
				clone:PivotTo(outsidePart.CFrame)
				clone:SetAttribute(CONSTANT.PLAYER.ATTRIBUTE._OWNER, player.UserId)
				modelOutside = clone
				local spawnLocation = clone:WaitForChild("SpawnLocation") :: SpawnLocation
				if spawnLocation then
					character = player.Character or player.CharacterAdded:Wait() :: Model
					player.RespawnLocation = spawnLocation
					character:PivotTo(spawnLocation.CFrame + Vector3.new(0, 10, 0))
				end

				-- player:SetAttribute(CONSTANT.PLAYER.ATTRIBUTE._OWNER, player.UserId)
			else
				warn("Not found model restaurant: ")
			end
		end)
	end

	-- local entryPart = modelOutside:WaitForChild("Teleport") :: BasePart

	-- local furnitures = Instance.new("Folder")
	-- furnitures.Name = "Furnitures"
	-- furnitures.Parent = modelInside
	local garden = Business.new({
        Player = player,
		Slot = slot,
        GardenModel = modelOutside,
        Land = {
            Soil1 = modelOutside:WaitForChild("GardenBox"):WaitForChild("Land") :: Part,
            -- Soil2 = modelOutside:WaitForChild("GardenBox2"):WaitForChild("Land") :: Part,
        },
	})
	garden:Initialize()

	if not garden then
		return nil
	end
	module.Garden[player] = garden

	-- for id, furniture in profile.Restaurant.Placement.Furnitures do
	-- 	local decodedCFrame = CFrame.new(table.unpack(HttpService:JSONDecode(furniture.CFrame)))
	-- 	local object: Asset = {
	-- 		Item = furniture.ItemId,
	-- 		Occupied = furniture.Occupied,
	-- 		CFrame = decodedCFrame,
	-- 		Rotation = furniture.Rotation,
	-- 		ID = id,
	-- 	} :: Asset

	-- 	local success = self:Place(player, object, true)
	-- 	if not success then
	-- 		warn("Failed to place furniture: " .. object.Item)
	-- 	end
	-- end
    Server.Garden.Init.Fire(player,slot)

	return garden
end


return module
