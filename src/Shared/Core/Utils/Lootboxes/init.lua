--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(script.Parent)

export type Item = {
	Name: string,
	Rarity: string,
	Weight: number,
	Value: number,
	[string]: any,
}

export type Library = { Item }

-- Seed the random number generator
math.randomseed(tick())

local function GetTotalWeightOfLootTable(items: Library): number
	local weight: number = 0
	for _, item in pairs(items) do
		weight += item.Weight or 0
	end

	return weight
end

--- Selects a random item from a given table of items based on their 'Weight' property.
-- This function returns the selected item without immediately calculating its percentage,
-- as the percentage will be relative to the *final generated lootbox*.
-- @param items A table where each entry is an item with a 'Weight' field.
-- @return The randomly selected item (a copy), or nil if the table is empty.
local function SelectRandomWeightedItem(items: Library): Item?
	local totalWeight = GetTotalWeightOfLootTable(items)
	if totalWeight == 0 then
		return nil -- No items or all items have 0 weight
	end

	local randomNumber = math.random(1, totalWeight)
	local cumulativeWeight = 0

	for _, item in pairs(items) do
		cumulativeWeight = cumulativeWeight + item.Weight
		if randomNumber <= cumulativeWeight then
			-- Create a copy of the item
			local selectedItem = table.clone(item)
			return selectedItem
		end
	end

	return nil -- Should not happen if totalWeight > 0
end

