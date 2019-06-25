
local DramaTemplateExtend = require("src/scene/battle/mode/DramaTemplateExtend")

local DramaModel = {}
local _inited

local dialogues

--加载技能配置信息
function DramaModel.load()
    if _inited then return end
    _inited = true
    local dramaDatas = require("data/EditorDramasData")
    dialogues = require("data/dramas")
    --扩展所有技能数据表的功能
    for i, v in ipairs(dramaDatas) do
        DramaTemplateExtend.extend(v)
    end

    DramaModel._dramaDatas = dramaDatas
end

function DramaModel.getDramaDatas()
    return DramaModel._dramaDatas
end

function DramaModel.getDramaDataById(id)
    for i, v in ipairs(DramaModel._dramaDatas) do
        if v.id == id then
            return v
        end
    end
    return nil
end
--获得指定ID的对白内容
function DramaModel.getDialogue(id)
    if dialogues then
        return dialogues[id]
    end
    return nil
end

return DramaModel