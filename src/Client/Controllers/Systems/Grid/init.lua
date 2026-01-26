--!strict

-->> Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-->> Modules
local GridUtil = require(ReplicatedStorage.Shared.GridUtil)
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)

-->> Inputs 
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local soil: BasePart = workspace.Plot.Soil
local cellSize = soil:GetAttribute("CellSize") or 4

-->> Raycast
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { soil }
rayParams.IgnoreWater = true

export type APIsType = {
	connections: {[string] : RBXScriptConnection}
}

local module = {} :: APIsType & Yumi.System


local function DrawMarker(pos: Vector3)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Size = Vector3.new(0.6, 0.6, 0.6)
	p.Position = pos + Vector3.new(0, 0.3, 0)
	p.Parent = workspace:FindFirstChild("Debug") or workspace
	game:GetService("Debris"):AddItem(p, 1.5)
end

local function Click(screenPos: Vector2?)
	-- PC: dùng mouse.Hit; Mobile: dùng screenPos -> Camera ray
	local cam = workspace.CurrentCamera
	if not cam then return end

	local origin: Vector3
	local direction: Vector3

	if screenPos then
		local unitRay = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
		origin = unitRay.Origin
		direction = unitRay.Direction * 500
	else
		origin = cam.CFrame.Position
		direction = (mouse.Hit.Position - origin).Unit * 500
	end

	local result = workspace:Raycast(origin, direction, rayParams)
	if not result then
		-- print("No hit on soil")
		return
	end

	local hitPos = result.Position
	    print("cc", cellSize, typeof(cellSize))

	if not cellSize and typeof(cellSize) == "number" then

		local cx, cz = GridUtil.WorldToCell(soil, cellSize, hitPos)

		if not GridUtil.IsCellInside(soil, cellSize, cx, cz) then
			print(("Clicked OUTSIDE grid: cell=(%d,%d)"):format(cx, cz))
			return
		end

		local snappedWorld = GridUtil.CellToWorldCenter(soil, cellSize, cx, cz)

		print(("CLICK cell=(%d, %d) | snappedWorld=(%.2f, %.2f, %.2f)"):format(
			cx, cz,
			snappedWorld.X, snappedWorld.Y, snappedWorld.Z
		))

		DrawMarker(snappedWorld)
	end

end

local function Destroy()
	for _, conn in pairs(module.connections) do
        conn:Disconnect()
    end
end

module._Start = function()
	print("Grid Click Debugger")
    mouse.Button1Down:Connect(function()
        Click(nil)
    end)
	-- if #module.connections > 0 then
	-- 	Destroy()
	-- end

	-- module.connections["Click"] = mouse.Button1Down:Connect(function()
    --     Click(nil)
    -- end)

	-- module.connections["TouchInput"] = UserInputService.InputBegan:Connect(function(input, processed)
    --     if processed then return end
    --     if input.UserInputType == Enum.UserInputType.Touch then
    --         Click(Vector2.new(input.Position.X, input.Position.Y))
    --     end
    -- end)
	UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            Click(Vector2.new(input.Position.X, input.Position.Y))
        end
    end)
end

return module
