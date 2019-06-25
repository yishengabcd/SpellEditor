
--集合了战斗中用到的自定义动作类
local BattleCustomActions = {}

local Role = require("src/scene/battle/mode/Role")
local MotionType = require("src/scene/battle/mode/MotionType")
local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local TweenFunction = require("src/scene/battle/mode/TweenFunction")
local EulerVector = require("src/scene/battle/mode/EulerVector")

local MoveAction = class("MoveAction")
local BlackScreenAction = class("BlackScreenAction")
local ShakeAction = class("ShakeAction")
local FlyAction = class("FlyAction")
local SingleFlyAction = class("SingleFlyAction")
local DieAction = class("DieAction")
local HideRoleAction = class("HideRoleAction")
local JumpAction = class("JumpAction")
local SpeedAdjustAction = class("SpeedAdjustAction")
local RiseAndFallAction = class("RiseAndFallAction")
local FlyOutAction = class("FlyOutAction")
local DelayCallAction = class("DelayCallAction")
local MissileAction = class("MissileAction")
local SingleMissileAction = class("SingleMissileAction")
local FadeOutAction = class("FadeOutAction")
local FadeInAction = class("FadeInAction")
local DriftAction = class("DriftAction")
local InnerRotationAction = class("InnerRotationAction")
local RoleShakeAction = class("RoleShakeAction")
local ReplaceBackgroundAction = class("ReplaceBackgroundAction")
local RoleSpeakAction = class("RoleSpeakAction")
local CurtainAction = class("CurtainAction")
local DramaMovieDialogAction = class("DramaMovieDialogAction")
local EffectAdjustAction = class("EffectAdjustAction")

local SequenceAction = class("SequenceAction") --按顺序执行的动作队列
local JoinSpellComeOut = class("JoinSpellComeOut")--连携技英雄出场动作
local TeamMoveAction = class("TeamMoveAction"); --队伍移动

BattleCustomActions.MoveAction = MoveAction
BattleCustomActions.BlackScreenAction = BlackScreenAction
BattleCustomActions.ShakeAction = ShakeAction
BattleCustomActions.FlyAction = FlyAction
BattleCustomActions.SingleFlyAction = SingleFlyAction
BattleCustomActions.DieAction = DieAction
BattleCustomActions.HideRoleAction = HideRoleAction
BattleCustomActions.JumpAction = JumpAction
BattleCustomActions.SpeedAdjustAction = SpeedAdjustAction
BattleCustomActions.RiseAndFallAction = RiseAndFallAction
BattleCustomActions.FlyOutAction = FlyOutAction
BattleCustomActions.DelayCallAction = DelayCallAction
BattleCustomActions.MissileAction = MissileAction
BattleCustomActions.SingleMissileAction = SingleMissileAction
BattleCustomActions.FadeOutAction = FadeOutAction
BattleCustomActions.FadeInAction = FadeInAction
BattleCustomActions.DriftAction = DriftAction --飘动，飘移（角色坐标不变，改变内部身体的位置）
BattleCustomActions.InnerRotationAction = InnerRotationAction
BattleCustomActions.RoleShakeAction = RoleShakeAction
BattleCustomActions.ReplaceBackgroundAction = ReplaceBackgroundAction
BattleCustomActions.RoleSpeakAction = RoleSpeakAction
BattleCustomActions.CurtainAction = CurtainAction
BattleCustomActions.DramaMovieDialogAction = DramaMovieDialogAction
BattleCustomActions.EffectAdjustAction = EffectAdjustAction

BattleCustomActions.SequenceAction = SequenceAction
BattleCustomActions.JoinSpellComeOut = JoinSpellComeOut
BattleCustomActions.TeamMoveAction = TeamMoveAction

local scheduler = cc.Director:getInstance():getScheduler()

local SECOND_PER_FRAME = 0.0333 --每帧的时间长度

if not LD_EDITOR then
    SECOND_PER_FRAME = SECOND_PER_FRAME/1.25
end 
BattleCustomActions.SECOND_PER_FRAME = SECOND_PER_FRAME

function BattleCustomActions.setFrameRateBySpeed(speed)
    SECOND_PER_FRAME = 0.0333/speed
    BattleCustomActions.SECOND_PER_FRAME = SECOND_PER_FRAME
end

------------------------MoveAction--------------------

--moveBack 是否是回到自己的位置
function MoveAction:ctor(role,startPt,endPt,frameCount, moveBack, endMotion, showBar, 
moveForwardFlag, lockMotion, directionNoChange, showDust)
    self.type = "MoveAction"
    self.finished = false
    
    self._role = role
    self._startPt = startPt
    self._endPt = endPt
    self._delta = cc.pSub(endPt,startPt)
    self._duration = frameCount*SECOND_PER_FRAME
    self._elapsed = 0
    self._moveBack = moveBack
    self._endMotion = endMotion
    self._moveForwardFlag = moveForwardFlag
    self._lockMotion = lockMotion
    self._showDust = showDust
--    if showDust then
--        self._dustCount = 0
--        self._dustMax = math.ceil(math.abs(endPt.x - startPt.x)/200)
--    end
    if self._showDust and role:getShowDustFlag() then
        local pt = cc.p(0, 24)
        if self._role:getDirection() == Role.DIRECTION_LEFT then
            pt.x = pt.x + 50
        else
            pt.x = pt.x - 50
        end
        local effect = SimpleEffect.new("effect/huichen/10", true, 0.4)
        effect:setScale(1.2)
        self._role:addEffect(effect, pt, -1)
        self._dustEff = effect
    end
    
    if role:getCurrentMotion() == MotionType.RUN and not LD_EDITOR then
        local template = role:getInfo():getTemplate()
        if template and template.sound_walking ~= "" then
            local walkingSound = "music/bt_sound/" .. template.sound_walking .. ".mp3"
            self._walkingSoundId = AudioEngine.playEffect(walkingSound, true)
        end
    end
    
    if not directionNoChange then
        if endPt.x > startPt.x then
            role:setDirection(Role.DIRECTION_RIGHT)
        else
            role:setDirection(Role.DIRECTION_LEFT)
        end
    end
    if not showBar then
        role:setBarVisible(false)
    end
    role:setIsMoving(true)
end

function MoveAction:getRole()
    return self._role
end

function MoveAction:setPaused(value)
    self._paused = value
    if self._dustEff then
        local v
        if value then
            v = false
        else
            v = true
        end
        self._dustEff:setVisible(v)
    end
