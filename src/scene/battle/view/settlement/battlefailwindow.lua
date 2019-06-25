local BaseWindow = require("src/ui/basewindow")
local LoseTipPanel = require("src/scene/battle/view/settlement/losetippanel")
local Localized = require("src/localized")
local Button = require("src/ui/button")
local BattleDal = require("src/dal/battle")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local BattleResultPromoteHelper = require("src.scene.battle.view.settlement.battleresultpromotehelper")

local BattleFailWindow = class("BattleFailWindow",BaseWindow)

BattleFailWindow._settlementData = nil

function BattleFailWindow:show(settlementData)
    local o = BattleFailWindow.new()
    o._settlementData = settlementData
    if o and o:init() then
        cc.Director:getInstance():getRunningScene():addChild(o,80)
        return
    end
end

function BattleFailWindow:init()
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.SETTLEMENT)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.MAIN)
    BattleFailWindow.super.init(self)
    local size = cc.size(695,640)
    self:setContentSize(size)
    self:setContainerContentSize(size)
    self:showCover(200)
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/image/animation/UI/team03/team03.ExportJson")
    local armature = ccs.Armature:create("team03")
    armature:setPosition(size.width/2, size.height/2 + 40)
    armature:getAnimation():playWithIndex(0)
    armature:getAnimation():play("stand", -1, 0)
    self:addToContainer(armature)
    
    local bg = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_count_skin_footer.png")
    bg:setPosition(size.width/2, bg:getContentSize().height/2 + 60)
    self:addToContainer(bg)

    local loseTipPanel = LoseTipPanel:create()
    loseTipPanel:setPosition(size.width/2, 220)
    self:addToContainer(loseTipPanel)
    
    local px = bg:getPositionX() - bg:getContentSize().width/2 + 90
    local padding = 140
    
    local function onPromoteBtnClick()
        self:leaveGame()
    end
    
    local evolve = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_EVOLVE, onPromoteBtnClick)
    evolve:setPosition(px, size.height)
    self:addToContainer(evolve)
    
    local advance = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_ADVANCE, onPromoteBtnClick)
    advance:setPosition(px + padding, size.height)
    self:addToContainer(advance)
    --[[
    local starsgins = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_STARSGINS, onPromoteBtnClick)
    starsgins:setPosition(px + padding * 2, size.height)
    self:addToContainer(starsgins)
    --]]
    local barrack = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_BARRACK, onPromoteBtnClick)
    barrack:setPosition(px + padding * 2, size.height)
    self:addToContainer(barrack)
    
    local function callback4()
        local deltaPos = cc.p(px + padding * 2, bg:getPositionY() - bg:getContentSize().height/2 + 95)
        local act = cc.MoveTo:create(0.2,deltaPos)
        barrack:runAction(act)
    end
    --[[
    local function callback3()
        local deltaPos = cc.p(px + padding * 2, bg:getPositionY() - bg:getContentSize().height/2 + 95)
        local act = cc.MoveTo:create(0.2,deltaPos)
        local seq = cc.Sequence:create(act, cc.CallFunc:create(callback4))
        starsgins:runAction(seq)
    end
    --]]
    local function callback2()
        local deltaPos = cc.p(px + padding, bg:getPositionY() - bg:getContentSize().height/2 + 95)
        local act = cc.MoveTo:create(0.2,deltaPos)
        local seq = cc.Sequence:create(act, cc.CallFunc:create(callback4))
        advance:runAction(seq)
    end
    local function callback1()
        local deltaPos = cc.p(px, bg:getPositionY() - bg:getContentSize().height/2 + 95)
        local act = cc.MoveTo:create(0.2,deltaPos)
        local seq = cc.Sequence:create(act, cc.CallFunc:create(callback2))
        evolve:runAction(seq)
    end
    local deltaPosition = cc.p(size.width/2 - loseTipPanel:getContentSize().width/2, 220)
    local act1 = cc.MoveTo:create(0.2,deltaPosition)
    local seq = cc.Sequence:create(act1, cc.CallFunc:create(callback1), nil)
    loseTipPanel:runAction(seq)
    
    return true
end

function BattleFailWindow:createBtn(icon_n, text, tag)
    local size = cc.size(96, 150)
    local sp = cc.Sprite:create()
    sp:setContentSize(size)
    sp:setAnchorPoint(0, 0)
    local  bottom = cc.Sprite:createWithSpriteFrameName("ui/main/ui_menu_bg_icon.png")
    bottom:setPosition(size.width / 2, 42)
    bottom:setAnchorPoint(0.5, 0)
    sp:addChild(bottom)
    local  icon = cc.Sprite:createWithSpriteFrameName(icon_n)
    icon:setPosition(size.width / 2, bottom:getPositionY() + bottom:getContentSize().height - 12)
    sp:addChild(icon)
    icon:setAnchorPoint(0.5, 0)
    local btn = Button:createButton(sp, nil, nil, self.onMenuHandler, self) 
    btn:setTag(tag)
    btn:setTitleText(text)
    btn:setFontColor(cc.c3b(252, 206, 120))
    btn:setTitleFontSize(25)
    btn:setTextOffPos(0, -size.height / 2 + 24)
    return btn
end

function BattleFailWindow:onTouchBegin(x, y)
    BattleDal:onBattleEndToWin()
    self:leaveGame()
end

function BattleFailWindow:leaveGame()
    self:removeFromParent()
    BattleMgr.disposeCurrentBattle()
    SceneManager:getInstance():switchSceneByType(SceneType.MAIN)
end

return BattleFailWindow