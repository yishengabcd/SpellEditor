local PreviewWindow = class("PreviewWindow", require("components.BaseWindow"))

local Map = require("src/scene/battle/mode/Map")
local model = require("spellgen.model.BattleSimulateModel")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local Role = require("src/scene/battle/mode/Role")
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local Battle = require("src/scene/battle/mode/Battle")
local CustomButton = require("components.CustomButton")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local Spell = require("src/scene/battle/mode/Spell")
local SpellMgr = require("src/scene/battle/manager/SpellMgr")
require("src/gameutils")

function PreviewWindow:ctor(closeHandler, composite)
    self._speed = 1
    
    local size = cc.size(964,679)
    PreviewWindow.super.ctor(self, size, closeHandler)
    self._composite = composite --是否是复合技能预览，不为nil时会预览BattleConfig.lua中的所有技能
    local rect = self:getContentRect()
    
    local container = cc.ClippingNode:create();
    container:setAnchorPoint(0,0)
    container:setPosition(rect.x,rect.y)
    self:addChild(container)
    self._container = container
    
    local stencil = cc.Sprite:create("ui/mask_rect.png")
    stencil:setAnchorPoint(0,0)
    stencil:setScaleX(rect.width/stencil:getContentSize().width)
    stencil:setScaleY(rect.height/stencil:getContentSize().height)
    stencil:setPosition(0,-rect.height)
    container:setStencil(stencil)
    
    self._container = container
    
    if self._composite then
        self:setTitle("配置战斗预览960*640");
    else
        self:setTitle("当前技能预览960*640");
    end
    
    
    local changeSideBtn = CustomButton.new("换 边", function (target) 
        if self._executorSide == RoleInfo.SIDE_LEFT then
            self._executorSide = RoleInfo.SIDE_RIGHT
        else
            self._executorSide = RoleInfo.SIDE_LEFT
        end
        self:refreshBattle()
    end)
    changeSideBtn:setAnchorPoint(0,1)
    changeSideBtn:setPosition(rect.x,rect.y)
    self:addChild(changeSideBtn)
    
    local speedBtn = CustomButton.new("速度X" .. self._speed, function (target) 
        if self._speed == 1 then
            self._speed = 2
        else
            self._speed = 1
        end
        self._speedBtn:setTitleText("速度X" .. self._speed)
        BattleMgr.setSpeed(self._speed)
    end)
    speedBtn:setAnchorPoint(0,1)
    speedBtn:setPosition(changeSideBtn:getPositionX() + changeSideBtn:getContentSize().width, changeSideBtn:getPositionY())
    self:addChild(speedBtn)
    self._speedBtn = speedBtn
    
    local slowSpeedBtn = CustomButton.new("速度X0.1", function (target) 
        BattleMgr.setSpeed(0.1)
    end)
    slowSpeedBtn:setAnchorPoint(0,1)
    slowSpeedBtn:setPosition(speedBtn:getPositionX() + speedBtn:getContentSize().width, speedBtn:getPositionY())
    self:addChild(slowSpeedBtn)
    
    self._executorSide = RoleInfo.SIDE_LEFT
end

function PreviewWindow:show()
    PreviewWindow.super.show(self, true)
    self._spellCompleteFunc = function (event) 
        self:refreshBattle()
    end
    self._spellCompletelistener = cc.EventListenerCustom:create(Spell.EVENT_SPELL_COMPLETE,self._spellCompleteFunc)
    addEventListenerWithFixedPriority(self._spellCompletelistener,1)
    self:refreshBattle()
--    SoundManager.playMusic("music/b_music/t_b_sound.mp3")
--    SoundManager.setMusicVolume(0.5)
    SpellMgr.setEndFlag(true)
end

function PreviewWindow:refreshBattle()
    
    if self._map then
        BattleMgr.disposeCurrentBattle()
        self._container:removeChild(self._map, true)
    end
    
    local rect = self:getContentRect()

    local battleData
    if self._composite then
        battleData = model.createBattleDataOfBattle(self._executorSide)
    else
        battleData = model.createBattleData(self._executorSide)
    end
    local PositionHelper = require("src/scene/battle/mode/PositionHelper")
    PositionHelper.initFormation(PositionHelper.FORMATION_6_3_3, PositionHelper.FORMATION_6_3_3)
    
    local battle =  Battle.new(battleData, cc.rect(400,0,rect.width,rect.height))
    BattleMgr.setBattle(battle)
    
    BattleMgr.setSpeed(self._speed)
    
    if self._onSpellComplete then
        SpellMgr:removeEventListener(Spell.EVENT_SPELL_COMPLETE, self._onSpellComplete)
    end
    
    local function onSpellComplete(event)
        if SpellMgr.isAllComplete() then
            self:refreshBattle()
        elseif #SpellMgr.getExecutingSpells() == 0 then
            SpellMgr.runActionTime()
        end
    end
    self._onSpellComplete = onSpellComplete
    
    SpellMgr:addEventListener(Spell.EVENT_SPELL_COMPLETE, self._onSpellComplete)
    self._battle = battle 

    local map = battle:getMap()
    map:setPosition(0,-rect.height)
    map:setOriginY(-rect.height)
    self._container:addChild(map)
    self._map = map

    if self._composite then
        for _, spellData in ipairs(model.createSpellDatasOfBattle(self._executorSide)) do
            BattleMgr.executeSpell(spellData)
        end
    else
        BattleMgr.executeSpell(model.createSpellData(self._executorSide, battleData))
    end
    
    if self._testui then
        self._container:removeChild(self._testui, true)
        self._testui = nil
    end
    self._testui = cc.Sprite:create("ui/battle/battle_ui_test.png")
    self._container:addChild(self._testui)
    self._testui:setAnchorPoint(0,0)
    self._testui:setPosition(0,-rect.height)
    
end

function PreviewWindow:hide()
    if self._onSpellComplete then
        SpellMgr:removeEventListener(Spell.EVENT_SPELL_COMPLETE, self._onSpellComplete)
        self._onSpellComplete = nil
    end
    BattleMgr.disposeCurrentBattle()
--    EventGlobal:removeEventListener("spellComplete", self._spellCompleteFunc)
    removeEventListener(self._spellCompletelistener)
    PreviewWindow.super.hide(self)
    AudioEngine.stopMusic(true)
end


return PreviewWindow