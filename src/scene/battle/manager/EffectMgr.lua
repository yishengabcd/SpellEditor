local EffectMgr = {}

local effects = {}

function EffectMgr.addEffect(name, eff, container)
    if not effects[name] then
        effects[name] = {eff = eff, container = container}
    end
end

function EffectMgr.removeEffect(name)
    effects[name] = nil
end

function EffectMgr.removeEffectByContainer(container)
    for key, var in pairs(effects) do
    	if var.container == container then
    	   effects[key] = nil
    	end
    end
end

function EffectMgr.getEffect(name)
    local obj = effects[name]
    if obj then return obj.eff end
    return nil
end

function EffectMgr.clear()
    effects = {}
end


return EffectMgr