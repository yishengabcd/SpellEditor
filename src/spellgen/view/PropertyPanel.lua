
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local LabelValue = require("spellgen.view.LabelValue")
local FrameState = require("src/scene/battle/mode/FrameState")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local CoordSelector = require("spellgen.view.CoordSelector")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local SpellGenTopBar = require("spellgen/view/SpellGenTopBar")
local EffectLevelSelector = require("spellgen.view.EffectLevelSelector")
local BlendFactor = require("src/scene/battle/mode/BlendFactor")

local winSize = cc.Director:getInstance():getVisibleSize()
local panelSize
local labelX = 130
local labelStartY = -70

local PropertyPanel = class("PropertyPanel",function ()
    return cc.Node:create()
end)

function PropertyPanel:ctor()
    self:setAnchorPoint(0, 0)
    
    panelSize = cc.size(306+winSize.width-1136,winSize.height - 150)
    self:setContentSize(panelSize)
    
    local back = ccui.Scale9Sprite:create(cc.rect(33,100,100,60),"ui/right_panel.png")
    back:setAnchorPoint(0,1)
    self:addChild(back, -10000)
    back:setContentSize(panelSize)
    
    local spellName = ccui.Text:create("未选择技能","Airal",14)
    spellName:setAnchorPoint(1,1)
    spellName:setColor(cc.c3b(200,200,200))
    spellName:setPosition(cc.p(panelSize.width - 10, -10))
    self:addChild(spellName)
    
    self._spellName = spellName
    
    local container = cc.Node:create()
    container:setAnchorPoint(0,0)
    self:addChild(container)
    
    self._container = container
    
    EditorSpellModel:addEventListener(EditorSpellModel.FRAME_SELECT, function (event) 
        self:setFrameData(EditorSpellModel.getSelectedKeyFrame())
    end)
    
    EventGlobal:addEventListener("AddAction", function (event) 
        self:setFrameData(EditorSpellModel.getSelectedKeyFrame())
    end)
    
    EditorSpellModel:addEventListener(EditorSpellModel.EDIT_SPELL_CHANGED, function (event) 
        self:setFrameData(nil)
    end)
    
    self:setFrameData(EditorSpellModel.getSelectedKeyFrame())
end

function PropertyPanel:setFrameData(data)
    self._frameData = data
    self._container:removeAllChildren(true)
    
    if data and data.type == FrameState.WEIGHT_KEY_FRAME then
        local action = data.action
        if action then
            self:addBasicElements()
            if action.type == FrameActionType.MOVE_FORWARD then
                self:setMoveForwardFrameView()
            elseif action.type == FrameActionType.PLAY_ACTION then
                self:setMotionFrameView()
            elseif action.type == FrameActionType.PLAY_EFFECT then
                self:setEffectFrameView()
            elseif action.type == FrameActionType.FLY_EFFECT then
                self:setFlyEffectFrameView()
            elseif action.type == FrameActionType.HURT then
                self:setHurtFrameView()
            elseif action.type == FrameActionType.MOVE_BACK then
                self:setMoveBackFrameView()
            elseif action.type == FrameActionType.BLACK_SCREEN then
                self:setBlackScreenFrameView()
            elseif action.type == FrameActionType.PLAY_SOUND then
                self:setSoundFrameView()
            elseif action.type == FrameActionType.SHAKE then
                self:setShakeFrameView()
            elseif action.type == FrameActionType.MOVE_MAP then
                self:setMoveMapView()
            elseif action.type == FrameActionType.ZOOM_MAP then
                self:setZoomMapView()
            elseif action.type == FrameActionType.MAP_RESET then
                self:setMapResetView()
            elseif action.type == FrameActionType.FOCUS then
                self:setFocusView()
            elseif action.type == FrameActionType.JUMP then
                self:setJumpView()
            elseif action.type == FrameActionType.JUMP_BACK then
                self:setJumpBackView()
            elseif action.type == FrameActionType.HIDE_ROLE then
                --do nothing
            elseif action.type == FrameActionType.SPEED_ADJUST then
                self:setSpeedAdjustView()
            elseif action.type == FrameActionType.ADD_AFTERIMAGE then
                --do nothing
            elseif action.type == FrameActionType.REMOVE_AFTERIAGE then
                --do nothing
            elseif action.type == FrameActionType.RISE then
                self:setRiseView()
            elseif action.type == FrameActionType.FALL then
                self:setFallView()
            elseif action.type == FrameActionType.FLY_OUT then
                self:setFlyOutView()
            elseif action.type == FrameActionType.CHANGE_COLOR then
                self:setChangeColorView()
            elseif action.type == FrameActionType.CHANGE_POSITION then
                self:setChangePositionView()
            elseif action.type == FrameActionType.BODY_SEPARATE then
                self:setBodySeparateView()
            elseif action.type == FrameActionType.MISSILE then
                self:setMissileView()
            elseif action.type == FrameActionType.CREATE_COPY then
                self:setCreateCopyView()
            elseif action.type == FrameActionType.REMOVE_COPY then
                self:setRemoveCopyView()
            elseif action.type == FrameActionType.FLY_OFF then
                self:setFlyOffView()
            elseif action.type == FrameActionType.ROTATION then
                self:setRotationView()
            elseif action.type == FrameActionType.ROLE_SHAKE then
                self:setRoleShakeFrameView()
            elseif action.type == FrameActionType.ADD_GHOST_SHADOW then
            --do nothing
            elseif action.type == FrameActionType.REMOVE_GHOST_SHADOW then
            --do nothing
            elseif action.type == FrameActionType.REPLACE_BACKGROUND then
                self:setReplaceBackgroundView()
            elseif action.type == FrameActionType.LEVEL_ADJUST then
                self:setLevelAdjustView()
            elseif action.type == FrameActionType.CALL_ROLE then
                self:setCallRoleView()
            elseif action.type == FrameActionType.REMOVE_ROLE then
                self:setRemoveRoleView()
            elseif action.type == FrameActionType.EFFECT_ADJUST then
                self:setEffectAdjustView()
            elseif action.type == FrameActionType.FINISH then
                --do nothing
            end
        end
    end 
end

function PropertyPanel:addBasicElements()
    local selectIndexTxt = LabelValue.new("帧位置：", LabelValue.TYPE_READ)
    selectIndexTxt:setPosition(labelX, labelStartY)
    self._container:addChild(selectIndexTxt);
    local layer, idx = EditorSpellModel.getSelectedFrame()
    selectIndexTxt:setValue(idx)
    
    local frameIndexTxt = LabelValue.new("关键帧位置：", LabelValue.TYPE_READ)
    frameIndexTxt:setPosition(labelX, selectIndexTxt:getPositionY() - 20)
    self._container:addChild(frameIndexTxt);
    frameIndexTxt:setValue(self._frameData.index)
    
    local actionTypeTxt = LabelValue.new("类型：", LabelValue.TYPE_READ)
    actionTypeTxt:setPosition(labelX, frameIndexTxt:getPositionY() - 20)
    self._container:addChild(actionTypeTxt);
    actionTypeTxt:setValue(SpellGenTopBar.getFrameActionName(self._frameData.action.type))
    
    self._actionTypeTxt = actionTypeTxt
end

--向前移动
function PropertyPanel:setMoveForwardFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.toX = tonumber(self._xEditor:getValue()) or action.toX
        action.toY = tonumber(self._yEditor:getValue()) or action.toY
--        action.duration = tonumber(self._durationEditor:getValue()) or action.duration
        action.coord = self._coordEditor:getValue2()
        action.motion = self._motionNameEditor:getValue()

        BattleMgr.refresh()
    end

--    local durationEditor = LabelValue.new("时间:", LabelValue.TYPE_EDIT,onChange)
--    durationEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
--    self._container:addChild(durationEditor);
--    durationEditor:setValue(action.duration)
--    self._durationEditor = durationEditor
    

    local xEditor = LabelValue.new("toX:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(xEditor);
    xEditor:setValue(action.toX)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("toY:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.toY)
    self._yEditor = yEditor
    
    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, yEditor:getPositionY() - 30)
    self._container:addChild(motionNameEditor);
    motionNameEditor:setValue(action.motion or "")
    self._motionNameEditor = motionNameEditor

    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange)
    coordEditor:setPosition(labelX-13,motionNameEditor:getPositionY() - 35)
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
end

function PropertyPanel:setMoveBackFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.motion = self._motionNameEditor:getValue()
    end

    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(motionNameEditor);
    motionNameEditor:setValue(action.motion or "")
    self._motionNameEditor = motionNameEditor
end

--播放动作
function PropertyPanel:setMotionFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.controlIds = self._controlIdsEditor:getValue()
        action.motion = self._motionNameEditor:getValue()
        action.transition = tonumber(self._transitionEditor:getValue()) or action.transition
        action.playStandWhenEnd = tonumber(self._playStandWhenEndEditor:getValue()) or action.playStandWhenEnd
        action.startFrame = tonumber(self._startFrameEditor:getValue()) or action.startFrame
        action.loop = tonumber(self._loopEditor:getValue()) or action.loop
        BattleMgr.refresh()
    end
    
    local controlIdsEditor = LabelValue.new("控制对象:", LabelValue.TYPE_EDIT,onChange)
    controlIdsEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(controlIdsEditor);
    controlIdsEditor:setValue(action.controlIds)
    self._controlIdsEditor = controlIdsEditor
    
    
    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, controlIdsEditor:getPositionY() - 30)
    self._container:addChild(motionNameEditor);
    motionNameEditor:setValue(action.motion)
    self._motionNameEditor = motionNameEditor


    local transitionEditor = LabelValue.new("过渡帧数:", LabelValue.TYPE_EDIT,onChange)
    transitionEditor:setPosition(labelX-13,motionNameEditor:getPositionY() - 30)
    self._container:addChild(transitionEditor);
    transitionEditor:setValue(action.transition)
    self._transitionEditor = transitionEditor
    
    local playStandWhenEndEditor = LabelValue.new("结束后站立(0或1):", LabelValue.TYPE_EDIT,onChange)
    playStandWhenEndEditor:setPosition(labelX-13,transitionEditor:getPositionY() - 30)
    self._container:addChild(playStandWhenEndEditor);
    playStandWhenEndEditor:setValue(action.playStandWhenEnd)
    self._playStandWhenEndEditor = playStandWhenEndEditor
    
    local startFrameEditor = LabelValue.new("开始帧:", LabelValue.TYPE_EDIT,onChange)
    startFrameEditor:setPosition(labelX-13,playStandWhenEndEditor:getPositionY() - 30)
    self._container:addChild(startFrameEditor);
    startFrameEditor:setValue(action.startFrame or 1)
    self._startFrameEditor = startFrameEditor
    
    local loopEditor = LabelValue.new("循环播放(1是0非):", LabelValue.TYPE_EDIT,onChange)
    loopEditor:setPosition(labelX-13,startFrameEditor:getPositionY() - 30)
    self._container:addChild(loopEditor);
    loopEditor:setValue(action.loop or 0)
    self._loopEditor = loopEditor
    
    local descLabel = ccui.Text:create("说明：控制对象栏在控制分身时使用,填入分身ID,以‘,’分隔，\n如果要同时控制主体和分身，可用空字符代表主体\n如'id1,,id2'或',id1', \n填'-1'表示控制受击者", "Airal", 14)
    descLabel:setColor(cc.c3b(220,220,220))
    descLabel:setAnchorPoint(0,0.5)
    descLabel:setPosition(labelX-90,loopEditor:getPositionY() - 80)
    self._container:addChild(descLabel)
