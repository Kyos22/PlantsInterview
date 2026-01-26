local DEBUGGING = false


local function AssignTeam(_currentMap: string, nations: { string })
	-- asign nations to map workspace
	local worlds = workspace:WaitForChild("Worlds"):WaitForChild(_currentMap)
	local SpawnTeam = worlds:FindFirstChild("Spawn") :: Folder
	if DEBUGGING then
		warn("SPAWN TEAM FOUND", SpawnTeam)
	end
	for i, nation in pairs(SpawnTeam:GetChildren()) do
		if DEBUGGING then
			warn("NATION FOUND", nation.Name)
		end
		if nation:IsA("Folder") then
			nation.Name = nations[i]
		end
	end
end

return {
    AssignTeam = AssignTeam,
}
