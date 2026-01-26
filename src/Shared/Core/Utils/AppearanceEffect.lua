--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local RthroScaler = require(ReplicatedStorage.Packages.RthroScaler)
--// Constants & Enums
local DefaultConfig = {
	BodyScale = {
		BodyDepthScale = 0.75,
		BodyHeightScale = 0.75,
		BodyWidthScale = 0.75,
		HeadScale = 1.25,
		BodyProportionScale = 0,
		BodyTypeScale = 0,
	},
	BodySize = {
		Height = 5.75,
	},
}
--// Variables
type AccessoryData = {
	Handle: 
		{
			Part: BasePart,
			Size: Vector3
		},
	OtherParts: 
		{
			{
				Part: BasePart,
				Size: Vector3,
				RelativePos: Vector3,
			}
		},
}
local AccessoryCache: {
	[Humanoid]: {[Accessory]: AccessoryData}	
} = {}
--private function
local function InitAccessoryAutoScaleEvent(hum: Humanoid, item: Accessory)
	local handle = item:FindFirstChild("Handle") :: BasePart
	if not handle then
		return
	end
	local otherParts = {}
	for _,ins in ipairs(item:GetDescendants()) do
		if ins:IsA("BasePart") and ins ~= handle then
			table.insert(otherParts,{
				Part = ins,
				Size = ins.Size,
				RelativePos = handle.CFrame:PointToObjectSpace(ins.Position)
			})
		end
	end
	local originalSize = handle.Size
	local originalSizeValue: Vector3Value = handle:FindFirstChild("OriginalSize")
	if originalSizeValue then
		originalSize = originalSizeValue.Value
	end
	local data: AccessoryData = {
		Handle = {
			Part = handle,
			Size = originalSize
		},
		OtherParts = otherParts
	}
	AccessoryCache[hum][item] = data
	
	local function ScaleOtherParts()
		local data = AccessoryCache[hum][item]
		if not data then
			return
		end
		local handle = data.Handle.Part
		local handleSize = handle.Size
		local handleOriginSize = data.Handle.Size
		local scaleVector = Vector3.new(
			handleSize.X/handleOriginSize.X,
			handleSize.Y/handleOriginSize.Y,
			handleSize.Z/handleOriginSize.Z)
		for _,partData in ipairs(data.OtherParts) do
			local part = partData.Part
			local partOriginSize = partData.Size
			part.Size = Vector3.new(
				scaleVector.X*partOriginSize.X,
				scaleVector.Y*partOriginSize.Y,
				scaleVector.Z*partOriginSize.Z)

			-- Calculate the new relative position based on the scaled handle
			local scaledRelativePos = Vector3.new(
				partData.RelativePos.X * scaleVector.X,
				partData.RelativePos.Y * scaleVector.Y,
				partData.RelativePos.Z * scaleVector.Z
			)

			-- Apply new position by transforming from the handle's CFrame
			part.Position = handle.CFrame:PointToWorldSpace(scaledRelativePos)
		end
	end
	handle:GetPropertyChangedSignal("Size"):Connect(function()
		ScaleOtherParts()
	end)
	
	--check if handle already scaled
	if originalSizeValue and (originalSizeValue.Value-handle.Size).Magnitude > 0.01 then
		ScaleOtherParts()
	end
end
local function InitLayerClothingAutoScaleEvent(char: Model, item: Accessory)
	local handle = item:FindFirstChild("Handle") :: BasePart
	if not handle:FindFirstChildWhichIsA("WrapLayer") then
		return
	end
	local root: BasePart = nil
	if item.AccessoryType == Enum.AccessoryType.Jacket then
		root = char:FindFirstChild("UpperTorso") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.Pants then
		root = char:FindFirstChild("LowerTorso") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.Shirt then
		root = char:FindFirstChild("UpperTorso") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.TShirt then
		root = char:FindFirstChild("UpperTorso") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.DressSkirt then
		root = char:FindFirstChild("UpperTorso") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.Shorts then
		root = char:FindFirstChild("LowerTorso") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.Sweater then
		root = char:FindFirstChild("UpperTorso") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.LeftShoe then
		root = char:FindFirstChild("LeftFoot") :: BasePart
	elseif item.AccessoryType == Enum.AccessoryType.RightShoe then
		root = char:FindFirstChild("RightFoot") :: BasePart
	end
	if not root then
		return
	end
	local rootOriginSize = root.Size
	local handleOriginSize = handle.Size
	local handleRelativePos = root.CFrame:PointToObjectSpace(handle.Position)
	root:GetPropertyChangedSignal("Size"):Connect(function()
		
		local rootSize = root.Size
		local scaleVector = Vector3.new(
			rootSize.X/rootOriginSize.X,
			rootSize.Y/rootOriginSize.Y,
			rootSize.Z/rootOriginSize.Z)
		handle.Size = Vector3.new(
			scaleVector.X*handleOriginSize.X,
			scaleVector.Y*handleOriginSize.Y,
			scaleVector.Z*handleOriginSize.Z)
		-- print(scaleVector)
		-- Calculate the new relative position based on the scaled handle
		local scaledRelativePos = Vector3.new(
			handleRelativePos.X * scaleVector.X,
			handleRelativePos.Y * scaleVector.Y,
			handleRelativePos.Z * scaleVector.Z
		)

		-- Apply new position by transforming from the handle's CFrame
		handle.Position = root.CFrame:PointToWorldSpace(scaledRelativePos)
	end)
end

export type Config = {
	BodyScale: {
		BodyDepthScale: number,
		BodyHeightScale: number,
		BodyWidthScale: number,
		HeadScale: number,
		BodyProportionScale: number,
		BodyTypeScale: number,
	},
	BodySize: {
		Height: number,
	},
}
local function Apply(char: Model, config_: Config?)
	local config = config_ or DefaultConfig
	local humanoid = char:WaitForChild("Humanoid") :: Humanoid
	humanoid.BreakJointsOnDeath = false
	
	--scale and size handle
	for name,value in pairs(config.BodyScale) do
		local numberValue: NumberValue = humanoid:FindFirstChild(name)
		if not numberValue then
			warn(name.." not found")
			continue
		end
		numberValue.Value = value
	end
	RthroScaler.raw(char,config.BodySize.Height)
	
	local head = char:FindFirstChild("Head") :: BasePart
	head.CanCollide = true
	--accessory cache handle
	AccessoryCache[humanoid] = {}
	for _,child in ipairs(char:GetChildren()) do
		if child:IsA("Accessory") then
			InitAccessoryAutoScaleEvent(humanoid,child)
			--InitLayerClothingAutoScaleEvent(player,child)
		end
	end
	char.DescendantAdded:Connect(function(ins)
		if ins:IsA("Accessory") then
			InitAccessoryAutoScaleEvent(humanoid,ins)
			--InitLayerClothingAutoScaleEvent(player,ins)
		end
	end)
end

return Apply
