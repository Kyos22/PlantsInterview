--!strict
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local System = require(ReplicatedStorage.Controllers.Systems.Profile)

--// Interface
local interface: System.APIsType = {} :: any

interface.Get = function(...)
    return System.Get(...)
end
interface.GetAsync = function(...)
    return System.GetAsync(...)
end

export type Profile = System.Profile

return interface
