--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local Plant = require(script.Plant)
--
export type APIsType = {
    new: (config: Plant.Config) -> (Plant.Type),
}

local module = {} :: APIsType & Yumi.System

--// Yumi

--// APIs
module._Setup = function()
    
end

module._Start = function()
    
end

module.new = function(config)
    return Plant.new(config)
end

return module
