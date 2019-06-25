
local SpellTemplateExtend = require("src/scene/battle/mode/SpellTemplateExtend")

local SpellModel = {}
local _inited

--加载技能配置信息
function SpellModel.load()
    if _inited then return end
    _inited = true
    local spellDatas = require("data/EditorSpellsData")
    --扩展所有技能数据表的功能
    for i, v in ipairs(spellDatas) do
        SpellTemplateExtend.extend(v)
    end
    
    SpellModel._spellDatas = spellDatas
end

function SpellModel.getSpellDatas()
    return SpellModel._spellDatas
end

--获得指定id的技能配置数据
function SpellModel.getSpellDataById(id)
    for i, v in ipairs(SpellModel._spellDatas) do
    	if v.id == id then
    	   return v
    	end
    end
    return nil
end

return SpellModel