
local BattleSpeedMgr = require("src/scene/battle/manager/BattleSpeedMgr")
local BuffNameEffect = {}

local BuffNameEffect = class("BuffNameEffect");

function BuffNameEffect.play(target, buffData)
    
    local type = buffData:getTemplate().buff_type
    local Localized = require("src/localized")
--    local str = Localized.lang["battle_buff_effect_" .. id]
    local str = buffData:getTemplate()["name" .. Localized.type]
    if str then
        local color
        if type == 1 then
            color = cc.c3b(0,180,255)
        else
            color = cc.c3b(255,2,0)
        end
        BuffNameEffect.new(target, str, color)
    end
end

function BuffNameEffect:ctor(target, str, color)
    local view = cc.Label:createWithSystemFont(str, FONT_TYPE.DEFAULT_FONT_BOLD, 40)
    view:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    view:setColor(color)
    
    local x = math.random()*20 - 20
    view:setAnchorPoint(0.5,0.5)

    local pt = cc.p(target:getPosition())
    pt.x = pt.x + x
    pt.y = pt.y + 180

    view:setPosition(pt)

    local container = target:getParent()
    container:addChild(view, 99999999)

    local function moveUpEnd()
        view:removeFromParent(true)
    end

    local function onExitHandler(event)
        if "exit" == event then
            BattleSpeedMgr.removeMember(self)
        end
    end

    view:registerScriptHandler(onExitHandler)

    view:setScale(1)
    local action

    local move3 = cc.MoveBy:create(1,cc.p(0, 150))
    local function startFadeOut()
        local action1 = cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function () self._fadeOutSpeedAction1 = nil end))
        self._fadeOutSpeedAction1 = cc.Speed:create(action1,self._effectSpeed or 1)

        view:runAction(self._fadeOutSpeedAction1)
    end

    local startFadeOutAction = cc.CallFunc:create(startFadeOut)

    local call = cc.CallFunc:create(moveUpEnd)
    action = cc.Sequence:create(startFadeOutAction,move3, call)

    local speedAction = cc.Speed:create(action,1)
    self._speedAction = speedAction
    BattleSpeedMgr.addMember(self)
    view:runAction(speedAction)
end


function BuffNameEffect:setSpeed(speed)
    self._effectSpeed = speed
    self._speedAction:setSpeed(speed)
    if self._fadeOutSpeedAction1 then
        self._fadeOutSpeedAction1:setSpeed(speed)
    end
end

return BuffNameEffect