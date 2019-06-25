local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local MotionType = require("src/scene/battle/mode/MotionType")
local RoleConfigModel = require("src/scene/battle/data/RoleConfigModel")
local Map = require("src/scene/battle/mode/Map")
local EventProtocol = require("src/utils/EventProtocol")
local RoleInfoBar = require("src/scene/battle/view/RoleInfoBar")
local BloodEffectHelper = require("src/scene/battle/view/BloodEffectHelper")
local BuffNameEffect = require("src/scene/battle/view/BuffNameEffect")
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")
local BattleSpeedMgr = require("src/scene/battle/manager/BattleSpeedMgr")
local EnterFrameMgr = require("src/scene/battle/manager/EnterFrameMgr")
local AfterimageMgr = require("src/scene/battle/manager/AfterimageMgr")
local GhostShadowMgr = require("src/scene/battle/manager/GhostShadowMgr")
local CustomAMGR = require("src/scene/battle/manager/CustomAMGR")
local BuffEffect = require("src/scene/battle/view/BuffEffect")
local SkeletonLoadMgr = require("src/scene/battle/manager/SkeletonLoadMgr")
local DramaRoleBubble = require("src/scene/battle/view/DramaRoleBubble")
local EffectMgr = require("src/scene/battle/manager/EffectMgr")

local Role = class("Role",function () 
    return cc.Node:create() 
end)

Role.DIRECTION_LEFT = 1 --角色朝向（面向）左
Role.DIRECTION_RIGHT = 2 --角色朝向（面向）右

local LAYER_Z_ROLE_BACK = -99999 --角色后面层
local LAYER_Z_ROLE = -89999 --角色层
local LAYER_Z_BUFF = -79999 --buff层
local LAYER_Z_FRONT = -69999 --角色前面层

Role.EVENT_MOTION_COMPLETE = "eventMotionComplete"
Role.EVENT_MOTION_COMPLETE2 = "eventMotionComplete2"
Role.EVENT_MOTION_CHANGED = "eventMotionChanged"

local scheduler = cc.Director:getInstance():getScheduler()

