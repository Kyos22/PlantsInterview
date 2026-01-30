--!strict

-->> Services 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Server = require(ReplicatedStorage.Shared.Network.Server)
local ServerScriptService = game:GetService("ServerScriptService")
-->> Modules
local Data = require(ServerScriptService.Systems.Profile)
local PlantModifier = require(ServerScriptService.Systems.Profile.DataModifier.Plant)
-->> Refs
local Assets = ReplicatedStorage.Shared.Assets
local PLANTS_MODEL = Assets.Models.Plants
local VISUAL = workspace.Visual
local TEMPLATE = {
    BillboardPlant = ReplicatedStorage.Assets.Display.Template.Plant.CooldownPlant,
    Harvest = ReplicatedStorage.Assets.Display.Template.Plant.Harvest
}

local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services

----> Constructor
export type Config = {
    Player: Player,
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
-->> Private functon
local function CreateRoot(cx:number, cz:number, pos):Part
    local root = Instance.new("Part")
    root.Name = "TreeRoot_" .. cx .. "_" .. cz
    root.Size = Vector3.new(1, 1, 1)
    root.Transparency = 1
    root.Anchored = true
    root.CanCollide = false
    root.CFrame = CFrame.new(pos)
    root.Parent = VISUAL

    return root
end

-- Public function
function module.methods.StartCountdown(self: Type, duration: number,startTime:number, displayLabel: TextLabel)
    task.spawn(function()
        while true do
            local elapsed = os.time() - startTime
            local remaining = duration - elapsed
            if remaining <= 0 then
                displayLabel.Text = "0.0"
                break
            end
            
            displayLabel.Text = string.format("%.1f", remaining)
            
            task.wait(0.05) 
        end
    end)
end

function module.constructors.new(config: Config)
    local self = setmetatable(prototype({} :: any, config), module.metatable)

    self.Player = config.Player
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

    local root = CreateRoot(cx, cz, pos)

    local template = TEMPLATE.BillboardPlant:Clone()
    template.Name = plant
    template.Parent = root
    local timeLabel = template.Time :: TextLabel
    self:StartCountdown(self.Duration,startTime, timeLabel)

    task.spawn(function()
        local currentModel: Model? = nil
        local totalStages = #stages
        local growthStagesCount = totalStages - 1 
        local stageInterval = self.Duration / growthStagesCount
       
        while true do
            local now = os.time()
            local elapsed = now - startTime
            local currentStageIndex = 1

            if elapsed >= self.Duration then
                currentStageIndex = totalStages
            else
                local calculated = math.floor(elapsed / stageInterval) + 1
                currentStageIndex = math.clamp(calculated, 1, growthStagesCount)
            end

            if not currentModel or currentModel:GetAttribute("Stage") ~= currentStageIndex then
                if currentModel then currentModel:Destroy() end
                
                currentModel = stages[currentStageIndex]:Clone()
                if currentModel then
                    currentModel:SetAttribute("Stage", currentStageIndex)
                    currentModel:PivotTo(CFrame.new(pos))
                    currentModel.Parent = root 
                end
            end

            if currentStageIndex == totalStages then break end
            task.wait(1)
        end

        -- Handle Trigger
        local proximityPrompt = TEMPLATE.Harvest:Clone() :: ProximityPrompt
        proximityPrompt.Parent = currentModel
        proximityPrompt.Triggered:Connect(function()
            if currentModel then
                currentModel:Destroy()
            end
            local data = Data.GetAsync(self.Player, true, true)
            if data then
               PlantModifier.Add(data, 1, plant)
            end
            Server.Garden.Harvest.Fire(self.Player, plant, 1)
        end)

    end)
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
