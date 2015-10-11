--local modulename = ...
--print("moudlename->" .. modulename)
local modulename = "RegistedObj"
local M = {}
_G[modulename] = M



local oc_bridage_name = "callOCFunbyName"



function M.performanceSelector(functionName, ...)

    assert(type(functionName) == "string", "the function name must be a string")


    arg = {...}


    local callingDict = {}
    callingDict.function_name = functionName


    local param_list = {}
    for i=1, #(arg) do
        assert(type(arg[i] ~= "nil", "can not support a nil param, If you really need a nil param, please tell me"))
        param_list["_param_"..i] = arg[i]
    end


    callingDict.param_list = param_list


    return _G[oc_bridage_name](callingDict)
end



return M
