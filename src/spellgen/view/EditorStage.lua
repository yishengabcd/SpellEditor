local Map = require("src/scene/battle/mode/Map")
local model = require("spellgen.model.BattleSimulateModel")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local Role = require("src/scene/battle/mode/Role")
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local FrameState = require("src/scene/battle/mode/FrameState")
local Battle = require("src/scene/battle/mode/Battle")
local MotionType = require("src/scene/battle/mode/MotionType")

local winSize = cc.Director:getInstance():getVisibleSize()
local viewport = cc.rect(0,150,830,530)
viewport.y = viewport.y + winSize.height - 680

local EditorStage = class("EditorStage",function () 
    return cc.ClippingNode:create()
end)

function EditorStage:ctor()
    local stencil = cc.Sprite:create("ui/mask_rect.png")
    stencil:setAnchorPoint(0,0)
    stencil:setScaleX(viewport.width/stencil:getContentSize().width)
    stencil:setScaleY(viewport.height/stencil:getContentSize().height)
    stencil:setPosition(viewport.x,viewport.y)
    self:setStencil(stencil)
end

function EditorStage:loadMap(info)
    
    if self._map then 
        local FrameActionFactory = require("src/scene/battle/mode/FrameActionFactory")
        FrameActionFactory.resetForEditor()
        self:removeChild(self._map,true)
        BattleMgr.disposeCurrentBattle()
    end
    
    BattleMgr.setEditing(true)
    
    local mapRect = cc.rect(400,0,960,640)
    local PositionHelper = require("src/scene/battle/mode/PositionHelper")
    PositionHelper.initFormation(PositionHelper.FORMATION_6_3_3, PositionHelper.FORMATION_6_3_3)
    local battle =  Battle.new(model.createBattleData(), mapRect)
    BattleMgr.setBattle(battle)
    self._battle = battle
    
    local map = battle:getMap()
    map:setPosition(viewport.x,viewport.y)
    map:setOriginY(viewport.y)
    self:addChild(map)
    map:setScale(0.8)
    self._map = map
    
    BattleMgr.executeSpellForEditor(model.createSpellData())
    
    if self._onFrameChanged then

        EditorSpellModel:removeEventListener(EditorSpellModel.EDIT_SPELL_CHANGED, self._onFrameChanged)
        EditorSpellModel:removeEventListener(EditorSpellModel.FRAME_INDEX_CHANGED, self._onFrameChanged)
        EditorSpellModel:removeEventListener(EditorSpellModel.ROLE_CHANGED, self._onRoleChange)

    end
    
    local function onFrameChanged (event) 
        BattleMgr.setFrameForEditor(EditorSpellModel.getCurrentFrameIndex())
    end
    
    local function onRoleChange (event) 
    
        if EditorSpellModel.getEditSpell().leftRolePath then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(EditorSpellModel.getEditSpell().leftRolePath)
            BattleMgr.getBattle():getRole(1,4):setArmature(EditorSpellModel.getEditSpell().leftRolePath)
        end

        if EditorSpellModel.getEditSpell().rightRolePath then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(EditorSpellModel.getEditSpell().rightRolePath)
            BattleMgr.getBattle():getRole(2,4):setArmature(EditorSpellModel.getEditSpell().rightRolePath)
            BattleMgr.getBattle():getRole(2,4):setDirection(Role.DIRECTION_LEFT)
            BattleMgr.getBattle():getRole(2,4):executeMotion(MotionType.PREPARE)
        end
    end
    
    self._onFrameChanged = onFrameChanged
    self._onRoleChange = onRoleChange

    EditorSpellModel:addEventListener(EditorSpellModel.EDIT_SPELL_CHANGED, onFrameChanged)
    EditorSpellModel:addEventListener(EditorSpellModel.FRAME_INDEX_CHANGED, onFrameChanged)
    EditorSpellModel:addEventListener(EditorSpellModel.ROLE_CHANGED, onRoleChange)
end

function EditorStage:getMap()
    return self._map
end

return EditorStage