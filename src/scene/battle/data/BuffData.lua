
local EventProtocol = require("src/utils/EventProtocol")

local BuffData = class("BuffData")
BuffData.buffId = 1
BuffData.index = nil 
BuffData.level = 1
BuffData.count = 1

BuffData.PROCESS_TYPE_ADD = 1
BuffData.PROCESS_TYPE_REMOVE = 2
BuffData.PROCESS_TYPE_INVOKE = 3 --生效
--过程数据
BuffData.processType = 1 --处理类型
BuffData.position = 1 --角色站位
BuffData.team = 1 --队伍
BuffData.hp = nil 
BuffData.realHp = nil

BuffData.EVENT_COUNT_CHANGED = "eventCountChanged"

function BuffData:ctor()
    self.count = 1
    EventProtocol.extend(self)
end

function BuffData:setCount(value)
    if self.count ~= value then
        self.count = value
        self:dispatchEvent({name=BuffData.EVENT_COUNT_CHANGED})
    end
end

--播放一次的资源路径
function BuffData:getHiddenRes()
    local template = self:getTemplate()
    if template then
        if template.res_hidden ~= "" then
            return template.res_hidden
        end
    end
    return ""
end

--持续播放的资源路径
function BuffData:getContinuousRes()
    local template = self:getTemplate()
    if template then
        if template.res_continuous ~= "" then
            return template.res_continuous
        end
    end
    return ""
end

function BuffData:getTemplate()
    return require("src/entities/templatemanager"):getBuff(self.buffId)
end

function BuffData:getBuffEffectTemplate()
    local template = self:getTemplate()
    if template then
        return require("src/entities/templatemanager"):getBuffEffect(template.buff_id)
    end
    return nil
end

return BuffData