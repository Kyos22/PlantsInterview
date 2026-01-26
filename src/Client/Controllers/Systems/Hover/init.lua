local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local GridUtil = require(ReplicatedStorage.Shared.GridUtil)

local player = Players.LocalPlayer

-- ====== CHỈNH ĐÚNG PATH SOIL CỦA BẠN ======
local soil: BasePart = workspace.Plot.Soil
local cellSize = soil:GetAttribute("CellSize") or 4

-- Raycast chỉ trúng Soil (highlight part sẽ không ảnh hưởng)
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Whitelist
rayParams.FilterDescendantsInstances = { soil }
rayParams.IgnoreWater = true

-- ====== Highlight Part (1 part duy nhất) ======
local hoverPart = Instance.new("Part")
hoverPart.Name = "HoverCell"
hoverPart.Anchored = true
hoverPart.CanCollide = false
hoverPart.CanQuery = false
hoverPart.CanTouch = false
hoverPart.Transparency = 1 -- mặc định ẩn
hoverPart.Material = Enum.Material.Neon
hoverPart.Parent = workspace

-- bạn có thể đổi màu highlight tại đây
hoverPart.Color = Color3.fromRGB(80, 255, 120)

-- độ dày mỏng của ô highlight + nhô lên chút để không bị z-fighting
local THICKNESS = 0.15
local Y_OFFSET = 0.05

-- cache ô trước đó để khỏi set liên tục
local lastCX, lastCZ = nil, nil

-- Helper: trả về CFrame đặt hoverPart đúng tâm ô + đúng rotation của soil
local function getCellCFrame(soilPart: BasePart, cellSize: number, cellX: number, cellZ: number)
	local halfX = soilPart.Size.X * 0.5
	local halfZ = soilPart.Size.Z * 0.5

	-- tâm ô trong local space của soil
	local localX = (-halfX) + (cellX + 0.5) * cellSize
	local localZ = (-halfZ) + (cellZ + 0.5) * cellSize

	-- đặt trên mặt đất (top surface)
	local localY = (soilPart.Size.Y * 0.5) + (THICKNESS * 0.5) + Y_OFFSET

	return soilPart.CFrame * CFrame.new(localX, localY, localZ)
end

local function hideHover()
	if hoverPart.Transparency ~= 1 then
		hoverPart.Transparency = 1
	end
	lastCX, lastCZ = nil, nil
end


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
    
-- Update mỗi frame để hover mượt
RunService.RenderStepped:Connect(function()
	local cam = workspace.CurrentCamera
	if not cam then
		hideHover()
		return
	end

	-- Lấy vị trí chuột/touch trên màn hình
	local mousePos = UserInputService:GetMouseLocation()
	local inset = GuiService:GetGuiInset()
	local screenPos = Vector2.new(mousePos.X, mousePos.Y - inset.Y)

	-- Ray từ screenPos xuống world
	local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)

	if not result then
		hideHover()
		return
	end

	local hitPos = result.Position
	local cx, cz = GridUtil.WorldToCell(soil, cellSize, hitPos)

	-- Ngoài bounds -> hide
	if not GridUtil.IsCellInside(soil, cellSize, cx, cz) then
		hideHover()
		return
	end

	-- Nếu vẫn cùng ô thì khỏi update
	if cx == lastCX and cz == lastCZ then
		return
	end
	lastCX, lastCZ = cx, cz

	-- Set size + CFrame + show
	hoverPart.Size = Vector3.new(cellSize, THICKNESS, cellSize)
	hoverPart.CFrame = getCellCFrame(soil, cellSize, cx, cz)
	hoverPart.Transparency = 0.45

	-- (Tuỳ bạn) Debug print khi hover ô mới
	print(("HOVER cell=(%d,%d)"):format(cx, cz))
end)

end

return module
