local BaseWindow = require("src/ui/basewindow")
local Localized = require("src/localized")
local Button = require("src/ui/button")
local ItemSlot = require("src/ui/bag/itemslot")
local BattleDal = require("src/dal/battle")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local TipText = require("src/ui/tiptext")
local CharacterDal = require("src/dal/character")
local InstanceChallengeDal = require("src/dal/instancechallenge")
local ChallengeDal = require("src/dal/challenge")
local Devildom = require("src/dal/devildom")
--物品合成
local BagDal = require("src/dal/bag")
local BagItemcompos = require ("src/ui/bag/bagitemcompose")

local DetailedInfoWindow = class("DetailedInfoWindow",BaseWindow)

local MENU_TAG = {
    MENU_AGAIN = 1,
    MENU_BACK = 2,
}
DetailedInfoWindow._itemList = {}
DetailedInfoWindow._settlementData = nil
DetailedInfoWindow._armature = nil
DetailedInfoWindow._againBtn = nil
DetailedInfoWindow._backBtn = nil
DetailedInfoWindow._dropCount = nil
DetailedInfoWindow._itemPadding = 40
DetailedInfoWindow._touchEnabled = nil

function DetailedInfoWindow:create()
    local o = DetailedInfoWindow.new()
    o:init()
    return o
end

function DetailedInfoWindow:init()
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.SETTLEMENT)
    DetailedInfoWindow.super.init(self)
    local size = cc.size(789,640)
    self:setContentSize(size)
    self:setContainerContentSize(size)
    self:showCover(200)
    self._autoDispose = false
    self._itemList = {}
    self._touchEnabled = true
    if CharacterDal.m_info.level >= 2 and not InstanceChallengeDal.instanceChallengeWin and not ChallengeDal.challengeWin then
        local againBtn = self:createBtn("ui/settlement/ui_count_btn_again.png", Localized.lang.settlement_btn_again, MENU_TAG.MENU_AGAIN)
        local pos = self._baseContainer:convertToNodeSpace(cc.p(winSize.width - againBtn:getContentSize().width * self.rate - 20, 180 * self.rate))
        againBtn:setPosition(pos)
        self:addToContainer(againBtn)
        againBtn:setVisible(false)
        self._againBtn = againBtn
    end
    local backBtn = self:createBtn("ui/settlement/ui_count_btn_back.png", Localized.lang.settlement_btn_back, MENU_TAG.MENU_BACK)
    local pos = self._baseContainer:convertToNodeSpace(cc.p(winSize.width - backBtn:getContentSize().width * self.rate - 20, 25))
    backBtn:setPosition(pos)
    self:addToContainer(backBtn)
    backBtn:setVisible(false)
    self._backBtn = backBtn
end

function DetailedInfoWindow:setData(data, battleData)
    self._settlementData = data
    self._battleData = battleData
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/image/animation/UI/ui_count_hezi/ui_count_hezi.ExportJson")
    local armature = ccs.Armature:create("ui_count_hezi")
    armature:setPosition(self:getContentSize().width/2 - 30, self:getContentSize().height/2 - 136)
    armature:getAnimation():playWithIndex(0)
    armature:getAnimation():play("stand", -1, 0)
    self:addToContainer(armature)
    self._armature = armature
    performWithDelay(self, self.shanguang, 1.5)
end

function DetailedInfoWindow:shanguang()
    local effect = createEffect("effect/ef_ui/count/shanguang", 0.09, nil, nil, nil, nil, true)
    self:addToContainer(effect)
    effect:setScale(2)
--    local scaleX = winSize.width / 450
--    local scaleY = winSize.height / 310
--    effect:setScale(math.max(scaleX, scaleY))
    effect:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
    self:itemsAction()
end

function DetailedInfoWindow:addItems()
    local dropList = self._settlementData.drops
    self._dropCount = getTableSize(dropList)
    for key, var in ipairs(dropList) do
        local item = ItemSlot:createBagItem()
        local tpl = require("src/entities/templatemanager"):getItemTplById(var.tplId)
        item:setTpl(tpl)
        item:setStack(var.count)
        self:addToContainer(item)
        item:setAnchorPoint(0.5,0.5)
        item:setScale(0)
        item:setPosition(self:getContentSize().width/2 + 15, self._armature:getContentSize().height/2 + 45)
        table.insert(self._itemList,item)
    end
end

function DetailedInfoWindow:itemsAction()
    self:addItems()
    local offset = nil
    if self._dropCount <= 5 then
        offset = self._dropCount
    else
        offset = 5
    end
    for key, var in ipairs(self._itemList) do
        local dt = nil
        local px = nil
        local py = self:getContentSize().height/2 + 210
        if key <= 5  then
            dt = math.abs(math.ceil(offset/2) - key) * 0.1 + 0.2
            px = ((1 - offset) / 2  + key - 1) * (var:getContentSize().width + self._itemPadding) + self:getContentSize().width / 2
        else
            dt = math.abs(math.ceil(offset/2) - (key - 5)) * 0.1 + 0.2
            px = ((1 - offset) / 2  + key - 6) * (var:getContentSize().width + self._itemPadding) + self:getContentSize().width / 2
            py = py - var:getContentSize().height - self._itemPadding
        end
        local deltaPos = cc.p(px, py)
        local act1 = cc.MoveTo:create(dt,deltaPos)
        local act2 = cc.ScaleTo:create(dt/2,1)
        local act3 = cc.RotateTo:create(dt,720)
        var:runAction(act1)
        var:runAction(act2)
        var:runAction(act3)
    end
    self._touchEnabled = false
    local delayDt = math.abs(math.ceil(self._dropCount/2) - self._dropCount) * 0.1 + 0.5
    performWithDelay(self, self.composeAction, delayDt)
