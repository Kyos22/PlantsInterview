--!strict

-->> Services 
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-->> Refs
local Assets = ReplicatedStorage.Shared.Assets
local PLANTS_MODEL = Assets.Models.Plants
local VISUAL = workspace.Visual
local PLANTS = require(ReplicatedStorage.Shared.Libraries.Plants)
local TEMPLATE = {
    BillboardPlant = ReplicatedStorage.Assets.Display.Template.Plant.CooldownPlant
}

local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services

----> Constructor
export type Config = {
    Duration: number,
    Pos : {
        cx : number,
        cz : number,
    },
    Name: string,
    Model : Model,
    StartTime : number,
    SnappedWorld : Vector3,
}
local function prototype(self, config: Config)
    ---->> Public

    ---->> Private
    type field = {
        tasks: { {Name: string, Thread: thread} },
        connections: { {Name: string, Connection: RBXScriptConnection} },
    }
    local _private = {
        tasks = {},
        connections = {},
    } :: field
    self._private = _private

    return self
end

---->> Public Properties
module.constructors.metatable = module.metatable
module.constructors.methods = module.methods
module.constructors.private = {}

function module.methods.StartCountdown(self: Type, duration: number, displayLabel: TextLabel)
    task.spawn(function()
        local startTick = os.time()
        
        while true do
            local elapsed = os.time() - startTick
            local remaining = duration - elapsed
            
            if remaining <= 0 then
                displayLabel.Text = "0.0"
                -- Gọi hàm xử lý khi cây chín ở đây (ví dụ: self:OnMatured())
                break
            end
            
            displayLabel.Text = string.format("%.1f", remaining)
            
            -- Đợi một khoảng thời gian ngắn hơn bước nhảy (0.1s) 
            -- để đảm bảo UI cập nhật mượt mà
            task.wait(0.05) 
        end
    end)
end

function module.constructors.new(config: Config)
    local self = setmetatable(prototype({} :: any, config), module.metatable)

    self.Duration = config.Duration
    self.Pos = {
        cx = config.Pos.cx,
        cz = config.Pos.cz,
    }
    self.Name = config.Name
    self.Model = config.Model
    self.StartTime = config.StartTime
    self.SnappedWorld = config.SnappedWorld

    return self :: Type
end

---->> Private Functions

---->> APIs
function module.methods.Initialize(self: Type)
    self:Growth(self.Pos.cx, self.Pos.cz, self.Name, self.StartTime, self.SnappedWorld)
end

function module.methods.Destroy(self: Type)
    local _p = self._private
    for _, data in ipairs(_p.tasks) do
        local task_ = data.Thread
        if coroutine.status(task_) == "suspended" then
            task.cancel(task_)
        else
            task.defer(function()
                task.cancel(task_)
            end)
        end
    end
    for _, data in ipairs(_p.connections) do
        local conn = data.Connection
        conn:Disconnect()
    end

    do --other destroy logic
    end

    table.clear(self :: any)
end
function module.methods.Growth(self: Type, cx:number,cz:number, plant:string, startTime: number, pos)
    local stages = PLANTS_MODEL[plant]:GetChildren()
    table.sort(stages, function(a,b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    local root = Instance.new("Part")
    root.Name = "TreeRoot_" .. cx .. "_" .. cz
    root.Size = Vector3.new(1, 1, 1)
    root.Transparency = 1
    root.Anchored = true
    root.CanCollide = false
    root.CFrame = CFrame.new(pos)
    root.Parent = VISUAL

    local template = TEMPLATE.BillboardPlant:Clone()
    template.Name = plant
    template.Parent = root
    local timeLabel = template.Time :: TextLabel
    self:StartCountdown(self.Duration, timeLabel)

    task.spawn(function()
        local currentModel: Model? = nil

        while true do
            local elapsed = os.time() - startTime
            -- Giả sử mỗi Stage cách nhau 3 giây
            local currentStageIndex = math.floor(elapsed / 3) + 1
            currentStageIndex = math.min(currentStageIndex, #stages)

            -- Cập nhật Model nếu chuyển sang Stage mới
            if not currentModel or currentModel:GetAttribute("Stage") ~= currentStageIndex then
                if currentModel then currentModel:Destroy() end
                
                currentModel = stages[currentStageIndex]:Clone()
                if not currentModel then
                    return
                end
                currentModel:SetAttribute("Stage", currentStageIndex)
                currentModel:PivotTo(CFrame.new(pos))
                currentModel.Parent = VISUAL -- Hoặc folder riêng
            end

            -- Nếu đã đạt Stage cuối thì thoát vòng lặp
            if currentStageIndex >= #stages then break end
            
            task.wait(5) -- Kiểm tra lại sau mỗi 5s
        end
    end)
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
