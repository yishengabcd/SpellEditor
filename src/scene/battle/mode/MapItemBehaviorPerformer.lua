
local MapItemBehaviorType = require("src/scene/battle/mode/MapItemBehaviorType")
local MapItemType = require("src/scene/battle/mode/MapItemType")
local MotionType = require("src/scene/battle/mode/MotionType")

local MapItemBehaviorPerformer = {}

function MapItemBehaviorPerformer.perform(target,itemData)
    local behaviors = itemData.behaviors
    local actions = {}
    local function createMotionFunc(motion)
        local func = function ()
            if motion then
                if target.data then
                    if  target.data.type == MapItemType.SKELETON then
                        target:getArmature():getAnimation():play(motion)
                    end
                elseif target._data then
                    if  target._data.type == MapItemType.SKELETON then
                        target:getView():getAnimation():play(motion)
                    end
                end
            end
        end
        
        return func
    end
    for i, behavior in ipairs(behaviors) do
        local action
    	if behavior.type == MapItemBehaviorType.MOVE then
            action = cc.MoveTo:create(behavior.duration,cc.p(itemData.x + behavior.x, itemData.y + behavior.y))
        elseif behavior.type == MapItemBehaviorType.SCALE then
            action = cc.ScaleTo:create(behavior.duration,behavior.scale)
        elseif behavior.type == MapItemBehaviorType.OPACITY then
            action = cc.FadeTo:create(behavior.duration,behavior.opacity)
        elseif behavior.type == MapItemBehaviorType.MOTION then
            action = cc.CallFunc:create(createMotionFunc(behavior.motion))
        elseif behavior.type == MapItemBehaviorType.SPACE then
            action = cc.DelayTime:create(behavior.duration)
    	end
    	table.insert(actions, action)
    end
    if #actions > 0 then
        local action = cc.Sequence:create(unpack(actions))
        if itemData.repeatFlag == 1 then
            action = cc.RepeatForever:create(action)
        end
        target:runAction(action)
    end
end

return MapItemBehaviorPerformer