--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Modules
local Signal = require(ReplicatedStorage.Packages.Signal)

export type WaitParam = (number | () -> number)
local function ProtectedBehavior(wait: WaitParam?, behavior: (delta: number) -> ())
    wait = wait or 0

    local waitFunction: () -> number = function()
        return 1
    end
    if typeof(wait) == "number" then
        waitFunction = function()
            return wait
        end
    elseif typeof(wait) == "function" then
        waitFunction = wait
    end

    while true do
        local delta = task.wait(waitFunction())
        local success,result = pcall(function()  
            behavior(delta)
        end)
        if not success then
            task.spawn(function()
                error(result)
            end)
        end
    end
end

export type ResultFunction = (success: boolean, result: any) -> ()
local function ProtectedSignal<T...>(signal: Signal.Signal<T...>, func: (T...) -> any, resultFunc: ResultFunction?): Signal.Connection
    local conn = signal:Connect(function(...) 
        local args = {...} -- capture all args
        local success,result = pcall(function() 
            return func(table.unpack(args))
        end)
        if resultFunc then
            resultFunc(success,result)
        end
    end)
    return conn
end

return {
    ProtectedBehavior = ProtectedBehavior,
    ProtectedSignal = ProtectedSignal
}