end

function MoveAction:execute(dt)
    if self._paused then return end
    self._elapsed = self._elapsed + dt
    self:setPercent(math.min(1, self._elapsed/self._duration))
end

function MoveAction:setPercent(value)
    if value == 1 then
        self._role:setPosition(self._endPt)
        self._role:setIsMoving(false)
        self.finished = true
        if self._moveBack then
            self._role:setTeamDirection()
            self._role:executeMotion(MotionType.PREPARE)
            self._role:setBarVisible(true)
            self._role:refreshDepth(self._endPt.y)
        else
            self._role:refreshDepth(self._endPt.y-1)
            if self._endMotion then
                self._role:executeMotion(self._endMotion)
            end
        end
        self._role:addPositionAfterimageAction()
        if self._walkingSoundId then
            AudioEngine.stopEffect(self._walkingSoundId)
            self._walkingSoundId = nil
        end
        if self._moveForwardFlag then
            self._role:setTeamDirection()
        end
        if self._dustEff then
            self._role:removeChild(self._dustEff)
            self._dustEff = nil
        end
    else
        if self._lockMotion and self._role:getCurrentMotion() ~= self._lockMotion then
            self._role:executeMotion(self._lockMotion)
        end
        local p = cc.pAdd(self._startPt, cc.pMul(self._delta, value))
        self._role:setPosition(p)
        self._role:refreshDepth(p.y-1)
        
        self._role:addPositionAfterimageAction()
    end
end

function MoveAction:canReplace(action) 
    return false
end

function MoveAction:giveup()
    if self._walkingSoundId then
        AudioEngine.stopEffect(self._walkingSoundId)
        self._walkingSoundId = nil
    end
end

--辅助方法，为指定角色创建一个回到原处的动作
function MoveAction.createMoveBack(role, frameCount, motion, lockMotion)
    local motion = motion or MotionType.RUN
    local position
    if role:getInfo().side == RoleInfo.SIDE_LEFT then
        position = PositionHelper.getLeft(role:getInfo().position)
    else
        position = PositionHelper.getRight(role:getInfo().position)
    end
    
    role:executeMotion(motion)

    local startPt = cc.p(role:getPosition())
    local move = BattleCustomActions.MoveAction.new(role,startPt,position,frameCount, true, nil, nil,nil, lockMotion)

    return move
end


------------------------BlackScreenAction--------------------

function BlackScreenAction:ctor(map, fromAlpha, toAlpha, frameCount, color3b, autoReset)
    self.type = "BlackScreenAction"
    self.finished = false
    
    self._map = map
    self._duration = frameCount*SECOND_PER_FRAME
    self._elapsed = 0
    self._fromAlpha = fromAlpha
    self._toAlpha = toAlpha or fromAlpha
    self._autoReset = autoReset
    self._color3b = color3b
    self._delta = self._toAlpha - fromAlpha
    
    map:setBlackScreen(fromAlpha, color3b)
end

function BlackScreenAction:execute(dt)
    if self._elapsed >= self._duration then
        if self._autoReset then
            self._map:setBlackScreen(0)
        end
        self.finished = true
        return
    end
    self._elapsed = self._elapsed + dt
    local dest = self._fromAlpha + self._delta * self._elapsed/self._duration
    if self._delta > 0 then
        dest = dest < self._toAlpha and dest or self._toAlpha
    else
        dest = dest > self._toAlpha and dest or self._toAlpha
    end
    
    self._map:setBlackScreen(dest,  self._color3b)
end

function BlackScreenAction:canReplace(action) 
    return false
end

function BlackScreenAction:giveup()
end


------------------------ShakeAction--------------------

function ShakeAction:ctor(map, strength, frameCount, decay)
    self.type = "ShakeAction"
    self.finished = false

    self._map = map
    self._strength = strength
    self._frameCount = frameCount
    self._duration = frameCount*SECOND_PER_FRAME
    self._decay = decay
    self._originY = map:getOriginY()
    self._elapsed = 0
    self._count = 0
end

function ShakeAction:execute(dt)
    self._elapsed = self._elapsed + dt
    local reach = math.floor(self._elapsed/SECOND_PER_FRAME)
    while self._count < reach and not self.finished do
        self:shakeOnce()
    end
end
function ShakeAction:shakeOnce()
    if self.finished then
        return 
    end
    self._count = self._count + 1
    if self._count > self._frameCount then
        self._map:setPositionY(self._originY)
        self.finished = true
    else
        self._strength = -self._strength * self._decay
        local y = self._originY + self._strength
        self._map:setPositionY(y)
    end
end

function ShakeAction:canReplace(action) 
    return false
end

function ShakeAction:giveup()
    self._map:setPositionY(self._originY)
end

------------------------FlyAction--------------------

function FlyAction:ctor(spell, frameData)
    self.type = "FlyAction"
    self.finished = true
    
    self._spell = spell
    self._frameData = frameData
    
    local action = self._frameData.action
    
    local function getRoleByCoord(coord, target)
        if coord == CoordSystemType.ATTACK_POS or coord == CoordSystemType.ATTACK_BOTTOM_POS then
            return spell:getExecutor()
        end
        return target
    end
    local fromX = action.fromX
    local toX = action.toX
    local executorSide = spell:getExecutor():getInfo().side
    if executorSide == RoleInfo.SIDE_RIGHT then
        fromX = -fromX
        toX = -toX
    end
    
    local targets = spell:getAttackTargets()
    
    for _, target in ipairs(targets) do
        local fromPt = PositionHelper.getPositionByCoordType(action.fromCoord,cc.p(fromX, action.fromY),getRoleByCoord(action.fromCoord,target), nil, executorSide)
        local toPt = PositionHelper.getPositionByCoordType(action.toCoord,cc.p(toX, action.toY),getRoleByCoord(action.toCoord, target), action.toBodyLocation, executorSide)

        local single = SingleFlyAction.new(spell:getBattle():getMap(), 
            action.effect,
            fromPt,
            toPt,
            frameData.__layerData:getKeyFrameLength(frameData),
            action.fromScale,action.toScale,executorSide,action.effectSpeed,
            action.blendSrc, action.blendDst)

        spell:getBattle():executeCustomAction(single)
    end
end

function FlyAction:execute(dt)
end

function FlyAction:canReplace(action) 
    return false
end

function FlyAction:giveup()
end

------------------------SingleFlyAction--------------------

