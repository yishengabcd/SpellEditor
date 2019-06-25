local Button = require("src/ui/button")
local BattleDal = require("src/dal/battle")
local Localized = require("src/localized")
local MapDal = require("src/dal/map")
local SettingWindow = require("src/ui/setting/settingwindow")
local BattleSettingPanel = class("", function () 
    return cc.LayerColor:create(cc.c4b(0,0,0,180))
end)

function BattleSettingPanel:ctor(battle)
    self._battle = battle
    local winSize = cc.Director:getInstance():getVisibleSize()
    local scale = winSize.width/960
    local gap = 60 * scale
    
    local btns = {}
    
    local function addBtn(title)
        local btn = Button:createButton("ui/common/ui_btn03.png", nil, nil, self.onMenuHandler, self, scale)
        btn:setAnchorPoint(0.5,0.5)
        btn:setScale(scale)
        btn:setTitleText(title)
        btn:setTitleFontSize(22)
        btn:setFontColor(cc.c3b(254, 246, 210))
        btn:setPositionY(winSize.height/2)
        btn:setTextOffPos(0, 1)
        self:addChild(btn)
        table.insert(btns,btn)
        return btn
    end
    
    --2级才显示返回按钮
--    if require("src/dal/character"):checkLevel(2) then
        --不是竞技场中才显示
        if not (self._battle:getBattleData().type == GameType.GAME_TOURNAMENT and not self._battle:getBattleData().arenaIsReplay) then
        self._exitBtn = addBtn(Localized.lang.battle_exit_btn_title)
        end
--    end
    self._soundBtn = addBtn(Localized.lang.battle_sound_opened_btn_title)
    self._musicBtn = addBtn(Localized.lang.battle_music_opened_btn_title)
    self:refreshSoundBtn()
    self._resumeBtn = addBtn(Localized.lang.battle_resume_btn_title)
    
    if #btns > 0 then
        local btnWidth = btns[1]:getContentSize().width * scale
        local left = winSize.width/2 - (((#btns - 1) * gap + (#btns) *btnWidth)/2 - btnWidth/2)
        for i, btn in ipairs(btns) do
            btn:setPositionX(left + (i - 1) * (btnWidth+gap))
        end
    end
    
    local function onTouchBegan(touch, event)
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function BattleSettingPanel:onMenuHandler(sender)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    if sender == self._exitBtn then
--        local TipBox = require("src/ui/tipbox")
        local function onConfirm(tag)
--            if tag == TipBox.TIPBOX_CONFIRMED then
                BattleMgr.disposeCurrentBattle()
                SceneManager:getInstance():switchSceneByType(SceneType.MAIN)
                BattleDal:onBattleEndToWin()
                if not LD_EDITOR and self._battle:getBattleData().type ~= GameType.GAME_TOURNAMENT and not self._battle:getBattleData().arenaIsReplay then
                    if self._battle:getBattleData().type == GameType.GAME_TOWER then
                        require("src/dal/tower"):gameExit()
                    else
                        MapDal:sendExitMap()
                    end
                end
--            end
        end
--        local alert = TipBox:showAlertWidthMsg(Localized.lang.battle_exit_tips,onMenuHandler)
--        alert:setFont(FONT_TYPE.DEFAULT_FONT, 26)
        onConfirm()
    elseif sender == self._soundBtn then
        local flag = not SettingWindow:getBool(SettingWindow.SW_BTN_EFFECT)
        SettingWindow:setBool(SettingWindow.SW_BTN_EFFECT, flag)
        self:refreshSoundBtn()
    elseif sender == self._musicBtn then
        local flag = not SettingWindow:getBool(SettingWindow.SW_BG_MUSIC)
        SettingWindow:setBool(SettingWindow.SW_BG_MUSIC, flag)
        self:refreshSoundBtn()
    elseif sender == self._resumeBtn then
        BattleMgr.resume()
        BattleMgr.getScene():removeChild(self, true)
    end
end

function BattleSettingPanel:refreshSoundBtn()
    if SettingWindow:getBool(SettingWindow.SW_BTN_EFFECT) then
        self._soundBtn:setTitleText(Localized.lang.battle_sound_closed_btn_title)
    else
        self._soundBtn:setTitleText(Localized.lang.battle_sound_opened_btn_title)
    end
    if SettingWindow:getBool(SettingWindow.SW_BG_MUSIC) then
        self._musicBtn:setTitleText(Localized.lang.battle_music_closed_btn_title)
    else
        self._musicBtn:setTitleText(Localized.lang.battle_music_opened_btn_title)
    end
end

function BattleSettingPanel:show()
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    BattleMgr.pause()
    BattleMgr.getScene():addChild(self)
end

return BattleSettingPanel