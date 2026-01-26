--!strict
export type AABB = {
	__index: AABB,
	new: (a: Vector3, b: Vector3) -> AABB,
	Intersects: (self: AABB, aabb: AABB) -> boolean,
	Union: (self: AABB, aabb: AABB) -> AABB?,

	FromPositionSize: (pos: Vector3, size: Vector3) -> AABB,
	WorldBoundingBox: (cf: CFrame, size: Vector3) -> Vector3,

	Min: Vector3,
	Max: Vector3,
}

local AABB = {} :: AABB
AABB.__index = AABB

local function Compare(a: Vector3, b: Vector3, func: (number, number) -> number): Vector3
	return Vector3.new(func(a.X, b.X), func(a.Y, b.Y), func(a.Z, b.Z))
end

function AABB.new(a: Vector3, b: Vector3)
	local self: AABB = setmetatable({} :: any, AABB)

	self.Min = Compare(a, b, math.min)
	self.Max = Compare(a, b, math.max)

	return self
end

function AABB.FromPositionSize(pos: Vector3, size: Vector3)
	return AABB.new(pos + size / 2, pos - size / 2)
end

function AABB.WorldBoundingBox(cf: CFrame, size: Vector3): Vector3
	local size2 = size / 2

	local c1 = cf:VectorToWorldSpace(Vector3.new(size2.X, size2.Y, size2.Z))
	local c2 = cf:VectorToWorldSpace(Vector3.new(-size2.X, size2.Y, size2.Z))
	local c3 = cf:VectorToWorldSpace(Vector3.new(-size2.X, -size2.Y, size2.Z))
	local c4 = cf:VectorToWorldSpace(Vector3.new(-size2.X, -size2.Y, -size2.Z))
	local c5 = cf:VectorToWorldSpace(Vector3.new(size2.X, -size2.Y, -size2.Z))
	local c6 = cf:VectorToWorldSpace(Vector3.new(size2.X, size2.Y, -size2.Z))
	local c7 = cf:VectorToWorldSpace(Vector3.new(size2.X, -size2.Y, size2.Z))
	local c8 = cf:VectorToWorldSpace(Vector3.new(-size2.X, size2.Y, -size2.Z))

	local max = Vector3.new(
		math.max(c1.X, c2.X, c3.X, c4.X, c5.X, c6.X, c7.X, c8.X),
		math.max(c1.Y, c2.Y, c3.Y, c4.Y, c5.Y, c6.Y, c7.Y, c8.Y),
		math.max(c1.Z, c2.Z, c3.Z, c4.Z, c5.Z, c6.Z, c7.Z, c8.Z)
	)

	local min = Vector3.new(
		math.min(c1.X, c2.X, c3.X, c4.X, c5.X, c6.X, c7.X, c8.X),
		math.min(c1.Y, c2.Y, c3.Y, c4.Y, c5.Y, c6.Y, c7.Y, c8.Y),
		math.min(c1.Z, c2.Z, c3.Z, c4.Z, c5.Z, c6.Z, c7.Z, c8.Z)
	)

	return max - min
end

function AABB:Intersects(aabb: AABB)
	local aMax, aMin = self.Max, self.Min
	local bMax, bMin = aabb.Max, aabb.Min

	if bMin.X > aMax.X then
		return false
	end
	if bMin.Y > aMax.Y then
		return false
	end
	if bMin.Z > aMax.Z then
		return false
	end
	if bMax.X < aMin.X then
		return false
	end
	if bMax.Y < aMin.Y then
		return false
	end
	if bMax.Z < aMin.Z then
		return false
	end

	return true
end

function AABB:Union(aabb: AABB)
	if not self:Intersects(aabb) then
		return nil
	end

	local min = Compare(aabb.Min, self.Min, math.max)
	local max = Compare(aabb.Max, self.Max, math.min)

	return AABB.new(min, max)
end

return AABB
