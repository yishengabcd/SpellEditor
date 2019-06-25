

local SpellMgr = require("src/scene/battle/manager/SpellMgr")
local Spell = require("src/scene/battle/mode/Spell")

--连携技使用时效管理
local SpellJoinableMgr = {}
local _executorIndex --使用主动技的英雄的索引
local _startCountFlag
local _timeoutHandler --可使用连携技时间结束
local _joinCount = 0
local _executed --已经播放的技能计数

--启动计时
function SpellJoinableMgr.start(executorIndex, timeoutHandler)
    _executorIndex = executorIndex
    _timeoutHandler = timeoutHandler

    _joinCount = 0
    _executed = 0
    
    SpellJoinableMgr.stop()
    SpellMgr:addEventListener(Spell.EVENT_HALF, SpellJoinableMgr.onSpellHalf)
end


--技能执行到一半时的处理方法
function SpellJoinableMgr.onSpellHalf(event)
    local spell = event.spell
    if (spell:getSpellData().fromPosition == _executorIndex 
        and spell:getSpellData().isActive
        and not spell:getSpellData().isJoin) then
        _executed = _executed + 1
        if _executed > _joinCount then
            SpellJoinableMgr.stop()
            if _timeoutHandler then 
                _timeoutHandler()
                _timeoutHandler = nil
            end
        end
    end
end

--主动结束计时
function SpellJoinableMgr.stop()
    SpellMgr:removeEventListener(Spell.EVENT_HALF, SpellJoinableMgr.onSpellHalf)
end

function SpellJoinableMgr.setTimeout()
    SpellJoinableMgr.stop()
    if _timeoutHandler then 
        _timeoutHandler()
        _timeoutHandler = nil
    end
end

--添加连携技，主要用于计数.因为每多一个连携技，其他的连携技使用的有效时间就延长到下一个技能的一半时间
function SpellJoinableMgr.join(executorIndex)
    _joinCount = _joinCount + 1
end


return SpellJoinableMgr