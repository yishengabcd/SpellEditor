local CharacterDal = require("src/dal/character")
local ItemSlot = require("src/ui/bag/itemslot")

local SettlementInfoPanel = class("SettlementInfoPanel",function ()
    return ccui.Widget:create()
end)

SettlementInfoPanel._characterIcon = nil
SettlementInfoPanel._expIcon = nil
SettlementInfoPanel._exp = nil
SettlementInfoPanel._goldIcon = nil
SettlementInfoPanel._gold = nil

function SettlementInfoPanel:create()
    local o = SettlementInfoPanel.new()
    o:init()
    return o
end

function SettlementInfoPanel:init()
    local characterIcon = ItemSlot:createHeroItem()
    characterIcon:setSizeScale(0.7)
    self:addChild(characterIcon)
    self._characterIcon = characterIcon
    local expIcon = cc.Sprite:createWithSpriteFrameName("ui/common/icon_exp.png")
    expIcon:setAnchorPoint(0, 0)
    expIcon:setPosition(characterIcon:getPositionX() + characterIcon:getContentSize().width + 40, characterIcon:getPositionY() + characterIcon:getContentSize().height - expIcon:getContentSize().height)
    self:addChild(expIcon)
    self._expIcon = expIcon

    local exp = cc.Label:createWithSystemFont("",FONT_TYPE.DEFAULT_FONT_BOLD, 25, cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    exp:setAnchorPoint(0, 0)
    self:addChild(exp)
    self._exp = exp

    local goldIcon = cc.Sprite:createWithSpriteFrameName("ui/common/icon_coin.png")
    goldIcon:setAnchorPoint(0, 0)
    goldIcon:setScale(0.8)
    goldIcon:setPosition(expIcon:getPositionX() + expIcon:getContentSize().width/2 - goldIcon:getContentSize().width/2 * 0.8, characterIcon:getPositionY())
    self:addChild(goldIcon)
    self._goldIcon = goldIcon

    local gold = cc.Label:createWithSystemFont("",FONT_TYPE.DEFAULT_FONT_BOLD, 25, cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    gold:setAnchorPoint(0, 0)
    self:addChild(gold)
    self._gold = gold

    self:setAnchorPoint(cc.p(0,0))
end

function SettlementInfoPanel:setData(data)
    local tpl = require("src/entities/templatemanager"):getMountInfo(CharacterDal.m_info.headId)
    self._characterIcon:setIcon(tpl.icon)
    local expText = 0
    local goldText = 0
    if data then
        expText = data.expBase + data.expAugment
        goldText = data.goldBase + data.goldAugment
    end
    self._exp:setString(string.format("+%d",expText))
    self._gold:setString(string.format("+%d",goldText))
    self._exp:setPosition(self._expIcon:getPositionX() + self._expIcon:getContentSize().width + 20, self._expIcon:getPositionY() + self._expIcon:getContentSize().height/2 - self._exp:getContentSize().height/2)
    self._gold:setPosition(self._exp:getPositionX(), self._characterIcon:getPositionY())
    local width = math.max(self._characterIcon:getContentSize().width + self._expIcon:getContentSize().width + self._exp:getContentSize().width + 60, self._characterIcon:getContentSize().width + self._goldIcon:getContentSize().width * 0.8 + self._gold:getContentSize().width + 60)
    self:setContentSize(width, self._characterIcon:getContentSize().height)
end

return SettlementInfoPanel