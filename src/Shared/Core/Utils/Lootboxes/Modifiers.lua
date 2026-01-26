--!strict

local Probability = {}

-- Returns a weighted random item from a table of weights. Specify weightField to use a field from the table entries as the weight.
function Probability.GetRandomByWeight<K, V>(items: { [K]: V }, weightField: string?): (K, V)
	local chosenIndex = next(items) :: K

	-- Calculate sum
	local sum = 0
	for _, value in items do
		local weight = (
			if type(value) == "number" then value elseif type(value) == "table" then value[weightField] else 0
		) :: number
		sum += weight
	end

	-- Get random item from given weights
	local index = math.random() * sum
	for candidate, value in items do
		local weight = (
			if type(value) == "number" then value elseif type(value) == "table" then value[weightField] else 0
		) :: number
		if weight <= 0 then
			continue
		end

		index -= weight
		if index <= 0 then
			chosenIndex = candidate
			break
		end
	end

	return chosenIndex, items[chosenIndex]
end

-- Returns the best item from a table based on rarity and an optional luckModifier. Specify rarityField to use a field from the table entries as the rarity.
function Probability.GetRandomByRarity<K, V>(
	data: { [K]: V },
	luckModifier: number?,
	defaultIndex: K?,
	rarityField: string?
): (K, V)
	-- Function is not guaranteed to overwrite the best pick, so allow user to specify a default index
	local bestPickIndex = (defaultIndex or next(data)) :: K
	local bestPickValue = data[bestPickIndex]
	local highestPickedRarity = -math.huge

	local rarityThreshold = 1 * (luckModifier or 1)

	-- Loop through all items and roll to find which is selected
	for index, value in pairs(data) do
		local rarity = (
			if type(value) == "number" then value elseif type(value) == "table" then value[rarityField] else 0
		) :: number

		local isChosen = rarity > highestPickedRarity
			and (math.random(1 * 1000, rarity * 1000) / 1000) <= rarityThreshold
		if isChosen then
			bestPickIndex = index
			bestPickValue = value
			highestPickedRarity = rarity
		end
	end

	return bestPickIndex, bestPickValue
end

return Probability
