
--战斗中技能播放速度的管理
local BattleSpeedMgr = {}
local _members = {}
local _speed = 1 --当前播放速度
local _speedGlobal = _speed
local _speedInside = 1
local _speedTemp = 1

local _paused

--添加成员到控制列表中，以实现改变速度时统一控制
function BattleSpeedMgr.addMember(mem)
    _members[mem] = mem
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    mem:setSpeed(_speed*BattleMgr.DEFAULT_SPEED)
end
--将成员从控制列表中移除
function BattleSpeedMgr.removeMember(mem)
    _members[mem] = nil
end

--设置技能的播放速度
--speedGlobal 全局速度,当仅调节局部速度时，可传nil
--speedInside 内部用于调节技能局部播放速度，如暴击时减速
--speedTemp 临时速度调整使用（如暴击）
function BattleSpeedMgr.setSpeed(speedGlobal, speedInside,speedTemp)
    _speedGlobal = speedGlobal or _speedGlobal
    _speedInside = speedInside or _speedInside
    _speedTemp = speedTemp or _speedTemp
    
    if _paused then
        return
    end

    local speed = _speedGlobal*_speedInside*_speedTemp

    if _speed ~= speed then
        _speed = speed
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        for k, v in pairs(_members) do
            v:setSpeed(_speed*BattleMgr.DEFAULT_SPEED)
        end
    end
end

function BattleSpeedMgr.pause()
    _paused = true
    _speed = 0
    for k, v in pairs(_members) do
        v:setSpeed(0)
    end
end

function BattleSpeedMgr.resume()
    _paused = false
    BattleSpeedMgr.setSpeed(_speedGlobal,_speedInside,_speedTemp)
end

--返回最终的速度
function BattleSpeedMgr.getSpeed()
    return _speed
end

function BattleSpeedMgr.getGlobalSpeed()
    return _speedGlobal
end

function BattleSpeedMgr.clear()
    _members = {}
end

return BattleSpeedMgr