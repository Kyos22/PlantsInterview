
local transCache: {[Model]: {[Instance]: number}} = {}
return function(player: Player, isLobby: boolean)
	local Character = player.Character or player.CharacterAdded:Wait() :: Model
	-- print(Character.Name, Character)
	local humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	if isLobby then
		--humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		humanoid.AutoRotate = true

		-- for _, part in pairs(Character:GetDescendants()) do
		-- 	if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
		-- 		part.Transparency = 0
		-- 	elseif part:IsA("Decal") or part:IsA("Texture") then
		-- 		part.Transparency = 0
		-- 	end
		-- end
		
		if not transCache[Character] then
			return
		end
		for ins, defaultValue in pairs(transCache[Character]) do
			local transProperty: string
			if ins:IsA("BasePart") and ins.Name ~= "HumanoidRootPart" then
				transProperty = "Transparency"
			elseif ins:IsA("Decal") or ins:IsA("Texture") then
				transProperty = "Transparency"
			elseif ins:IsA("BillboardGui") then
				ins.Enabled = true
			end
			if not transProperty then
				continue
			end
			ins[transProperty] = defaultValue
		end
		transCache[Character] = nil
	else -- is in restaurant
		--humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		humanoid.AutoRotate = false

		transCache[Character] = {}
		for _, ins in pairs(Character:GetDescendants()) do
			local transProperty: string
			if ins:IsA("BasePart") and ins.Name ~= "HumanoidRootPart" then
				transProperty = "Transparency"
			elseif ins:IsA("Decal") or ins:IsA("Texture") then
				transProperty = "Transparency"
			elseif ins:IsA("BillboardGui") then
				ins.Enabled = false
			end
			if not transProperty or ins[transProperty] == 1 then
				continue
			end
			transCache[Character][ins] = ins[transProperty]
			ins[transProperty] = 1
		end
	end
end
