local BaseWindow = require("src/ui/basewindow")
local ProgressPanel = require("src/scene/battle/view/settlement/progresspanel")
local SettlementInfoPanel = require("src/scene/battle/view/settlement/settlementinfopanel")
local DetailedInfoWindow = require("src/scene/battle/view/settlement/detailedinfowindow")
local HeroItemView = require("src/scene/battle/view/settlement/heroitemview")
local Localized = require("src/localized")

local BattleWinWindow = class("BattleWinWindow",BaseWindow)

BattleWinWindow._settlementData = nil
BattleWinWindow._heroList = nil
BattleWinWindow._bones1 = nil
BattleWinWindow._bones2 = nil

function BattleWinWindow:show(settlementData, battleData)
    local o = BattleWinWindow.new()
    o._settlementData = settlementData
    o._battleData = battleData
    if o and o:init() then
        cc.Director:getInstance():getRunningScene():addChild(o,80)
        return
    end
end

function BattleWinWindow:init()
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.SETTLEMENT)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.ICON)
    BattleWinWindow.super.init(self)
    local size = cc.size(789,640)
    self:setContentSize(size)
    self:setContainerContentSize(size)
    self:showCover(200)
    self._heroList = {}
    local ray = cc.Sprite:create("ui/common/ui_lottery_light_yellow.png")
    ray:setPosition(size.width/2, size.height/2 + 150)
    ray:setScale(2)
    self:addToContainer(ray)
    local action = cc.RepeatForever:create(cc.RotateBy:create(4,360))
    ray:runAction(action)

    self._bones1 = "res/image/animation/UI/team02/team02.ExportJson"
    self._bones2 = "res/image/animation/UI/team04/team04.ExportJson"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(self._bones1)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(self._bones2)
    local n = string.gsub(self._bones1, "%.[%a%d]+$", "")
    n = string.gsub(n,".+/","")
    local armature = ccs.Armature:create(n)
    armature:setPosition(size.width/2, size.height/2 + 150)
    local star = self._settlementData.starType
    local str = nil
    if star == 1 then
        str = "stand"
    else
        str = "stand" .. tostring(star)
    end
    armature:getAnimation():play(str, -1, 0)
    self:addToContainer(armature)

    n = string.gsub(self._bones2, "%.[%a%d]+$", "")
    n = string.gsub(n,".+/","")
    local armature1 = ccs.Armature:create(n)
    armature1:setPosition(size.width/2, size.height/2 + 150)
    armature1:getAnimation():playWithIndex(0)
    self:addToContainer(armature1)

    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete then
            self:progressAction()
        elseif movementType == ccs.MovementEventType.complete then
            self:progressAction()
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationEvent)

    return true
end

function BattleWinWindow:onExit()
    ResourceManager:getInstance():removeArmatureFileInfo(self._bones1)
    ResourceManager:getInstance():removeArmatureFileInfo(self._bones2)
    BattleWinWindow.super.onExit(self)
end

function BattleWinWindow:onTouchBegin(x, y)
    local w = DetailedInfoWindow:create()
    w:setData(self._settlementData, self._battleData)
    w:show()
    self:disposeNextFrame()
    return true
end

function BattleWinWindow:progressAction()
    local progress = ProgressPanel:create()
    progress:setData()
    progress:setPosition(self:getContentSize().width/2 + progress:getContentSize().width, 269)
    self:addToContainer(progress)
    local act1 = cc.MoveTo:create(0.3,cc.p(95,269))
    local seq = cc.Sequence:create(act1, cc.CallFunc:create(handler(self,self.infoPanelAction)), nil)
    progress:runAction(seq)
end

function BattleWinWindow:infoPanelAction()
    local infoPanel = SettlementInfoPanel:create()
    infoPanel:setData(self._settlementData)
    infoPanel:setPosition(-self:getContentSize().width/2 - infoPanel:getContentSize().width, 195)
    self:addToContainer(infoPanel)
    local act = cc.MoveTo:create(0.3,cc.p(180,195))
    infoPanel:runAction(act)
    performWithDelay(self, self.heroPanelAction, 0.3)
end

function BattleWinWindow:heroPanelAction()
    local heroPadding = 40
    local heroCount = getTableSize(self._settlementData.heroList)
    for key, var in ipairs(self._settlementData.heroList) do
        local hero = HeroItemView:create()
        self:addToContainer(hero)
        local px = ((1 - heroCount) / 2  + key - 1) * (hero:getContentSize().width + heroPadding) + self:getContentSize().width / 2 - hero:getContentSize().width/2
        hero:setPosition(px, 35)
        hero:setData(var)
        table.insert(self._heroList,hero)
    end
    local draw = cc.DrawNode:create()
    draw:setAnchorPoint(0,0)
    draw:drawSolidRect(cc.p(42, 190), cc.p(720, 188), cc.c4f(0.9,0.8,0.6,0.2))
    self:addToContainer(draw)
    self:updateExpbar()
end

function BattleWinWindow:updateExpbar()
    for key, var in ipairs(self._heroList) do
        local heroListData = self._settlementData.heroList
        var:updateExpbar(heroListData[key])
    end
    performWithDelay(self, self.upLevelAction, 1)
end

function BattleWinWindow:upLevelAction()
    local dt = 0
    local flag = false
    for key, var in ipairs(self._heroList) do
        if var:isUplevel() then
            var:upLevelAction()
            flag = true
        else
            flag = false
        end
    end
    if flag then
        dt = 1.5
    else
        dt = 0
    end
    performWithDelay(self, self.doTextEffect, dt)
end

function BattleWinWindow:doTextEffect()
    local ret = cc.Label:createWithSystemFont(Localized.lang.hero_press_any_key_continue, FONT_TYPE.DEFAULT_FONT, 20)
    ret:setPosition(winSize.width/2, 30)
    self:addChild(ret)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
    ret:runAction(action)
end

return BattleWinWindow