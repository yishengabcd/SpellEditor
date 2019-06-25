local ProgressBar = require("src/ui/progressbar")
local CharacterDal = require("src/dal/character")

local ProgressPanel = class("ProgressPanel",function ()
    return ccui.Widget:create()
end)

ProgressPanel._expBar = nil

function ProgressPanel:create()
    local o = ProgressPanel.new()
    o:init()
    return o
end

function ProgressPanel:init()
    local levelIcon = cc.Sprite:createWithSpriteFrameName("ui/common/ui_city_icon_lv.png")
    levelIcon:setAnchorPoint(0, 0)
    self:addChild(levelIcon)
    
    local level = cc.Label:createWithSystemFont(CharacterDal.m_info.level,FONT_TYPE.DEFAULT_FONT_BOLD, 30, cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    level:setAnchorPoint(0, 0)
    level:setPosition(levelIcon:getPositionX() + levelIcon:getContentSize().width + 10, levelIcon:getPositionY() + levelIcon:getContentSize().height/2 - level:getContentSize().height/2)
    level:setColor(cc.c3b(255,234,169))
    self:addChild(level)
    
    local expBar = ProgressBar:create("ui/settlement/ui_count_bg_progressBar.png", "ui/settlement/ui_count_skin_progressBar.png", 0, 52, 4)
    expBar:setPosition(level:getPositionX() + level:getContentSize().width + 20, levelIcon:getPositionY() + levelIcon:getContentSize().height/2 - expBar:getContentSize().height/2)
    self:addChild(expBar)
    expBar:updateProgress(0, 100)
    self._expBar = expBar
    
    local width = levelIcon:getContentSize().width + level:getContentSize().width + expBar:getContentSize().width + 30
    self:setContentSize(width, 30)
    self:setAnchorPoint(cc.p(0,0))
end

function ProgressPanel:setData()
    local needExp = CharacterDal.m_info:getLevelUpNeedExp()
    self._expBar:updateProgress(CharacterDal.m_info.exp, needExp)
    self._expBar:setString(string.format("%d/%d",CharacterDal.m_info.exp, needExp))
end

return ProgressPanel