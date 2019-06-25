local DramaRoleBubble = class("DramaRoleBubble", function ()
    return cc.Node:create()
end)

local MAX_WIDTH = 200
local BORDER = 12
function DramaRoleBubble:ctor(actionData)
    self._actionData = actionData
    self:setAnchorPoint(0.5, 0)
    
    local back = ccui.Scale9Sprite:create("ui/common/drama_bubble.png")
    back:setCapInsets(cc.rect(45,12,53,35))
--    back:setContentSize(cc.size(winSize.width,149))
    back:setAnchorPoint(0.5, 0)
    self:addChild(back)
    self._back = back
    if actionData.direction == 2 then
        back:setScaleX(-1)
    end
    
    local words = cc.Label:createWithSystemFont("", FONT_TYPE.DEFAULT_FONT, 20)
    words:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    words:setColor(cc.c3b(0,0,0))
--    words:setAnchorPoint(cc.p(0,1))
--    words:setDimensions(back:getContentSize().width - 240,0)
    self:addChild(words)
    self._words = words
    if actionData.xOffset then
        back:setPositionX(actionData.xOffset)
        words:setPositionX(actionData.xOffset)
    end
end

function DramaRoleBubble:speak(words)
    self._words:setString(words)
    if self._words:getContentSize().width > MAX_WIDTH then
        self._words:setDimensions(MAX_WIDTH - BORDER * 2,0)
    end
    local backW = self._words:getContentSize().width + BORDER * 2
    if backW < 56 then backW = 56 end
    self._back:setContentSize(cc.size(backW,self._words:getContentSize().height + BORDER + 22))
    self._words:setPositionY(self._words:getContentSize().height/2 + 22)
    if self._actionData.direction == 2 then
        local w = self._back:getContentSize().width-30
        self:setAnchorPoint(w/self._back:getContentSize().width, 0)
    else
        self:setAnchorPoint(30/self._back:getContentSize().width, 0)
    end
    self:setAnchorPoint(0, 0)
    self:setScale(0.1)
    self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.1),cc.ScaleTo:create(0.03, 0.9),cc.ScaleTo:create(0.02, 1)))
end

return DramaRoleBubble