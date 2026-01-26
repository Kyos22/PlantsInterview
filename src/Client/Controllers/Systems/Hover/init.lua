--!strict

-->> Services 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")


-->> Modules
local GridUtil = require(ReplicatedStorage.Shared.GridUtil)


local soil: BasePart = workspace.Plot.Soil
local cellSize = soil:GetAttribute("CellSize") or 4

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { soil }
rayParams.IgnoreWater = true

local hoverPart = Instance.new("Part")
hoverPart.Name = "HoverCell"
hoverPart.Anchored = true
hoverPart.CanCollide = false
hoverPart.CanQuery = false
hoverPart.CanTouch = false
hoverPart.Transparency = 1 
hoverPart.Material = Enum.Material.Neon
hoverPart.Parent = workspace

hoverPart.Color = Color3.fromRGB(80, 255, 120)

local THICKNESS = 0.15
local Y_OFFSET = 0.05

local lastCX, lastCZ = nil, nil

local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)

export type APIsType = {}

local module = {} :: APIsType & Yumi.System

local function GetCellCFrame(soilPart: BasePart, cellSize: number, cellX: number, cellZ: number)
	local halfX = soilPart.Size.X * 0.5
	local halfZ = soilPart.Size.Z * 0.5

	local localX = (-halfX) + (cellX + 0.5) * cellSize
	local localZ = (-halfZ) + (cellZ + 0.5) * cellSize

	local localY = (soilPart.Size.Y * 0.5) + (THICKNESS * 0.5) + Y_OFFSET

	return soilPart.CFrame * CFrame.new(localX, localY, localZ)
end

local function Hide()
	if hoverPart.Transparency ~= 1 then
		hoverPart.Transparency = 1
	end
	lastCX, lastCZ = nil, nil
end

-->> APIs
module._Start = function()
    
RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if not cam then
		Hide()
		return
	end

	local mousePos = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	local screenPos = Vector2.new(mousePos.X, mousePos.Y - inset.Y)

	local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)

	if not result then
		Hide()
		return
	end

	local hitPos = result.Position
	local cx, cz = GridUtil.WorldToCell(soil, cellSize, hitPos)

	-- Ngoài bounds -> hide
	if not GridUtil.IsCellInside(soil, cellSize, cx, cz) then
		Hide()
		return
	end

	-- Nếu vẫn cùng ô thì khỏi update
	if cx == lastCX and cz == lastCZ then
		return
	end
	lastCX, lastCZ = cx, cz

	-- Set size + CFrame + show
	hoverPart.Size = Vector3.new(cellSize, THICKNESS, cellSize)
	hoverPart.CFrame = GetCellCFrame(soil, cellSize, cx, cz)
	hoverPart.Transparency = 0.45

	-- (Tuỳ bạn) Debug print khi hover ô mới
	print(("HOVER cell=(%d,%d)"):format(cx, cz))
end)

end

return module
