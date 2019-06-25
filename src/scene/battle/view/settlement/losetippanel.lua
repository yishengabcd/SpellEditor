local Localized = require("src/localized")
local LoseTipPanel = class("LoseTipPanel",function ()
    return ccui.Widget:create()
end)

function LoseTipPanel:create()
    local o = LoseTipPanel.new()
    o:init()
    return o
end

function LoseTipPanel:init()
    local bg = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_count_border_text.png")
    bg:setAnchorPoint(0, 0)
    self:addChild(bg)

    local text = cc.Label:createWithSystemFont(Localized.lang.settlement_express,FONT_TYPE.DEFAULT_FONT_BOLD, 22, cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    text:setAnchorPoint(0, 0)
    text:setPosition(bg:getPositionX() + bg:getContentSize().width/2 - text:getContentSize().width/2, bg:getPositionY() + bg:getContentSize().height/2 - text:getContentSize().height/2)
    text:setColor(cc.c3b(252,237,175))
    self:addChild(text)

    self:setContentSize(bg:getContentSize().width, 30)
    self:setAnchorPoint(cc.p(0,0))
end

return LoseTipPanel