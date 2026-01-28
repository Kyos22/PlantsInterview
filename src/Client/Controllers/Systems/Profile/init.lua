-- --!strict
-- --// Service
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- --// Modules
-- local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
-- local ProfileTemplate = require(ReplicatedStorage.Shared.Libraries.Profile.Template)
-- ---->> Network
-- local Client = require(ReplicatedStorage.Shared.Network.Client)
-- ---->> Observer
-- local ProfileObserver = require(ReplicatedStorage.Controllers.Observers.Profile)
-- --// Variables
-- local Profile: ProfileTemplate.Profile
-- --// Type
-- export type Profile = ProfileTemplate.Profile
-- --
-- export type APIsType = {
--     Get: () -> Profile?,
--     GetAsync: () -> Profile?
-- }

-- local module = {} :: APIsType & Yumi.System

-- --// Yumi
-- module._Start = function()
--     Client.ProfileUpdated.On(function(data: unknown)
--         Profile = data :: Profile
--         ProfileObserver.Fire(ProfileObserver.Event.Updated, {
--             Data = Profile
--         } :: ProfileObserver.UpdatedEventArgs)
--     end)

--     Profile = Client.GetProfile.Invoke() :: Profile
-- end
-- --// APIs
-- module.Get = function()
--     return Profile
-- end
-- module.GetAsync = function()
--     if not Profile then
--         Profile = Client.GetProfile.Invoke() :: Profile
--     end
--     return Profile
-- end

-- return module
--!strict
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Shared = ReplicatedStorage.Shared
---->> Yumi
local Yumi = require(Shared.Core.Yumi)
---->> Network
-- local Client = require(Shared.Network.Client)
local Client = require(ReplicatedStorage.Shared.Network.Client)

local ProfileTemplate = require(ReplicatedStorage.Shared.Libraries.Profile.Template)
---->> Observers
-- local ProfileObserver = require(ReplicatedStorage.SharedControllers.Observers.Profile)
---->> Libraries
-- local ProfileLibrary = require(Libraries.Profile)

--// Constants & Enums
local GET_ASYNC_TIMEOUT = 5
local GET_ASYNC_INTERVAL = 0.5

--// Types
export type APIsType = {
	Get: () -> ProfileTemplate.Profile?,
	GetAsync: () -> ProfileTemplate.Profile?,

	Data: any,
	Version: number,
}

export type Type = Yumi.System & APIsType

--// System
local System = {} :: Type
System.Data = nil
System.Version = 0

local function UpdateData(data: any, version: number?)
	System.Data = data
	if version then
		System.Version = version
	end

	-- local args: ProfileObserver.UpdatedEventArgs = {
	-- 	Data = data
	-- }
	-- ProfileObserver.Fire(ProfileObserver.Event.DataUpdated, args)
end

System._Setup = function()
	-- Client.Profile.Updated.On(UpdateData)
    Client.ProfileUpdated.On(UpdateData)
end

System._Start = function()
	if not System.Data then
		local future = Client.Profile.Get.Invoke(true)
		local success, data, version = future:Await()
		
		UpdateData(data, version)
	end
end

--// APIs
export type Profile = ProfileTemplate.Profile

System.Get = function()
	return System.Data
end

System.GetAsync = function()
	local counter = 0
	local isWarned = false

	while not System.Data do
		counter += GET_ASYNC_INTERVAL
		if not isWarned and counter > GET_ASYNC_TIMEOUT then
			isWarned = true
			warn(`[Data] Infinite yield while getting local Data (Client)`)
		end

		task.wait(GET_ASYNC_INTERVAL)
	end

	return System.Data
end

return System