function SingleFlyAction:ctor(map, effectString, startPt, endPt, frameCount, fromScale, toScale,executorSide, speed, blendSrc, blendDst, dramaFlag)
    self.type = "SingleFlyAction"
    self.finished = false
    
    self._map = map
    
    local effect = SimpleEffect.new(effectString, true, speed,blendSrc,blendDst, nil, nil, dramaFlag, true)
    map:addEffect(effect, startPt)
    
    self._effect = effect
    self._startPt = startPt
    self._endPt = endPt
    self._duration = frameCount * SECOND_PER_FRAME
    self._delta = cc.pSub(endPt,startPt)
    self._elapsed = 0
    
    local atan = math.atan2(endPt.y - startPt.y, endPt.x - startPt.x)
    effect:setAnchorPoint(1,0.5)
    effect:setRotation(math.atan2(startPt.y - endPt.y, endPt.x - startPt.x)*57.29577951)--180/PI
    
    self._fromScale = fromScale
    self._toScale = toScale
    self._scaleDelta = toScale - fromScale
    self._executorSide = executorSide;
    
    if executorSide == RoleInfo.SIDE_LEFT then
        effect:setScale(fromScale)
    else
        effect:setScaleX(fromScale)
        effect:setScaleY(-fromScale)
    end
end

function SingleFlyAction:execute(dt)
    self._elapsed = self._elapsed + dt
    self:setPercent(math.min(1, self._elapsed/self._duration))
end

function SingleFlyAction:setPercent(value)
    if value == 1 then
        self._map:removeEffect(self._effect)
        self._effect = nil
        self.finished = true
    else
        local p = cc.pAdd(self._startPt, cc.pMul(self._delta, value))
        self._effect:setPosition(p)
        
        self._effect:setScale(self._fromScale + self._scaleDelta*value)
        if self._executorSide == RoleInfo.SIDE_RIGHT then
            self._effect:setScaleY(-(self._effect:getScaleY() + self._scaleDelta*value))
        end
    end
end

function SingleFlyAction:canReplace(action) 
    return false
end

function SingleFlyAction:giveup()
    if self._effect then
        self._map:removeEffect(self._effect)
        self._effect = nil
    end
end

------------------------DieAction--------------------

function DieAction:ctor(role)
    self.type = "DieAction"
    self.finished = false
    self._role = role
end

function DieAction:execute(dt)
    if self._role.lockCount < 1 then
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        if BattleMgr.getBattle():getBattleData().type == GameType.GAME_STORY then
            local MapMgr = require("src/scene/battle/manager/MapMgr")
            local position = self._role:getCenterPositionInMap(1)
            MapMgr.checkAndDrop(self._role:getInfo().unitId,self._role:getInfo().position,position)
        end
        
        self._role:executeMotion(MotionType.DIE, nil, 0)
        self._role:getInfo():die()
        self._role:setBarVisible(false)
        self._role:setBuffVisible(false)
        self._role:clearBuffStates()
        self._role:getMap():getBattle():sendRoleDieEvent(self._role)
        
        local onNotionComplete
        onNotionComplete = function (event)
            self._role:removeEventListener(Role.EVENT_MOTION_COMPLETE2, onNotionComplete)
            
            local function fadeOutEnd()
                self._role:getMap():getBattle():removeRole(self._role)
            end
            local action = FadeOutAction.new(self._role, 3)
            action = SequenceAction.new({action}, fadeOutEnd)
            
            self._role:executeCustomAction(action)
        end

        self._role:addEventListener(Role.EVENT_MOTION_COMPLETE2, onNotionComplete)
        
        
        if not LD_EDITOR then
            local template = self._role:getInfo():getTemplate()
            if template and template.sound_failure and template.sound_failure ~= "" then
                local sound = "music/bt_sound/" .. template.sound_failure .. ".mp3"
                AudioEngine.playEffect(sound)
            end
        end
        
        self.finished = true
    end
end

function DieAction:canReplace(action) 
    return false
end

function DieAction:giveup()
end

------------------------HideRoleAction--------------------

function HideRoleAction:ctor(role,frameCount,autoReset)
    self.type = "HideRoleAction"
    self.finished = false
    self._role = role
    self._duration = frameCount*SECOND_PER_FRAME
    self._autoReset = autoReset
    self._elapsed = 0
    role:setVisible(false)
    role:setBuffVisible(false)
end

function HideRoleAction:execute(dt)
    self._elapsed = self._elapsed + dt
    if self._elapsed >= self._duration then
        if self._autoReset then
            self._role:setVisible(true)
            self._role:setBuffVisible(true)
        end
        self.finished = true
    end
end

function HideRoleAction:canReplace(action) 
    return false
end

function HideRoleAction:giveup()
end


------------------------JumpAction--------------------

--takeOffPoint 起跳时间点（毫秒）
function JumpAction:ctor(role,startPt,endPt,frameCount, moveBack,takeOffPoint)
    self.type = "JumpAction"
    self.finished = false
    
    self._role = role
    self._startPt = startPt
    self._endPt = endPt
    self._frameCount = frameCount
    self._duration = frameCount * SECOND_PER_FRAME
    self._moveBack = moveBack
    self._takeOffPoint = takeOffPoint and takeOffPoint/1000
    self._elapsed = 0

    if endPt.x > startPt.x then
        role:setDirection(Role.DIRECTION_RIGHT)
    else
        role:setDirection(Role.DIRECTION_LEFT)
    end
    role:setBarVisible(false)
    
    if not takeOffPoint or takeOffPoint <= 0 then
        self:startMove()
    end
end

function JumpAction:execute(dt)
    if self._moveAction then
        if self._moveAction.finished then
            self.finished = true
        end
    elseif self._takeOffPoint then
        self._elapsed = self._elapsed + dt
        if self._elapsed >= self._takeOffPoint then
            self:startMove()
        end
    end
end

function JumpAction:canReplace(action) 
    return false
end

function JumpAction:startMove()
    local move = BattleCustomActions.MoveAction.new(self._role,self._startPt,self._endPt,self._frameCount,self._moveBack)
    self._role:executeCustomAction(move)
    self._moveAction = move
end

function JumpAction:giveup()
    self.finished = true
    if self._moveAction then
        self._role:removeCustomAction(self._moveAction)
        self._moveAction = nil
    end
end


------------------------SpeedAdjustAction--------------------