--- Generates a list of items for a lootbox with guaranteed rarities.
-- This function will ensure at least one Ultimate and one Mythical item
-- are included, and the remaining slots are filled based on the general
-- rarity distribution. Duplicates of guaranteed items are possible in
-- the remaining slots as per the overall probability.
-- After selection, it calculates each item's percentage based on its
-- weight relative to the *total weight of all items in this specific lootbox*.
-- @param numItems The total number of items to generate for the lootbox.
-- @return A table containing the generated items, each with a 'Percentage' field.
function GenerateBoxFromLibrary(library: Library, numItems: number)
	local selectedItems = {}

	-- Separate items by rarity for easy access
	local itemsByRarity = {}
	for _, item in pairs(library) do
		if not itemsByRarity[item.Rarity] then
			itemsByRarity[item.Rarity] = {}
		end
		table.insert(itemsByRarity[item.Rarity], item)
	end

	-- --- Step 1: Guarantee one Ultimate item ---
	if itemsByRarity["Ultimate"] and #itemsByRarity["Ultimate"] > 0 then
		local ultimateIndex = math.random(1, #itemsByRarity["Ultimate"])
		table.insert(selectedItems, itemsByRarity["Ultimate"][ultimateIndex])
	else
		warn("No Ultimate items available in the library!")
	end

	-- --- Step 2: Guarantee one Mythical item ---
	if itemsByRarity["Mythical"] and #itemsByRarity["Mythical"] > 0 then
		local mythicalIndex = math.random(1, #itemsByRarity["Mythical"])
		table.insert(selectedItems, itemsByRarity["Mythical"][mythicalIndex])
	else
		warn("No Mythical items available in the library!")
	end

	-- --- Step 3: Fill the remaining slots with weighted random items ---
	local remainingSlots = numItems - #selectedItems
	for _ = 1, remainingSlots do
		local randomItem = SelectRandomWeightedItem(library)
		if randomItem then
			table.insert(selectedItems, randomItem)
		else
			warn("Could not select a random item for a remaining slot. Items might be empty or all weights are zero.")
		end
	end

	-- --- Step 4: Calculate and assign percentages based on the generated lootbox items ---
	local totalWeightInLootbox = 0
	for _, item in ipairs(selectedItems) do
		totalWeightInLootbox = totalWeightInLootbox + item.Weight
	end

	-- Avoid division by zero if for some reason totalWeightInLootbox is 0
	if totalWeightInLootbox > 0 then
		for i, item in ipairs(selectedItems) do
			-- Create a new table to ensure we are not modifying the original Items item reference
			local itemWithPercentage = table.clone(item)
			itemWithPercentage.Percentage = (item.Weight / totalWeightInLootbox) * 100
			selectedItems[i] = itemWithPercentage
		end
	else
		warn("Total weight of items in lootbox is zero. Percentages cannot be calculated.")
	end

	return selectedItems
end

function GetPercentageFromBox(library: Library, items: { string }): { Item }
	local function GetItem(itemName: string): Item?
		for _, item in pairs(library) do
			if item.Name == itemName then
				return item
			end
		end

		return
	end

	local lootbox = {}
	for _, itemName in pairs(items) do
		local item = GetItem(itemName)
		if item then
			table.insert(lootbox, item)
		end
	end

	local totalWeightInLootbox = 0
	for _, item in ipairs(lootbox) do
		totalWeightInLootbox = totalWeightInLootbox + item.Weight
	end

	if totalWeightInLootbox > 0 then
		for i, item in ipairs(lootbox) do
			-- Create a new table to ensure we are not modifying the original Items item reference
			local itemWithPercentage = table.clone(item)
			itemWithPercentage.Percentage = (item.Weight / totalWeightInLootbox) * 100
			lootbox[i] = itemWithPercentage
		end
	else
		warn("Total weight of items in lootbox is zero. Percentages cannot be calculated.")
	end

	return lootbox
end

function GetModifiedWeights(baseWeights: Library, luckFactor: number): Library
	luckFactor = math.max(0, luckFactor or 1) -- Ensure luckFactor is at least 0

	local newLibrary: Library = Utils.CloneTable(baseWeights, true)

	for _, item: Item in pairs(newLibrary) do
		local newWeight = item.Weight

		if item.Rarity == "Common" then
			-- Option A: Reduce common items slightly with luck
			newWeight = item.Weight * (1 - (luckFactor - 1) * 0.1) -- Reduce by 10% for each point of luckFactor above 1
		elseif item.Rarity == "Uncommon" then
			newWeight = item.Weight * (1 - (luckFactor - 1) * 0.05) -- Less reduction
		elseif item.Rarity == "Rare" then
			-- Maybe no change, or slight increase/decrease depending on desired curve
		elseif item.Rarity == "Epic" then
			newWeight = item.Weight * (1 + (luckFactor - 1) * 0.5) -- 50% more likely per point of luckFactor above 1
		elseif item.Rarity == "Legendary" then
			newWeight = item.Weight * (1 + (luckFactor - 1) * 1) -- Double likelihood per point of luckFactor above 1
		elseif item.Rarity == "Mythical" then
			newWeight = item.Weight * (1 + (luckFactor - 1) * 1.5) -- 1.5x likelihood per point of luckFactor above 1
		elseif item.Rarity == "Ultimate" then
			newWeight = item.Weight * (1 + (luckFactor - 1) * 2) -- Double likelihood per point of luckFactor above 1
		end

		-- Ensure weights don't go below 1 (or 0 if you want them to be truly impossible)
		item.Weight = math.max(1, math.floor(newWeight))
	end
	return newLibrary
end

function ShuffleArray(array: { any }): { any }
	-- fisher-yates
	local output: { any } = {}
	for index = 1, #array do
		local offset: number = index - 1
		local value: any = array[index]
		local randomIndex: number = offset * math.random()

		local flooredIndex: number = randomIndex - randomIndex % 1

		if flooredIndex == offset then
			output[#output + 1] = value
		else
			output[#output + 1] = output[flooredIndex + 1]
			output[flooredIndex + 1] = value
		end
	end

	return output
end

local libraries = {}
for _, list in pairs(script:GetChildren()) do
	if list:IsA("ModuleScript") then
		libraries[list.Name] = require(list) :: Library
	end
end

function FindItemByName(library: { Item }, searchingName: string): Item?
	for _, item in pairs(library) do
		if item.Name == searchingName then
			return item
		end
	end

	return nil -- Item not found
end

return {
	GetModifiedWeights = GetModifiedWeights,
	GenerateBoxFromLibrary = GenerateBoxFromLibrary,
	GetPercentageFromBox = GetPercentageFromBox,
	SelectRandomWeightedItem = SelectRandomWeightedItem,
	ShuffleArray = ShuffleArray,
	FindItemByName = FindItemByName,

	Libraries = libraries,
}
