
local BattleProxy = require("src/dal/battleproxy")
local BuffData = require("src/scene/battle/data/BuffData")

local BuffMgr = {}

local _battle
local _buffs

function BuffMgr.setup(battle)
    _battle = battle
    _buffs = {}
    
    BuffMgr.dispose()
    
    local SpellMgr = require("src/scene/battle/manager/SpellMgr")
    
    BuffMgr._onBuffProcess = function (event)
        if SpellMgr.isFreeTime() or SpellMgr.isAllComplete() then
            BuffMgr.processBuff(event.data)
        else
            BuffMgr.cache(event.data)
        end
    end
    
    BattleProxy:addEventListener(BattleProxy.EVENT_BUFF_INVOKE, BuffMgr._onBuffProcess)
    BattleProxy:addEventListener(BattleProxy.EVENT_BUFF_REMOVE, BuffMgr._onBuffProcess)
end


function BuffMgr.cache(buffData)
    for i, mem in ipairs(_buffs) do
        if mem == buffData then
            return
        end
    end
    table.insert(_buffs,buffData)
end

function BuffMgr.process()
    for i, buffData in ipairs(_buffs) do
        BuffMgr.processBuff(buffData)
    end
    _buffs = {}
end

function BuffMgr.processBuff(buffData)
    if buffData.processType == BuffData.PROCESS_TYPE_ADD then
        local roleInfo = _battle:getBattleData():getRoleInfo(buffData.team, buffData.position)
        if roleInfo then
            roleInfo:addBuff(buffData)
        end
    elseif buffData.processType == BuffData.PROCESS_TYPE_REMOVE then
        local roleInfo = _battle:getBattleData():getRoleInfo(buffData.team, buffData.position)
        if roleInfo then
            roleInfo:removeBuff(buffData)
        end
    elseif buffData.processType == BuffData.PROCESS_TYPE_INVOKE then
        local roleInfo = _battle:getBattleData():getRoleInfo(buffData.team, buffData.position)
        if roleInfo then
            roleInfo:invokeBuff(buffData)
        end
    end
end

function BuffMgr.dispose()
    if BuffMgr._onBuffProcess then
        BattleProxy:removeEventListener(BattleProxy.EVENT_BUFF_INVOKE, BuffMgr._onBuffProcess)
        BattleProxy:removeEventListener(BattleProxy.EVENT_BUFF_REMOVE, BuffMgr._onBuffProcess)
        BuffMgr._onBuffProcess = nil
    end
end

return BuffMgr