end

--播放特效
function PropertyPanel:setEffectFrameView()
    local action = self._frameData.action
    
    local function onChange(target)
        action.id = tostring(self._idEditor:getValue())
        action.controlIds = self._controlIdsEditor:getValue()
        action.x = tonumber(self._xEditor:getValue()) or action.x
        action.y = tonumber(self._yEditor:getValue()) or action.y
        action.scale = tonumber(self._scaleEditor:getValue()) or action.scale
        action.duration = tonumber(self._durationEditor:getValue()) or action.duration
        action.coord = self._coordEditor:getValue2()
        action.effectLevel = self._levelEditor:getValue2()
        action.effectLevelAddition = tonumber(self._effectLevelAdditionEditor:getValue()) or action.effectLevelAddition
        
        action.effectSpeed = tonumber(self._speedEditor:getValue()) or action.effectSpeed
        action.blendSrc = BlendFactor[self._blendSrcEditor:getValue()] or action.blendSrc
        action.blendDst = BlendFactor[self._blendDstEditor:getValue()] or action.blendDst
        action.rotation = tonumber(self._rotationEditor:getValue()) or action.rotation
        action.bodyLocation = tonumber(self._bodyLocationEditor:getValue()) or action.bodyLocation
        action.showInMap = tonumber(self._showInMapEditor:getValue()) or action.showInMap
        action.flipX = tonumber(self._flipXEditor:getValue()) or action.flipX
        
        BattleMgr.refresh()
    end
    
    local idEditor = LabelValue.new("特效ID:", LabelValue.TYPE_EDIT,onChange)
    idEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(idEditor);
    idEditor:setValue(action.id)
    self._idEditor = idEditor
    
    local controlIdsEditor = LabelValue.new("控制对象:", LabelValue.TYPE_EDIT,onChange)
    controlIdsEditor:setPosition(labelX-13, idEditor:getPositionY() - 30)
    self._container:addChild(controlIdsEditor);
    controlIdsEditor:setValue(action.controlIds)
    self._controlIdsEditor = controlIdsEditor
    
    local effectNameTxt = LabelValue.new("技能名称：", LabelValue.TYPE_READ)
    effectNameTxt:setPosition(labelX, controlIdsEditor:getPositionY() - 30)
    self._container:addChild(effectNameTxt);
    effectNameTxt:setValue(action.effect)
    self._effectNameTxt = effectNameTxt
    
    local xEditor = LabelValue.new("x:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,effectNameTxt:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.x)
    self._xEditor = xEditor
    
    local yEditor = LabelValue.new("y:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.y)
    self._yEditor = yEditor
    
    local scaleEditor = LabelValue.new("scale:", LabelValue.TYPE_EDIT,onChange)
    scaleEditor:setPosition(labelX-13,yEditor:getPositionY() - 30)
    self._container:addChild(scaleEditor);
    scaleEditor:setValue(action.scale)
    self._scaleEditor = scaleEditor
    
    local rotationEditor = LabelValue.new("角度(0-360):", LabelValue.TYPE_EDIT,onChange)
    rotationEditor:setPosition(labelX-13,scaleEditor:getPositionY() - 30)
    self._container:addChild(rotationEditor);
    rotationEditor:setValue(action.rotation)
    self._rotationEditor = rotationEditor
    
    local speedEditor = LabelValue.new("特效速度:", LabelValue.TYPE_EDIT,onChange)
    speedEditor:setPosition(labelX-13,rotationEditor:getPositionY() - 30)
    self._container:addChild(speedEditor);
    speedEditor:setValue(action.effectSpeed or 1)
    self._speedEditor = speedEditor
    
    local durationEditor = LabelValue.new("播放时间(秒):", LabelValue.TYPE_EDIT,onChange)
    durationEditor:setPosition(labelX-13,speedEditor:getPositionY() - 30)
    self._container:addChild(durationEditor);
    durationEditor:setValue(action.duration)
    self._durationEditor = durationEditor
    
    local bodyLocationEditor = LabelValue.new("bodyLocation(1是0非):", LabelValue.TYPE_EDIT,onChange)
    bodyLocationEditor:setPosition(labelX-13,durationEditor:getPositionY() - 30)
    self._container:addChild(bodyLocationEditor);
    bodyLocationEditor:setValue(action.bodyLocation or 0)
    self._bodyLocationEditor = bodyLocationEditor
    
    local showInMapEditor = LabelValue.new("showInMap(1是0非):", LabelValue.TYPE_EDIT,onChange)
    showInMapEditor:setPosition(labelX-13,bodyLocationEditor:getPositionY() - 30)
    self._container:addChild(showInMapEditor);
    showInMapEditor:setValue(action.showInMap or 0)
    self._showInMapEditor = showInMapEditor
    
    local effectLevelAdditionEditor = LabelValue.new("层次微调(0-100):", LabelValue.TYPE_EDIT,onChange)
    effectLevelAdditionEditor:setPosition(labelX-13,showInMapEditor:getPositionY() - 30)
    self._container:addChild(effectLevelAdditionEditor);
    effectLevelAdditionEditor:setValue(action.effectLevelAddition or 0)
    self._effectLevelAdditionEditor = effectLevelAdditionEditor
    
    local flipXEditor = LabelValue.new("水平翻转(1是0非):", LabelValue.TYPE_EDIT,onChange)
    flipXEditor:setPosition(labelX-13,effectLevelAdditionEditor:getPositionY() - 30)
    self._container:addChild(flipXEditor);
    flipXEditor:setValue(action.flipX or 0)
    self._flipXEditor = flipXEditor
    
    
    
    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange)
    coordEditor:setPosition(labelX + 280,controlIdsEditor:getPositionY())
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
    
    local levelEditor = LabelValue.new("层次:", LabelValue.TYPE_EFFECT_LEVEL,onChange)
    levelEditor:setPosition(coordEditor:getPositionX(),coordEditor:getPositionY() - 35)
    self._container:addChild(levelEditor);
    levelEditor:setValue(EffectLevelSelector.getStringByType(action.effectLevel))
    self._levelEditor = levelEditor
    
    local blendSrcEditor = LabelValue.new("混合模式src:", LabelValue.TYPE_BLEND_FACTOR,onChange,true)
    blendSrcEditor:setPosition(coordEditor:getPositionX(),levelEditor:getPositionY() - 35)
    self._container:addChild(blendSrcEditor);
    blendSrcEditor:setValue(BlendFactor.getKeyByValue(action.blendSrc))
    self._blendSrcEditor = blendSrcEditor
    
    local blendDstEditor = LabelValue.new("混合模式Dst:", LabelValue.TYPE_BLEND_FACTOR,onChange,false)
    blendDstEditor:setPosition(coordEditor:getPositionX(),blendSrcEditor:getPositionY() - 35)
    self._container:addChild(blendDstEditor);
    blendDstEditor:setValue(BlendFactor.getKeyByValue(action.blendDst))
    self._blendDstEditor = blendDstEditor
end

--飞行特效
function PropertyPanel:setFlyEffectFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.fromCoord = self._fromCoordEditor:getValue2()
        action.fromX = tonumber(self._fromXEditor:getValue()) or action.fromX
        action.fromY = tonumber(self._fromYEditor:getValue()) or action.fromY
        action.fromScale = tonumber(self._fromScaleEditor:getValue()) or action.fromScale

        action.toCoord = self._toCoordEditor:getValue2()
        action.toX = tonumber(self._toXEditor:getValue()) or action.toX
        action.toY = tonumber(self._toYEditor:getValue()) or action.toY
        action.toScale = tonumber(self._toScaleEditor:getValue()) or action.toScale
        
        action.effectSpeed = tonumber(self._speedEditor:getValue()) or action.effectSpeed
        
        action.blendSrc = BlendFactor[self._blendSrcEditor:getValue()] or action.blendSrc
        action.blendDst = BlendFactor[self._blendDstEditor:getValue()] or action.blendDst
        
        action.toBodyLocation = tonumber(self._bodyLocationEditor:getValue()) or action.toBodyLocation

--        action.duration = tonumber(self._durationEditor:getValue()) or action.duration
--        action.effect = self._effectNameTxt:getValue()

        BattleMgr.refresh()
    end

    local effectNameTxt = LabelValue.new("技能名称：", LabelValue.TYPE_READ)
    effectNameTxt:setPosition(labelX, self._actionTypeTxt:getPositionY() - 23)
    self._container:addChild(effectNameTxt);
    effectNameTxt:setValue(action.effect)
    self._effectNameTxt = effectNameTxt
    
--    local durationEditor = LabelValue.new("持续时间:", LabelValue.TYPE_EDIT,onChange)
--    durationEditor:setPosition(labelX-13, effectNameTxt:getPositionY() - 30)
--    self._container:addChild(durationEditor);
--    durationEditor:setValue(action.duration)
--    self._durationEditor = durationEditor

    local fromXEditor = LabelValue.new("fromX:", LabelValue.TYPE_EDIT,onChange)
    fromXEditor:setPosition(labelX-13-50,effectNameTxt:getPositionY() - 30)
    self._container:addChild(fromXEditor);
    fromXEditor:setValue(action.fromX)
    self._fromXEditor = fromXEditor

    local fromYEditor = LabelValue.new("fromY:", LabelValue.TYPE_EDIT,onChange)
    fromYEditor:setPosition(labelX-13-50,fromXEditor:getPositionY() - 30)
    self._container:addChild(fromYEditor);
    fromYEditor:setValue(action.fromY)
    self._fromYEditor = fromYEditor

    local fromScaleEditor = LabelValue.new("fromScale:", LabelValue.TYPE_EDIT,onChange)
    fromScaleEditor:setPosition(labelX-13-50,fromYEditor:getPositionY() - 30)
    self._container:addChild(fromScaleEditor);
    fromScaleEditor:setValue(action.fromScale)
    self._fromScaleEditor = fromScaleEditor

    local toXEditor = LabelValue.new("toX:", LabelValue.TYPE_EDIT,onChange)
    toXEditor:setPosition(labelX-13-50,fromScaleEditor:getPositionY() - 35)
    self._container:addChild(toXEditor);
    toXEditor:setValue(action.toX)
    self._toXEditor = toXEditor

    local toYEditor = LabelValue.new("toY:", LabelValue.TYPE_EDIT,onChange)
    toYEditor:setPosition(labelX-13-50,toXEditor:getPositionY() - 30)
    self._container:addChild(toYEditor);
    toYEditor:setValue(action.toY)
    self._toYEditor = toYEditor

    local toScaleEditor = LabelValue.new("toScale:", LabelValue.TYPE_EDIT,onChange)
    toScaleEditor:setPosition(labelX-13-50,toYEditor:getPositionY() - 30)
    self._container:addChild(toScaleEditor);
    toScaleEditor:setValue(action.toScale)
    self._toScaleEditor = toScaleEditor
    
    local speedEditor = LabelValue.new("特效速度:", LabelValue.TYPE_EDIT,onChange)
    speedEditor:setPosition(labelX-13-50,toScaleEditor:getPositionY() - 30)
    self._container:addChild(speedEditor);
    speedEditor:setValue(action.effectSpeed or 1)
    self._speedEditor = speedEditor
    
    local bodyLocationEditor = LabelValue.new("bodyLocation(1是0非):", LabelValue.TYPE_EDIT,onChange)
    bodyLocationEditor:setPosition(labelX-13,speedEditor:getPositionY() - 30)
    self._container:addChild(bodyLocationEditor);
    bodyLocationEditor:setValue(action.toBodyLocation or 0)
    self._bodyLocationEditor = bodyLocationEditor
    
    local fromCoordEditor = LabelValue.new("from参考点:", LabelValue.TYPE_COORD,onChange)
    fromCoordEditor:setPosition(labelX-13,bodyLocationEditor:getPositionY() - 35)
    self._container:addChild(fromCoordEditor);
    fromCoordEditor:setValue(CoordSelector.getStringByType(action.fromCoord))
    self._fromCoordEditor = fromCoordEditor

    local toCoordEditor = LabelValue.new("to参考点:", LabelValue.TYPE_COORD,onChange)
    toCoordEditor:setPosition(labelX-13,fromCoordEditor:getPositionY() - 35)
    self._container:addChild(toCoordEditor);
    toCoordEditor:setValue(CoordSelector.getStringByType(action.toCoord))
    self._toCoordEditor = toCoordEditor
    
    local blendSrcEditor = LabelValue.new("混合模式src:", LabelValue.TYPE_BLEND_FACTOR,onChange,true)
    blendSrcEditor:setPosition(labelX-13,toCoordEditor:getPositionY() - 35)
    self._container:addChild(blendSrcEditor);
    blendSrcEditor:setValue(BlendFactor.getKeyByValue(action.blendSrc))
    self._blendSrcEditor = blendSrcEditor

    local blendDstEditor = LabelValue.new("混合模式Dst:", LabelValue.TYPE_BLEND_FACTOR,onChange,false)
    blendDstEditor:setPosition(labelX-13,blendSrcEditor:getPositionY() - 35)
    self._container:addChild(blendDstEditor);
    blendDstEditor:setValue(BlendFactor.getKeyByValue(action.blendDst))
    self._blendDstEditor = blendDstEditor
end

--受击特效
function PropertyPanel:setHurtFrameView()
    local action = self._frameData.action

    local function onChange(target)
    
        action.motion = self._motionNameEditor:getValue()
        action.playStandWhenEnd = tonumber(self._playStandWhenEndEditor:getValue()) or action.playStandWhenEnd
        action.startFrame = tonumber(self._startFrameEditor:getValue()) or action.startFrame
        action.bloodX = tonumber(self._bloodXEditor:getValue()) or action.bloodX
        action.bloodY = tonumber(self._bloodYEditor:getValue()) or action.bloodY
        
        if self._effectNameTxt:getValue() ~= "" then
            action.x = tonumber(self._xEditor:getValue()) or action.x
            action.y = tonumber(self._yEditor:getValue()) or action.y
            action.scale = tonumber(self._scaleEditor:getValue()) or action.scale
            action.coord = self._coordEditor:getValue2()
            action.effectLevel = self._levelEditor:getValue2()
            action.effectSpeed = tonumber(self._speedEditor:getValue()) or action.effectSpeed
            action.blendSrc = BlendFactor[self._blendSrcEditor:getValue()] or action.blendSrc
            action.blendDst = BlendFactor[self._blendDstEditor:getValue()] or action.blendDst
            
        end
        BattleMgr.refresh()
    end


    local effectNameTxt = LabelValue.new("技能名称：", LabelValue.TYPE_READ)
    effectNameTxt:setPosition(labelX, self._actionTypeTxt:getPositionY() - 23)
    self._container:addChild(effectNameTxt);
    effectNameTxt:setValue(action.effect)
    self._effectNameTxt = effectNameTxt
    
    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, effectNameTxt:getPositionY() - 30)
    self._container:addChild(motionNameEditor);
    motionNameEditor:setValue(action.motion)
    self._motionNameEditor = motionNameEditor

    local xEditor = LabelValue.new("x:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,motionNameEditor:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.x)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("y:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.y)
    self._yEditor = yEditor

    local scaleEditor = LabelValue.new("scale:", LabelValue.TYPE_EDIT,onChange)
    scaleEditor:setPosition(labelX-13,yEditor:getPositionY() - 30)
    self._container:addChild(scaleEditor);
    scaleEditor:setValue(action.scale)
    self._scaleEditor = scaleEditor
    
    local speedEditor = LabelValue.new("特效速度:", LabelValue.TYPE_EDIT,onChange)
    speedEditor:setPosition(labelX-13,scaleEditor:getPositionY() - 30)
    self._container:addChild(speedEditor);
    speedEditor:setValue(action.effectSpeed or 1)
    self._speedEditor = speedEditor
    
    local playStandWhenEndEditor = LabelValue.new("结束后站立(0或1):", LabelValue.TYPE_EDIT,onChange)
    playStandWhenEndEditor:setPosition(labelX-13,speedEditor:getPositionY() - 30)
    self._container:addChild(playStandWhenEndEditor);
    playStandWhenEndEditor:setValue(action.playStandWhenEnd)
    self._playStandWhenEndEditor = playStandWhenEndEditor
    
    local startFrameEditor = LabelValue.new("开始帧:", LabelValue.TYPE_EDIT,onChange)
    startFrameEditor:setPosition(labelX-13,playStandWhenEndEditor:getPositionY() - 30)
    self._container:addChild(startFrameEditor);
    startFrameEditor:setValue(action.startFrame or 1)
    self._startFrameEditor = startFrameEditor
    
    local bloodXEditor = LabelValue.new("掉血位置X:", LabelValue.TYPE_EDIT,onChange)
    bloodXEditor:setPosition(labelX-13,startFrameEditor:getPositionY() - 30)
    self._container:addChild(bloodXEditor);
    bloodXEditor:setValue(action.bloodX or 0)
    self._bloodXEditor = bloodXEditor
    
    local bloodYEditor = LabelValue.new("掉血位置Y:", LabelValue.TYPE_EDIT,onChange)
    bloodYEditor:setPosition(labelX-13,bloodXEditor:getPositionY() - 30)
    self._container:addChild(bloodYEditor);
    bloodYEditor:setValue(action.bloodY or 0)
    self._bloodYEditor = bloodYEditor
    
    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange)
    coordEditor:setPosition(labelX-13+300,effectNameTxt:getPositionY())
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
    
    local levelEditor = LabelValue.new("层次:", LabelValue.TYPE_EFFECT_LEVEL,onChange)
    levelEditor:setPosition(coordEditor:getPositionX(),coordEditor:getPositionY() - 35)
    self._container:addChild(levelEditor);
    levelEditor:setValue(EffectLevelSelector.getStringByType(action.effectLevel))
    self._levelEditor = levelEditor
    
    local blendSrcEditor = LabelValue.new("混合模式src:", LabelValue.TYPE_BLEND_FACTOR,onChange,true)
    blendSrcEditor:setPosition(coordEditor:getPositionX(),levelEditor:getPositionY() - 35)
    self._container:addChild(blendSrcEditor);
    blendSrcEditor:setValue(BlendFactor.getKeyByValue(action.blendSrc))
    self._blendSrcEditor = blendSrcEditor

    local blendDstEditor = LabelValue.new("混合模式Dst:", LabelValue.TYPE_BLEND_FACTOR,onChange,false)
    blendDstEditor:setPosition(coordEditor:getPositionX(),blendSrcEditor:getPositionY() - 35)
    self._container:addChild(blendDstEditor);
    blendDstEditor:setValue(BlendFactor.getKeyByValue(action.blendDst))
    self._blendDstEditor = blendDstEditor
    
