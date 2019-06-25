local CurtainView = class("CurtainView", function ()
    return cc.Node:create()
end)

function CurtainView:ctor(words)
    local winSize = winSize or cc.Director:getInstance():getVisibleSize()
    local black = cc.Sprite:create()
    local rect = cc.rect(0, 0, winSize.width*1.3, winSize.height*1.3)
    black:setTextureRect(rect)
    black:setColor(cc.c3b(0,0,0))
    self:addChild(black)
    self._black = black

    local words = cc.Label:createWithSystemFont(words, FONT_TYPE.DEFAULT_FONT, 20)
    words:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    words:setColor(cc.c3b(255,255,255))
    words:setAnchorPoint(cc.p(0.5,0.5))
    if words:getContentSize().width > 500 then
        words:setDimensions(500,0)
    end
    self:addChild(words)
    self._words = words
end

function CurtainView:setOpacity(value)
    self._black:setOpacity(value)
    self._words:setOpacity(value)
end

return CurtainView