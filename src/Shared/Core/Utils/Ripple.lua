--[[

Sequence: Creates tween sequences
Supports both looped and non-looped versions.

>> CREDITS <<
Creator: SectorJack

]]

--// Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Libraries
local Signal = require(ReplicatedStorage.Packages.Signal)
local Sweeper = require(ReplicatedStorage.Shared.Core.Utils.Sweeper)

--// Variables
local heartbeatSignal = Signal.Wrap(RunService.Heartbeat)

--// Types & Enums
export type Ripple = {
	Step: number,
	Tweens: {any},
	isPlaying: boolean,
	isPaused: boolean,
	Looped: boolean,

	Started: any,
	Stopped: any,
	Paused: any,
	Destroyed: any,

	new: (tweens: {any}, looped: boolean) -> Ripple,
	_Play: (self: Ripple, step: number, version: number) -> (),
	_PlayNext: (self: Ripple, version: number) -> (),
	_PlayCurrent: (self: Ripple, version: number) -> (),

	Play: (self: Ripple) -> (),
	Stop: (self: Ripple) -> (),
	Pause: (self: Ripple) -> (),
	Reset: (self: Ripple) -> (),
	Destroy: (self: Ripple) -> (),
}

--// System
local Ripple = {}
Ripple.__index = Ripple

function Ripple.new(tweens, looped: boolean)
	return setmetatable({
		Step = 0,
		Tweens = tweens,
		isPlaying = false,
		isPaused = false,
		Looped = looped or false,

		Started = Signal.new(),
		Stopped = Signal.new(),
		Paused = Signal.new(),
		Destroyed = Signal.new(),

		_version = 0,
		_currentSweeper = nil,
	}, Ripple)
end

function Ripple:_Play(step, version)
	if version ~= self._version then return end

	if self._currentSweeper then
		self._currentSweeper:Sweep()
	end

	local sweeper = Sweeper.new()
	self._currentSweeper = sweeper
	local tween = self.Tweens[step]

	if typeof(tween) == "number" then
		local timeElapsed = 0
		local heartbeatConnection = heartbeatSignal:Connect(function(deltaTime)
			if version ~= self._version then
				sweeper:Sweep()
				return
			end
			if not self.isPaused then
				timeElapsed += deltaTime
			end
			if timeElapsed >= tween then
				sweeper:Sweep()
				self:_PlayNext(version)
			end
		end)
		sweeper:Add(heartbeatConnection)

	elseif typeof(tween) == "function" then
		if version ~= self._version then return end
		tween()
		self:_PlayNext(version)

	else
		local tweenSignal = Signal.Wrap(tween.Completed)
		local tweenConnection = tweenSignal:Connect(function()
			if version ~= self._version then return end
			sweeper:Sweep()
			self:_PlayNext(version)
		end)

		local stoppedConnection = self.Stopped:Connect(function()
			sweeper:Sweep()
			tween:Cancel()
		end)

		local pausedConnection = self.Paused:Connect(function()
			tween:Pause()
		end)

		sweeper:Add(tweenConnection)
		sweeper:Add(stoppedConnection)
		sweeper:Add(pausedConnection)

		tween:Play()
	end
end

function Ripple:_PlayNext(version)
	if version ~= self._version then return end
	if (self.Step + 1) > #self.Tweens then
		if self.Looped then
			self.Step = 1
		else
			self:Stop()
			return
		end
	else
		self.Step += 1
	end
	self:_Play(self.Step, version)
end

function Ripple:_PlayCurrent(version)
	self:_Play(self.Step, version)
end

function Ripple:Play()
	-- Always restart
	self:Stop()
	self.Step = 1
	self.isPlaying = true
	self.isPaused = false
	self._version += 1
	self.Started:Fire()
	self:_Play(self.Step, self._version)
end

function Ripple:Stop()
	if self._currentSweeper then
		self._currentSweeper:Sweep()
		self._currentSweeper = nil
	end
	self.isPlaying = false
	self.isPaused = false
	self.Step = 0
	self.Stopped:Fire()
end

function Ripple:Pause()
	self.isPlaying = false
	self.isPaused = true
	self.Paused:Fire()
end

function Ripple:Reset()
	if typeof(self.Tweens[1]) == "function" then
		self.Tweens[1]()
	end
end

function Ripple:Destroy()
	self:Stop()
	self.Destroyed:Fire()
	setmetatable(self, nil)
	table.clear(self)
end

return Ripple