end

--播放音效
function PropertyPanel:setSoundFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.sound = self._soundEditor:getValue()
    end

    local soundEditor = LabelValue.new("音效名称:", LabelValue.TYPE_EDIT,onChange)
    soundEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(soundEditor);
    soundEditor:setValue(action.sound)
    self._soundEditor = soundEditor
end


--震屏
function PropertyPanel:setShakeFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.strength = tonumber(self._strengthEditor:getValue()) or action.strength
--        action.duration = tonumber(self._durationEditor:getValue()) or action.duration
        action.decay = tonumber(self._decayEditor:getValue()) or action.decay
        
        BattleMgr.refresh()
    end

    local strengthEditor = LabelValue.new("震幅:", LabelValue.TYPE_EDIT,onChange)
    strengthEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(strengthEditor);
    strengthEditor:setValue(action.strength)
    self._strengthEditor = strengthEditor
    
--    local durationEditor = LabelValue.new("持续时间:", LabelValue.TYPE_EDIT,onChange)
--    durationEditor:setPosition(labelX-13, strengthEditor:getPositionY() - 30)
--    self._container:addChild(durationEditor);
--    durationEditor:setValue(action.duration)
--    self._durationEditor = durationEditor
    
    local decayEditor = LabelValue.new("衰减系数(0-1):", LabelValue.TYPE_EDIT,onChange)
    decayEditor:setPosition(labelX-13, strengthEditor:getPositionY() - 30)
    self._container:addChild(decayEditor);
    decayEditor:setValue(action.decay)
    self._decayEditor = decayEditor
