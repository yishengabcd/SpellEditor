local winSize = cc.Director:getInstance():getVisibleSize()
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local TimelinePanel = require("spellgen.view.TimelinePanel")
local CanselAndResumDo = require("spellgen.view.CanselAndResumDo")
local SpellGenerateScene = class("SpellGenerateScene", function () 
    return cc.Scene:create()
end)

function SpellGenerateScene.start()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/battle.1.plist")
    local scene = SpellGenerateScene.new()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
end

function SpellGenerateScene:ctor()
    local background = cc.Sprite:create("ui/background.png")
    background:setAnchorPoint(0,0)
    background:setScaleX(winSize.width/background:getContentSize().width)
    background:setScaleY(winSize.height/background:getContentSize().height)
    self:addChild(background, -999999)
    
    local stage = require("spellgen.view.EditorStage").new()
    self:addChild(stage, -10000)
    
    local topBar = require("spellgen/view/SpellGenTopBar").new()
    topBar:setPosition(0,winSize.height)
    self:addChild(topBar)
    
    local rightPanel = require("spellgen.view.PropertyPanel").new()
    rightPanel:setPosition(winSize.width - rightPanel:getContentSize().width, winSize.height)
    self:addChild(rightPanel)
    
    local timeline = TimelinePanel.new()
    timeline:setAnchorPoint(0,0)
    self:addChild(timeline)
    local CanselResumDo = CanselAndResumDo.new(timeline,topBar)
    self:addChild(CanselResumDo)
    if self._spellChange then
        EditorSpellModel:removeEventListener(EditorSpellModel.EDIT_SPELL_CHANGED, self._spellChange)
    end
    
    local function spellChange(event) 
        stage:loadMap(nil)
        timeline:setEditSpell(EditorSpellModel.getEditSpell())
        rightPanel:setEditSpell(EditorSpellModel.getEditSpell())
    end
    self._spellChange = spellChange
    
    EditorSpellModel:addEventListener(EditorSpellModel.EDIT_SPELL_CHANGED, spellChange)
    
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    BattleMgr.setScene(self)
    
    --用于显示技能名称
    local spellNameLayer = cc.Layer:create()
    self:addChild(spellNameLayer, 100000000)
    self.spellNameLayer = spellNameLayer
    
--    local testsp = filters.FilteredSpriteWithOne:create("ui/battle/skillName1.png")
--    local filterCls = require("src/utils/filter")
--    local filter1 = filterCls.newFilter("ZOOM_BLUR", {1,0.5,0.5})
--    testsp:setFilter(filter1)
--    self:addChild(testsp)
--    testsp:setPosition(500,100)

--    local program = cc.GLProgram:create("shaders/example_ColorBars.vsh", "shaders/example_ColorBars.fsh")
--    program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
--    program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
--    program:link()
--    program:updateUniforms()
--    
--    local sp = cc.Sprite:create("ui/battle/skillName3.png")
--    sp:setPosition(400,400)
--    self:addChild(sp)
--    sp:setGLProgram( program )
--    sp:getGLProgramState():setUniformFloat("u_blurSize",1)
--    sp:getGLProgramState():setUniformFloat("u_originStrength",0.2)
--    sp:getGLProgramState():setUniformFloat("u_expandStrength",1)
--    sp:getGLProgramState():setUniformVec2("u_blurCenter",cc.p(0.5,0.5))
end


return SpellGenerateScene
