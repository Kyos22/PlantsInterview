-- ReplicatedStorage/Shared/GridUtil.lua
local GridUtil = {}

-- Convert world position -> (cellX, cellZ) index in plot local space
function GridUtil.WorldToCell(soilPart: BasePart, cellSize: number, worldPos: Vector3)
	-- local space relative to soil
	local lp = soilPart.CFrame:PointToObjectSpace(worldPos)

	-- soil.Size is centered at soilPart.CFrame (Origin at center)
	local halfX = soilPart.Size.X * 0.5
	local halfZ = soilPart.Size.Z * 0.5

	-- Convert local position into "grid coordinates" with origin at soil min corner
	-- gx/gz = 0..N-1
	local gx = (lp.X + halfX) / cellSize
	local gz = (lp.Z + halfZ) / cellSize

	local cellX = math.floor(gx)
	local cellZ = math.floor(gz)

	return cellX, cellZ
end

-- Convert (cellX, cellZ) -> snapped world position at center of that cell
function GridUtil.CellToWorldCenter(soilPart: BasePart, cellSize: number, cellX: number, cellZ: number)
	local halfX = soilPart.Size.X * 0.5
	local halfZ = soilPart.Size.Z * 0.5

	-- center of the cell in local space
	local localX = (-halfX) + (cellX + 0.5) * cellSize
	local localZ = (-halfZ) + (cellZ + 0.5) * cellSize

	-- keep Y at soil top surface (optional)
	local y = soilPart.Size.Y * 0.5
	local localPos = Vector3.new(localX, y, localZ)

	return soilPart.CFrame:PointToWorldSpace(localPos)
end

-- Check if cell index is inside soil bounds
function GridUtil.IsCellInside(soilPart: BasePart, cellSize: number, cellX: number, cellZ: number)
	local maxX = math.floor(soilPart.Size.X / cellSize) - 1
	local maxZ = math.floor(soilPart.Size.Z / cellSize) - 1
	return cellX >= 0 and cellZ >= 0 and cellX <= maxX and cellZ <= maxZ
end

return GridUtil
