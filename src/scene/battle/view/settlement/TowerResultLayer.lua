local BaseWindow = require("src/ui/basewindow")
local Localized = require("src/localized")
local BattleDal = require("src/dal/battle")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local Button = require("src/ui/button")
local TowerDal = require("src/dal/tower")
local BattleResultPromoteHelper = require("src.scene.battle.view.settlement.battleresultpromotehelper")

local TowerResultLayer = class("TowerResultLayer",BaseWindow)

TowerResultLayer._settlementData = nil
TowerResultLayer._heroList = nil
TowerResultLayer._bones1 = nil
TowerResultLayer._bones2 = nil

local size = cc.size(960,640)

function TowerResultLayer:ctor()
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.SETTLEMENT)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.ICON)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.MAIN)
    TowerResultLayer.super.init(self)
    
    self:setContainerContentSize(size)
    self:showCover(200)
end

function TowerResultLayer:exitBattle()
    BattleDal:onBattleEndToWin()
    BattleMgr.disposeCurrentBattle()
    SceneManager:getInstance():switchSceneByType(SceneType.MAIN)
end

function TowerResultLayer:setData(isWin, settlementData)
--    isWin = false
    if isWin then
        self._bones1 = "res/image/animation/UI/jinjiechenggong/jinjiechenggong.ExportJson"
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(self._bones1)
        local n = string.gsub(self._bones1, "%.[%a%d]+$", "")
        n = string.gsub(n,".+/","")
        local armature = ccs.Armature:create(n)
        armature:setPosition(size.width/2, size.height/2 + 100)
        armature:getAnimation():play("stand1", -1, 0)
        self:addToContainer(armature)
        
        local rewardTitleBack = ccui.Scale9Sprite:create("ui/common/ui_common_mingzidi.png")
        rewardTitleBack:setContentSize(cc.size(302,46))
        rewardTitleBack:setPosition(size.width/2, 294)
        self:addToContainer(rewardTitleBack)

        local rewardTitle = cc.Label:createWithSystemFont(Localized.lang.tower_result_reward_title,FONT_TYPE.DEFAULT_FONT,23)
        rewardTitle:setColor(cc.c3b(255,255,255))
        rewardTitle:setPosition(rewardTitleBack:getPosition())
        self:addToContainer(rewardTitle)
        
        local goldRewardBack = ccui.Scale9Sprite:create("ui/common/ui_common_jinbidi.png")
        goldRewardBack:setContentSize(cc.size(324, 41))
        goldRewardBack:setPosition(size.width/2, rewardTitleBack:getPositionY() - 50)
        self:addToContainer(goldRewardBack)
        
        local goldIcon = cc.Sprite:createWithSpriteFrameName("ui/common/icon_coin.png")
        goldIcon:setPosition(goldRewardBack:getPositionX() - goldRewardBack:getContentSize().width/2 + 28,goldRewardBack:getPositionY())
        self:addToContainer(goldIcon)
        
        local gold = settlementData and settlementData.gold or 0
        local rewardValue = cc.Label:createWithSystemFont("+" .. gold, FONT_TYPE.DEFAULT_FONT,25)
        rewardValue:setAnchorPoint(1, 0.5)
        rewardValue:setColor(cc.c3b(255,255,255))
        rewardValue:setPosition(goldRewardBack:getPositionX() + goldRewardBack:getContentSize().width/2 - 11,goldRewardBack:getPositionY())
        self:addToContainer(rewardValue)

        if TowerDal:getNextFightFloor().locked then
            local lockTips = cc.Label:createWithSystemFont(Localized.lang.tower_result_lock_tips:format(TowerDal:getNextFightFloor():getTemplate().level),FONT_TYPE.DEFAULT_FONT,30)
            lockTips:setColor(cc.c3b(255,251,214))
            lockTips:setPosition(size.width/2, 43)
            self:addToContainer(lockTips)
        else
            self._goonBtn = Button:createButton("ui/common/ui_btn2.png", nil, nil, self.onMenuHandler,self)
            self._goonBtn:setTitleText(Localized.lang.tower_go_on_fight)
            self:addToContainer(self._goonBtn)
            self._goonBtn:setPosition(size.width/2-self._goonBtn:getContentSize().width/2, 66)
        end
    else
        self._bones1 = "res/image/animation/UI/team03/team03.ExportJson"
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(self._bones1)
        local n = string.gsub(self._bones1, "%.[%a%d]+$", "")
        n = string.gsub(n,".+/","")
        local armature = ccs.Armature:create(n)
        armature:setPosition(size.width/2, size.height/2 + 50)
        armature:getAnimation():play("stand", -1, 0)
        self:addToContainer(armature)
        
        
        local function onPromoteBtnClick()
            self:exitBattle()
        end
        
        local promoteBtns = {}
        
        local evolve = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_EVOLVE, onPromoteBtnClick)
        evolve:setAnchorPoint(0.5,0)
        self:addToContainer(evolve)
        table.insert(promoteBtns, evolve)

        local advance = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_ADVANCE, onPromoteBtnClick)
        advance:setAnchorPoint(0.5,0)
        self:addToContainer(advance)
        table.insert(promoteBtns, advance)

        local starsgins = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_STARSGINS, onPromoteBtnClick)
        self:addToContainer(starsgins)
        starsgins:setAnchorPoint(0.5,0)
        table.insert(promoteBtns, starsgins)

        local barrack = BattleResultPromoteHelper:createBtn(BattleResultPromoteHelper.WAY_BARRACK, onPromoteBtnClick)
        barrack:setAnchorPoint(0.5,0)
        self:addToContainer(barrack)
        table.insert(promoteBtns, barrack)
        
        for i, btn in ipairs(promoteBtns) do
            btn:setPosition(size.width/2 - (i - #promoteBtns/2 - 0.5) * 182,200)
        end
        
        self._retryBtn = Button:createButton("ui/common/ui_btn2.png", nil, nil, self.onMenuHandler,self)
        self._retryBtn:setTitleText(Localized.lang.tower_retry_fight)
        self:addToContainer(self._retryBtn)
        self._retryBtn:setPosition(size.width/2-self._retryBtn:getContentSize().width/2, 66)
    end
    
    local rate = winSize.width / size.width
    self._returnBtn = Button:createButton("ui/common/ui_common_fanhui.png", nil, nil, self.onMenuHandler,self)
    self._returnBtn:setScale(rate)
    self:addChild(self._returnBtn)
    self._returnBtn:setPosition(15, winSize.height - (self._returnBtn:getContentSize().height + 10) * rate)
end

function TowerResultLayer:onMenuHandler(sender)
    if sender == self._retryBtn then
--        self:exitBattle()
        TowerDal:fightCurrentFloor()
    elseif sender == self._goonBtn then
--        self:exitBattle()
        TowerDal:fightCurrentFloor()
    elseif sender == self._returnBtn then
        self:exitBattle()
    end
end

function TowerResultLayer:onExit()
    ResourceManager:getInstance():removeArmatureFileInfo(self._bones1)
    TowerResultLayer.super.onExit(self)
end

function TowerResultLayer:onTouchBegin(x, y)
--    local w = DetailedInfoWindow:create()
--    w:setData(self._settlementData)
--    w:show()
--    self:disposeNextFrame()
    self:exitBattle()
    return true
end


return TowerResultLayer