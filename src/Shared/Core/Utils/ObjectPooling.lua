
local module = {}
module.constructors = {}
module.methods = {}
module.metatable = { __index = module.methods }

--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--modules

--events

--constant

--type

--variable
local PoolingFolder = Instance.new("Folder")
PoolingFolder.Name = "ObjectPooling"
PoolingFolder.Parent = ReplicatedStorage.Runtime

function module.constructors.new(template: Instance, size: number?)
	local self = setmetatable({}, module.metatable)
	
	-- public properties
	self.size = size
	self.template = template
	
	self.pool = {} :: {Instance}
	
	-- private field
	type field = {
		tasks: {[string]: thread},
		connections: {[string]: RBXScriptConnection}
	}
	local _private: field = {
		tasks = {},
		connections = {}
	}
	self._private = _private
	
	self:Initialize()
	
	return self
end
--private function
local function PoolBehavior(self: Type)
	if not self.size then
		return
	end
	local poolCheckingInterval = 0.25
	while true do
		task.wait(poolCheckingInterval)
		if #self.pool > self.size  then
			local ins = table.remove(self.pool)
			ins:Destroy()
		end
	end
end
--properties

--class function
function module.methods.Initialize(self: Type)
	local _p = self._private
	local size = self.size
	local template = self.template
	if not template.IsA or not template:IsA("Instance") then
		task.spawn(function()
			error(tostring(template).." is not an Instance!")
		end)
		return
	end
	if size then
		for i=1,size,1 do
			local obj = template:Clone()
			obj.Parent = PoolingFolder 
			table.insert(self.pool, obj)
		end
	end
	_p.tasks["PoolBehavior"] = task.spawn(function()
		PoolBehavior(self)
	end)
end
function module.methods.Get(self:Type)
	if #self.pool > 0 then
		return table.remove(self.pool)
	else
		return self.template:Clone()
	end
end
function module.methods.Return(self:Type, obj: Instance)
	if obj.Parent == PoolingFolder then
		return
	end
	obj.Parent = PoolingFolder
	table.insert(self.pool, obj)
end
function module.methods.Clear(self:Type)
	for _,item in ipairs(self.pool) do
		item:Destroy()
	end 
	table.clear(self.pool)
end


function module.methods.Destroy(self: Type)
	local _p = self._private
	for _,task_ in pairs(_p.tasks) do
		if coroutine.status(task_) == "suspended" then
			task.cancel(task_)
		else
			task.defer(function()
				task.cancel(task_)
			end)
		end
	end
	for _,conn in pairs(_p.connections) do
		conn:Disconnect()
	end
	self:Clear()
	table.clear(self)
end
export type Type = typeof(module.constructors.new(table.unpack(...)))

return module.constructors