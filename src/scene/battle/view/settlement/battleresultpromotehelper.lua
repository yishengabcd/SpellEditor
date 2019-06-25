local Button = require("src/ui/button")
local BattleDal = require("src/dal/battle")
local Localized = require("src/localized")

local BattleResultPromoteHelper = {}

BattleResultPromoteHelper.WAY_EVOLVE = 1
BattleResultPromoteHelper.WAY_ADVANCE = 2
BattleResultPromoteHelper.WAY_STARSGINS = 3
BattleResultPromoteHelper.WAY_BARRACK = 4

function BattleResultPromoteHelper:createBtn(tag, callback)
    self._callback = callback;
    local icon_n
    local text
    if tag == BattleResultPromoteHelper.WAY_EVOLVE then
        icon_n = "ui/main/ui_city_icon_bag.png"
        text = Localized.lang.strengthen_way1
    elseif tag == BattleResultPromoteHelper.WAY_ADVANCE then
        icon_n = "ui/main/ui_city_icon_friend.png"
        text = Localized.lang.strengthen_way2
    elseif tag == BattleResultPromoteHelper.WAY_STARSGINS then
        icon_n = "ui/main/icon_horoscope.png"
        text = Localized.lang.strengthen_way3
    elseif tag == BattleResultPromoteHelper.WAY_BARRACK then
        icon_n = "ui/main/ui_city_icon_rank.png"
        text = Localized.lang.strengthen_way4
    end
    
    local btn = Button:createButton("ui/main/ui_city_icon.png", nil,nil,self.onMenuHandler,self)
    local back = cc.Sprite:createWithSpriteFrameName(icon_n)
    back:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
    btn:addChild(back, -1)
    btn:setTitleFontSize(23)
    btn:setTextOffPos(0, -65)
    btn:setAnchorPoint(0.5, 0.5)
    btn:setTag(tag)
    btn:setTitleText(text)
    btn:setFontColor(cc.c3b(252, 255, 255))
    
    return btn
end

function BattleResultPromoteHelper:onMenuHandler(sender)
    local tag = sender:getTag()
    if tag == BattleResultPromoteHelper.WAY_EVOLVE then
        BattleDal:onStrengthenWay(BattleResultPromoteHelper.WAY_EVOLVE)
    elseif tag == BattleResultPromoteHelper.WAY_ADVANCE then
        BattleDal:onStrengthenWay(BattleResultPromoteHelper.WAY_ADVANCE)
    elseif tag == BattleResultPromoteHelper.WAY_STARSGINS then
        BattleDal:onStrengthenWay(BattleResultPromoteHelper.WAY_STARSGINS)
    elseif tag == BattleResultPromoteHelper.WAY_BARRACK then
        BattleDal:onStrengthenWay(BattleResultPromoteHelper.WAY_BARRACK)
    end
    if self._callback then
        self._callback()
    end
end

return BattleResultPromoteHelper