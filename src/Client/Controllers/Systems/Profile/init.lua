
--!strict
-->> Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-->> Modules
local Shared = ReplicatedStorage.Shared
local Yumi = require(Shared.Core.Yumi)
local ProfileTemplate = require(ReplicatedStorage.Shared.Libraries.Profile.Template)

---->> Network
local Client = require(ReplicatedStorage.Shared.Network.Client)

---->> Observers
-- local ProfileObserver = require(ReplicatedStorage.SharedControllers.Observers.Profile)

-->> Constants & Enums
local GET_ASYNC_TIMEOUT = 5
local GET_ASYNC_INTERVAL = 0.5

-->> Types
export type APIsType = {
	Get: () -> ProfileTemplate.Profile?,
	GetAsync: () -> ProfileTemplate.Profile?,

	Data: any,
	Version: number,
}

export type Type = Yumi.System & APIsType

-->> System
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