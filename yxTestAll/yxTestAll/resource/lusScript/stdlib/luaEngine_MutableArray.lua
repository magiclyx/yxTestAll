--local modulename = ...
--print("moudlename->" .. modulename)
local modulename = "array"
local M = {}
_G[modulename] = M




 M.mt = {}


function M.new(t)

    if t == nil then
	    return nil
	end

    local mutableArray = {}
	setmetatable(mutableArray,  M.mt)

    for i=1, #(t) do
	    table.insert(mutableArray, t[i])
	end

    mutableArray["_lua_oc_bridage_array_datatype_"] = true

	return mutableArray
end

function  M.add(a, b)

    local c = M.new{}

	if a ~= nil then
        for i=1, #(a) do
	        table.insert(c, a[i])
	    end
	end

	if b ~= nil then
	    for i=1, #(b) do
	        table.insert(c, b[i])
	    end
	end

	return c
end

 M.mt.__add = M.add


function  M.tostring(array)

    if array == nil then
	    return "nil"
	end

    local str ="[\n"
	local sep = ""
	for i=1, #(array) do
	    str = str .. sep .. tostring(i) .. " = " ..array[i]
		sep = ",\n"
	end

	return str .. "\n]"
end


function  M.debug(s)
    print( M.tostring(s))
end



return M



