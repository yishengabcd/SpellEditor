

local ITween = require("src/scene/battle/mode/ITween")
local ActionEaseType = require("src/scene/battle/mode/ActionEaseType")

------------------------Tween-------------------

local Tween = class("Tween", ITween)

function Tween:ctor(target, fromScale, toScale, duration, tweenType, phase)
    self._target = target
    self._fromScale = fromScale
    self._diff = toScale - fromScale
    self._phase = phase
    Tween.super.ctor(self, duration, tweenType)
end

function Tween:update(time)
    local scale = self._fromScale + self._diff*time
    if self._phase == 1 then
        self._target:getGLProgramState():setUniformFloat("u_expandStrength",1+time*2)
    elseif self._phase == 2 then
        self._target:getGLProgramState():setUniformFloat("u_blurSize",3-time*3)
        self._target:getGLProgramState():setUniformFloat("u_expandStrength",3-time*2)
    elseif self._phase == 3 then
        self._target:getGLProgramState():setUniformFloat("u_opacity",1-time)
    end
    self._target:setScale(scale)
end

------------------------SpellNameEffect-------------------

--技能名称显示效果
local SpellNameEffect = class("SpellNameEffect", function ()
   return cc.Node:create() 
end)

function SpellNameEffect:ctor(name)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    self._container = BattleMgr.getScene().spellNameLayer;
    
--    local effName = ccui.Text:create()
--    effName:setColor(cc.c3b(227,148,58))
--    effName:setString(name)
--    effName:setFontSize(60)
--    effName:setFontName("STHupo")
--    self:addChild(effName)
--    effName:setScale(0.1)
--    effName:setOpacity(0)
--    effName:setSkewY(5)
    
    local program = cc.GLProgram:create("shaders/battle_spell_name.vsh", "shaders/battle_spell_name.fsh")
    program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
    program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
    program:link()
    program:updateUniforms()
    
    local image = cc.Sprite:create("spellname/skillName3.png")
    self:addChild(image)
    image:setScale(0.1)
    image:setOpacity(0)
    image:setGLProgram( program )
    image:getGLProgramState():setUniformFloat("u_blurSize",3)
    image:getGLProgramState():setUniformFloat("u_originStrength",0.2)
    image:getGLProgramState():setUniformFloat("u_expandStrength",1)
    image:getGLProgramState():setUniformVec2("u_blurCenter",cc.p(0.5,0.5))
    image:getGLProgramState():setUniformFloat("u_opacity",1)
    self._image = image
    
    local function onNodeEvent(event)
        local EnterFrameMgr = require("src/scene/battle/manager/EnterFrameMgr")
        if "enter" == event then
--            BattleSpeedMgr.addMember(self)
            EnterFrameMgr.register(self)
        elseif "exit" == event then
--            BattleSpeedMgr.removeMember(self)
            EnterFrameMgr.unregister(self)
            local BattleMgr = require("src/scene/battle/manager/BattleMgr")
            for i, tween in ipairs(self._tweens) do
                BattleMgr.getTweenMgr():remove(tween)
            end
        end
    end

    self:registerScriptHandler(onNodeEvent)
    
    self._elapsed = 0
    self._currentFrame = 0
    self._tweens = {}
end

function SpellNameEffect:enterFrame(dt)
    self._elapsed = self._elapsed + dt
    local reach = math.floor(self._elapsed/0.0333)
    if self._currentFrame < reach then
        self._currentFrame = self._currentFrame + 1
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        if self._currentFrame == 1 then
            local tween = Tween.new(self._image, 0.1, 1, 0.1, ActionEaseType.EaseIn,1)
            BattleMgr.getTweenMgr():addTween(tween)
            table.insert(self._tweens,tween)
        elseif self._currentFrame == 6 then
            local tween = Tween.new(self._image, 1, 0.9, 0.1, ActionEaseType.None,2)
            BattleMgr.getTweenMgr():addTween(tween)
            table.insert(self._tweens,tween)
        elseif self._currentFrame == 28 then
            local tween = Tween.new(self._image, 0.9, 2, 0.1, ActionEaseType.EaseIn,3)
            BattleMgr.getTweenMgr():addTween(tween)
            table.insert(self._tweens,tween)
        elseif self._currentFrame == 38 then
            self:getParent():removeChild(self, true)
        end
    end
end

function SpellNameEffect:show()
    local winSize = cc.Director:getInstance():getVisibleSize()
    self:setPosition(winSize.width/2,winSize.height/2)
    self._container:addChild(self)
end

return SpellNameEffect