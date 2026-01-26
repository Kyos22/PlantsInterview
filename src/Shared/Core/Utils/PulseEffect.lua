--!strict
local TweenService = game:GetService("TweenService")

return function(frame: Frame)
	if not frame then
		return
	end
	local uiScale = frame:FindFirstChildOfClass("UIScale") :: UIScale
	if not uiScale then
		uiScale = Instance.new("UIScale")
		if uiScale then
			uiScale.Parent = frame
			uiScale.Scale = 1
		end
	else
		uiScale.Scale = 1
	end

	local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true)

	TweenService:Create(uiScale, tweenInfo, { Scale = 1.4 }):Play()
end
