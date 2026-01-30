-->> Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-->> Modules
local Profile = require(ServerScriptService.Systems.Profile)
local GridUtil = require(ReplicatedStorage.Shared.GridUtil)
local Plants = require(ServerScriptService.Systems.Plants)

-->> Libraries
local PLANTS = require(ReplicatedStorage.Shared.Libraries.Plants)

--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services

----> Constructor
export type Config = {
    Player: Player,
    Slot: number,
    GardenModel: Model,
    Land: {
        Soil1: Part,
        -- Soil2: Part,
    },

}
local function prototype(self, config: Config)
    ---->> Public

    ---->> Private
    type field = {
        tasks: { {Name: string, Thread: thread} },
        connections: { {Name: string, Connection: RBXScriptConnection} },
    }
    local _private = {
        tasks = {},
        connections = {},
    } :: field
    self._private = _private

    return self
end

---->> Public Properties
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {}

function module.constructors.new(config: Config)
    local self = setmetatable(prototype({} :: any, config), module.metatable)
    local player = config.Player
    local profile = Profile.GetAsync(player, false, false)
	if not profile then
		task.spawn(function()
			error("Player data failed to load" .. player.UserId)
		end)

		player:Kick("Failed to load player data")

		return nil
	end
    self.Player = player
    self.Slot = config.Slot
    self.GardenModel = config.GardenModel
    self.Land = {
        Soil1 = config.Land.Soil1,
    }
    self.cellSize = self.Land.Soil1:GetAttribute("CellSize") :: string

    return self :: Type

end

---->> Private Functions

---->> APIs
function module.methods.Initialize(self: Type)
    local profile = Profile.GetAsync(self.Player, false, false)
    if not profile then return end

    -- local gardenData = profile.Data.Gardens[tostring(self.Slot)]
    local slot = profile.Garden.Slot
    
    -- local startTime = os.time()

    
    for plantKey, data in pairs(slot) do
        local coords = string.split(plantKey, "_")
        local cx, cz = tonumber(coords[1]), tonumber(coords[2])
        
        -- Tính toán lại vị trí World
        local snappedWorld = GridUtil.CellToWorldCenter(self.Land.Soil1, self.cellSize, cx, cz)
        local plantLibrary = PLANTS.Data[data.Name]
        print("dd", plantLibrary.GrowthDuration)
        local config = {
            Player = self.Player,
            Duration = plantLibrary.GrowthDuration or 15,
            Pos = { cx = cx, cz = cz },
            Name = data.Name,
            Model = self.GardenModel,
            StartTime = data.StartTime, -- Dùng StartTime cũ từ Data
            SnappedWorld = snappedWorld,
        }
        
        local plant = Plants.new(config)
        plant:Initialize()
    end

end

function module.methods.Destroy(self: Type)
    local _p = self._private
    for _, data in ipairs(_p.tasks) do
        local task_ = data.Thread
        if coroutine.status(task_) == "suspended" then
            task.cancel(task_)
        else
            task.defer(function()
                task.cancel(task_)
            end)
        end
    end
    for _, data in ipairs(_p.connections) do
        local conn = data.Connection
        conn:Disconnect()
    end

    do --other destroy logic
    end

    table.clear(self :: any)
end

function module.methods.Grid(self: Type, cx: number, cz: number,namePlant:string)
    
    local profile = Profile.GetAsync(self.Player, true, true)
    if not profile then
        return
    end
    
    local plantKey = cx .. "_" .. cz
    local slot = profile.Garden.Slot
    local gardenData = slot[tostring(plantKey)]
    
    if gardenData then 
        print("Ô này đã có cây!") 
        return 
    end
    local startTime = os.time()
    slot[plantKey] = {
        Name = namePlant,
        StartTime = startTime,
    }

    if self.cellSize and typeof(self.cellSize) == "number" then
        local snappedWorld = GridUtil.CellToWorldCenter(self.Land.Soil1, self.cellSize, cx, cz)
        local data = PLANTS.Data[namePlant]
        print("snapp",snappedWorld,data)
        local config = {
            Player = self.Player,
            Duration = data.GrowthDuration,
            Pos = {
                cx = cx,
                cz = cz,
            },
            Name = data.Name,
            Model = self.GardenModel,
            StartTime = os.time(),
            SnappedWorld = snappedWorld,
        }
        local plant = Plants.new(config)
        plant:Initialize()
    end
end

function module.methods.DoABC(self: Type)
    print("Super DoABC")
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