function SpeedAdjustAction:ctor(fromSpeed, toSpeed,frameCount, tweenType, isTemp)
    self.type = "SpeedAdjustAction"
    self.finished = false
    self._fromSpeed = fromSpeed
    self._toSpeed = toSpeed
    self._delta = toSpeed - fromSpeed
    self._duration = frameCount*SECOND_PER_FRAME
    self._tweenType = tweenType
    self._isTemp = isTemp
    self._elapsed = 0
end

function SpeedAdjustAction:execute(dt)
    self._elapsed = self._elapsed + dt
    
    local time = math.max(0, math.min(1, self._elapsed/self._duration))
    if self._tweenType then
        time = TweenFunction[self._tweenType](time)
    end
    
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    if self._isTemp then
        BattleMgr.setSpeed(nil,nil, self._fromSpeed + time*self._delta)
    else
        BattleMgr.setSpeed(nil,self._fromSpeed + time*self._delta)
    end
    
    
    if self._elapsed >= self._duration then
        self.finished = true
    end
end

function SpeedAdjustAction:canReplace(action) 
    return false
end

function SpeedAdjustAction:giveup()
end


------------------------RiseAndFallAction--------------------

function RiseAndFallAction:ctor(role, fromH, toH, frameCount, tweenType, unlockFlag, spell)
    self.type = "RiseAndFallAction"
    self.finished = false
    
    self._role = role
    self._fromH = fromH
    self._toH = toH
    self._delta = toH - fromH
    
    self._duration = frameCount*SECOND_PER_FRAME
    self._tweenType = tweenType
    self._unlockFlag = unlockFlag
    self._spell = spell
    self._elapsed = 0
end

function RiseAndFallAction:execute(dt)
    self._elapsed = self._elapsed + dt

    local time = math.max(0, math.min(1, self._elapsed/self._duration))
    if self._tweenType then
        time = TweenFunction[self._tweenType](time)
    end

    self._role:setPositionH(self._fromH + time*self._delta)
    
    if self._elapsed >= self._duration then
        self.finished = true
        if self._unlockFlag then
            self._spell:unlockTargets(nil)
        end
    end
end

function RiseAndFallAction:canReplace(action) 
    return false
end

function RiseAndFallAction:giveup()
end

------------------------FlyOutAction--------------------

function FlyOutAction:ctor(role, speed, direction, friction, gravity)
    self.type = "FlyOutAction"
    self.finished = false

    self._role = role
    self._speed = speed * 100
    self._direction = direction
    self._friction = friction
    self._mass = 1;
    self._gf = gravity*300
    
    local angle = math.pi*direction/180
    self._vx = EulerVector.new(role:getPositionX(),math.cos(angle)*self._speed,0);
    self._vy = EulerVector.new(role:getPositionH(),math.sin(angle)*self._speed,0);
    
    self._role:executeMotion(MotionType.HURT, nil, 0)
end

function FlyOutAction:getNextXY(dt)
    self._vx:step(self._mass, self._friction, 0, dt);
    self._vy:step(self._mass, self._friction, self._gf, dt);
    return cc.p(self._vx.x0,self._vy.x0);  
end

function FlyOutAction:execute(dt)
    local pos = self:getNextXY(dt)
    
    local h = pos.y
    local x = pos.x
    local rect = self._role:getMap():getViewport()
    if x > rect.x + rect.width - self._role:getContentSize().width/2 then
        if self._vx.x1 < 0 then
            self._vx.x1 = -self._vx.x1
        end
        x = rect.x + rect.width - self._role:getContentSize().width/2
        self._vx.x0 = x
    elseif x < rect.x + self._role:getContentSize().width/2 then
        if self._vx.x1 > 0 then
            self._vx.x1 = -self._vx.x1
        end
        x = rect.x + self._role:getContentSize().width/2
        self._vx.x0 = x
    end

    self._role:setPositionX(x)
    if h <= 0 then
        self._role:setPositionH(0)
        local move = MoveAction.createMoveBack(self._role,5, nil, MotionType.RUN)
        self._role:executeCustomAction(move)
        self._moveAction = move
        self.finished = true
    else
        if h >  rect.height - self._role:getPositionY() - self._role:getContentSize().height then
            if self._vy.x1 < 0 then
                self._vy.x1 = self._vy.x1*-1
            end
            h = rect.height - self._role:getPositionY() - self._role:getContentSize().height
            self._vy.x0 = h
        end
        self._role:setPositionH(h)
    end
end

function FlyOutAction:canReplace(action) 
    return false
end

function FlyOutAction:giveup()
    self.finished = true
    if self._moveAction then
        self._role:removeCustomAction(self._moveAction)
        self._moveAction = nil
    end
end

------------------------MissileAction--------------------

function MissileAction:ctor(spell, frameData)
    self.type = "MissileAction"
    self.finished = true

    self._spell = spell
    self._frameData = frameData

    local action = self._frameData.action

    local function getRoleByCoord(coord, target)
        if coord == CoordSystemType.ATTACK_POS or coord == CoordSystemType.ATTACK_BOTTOM_POS then
            return spell:getExecutor()
        end
        return target
    end
    local fromX = action.fromX
    local toX = action.toX
    local executorSide = spell:getExecutor():getInfo().side
    if executorSide == RoleInfo.SIDE_RIGHT then
        fromX = -fromX
        toX = -toX
    end

    local targets = spell:getAttackTargets()
    
    local controlPoint1 = cc.p(action.controlPoint1X, action.controlPoint1Y)
    local controlPoint2 = cc.p(action.controlPoint2X, action.controlPoint2Y)

    for _, target in ipairs(targets) do
        local fromPt = PositionHelper.getPositionByCoordType(action.fromCoord,cc.p(fromX, action.fromY),getRoleByCoord(action.fromCoord,target), nil, executorSide)
        local toPt = PositionHelper.getPositionByCoordType(action.toCoord,cc.p(toX, action.toY),getRoleByCoord(action.toCoord, target), nil, executorSide)

        local single = SingleMissileAction.new(spell:getBattle():getMap(), 
            action.effect,
            fromPt,
            toPt,
            frameData.__layerData:getKeyFrameLength(frameData),
            action.fromScale,action.toScale,executorSide,action.effectSpeed,
            action.blendSrc, action.blendDst,action.tween,
            controlPoint1,controlPoint2, action.effectLevel1, action.effectLevel2)

        spell:getBattle():executeCustomAction(single)
    end
end

function MissileAction:execute(dt)
end

