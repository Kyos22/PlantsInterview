--!strict
-- local UserInputService = game:GetService("UserInputService")

return function(player:Player) : boolean
    local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return false end

	local guiInset = playerGui:FindFirstChild("TouchGui")
	if guiInset then
		-- is mobile or tablet
		return true
	else
		-- is pc
		return false
	end
end