end

--黑屏
function PropertyPanel:setBlackScreenFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.alpha = tonumber(self._alphaEditor:getValue()) or action.alpha
        action.toAlpha = tonumber(self._toAlphaEditor:getValue()) or action.toAlpha
        action.colorR = tonumber(self._colorREditor:getValue()) or action.colorR
        action.colorG = tonumber(self._colorGEditor:getValue()) or action.colorG
        action.colorB = tonumber(self._colorBEditor:getValue()) or action.colorB
        
        BattleMgr.refresh()
    end

    local alphaEditor = LabelValue.new("fromAlpha(1-255):", LabelValue.TYPE_EDIT,onChange)
    alphaEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(alphaEditor);
    alphaEditor:setValue(action.alpha)
    self._alphaEditor = alphaEditor
    
    local toAlphaEditor = LabelValue.new("toAlpha(1-255):", LabelValue.TYPE_EDIT,onChange)
    toAlphaEditor:setPosition(labelX-13,alphaEditor:getPositionY() - 30)
    self._container:addChild(toAlphaEditor);
    toAlphaEditor:setValue(action.toAlpha or action.alpha)
    self._toAlphaEditor = toAlphaEditor

    local colorREditor = LabelValue.new("R(0-255):", LabelValue.TYPE_EDIT,onChange)
    colorREditor:setPosition(labelX-13, toAlphaEditor:getPositionY() - 30)
    self._container:addChild(colorREditor);
    colorREditor:setValue(action.colorR)
    self._colorREditor = colorREditor

    local colorGEditor = LabelValue.new("G(0-255):", LabelValue.TYPE_EDIT,onChange)
    colorGEditor:setPosition(labelX-13, colorREditor:getPositionY() - 30)
    self._container:addChild(colorGEditor);
    colorGEditor:setValue(action.colorG)
    self._colorGEditor = colorGEditor

    local colorBEditor = LabelValue.new("B(0-255):", LabelValue.TYPE_EDIT,onChange)
    colorBEditor:setPosition(labelX-13, colorGEditor:getPositionY() - 30)
    self._container:addChild(colorBEditor);
    colorBEditor:setValue(action.colorB)
    self._colorBEditor = colorBEditor
end


--移动地图
function PropertyPanel:setMoveMapView()
    local action = self._frameData.action

    local function onChange(target)
        action.offsetX = tonumber(self._offsetXEditor:getValue()) or action.offsetX
        action.tween = self._tweenEditor:getValue()
        action.forceCenter = tonumber(self._forceCenterEditor:getValue()) or action.forceCenter

        BattleMgr.refresh()
    end

    local offsetXEditor = LabelValue.new("移动距离(x):", LabelValue.TYPE_EDIT,onChange)
    offsetXEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(offsetXEditor);
    offsetXEditor:setValue(action.offsetX)
    self._offsetXEditor = offsetXEditor
    
    local forceCenterEditor = LabelValue.new("强制居中(1是0非):", LabelValue.TYPE_EDIT,onChange)
    forceCenterEditor:setPosition(labelX-13,offsetXEditor:getPositionY() - 30)
    self._container:addChild(forceCenterEditor);
    forceCenterEditor:setValue(action.forceCenter or 0)
    self._forceCenterEditor = forceCenterEditor
    
    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13,forceCenterEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor
end

--缩放地图
function PropertyPanel:setZoomMapView()
    local action = self._frameData.action

    local function onChange(target)
        action.zoom = tonumber(self._zoomEditor:getValue()) or action.zoom
        action.centerX = tonumber(self._xEditor:getValue()) or action.centerX
        action.centerY = tonumber(self._yEditor:getValue()) or action.centerY
        action.coord = self._coordEditor:getValue2()
        action.tween = self._tweenEditor:getValue()
        action.forceCenter = tonumber(self._forceCenterEditor:getValue()) or action.forceCenter
        
        BattleMgr.refresh()
    end

    local zoomEditor = LabelValue.new("缩放比率:", LabelValue.TYPE_EDIT,onChange)
    zoomEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(zoomEditor);
    zoomEditor:setValue(action.zoom)
    self._zoomEditor = zoomEditor
    
    local xEditor = LabelValue.new("缩放点x:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,zoomEditor:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.centerX)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("缩放点y:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.centerY)
    self._yEditor = yEditor
    
    local forceCenterEditor = LabelValue.new("强制居中(1是0非):", LabelValue.TYPE_EDIT,onChange)
    forceCenterEditor:setPosition(labelX-13,yEditor:getPositionY() - 30)
    self._container:addChild(forceCenterEditor);
    forceCenterEditor:setValue(action.forceCenter or 0)
    self._forceCenterEditor = forceCenterEditor


    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange, {filterCoord = 1})
    coordEditor:setPosition(labelX-13,forceCenterEditor:getPositionY() - 35)
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
    
    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13,coordEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor
    
end

--地图还原
function PropertyPanel:setMapResetView()
    local action = self._frameData.action

    local function onChange(target)
        action.tween = self._tweenEditor:getValue()
        action.forceCenter = tonumber(self._forceCenterEditor:getValue()) or action.forceCenter
    end
    
    local forceCenterEditor = LabelValue.new("强制居中(1是0非):", LabelValue.TYPE_EDIT,onChange)
    forceCenterEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(forceCenterEditor);
    forceCenterEditor:setValue(action.forceCenter or 0)
    self._forceCenterEditor = forceCenterEditor

    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13,forceCenterEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor

end

--聚焦
function PropertyPanel:setFocusView()
    local action = self._frameData.action

    local function onChange(target)
        action.tween = self._tweenEditor:getValue()
        action.zoom = tonumber(self._zoomEditor:getValue()) or action.zoom
--        action.forceCenter = tonumber(self._forceCenterEditor:getValue()) or action.forceCenter
        action.toX = tonumber(self._xEditor:getValue()) or action.toX
        action.toY = tonumber(self._yEditor:getValue()) or action.toY
        action.coord = self._coordEditor:getValue2()
        action.forceCenter = tonumber(self._forceCenterEditor:getValue()) or action.forceCenter
        
        BattleMgr.refresh()
    end
    
    local zoomEditor = LabelValue.new("缩放比率:", LabelValue.TYPE_EDIT,onChange)
    zoomEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(zoomEditor);
    zoomEditor:setValue(action.zoom)
    self._zoomEditor = zoomEditor
    
    local xEditor = LabelValue.new("toX:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,zoomEditor:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.toX)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("toY:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.toY)
    self._yEditor = yEditor
    
    local forceCenterEditor = LabelValue.new("强制居中(1是0非):", LabelValue.TYPE_EDIT,onChange)
    forceCenterEditor:setPosition(labelX-13,yEditor:getPositionY() - 30)
    self._container:addChild(forceCenterEditor);
    forceCenterEditor:setValue(action.forceCenter or 0)
    self._forceCenterEditor = forceCenterEditor

    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange, {filterCoord = 2})
    coordEditor:setPosition(labelX-13,forceCenterEditor:getPositionY() - 35)
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
    
    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13,coordEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor

end

--跳跃
function PropertyPanel:setJumpView()
    local action = self._frameData.action

    local function onChange(target)
        action.toX = tonumber(self._xEditor:getValue()) or action.toX
        action.toY = tonumber(self._yEditor:getValue()) or action.toY
        action.coord = self._coordEditor:getValue2()
        action.startFrame = tonumber(self._startFrameEditor:getValue()) or action.startFrame
        action.takeOffPoint = tonumber(self._takeOffPointEditor:getValue()) or action.takeOffPoint
        action.motion = self._motionNameEditor:getValue()

        BattleMgr.refresh()
    end
    
    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(motionNameEditor);
    motionNameEditor:setValue(action.motion)
    self._motionNameEditor = motionNameEditor
    
    
    local xEditor = LabelValue.new("toX:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,motionNameEditor:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.toX)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("toY:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.toY)
    self._yEditor = yEditor
    
    local takeOffPointEditor = LabelValue.new("起跳点(毫秒):", LabelValue.TYPE_EDIT,onChange)
    takeOffPointEditor:setPosition(labelX-13,yEditor:getPositionY() - 30)
    self._container:addChild(takeOffPointEditor);
    takeOffPointEditor:setValue(action.takeOffPoint)
    self._takeOffPointEditor = takeOffPointEditor 
    
    local startFrameEditor = LabelValue.new("开始帧:", LabelValue.TYPE_EDIT,onChange)
    startFrameEditor:setPosition(labelX-13,takeOffPointEditor:getPositionY() - 30)
    self._container:addChild(startFrameEditor);
    startFrameEditor:setValue(action.startFrame or 1)
    self._startFrameEditor = startFrameEditor

    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange)
    coordEditor:setPosition(labelX-13,startFrameEditor:getPositionY() - 35)
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
end

