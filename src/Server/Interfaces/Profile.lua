--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Modules
local ProfileSystem = require(ServerScriptService.Systems.Profile)

--// Interface
local interface: ProfileSystem.APIsType = {} :: any

interface.Reset = function(...)
	return ProfileSystem.Reset(...)
end
interface.Get = function(...)
	return ProfileSystem.Get(...)
end
interface.GetAsync = function(...)
	return ProfileSystem.GetAsync(...)
end
interface.Update = function(...)
	return ProfileSystem.Update(...)
end

interface.RequestProfile = function(...)
	return ProfileSystem.RequestProfile(...)
end

export type Profile = ProfileSystem.Profile

return interface
