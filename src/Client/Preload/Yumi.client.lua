--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Preloader = require(script.Parent.Preloader)

ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Getting assets
local preloader = Preloader.new()

-- Preload the content and time it
local startTime = os.clock()

preloader:Load():Then(function()
	warn("⭕| Preloader loaded!")
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local deltaTime = os.clock() - startTime
	warn("Game loaded took", deltaTime, "seconds to load", #preloader.Items, "assets.")

	local Yumi = require(ReplicatedStorage.Shared.Core.Yumi)
	Yumi:Add("Systems", ReplicatedStorage.Controllers.Systems)

	Yumi:Start()
		:Then(function()
			preloader.LoadedProgress = 1
			warn("⭕| Yumi Client loaded!")
		end)
		:Catch(warn)
		:Await()
end)