--跳回原地
function PropertyPanel:setJumpBackView()
    local action = self._frameData.action

    local function onChange(target)
        action.startFrame = tonumber(self._startFrameEditor:getValue()) or action.startFrame
        action.takeOffPoint = tonumber(self._takeOffPointEditor:getValue()) or action.takeOffPoint
--        action.motion = self._motionNameEditor:getValue()

        BattleMgr.refresh()
    end


    local takeOffPointEditor = LabelValue.new("起跳点(毫秒):", LabelValue.TYPE_EDIT,onChange)
    takeOffPointEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(takeOffPointEditor);
    takeOffPointEditor:setValue(action.takeOffPoint)
    self._takeOffPointEditor = takeOffPointEditor 

    local startFrameEditor = LabelValue.new("开始帧:", LabelValue.TYPE_EDIT,onChange)
    startFrameEditor:setPosition(labelX-13,takeOffPointEditor:getPositionY() - 30)
    self._container:addChild(startFrameEditor);
    startFrameEditor:setValue(action.startFrame or 1)
    self._startFrameEditor = startFrameEditor
end

--速度调节
function PropertyPanel:setSpeedAdjustView()
    local action = self._frameData.action

    local function onChange(target)
        action.fromSpeed = tonumber(self._fromSpeedEditor:getValue()) or action.fromSpeed
        action.toSpeed = tonumber(self._toSpeedEditor:getValue()) or action.toSpeed
        action.tween = self._tweenEditor:getValue()

        BattleMgr.refresh()
    end

    local fromSpeedEditor = LabelValue.new("fromSpeed:", LabelValue.TYPE_EDIT,onChange)
    fromSpeedEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(fromSpeedEditor);
    fromSpeedEditor:setValue(action.fromSpeed)
    self._fromSpeedEditor = fromSpeedEditor

    local toSpeedEditor = LabelValue.new("toSpeed:", LabelValue.TYPE_EDIT,onChange)
    toSpeedEditor:setPosition(labelX-13,fromSpeedEditor:getPositionY() - 30)
    self._container:addChild(toSpeedEditor);
    toSpeedEditor:setValue(action.toSpeed)
    self._toSpeedEditor = toSpeedEditor
    
    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13,toSpeedEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor
end

--上升
function PropertyPanel:setRiseView()
    local action = self._frameData.action

    local function onChange(target)
        action.controlIds = self._controlIdsEditor:getValue()
        action.targetType = tonumber(self._targetTypeEditor:getValue()) or action.targetType
        action.height = tonumber(self._heightEditor:getValue()) or action.height
        action.tween = self._tweenEditor:getValue()
        
        BattleMgr.refresh()
    end

    local controlIdsEditor = LabelValue.new("控制对象:", LabelValue.TYPE_EDIT,onChange)
    controlIdsEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(controlIdsEditor);
    controlIdsEditor:setValue(action.controlIds)
    self._controlIdsEditor = controlIdsEditor
    
    local targetTypeEditor = LabelValue.new("目标(1攻2受):", LabelValue.TYPE_EDIT,onChange)
    targetTypeEditor:setPosition(labelX-13, controlIdsEditor:getPositionY() - 30)
    self._container:addChild(targetTypeEditor);
    targetTypeEditor:setValue(action.targetType)
    self._targetTypeEditor = targetTypeEditor

    local heightEditor = LabelValue.new("高度:", LabelValue.TYPE_EDIT,onChange)
    heightEditor:setPosition(labelX-13,targetTypeEditor:getPositionY() - 30)
    self._container:addChild(heightEditor);
    heightEditor:setValue(action.height)
    self._heightEditor = heightEditor

    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13,heightEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor
end

--下落
function PropertyPanel:setFallView()
    local action = self._frameData.action

    local function onChange(target)
        action.controlIds = self._controlIdsEditor:getValue()
        action.targetType = tonumber(self._targetTypeEditor:getValue()) or action.targetType
        action.height = tonumber(self._heightEditor:getValue()) or action.height
        action.tween = self._tweenEditor:getValue()
    end
    
    local controlIdsEditor = LabelValue.new("控制对象:", LabelValue.TYPE_EDIT,onChange)
    controlIdsEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(controlIdsEditor);
    controlIdsEditor:setValue(action.controlIds)
    self._controlIdsEditor = controlIdsEditor

    local targetTypeEditor = LabelValue.new("目标(1攻2受):", LabelValue.TYPE_EDIT,onChange)
    targetTypeEditor:setPosition(labelX-13, controlIdsEditor:getPositionY() - 30)
    self._container:addChild(targetTypeEditor);
    targetTypeEditor:setValue(action.targetType)
    self._targetTypeEditor = targetTypeEditor

    local heightEditor = LabelValue.new("高度:", LabelValue.TYPE_EDIT,onChange)
    heightEditor:setPosition(labelX-13,targetTypeEditor:getPositionY() - 30)
    self._container:addChild(heightEditor);
    heightEditor:setValue(action.height)
    self._heightEditor = heightEditor
    
    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13,heightEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor
end

--飞出
function PropertyPanel:setFlyOutView()
    local action = self._frameData.action

    local function onChange(target)
        action.targetType = tonumber(self._targetTypeEditor:getValue()) or action.targetType
        action.direction = tonumber(self._directionEditor:getValue()) or action.direction
        action.gravity = tonumber(self._gravityEditor:getValue()) or action.gravity
        action.speed = tonumber(self._speedEditor:getValue()) or action.speed
        action.friction = tonumber(self._frictionEditor:getValue()) or action.friction
        action.testHeight = tonumber(self._testHeightEditor:getValue()) or action.testHeight
        
        BattleMgr.refresh()
    end

    local targetTypeEditor = LabelValue.new("目标(1攻2受):", LabelValue.TYPE_EDIT,onChange)
    targetTypeEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(targetTypeEditor);
    targetTypeEditor:setValue(action.targetType)
    self._targetTypeEditor = targetTypeEditor

    local directionEditor = LabelValue.new("方向(0-360):", LabelValue.TYPE_EDIT,onChange)
    directionEditor:setPosition(labelX-13,targetTypeEditor:getPositionY() - 30)
    self._container:addChild(directionEditor);
    directionEditor:setValue(action.direction)
    self._directionEditor = directionEditor
    
    local speedEditor = LabelValue.new("速度:", LabelValue.TYPE_EDIT,onChange)
    speedEditor:setPosition(labelX-13,directionEditor:getPositionY() - 30)
    self._container:addChild(speedEditor);
    speedEditor:setValue(action.speed)
    self._speedEditor = speedEditor
    
    local gravityEditor = LabelValue.new("重力加速度系数:", LabelValue.TYPE_EDIT,onChange)
    gravityEditor:setPosition(labelX-13,speedEditor:getPositionY() - 30)
    self._container:addChild(gravityEditor);
    gravityEditor:setValue(action.gravity)
    self._gravityEditor = gravityEditor
    
    local frictionEditor = LabelValue.new("摩擦力:", LabelValue.TYPE_EDIT,onChange)
    frictionEditor:setPosition(labelX-13,gravityEditor:getPositionY() - 30)
    self._container:addChild(frictionEditor);
    frictionEditor:setValue(action.friction)
    self._frictionEditor = frictionEditor
    
    local testHeightEditor = LabelValue.new("测试高度:", LabelValue.TYPE_EDIT,onChange)
    testHeightEditor:setPosition(labelX-13,frictionEditor:getPositionY() - 30)
    self._container:addChild(testHeightEditor);
    testHeightEditor:setValue(action.testHeight)
    self._testHeightEditor = testHeightEditor
    
end

--改变颜色
function PropertyPanel:setChangeColorView()
    local action = self._frameData.action

    local function onChange(target)
--        action.controlIds = self._controlIdsEditor:getValue()
        action.colorR = tonumber(self._colorREditor:getValue()) or action.colorR
        action.colorG = tonumber(self._colorGEditor:getValue()) or action.colorG
        action.colorB = tonumber(self._colorBEditor:getValue()) or action.colorB

        BattleMgr.refresh()
    end
    
--    local controlIdsEditor = LabelValue.new("控制对象:", LabelValue.TYPE_EDIT,onChange)
--    controlIdsEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
--    self._container:addChild(controlIdsEditor);
--    controlIdsEditor:setValue(action.controlIds)
--    self._controlIdsEditor = controlIdsEditor

    local colorREditor = LabelValue.new("R(0-255):", LabelValue.TYPE_EDIT,onChange)
    colorREditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(colorREditor);
    colorREditor:setValue(action.colorR)
    self._colorREditor = colorREditor

    local colorGEditor = LabelValue.new("G(0-255):", LabelValue.TYPE_EDIT,onChange)
    colorGEditor:setPosition(labelX-13, colorREditor:getPositionY() - 30)
    self._container:addChild(colorGEditor);
    colorGEditor:setValue(action.colorG)
    self._colorGEditor = colorGEditor

    local colorBEditor = LabelValue.new("B(0-255):", LabelValue.TYPE_EDIT,onChange)
    colorBEditor:setPosition(labelX-13, colorGEditor:getPositionY() - 30)
    self._container:addChild(colorBEditor);
    colorBEditor:setValue(action.colorB)
    self._colorBEditor = colorBEditor
    
    local descLabel = ccui.Text:create("说明：RGB都输入255时，\n即为还原色彩", "Airal", 14)
    descLabel:setColor(cc.c3b(220,220,220))
    descLabel:setAnchorPoint(0,0.5)
    descLabel:setPosition(labelX-10,colorGEditor:getPositionY() - 80)
    self._container:addChild(descLabel)
end

