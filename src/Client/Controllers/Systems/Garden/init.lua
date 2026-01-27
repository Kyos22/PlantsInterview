--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
local Client = require(ReplicatedStorage.Shared.Network.Client)
local OUTSIDE = workspace:WaitForChild("OUTSIDE") :: Folder
local Garden = require(script.Garden)
--
export type APIsType = {}

local module = {} :: APIsType & Yumi.System

--// Yumi

--// APIs
local function Get(slotIndex : number): Garden.Type | nil
    local slot = OUTSIDE:WaitForChild(tostring(slotIndex))
    local garden = slot:FindFirstChildOfClass("Model") :: Model
    print("garden")
    if not garden then
        return

    end

    local soil1 = garden:WaitForChild("GardenBox"):WaitForChild("Land")

    return {
        Player = Players.LocalPlayer,
        Slot = slotIndex,
        GardenModel = garden,
        Land = {
            Soil1 = soil1,
        }
    }
end

module._Start = function()
    Client.Garden.Init.On(function(indexSlot:number)
        local garden = Get(indexSlot)
        local gardenBusiness = Garden.new(garden)
    end)
end

export type Config = {
    Player: Player,
    Slot: number,
    GardenModel: Model,
    Land: {
        Soil1: Part,
        Soil2: Part,
    },
}
return module