--isClear 是否是干净版，不为nil时，不显示血条等内容
--isShadow 是否是残影
function Role:ctor(info, isClear, isShadow, asyncLoad, dramaFlag, defaultMotion, showShade)
    self._info = info
    self._isClear = isClear
    self._isShadow = isShadow
    self._asyncLoad = asyncLoad
    self._dramaFlag = dramaFlag
    self._showShade = showShade
    self._defaultMotion = defaultMotion or MotionType.PREPARE
    self._parts = {}
    self._buffs = {}
    self._customAmgr = CustomAMGR.new()
    self._spaceH = 0
    self._innerX = 0
    self._opacity = 255
    self._rotationInner = 0
    
    self.lockCount = 0--锁定状态计数器（值大于0时，角色处于锁定状态，处于锁定状态的角色会被限制某些行为，如死亡时不会立即被移除）
    
    self._isDead = false
    self._additionY = 0
    self._direction = Role.DIRECTION_RIGHT
    EventProtocol.extend(self) -- 添加事件处理功能
    
    local body = cc.Node:create()
    self:addChild(body,LAYER_Z_ROLE)
    self._body = body
    
    if not isClear then
        local bar = RoleInfoBar.new(info)
        --bar:setScaleX(1)
        --bar:setFlippedX(true)
        bar:setPositionY(200)--默认值
        bar:setCurrentHp(info.hp, info.maxHp)
        self:addChild(bar, LAYER_Z_FRONT+100)
        self._bar = bar
    end
    if not isClear or self._showShade then
        local shade = cc.Sprite:createWithSpriteFrameName("ui/battle/shade.png")
        shade:setPosition(5,-10)
        self:addChild(shade, LAYER_Z_ROLE_BACK)
        self._shade = shade;
    end
    
    self.setVisible = function (node, value)
        self._isVisible = value
        self._body:setVisible(value)
        if self._barIsVisible == true and self._bar then
            if  not self._showShade then
                self._shade:setVisible(value)
            end
            self._bar:setVisible(value)
        end
        if self._buffVisible == true then
            self:setBuffVisible(value)
        end
        
        if self._afterimageMgr then
            self._afterimageMgr:setVisible(value)
        end
        if self._readyEffect then
            self._readyEffect:setVisible(value)
        end
        if self._ghostShadowMgr then
            self._ghostShadowMgr:setVisible(value)
        end
    end
    self._barIsVisible = true
    self._isVisible = true
    
    self:loadArmature(info:getResPath())
    
    self._onAddBuff = function (event)
        self:addBuffEffect(event.data)
    end
    
    self._onInvokeBuff = function (event)
        self:invokeBuff(event.data)
    end
    
    self._onRemoveBuff = function (event)
        self:removeBuffEffect(event.data)
    end
    
    info:addEventListener(RoleInfo.EVENT_ADD_BUFF, self._onAddBuff)
    info:addEventListener(RoleInfo.EVENT_INVOKE_BUFF, self._onInvokeBuff)
    info:addEventListener(RoleInfo.EVENT_REMOVE_BUFF, self._onRemoveBuff)
    
    local function onNodeEvent(event)
        if "enter" == event then
            if not self._dramaFlag then
                BattleSpeedMgr.addMember(self)
            end
            EnterFrameMgr.register(self)
        elseif "exit" == event then
            info:removeEventListener(RoleInfo.EVENT_ADD_BUFF, self._onAddBuff)
            info:removeEventListener(RoleInfo.EVENT_INVOKE_BUFF, self._onInvokeBuff)
            info:removeEventListener(RoleInfo.EVENT_REMOVE_BUFF, self._onRemoveBuff)
            
            EffectMgr.removeEffectByContainer(self)
            if not self._dramaFlag then
                BattleSpeedMgr.removeMember(self)
            end
            EnterFrameMgr.unregister(self)
            if self._spellPerformer then
                self._spellPerformer:dispose()
                self._spellPerformer = nil
            end
            if self._customAmgr then
                self._customAmgr:dispose()
                self._customAmgr=nil
            end
            if self._roleAi then
                self._roleAi:dispose()
                self._roleAi = nil
            end
            if self._exposureSchedulerEntry then
                scheduler:unscheduleScriptEntry(self._exposureSchedulerEntry)
                self._exposureSchedulerEntry = nil
            end
            if self._armaturePath then
--                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(self._armaturePath)
                ResourceManager:getInstance():removeArmatureFileInfo(self._armaturePath)
                self._armaturePath = nil
            end
            if self._ghostShadowMgr then
                self._ghostShadowMgr:dispose()
                self._ghostShadowMgr = nil
            end
        end
    end

    self:registerScriptHandler(onNodeEvent)
    self:setScale(1)
end

function Role:executeCustomAction(action)
    self._customAmgr:act(action)
end

function Role:removeCustomAction(action)
    self._customAmgr:removeAction(action)
end

function Role:clearCustomActions()
    self._customAmgr:clearActions()
end

function Role:enterFrame(dt)
    if self._afterimageMgr then 
        self._afterimageMgr:update(dt)
    end
end

function Role:showGhostShadow()
    if not self._ghostShadowMgr then 
        self._ghostShadowMgr = GhostShadowMgr.new(self)
    end
    self._ghostShadowMgr:start()
end

function Role:stopGhostShadow()
    if self._ghostShadowMgr then 
        self._ghostShadowMgr:stop()
    end
end

--显示残影
function Role:showAfterimage(params)
    if not self._afterimageMgr then 
        self._afterimageMgr = AfterimageMgr.new(self)
    end
    self._afterimageMgr:setParams(params)
end

--添加坐标相关的残影动作
function Role:addPositionAfterimageAction()
    if self._afterimageMgr then 
        local x, y = self:getPosition()
        self._afterimageMgr:addAction({type=AfterimageMgr.ACTION_TYPE_POSITION, x=x, y=y})
    end
