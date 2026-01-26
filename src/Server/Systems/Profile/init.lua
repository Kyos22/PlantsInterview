--!strict
--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local ProfileStore = require(ServerScriptService.Packages.ProfileStore)
local Resolver = require(script.Resolver)
local Utils = require(ReplicatedStorage.Shared.Core.Utils)
local Template = require(script.Template)
---->> Observer
local ProfileObserver = require(ServerScriptService.Observers.Profile)
---->> Network
local Server = require(ReplicatedStorage.Shared.Network.Server)
--// Constants & Enums
local DATASTORE_VERSION = Template.DATASTORE_VERSION
local DATASTORE_PREFIX = Template.DATASTORE_PREFIX
local SAVED = true

local GET_ASYNC_TIMEOUT = 5
local GET_ASYNC_INTERVAL = 0.5
--// Variables
local DataStore = ProfileStore.New(`{DATASTORE_PREFIX}_{DATASTORE_VERSION}`, Template.Template)
local Profiles: { [Player]: ProfileStore.Profile<Template.Profile> } = {}
local Tasks = {}

export type Profile = Template.Profile

export type APIsType = {
	Get: (player: Player, editable: boolean?, autoUpdate: boolean?) -> Template.Profile?,
	RequestProfile: (userID: number, editable: boolean?, autoUpdate: boolean?) -> Profile?,
	GetAsync: (player: Player, editable: boolean?, autoUpdate: boolean?) -> Template.Profile?,
	Update: (player: Player) -> (),
	Reset: (player: Player) -> (),
	Load: (player: Player) -> (),
	Release: (player: Player) -> (),
}
export type Type = Yumi.System & APIsType
local Data = {} :: Type

function Data:_Start()
	Server.GetProfile.On(function(player, async)
		local data = if async then Data.GetAsync(player, false) else Data.Get(player, false)
		return data
	end)
	for _, player in Players:GetPlayers() do
		Data.Load(player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		Data.Load(player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		Data.Release(player)
	end)
	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			Data.Release(player)
		end
	end)
end

function Data:_Setup() end

function Data.Get(player: Player, editable: boolean?, autoUpdate: boolean?): Template.Profile?
	local profile = Profiles[player]
	if not profile then
		return
	end

	if not editable then
		local copy = Utils.CloneTable(profile.Data, true) :: Template.Profile

		Utils.FreezeTable(copy, true)
		return copy
	else
		if autoUpdate ~= false then
			Data.Update(player)
		end
		return profile.Data :: Template.Profile
	end
end

function Data.GetAsync(player: Player, editable: boolean?, autoUpdate: boolean?): Template.Profile?
	local counter = 0
	local isWarned = false

	while not Profiles[player] do
		counter += GET_ASYNC_INTERVAL
		if not isWarned and counter > GET_ASYNC_TIMEOUT then
			isWarned = true
			warn(`[Data] Infinite yield while getting {player.Name}'s Data`)
		end

		task.wait(GET_ASYNC_INTERVAL)
	end

	return Data.Get(player, editable, autoUpdate)
end

function Data.RequestProfile(userID: number, editable: boolean?, autoUpdate: boolean?): Profile?
	-- Check if the player is in the game
	local player = Players:GetPlayerByUserId(userID)
	local profile: Profile?
	if not player then
		local data = DataStore:GetAsync(`{userID}`)
		if not data then
			-- warn("Cannot get the player data")
			return nil
		end
		profile = data.Data
	elseif player then
		-- if player is not in the game, get the profile from the
		profile = Data.GetAsync(player, editable, autoUpdate)
	end

	return profile
end

function Data.Load(player: Player)
	-- Start a profile session for this player's data:
	local profile
	if SAVED then
		profile = DataStore:StartSessionAsync(`{player.UserId}`, {
			Cancel = function()
				return player.Parent ~= Players
			end,
		})
	else
		profile = DataStore:GetAsync(`{player.UserId}`)
		print("Profile loaded:", profile)
	end
	-- Handling new profile session or failure to start it:

	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

		profile.OnSessionEnd:Connect(function()
			ProfileObserver.Fire(
				ProfileObserver.Event.Ended,
				{
					Data = Data.Get(player, false, false),
					Player = player,
				} :: ProfileObserver.EndedEventArgs,
				false
			)
			if SAVED then
				Profiles[player] = nil
				player:Kick(`Profile session end - Please rejoin`)
			end
		end)

		if player.Parent == Players then
			Resolver.Resolve(profile.Data, Template.VERSION) --resolve version conflict
			Profiles[player] = profile :: any

			if Profiles[player].Data.Player.UserId == 0 then
				Profiles[player].Data.Player.UserId = player.UserId
			end

			ProfileObserver.Fire(ProfileObserver.Event.Loaded, {
				Player = player,
				Data = Data.Get(player),
			}, true)

			Data.Update(player)
		else
			-- The player has left before the profile session started
			profile:EndSession()
		end
	else
		-- This condition should only happen when the Roblox server is shutting down
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function Data.Release(player: Player)
	local profile = Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end
end

function Data.Update(player: Player)
	local UPDATE_TASK_NAME = "Update_Profile:" .. tostring(player.UserId)
	--only update client profile one time at the end of frame to prevent multiple remote events fired

	if Tasks[UPDATE_TASK_NAME] then
		return
	end

	Tasks[UPDATE_TASK_NAME] = task.defer(function()
		local success, message = pcall(function()
			local profile = Profiles[player]
			if profile then
				Server.ProfileUpdated.Fire(player, profile.Data)
			end
		end)

		Tasks[UPDATE_TASK_NAME] = nil
		if not success then
			task.spawn(function()
				error(message)
			end)
		end
	end)
end

function Data.Reset(player: Player)
	local profile = Profiles[player]
	if not profile then
		return
	end

	profile.Data = Utils.CloneTable(Template.Template, true)

	Data.Update(player)

	Data.Release(player)
end
-- Data.Set(player: Player, event: string, ...: any): (boolean, string)
-- 	local data = Data.Get(player, true)
-- 	local pack = { ... }
-- 	local message = "Success"

-- 	if not data then
-- 		return false, message
-- 	end

-- 	local succes = true
-- 	pcall(function()
-- 		local modifierModule = script.Modifier:FindFirstChild(event)
-- 		if not modifierModule or not modifierModule:IsA("ModuleScript") then
-- 			succes, message = false, "Error: Modifier not found"
-- 		end

-- 		local modifier = require(modifierModule) :: (player: Player, data: Template.Profile, ...any) -> boolean
-- 		if not modifier or typeof(modifier) ~= "function" then
-- 			succes, message = false, "Error: Modifier not found"
-- 		end

-- 		succes, message = modifier(player, data, table.unpack(pack))
-- 	end)

-- 	return succes, message
-- end

return Data
