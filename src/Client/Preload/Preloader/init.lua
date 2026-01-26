--!strict
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Promise = require(Packages.Promise)
local Signal = require(Packages.Signal)
local Loading = require(script.Loading)

export type Preloader = {
	__index: Preloader,
	new: () -> Preloader,
	Load: (self: Preloader) -> Promise.Promise,
	Destroy: (self: Preloader) -> (),
	LoadingGui: Loading.Type,
	LoadedProgress: number,

	Items: { Instance },
	Loaded: Signal.Signal<Instance>,
}
local Class: Preloader = {} :: Preloader
Class.__index = Class

function Class.new(): Preloader
	local self: Preloader = setmetatable({} :: any, Class)
	self.Loaded = Signal.new()
	self.LoadingGui = Loading.new()
	self.LoadedProgress = 0

	ReplicatedFirst:RemoveDefaultLoadingScreen()
	return self
end

function Class:Load()
	local promise = Promise.new(function(resolve: (...any) -> (), reject: (...any) -> ())
		local assets = ReplicatedFirst:FindFirstChild("GUI")
		self.Items = assets and assets:GetChildren() or {}

		self.LoadingGui:Initialize()
		self.LoadingGui:SetProgress(0)

		local itemsToLoad = {}
		local loaded = 0
		if assets then
			itemsToLoad = assets:GetChildren()
		end
		local loadCount = #itemsToLoad

		local startTime = os.clock()
		for _, item in pairs(itemsToLoad) do
			if item:IsA("GuiObject") then
				ContentProvider:PreloadAsync(itemsToLoad)
			end
			loaded += 1
			local progress = (loaded/math.max(1, loadCount)) * 0.5
			self.LoadingGui:SetProgress(progress)
			task.wait()
		end

		local itemToLoad = #self.Items
		local itemLoaded = 0

		for _, item in pairs(self.Items) do
			if item:IsA("GuiObject") then
				ContentProvider:PreloadAsync({ item })
			end
			self.Loaded:Fire(item)
			itemLoaded += 1
			local progress: number = 0.5 + itemLoaded/math.max(1, itemToLoad) * 0.2
			self.LoadingGui:SetProgress(progress)
			task.wait()
		end
		
		
		-- local playerGui = Player:WaitForChild("PlayerGui")
		-- for _, item in pairs(self.Items) do
		-- 	item.Parent = StarterGui
		-- 	local new = item:Clone()

		-- 	new.Parent = playerGui
		-- end
		local deltaTime = os.clock() - startTime
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
		for _, item in pairs(itemsToLoad) do
			item.Parent = StarterGui
			local new = item:Clone()
			new.Parent = PlayerGui
		end
		
		resolve()
		
		warn("Preloading took", deltaTime, "seconds to load", #self.Items, "assets.")
		task.spawn(function()
			while self.LoadedProgress < 1 do
				task.wait()
				self.LoadingGui:SetProgress(0.25 + self.LoadedProgress * 0.75)
			end
			
			self.LoadingGui:SetProgress(1)
			task.wait(0.5)
			self.LoadingGui:End()
		end)		
	end)

	return promise
end

function Class:Destroy()
	self.Items = {}
	self.Loaded:DisconnectAll()
end

return Class
