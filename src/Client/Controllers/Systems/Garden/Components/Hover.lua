local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hover = {}
local GridUtil = require(ReplicatedStorage.Shared.GridUtil)
local lastCX, lastCZ = nil, nil
local THICKNESS = 0.15
local Y_OFFSET = 0.05

local function Hide(self)
	if self.hoverPart.Transparency ~= 1 then
		self.hoverPart.Transparency = 1
	end
	lastCX, lastCZ = nil, nil
end

local function GetCellCFrame(soilPart: BasePart, cellSize: number, cellX: number, cellZ: number)
	local halfX = soilPart.Size.X * 0.5
	local halfZ = soilPart.Size.Z * 0.5

	local localX = (-halfX) + (cellX + 0.5) * cellSize
	local localZ = (-halfZ) + (cellZ + 0.5) * cellSize

	local localY = (soilPart.Size.Y * 0.5) + (THICKNESS * 0.5) + Y_OFFSET

	return soilPart.CFrame * CFrame.new(localX, localY, localZ)
end


Hover.Initialize = function(self, rayParams)
    local hoverPart = Instance.new("Part")
    hoverPart.Name = "HoverCell"
    hoverPart.Anchored = true
    hoverPart.CanCollide = false
    hoverPart.CanQuery = false
    hoverPart.CanTouch = false
    hoverPart.Transparency = 1 
    hoverPart.Material = Enum.Material.Neon
    hoverPart.Parent = workspace
    self.hoverPart = hoverPart

    hoverPart.Color = Color3.fromRGB(80, 255, 120)

    -- Hover.Input(self, hoverPart)
    RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then
            Hide(self)
            return
        end

        local mousePos = UserInputService:GetMouseLocation()
        local inset = GuiService:GetGuiInset()
        local screenPos = Vector2.new(mousePos.X, mousePos.Y - inset.Y)

        local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)

        if not result then
            Hide(self)
            return
        end

        local hitPos = result.Position
        local cx, cz = GridUtil.WorldToCell(self.Land.Soil1, self.cellSize, hitPos)

        if not GridUtil.IsCellInside(self.Land.Soil1, self.cellSize, cx, cz) then
            Hide(self)
            return
        end

        if cx == lastCX and cz == lastCZ then
            return
        end
        lastCX, lastCZ = cx, cz

        hoverPart.Size = Vector3.new(self.cellSize, THICKNESS, self.cellSize)
        hoverPart.CFrame = GetCellCFrame(self.Land.Soil1, self.cellSize, cx, cz)
        hoverPart.Transparency = 0.45

        print(("HOVER cell=(%d,%d)"):format(cx, cz))
    end)
end


return Hover