function MissileAction:canReplace(action) 
    return false
end

function MissileAction:giveup()
end

------------------------SingleMissileAction--------------------

function SingleMissileAction:ctor(map, effectString, startPt, endPt, frameCount, fromScale, toScale,
    executorSide, speed, blendSrc, blendDst, tweenType,controlPoint1,controlPoint2, effectLevel1, effectLevel2, dramaFlag)
    self.type = "SingleMissileAction"
    self.finished = false

    self._map = map
    
    local effect = SimpleEffect.new(effectString, true, speed,blendSrc,blendDst, nil, nil, dramaFlag, true)
    map:addEffect(effect, startPt, effectLevel1)

    self._effect = effect
    self._startPt = startPt
    self._endPt = endPt
    self._pt = cc.p(0,0)
    if effectLevel1 ~= effectLevel2 then
        self._effectLevel2 = effectLevel2
    end
    
    local dis = math.abs(startPt.x - endPt.x)
    local ptScale = dis/500
    controlPoint1 = cc.p(controlPoint1.x*ptScale, controlPoint1.y*ptScale)
    controlPoint2 = cc.p(controlPoint2.x*ptScale, controlPoint2.y*ptScale)
    if executorSide == RoleInfo.SIDE_RIGHT then
        controlPoint1.x = -controlPoint1.x
        controlPoint2.x = -controlPoint2.x
    end
    
    self._controlPt1 = cc.pAdd(startPt,controlPoint1)
    self._controlPt2 = cc.pAdd(endPt,controlPoint2)
    self._duration = frameCount * SECOND_PER_FRAME
    self._elapsed = 0

    self._fromScale = fromScale
    self._toScale = toScale
    self._scaleDelta = toScale - fromScale
    self._executorSide = executorSide;
    self._tweenType = tweenType

    if executorSide == RoleInfo.SIDE_LEFT then
        effect:setScale(fromScale)
    end
end

function SingleMissileAction:execute(dt)
    self._elapsed = self._elapsed + dt
    
    local time = math.min(1, self._elapsed/self._duration)
    if self._tweenType then
        time = TweenFunction[self._tweenType](time)
    end
    if time >= 1 or self._elapsed >= self._duration then
        self._map:removeEffect(self._effect)
        self._effect = nil
        self.finished = true
--        if LD_EDITOR then
--            for i, circle in ipairs(self._lineCircles) do
--                self._map:removeEffect(circle)
--            end
--        end
    else
        if self._effectLevel2 and not self._levelChanged and self._elapsed > self._duration/2 then
            if self._effectLevel2 == 1 then
                self._map:bringToFront(self._effect)
            else
                self._map:sendToBack(self._effect)
            end
            self._levelChanged = true
        end
        self:calcuPosition(time,self._pt)
        self._effect:setPosition(self._pt)

        local pt1 = self:calcuPosition(math.max(0, time - 0.01))

        self._effect:setRotation(math.atan2(pt1.y - self._pt.y, self._pt.x - pt1.x)*57.29577951)

        self._effect:setScale(self._fromScale + self._scaleDelta*time)
    end
end

function SingleMissileAction:calcuPosition(t, pt)
    local pt = pt or {}
    pt.x = math.pow(1 - t, 3) * self._startPt.x + 3.0 * math.pow(1 - t, 2) * t * self._controlPt1.x + 3.0 * (1 - t) * t * t * self._controlPt2.x + t * t * t * self._endPt.x;
    pt.y = math.pow(1 - t, 3) * self._startPt.y + 3.0 * math.pow(1 - t, 2) * t * self._controlPt1.y + 3.0 * (1 - t) * t * t * self._controlPt2.y + t * t * t * self._endPt.y
    return pt
end

function SingleMissileAction:canReplace(action) 
    return false
end

function SingleMissileAction:giveup()
--    if self._effect then
--        self._map:removeEffect(self._effect)
--        self._effect = nil
--    end
--    self.finished = true
end

------------------------FadeOutAction--------------------

function FadeOutAction:ctor(target, duration)
    self.type = "FadeOutAction"
    self.finished = false
    
    self._target = target
    self._duration = duration
    self._startOpacity = target:getOpacity()
    self._elapsed = 0
end

function FadeOutAction:execute(dt)
    self._elapsed = self._elapsed + dt
    if self._elapsed >= self._duration then
        self._target:setVisible(false)
        self._target:setOpacity(0)
        self.finished = true
    else
        local opacity = self._startOpacity - self._startOpacity*self._elapsed/self._duration
        self._target:setOpacity(opacity)
    end
end

function FadeOutAction:canReplace(action) 
    return false
end

function FadeOutAction:giveup()

end

------------------------FadeInAction--------------------

function FadeInAction:ctor(target, duration)
    self.type = "FadeOutAction"
    self.finished = false

    self._target = target
    self._duration = duration
    self._startOpacity = target:getOpacity()
    self._elapsed = 0
    target:setVisible(true)
end

function FadeInAction:execute(dt)
    self._elapsed = self._elapsed + dt
    if self._elapsed >= self._duration then
        self._target:setOpacity(255)
        self.finished = true
    else
        local opacity = self._startOpacity + (255 - self._startOpacity)*self._elapsed/self._duration
        self._target:setOpacity(opacity)
    end
end

function FadeInAction:canReplace(action) 
    return false
end

function FadeInAction:giveup()

end

------------------------DriftAction--------------------

--moveBack 是否是回到自己的位置
function DriftAction:ctor(role, startX, endX, startH, endH, duration, motion, motionLoop, tweenType, endMotion, unlockFlag, spell)
    self.type = "MoveAction"
    self.finished = false

    self._role = role
    self._startX = startX
    self._endX = endX
    self._deltaX = endX - self._startX
    
    self._startH = startH
    self._endH = endH
    self._deltaH = endH - self._startH
    
    self._duration = duration
    self._motion = motion
    self._motionLoop = motionLoop
    self._tweenType = tweenType
    
    self._elapsed = 0
    self._endMotion = endMotion
    self._unlockFlag = unlockFlag
    self._spell = spell
    self._firstExecute = true
end

