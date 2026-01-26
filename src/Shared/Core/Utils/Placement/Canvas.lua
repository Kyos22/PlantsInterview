--!strict

local ZERO = Vector3.new(0, 0, 0)
local AABB = require(script.Parent.AABB)
local SETTINGS = require(script.Parent.SETTINGS)

local function Overlap(cfA: CFrame, sizeA: Vector3, cfB: CFrame, sizeB: Vector3): number
	local rbCF = cfA:Inverse() * cfB
	local A = AABB.FromPositionSize(ZERO, sizeA)
	local B = AABB.FromPositionSize(rbCF.Position, AABB.WorldBoundingBox(rbCF, sizeB))

	local union = A:Union(B)
	local area = union and union.Max - union.Min or ZERO

	return area.X * area.Y * area.Z
end

export type Canvas = {
	__index: Canvas,
	new: (canvasPart: BasePart, placements: { Canvas }) -> Canvas,
	Calculate: (
		self: Canvas,
		calculationType: "Canvas" | "Placement",
		model: Model?,
		position: Vector3?,
		rotation: number?
	) -> (CFrame?, Vector2?),
	Collided: (self: Canvas, model: Model) -> boolean,
	Destroy: (self: Canvas) -> (),

	Canvas: BasePart,
	Placements: { Canvas },
}

local Canvas = {} :: Canvas
Canvas.__index = Canvas

-- constructor

function Canvas.new(canvasPart, placements: { Canvas })
	local self: Canvas = setmetatable({} :: any, Canvas)

	self.Canvas = canvasPart
	self.Placements = placements

	return self
end

function Canvas:Calculate(calculationType: "Canvas" | "Placement", ...): (CFrame?, Vector2?)
	if calculationType == "Canvas" then
		local canvasSize = self.Canvas.Size
		local cframe = self.Canvas.CFrame

		local up = Vector3.new(0, 1, 0)
		local back = -Vector3.FromNormalId(Enum.NormalId.Top)

		local dot = back:Dot(Vector3.new(0, 1, 0))
		local axis = (math.abs(dot) == 1) and Vector3.new(-dot, 0, 0) or up

		local right = CFrame.fromAxisAngle(axis, math.pi / 2) * back
		local top = back:Cross(right).Unit

		local cf = cframe * CFrame.fromMatrix(-back * canvasSize / 2, right, top, back)
		local size = Vector2.new((canvasSize * right).Magnitude, (canvasSize * top).Magnitude)

		return cf, size
	elseif calculationType == "Placement" then
		local model: Model, position: Vector3, rotation: number = ...
		local cf, size = self:Calculate("Canvas")
		if cf and size and model.PrimaryPart then
			local modelSize = AABB.WorldBoundingBox(CFrame.Angles(0, rotation, 0), model.PrimaryPart.Size)

			-- use AABB to make sure the model has no 2D area on other canvases
			local sum = 0
			local placements = self.Placements
			for i = 1, #placements do
				local canvasCF, canvasSize = placements[i]:Calculate("Canvas")
				if canvasCF and canvasSize then
					sum += Overlap(
						CFrame.new(position) * (canvasCF - canvasCF.Position),
						Vector3.new(modelSize.X, modelSize.Z, 1),
						canvasCF,
						Vector3.new(canvasSize.X, canvasSize.Y, 1)
					)
				end
			end

			-- only clamp we're fully covered (margin of error included)
			local area = modelSize.X * modelSize.Z
			local clamp = (sum < area - 0.1)

			local lpos = cf:PointToObjectSpace(position)
			local size2 = (size - Vector2.new(modelSize.X, modelSize.Z)) / 2
			local x = clamp and math.clamp(lpos.X, -size2.X, size2.X) or lpos.X
			local y = clamp and math.clamp(lpos.Y, -size2.Y, size2.Y) or lpos.Y

			local g = SETTINGS.GRID.SIZE
			if g > 0 then
				x = math.sign(x) * ((math.abs(x) - math.abs(x) % g) + (size2.X % g))
				y = math.sign(y) * ((math.abs(y) - math.abs(y) % g) + (size2.Y % g))
			end

			return cf * CFrame.new(x, y, -modelSize.Y / 2) * CFrame.Angles(-math.pi / 2, rotation, 0)
		end
	end

	return nil, nil
end

function Canvas:Collided(model)
	local primaryPart = model.PrimaryPart
	if not primaryPart then
		return false
	end
	local isColliding = false
	local touching = primaryPart:GetTouchingParts()

	for i = 1, #touching do
		if not touching[i]:IsDescendantOf(model) then
			isColliding = true
			break
		end
	end

	return isColliding
end

function Canvas:Destroy()
	self.Placements = {}
	self.Canvas:Destroy()
end

--

return Canvas