end

function Role:addRotationAfterimageAction()
    if self._afterimageMgr then 
        local rotation = self:getRotation()
        self._afterimageMgr:addAction({type=AfterimageMgr.ACTION_TYPE_ROTATION, rotation = rotation})
    end
end

--清除残影
function Role:clearAfterimage()
    if self._afterimageMgr then
        self._afterimageMgr:clear()
    end
end

function Role:loadArmature(path)
--    if self._asyncLoad then
--        local function dataLoaded()
--            self:setArmature(path)
--        end
--        SkeletonLoadMgr.load(path, dataLoaded)
--    else
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
        self:setArmature(path)
--    end
end
function Role:setArmature(path)
    if self._armaturePath == path then
        return
    end
    
    if self._myArmature then
        self._body:removeChild(self._myArmature, true)
    end
    
    self._armaturePath = path
    
    local n = string.gsub(path, "%.[%a%d]+$", "")
    n = string.gsub(n,".+/","")
    local myArmature = customext.MyArmature:create(n)
    self._myArmature = myArmature;
    local armature = myArmature:getArmature();
    
    local ptBottom, ptHit, ptTop = RoleConfigModel.getKeyPositions(path)
    local anchor = cc.p(0.5,0)
    local center = cc.p(0, armature:getContentSize().height/2)
    local headerPos = cc.p(0,armature:getContentSize().height)
    self._showDustFlag = RoleConfigModel.getShowDustFlag(path)
    if ptBottom then
        anchor.x = (ptBottom.x + armature:getContentSize().width/2)/armature:getContentSize().width
        anchor.y = ptBottom.y/armature:getContentSize().height
        center.x = ptHit.x - ptBottom.x
        center.y = ptHit.y - ptBottom.y  
        if ptTop then
            headerPos.x = ptTop.x - ptBottom.x
            if self._direction == Role.DIRECTION_LEFT then
                headerPos.x = -headerPos.x
            end
            headerPos.y = ptTop.y - ptBottom.y
        end
    end
    
    armature:setAnchorPoint(anchor)
    self._myArmature:recordAnchor(anchor);
    
    self._centerPt = center
    self._headerPt = headerPos
    if self._bar then
        self._bar:setPosition(headerPos)
    end
    
    self._body:addChild(myArmature, LAYER_Z_ROLE)
    

    local function animationEvent(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete then
            self:dispatchEvent({name = Role.EVENT_MOTION_COMPLETE, movementID = movementID})
        elseif movementType == ccs.MovementEventType.complete then
            self:dispatchEvent({name = Role.EVENT_MOTION_COMPLETE2, movementID = movementID})
        end
    end

    armature:getAnimation():setMovementEventCallFunc(animationEvent)

    self._armature = armature
    self:setContentSize(armature:getContentSize())
    self:setSpeed(self._speed or 1)
    
    self:executeMotion(self._defaultMotion)
    if not self._isShadow and not self._isClear then
        for i, buffData in ipairs(self._info.buffs) do
            self:addBuffEffect(buffData)
        end
    end

    if self._info.type == CreatureType.CREATURE_MONSTER and not LD_EDITOR and self._info:getTemplate() and self._info:getTemplate().color ~= 0 then
        self:setHueParam(self._info:getTemplate().color)
    end
end

function Role:setMap(map)
    if self._info.side == RoleInfo.SIDE_LEFT then
        if self._info.unitX then
            self:setPosition(PositionHelper.getPositionByUnitX(RoleInfo.SIDE_LEFT, self._info.position,self._info.unitX))
        else
            self:setPosition(PositionHelper.getLeft(self._info.position))
        end
        self:setDirection(Role.DIRECTION_RIGHT)
    else
        if self._info.unitX then
            self:setPosition(PositionHelper.getPositionByUnitX(RoleInfo.SIDE_RIGHT, self._info.position,self._info.unitX))
        else
            self:setPosition(PositionHelper.getRight(self._info.position))
        end
        self:setDirection(Role.DIRECTION_LEFT)
    end
    
    self._map = map
    self:refreshDepth(self:getPositionY())
end

--设置为队伍的朝向
function Role:setTeamDirection()
    if self._info.side == RoleInfo.SIDE_LEFT then
        self:setDirection(Role.DIRECTION_RIGHT)
    else
        self:setDirection(Role.DIRECTION_LEFT)
    end
end

--设置朝向
function Role:setDirection(dir)
    if self._armature then
        if self._direction ~= dir then
            if dir == Role.DIRECTION_RIGHT then
                self._body:setScaleX(1)
            else
                self._body:setScaleX(-1)
            end
            self:updateInner()
            self._direction = dir
        end
    end
    if self._afterimageMgr then
        self._afterimageMgr:addAction({type = AfterimageMgr.ACTION_TYPE_DIRECTION, dir=dir})
    end
end

function Role:getDirection()
    return self._direction
end

--设置角色的高度（非尺寸，而是垂直空间上的距离）
function Role:setPositionH(h)
    if self._spaceH == h then
        return
    end
    self._spaceH = h
--    self._body:setPositionY(self._spaceH)
    
    self:updateInner()
    
    if self._afterimageMgr then
        self._afterimageMgr:addAction({type = AfterimageMgr.ACTION_TYPE_HEIGHT, height=h})
    end
end

function Role:getPositionH()
    return self._spaceH
end

function Role:getPositionXInner()
    return self._innerX
end

function Role:setPositionXInner(value)
    if self._innerX ~= value then
        self._innerX = value
        self:updateInner()
    end
end

function Role:setRotationInner(value)
    self._rotationInner = value
    self:updateInner()
    if self._afterimageMgr then
        self._afterimageMgr:addAction({type = AfterimageMgr.ACTION_TYPE_ROTATION_INNER, rotation=value})
    end
end

function Role:getRotationInner()
    return self._rotationInner
end

function Role:updateInner()
    if self._armature then
        local size = self._armature:getContentSize()
        local anchor = self._armature:getAnchorPoint()
        local distance = size.height/2
        local x = -math.sin(self._rotationInner/180*math.pi) * distance
        local y = distance - math.cos(self._rotationInner/180*math.pi) * distance
        self._body:setPositionY(y + self._spaceH)
        
        if self._body:getScaleX() == 1 then
            self._body:setRotation(self._rotationInner)
            self._body:setPositionX(x+self._innerX)
        else
            self._body:setRotation(-self._rotationInner)
            self._body:setPositionX(-x+self._innerX)
        end
    end
end

--设置色相
function Role:setHueParam(value)
    if self._myArmature then
        self._myArmature:setHueParam(value)
    end
end

function Role:setExposureVec3(value)
    if self._myArmature then
        self._myArmature:setExposureParams(value)
    end
end

--刷新深度值
function Role:refreshDepth(y)
    if self._isShadow then --self.shadowFather 在外部有附值
        y = y + 1000
    end
    if self._map then
        self._map:setUnitDepth(self, y+self._additionY)
    end
end

function Role:setAdditionY(value)
    self._additionY = value
    self:refreshDepth(self:getPositionY())
end
--name 动作名称
--durationTo 从上一个动作转到要播放的动作的过渡的帧数
--loop 循环次数
--nextName 当不为空时，指定的动作播放完成后，会自动转到下一个动作
--startFrame 从第几帧开始播放
function Role:executeMotion(name, durationTo, loop, nextName, startFrame)
    local oldMotion = self._currentMotion
    if LD_EDITOR then
        local labelstr = custom.CustomArmatureHelper:getLabels(self._armature:getAnimation():getAnimationData())
        local labels = string.split(labelstr, "_=+")
        local found
        for _, label in ipairs(labels) do
            if label == name then
                found = true
                break;
            end
        end
        if not found then
            Message.show("不存在该动作："..name)
            return
        end
    end
    
    if self._currentMotion == MotionType.DIE and self._info.isDead and name ~= MotionType.DIE then
        return
    end
    
    if name == MotionType.PREPARE then
        if self._preparing then
            name = MotionType.READY
        end
    end
--    if name == MotionType.STAND then--临时
--        name = MotionType.PREPARE
--    end
--    if name == MotionType.HURT1 or name == MotionType.DOWN and self._info.type == CreatureType.CREATURE_HERO then--临时
--        name = MotionType.HURT
--    end

    self:clearParts()
    self:addParts(name);
    
    self._currentMotion = name
    if self._afterimageMgr then
        self._afterimageMgr:addAction({type = AfterimageMgr.ACTION_TYPE_MOTION,motion=name, durationTo=durationTo, loop= loop, nextName=nextName, startFrame = startFrame})
    end
    if not self._isShadow then
        if name == MotionType.HURT or name == MotionType.HURT1 or name == MotionType.DOWN then
            self:setColor(cc.c3b(255,0,0))
            if not LD_EDITOR then
                local template = self:getInfo():getTemplate()
                if template and template.sound_attacked ~= "" then
                    local burtSound = "music/bt_sound/" .. template.sound_attacked .. ".mp3"
                    AudioEngine.playEffect(burtSound)
                end
            end
        else
            self:setColor(nil)
        end
    end
    
    local durationTo = durationTo or -1
    local loop = loop or -1
    local oldMotionLoop = self._motionLoop
    self._motionLoop = loop
    if self._armature then
        if oldMotion ~= name or oldMotionLoop ~= loop or (name ~= MotionType.STAND and name ~= MotionType.PREPARE) then
            self._armature:getAnimation():play(name, durationTo, loop)
        end
        if startFrame and startFrame > 1 then
            self._armature:getAnimation():gotoAndPlay(startFrame)
        end
    end
    
    if self._nextMotionListener then
        self:removeEventListener(Role.EVENT_MOTION_COMPLETE, self._nextMotionListener)
        self._nextMotionListener = nil
    end
    if nextName then
        local function onNotionComplete(event)
            if not self._isDead and not self:getIsMoving() then
                self:executeMotion(nextName)
            end
            if self._nextMotionListener then
                self:removeEventListener(Role.EVENT_MOTION_COMPLETE, self._nextMotionListener)
                self._nextMotionListener = nil
            end
        end
        self._nextMotionListener = onNotionComplete

        self:addEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
    end
    self:dispatchEvent({name = Role.EVENT_MOTION_CHANGED})
end

function Role:getCurrentMotion()
    return self._currentMotion
end

--添加角色的附加部件
function Role:addParts(motion)
    local partsData = RoleConfigModel.getPartsOfMotion(self._armaturePath,motion)

    if partsData then
        for i, partData in ipairs(partsData) do
            local speed = partData.effectSpeed or 1
            local effect = SimpleEffect.new(partData.effect, true, speed)
            if partData.effectLevel == -1 then
                self._body:addChild(effect, LAYER_Z_ROLE_BACK)
            else
                self._body:addChild(effect, LAYER_Z_FRONT)
            end
            effect:setScale(partData.scale)
            local pt = cc.p(partData.x,partData.y)
            local ptBottom = RoleConfigModel.getKeyPositions(self._armaturePath)
            if ptBottom then
                pt.x = pt.x - ptBottom.x
                pt.y = pt.y - ptBottom.y
            end
            effect:setPosition(pt)
--            
--            local position = cc.p(action.x, action.y);
--            local executorSide = self._spell:getExecutor():getInfo().side
--            if executorSide == RoleInfo.SIDE_RIGHT then
--                position.x = -position.x
--                eff:setScaleX(-scale)
--            end
--            effect:setGLProgramState(cc.GLProgramState:create(ccs.DisplayManager:getCustomProgram()))
--            ccs.DisplayManager:setCustomColor(effect:getGLProgramState(), 0,0,0,0);
            table.insert(self._parts, effect)
            
        end

    end
end

--清除角色附加的部件
function Role:clearParts()
    for i, part in ipairs(self._parts) do
        self._body:removeChild(part, true)
    end
    self._parts = {}
end

--添加特效
--level 显示在哪个层次，1表示在人物上层，-1表示在人物下层
function Role:addEffect(effect, position, level, levelAddition)
    local levelAddition = levelAddition or 0
    position.y = position.y + self._spaceH
    effect:setPosition(position)
    local z = level == -1 and LAYER_Z_ROLE_BACK or LAYER_Z_FRONT
    self:addChild(effect, z+levelAddition)
    if effect.name then
        EffectMgr.addEffect(effect.name,effect,self)
    end
end

function Role:addBuffEffect(buffData)
    if self._info.isDead then return end
    self:calcuBuffAffect()
    local buffTemplate = buffData:getTemplate()
    if not buffTemplate then return end
    
    local position
    local level
    if buffTemplate.position == 1 then
        position = cc.p(self._headerPt.x, self._headerPt.y)
    elseif buffTemplate.position == 2 then
--        position = cc.p(self:getCenterPosition().x, self:getCenterPosition().y)
        position = cc.p(0, self:getCenterPosition().y)
    elseif buffTemplate.position == 3 then
        position = cc.p(0,0)
        level = -1
    end
    
    local hiddenRes = buffData:getHiddenRes()
    if hiddenRes ~= "" then
        local eff = SimpleEffect.new(hiddenRes, false, 0.5)
        eff:setScale(2)
        self:addEffect(eff,position, level)
    end

    local old = self._buffs[buffTemplate.position]
    local addFlag = false
    local continuousRes = buffData:getContinuousRes()
    if old then
        if old:getBuffData().buffId ~= buffData.buffId and old:getBuffData().count<2 and continuousRes ~= "" then
            self:removeBuffEffect(old:getBuffData())
            addFlag = true
        end
    else
        addFlag = true
    end
    
    if addFlag and continuousRes ~= "" then
        local buffEffect = BuffEffect.new(buffData,continuousRes)
        self:addEffect(buffEffect,position, level)
        self._buffs[buffTemplate.position] = buffEffect
    end
    
    if self._bar then
        self._bar:addBuffIcon(buffData)
    end
    BuffNameEffect.play(self,buffData)
    if buffTemplate.sound and buffTemplate.sound ~= "" then
        AudioEngine.playEffect(buffTemplate.sound .. ".mp3")
    end
end

function Role:calcuBuffAffect()
end

function Role:invokeBuff(buffData)
    self:removeHp(-buffData.realHp,-buffData.hp)
    print("--buff removeHp:" .. "realHp=" .. -buffData.realHp .. " displayHp=" .. -buffData.hp)
end

function Role:removeBuffEffect(buffData)
    local buffTemplate = buffData:getTemplate()
    if not buffTemplate then return end
    
    local old = self._buffs[buffTemplate.position]
    if old then
        self._buffs[buffTemplate.position] = nil
        self:removeChild(old,true)
    end
    
    self:calcuBuffAffect()
    if self._bar then
        self._bar:removeBuffIcon(buffData)
    end
end

function Role:clearBuffStates()
    for i, buff in pairs(self._buffs) do
        self:removeChild(buff,true)
    end
    self._buffs = {}
    if self._bar then
        self._bar:clearBuffIcons()
    end
end

--设置buff是否可见
function Role:setBuffVisible(value)
    self._buffVisible = value
    for i = 1, 3 do
        local buffEff = self._buffs[i]
        if buffEff then
            buffEff:setVisible(value)
        end
    end
end

--掉血
function Role:removeHp(value,displayValue, damageType, x, y)
    local hp = self._info.hp - value
    
    self._info.hp = hp
    if self._bar then
        self._bar:setCurrentHp(self._info.hp, self._info.maxHp)
    end
    BloodEffectHelper.playRemoveHpEffect(self, displayValue,damageType, x, y)
    self._info:refreshHp()
    if hp < 1 and (not self._isDead) then
        self:die()
    end
end
--角色死亡
function Role:die()
    self._isDead = true
    self._info.isDead = true
    local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
    local action = BattleCustomActions.DieAction.new(self)
    self:executeCustomAction(action)
end

function Role:isDead()
    return self._isDead
end

--改变怒气值
function Role:changeMp(offset)
    self._info:changeMp(offset)
end

--设置骨骼动画的播放速度
function Role:setSpeed(value)
    if self._speed ~= value then
        self._speed = value
        if self._armature then
            self._armature:getAnimation():setSpeedScale(self._speed)
        end
    end
end

function Role:fadeIn()
    if self._fadeAction then
        self:removeCustomAction(self._fadeAction)
        self._fadeAction = nil
    end
    local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
    self._fadeAction = BattleCustomActions.FadeInAction.new(self, 0.3)
    self:executeCustomAction(self._fadeAction)
end

function Role:fadeOut()
    if self._fadeAction then
        self:removeCustomAction(self._fadeAction)
        self._fadeAction = nil
    end
    local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
    self._fadeAction = BattleCustomActions.FadeOutAction.new(self, 0.3)
    self:executeCustomAction(self._fadeAction)
    self:setBarVisible(false)
end

function Role:updateDatas()
    if self._bar then
        self._bar:setCurrentHp(self._info.hp, self._info.maxHp)
    end
end

--设置蓄力状态
function Role:prepare()
    do return end
    if self._spellExecuting then
        self._needPrepare = true
    else
        self._needPrepare = false
        self._preparing = true
        self._info:setPreparing(self._preparing)
        self:executeMotion(MotionType.READY)
        self:prepareFlash()
        self:showReadyEffect(true)
        self:setVisible(true)
        self:fadeIn()
    end
end

function Role:showReadyEffect(flag)
    if flag then
        if not self._readyEffect then
            local eff = SimpleEffect.new("effect/ef_tongyong/ready_ef", true, 0.5, gl.ONE, gl.ONE, nil, nil)
            local pt = cc.p(0,-8)
            self:addEffect(eff, pt, -1)
            self._readyEffect = eff;
        end
    else
        if self._readyEffect then
            self:removeChild(self._readyEffect,true)
            self._readyEffect = nil
        end
    end
end

function Role:prepareFlash()
    self:setExposureVec3(cc.vec3(4.0,4.0,1.0))
    local function flashEnd(dt)
        self:setExposureVec3(cc.vec3(1.0,1.0,1.0))
        scheduler:unscheduleScriptEntry(self._exposureSchedulerEntry)
        self._exposureSchedulerEntry = nil
    end

    self._exposureSchedulerEntry = scheduler:scheduleScriptFunc(flashEnd,0.1,false)
end

function Role:cancelPrepareState()
    self._preparing = false
    self._info:setPreparing(self._preparing)
    self:showReadyEffect(false)
end

--设置是否正在执行技能
function Role:setSpellExecuting(value)
    self._spellExecuting = value
    if not value and self._needPrepare then
        self:prepare()
    end
end

function Role:getSpellExecuting()
    return self._spellExecuting
end

--设置信息栏是否可见
function Role:setBarVisible(value)
    self._barIsVisible = value
    if self._isVisible then
        if self._bar then
            self._bar:setVisible(value)
        end
        if self._shade and not self._showShade then
            self._shade:setVisible(value)
        end
    end
end

function Role:moveBack()
    local dis = math.abs(self:getPositionX() - self:getOriginPosition().x)
    if dis > 20 then
        local frameCount = math.floor(dis/33)
        local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
        local action = BattleCustomActions.MoveAction.createMoveBack(self, frameCount, nil, MotionType.RUN)
        self:executeCustomAction(action)
    else
        self:setPosition(self:getOriginPosition())
    end
end

--标识需不需要隐藏该角色，如果为true时
function Role:setNeedHideFlag(value)
    self._needHideFlag = value
end
function Role:getNeedHideFlag()
    return self._needHideFlag
end

function Role:setAi(roleAi)
    self._roleAi = roleAi
end

function Role:getIsMoving()
    return self._isMoving
end

function Role:setIsMoving(value)
    self._isMoving = value
end

function Role:gotoAndPause(frameIndex)
    self._armature:getAnimation():gotoAndPause(frameIndex)
end

function Role:getCurrentFrameIndex()
    return self._myArmature:getCurrentFrameIndex()
end

function Role:speak(words, actionData)
    self:stopSpeak()
    local bubble = DramaRoleBubble.new(actionData)
    self:addChild(bubble, LAYER_Z_FRONT+100)
    local pt
    if self._headerPt then
        pt = cc.p(self._headerPt.x, self._headerPt.y)
    end
    if not pt then
        pt = cc.p(0, 220)
    end
    bubble:setPosition(pt.x, pt.y)
    self._bubbleView = bubble
    self._bubbleView:speak(words)
end

function Role:stopSpeak()
    if self._bubbleView then
        self:removeChild(self._bubbleView,true)
        self._bubbleView = nil
    end
end

--获得中心点
function Role:getCenterPosition(bodyLocation)
    if bodyLocation == 1 then
        return cc.p(self._centerPt.x + self._innerX, self._centerPt.y)
    end
    return self._centerPt
end

function Role:getHeadPosition()
    return self._headerPt
end

--获得中心点在地图中的位置
function Role:getCenterPositionInMap(bodyLocation)
    if bodyLocation == 1 then
        return cc.p(self:getPositionX()+self._centerPt.x+ self._innerX,self:getPositionY()+self._centerPt.y)
    end
    return cc.p(self:getPositionX()+self._centerPt.x,self:getPositionY()+self._centerPt.y)
end

--获得原始的站位坐标
function Role:getOriginPosition()
    if self._info.side == RoleInfo.SIDE_RIGHT then
        return PositionHelper.getRight(self._info.position)
    else
        return PositionHelper.getLeft(self._info.position)
    end
end

function Role:getShowDustFlag()
    local ret = true
    if self._showDustFlag == 0 then
        ret = false
    end
    return ret
end

function Role:getArmature()
    return self._armature
end
function Role:getInfo()
    return self._info
end
function Role:getTemplate()
    return self._info:getTemplate();
end
function Role:getMap()
    return self._map
end

function Role:getBody()
    return self._body
end
function Role:setOpacity(value, c3bValue)
    self._opacity = value
    if self._armature then
        self._armature:setOpacity(value)
        if c3bValue then
            self._armature:setColor(c3bValue)
        end
        for i, part in ipairs(self._parts) do
            part:setOpacity(value)
        end
    end
end
function Role:getOpacity()
    return self._opacity
end
function Role:setColor(color3b)
    local color3b = color3b or cc.c3b(255,255,255)
    if self._armature then
        self._armature:setColor(color3b)

        for i, part in ipairs(self._parts) do
            part:setColor(color3b)
        end
        self._myArmature:recordColor(color3b);
    end
end

function Role:setCustomColor(color4b)
    local color4b = color4b or cc.c4b(0,0,0,0);
    local r = color4b.r/255;
    local g = color4b.g/255
    local b = color4b.b/255
    local a = color4b.a/255
    self._armature:setCustomColor(r,g,b,a);
--    for i, part in ipairs(self._parts) do
--        ccs.DisplayManager:setCustomColor(part:getGLProgramState(), r,g,b,a);
--    end
end

function Role:getArmaturePath()
    return self._armaturePath
end

--演示指定技能（播放该技能的简要过程）
function Role:performSpell(performId)
    if not self._spellPerformer then
        local SpellPerformer = require("src/scene/battle/mode/SpellPerformer")
        self._spellPerformer = SpellPerformer.new(self)
    end
    self._spellPerformer:perform(performId)
end

--克隆角色，可用于制作残影
function Role:clone(isShadow)
    local role = Role.new(self._info, true, isShadow)
    return role
end

return Role