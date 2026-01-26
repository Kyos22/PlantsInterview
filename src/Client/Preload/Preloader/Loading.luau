--!strict
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }
--// Services
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

----> Modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utils = require(Shared.Core.Utils)
local CONSTANT = require(Shared.CONSTANT)
local Ripple = require(Shared.Core.Utils.Ripple)

----> Constructor
local loadingRefs = ReplicatedFirst.Loading
local Camera = workspace.CurrentCamera

----> Constants
local TIP_MESSAGES = CONSTANT.TIP_MESSAGES

export type Config = {
	Part1: BasePart,
}

local function cloneSingleton(uiTemplate: Instance): Instance
	local newUI = uiTemplate:Clone()
	newUI.Parent = Players.LocalPlayer.PlayerGui
	return newUI
end

local function prototype(self)
	---->> Public

	self.UI = cloneSingleton(loadingRefs) :: typeof(loadingRefs)
	local canvas = self.UI.Background
	local titles = canvas.Titles
	local title = titles.Tile
	local title2 = titles.Tile2
	local mainTitle = self.UI.MainTitle
	local starter_pellets = self.UI.Pellets
	local end_pellets = self.UI.LoadProgress.End_Pellets
	local progress = self.UI.LoadProgress
	local frameDim = self.UI.FrameDim
	local tipFront = canvas.Tips.Front
	local tipBack = canvas.Tips.Back
	local _ripples = {
		TitleMovement = Ripple.new({
			TweenService:Create(title, TweenInfo.new(0), { Position = UDim2.fromScale(1, 1) }),
			TweenService:Create(
				title,
				TweenInfo.new(20, Enum.EasingStyle.Linear),
				{ Position = UDim2.fromScale(0, 0) }
			),
		}, true),
		TitleMovement2 = Ripple.new({
			TweenService:Create(title2, TweenInfo.new(0), { Position = UDim2.fromScale(0, 1) }),
			TweenService:Create(
				title2,
				TweenInfo.new(50, Enum.EasingStyle.Linear),
				{ Position = UDim2.fromScale(1, 0) }
			),
		}, true),
		StarterPellet = Ripple.new({
			TweenService:Create(starter_pellets, TweenInfo.new(0), { Size = UDim2.fromScale(0, 0) }),
			TweenService:Create(
				starter_pellets,
				TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(0.5, 0.5) }
			),
		}, false),
		StarterPellet_Fade = Ripple.new({
			TweenService:Create(starter_pellets, TweenInfo.new(0), { ImageTransparency = 0 }),
			TweenService:Create(
				starter_pellets,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{ ImageTransparency = 1 }
			),
		}, false),
		LoadComplete_Effect = Ripple.new({
			TweenService:Create(end_pellets, TweenInfo.new(0), { Size = UDim2.fromScale(0, 0) }),
			TweenService:Create(
				end_pellets,
				TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(3, 3) }
			),
		}, false),
		LoadComplete_FadeEffect = Ripple.new({
			TweenService:Create(end_pellets, TweenInfo.new(0), { ImageTransparency = 0 }),
			TweenService:Create(
				end_pellets,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
				{ ImageTransparency = 1 }
			),
		}, false),
		MainTitleAppear = Ripple.new({
			TweenService:Create(mainTitle, TweenInfo.new(0), { Size = UDim2.fromScale(0, 0) }),
			TweenService:Create(
				mainTitle,
				TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(0.497, 0.497) }
			),
		}, false),
		MainTitleDisappear = Ripple.new({
			TweenService:Create(mainTitle, TweenInfo.new(0), { Size = UDim2.fromScale(0.497, 0.497) }),
			TweenService:Create(
				mainTitle,
				TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{ Size = UDim2.fromScale(0, 0) }
			),
		}, false),
		MainTitleAnim = Ripple.new({
			TweenService:Create(mainTitle, TweenInfo.new(0), { Rotation = -5 }),
			TweenService:Create(
				mainTitle,
				TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Rotation = 5 }
			),
			TweenService:Create(
				mainTitle,
				TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Rotation = -5 }
			),
		}, true),
		ProgressAppear = Ripple.new({
			TweenService:Create(progress, TweenInfo.new(0), { Size = UDim2.fromScale(0, 0) }),
			TweenService:Create(
				progress,
				TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ Size = UDim2.fromScale(0.25, 0.25) }
			),
		}, false),
		ProgressDisappear = Ripple.new({
			TweenService:Create(progress, TweenInfo.new(0), { Size = UDim2.fromScale(0.25, 0.25), Rotation = 0 }),
			TweenService:Create(
				progress,
				TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{ Size = UDim2.fromScale(0, 0), Rotation = 10 }
			),
		}, false),
		TitlesAppear = Ripple.new({
			TweenService:Create(titles, TweenInfo.new(0), { Size = UDim2.fromScale(5, 5) }),
			TweenService:Create(
				titles,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Size = UDim2.fromScale(1, 1) }
			),
		}, false),
		LoadOff = Ripple.new({
			TweenService:Create(canvas, TweenInfo.new(0), { GroupTransparency = 0 }),
			TweenService:Create(canvas, TweenInfo.new(0.75, Enum.EasingStyle.Linear), { GroupTransparency = 1 }),
		}, false),
		DimFadingOff = Ripple.new({
			TweenService:Create(frameDim, TweenInfo.new(0), { BackgroundTransparency = 0 }),
			TweenService:Create(frameDim, TweenInfo.new(0.75, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 }),
		}, false),
		CameraEffect = Ripple.new({
			TweenService:Create(Camera, TweenInfo.new(0), { FieldOfView = 40 }),
			TweenService:Create(
				Camera,
				TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ FieldOfView = 70 }
			),
		}, false),
		TipMsg_Txt = Ripple.new({
			TweenService:Create(tipFront, TweenInfo.new(0), { TextTransparency = 1 }),
			TweenService:Create(tipFront, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { TextTransparency = 0 }),
		}, false),
		TipMsg_Stroke = Ripple.new({
			TweenService:Create(tipFront.UIStroke, TweenInfo.new(0), { Transparency = 1 }),
			TweenService:Create(tipFront.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { Transparency = 0 }),
		}, false),
		TipMsg_Txt_Back = Ripple.new({
			TweenService:Create(tipBack, TweenInfo.new(0), { TextTransparency = 1 }),
			TweenService:Create(tipBack, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { TextTransparency = 0 }),
		}, false),
		TipMsg_Stroke_Back = Ripple.new({
			TweenService:Create(tipBack.UIStroke, TweenInfo.new(0), { Transparency = 1 }),
			TweenService:Create(tipBack.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { Transparency = 0 }),
		}, false),
	}

	self.Ripples = _ripples

	local progressValue = Instance.new("NumberValue")
	progressValue.Name = "ProgressValue"
	progressValue.Parent = self.UI
	self.ProgressValue = progressValue

	---->> Private
	type field = {
		tasks: { { Name: string, Thread: thread } },
		connections: { { Name: string, Connection: RBXScriptConnection } },
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
function module.constructors.new()
	local self = setmetatable(prototype({} :: any), module.metatable)

	return self :: Type
end

function module.methods.SetProgress(self: Type, value: number)
	self.ProgressValue.Value = value
end

---->> Private Functions
local RenderLabel = Utils.RenderLabel
local function getRandomTip(): string
	local tip = TIP_MESSAGES[math.random(1, #TIP_MESSAGES)]
	return tip
end

---->> APIs
function module.methods.Initialize(self: Type)
	local tip = getRandomTip()
	RenderLabel(self.UI.Background.Tips, tip)
	task.wait(1.75)
	self.Ripples.TitlesAppear:Play()
	self.Ripples.DimFadingOff:Play()
	task.wait(0.25)
	self.Ripples.MainTitleAppear:Play()
	self.Ripples.TitleMovement:Play()
	self.Ripples.TitleMovement2:Play()
	self.Ripples.MainTitleAnim:Play()
	self.Ripples.ProgressAppear:Play()
	task.spawn(function()
		task.wait(0.25)
		self.Ripples.StarterPellet:Play()
		self.Ripples.StarterPellet_Fade:Play()
		self.Ripples.TipMsg_Txt:Play()
		self.Ripples.TipMsg_Stroke:Play()
		self.Ripples.TipMsg_Txt_Back:Play()
		self.Ripples.TipMsg_Stroke_Back:Play()
	end)

	local progressFrame = self.UI.LoadProgress.Progress
	local function _setProgress(value: number)
		value = math.clamp(value, 0, 1)
		TweenService:Create(progressFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(value, 1),
			TileSize = UDim2.fromScale(0.25 / math.max(value, 0.05), 5),
		}):Play()
		if value == 1 then
			task.wait(0.1)
			self.Ripples.LoadComplete_Effect:Play()
			self.Ripples.LoadComplete_FadeEffect:Play()
		end
	end
	_setProgress(0)
	self.ProgressValue.Changed:Connect(function(value)
		_setProgress(value)
	end)
end

function module.methods.End(self: Type)
	task.spawn(function()
		task.wait(1)
		self.Ripples.LoadOff:Play()
		self.Ripples.CameraEffect:Play()
		self.Ripples.MainTitleDisappear:Play()
		self.Ripples.ProgressDisappear:Play()
		task.wait(0.75)
		self:Destroy()
	end)
end

function module.methods.Destroy(self: Type)
	self.UI:Destroy()
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
function module.methods.DoABC(self: Type)
	print("Super DoABC")
end

export type Type = typeof(prototype(...)) & typeof(module.methods)

return module.constructors
