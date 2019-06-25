local BlendFactor = {}

--[[BlendingFactorDest--]]
BlendFactor.NONE = -1 --不使用混合模式
BlendFactor.ZERO = gl.ZERO
BlendFactor.ONE = gl.ONE
BlendFactor.SRC_COLOR = gl.SRC_COLOR
BlendFactor.ONE_MINUS_SRC_COLOR = gl.ONE_MINUS_SRC_COLOR
BlendFactor.SRC_ALPHA = gl.SRC_ALPHA
BlendFactor.ONE_MINUS_SRC_ALPHA = gl.ONE_MINUS_SRC_ALPHA
BlendFactor.DST_ALPHA = gl.DST_ALPHA
BlendFactor.ONE_MINUS_DST_ALPHA = gl.ONE_MINUS_DST_ALPHA
BlendFactor.CONSTANT_COLOR = gl.CONSTANT_COLOR
BlendFactor.ONE_MINUS_CONSTANT_COLOR = gl.ONE_MINUS_CONSTANT_COLOR
BlendFactor.CONSTANT_ALPHA = gl.CONSTANT_ALPHA
BlendFactor.ONE_MINUS_CONSTANT_ALPHA = gl.ONE_MINUS_CONSTANT_ALPHA

--[[BlendingFactorSrc--]]
--BlendFactor.NONE = -1 --不使用混合模式
--BlendFactor.ZERO = gl.ZERO
--BlendFactor.ONE = gl.ONE
BlendFactor.DST_COLOR = gl.DST_COLOR
BlendFactor.ONE_MINUS_DST_COLOR = gl.ONE_MINUS_DST_COLOR
BlendFactor.SRC_ALPHA_SATURATE = gl.SRC_ALPHA_SATURATE
--BlendFactor.SRC_ALPHA = gl.SRC_ALPHA
--BlendFactor.ONE_MINUS_SRC_ALPHA = gl.ONE_MINUS_SRC_ALPHA
--BlendFactor.DST_ALPHA = gl.DST_ALPHA
--BlendFactor.ONE_MINUS_DST_ALPHA = gl.ONE_MINUS_DST_ALPHA
--BlendFactor.CONSTANT_COLOR = gl.CONSTANT_COLOR
--BlendFactor.ONE_MINUS_CONSTANT_COLOR = gl.ONE_MINUS_CONSTANT_COLOR
--BlendFactor.CONSTANT_ALPHA = gl.CONSTANT_ALPHA
--BlendFactor.ONE_MINUS_CONSTANT_ALPHA = gl.ONE_MINUS_CONSTANT_ALPHA



--以下方法仅用于编辑器，因此不考虑性能因素，只考虑最大化降低对游戏的影响
local function getValueDict()
    local dict = {}
    for key, v in pairs(BlendFactor) do
        if type(v) == "number" then
            dict[v] = key
        end
    end
    
    return dict
end

function BlendFactor.getDestKeys()
    local dict = getValueDict()
    local keys = {}
    
    table.insert(keys,dict[BlendFactor.NONE])
    table.insert(keys,dict[BlendFactor.ZERO])
    table.insert(keys,dict[BlendFactor.ONE])
    table.insert(keys,dict[BlendFactor.SRC_COLOR])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_SRC_COLOR])
    table.insert(keys,dict[BlendFactor.SRC_ALPHA])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_SRC_ALPHA])
    table.insert(keys,dict[BlendFactor.DST_ALPHA])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_DST_ALPHA])
    table.insert(keys,dict[BlendFactor.CONSTANT_COLOR])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_CONSTANT_COLOR])
    table.insert(keys,dict[BlendFactor.CONSTANT_ALPHA])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_CONSTANT_ALPHA])
    
    return keys
end
function BlendFactor.getSrcKeys()
    local dict = getValueDict()
    local keys = {}

    table.insert(keys,dict[BlendFactor.NONE])
    table.insert(keys,dict[BlendFactor.ZERO])
    table.insert(keys,dict[BlendFactor.ONE])
    table.insert(keys,dict[BlendFactor.DST_COLOR])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_DST_COLOR])
    table.insert(keys,dict[BlendFactor.SRC_ALPHA_SATURATE])
    table.insert(keys,dict[BlendFactor.SRC_ALPHA])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_SRC_ALPHA])
    table.insert(keys,dict[BlendFactor.DST_ALPHA])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_DST_ALPHA])
    table.insert(keys,dict[BlendFactor.CONSTANT_COLOR])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_CONSTANT_COLOR])
    table.insert(keys,dict[BlendFactor.CONSTANT_ALPHA])
    table.insert(keys,dict[BlendFactor.ONE_MINUS_CONSTANT_ALPHA])

    return keys
end
function BlendFactor.getKeyByValue(value)
    if value then
        local dict = getValueDict()
        local key = dict[value]
        if key then
            return key
        end
    end
    return "NONE"
end
return BlendFactor