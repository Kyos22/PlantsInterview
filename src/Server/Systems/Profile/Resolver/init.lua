return {
	Resolve = function(data: { [any]: any }, currentVersion: number)
		while data.Version < currentVersion do --upgrade data with resolvers
			local resolver = require(script:FindFirstChild(tostring(data.Version + 1)))
			if resolver then
				local oldVersion = data.Version
				local success, message = pcall(function()
					resolver.Resolve(data)
				end)
				local newVersion = data.Version
				if not success then
					task.spawn(function()
						error(`Fail to resolve data version {data.version} with error message: {message}`)
					end)
				else
					print(`Data resolved successfully: {oldVersion}->{newVersion}`)
				end
			else
				warn(`Resolver version {data.Version} not found!`)
				break
			end
		end
	end,
}
