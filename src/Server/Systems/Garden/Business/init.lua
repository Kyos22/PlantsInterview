-->> Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-->> Modules
local Profile = require(ServerScriptService.Systems.Profile)
local GridUtil = require(ReplicatedStorage.Shared.GridUtil)

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
function module.methods.Initialize(self: Type) end

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

function module.methods.Grid(self: Type, cx: number, cz: number)
    if self.cellSize and typeof(self.cellSize) == "number" then
        local snappedWorld = GridUtil.CellToWorldCenter(self.Land.Soil1, self.cellSize, cx, cz)
        print("snapp",snappedWorld)
    end
end

function module.methods.DoABC(self: Type)
    print("Super DoABC")
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
