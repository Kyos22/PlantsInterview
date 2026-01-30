--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-->> Modules
local GridUtil = require(ReplicatedStorage.Shared.GridUtil)
local Hover = require(script.Parent.Components.Hover)


-->> Inputs
local mouse = Players.LocalPlayer:GetMouse()

-->> Interfaces
local DisplayInterface = require(ReplicatedStorage.Controllers.Interfaces.Display)
-->> Observers
local GardenObserver = require(ReplicatedStorage.Controllers.Observers.Garden)
local Client = require(ReplicatedStorage.Shared.Network.Client)

----> Constructor
export type Config = {
    Player: Player,
    Slot: number,
    GardenModel: Model,
    Land: {
        Soil1: BasePart,
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

    self.Player = config.Player
    self.Slot = config.Slot
    self.GardenModel = config.GardenModel
    self.Land = {
        Soil1 = config.Land.Soil1,
    }
    
    self.cellSize = self.Land.Soil1:GetAttribute("CellSize") :: string

    self:Initialize()
    return self :: Type
end

---->> Private Functions
local function DrawMarker(pos: Vector3)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Size = Vector3.new(0.6, 0.6, 0.6)
	p.Position = pos + Vector3.new(0, 0.3, 0)
	p.Parent = workspace:FindFirstChild("Debug") or workspace
	game:GetService("Debris"):AddItem(p, 1.5)
end

---->> APIs
function module.methods.Initialize(self: Type)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Include
    rayParams.FilterDescendantsInstances = { self.Land.Soil1 }
    rayParams.IgnoreWater = true
    self.rayParams = rayParams

    mouse.Button1Down:Connect(function()
        self:Click(nil)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            self:Click(Vector2.new(input.Position.X, input.Position.Y))
        end
    end)

    Hover.Initialize(self, rayParams)
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

function module.methods.Click(self: Type,screenPos: Vector2?)
    local cam = workspace.CurrentCamera
	if not cam then return end

	local origin: Vector3
	local direction: Vector3

	if screenPos then
		local unitRay = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
		origin = unitRay.Origin
		direction = unitRay.Direction * 500
	else
		origin = cam.CFrame.Position
		direction = (mouse.Hit.Position - origin).Unit * 500
	end

	local result = workspace:Raycast(origin, direction, self.rayParams)
	if not result then
		-- print("No hit on soil")
		return
	end

	local hitPos = result.Position
	if self.cellSize and typeof(self.cellSize) == "number" then
        print("hitpos",hitPos)
		local cx: number, cz = GridUtil.WorldToCell(self.Land.Soil1, self.cellSize, hitPos)
        print("cx,cz",cx,cz)
		if not GridUtil.IsCellInside(self.Land.Soil1, self.cellSize, cx, cz) then
			print(("Clicked OUTSIDE grid: cell=(%d,%d)"):format(cx, cz))
			return
		end

		local snappedWorld = GridUtil.CellToWorldCenter(self.Land.Soil1, self.cellSize, cx, cz)

		print(("CLICK cell=(%d, %d) | snappedWorld=(%.2f, %.2f, %.2f)"):format(
			cx, cz,
			snappedWorld.X, snappedWorld.Y, snappedWorld.Z
		))
        local selectedPlant = DisplayInterface.Hotbar.GetInstance().SelectPlant.Value
        print("selec",selectedPlant)
        -- GardenObserver.Fire(GardenObserver.Event.Sow, {
        --     Name = selectedPlant,
        -- })
        Client.Garden.Sow.Fire(selectedPlant,{
            cx = cx,
            cz = cz,
        })
        GardenObserver.Fire(GardenObserver.Event.Sow, {
            Name = selectedPlant,
        })
		-- DrawMarker(snappedWorld)
	end
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
