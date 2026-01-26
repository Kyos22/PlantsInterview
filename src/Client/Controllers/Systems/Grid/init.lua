-- -- StarterPlayerScripts/GridClickDebugger.client.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GridUtil = require(ReplicatedStorage.Shared.GridUtil)

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ====== CHỈNH ĐÚNG PATH SOIL CỦA BẠN ======
local soil: BasePart = workspace.Plot.Soil
local cellSize = soil:GetAttribute("CellSize") or 4

-- Raycast params: chỉ cho chạm Soil
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Whitelist
rayParams.FilterDescendantsInstances = { soil }
rayParams.IgnoreWater = true

-- -- (Optional) vẽ marker debug
local function drawMarker(pos: Vector3)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Size = Vector3.new(0.6, 0.6, 0.6)
	p.Position = pos + Vector3.new(0, 0.3, 0)
	p.Parent = workspace:FindFirstChild("Debug") or workspace
	game:GetService("Debris"):AddItem(p, 1.5)
end

local function handleWorldClick(screenPos: Vector2?)
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

	-- 1) worldPos -> cell
	local cx, cz = GridUtil.WorldToCell(soil, cellSize, hitPos)

	-- 2) validate inside
	if not GridUtil.IsCellInside(soil, cellSize, cx, cz) then
		print(("Clicked OUTSIDE grid: cell=(%d,%d)"):format(cx, cz))
		return
	end

	-- 3) cell -> snapped center world
	local snappedWorld = GridUtil.CellToWorldCenter(soil, cellSize, cx, cz)

	-- PRINT yêu cầu của bạn:
	print(("CLICK cell=(%d, %d) | snappedWorld=(%.2f, %.2f, %.2f)"):format(
		cx, cz,
		snappedWorld.X, snappedWorld.Y, snappedWorld.Z
	))

	-- debug marker để thấy snap
	drawMarker(snappedWorld)
end

-- -- PC: click chuột
-- mouse.Button1Down:Connect(function()
-- 	handleWorldClick(nil)
-- end)

-- -- Mobile + cả PC: bắt touch/click theo screen pos (ổn định hơn)
-- UserInputService.InputBegan:Connect(function(input, processed)
-- 	if processed then return end
-- 	if input.UserInputType == Enum.UserInputType.Touch then
-- 		handleWorldClick(input.Position)
-- 	end
-- end)
--!strict
--// Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)

--
export type APIsType = {}

local module = {} :: APIsType & Yumi.System

--// Yumi

--// APIs
module._Start = function()
	print("Grid Click Debugger")
    -- PC: click chuột
    mouse.Button1Down:Connect(function()
    handleWorldClick(nil)
    end)

    -- Mobile + cả PC: bắt touch/click theo screen pos (ổn định hơn)
    UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
    handleWorldClick(input.Position)
    end
    end)
end

return module
