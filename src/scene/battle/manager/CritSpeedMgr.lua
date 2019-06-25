
--暴击时的速度调节
local CritSpeedMgr = {}

local _currentAction

--产生暴击时调用
function CritSpeedMgr.occur()
    do return end
    local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
    local ActionEaseType = require("src/scene/battle/mode/ActionEaseType")
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    
    if _currentAction then
        BattleMgr.removeCustomAction(_currentAction)
        _currentAction = nil
    end

    local function onComplete()
--        BattleMgr.setSpeed(nil,nil, 1)
        if _currentAction then
            _currentAction = nil
        end
    end
    local speed1 = BattleCustomActions.SpeedAdjustAction.new(1, 0.1, 2,ActionEaseType.EaseOut, true)
    local speed2 = BattleCustomActions.SpeedAdjustAction.new(0.1, 1, 2,ActionEaseType.EaseIn, true)
    local queue = BattleCustomActions.SequenceAction.new({speed1, speed2}, onComplete)
    BattleMgr.executeCustomAction(queue)
    _currentAction = queue
    
--    BattleMgr.setSpeed(nil,nil, 0.1)
--    local delay = BattleCustomActions.DelayCallAction.new(onComplete,3)
--    BattleMgr.executeCustomAction(delay)
--    _currentAction = delay
end

return CritSpeedMgr