function DriftAction:execute(dt)
    if self._firstExecute then
        if self._motion and self._motion ~= "" then
            self._role:executeMotion(self._motion,nil, self._motionLoop)
        end
        self._firstExecute = false
    end
    self._elapsed = self._elapsed + dt

    local time = math.max(0, math.min(1, self._elapsed/self._duration))
    if self._tweenType then
        time = TweenFunction[self._tweenType](time)
    end
    
    local dying = self._role:isDead() and self._role:getCurrentMotion() == MotionType.DIE

    self._role:setPositionH(self._startH + time*self._deltaH)
    if not dying then 
        self._role:setPositionXInner(self._startX + time*self._deltaX)
    end

    if self._elapsed >= self._duration then
        if self._endMotion then
            self._role:executeMotion(self._endMotion)
        end
        self._role:setPositionH(self._endH)
        if not dying then 
            self._role:setPositionXInner(self._endX)
        end
        self.finished = true
        
        if self._unlockFlag then
            self._spell:unlockTargets(nil)
        end
    end
end

function DriftAction:canReplace(action) 
    return false
end

function DriftAction:giveup()
end

------------------------InnerRotationAction--------------------

function InnerRotationAction:ctor(role, from, to, frameCount)
    self.type = "RiseAndFallAction"
    self.finished = false

    self._role = role
    self._from = from
    self._to = to
    self._delta = to - from

    self._duration = frameCount*SECOND_PER_FRAME
    self._elapsed = 0
end

function InnerRotationAction:execute(dt)
    if self._role:isDead() and self._role:getCurrentMotion() == MotionType.DIE then 
        self._role:setRotationInner(0)
        self.finished = true 
        return 
    end
    self._elapsed = self._elapsed + dt

    if self._elapsed >= self._duration then
        self.finished = true
        self._elapsed = self._duration
    end
    self._role:setRotationInner(self._from + self._elapsed/self._duration*self._delta)
end

function InnerRotationAction:canReplace(action) 
    return false
end

function InnerRotationAction:giveup()
end


------------------------RoleShakeAction--------------------

function RoleShakeAction:ctor(target, strength, frameCount, decay)
    self.type = "RoleShakeAction"
    self.finished = false

    self._target = target
    self._strength = strength
    self._frameCount = frameCount
    self._duration = frameCount*SECOND_PER_FRAME
    self._decay = decay
    self._origin = target:getPositionX()
    self._elapsed = 0
    self._count = 0
end

function RoleShakeAction:execute(dt)
    self._elapsed = self._elapsed + dt
    local reach = math.floor(self._elapsed/SECOND_PER_FRAME)
    while self._count < reach and not self.finished do
        self:shakeOnce()
    end
end
function RoleShakeAction:shakeOnce()
    if self.finished then
        return 
    end
    self._count = self._count + 1
    if self._count > self._frameCount then
        self._target:setPositionX(self._origin)
        self.finished = true
    else
        self._strength = -self._strength * self._decay
        local x = self._origin + self._strength
        self._target:setPositionX(x)
    end
end

function RoleShakeAction:canReplace(action) 
    return false
end

function RoleShakeAction:giveup()
    self._target:setPositionX(self._origin)
end


------------------------ReplaceBackgroundAction--------------------

function ReplaceBackgroundAction:ctor(map, frameData)
    self.type = "ReplaceBackgroundAction"
    self.finished = false

    self._map = map
    self._frameData = frameData
    self._duration = frameData.__layerData:getKeyFrameLength(frameData)*SECOND_PER_FRAME
    self._elapsed = 0
    self._fadeInDuration = frameData.action.fadeIn
    self._fadeOutDuration = frameData.action.fadeOut
    self._firstFlag = true
end

function ReplaceBackgroundAction:execute(dt)
    if self._firstFlag then
        self._firstFlag = false
        local eff = SimpleEffect.new(self._frameData.action.effect, true, nil, nil, nil, nil, nil,nil, true)
        local viewport = self._map:getViewport()
        local size = eff:getContentSize()
        local scale
        if viewport.width/viewport.height > size.width/size.height then
            scale = viewport.width/size.width
        else
            scale = viewport.height/size.height
        end
        eff:setAnchorPoint(0,0)
        eff:setScale(scale)
        eff:setPosition(cc.p(0, 0))
        eff:setOpacity(0)
        self._map:replaceBackground(eff)
        self._eff = eff
    end
    self._elapsed = self._elapsed + dt
    if self._elapsed > self._duration then
        self._map:removeReplaceBackground()
        self._eff = nil
        self.finished = true
    elseif self._elapsed < self._fadeInDuration then
        self._eff:setOpacity(255*self._elapsed/self._fadeInDuration)
    elseif self._elapsed > self._duration - self._fadeOutDuration then
        self._eff:setOpacity(255 - 255*(self._elapsed - self._duration + self._fadeOutDuration)/self._fadeInDuration)
    else
        self._eff:setOpacity(255)
    end
end

function ReplaceBackgroundAction:canReplace(action) 
    if action.type == self.type then
        return true
    end
    return false
end

function ReplaceBackgroundAction:giveup()
    self.finished = true
    self._map:removeReplaceBackground()
    self._eff = nil
end

------------------------RoleSpeakAction--------------------

function RoleSpeakAction:ctor(role, frameCount, words, actionData)
    self.type = "RoleSpeakAction"
    self.finished = false

    self._role = role
    self._duration = frameCount*SECOND_PER_FRAME
    self._words = words
    self._elapsed = 0
    
    role:speak(words, actionData)
end

function RoleSpeakAction:execute(dt)
    if self._elapsed >= self._duration then
        self.finished = true
        self._role:stopSpeak()
        return
    end
    self._elapsed = self._elapsed + dt
end

function RoleSpeakAction:canReplace(action) 
    if action.type == self.type then return true end
    return false
end

function RoleSpeakAction:giveup()
end
------------------------CurtainAction--------------------

function CurtainAction:ctor(map, words, duration, fadeInTime, fadeOutTime, autoClear)
    self.type = "CurtainAction"
    self.finished = false
    
    self._map = map
    self._duration = duration
    self._elapsed = 0
    self._fadeInTime = fadeInTime or 0
    self._fadeOutTime = fadeOutTime or 0
    self._autoClear = autoClear
    
    self._curtainView = self._map:playCurtain(words)
    if fadeInTime ~= 0 then
        self._curtainView:setOpacity(0)
    end
end