--改变位置
function PropertyPanel:setChangePositionView()
    local action = self._frameData.action

    local function onChange(target)
        action.controlIds = self._controlIdsEditor:getValue()
        action.targetType = tonumber(self._targetTypeEditor:getValue()) or action.targetType
        action.reset = tonumber(self._resetEditor:getValue()) or action.reset
        action.direction = tonumber(self._directionEditor:getValue()) or action.direction
        action.toX = tonumber(self._xEditor:getValue()) or action.toX
        action.toY = tonumber(self._yEditor:getValue()) or action.toY
        action.hideBar = tonumber(self._hideBarEditor:getValue()) or action.hideBar
        action.rotation = tonumber(self._rotationEditor:getValue()) or action.rotation
        action.coord = self._coordEditor:getValue2()

        BattleMgr.refresh()
    end
    
    local controlIdsEditor = LabelValue.new("控制对象:", LabelValue.TYPE_EDIT,onChange)
    controlIdsEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(controlIdsEditor);
    controlIdsEditor:setValue(action.controlIds)
    self._controlIdsEditor = controlIdsEditor
    
    local targetTypeEditor = LabelValue.new("目标(1攻2受):", LabelValue.TYPE_EDIT,onChange)
    targetTypeEditor:setPosition(labelX-13, controlIdsEditor:getPositionY() - 30)
    self._container:addChild(targetTypeEditor);
    targetTypeEditor:setValue(action.targetType)
    self._targetTypeEditor = targetTypeEditor
    
    local resetEditor = LabelValue.new("是否复位(1是0非):", LabelValue.TYPE_EDIT,onChange)
    resetEditor:setPosition(labelX-13,targetTypeEditor:getPositionY() - 30)
    self._container:addChild(resetEditor);
    resetEditor:setValue(action.reset)
    self._resetEditor = resetEditor
    
    local directionEditor = LabelValue.new("朝向(0不变1左2右):", LabelValue.TYPE_EDIT,onChange)
    directionEditor:setPosition(labelX-13,resetEditor:getPositionY() - 30)
    self._container:addChild(directionEditor);
    directionEditor:setValue(action.direction)
    self._directionEditor = directionEditor

    local xEditor = LabelValue.new("toX:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,directionEditor:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.toX)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("toY:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.toY)
    self._yEditor = yEditor
    
    local hideBarEditor = LabelValue.new("隐藏血条(1是0非):", LabelValue.TYPE_EDIT,onChange)
    hideBarEditor:setPosition(labelX-13,yEditor:getPositionY() - 30)
    self._container:addChild(hideBarEditor);
    hideBarEditor:setValue(action.hideBar)
    self._hideBarEditor = hideBarEditor
    
    local rotationEditor = LabelValue.new("角度(0-360):", LabelValue.TYPE_EDIT,onChange)
    rotationEditor:setPosition(labelX-13,hideBarEditor:getPositionY() - 30)
    self._container:addChild(rotationEditor);
    rotationEditor:setValue(action.rotation)
    self._rotationEditor = rotationEditor
    
    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange)
    coordEditor:setPosition(labelX-13,rotationEditor:getPositionY() - 35)
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
    
    local descLabel = ccui.Text:create("说明：是否复位栏填1时，\n其下方参数无效\n参考点为角色相关时，\n取的该角色的站位点", "Airal", 14)
    descLabel:setColor(cc.c3b(220,220,220))
    descLabel:setAnchorPoint(0,0.5)
    descLabel:setPosition(labelX-10,coordEditor:getPositionY() - 80)
    self._container:addChild(descLabel)
end

--分身
function PropertyPanel:setBodySeparateView()
    local action = self._frameData.action

    local function onChange(target)
        action.option = tonumber(self._optionEditor:getValue()) or action.option
    end
    
    local optionEditor = LabelValue.new("1开始0结束:", LabelValue.TYPE_EDIT,onChange)
    optionEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(optionEditor);
    optionEditor:setValue(action.option)
    self._optionEditor = optionEditor
end

--导弹
function PropertyPanel:setMissileView()
    local action = self._frameData.action

    local function onChange(target)
        action.fromCoord = self._fromCoordEditor:getValue2()
        action.fromX = tonumber(self._fromXEditor:getValue()) or action.fromX
        action.fromY = tonumber(self._fromYEditor:getValue()) or action.fromY
        action.fromScale = tonumber(self._fromScaleEditor:getValue()) or action.fromScale

        action.toCoord = self._toCoordEditor:getValue2()
        action.toX = tonumber(self._toXEditor:getValue()) or action.toX
        action.toY = tonumber(self._toYEditor:getValue()) or action.toY
        action.toScale = tonumber(self._toScaleEditor:getValue()) or action.toScale

        action.effectSpeed = tonumber(self._speedEditor:getValue()) or action.effectSpeed

        action.blendSrc = BlendFactor[self._blendSrcEditor:getValue()] or action.blendSrc
        action.blendDst = BlendFactor[self._blendDstEditor:getValue()] or action.blendDst
        
        action.tween = self._tweenEditor:getValue()
        action.controlPoint1X = tonumber(self._controlPoint1XEditor:getValue()) or action.controlPoint1X
        action.controlPoint1Y = tonumber(self._controlPoint1YEditor:getValue()) or action.controlPoint1Y
        action.controlPoint2X = tonumber(self._controlPoint2XEditor:getValue()) or action.controlPoint2X
        action.controlPoint2Y = tonumber(self._controlPoint2YEditor:getValue()) or action.controlPoint2Y
        
        action.effectLevel1 = self._level1Editor:getValue2()
        action.effectLevel2 = self._level2Editor:getValue2()

        BattleMgr.refresh()
    end

    local effectNameTxt = LabelValue.new("技能名称：", LabelValue.TYPE_READ)
    effectNameTxt:setPosition(labelX, self._actionTypeTxt:getPositionY() - 23)
    self._container:addChild(effectNameTxt);
    effectNameTxt:setValue(action.effect)
    self._effectNameTxt = effectNameTxt

    local fromXEditor = LabelValue.new("fromX:", LabelValue.TYPE_EDIT,onChange)
    fromXEditor:setPosition(labelX-13-50,effectNameTxt:getPositionY() - 30)
    self._container:addChild(fromXEditor);
    fromXEditor:setValue(action.fromX)
    self._fromXEditor = fromXEditor

    local fromYEditor = LabelValue.new("fromY:", LabelValue.TYPE_EDIT,onChange)
    fromYEditor:setPosition(labelX-13-50,fromXEditor:getPositionY() - 30)
    self._container:addChild(fromYEditor);
    fromYEditor:setValue(action.fromY)
    self._fromYEditor = fromYEditor

    local fromScaleEditor = LabelValue.new("fromScale:", LabelValue.TYPE_EDIT,onChange)
    fromScaleEditor:setPosition(labelX-13-50,fromYEditor:getPositionY() - 30)
    self._container:addChild(fromScaleEditor);
    fromScaleEditor:setValue(action.fromScale)
    self._fromScaleEditor = fromScaleEditor

    local toXEditor = LabelValue.new("toX:", LabelValue.TYPE_EDIT,onChange)
    toXEditor:setPosition(labelX-13-50,fromScaleEditor:getPositionY() - 35)
    self._container:addChild(toXEditor);
    toXEditor:setValue(action.toX)
    self._toXEditor = toXEditor

    local toYEditor = LabelValue.new("toY:", LabelValue.TYPE_EDIT,onChange)
    toYEditor:setPosition(labelX-13-50,toXEditor:getPositionY() - 30)
    self._container:addChild(toYEditor);
    toYEditor:setValue(action.toY)
    self._toYEditor = toYEditor

    local toScaleEditor = LabelValue.new("toScale:", LabelValue.TYPE_EDIT,onChange)
    toScaleEditor:setPosition(labelX-13-50,toYEditor:getPositionY() - 30)
    self._container:addChild(toScaleEditor);
    toScaleEditor:setValue(action.toScale)
    self._toScaleEditor = toScaleEditor

    local speedEditor = LabelValue.new("特效速度:", LabelValue.TYPE_EDIT,onChange)
    speedEditor:setPosition(labelX-13-50,toScaleEditor:getPositionY() - 30)
    self._container:addChild(speedEditor);
    speedEditor:setValue(action.effectSpeed or 1)
    self._speedEditor = speedEditor
    
    local controlPoint1XEditor = LabelValue.new("控制点1X:", LabelValue.TYPE_EDIT,onChange)
    controlPoint1XEditor:setPosition(labelX-13-50,speedEditor:getPositionY() - 30)
    self._container:addChild(controlPoint1XEditor);
    controlPoint1XEditor:setValue(action.controlPoint1X)
    self._controlPoint1XEditor = controlPoint1XEditor
    
    local controlPoint1YEditor = LabelValue.new("控制点1Y:", LabelValue.TYPE_EDIT,onChange)
    controlPoint1YEditor:setPosition(labelX-13-50,controlPoint1XEditor:getPositionY() - 30)
    self._container:addChild(controlPoint1YEditor);
    controlPoint1YEditor:setValue(action.controlPoint1Y)
    self._controlPoint1YEditor = controlPoint1YEditor
    
    local controlPoint2XEditor = LabelValue.new("控制点2X:", LabelValue.TYPE_EDIT,onChange)
    controlPoint2XEditor:setPosition(labelX-13-50,controlPoint1YEditor:getPositionY() - 30)
    self._container:addChild(controlPoint2XEditor);
    controlPoint2XEditor:setValue(action.controlPoint2X)
    self._controlPoint2XEditor = controlPoint2XEditor
    
    local controlPoint2YEditor = LabelValue.new("控制点2Y:", LabelValue.TYPE_EDIT,onChange)
    controlPoint2YEditor:setPosition(labelX-13-50,controlPoint2XEditor:getPositionY() - 30)
    self._container:addChild(controlPoint2YEditor);
    controlPoint2YEditor:setValue(action.controlPoint2Y)
    self._controlPoint2YEditor = controlPoint2YEditor
    
    local level1Editor = LabelValue.new("开始层次:", LabelValue.TYPE_EFFECT_LEVEL,onChange)
    level1Editor:setPosition(labelX-13+300,effectNameTxt:getPositionY())
    self._container:addChild(level1Editor);
    level1Editor:setValue(EffectLevelSelector.getStringByType(action.effectLevel1 or 1))
    self._level1Editor = level1Editor
    
    local level2Editor = LabelValue.new("结束层次:", LabelValue.TYPE_EFFECT_LEVEL,onChange)
    level2Editor:setPosition(labelX-13+300,level1Editor:getPositionY() - 35)
    self._container:addChild(level2Editor);
    level2Editor:setValue(EffectLevelSelector.getStringByType(action.effectLevel2 or 1))
    self._level2Editor = level2Editor

    local fromCoordEditor = LabelValue.new("from参考点:", LabelValue.TYPE_COORD,onChange)
    fromCoordEditor:setPosition(labelX-13+300,level2Editor:getPositionY()-35)
    self._container:addChild(fromCoordEditor);
    fromCoordEditor:setValue(CoordSelector.getStringByType(action.fromCoord))
    self._fromCoordEditor = fromCoordEditor

    local toCoordEditor = LabelValue.new("to参考点:", LabelValue.TYPE_COORD,onChange)
    toCoordEditor:setPosition(labelX-13+300,fromCoordEditor:getPositionY() - 35)
    self._container:addChild(toCoordEditor);
    toCoordEditor:setValue(CoordSelector.getStringByType(action.toCoord))
    self._toCoordEditor = toCoordEditor

    local blendSrcEditor = LabelValue.new("混合模式src:", LabelValue.TYPE_BLEND_FACTOR,onChange,true)
    blendSrcEditor:setPosition(labelX-13+300,toCoordEditor:getPositionY() - 35)
    self._container:addChild(blendSrcEditor);
    blendSrcEditor:setValue(BlendFactor.getKeyByValue(action.blendSrc))
    self._blendSrcEditor = blendSrcEditor

    local blendDstEditor = LabelValue.new("混合模式Dst:", LabelValue.TYPE_BLEND_FACTOR,onChange,false)
    blendDstEditor:setPosition(labelX-13+300,blendSrcEditor:getPositionY() - 35)
    self._container:addChild(blendDstEditor);
    blendDstEditor:setValue(BlendFactor.getKeyByValue(action.blendDst))
    self._blendDstEditor = blendDstEditor
    
    local tweenEditor = LabelValue.new("缓动类型:", LabelValue.TYPE_ACTION_EASE,onChange)
    tweenEditor:setPosition(labelX-13+300,blendDstEditor:getPositionY() - 35)
    self._container:addChild(tweenEditor);
    tweenEditor:setValue(action.tween)
    self._tweenEditor = tweenEditor
    