end

function DetailedInfoWindow:showItems()
    self:addItems()
    local offset = nil
    if self._dropCount <= 5 then
        offset = self._dropCount
    else
        offset = 5
    end
    for key, var in ipairs(self._itemList) do
        var:setScale(1)
--        local px = nil
--        local py = self:getContentSize().height/2 + 210
--        if key <= 5  then
--            px = ((1 - offset) / 2  + key - 1) * (var:getContentSize().width + self._itemPadding) + self:getContentSize().width / 2
--        else
--            px = ((1 - offset) / 2  + key - 6) * (var:getContentSize().width + self._itemPadding) + self:getContentSize().width / 2
--            py = py - var:getContentSize().height - self._itemPadding
--        end
       local px = ((1 - offset) / 2  + (key - 1)%5) * (var:getContentSize().width + self._itemPadding) + self:getContentSize().width / 2
       local py = self:getContentSize().height/2 + 210 - (var:getContentSize().height + self._itemPadding) * math.floor((key - 1)/5)
        var:setPosition(px, py)
    end
end

function DetailedInfoWindow:setBtnVisibel()
    if self._againBtn then
        self._againBtn:setVisible(true)
    end
    if self._backBtn then
        self._backBtn:setVisible(true)
    end
end

function DetailedInfoWindow:onTouchBegin(x, y)
    if self._touchEnabled then
        self:stopAllActions()
        self._armature:getAnimation():setSpeedScale(100)
        self:showItems()
        self:setBtnVisibel()
        self._touchEnabled = false
    end
    return true
end

function DetailedInfoWindow:composeAction()
     --显示合成的物品
    local haveitemcompse = BagDal:haveCompseItem()
    if haveitemcompse then
        self:doBagItemcompose()
    end
    self:setBtnVisibel()
end

function DetailedInfoWindow:createBtn(icon_n, text, tag)
    local size = cc.size(98, 137)
    local sp = cc.Sprite:create()
    sp:setContentSize(size)
    sp:setAnchorPoint(0, 0)
    local icon = cc.Sprite:createWithSpriteFrameName(icon_n)
    icon:setPosition(size.width / 2, 39)
    sp:addChild(icon)
    icon:setAnchorPoint(0.5, 0)
    local btn = Button:createButton(sp, nil, nil, self.onMenuHandler, self) 
    btn:setTag(tag)
    btn:setTitleText(text)
    btn:setFontColor(cc.c3b(240, 182, 69))
    btn:setTitleFontSize(29)
    btn:setTextOffPos(0, -size.height / 2 + 15)
    return btn
end

function DetailedInfoWindow:onMenuHandler(sender)
    if sender:getTag() == MENU_TAG.MENU_AGAIN then
        if self._battleData.type == GameType.GAME_STORY then
            local battleData = BattleMgr.getBattleData()
            self:enterStory(battleData.mapData)
        elseif self._battleData.type == GameType.GAME_DEVILDOM_FEMALE
            or self._battleData.type == GameType.GAME_DEVILDOM_MALE
            or self._battleData.type == GameType.GAME_DEVILDOM_WITH then
            if Devildom.currentFightInfo then
                if Devildom.currentFightInfo:getDoorInfo().leftTimes < 1 then
                    local TipText = require("src/ui/tiptext")
                    TipText:show(Localized.lang.devildom_time_empty)
                else
                    Devildom:sendFight(Devildom.currentFightInfo)
                end
            end
        end
    elseif sender:getTag() == MENU_TAG.MENU_BACK then
        self:leaveGame()
    end
end

function DetailedInfoWindow:enterStory(mapData)
    local CharacterDal = require("src/dal/character")
    local StoryDal = require("src/dal/story")
    local storyTpl = require("src/entities/templatemanager"):getChapterNodeTplByTplId(mapData.storyId)
    if storyTpl.need_energy > CharacterDal.m_info.energy then
        TipText:show(Localized.lang.global_energy_not_enough)
        return
    end
    StoryDal:sendEnterStory(mapData.storyId)
end

function DetailedInfoWindow:leaveGame()
    BattleDal:onBattleEndToWin()
    self:removeFromParent()
    BattleMgr.disposeCurrentBattle()
    SceneManager:getInstance():switchSceneByType(SceneType.MAIN)
end

--显示合成物品
function DetailedInfoWindow:doBagItemcompose()
    local composlist = BagDal:getComposItem()
    if composlist then
        local bagitemcompos = BagItemcompos:create(composlist)
        bagitemcompos:show()
    else
        return 
    end
end

function DetailedInfoWindow:onExit()
     --重置背包合成
    BagDal:setCompseItem()
end

return DetailedInfoWindow