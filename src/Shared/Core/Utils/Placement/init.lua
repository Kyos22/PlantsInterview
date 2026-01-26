--!strict
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Assets = ReplicatedStorage.Shared.Assets
local Furnitures = Assets:WaitForChild("Furnitures")

local Canvas = require(script.Canvas)
local Greedy = require(script.Parent.Greedy)
local SETTINGS = require(script.SETTINGS)
local Signal = require(ReplicatedStorage.Packages.Signal)

local function Split(str: string): (number, number, number)
	-- Remove all spaces and split by comma
	local numbers = string.gsub(str, "%s+", ""):split(",")

	-- Convert strings to numbers
	local n1 = tonumber(numbers[1]) or 1
	local n2 = tonumber(numbers[2]) or 1
	local n3 = tonumber(numbers[3]) or 1

	return n1, n2, n3
end

export type Placement = {
	__index: Placement,
	new: (placementFolder: Folder) -> Placement,
	Add: (self: Placement, cellPart: BasePart) -> (),

	Refresh: (self: Placement) -> (),
	Update: (self: Placement) -> (),
	Lock: (self: Placement, cellPart: BasePart) -> (),
	Unlock: (self: Placement, cellPart: BasePart) -> (),

	Rotate: (self: Placement) -> (),
	Move: (self: Placement) -> (),
	Place: (self: Placement) -> (),

	Bind: (self: Placement) -> (),
	Destroy: (self: Placement) -> (),

	Object: Model,
	Source: Folder,
	Cells: Model,
	Placement: Model,

	Movement: {
		Rotation: number,
		Angles: CFrame,
		Target: CFrame,
	},

	Canvas: Canvas.Canvas?,
	Index: { [BasePart]: Canvas.Canvas },
	Grid: { Canvas.Canvas },
	Params: { Cells: RaycastParams, Canvas: RaycastParams },

	Collided: Signal.Signal<BasePart>,
	Placed: Signal.Signal<Model>,
	Rotated: Signal.Signal<number>,
	Terminated: Signal.Signal<nil>,
	Activated: Signal.Signal<nil>,

	Connections: { RBXScriptConnection },
}
local Class: Placement = {} :: Placement
Class.__index = Class

function Class.new(placementFolder: Folder): Placement
	local self: Placement = setmetatable({} :: any, Class)

	self.Connections = {}
	self.Collided = Signal.new()
	self.Rotated = Signal.new()
	self.Placed = Signal.new()
	self.Activated = Signal.new()
	self.Terminated = Signal.new()

	self.Movement = {
		Rotation = 0,
		Target = CFrame.new(0, 0, 0),
		Angles = CFrame.new(0, 0, 0),
	}

	self.Index = {}
	self.Grid = {}
	self.Source = placementFolder

	self.Cells = self.Source:WaitForChild("Cells") :: Model
	self.Placement = self.Source:WaitForChild("Canvas") :: Model

	local canvasParams = RaycastParams.new()
	canvasParams.FilterType = Enum.RaycastFilterType.Include
	canvasParams.IgnoreWater = true
	canvasParams.FilterDescendantsInstances = { self.Placement }

	local cellParams = RaycastParams.new()
	cellParams.FilterType = Enum.RaycastFilterType.Include
	cellParams.IgnoreWater = true
	cellParams.FilterDescendantsInstances = { self.Cells }

	self.Params = {
		Cells = cellParams,
		Canvas = canvasParams,
	}

	table.insert(
		self.Connections,
		self.Cells.ChildAdded:Connect(function(child: Instance)
			if child:IsA("BasePart") then
				self:Refresh()
			end
		end)
	)

	table.insert(
		self.Connections,
		self.Cells.ChildRemoved:Connect(function(child: Instance)
			if child:IsA("BasePart") then
				self:Refresh()
			end
		end)
	)

	self:Refresh()
	return self
end

function Class:Bind()
	self.Object = Furnitures:WaitForChild("Model"):Clone() :: Model
	self.Object.Parent = workspace
	self.Object.Name = "Test"

	local camera = workspace.CurrentCamera

	ContextActionService:BindAction("Rotate", function(_, inputState: Enum.UserInputState, _): Enum.ContextActionResult?
		if inputState == Enum.UserInputState.Begin then
			self:Rotate()
		end

		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.R)
	ContextActionService:BindAction("Place", function(_, inputState: Enum.UserInputState, _): Enum.ContextActionResult?
		if inputState == Enum.UserInputState.Begin then
			self:Place()
		end

		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.MouseButton1)

	local gridParts: { Instance } = {}
	for _, cell in pairs(self.Grid) do
		table.insert(gridParts, cell.Canvas)
	end

	local highLight = Instance.new("Highlight")
	highLight.Parent = workspace.CurrentCamera

	RunService.RenderStepped:Connect(function(dt)
		local mousePos = UserInputService:GetMouseLocation()

		local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
		local cellResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, self.Params.Cells) -- adjust length
		local canvasResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, self.Params.Canvas) -- adjust length

		local cellPart = cellResult and cellResult.Instance
		local canvasPart = canvasResult and canvasResult.Instance

		if self.Object and cellPart and canvasPart then
			-- print(canvasPart, self.Index[canvasPart])
			if self.Index[canvasPart] then
				self.Canvas = self.Index[canvasPart]
			end

			highLight.Parent = cellPart
			highLight.Adornee = cellPart
			highLight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

			if self.Canvas then
				local cf = self.Canvas:Calculate("Placement", self.Object, cellPart.Position, self.Movement.Rotation)
				if cf then
					local offset = (cf.Position - self.Movement.Target.Position)
					if offset.Magnitude > 0.01 then
						local unit = offset.Unit * 0.1
						local roll = -unit.X
						local pitch = -unit.Z

						self.Movement.Angles = CFrame.Angles(roll, 0, pitch)
					end

					self.Movement.Target = cf
				end
			end
		end

		self.Object:PivotTo(self.Object:GetPivot():Lerp(self.Movement.Target * self.Movement.Angles, 0.25))
		self.Movement.Angles = self.Movement.Angles:Lerp(CFrame.Angles(0, 0, 0), 0.1)
	end)
end

function Class:Rotate()
	self.Movement.Rotation += math.pi / 2
	self.Rotated:Fire(self.Movement.Rotation)
end

function Class:Place()
	-- local mouse = Player:GetMouse()
	-- local model = self.Object
	-- local rotation = self.Movement.Rotation

	-- local cf = self.Canvas[1]:Calculate("Placement", model, mouse.Hit.Position, rotation)
	-- if cf then
	-- 	local success = Client.Placement.Call(model.Name, cf)
	-- 	if success then
	-- 		self.Placed:Fire(model)
	-- 	end
	-- end
end

function Class:Move() end

function Class:Refresh()
	local oldPlacement = self.Placement:FindFirstChildWhichIsA("Model")
	if oldPlacement then
		oldPlacement:Destroy()
	end

	for _, canvas in pairs(self.Grid) do
		canvas:Destroy()
	end

	self.Index = {}
	self.Grid = {}

	local newGrid, finalModel = Greedy(self.Cells, SETTINGS.GRID.SIZE)
	finalModel.Parent = self.Placement
	for _, canvasPart in pairs(newGrid) do
		local canvas = Canvas.new(canvasPart, self.Grid)
		self.Index[canvasPart] = canvas
		table.insert(self.Grid, canvas)
	end

	local _, canvas = next(self.Grid)
	self.Canvas = canvas

	-- print("New grid size", #self.Grid)
end

function Class:Update() end

function Class:Destroy() end

return Class