end

--创建分身
function PropertyPanel:setCreateCopyView()
    local action = self._frameData.action

    local function onChange(target)
        action.copyId = self._copyIdEditor:getValue()
        action.motion = self._motionNameEditor:getValue()
        action.direction = tonumber(self._directionEditor:getValue()) or action.direction
        action.x = tonumber(self._xEditor:getValue()) or action.x
        action.y = tonumber(self._yEditor:getValue()) or action.y
        action.coord = self._coordEditor:getValue2()

        BattleMgr.refresh()
    end

    local copyIdEditor = LabelValue.new("分身ID:", LabelValue.TYPE_EDIT,onChange)
    copyIdEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(copyIdEditor);
    copyIdEditor:setValue(action.copyId)
    self._copyIdEditor = copyIdEditor
    
    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, copyIdEditor:getPositionY() - 30)
    self._container:addChild(motionNameEditor);
    motionNameEditor:setValue(action.motion)
    self._motionNameEditor = motionNameEditor
    
    local directionEditor = LabelValue.new("朝向(0同1左2右):", LabelValue.TYPE_EDIT,onChange)
    directionEditor:setPosition(labelX-13,motionNameEditor:getPositionY() - 30)
    self._container:addChild(directionEditor);
    directionEditor:setValue(action.direction)
    self._directionEditor = directionEditor
    
    local xEditor = LabelValue.new("x:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,directionEditor:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.x)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("y:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.y)
    self._yEditor = yEditor

    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange)
    coordEditor:setPosition(labelX-13,yEditor:getPositionY() - 35)
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
    
end

--移除分身
function PropertyPanel:setRemoveCopyView()
    local action = self._frameData.action

    local function onChange(target)
        action.copyIds = self._copyIdsEditor:getValue()
    end

    local copyIdsEditor = LabelValue.new("分身IDs:", LabelValue.TYPE_EDIT,onChange)
    copyIdsEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(copyIdsEditor);
    copyIdsEditor:setValue(action.copyIds)
    self._copyIdsEditor = copyIdsEditor
    
    local descLabel = ccui.Text:create("说明：移除多个分身时，以','分隔ID", "Airal", 14)
    descLabel:setColor(cc.c3b(220,220,220))
    descLabel:setAnchorPoint(0,0.5)
    descLabel:setPosition(labelX-10,copyIdsEditor:getPositionY() - 80)
    self._container:addChild(descLabel)
end


--击退
function PropertyPanel:setFlyOffView()
    local action = self._frameData.action

    local function onChange(target)
        action.hitWallHeight = tonumber(self._hitWallHeightEditor:getValue()) or action.hitWallHeight
        action.phase1Duration = tonumber(self._phase1DurationEditor:getValue()) or action.phase1Duration
        action.phase1Motion = self._phase1MotionEditor:getValue()
        action.phase2Duration = tonumber(self._phase2DurationEditor:getValue()) or action.phase2Duration
        action.phase2Motion = self._phase2MotionEditor:getValue()
        action.phase3Duration = tonumber(self._phase3DurationEditor:getValue()) or action.phase3Duration
        action.phase3Motion = self._phase3MotionEditor:getValue()
    end

    local hitWallHeightEditor = LabelValue.new("撞墙时高度:", LabelValue.TYPE_EDIT,onChange)
    hitWallHeightEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(hitWallHeightEditor);
    hitWallHeightEditor:setValue(action.hitWallHeight)
    self._hitWallHeightEditor = hitWallHeightEditor
    
    local phase1DurationEditor = LabelValue.new("阶段1时间:", LabelValue.TYPE_EDIT,onChange)
    phase1DurationEditor:setPosition(labelX-13,hitWallHeightEditor:getPositionY() - 30)
    self._container:addChild(phase1DurationEditor);
    phase1DurationEditor:setValue(action.phase1Duration)
    self._phase1DurationEditor = phase1DurationEditor

    local phase1MotionEditor = LabelValue.new("阶段1动作:", LabelValue.TYPE_EDIT,onChange)
    phase1MotionEditor:setPosition(labelX-13, phase1DurationEditor:getPositionY() - 30)
    self._container:addChild(phase1MotionEditor);
    phase1MotionEditor:setValue(action.phase1Motion)
    self._phase1MotionEditor = phase1MotionEditor
    
    local phase2DurationEditor = LabelValue.new("阶段2时间:", LabelValue.TYPE_EDIT,onChange)
    phase2DurationEditor:setPosition(labelX-13,phase1MotionEditor:getPositionY() - 30)
    self._container:addChild(phase2DurationEditor);
    phase2DurationEditor:setValue(action.phase2Duration)
    self._phase2DurationEditor = phase2DurationEditor

    local phase2MotionEditor = LabelValue.new("阶段2动作:", LabelValue.TYPE_EDIT,onChange)
    phase2MotionEditor:setPosition(labelX-13, phase2DurationEditor:getPositionY() - 30)
    self._container:addChild(phase2MotionEditor);
    phase2MotionEditor:setValue(action.phase2Motion)
    self._phase2MotionEditor = phase2MotionEditor
    
    local phase3DurationEditor = LabelValue.new("阶段3时间:", LabelValue.TYPE_EDIT,onChange)
    phase3DurationEditor:setPosition(labelX-13,phase2MotionEditor:getPositionY() - 30)
    self._container:addChild(phase3DurationEditor);
    phase3DurationEditor:setValue(action.phase3Duration)
    self._phase3DurationEditor = phase3DurationEditor

    local phase3MotionEditor = LabelValue.new("阶段3动作:", LabelValue.TYPE_EDIT,onChange)
    phase3MotionEditor:setPosition(labelX-13, phase3DurationEditor:getPositionY() - 30)
    self._container:addChild(phase3MotionEditor);
    phase3MotionEditor:setValue(action.phase3Motion)
    self._phase3MotionEditor = phase3MotionEditor

end


--旋转
function PropertyPanel:setRotationView()
    local action = self._frameData.action

    local function onChange(target)
        action.controlIds = self._controlIdsEditor:getValue()
        action.targetType = tonumber(self._targetTypeEditor:getValue()) or action.targetType
        action.innerRotation = tonumber(self._innerRotationEditor:getValue()) or action.innerRotation
        
        BattleMgr.refresh()
    end
    
    local controlIdsEditor = LabelValue.new("控制对象:", LabelValue.TYPE_EDIT,onChange)
    controlIdsEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(controlIdsEditor);
    controlIdsEditor:setValue(action.controlIds)
    self._controlIdsEditor = controlIdsEditor

    local targetTypeEditor = LabelValue.new("目标(1攻2受):", LabelValue.TYPE_EDIT,onChange)
    targetTypeEditor:setPosition(labelX-13, controlIdsEditor:getPositionY() - 30)
    self._container:addChild(targetTypeEditor);
    targetTypeEditor:setValue(action.targetType)
    self._targetTypeEditor = targetTypeEditor
    
    local innerRotationEditor = LabelValue.new("角度:", LabelValue.TYPE_EDIT,onChange)
    innerRotationEditor:setPosition(labelX-13,targetTypeEditor:getPositionY() - 40)
    self._container:addChild(innerRotationEditor);
    innerRotationEditor:setValue(action.innerRotation)
    self._innerRotationEditor = innerRotationEditor
end

