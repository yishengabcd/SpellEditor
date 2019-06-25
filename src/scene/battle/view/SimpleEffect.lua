
local BlendFactor = require("src/scene/battle/mode/BlendFactor")
local BattleSpeedMgr = require("src/scene/battle/manager/BattleSpeedMgr")
local EffectPreloader = require("src/scene/battle/utils/EffectPreloader")
local EffectMgr = require("src/scene/battle/manager/EffectMgr")

local scheduler = cc.Director:getInstance():getScheduler()

local effectReference = {}

local SimpleEffect = class("SimpleEffect",function () 
    return customext.AnimateSprite:create() 
end)
SimpleEffect.DEFAULT_DELAY_PER_UNIT = 0.033--默认的每帧间隔时间，0.033是特效生成脚本写死的
function SimpleEffect:ctor(name, repeatFlag, defSpeed, blendSrc, blendDst, duration, callback, nonSpeedAjustable, recycle)
    local defSpeed = defSpeed or 1
    local delayPerUnit = SimpleEffect.DEFAULT_DELAY_PER_UNIT/defSpeed
    
    local path = name .. ".animate.plist"
    local cache = cc.AnimationCache:getInstance()
    cache:addAnimations(path)
    self._path = path;
    self._effectName = name
    
    local count = effectReference[path] or 0
    count = count + 1
    effectReference[path] = count
    
    if not EffectPreloader.isLoaded(path) then
        EffectPreloader.setLoadedOfPlist(path)
--        require("src/ui/tiptext"):show(path)
    end
    
    local animation = cache:getAnimation(name)
    animation:setDelayPerUnit(delayPerUnit)
    self._animation = animation

    local action = cc.Animate:create(animation)
    if repeatFlag then
        action = cc.RepeatForever:create(action)
        if duration and duration > 0 then
            self._onPlayTimeout = function (dt)
                if self._schedulerEntry then
                    scheduler:unscheduleScriptEntry(self._schedulerEntry)
                    self._schedulerEntry = nil
                end
                BattleSpeedMgr.removeMember(self)
                if self:getParent() then
                    self:getParent():removeChild(self, true)
                end
            end
            self._schedulerEntry = scheduler:scheduleScriptFunc(self._onPlayTimeout, duration, false)
        end

    else
        local function effEnd()
            BattleSpeedMgr.removeMember(self)
            if self:getParent() then
                self:getParent():removeChild(self, true)
            end
            if callback then
                callback()
            end
        end
        action = cc.Sequence:create(action,cc.CallFunc:create(effEnd))
    end
    local speedAction = cc.Speed:create(action,1)
    self._speedAction = speedAction
    if not nonSpeedAjustable then
        BattleSpeedMgr.addMember(self)
    end
    self:runAction(speedAction)
    
    if blendSrc and blendDst and blendSrc ~= BlendFactor.NONE and blendDst ~= BlendFactor.NONE then
        self:setBlendFunc(blendSrc, blendDst)
    end
    
    
    local function onExitHandler(event)
        if "exit" == event then
            local count = effectReference[path]
            count = count - 1
            if count < 0 then count = 0 end
            effectReference[path] = count
            if count == 0 and recycle then
                cc.AnimationCache:getInstance():removeAnimation(self._effectName)
                cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(self._effectName .. ".plist")
                cc.Director:getInstance():getTextureCache():removeTextureForKey(self._effectName .. ".pvr.ccz")
                EffectPreloader.recycleEffect(path)
            end

            BattleSpeedMgr.removeMember(self)
            if self._schedulerEntry then
                scheduler:unscheduleScriptEntry(self._schedulerEntry)
                self._schedulerEntry = nil
            end
            self:clearCustomAction()
            if self.name then
                EffectMgr.removeEffect(self.name)
            end
        end
    end
    self:registerScriptHandler(onExitHandler)
    local frames = animation:getFrames()
    if #frames > 0 then
        self:setContentSize(frames[1]:getSpriteFrame():getOriginalSize())
    end
end

function SimpleEffect:attachCustomAction(action)
    if not self._customActions then
        self._customActions = {}
    end
    table.insert(self._customActions, action)
end

function SimpleEffect:clearCustomAction()
    if self._customActions then
        for i, action in ipairs(self._customActions) do
            action.finished = true
        end
    end
end

function SimpleEffect:getAnimation()
    return self._animation
end

function SimpleEffect:setSpeed(speed)
    self._speedAction:setSpeed(speed)
end

function SimpleEffect:getFrameNum()
    local frames = self._animation:getFrames()
    return #frames
end

return SimpleEffect