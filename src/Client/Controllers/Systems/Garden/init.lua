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
local function Get(slotIndex): Garden.Type | nil
    local slot = OUTSIDE:WaitForChild(tostring(slotIndex))
    local garden = slot:FindFirstChildOfClass("Model")
    print("garden")
    if not garden then
        return

    end

    local soil1 = garden:WaitForChild("GardenBox1"):WaitForChild("Land")
    local soil2 = garden:WaitForChild("GardenBox2"):WaitForChild("Land")    

    return {
        Player = Players.LocalPlayer,
        Slot = slotIndex,
        GardenModel = garden,
        Land = {
            Soil1 = soil1,
            Soil2 = soil2,
        },
    }
end

module._Start = function()
    Client.Garden.Init.On(function(indexSlot:number)
        print("slot",indexSlot)
        local garden = Get(indexSlot)
        print("garden",garden)
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
