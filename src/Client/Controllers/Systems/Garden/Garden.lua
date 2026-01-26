--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
-->> Modules
local GridUtil = require(ReplicatedStorage.Shared.GridUtil)
-->> Inputs
local mouse = Players.LocalPlayer:GetMouse()
local THICKNESS = 0.15
local Y_OFFSET = 0.05
local lastCX, lastCZ = nil, nil

----> Constructor
export type Config = {
    Player: Player,
    Slot: number,
    GardenModel: Model,
    Land: {
        Soil1: Part,
        Soil2: Part,
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
        Soil2 = config.Land.Soil2,
    }
    
    self.cellSize = self.Land.Soil1:GetAttribute("CellSize") :: string

    self:Initialize()
    return self :: Type
end

---->> Private Functions
local function GetCellCFrame(soilPart: BasePart, cellSize: number, cellX: number, cellZ: number)
	local halfX = soilPart.Size.X * 0.5
	local halfZ = soilPart.Size.Z * 0.5

	local localX = (-halfX) + (cellX + 0.5) * cellSize
	local localZ = (-halfZ) + (cellZ + 0.5) * cellSize

	local localY = (soilPart.Size.Y * 0.5) + (THICKNESS * 0.5) + Y_OFFSET

	return soilPart.CFrame * CFrame.new(localX, localY, localZ)
end

local function Hide(self)
	if self.hoverPart.Transparency ~= 1 then
		self.hoverPart.Transparency = 1
	end
	lastCX, lastCZ = nil, nil
end
---->> APIs
function module.methods.Initialize(self: Type)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Include
    rayParams.FilterDescendantsInstances = { self.Land.Soil1 }
    rayParams.IgnoreWater = true
    self.rayParams = rayParams

    local hoverPart = Instance.new("Part")
    hoverPart.Name = "HoverCell"
    hoverPart.Anchored = true
    hoverPart.CanCollide = false
    hoverPart.CanQuery = false
    hoverPart.CanTouch = false
    hoverPart.Transparency = 1 
    hoverPart.Material = Enum.Material.Neon
    hoverPart.Parent = workspace
    self.hoverPart = hoverPart

    hoverPart.Color = Color3.fromRGB(80, 255, 120)

    mouse.Button1Down:Connect(function()
        self:Click(nil)
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            self:Click(Vector2.new(input.Position.X, input.Position.Y))
        end
    end)

    RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if not cam then
		Hide(self)
		return
	end

	local mousePos = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	local screenPos = Vector2.new(mousePos.X, mousePos.Y - inset.Y)

	local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)

	if not result then
		Hide(self)
		return
	end

	local hitPos = result.Position
	local cx, cz = GridUtil.WorldToCell(self.Land.Soil1, self.cellSize, hitPos)

	-- Ngoài bounds -> hide
	if not GridUtil.IsCellInside(self.Land.Soil1, self.cellSize, cx, cz) then
		Hide(self)
		return
	end

	-- Nếu vẫn cùng ô thì khỏi update
	if cx == lastCX and cz == lastCZ then
		return
	end
	lastCX, lastCZ = cx, cz

	-- Set size + CFrame + show
	hoverPart.Size = Vector3.new(self.cellSize, THICKNESS, self.cellSize)
	hoverPart.CFrame = GetCellCFrame(self.Land.Soil1, self.cellSize, cx, cz)
	hoverPart.Transparency = 0.45

	-- (Tuỳ bạn) Debug print khi hover ô mới
	print(("HOVER cell=(%d,%d)"):format(cx, cz))
end)
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
    print("Super DoABC")
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
    print("cc", self.cellSize, typeof(self.cellSize))
	if self.cellSize and typeof(self.cellSize) == "string" then

		local cx, cz = GridUtil.WorldToCell(self.Land.Soil1, self.cellSize, hitPos)

		if not GridUtil.IsCellInside(self.Land.Soil1, self.cellSize, cx, cz) then
			print(("Clicked OUTSIDE grid: cell=(%d,%d)"):format(cx, cz))
			return
		end

		local snappedWorld = GridUtil.CellToWorldCenter(self.Land.Soil1, self.cellSize, cx, cz)

		print(("CLICK cell=(%d, %d) | snappedWorld=(%.2f, %.2f, %.2f)"):format(
			cx, cz,
			snappedWorld.X, snappedWorld.Y, snappedWorld.Z
		))

		-- DrawMarker(snappedWorld)
	end
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
