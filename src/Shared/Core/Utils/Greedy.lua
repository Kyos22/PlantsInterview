local function Split(str: string): (number, number, number)
	-- Remove all spaces and split by comma
	local numbers = string.gsub(str, "%s+", ""):split(",")

	-- Convert strings to numbers
	local n1 = tonumber(numbers[1]) or 1
	local n2 = tonumber(numbers[2]) or 1
	local n3 = tonumber(numbers[3]) or 1

	return n1, n2, n3
end

return function(gridModel: Model, cell_size: number)
	local grid = {}
	for _, cellPart in pairs(gridModel:GetChildren()) do
		if cellPart:IsA("BasePart") then
			local r, c, _ = Split(cellPart.Name)
			grid[r] = grid[r] or {}
			grid[r][c] = grid[r][c] or cellPart
		end
	end

	local height = 1

	local min_x, max_x = math.huge, -math.huge
	local min_y, max_y = math.huge, -math.huge
	for x, yt in pairs(grid) do
		min_x = math.min(min_x, x)
		max_x = math.max(max_x, x)
		for y in pairs(yt) do
			min_y = math.min(min_y, y)
			max_y = math.max(max_y, y)
		end
	end

	local isVisited = {}
	for x = min_x, max_x do
		isVisited[x] = {}
		for y = min_y, max_y do
			isVisited[x][y] = false
		end
	end

	local function isOccupied(x, y)
		if grid[x] and grid[x][y] then
			return true
		else
			return false
		end
	end

	local cuboids = {}
	for x = min_x, max_x do
		for y = min_y, max_y do
			if isVisited[x][y] or not isOccupied(x, y) then
				continue
			end
			local startX, startY = x, y
			local endX, endY = x, y
			isVisited[x][y] = true

			-- Extend X
			while endX < max_x do
				local newEndX = endX + 1
				if isVisited[newEndX][y] or not isOccupied(newEndX, y) then
					break
				end
				isVisited[newEndX][y] = true
				endX = newEndX
			end

			-- Extend Y
			while endY < max_y do
				local newEndY = endY + 1
				local rowUsable = true
				for dx = startX, endX do
					if isVisited[dx][newEndY] or not isOccupied(dx, newEndY) then
						rowUsable = false
						break
					end
				end
				if not rowUsable then
					break
				end
				for dx = startX, endX do
					isVisited[dx][newEndY] = true
				end
				endY = newEndY
			end

			table.insert(cuboids, { SX = startX, SY = startY, EX = endX, EY = endY })
		end
	end

	local finalParts = {}
	local finalModel = Instance.new("Model")
	finalModel.Name = "Merged"
	-- Create merged parts
	for i, cub in ipairs(cuboids) do
		local width = (cub.EX - cub.SX + 1) * cell_size
		local depth = (cub.EY - cub.SY + 1) * cell_size
		local newPart = Instance.new("Part")
		newPart.Anchored = true
		newPart.Size = Vector3.new(width, height, depth)
		newPart.Position = Vector3.new(
			((cub.SX + cub.EX) / 2) * cell_size + cell_size / 2,
			height / 2,
			((cub.SY + cub.EY) / 2) * cell_size + cell_size / 2
		)

		newPart.Name = tostring(i) .. "_Canvas"
		newPart.Parent = finalModel -- Adjust as needed
		table.insert(finalParts, newPart)
	end

	local sourceCFrame = gridModel:GetBoundingBox()
	finalModel:PivotTo(sourceCFrame)

	return finalParts, finalModel
end
