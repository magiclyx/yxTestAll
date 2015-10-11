

print("load A")


function test(val)
    print("aaa")
   -- print(type(luaEngine_runtime))
   --print(type(luaEngine_runtime.performSelector))
   -- print(type(performSelector))

    --returnVal = performSelector("luaLib_test:", 123)
    local returnVal = luaEngine_runtime.performSelector("luaLib_test:", 123)

    print("back to test function")
    print(returnVal)
    print(type(returnVal))

    -- return nil
end