function CurtainAction:execute(dt)
    if self._elapsed >= self._duration then
        if self._autoClear then
            self._map:removeCurtain()
        end
        self.finished = true
        return
    end
    self._elapsed = self._elapsed + dt
    if self._fadeInTime > 0 then
        if self._elapsed < self._fadeInTime then
            local opacity = self._elapsed/self._fadeInTime* 255
            self._curtainView:setOpacity(opacity)
        else
            self._curtainView:setOpacity(255)
            self._fadeInTime = 0 --不让重复设置
        end
    end
    if self._fadeOutTime > 0 then
        if self._elapsed > self._duration - self._fadeOutTime then
            local opacity = (self._duration - self._elapsed) /self._fadeOutTime* 255
            self._curtainView:setOpacity(opacity)
        end
    end
end

function CurtainAction:canReplace(action) 
    if self.type == action.type then return true end
    return false
end

function CurtainAction:giveup()
    self.finished = true
end
------------------------DramaMovieDialogAction--------------------

function DramaMovieDialogAction:ctor(map, data, duration, autoClear)
    self.type = "DramaMovieDialogAction"
    self.finished = false
    
    self._map = map
    self._duration = duration
    self._elapsed = 0
    self._autoClear = autoClear
    
    map:playDramaMovieDialog(data)
end

function DramaMovieDialogAction:execute(dt)
    if self._elapsed >= self._duration then
        if self._autoClear then
            self._map:removeDramaMovieDialog()
        end
        self.finished = true
        return
    end
    self._elapsed = self._elapsed + dt
end

function DramaMovieDialogAction:canReplace(action) 
    if self.type == action.type then return true end
    return false
end

function DramaMovieDialogAction:giveup()
    self.finished = true
end
------------------------EffectAdjustAction--------------------

function EffectAdjustAction:ctor(effect, duration, executorSide, toAlpha, toScaleX, toScaleY, offsetX, offsetY,toRotation, anchorX, anchorY)
    self.type = "DramaMovieDialogAction"
    self.finished = false
    
    self._effect = effect
    self._duration = duration
    if executorSide == RoleInfo.SIDE_RIGHT then
        if offsetX and offsetX ~= 0 then
            offsetX = -offsetX
        end
        if toRotation then
            toRotation = -toRotation
        end
        if toScaleX then
            toScaleX = -toScaleX
        end
        if anchorX or anchorY then
--            if anchorX then
--                anchorX = 1 - anchorX
--            end
        end
    end
    if anchorX or anchorY then
        local anchor = effect:getAnchorPoint()
        local anchorX = anchorX or anchor.x
        local anchorY = anchorY or anchor.y
        local size = effect:getContentSize()
        size.width = math.abs(effect:getScaleX()) * size.width
        size.height = math.abs(effect:getScaleY()) * size.height
        if executorSide == RoleInfo.SIDE_RIGHT then
            effect:setPositionX(effect:getPositionX() + size.width*anchor.x - size.width*anchorX)
        else
            effect:setPositionX(effect:getPositionX() - size.width*anchor.x + size.width*anchorX)
        end
        effect:setPositionY(effect:getPositionY() - size.height*anchor.y + size.height*anchorY)
        effect:setAnchorPoint(anchorX, anchorY)
    end

    if toAlpha then
        self._fromAlpha = effect:getOpacity()
        self._deltaAlpha = toAlpha - self._fromAlpha
    end
    if toScaleX then
        self._fromScaleX = effect:getScaleX()
        self._deltaScaleX = toScaleX - self._fromScaleX
    end
    if toScaleY then
        self._fromScaleY = effect:getScaleY()
        self._deltaScaleY = toScaleY - self._fromScaleY
    end
    if offsetX and offsetX ~= 0 then
        self._fromX = effect:getPositionX()
        self._deltaX = offsetX
    end
    if offsetY and offsetY ~= 0 then
        self._fromY = effect:getPositionY()
        self._deltaY = offsetY
    end
    if toRotation then
        self._fromRotation = effect:getRotation()
        self._deltaRotation = toRotation - self._fromRotation
    end
    self._elapsed = 0
end

function EffectAdjustAction:execute(dt)
    if self._elapsed >= self._duration then
        self.finished = true
        return
    end
    self._elapsed = self._elapsed + dt
    local percent =  self._elapsed/self._duration
    if percent > 1 then percent = 1 end
    
    if self._deltaAlpha then
        self._effect:setOpacity(self._fromAlpha + self._deltaAlpha*percent)
    end
    if self._deltaScaleX then
        self._effect:setScaleX(self._fromScaleX + self._deltaScaleX*percent)
    end
    if self._deltaScaleY then
        self._effect:setScaleY(self._fromScaleY + self._deltaScaleY*percent)
    end
    if self._deltaX then
        self._effect:setPositionX(self._fromX + self._deltaX*percent)
    end
    if self._deltaY then
        self._effect:setPositionY(self._fromY + self._deltaY*percent)
    end
    if self._fromRotation then
        self._effect:setRotation(self._fromRotation + self._deltaRotation*percent)
    end
end

function EffectAdjustAction:canReplace(action) 
    return false
end

function EffectAdjustAction:giveup()
    self.finished = true
end

------------------------DelayCallAction--------------------

function DelayCallAction:ctor(callback, frameCount)
    self.type = "RiseAndFallAction"
    self.finished = false

    self._callback = callback
    self._duration = frameCount*SECOND_PER_FRAME
    self._elapsed = 0
end

function DelayCallAction:execute(dt)
    self._elapsed = self._elapsed + dt

    if self._elapsed >= self._duration then
        if self._callback then
            self._callback()
        end
        self.finished = true
    end
end

function DelayCallAction:canReplace(action) 
    return false
end

function DelayCallAction:giveup()
end


------------------------SequenceAction--------------------

function SequenceAction:ctor(actions, onComplete, ...)
    self.type = "SequenceAction"
    self.finished = false

    self._actions = actions
    self._onComplete = onComplete
    self.completeParams = {...}
    self._count = 1
end

function SequenceAction:execute(dt)
    local sub = self._actions[self._count]
    if sub then
        if not sub.finished then
            sub:execute(dt)
        end
        if sub.finished then
            self._count = self._count + 1
            if #self._actions < self._count then
                self:setFinished()
            end
        end
    else
        self:setFinished()
    end
end
function SequenceAction:setFinished()
    self.finished = true
    if self._onComplete then
        if self.completeParams then
            self._onComplete(unpack(self.completeParams))
        else
            self._onComplete()
        end
        self._onComplete = nil
    end
end

function SequenceAction:canReplace(action) 
    return false
end

