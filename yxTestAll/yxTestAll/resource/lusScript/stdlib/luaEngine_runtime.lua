
-- [================================[ declare ]================================]

local modulename = "luaEngine_runtime"
local M = {}
_G[modulename] = M

-- [================================[ function ]================================]

-- get/set instance

local runtime_instance = 0

function setInstance(instance)

    assert(type(instance) == "number", "invalidate function address")

    runtime_instance = instance

end


function insttance()
    return runtime_instance
end

-- property

local property = {} 

function getProperty(key)
    return property[key]
end

function setProperty(key, val)
    property[key] = val
end


-- perform selector

local oc_bridage_name = "callOCFunbyName"

local function performSelector(functionName, ...)

    print("in performSelector")

    assert(type(functionName) == "string", "invalidate funcation name")

    arg = {...}


    local callingDict = {}
    callingDict.function_name = functionName
    callingDict.engine_address = runtime_instance


    local param_list = {}
    for i=1, #(arg) do

        assert(type(arg[i] ~= "nil", "TODO: do not support nil type"))

        param_list["_param_"..i] = arg[i]
    end


    callingDict.param_list = param_list


    return _G[oc_bridage_name](callingDict)
    
end

M.getProperty = getProperty
M.setProperty = setProperty
M.performSelector = performSelector
