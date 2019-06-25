local ItemSlot = require("src/ui/bag/itemslot")
local ProgressBar = require("src/ui/progressbar")
local HeroDal = require("src/dal/hero")
local CharacterDal = require("src/dal/character")
local BlendFactor = require("src/scene/battle/mode/BlendFactor")

local HeroItemView = class("HeroItemView",function ()
    return ccui.Widget:create()
end)

HeroItemView._icon = nil
HeroItemView._levelIcon = nil
HeroItemView._level = nil
HeroItemView._expBar = nil
HeroItemView._exp = nil
HeroItemView._data = nil

function HeroItemView:create()
    local o = HeroItemView.new()
    o:init()
    return o
end

function HeroItemView:init()
    local size = cc.size(96, 135)
    self:setContentSize(size)
    self:setAnchorPoint(cc.p(0,0))

    local icon = ItemSlot:createHeroItem()
    icon:setSizeScale(0.7)
    self:addChild(icon)
    self._icon = icon

    local levelIcon = cc.Sprite:createWithSpriteFrameName("ui/common/ui_city_icon_lv.png")
    levelIcon:setAnchorPoint(0, 0)
    self:addChild(levelIcon)
    self._levelIcon = levelIcon

    local level = cc.Label:createWithSystemFont("",FONT_TYPE.DEFAULT_FONT_BOLD, 24, cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    level:setAnchorPoint(0, 0)
    self:addChild(level)
    self._level = level

    local scale = 92/216
    local outer = ccui.Scale9Sprite:createWithSpriteFrameName("ui/common/jindutiao01.png")
    outer:setContentSize(outer:getContentSize().width * scale, outer:getContentSize().height)
    local inner = ccui.Scale9Sprite:createWithSpriteFrameName("ui/common/jindutiao.png")
    inner:setContentSize(outer:getContentSize().width + 2,outer:getContentSize().height + 2)
    local expBar = ProgressBar:createWithScale9Sprite(inner, outer, 0, 1, 1)
    self:addChild(expBar)
    expBar:updateProgress(0, 100)
    self._expBar = expBar

    local exp = cc.Label:createWithSystemFont("",FONT_TYPE.DEFAULT_FONT_BOLD, 20, cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    exp:setAnchorPoint(0, 0)
    self:addChild(exp)
    self._exp = exp
end

function HeroItemView:setData(data)
    self._data = data
    local info = HeroDal:getHeroInfoById(data.heroId)
    local heroTpl = info:getHeroTpl()
    self._icon:setIcon(heroTpl.res_head)
    local quality = info:getHeroQuality()
    self._icon:setQulityIcon(quality)
    self._level:setString(tostring(info.level))
    self._exp:setString(string.format("+%d",0))
    self._icon:setPosition(0, self:getContentSize().height - self._icon:getContentSize().height)
    self._levelIcon:setPosition(self._icon:getPositionX() + 15, self._icon:getPositionY() - self._levelIcon:getContentSize().height/2)
    self._level:setPosition(self._levelIcon:getPositionX() + self._levelIcon:getContentSize().width, self._levelIcon:getPositionY() + self._levelIcon:getContentSize().height/2 - self._level:getContentSize().height/2)
    self._expBar:setPosition(self._icon:getPositionX() + self._icon:getContentSize().width/2 - self._expBar:getContentSize().width/2, self._icon:getPositionY() - self._expBar:getContentSize().height - 15)
    self._exp:setPosition(self._icon:getPositionX() + self._icon:getContentSize().width/2 - self._exp:getContentSize().width/2, self._expBar:getPositionY() - self._exp:getContentSize().height - 5)
end

function HeroItemView:updateExpbar()
    local info = HeroDal:getHeroInfoById(self._data.heroId)
    local needExp = info:getNeedExp()
    self._expBar:updateProgress(HeroDal._heroDic[self._data.heroId].exp, needExp)
    local exp = self._data.expBase + self._data.expAugment
    self._exp:setString(string.format("+%d",exp))
    self._expBar:setPosition(self._icon:getPositionX() + self._icon:getContentSize().width/2 - self._expBar:getContentSize().width/2, self._icon:getPositionY() - self._expBar:getContentSize().height - 15)
    self._exp:setPosition(self._icon:getPositionX() + self._icon:getContentSize().width/2 - self._exp:getContentSize().width/2, self._expBar:getPositionY() - self._exp:getContentSize().height - 5)
end

function HeroItemView:upLevelAction()
    local up = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_count_skin_lvUp.png")
    up:setAnchorPoint(0, 0)
    up:setPosition(self._icon:getPositionX() + self._icon:getContentSize().width/2 - up:getContentSize().width/2, self._icon:getPositionY() + self._icon:getContentSize().height - 10)
    self:addChild(up)
    local deltaPos = cc.p(self._icon:getPositionX() + self._icon:getContentSize().width/2 - up:getContentSize().width/2, self._icon:getPositionY() + self._icon:getContentSize().height - 5)
    local action = cc.MoveTo:create(0.2,deltaPos)
    up:runAction(action)

    local effect = createEffect("effect/ef_ui/count/lvup", nil, true, nil, true, nil, true)
    self:addChild(effect)
    effect:setScale(1.7)
    effect:setPosition(self._icon:getPositionX() + self._icon:getContentSize().width/2 + 10,self._icon:getPositionY() + self._icon:getContentSize().height/2 + 15)
end

function HeroItemView:isUplevel()
    if self._data then
        local info = HeroDal:getHeroInfoById(self._data.heroId)
        if info.exp >= self._data.expTotal then
            return false
        else
            return true
        end
    else
        return false
    end
end

return HeroItemView