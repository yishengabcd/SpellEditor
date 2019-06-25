
local BattleSpeedMgr = require("src/scene/battle/manager/BattleSpeedMgr")
local BloodEffectHelper = {}

local BloodEffect = class("BloodEffect");

function BloodEffect:ctor(target, value,damageType, offsetX, offsetY)
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0
    
    local view = cc.Node:create()
    local txt
    local sign
    if value > 0 then
        if damageType == DamageType.DAMAGE_CRIT then --暴击
            txt = cc.LabelAtlas:_create(value,"ui/common/ui_fight_no_crit.png",50,60,string.byte("0"))
            sign = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_icon_crit.png")
        else
            txt = cc.LabelAtlas:_create(value,"ui/common/ui_fight_no_normal.png",31,35,string.byte("0"))
            sign = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_icon_normalReduce.png")
        end
        
    else
        txt = cc.LabelAtlas:_create(-value,"ui/common/ui_fight_no_cure.png",31,35,string.byte("0"))
        sign = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_icon_cureAdd.png")
    end
    
    txt:setAnchorPoint(0.5, 0.5)
    sign:setAnchorPoint(1, 0.5)
    if value > 0 and damageType == DamageType.DAMAGE_CRIT then
        sign:setPositionX(txt:getPositionX() - txt:getContentSize().width/2 + 130)
    else
        sign:setPositionX(txt:getPositionX() - txt:getContentSize().width/2)
    end
    
    view:addChild(sign)
    view:addChild(txt)
    
    local x = math.random()*60 - 60
    view:setAnchorPoint(0.5,0.5)
    
    local pt = cc.p(target:getPosition())
    pt.x = pt.x + x + offsetX
    pt.y = pt.y + 180 + offsetY
    
    view:setPosition(pt)
    
    local container = target:getParent()
    container:addChild(view, 99999999)
    
    if damageType == DamageType.DAMAGE_CRIT then --暴击
        local CritSpeedMgr = require("src/scene/battle/manager/CritSpeedMgr")
        CritSpeedMgr.occur()
    end

    local function moveUpEnd()
        view:removeFromParent(true)
    end
    
    local function onExitHandler(event)
        if "exit" == event then
            BattleSpeedMgr.removeMember(self)
        end
    end

    view:registerScriptHandler(onExitHandler)
    
--    local action
--    if value > 0 then
--        local scaleAction = cc.ScaleTo:create(0.1,2)
--        local fade = cc.FadeIn:create(0.1)
--        local move1 = cc.MoveBy:create(0.1,cc.p(0, 10))
--
--        local spawn = cc.Spawn:create(scaleAction,fade,move1)
--
--        local scaleAction2 = cc.ScaleTo:create(0.03,1)
--        local move2 = cc.MoveBy:create(0.3,cc.p(0, 150))
--
--        local move3 = cc.MoveBy:create(0.1,cc.p(0, 50))
--        local fadeOut = cc.FadeOut:create(0.1)
--        local spawn2 = cc.Spawn:create(move3,fadeOut)
--
--        local call = cc.CallFunc:create(moveUpEnd)
--        action = cc.Sequence:create(spawn,scaleAction2,move2,spawn2, call)
--    else
--        local delay = cc.DelayTime:create(0.2)
--        local move2 = cc.MoveBy:create(0.3,cc.p(0, 150))
--        local move3 = cc.MoveBy:create(0.1,cc.p(0, 50))
--        local fadeOut = cc.FadeOut:create(0.1)
--        local spawn2 = cc.Spawn:create(move3,fadeOut)
--        local call = cc.CallFunc:create(moveUpEnd)
--        action = cc.Sequence:create(delay,move2,spawn2, call)
--    end
    
    view:setScale(4)
    local action
    local scaleAction = cc.ScaleTo:create(0.07,1)
--    local move1 = cc.MoveBy:create(0.1,cc.p(0, 10))
    local scaleAction2 = cc.ScaleTo:create(0.03,2)
    local scaleAction3 = cc.ScaleTo:create(0.01,1)
    local delay2 = cc.DelayTime:create(0.2)

    local move3 = cc.MoveBy:create(1.2,cc.p(0, 150))
    local function startFadeOut()
        local action1 = cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function () self._fadeOutSpeedAction1 = nil end))
        self._fadeOutSpeedAction1 = cc.Speed:create(action1,self._effectSpeed or 1)
        
        local action2 = cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function () self._fadeOutSpeedAction2 = nil end))
        self._fadeOutSpeedAction2 = cc.Speed:create(action2,self._effectSpeed or 1)
        
        sign:runAction(self._fadeOutSpeedAction1)
        txt:runAction(self._fadeOutSpeedAction2)
        
    end
    
    local startFadeOutAction = cc.CallFunc:create(startFadeOut)

    local call = cc.CallFunc:create(moveUpEnd)
    action = cc.Sequence:create(scaleAction,scaleAction2,scaleAction3,delay2,startFadeOutAction,move3, call)
    
    local speedAction = cc.Speed:create(action,1)
    self._speedAction = speedAction
    BattleSpeedMgr.addMember(self)
    view:runAction(speedAction)
end


function BloodEffect:setSpeed(speed)
    self._effectSpeed = speed
    self._speedAction:setSpeed(speed)
    if self._fadeOutSpeedAction1 then
        self._fadeOutSpeedAction1:setSpeed(speed)
        self._fadeOutSpeedAction2:setSpeed(speed)
    end
end

function BloodEffectHelper.playRemoveHpEffect(target, value,damageType, x, y)
    local effect = BloodEffect.new(target, value,damageType, x, y)
end
return BloodEffectHelper