--角色震动
function PropertyPanel:setRoleShakeFrameView()
    local action = self._frameData.action

    local function onChange(target)
        action.strength = tonumber(self._strengthEditor:getValue()) or action.strength
        action.decay = tonumber(self._decayEditor:getValue()) or action.decay

        BattleMgr.refresh()
    end

    local strengthEditor = LabelValue.new("震幅:", LabelValue.TYPE_EDIT,onChange)
    strengthEditor:setPosition(labelX-13,self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(strengthEditor);
    strengthEditor:setValue(action.strength)
    self._strengthEditor = strengthEditor

    local decayEditor = LabelValue.new("衰减系数(0-1):", LabelValue.TYPE_EDIT,onChange)
    decayEditor:setPosition(labelX-13, strengthEditor:getPositionY() - 30)
    self._container:addChild(decayEditor);
    decayEditor:setValue(action.decay)
    self._decayEditor = decayEditor
end

--更换背景
function PropertyPanel:setReplaceBackgroundView()
    local action = self._frameData.action

    local function onChange(target)
--        action.x = tonumber(self._xEditor:getValue()) or action.x
--        action.y = tonumber(self._yEditor:getValue()) or action.y
--        action.scale = tonumber(self._scaleEditor:getValue()) or action.scale
        
        action.fadeIn = tonumber(self._fadeInEditor:getValue()) or action.fadeIn
        action.fadeOut = tonumber(self._fadeOutEditor:getValue()) or action.fadeOut

        BattleMgr.refresh()
    end


    local effectNameTxt = LabelValue.new("特效名称：", LabelValue.TYPE_READ)
    effectNameTxt:setPosition(labelX, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(effectNameTxt);
    effectNameTxt:setValue(action.effect)
    self._effectNameTxt = effectNameTxt

--    local xEditor = LabelValue.new("x:", LabelValue.TYPE_EDIT,onChange)
--    xEditor:setPosition(labelX-13,effectNameTxt:getPositionY() - 30)
--    self._container:addChild(xEditor);
--    xEditor:setValue(action.x)
--    self._xEditor = xEditor
--
--    local yEditor = LabelValue.new("y:", LabelValue.TYPE_EDIT,onChange)
--    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
--    self._container:addChild(yEditor);
--    yEditor:setValue(action.y)
--    self._yEditor = yEditor

--    local scaleEditor = LabelValue.new("scale:", LabelValue.TYPE_EDIT,onChange)
--    scaleEditor:setPosition(labelX-13,effectNameTxt:getPositionY() - 30)
--    self._container:addChild(scaleEditor);
--    scaleEditor:setValue(action.scale)
--    self._scaleEditor = scaleEditor
    
    local fadeInEditor = LabelValue.new("淡入时间:", LabelValue.TYPE_EDIT,onChange)
    fadeInEditor:setPosition(labelX-13,effectNameTxt:getPositionY() - 30)
    self._container:addChild(fadeInEditor);
    fadeInEditor:setValue(action.fadeIn)
    self._fadeInEditor = fadeInEditor
    
    local fadeOutEditor = LabelValue.new("淡出时间:", LabelValue.TYPE_EDIT,onChange)
    fadeOutEditor:setPosition(labelX-13,fadeInEditor:getPositionY() - 30)
    self._container:addChild(fadeOutEditor);
    fadeOutEditor:setValue(action.fadeOut)
    self._fadeOutEditor = fadeOutEditor

end

function PropertyPanel:setLevelAdjustView()
    local action = self._frameData.action

    local function onChange(target)
        action.additionY = tonumber(self._additionYEditor:getValue()) or action.additionY
    end
    local additionYEditor = LabelValue.new("加成高度：", LabelValue.TYPE_EDIT,onChange)
    additionYEditor:setPosition(labelX, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(additionYEditor);
    additionYEditor:setValue(action.additionY)
    self._additionYEditor = additionYEditor
end


--添加角色
function PropertyPanel:setCallRoleView()
    local action = self._frameData.action

    local function onChange(target)
        action.x = tonumber(self._xEditor:getValue()) or action.x
        action.y = tonumber(self._yEditor:getValue()) or action.y
        action.motion = self._motionNameEditor:getValue()
        action.direction = tonumber(self._directionEditor:getValue()) or action.direction
        action.callId = tostring(self._roleIdEditor:getValue())
        action.coord = self._coordEditor:getValue2()

        BattleMgr.refresh()
    end

    local rolePathTxt = LabelValue.new("角色资源：", LabelValue.TYPE_READ)
    rolePathTxt:setPosition(labelX, self._actionTypeTxt:getPositionY() - 30)
    self._container:addChild(rolePathTxt);
    rolePathTxt:setValue(action.rolePath)

    local roleIdEditor = LabelValue.new("角色ID:", LabelValue.TYPE_EDIT,onChange)
    roleIdEditor:setPosition(labelX-13,rolePathTxt:getPositionY() - 30)
    self._container:addChild(roleIdEditor);
    roleIdEditor:setValue(action.callId)
    self._roleIdEditor = roleIdEditor

    local xEditor = LabelValue.new("x:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,roleIdEditor:getPositionY() - 30)
    self._container:addChild(xEditor);
    xEditor:setValue(action.x)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("y:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._container:addChild(yEditor);
    yEditor:setValue(action.y)
    self._yEditor = yEditor

    local directionEditor = LabelValue.new("朝向(1左2右):", LabelValue.TYPE_EDIT,onChange)
    directionEditor:setPosition(labelX-13,yEditor:getPositionY() - 30)
    self._container:addChild(directionEditor);
    directionEditor:setValue(action.direction)
    self._directionEditor = directionEditor


    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, directionEditor:getPositionY() - 30)
    self._container:addChild(motionNameEditor);
    motionNameEditor:setValue(action.motion)
    self._motionNameEditor = motionNameEditor
    
    local coordEditor = LabelValue.new("参考点:", LabelValue.TYPE_COORD,onChange)
    coordEditor:setPosition(labelX-13,motionNameEditor:getPositionY() - 35)
    self._container:addChild(coordEditor);
    coordEditor:setValue(CoordSelector.getStringByType(action.coord))
    self._coordEditor = coordEditor
end


--移除角色
function PropertyPanel:setRemoveRoleView()
    local action = self._frameData.action

    local function onChange(target)
        action.controlId = tostring(self._controlIdEditor:getValue())
        BattleMgr.refresh()
    end

    local controlIdEditor = LabelValue.new("角色ID:", LabelValue.TYPE_EDIT,onChange)
    controlIdEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(controlIdEditor);
    controlIdEditor:setValue(action.controlId)
    self._controlIdEditor = controlIdEditor
end
--特效调整
function PropertyPanel:setEffectAdjustView()
    local action = self._frameData.action

    local function onChange(target)
        action.controlId = tostring(self._controlIdEditor:getValue())
        action.toAlpha = tonumber(self._toAlphaEditor:getValue())-- or action.toAlpha
        action.toScaleX = tonumber(self._toScaleXEditor:getValue())-- or action.toScaleX
        action.toScaleY = tonumber(self._toScaleYEditor:getValue())-- or action.toScaleY
        action.offsetX = tonumber(self._offsetXEditor:getValue())-- or action.offsetX
        action.offsetY = tonumber(self._offsetYEditor:getValue())-- or action.offsetY
        action.toRotation = tonumber(self._toRotationEditor:getValue())
        action.anchorX = tonumber(self._anchorXEditor:getValue())-- or action.anchorX
        action.anchorY = tonumber(self._anchorYEditor:getValue())-- or action.anchorY
       
--        BattleMgr.refresh()
    end

    local controlIdEditor = LabelValue.new("特效ID:", LabelValue.TYPE_EDIT,onChange)
    controlIdEditor:setPosition(labelX-13, self._actionTypeTxt:getPositionY() - 40)
    self._container:addChild(controlIdEditor);
    controlIdEditor:setValue(action.controlId)
    self._controlIdEditor = controlIdEditor
    
    local toAlphaEditor = LabelValue.new("toAlpha(0-255):", LabelValue.TYPE_EDIT,onChange)
    toAlphaEditor:setPosition(labelX-13,controlIdEditor:getPositionY() - 30)
    self._container:addChild(toAlphaEditor);
    toAlphaEditor:setValue(action.toAlpha)
    self._toAlphaEditor = toAlphaEditor
    
    local toScaleXEditor = LabelValue.new("toScaleX:", LabelValue.TYPE_EDIT,onChange)
    toScaleXEditor:setPosition(labelX-13,toAlphaEditor:getPositionY() - 30)
    self._container:addChild(toScaleXEditor);
    toScaleXEditor:setValue(action.toScaleX)
    self._toScaleXEditor = toScaleXEditor
    
    local toScaleYEditor = LabelValue.new("toScaleY:", LabelValue.TYPE_EDIT,onChange)
    toScaleYEditor:setPosition(labelX-13,toScaleXEditor:getPositionY() - 30)
    self._container:addChild(toScaleYEditor);
    toScaleYEditor:setValue(action.toScaleY)
    self._toScaleYEditor = toScaleYEditor
    
    local offsetXEditor = LabelValue.new("offsetX:", LabelValue.TYPE_EDIT,onChange)
    offsetXEditor:setPosition(labelX-13,toScaleYEditor:getPositionY() - 30)
    self._container:addChild(offsetXEditor);
    offsetXEditor:setValue(action.offsetX)
    self._offsetXEditor = offsetXEditor
    
    local offsetYEditor = LabelValue.new("offsetY:", LabelValue.TYPE_EDIT,onChange)
    offsetYEditor:setPosition(labelX-13,offsetXEditor:getPositionY() - 30)
    self._container:addChild(offsetYEditor);
    offsetYEditor:setValue(action.offsetY)
    self._offsetYEditor = offsetYEditor
    
    local toRotationEditor = LabelValue.new("旋转角度:", LabelValue.TYPE_EDIT,onChange)
    toRotationEditor:setPosition(labelX-13,offsetYEditor:getPositionY() - 30)
    self._container:addChild(toRotationEditor);
    toRotationEditor:setValue(action.toRotation)
    self._toRotationEditor = toRotationEditor
    
    local anchorXEditor = LabelValue.new("锚点X:", LabelValue.TYPE_EDIT,onChange)
    anchorXEditor:setPosition(labelX-13,toRotationEditor:getPositionY() - 30)
    self._container:addChild(anchorXEditor);
    anchorXEditor:setValue(action.anchorX)
    self._anchorXEditor = anchorXEditor
    
    local anchorYEditor = LabelValue.new("锚点Y:", LabelValue.TYPE_EDIT,onChange)
    anchorYEditor:setPosition(labelX-13,anchorXEditor:getPositionY() - 30)
    self._container:addChild(anchorYEditor);
    anchorYEditor:setValue(action.anchorY)
    self._anchorYEditor = anchorYEditor
    
end

function PropertyPanel:setEditSpell(spell)
    self._spellName:setString("当前技能：" .. spell.id)
end

return PropertyPanel