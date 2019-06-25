
local CustomAMGR = require("src/scene/battle/manager/CustomAMGR")
local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
local MotionType = require("src/scene/battle/mode/MotionType")

local RoleAi = class("RoleAi")

local scheduler = cc.Director:getInstance():getScheduler()

function RoleAi:ctor(role, roadRect, margin)
    self._role = role
    self._bornPosition = cc.p(role:getPosition())
    self._roadRect = roadRect
    self._margin = margin
    self._actionAmgr = CustomAMGR.new(true)
    
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
    end

    local function onEnterFrame(dt)
        self._actionAmgr:enterFrame(dt)
    end
    self._schedulerEntry = scheduler:scheduleScriptFunc(onEnterFrame,1/60, false)
    
    local behaviours = {{behaviour=self.behaviourMove, weight=30}, {behaviour=self.behaviourStand, weight=70}}
    local totalWeight = 0
    for _, v in ipairs(behaviours) do
        totalWeight = totalWeight + v.weight
    end
    
    self._totalWeight = totalWeight
    self._behaviours = behaviours
    
    self:behaviourStand()
end
--当前行为结束时调用
function RoleAi:onBehaviourComplete()
    if not self._role then return end
    local rand = math.random() * self._totalWeight
    local behaviourData
    local count = 0
    for i, v in ipairs(self._behaviours) do
        count = count + v.weight
        if count > rand then
            behaviourData = v
            break
        end
    end
    if behaviourData then
        behaviourData.behaviour(self)
    end
end

--行走
function RoleAi:behaviourMove()
    local position = cc.p(self._role:getPosition())
    position.x = position.x + math.random() * 600 - 300
    position.y = position.y + math.random() * 150 - 75
    if position.x < self._roadRect.x then
        position.x = self._roadRect.x
    elseif position.x > self._roadRect.width - self._margin * 2 then
        position.x = self._roadRect.width - self._margin * 2
    end
    
    if position.y < self._roadRect.y then
        position.y = self._roadRect.y
    elseif position.y > self._roadRect.height then
        position.y = self._roadRect.height
    end
    
    local startPt = cc.p(self._role:getPosition())
    local distance = cc.pGetLength(cc.pSub(position,startPt))
    local frame = distance/4
    self._role:executeMotion(MotionType.RUN)
    local move = BattleCustomActions.MoveAction.new(self._role,startPt,position,frame)
    self:executeActions({move})
end

function RoleAi:behaviourStand()
    self._role:executeMotion(MotionType.STAND)
    local delayFrame = math.random() * 100 + 20
    local action = BattleCustomActions.DelayCallAction.new(nil, delayFrame)
    self:executeActions({action})
end

function RoleAi:executeActions(actions)
    local function onComplete()
        self:onBehaviourComplete()
    end
    local action = BattleCustomActions.SequenceAction.new(actions,onComplete)
    self._actionAmgr:act(action)
end

function RoleAi:dispose()
    self._role = nil
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
        self._schedulerEntry = nil
    end
    if self._actionAmgr then
        self._actionAmgr:dispose()
        self._actionAmgr = nil
    end
end

return RoleAi