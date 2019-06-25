
local HitNumberEffect = class("HitNumberEffect",function ()
    return cc.Node:create()
end)

function HitNumberEffect:ctor()
    local hitWords = cc.Sprite:createWithSpriteFrameName("ui/battle/hit.png")
    hitWords:setAnchorPoint(1,0.5)
    self._hitWords = hitWords
    self:addChild(hitWords)
    
    local numTxt = cc.LabelAtlas:_create("0","ui/common/battle_hit_number.png",58,57,string.byte("0"))
    numTxt:setAnchorPoint(0,0.5)
    self:addChild(numTxt)
    self._numTxt = numTxt
end

function HitNumberEffect:setNumber(value)
    self._numTxt:setString(tostring(value))
end


function HitNumberEffect:disappear()
    local function complete()
        self:getParent():removeChild(self, true)
    end
    
    local action = cc.FadeOut:create(1)
    action = cc.Sequence:create(cc.DelayTime:create(1),action, cc.CallFunc:create(complete))
    self._numTxt:runAction(action)
    
    action = cc.FadeOut:create(1)
    action = cc.Sequence:create(cc.DelayTime:create(1),action)
    self._hitWords:runAction(action)
    
end

return HitNumberEffect
