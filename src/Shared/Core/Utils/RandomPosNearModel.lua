--!strict
-- This script provides a function to find a random walkable position
-- on a surface surrounding a player in Roblox, ensuring direct line of sight.

local DEBUGGING = false

-- Configuration for the random position generation
local CONFIG = {
	DISTANCE = {
		MIN = 2, -- Minimum distance from the player to the random point
		MAX = 7, -- Maximum distance from the player to the random point
	},
	HEIGHT_OFFSET = 6, -- How high above the random point to start the downward raycast
	DOWNWARD_RANGE = 12, -- Maximum distance for the downward raycast to find a surface
	TRIES_PER_RADIUS = 10, -- Maximum attempts to find a valid position at a given radius range
	RADIUS_DECREMENT_STEP = 0.5, -- How much to narrow the radius if TRIES_PER_RADIUS fail (e.g., 0.5 stud)
	ANGLE_THRESHOLD = 0.7, -- Dot product threshold for a walkable surface (e.g., 0.7 for angles up to ~45 degrees)
	LOS_OFFSET = Vector3.new(0, 2, 0), -- Offset for the line of sight raycast start from HumanoidRootPart
	LOS_OBSTRUCTION = 3, -- Minimum distance for an obstruction to be considered blocking LOS
	LAST_POS_AVOIDANCE_RADIUS = 5, -- Radius around a previously found position to avoid
	NUM_LAST_POSITIONS_TO_AVOID = 6, -- Number of previous positions to keep track of and avoid
	TOTAL_MAX_ATTEMPTS = 150, -- Absolute maximum number of attempts before giving up entirely
}

-- Private variable to store the last successfully found positions (list/array)
local _lastFoundPositions: { Vector3 } = {}

--- Creates RaycastParams for raycasting, excluding specified instances.
-- @param ignoreDescendantsTable table A table of instances whose descendants should be ignored.
-- @return RaycastParams
local function CreateRaycastParams(ignoreDescendantsTable: { Instance })
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignoreDescendantsTable
	params.IgnoreWater = true -- Generally ignore water for surface finding
	return params
end

--- Checks if a surface normal indicates a walkable surface.
-- @param normal Vector3 The normal vector of the surface.
-- @return boolean True if the surface is walkable, false otherwise.
local function IsWalkableSurface(normal: Vector3): boolean
	-- A surface is walkable if its normal points sufficiently upwards.
	-- Dot product of normal and Vector3.up (0,1,0) should be greater than the threshold.
	return normal:Dot(Vector3.new(0, 1, 0)) > CONFIG.ANGLE_THRESHOLD
end

--- Checks if a given position is too close to any of the previously found positions.
-- @param position Vector3 The position to check.
-- @return boolean True if the position is too close to a previous one, false otherwise.
local function IsTooCloseToPrevious(position: Vector3): boolean
	for _, lastPos in ipairs(_lastFoundPositions) do
		if (position - lastPos).Magnitude < CONFIG.LAST_POS_AVOIDANCE_RADIUS then
			return true
		end
	end
	return false
end

--- Adds a new position to the list of last found positions, maintaining the maximum size.
-- @param position Vector3 The position to add.
local function AddLastFoundPosition(position: Vector3)
	table.insert(_lastFoundPositions, 1, position) -- Insert at the beginning (most recent)
	-- Trim the list if it exceeds the maximum size
	while #_lastFoundPositions > CONFIG.NUM_LAST_POSITIONS_TO_AVOID do
		table.remove(_lastFoundPositions) -- Remove from the end (oldest)
	end
end

--- Finds a random position on a surface around the player, considering LOS and walkability.
-- This function will prioritize finding positions at the furthest range first,
-- and then gradually narrows the radius if previous attempts fail.
-- It includes a global escape to prevent excessive attempts.
-- @param character Model The player's character model.
-- @return (Vector3?, Vector3?) The found random position and its normal, or (nil, nil) if no valid position could be found.
local function FindRandomPosition(model: Model): (Vector3?, Vector3?)
	local primary = model.PrimaryPart
	if not primary then
		if DEBUGGING then
			warn("PrimaryPart not found for Model:", model.Name)
		end
		return nil, nil
	end

	local originPosition = primary.Position
	local raycastIgnoreList: { Instance } = { model } -- Always ignore the character itself for raycasts

	local downwardRaycastParams = CreateRaycastParams(raycastIgnoreList)
	local losRaycastParams = CreateRaycastParams(raycastIgnoreList)

	local currentMaxRadius = CONFIG.DISTANCE.MAX + CONFIG.RADIUS_DECREMENT_STEP
	local totalAttempts = 0 -- NEW: Global attempt counter

	-- Outer loop: gradually narrow the search radius
	while currentMaxRadius >= CONFIG.DISTANCE.MIN do
		if totalAttempts >= CONFIG.TOTAL_MAX_ATTEMPTS then
			if DEBUGGING then
				warn("Global attempt limit reached for Hatch. Aborting search.")
			end
			_lastFoundPositions = {} -- Clear history if we gave up
			return nil, nil
		end

		local minSearchRadius = math.max(CONFIG.DISTANCE.MIN, currentMaxRadius - CONFIG.RADIUS_DECREMENT_STEP)

		for _ = 1, CONFIG.TRIES_PER_RADIUS do
			totalAttempts = totalAttempts + 1 -- Increment global counter for each actual attempt

			-- Generate a random point within the current valid horizontal range
			local randomRadius = math.random(minSearchRadius * 100, currentMaxRadius * 100) / 100
			local randomAngle = math.random() * math.pi * 2

			local xOffset = math.cos(randomAngle) * randomRadius
			local zOffset = math.sin(randomAngle) * randomRadius

			local potentialGroundPoint = originPosition + Vector3.new(xOffset, CONFIG.HEIGHT_OFFSET, zOffset)
			local raycastEnd = potentialGroundPoint - Vector3.new(0, CONFIG.DOWNWARD_RANGE, 0)

			local hitResult =
				workspace:Raycast(potentialGroundPoint, raycastEnd - potentialGroundPoint, downwardRaycastParams)

			if hitResult and hitResult.Instance and IsWalkableSurface(hitResult.Normal) then
				local surfacePosition = hitResult.Position

				if IsTooCloseToPrevious(surfacePosition) then
					if DEBUGGING then
						print("Point too close to previous")
					end
					continue
				end

				local losStart = primary.Position + CONFIG.LOS_OFFSET
				local losDirection = (surfacePosition - losStart).Unit
				local losDistance = (surfacePosition - losStart).Magnitude

				local losResult = workspace:Raycast(losStart, losDirection * losDistance, losRaycastParams)

				if
					not losResult
					or (
						losResult.Instance == hitResult.Instance
						and (losResult.Position - surfacePosition).Magnitude < 1
					)
				then
					AddLastFoundPosition(surfacePosition)
					return surfacePosition, hitResult.Normal
				elseif
					losResult and (losResult.Position - losStart).Magnitude < losDistance - CONFIG.LOS_OBSTRUCTION
				then
					continue
				end
			end
		end

		currentMaxRadius = currentMaxRadius - CONFIG.RADIUS_DECREMENT_STEP
		if currentMaxRadius < CONFIG.DISTANCE.MIN then
			currentMaxRadius = CONFIG.DISTANCE.MIN
		end
	end

	-- If no valid position is found after all attempts (even at the minimum radius), clear the list and return nil
	_lastFoundPositions = {}
	if DEBUGGING then
		warn("Failed to find a valid random position after all radius attempts for character:", model.Name)
	end
	return nil, nil
end

return FindRandomPosition