function SequenceAction:giveup()
    for i, sub in ipairs(self._actions) do
        if not sub.finished then
            sub:giveup()
        end
    end
    self.finished = true 
end


-----------------------JoinSpellComeOut--------------------

function JoinSpellComeOut:ctor(prevSpell, nextSpell)
    self.type = "JoinSpellComeOut"
    self.finished = false

    self._nextSpell = nextSpell
    self._prevSpell = prevSpell
    
    local executor = nextSpell:getExecutor()
    local targets = nextSpell:getAttackTargets()
    local target = targets and targets[1]
    
    self.setFinished = function ()
        self.finished = true
    end
    if target and executor then
        if not nextSpell:isStandSpell() then
            local frame = nextSpell:getMoveForwardFrame()
            local executorSide = executor:getInfo().side
            local startPt = cc.p(target:getOriginPosition());
            if frame and frame.action.coord == CoordSystemType.OPPO_TEAM_CENTER then
                if executorSide == RoleInfo.SIDE_RIGHT then
                    startPt = cc.p(PositionHelper.getLeftCenter())
                else
                    startPt = cc.p(PositionHelper.getRightCenter())
                end
                startPt.y = startPt.y + frame.action.toY
            else

            end
            local endPt = cc.p(startPt.x, startPt.y)
            if executorSide == RoleInfo.SIDE_RIGHT then
                startPt.x = startPt.x + PositionHelper.JOIN_SPELL_DIS + PositionHelper.JOIN_SPELL_COME_OUT_FROM
                endPt.x = startPt.x - PositionHelper.JOIN_SPELL_COME_OUT_FROM
            else
                startPt.x = startPt.x - PositionHelper.JOIN_SPELL_DIS - PositionHelper.JOIN_SPELL_COME_OUT_FROM
                endPt.x = startPt.x + PositionHelper.JOIN_SPELL_COME_OUT_FROM
            end

            executor:setPosition(startPt)
        end
        executor:setVisible(true)
        
--        local RUN_FRAME = 15
--        
--        executor:executeMotion(MotionType.RUN)
--        local move = MoveAction.new(executor,startPt,endPt, RUN_FRAME)
--        local queue = SequenceAction.new({move}, self.setFinished)
--        executor:executeCustomAction(queue)
        self.setFinished()
        
--        if prevSpell:isStandSpell() then
--        --跑出
--            local move = MoveAction.new(prevSpell:getExecutor(),endPt,startPt, RUN_FRAME)
--            prevSpell:getExecutor():executeCustomAction(move)
--            prevSpell:getExecutor():executeMotion(MotionType.RUN)
--        end
        
        --镜头
--        local map = nextSpell:getBattle():getMap()
--        local camera = map:getCamera()
--        local position = cc.p(endPt.x, endPt.y+target:getCenterPosition().y)
--        if executorSide == RoleInfo.SIDE_RIGHT then
--            position.x = position.x - PositionHelper.JOIN_SPELL_DIS/2
--        else
--            position.x = position.x + PositionHelper.JOIN_SPELL_DIS/2
--        end
--        camera:lookAt(position,1,0,nil,true);
    else
        self.setFinished()
    end
end

function JoinSpellComeOut:execute(dt)
    
end

function JoinSpellComeOut:canReplace(action) 
    return false
end

function JoinSpellComeOut:giveup()
end

-----------------------TeamMoveAction--------------------

function TeamMoveAction:ctor(unitInfo, startX, toX, moveEnd, mapData)
    self.type = "TeamMoveAction"
    self.finished = false
    
    self._unitInfo = unitInfo
    self._startX = startX
    self._toX = toX
    self._moveEnd = moveEnd
    self._mapData = mapData
    
    self._delta = toX - startX
    self._frameCount = math.floor(math.abs(self._delta)/10)
    self._duration = self._frameCount*SECOND_PER_FRAME
    self._elapsed = 0
    self:checkTriggerDrama(startX)
end

function TeamMoveAction:checkTriggerDrama(x)
    local DramaMgr = require("src/scene/battle/manager/DramaMgr")
    if DramaMgr.checkTriggerDrama(x) then
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        local function onDramaComplete()
            self._paused = nil
            BattleMgr.getTweenMgr():setPaused(nil)
            if self._moveActions then
                for _, move in ipairs(self._moveActions) do
                    if not move.finished then
                        move:getRole():executeMotion(MotionType.RUN)
                        move:setPaused(nil)
                    end
                end
            end
        end
        self._paused = true
        BattleMgr.getTweenMgr():setPaused(true)
        if self._moveActions then
            for _, move in ipairs(self._moveActions) do
                move:getRole():executeMotion(MotionType.PREPARE)
                move:setPaused(true)
            end
        end
        DramaMgr.start(onDramaComplete)
    end
end

function TeamMoveAction:execute(dt)
    if self._paused then
        return
    end
    if self._elapsed == 0 then
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        local roles = BattleMgr.getBattle():getLeftRoles()
        self._moveActions = {}
        for i, role in ipairs(roles) do
            if not role:isDead() then
                role:executeMotion(MotionType.RUN)
                local startPt = cc.p(role:getPosition())

                local position = PositionHelper.getPositionByUnitX(RoleInfo.SIDE_LEFT, role:getInfo().position, self._toX);
                local move = MoveAction.new(role,startPt,position,self._frameCount, nil, MotionType.PREPARE, true, nil, MotionType.RUN, nil, true)
                BattleMgr.getBattle():executeCustomAction(move)
                table.insert(self._moveActions,move)
            end
        end
        
        BattleMgr.getBattle():getMap():collectAllDrops()

        local camera = BattleMgr.getBattle():getMap():getCamera()
        camera:moveTo(self._toX + PositionHelper.getLeftUnitBetweenCenter(), camera:getPositionY(),self._duration)
    end
    
    self._elapsed = self._elapsed + dt
    self:setPercent(math.min(1, self._elapsed/self._duration))
end
function TeamMoveAction:setPercent(percent)
    local x = self._startX + self._delta*percent
    self._unitInfo.x = x
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    BattleMgr.getBattle():getMap():collectDrops(x+50)
    
    if percent == 1 then
        if self._moveEnd then
            self._moveEnd()
        end
        self._moveActions = nil
        self.finished = true
    else
        self:checkTriggerDrama(x)
    end
end

function TeamMoveAction:canReplace(action) 
    return false
end

function TeamMoveAction:giveup()
    self._moveActions = nil
end
------------------------------------------------

return BattleCustomActions