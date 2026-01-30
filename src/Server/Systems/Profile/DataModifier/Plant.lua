--!strict
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
--// Modules
---->> Interface
local ProfileInterface = require(ServerScriptService.Interfaces.Profile)
---->> Observers 
local PlayerObserver = require(ServerScriptService.Observers.PlayerObserver)
---->> Libraries
-- local Libraries = ReplicatedStorage.Shared.Libraries
-- local EconomyLibrary = require(Libraries.Economy)
local PLANTS = require(ReplicatedStorage.Shared.Libraries.Plants)

--// Constants & Enums
type Profile = ProfileInterface.Profile
-- local Currency = EconomyLibrary.Currency


local function IsDataValid(profile: Profile, plant: string?): boolean
    local valid = false
    if not profile then
        warn("Profile not found")
	elseif type and not PLANTS.Data[plant] then
        warn("Invalid plant type")
	else
        valid = true
	end
    return valid
end 

local function Add(profile: Profile, amount: number, plant: string): (boolean,string?)
	if not IsDataValid(profile, plant) then
		return false, `Invalid input data`
	end

	if amount < 0 or not amount then
		return false, `Attempt to add a currency that results in less than zero`
	end

	-- PlayerObserver.Fire(PlayerObserver.Event.Loaded, {
	-- 	Player = profile.Player,
	-- 	Data = profile,
	-- 	Amount = amount,
	-- 	Type = type,
	-- })

	-- profile.Balance[type] += amount
    local existing = profile.Inventory.Plants[plant]
    if not existing then
        existing = {
            Quantity = amount,
        }
        profile.Inventory.Plants[plant] = existing
    else
        existing.Quantity += amount
    end
	
    return true
end
-- local function Subtract(profile: Profile, amount: number, type: string): (boolean,string?)
-- 	if not IsDataValid(profile, type) then
-- 		return false, `Invalid input data`
-- 	end
 
-- 	local currentBalance: number = profile.Balance[type]
-- 	local newBalance = currentBalance - amount
-- 	if newBalance < 0 then
-- 		return false, `Attempt to edit a currency that results in less than zero`
-- 	end
-- 	profile.Balance[type] = newBalance

--     return true
-- end
-- local function Get(profile: Profile, type: string): (number?,string?)
-- 	if not IsDataValid(profile, type) then
-- 		return nil, `Invalid input data`
-- 	end

-- 	return profile.Balance[type]
-- end

return {
    Add = Add,
    -- Subtract = Subtract,
	-- Get = Get,
}