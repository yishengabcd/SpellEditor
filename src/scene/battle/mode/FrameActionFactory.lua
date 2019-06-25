local SimpleEffect = require("src/scene/battle/view/SimpleEffect")
local Map = require("src/scene/battle/mode/Map")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local MotionType = require("src/scene/battle/mode/MotionType")
local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local Role = require("src/scene/battle/mode/Role")
local ActionEaseType = require("src/scene/battle/mode/ActionEaseType")
local EffectMgr = require("src/scene/battle/manager/EffectMgr")

local FrameActionFactory = {}
--出于性能考虑，以下FrameAction未采用继承方式
--设计以下类的原因是适配编辑器和正式战斗的关系，使两种情型可以共存
local FrameAction = class("FrameAction")
local MoveForwardAction = class("MoveForwardAction")
local PlayEffectAction = class("PlayEffectAction")
local PlayMotionAction = class("PlayMotionAction")
local MoveBackAction = class("MoveBackAction")
local PlaySoundAction = class("PlaySoundAction")
local BlackScreenAction = class("BlackScreenAction")
local ShakeAction = class("ShakeAction")
local HurtAction = class("HurtAction")
local FlyAction = class("FlyAction")
local MoveMapAction = class("MoveMapAction")
local ZoomMapAction = class("ZoomMapAction")
local MapResetAction = class("MapResetAction")
local FocusAction = class("FocusAction")
local JumpAction = class("JumpAction")
local JumpBackAction = class("JumpBackAction")
local HideRoleAction = class("HideRoleAction")
local SpeedAdjustAction = class("SpeedAdjustAction")
local AddAfterimageAction = class("AddAfterimageAction")
local RemoveAfterimageAction = class("RemoveAfterimageAction")
local RiseAction = class("RiseAction")
local FallAction = class("FallAction")
local FlyOutAction = class("FlyOutAction")
local ChangeColorAction = class("ChangeColorAction")
local ChangePositionAction = class("ChangePositionAction")
local BodySeparateAction = class("BodySeparateAction")
local MissileAction = class("MissileAction")
local CreateCopyAction = class("CreateCopyAction")
local RemoveCopyAction = class("RemoveCopyAction")
local FlyOffAction = class("FlyOffAction")
local RotationAction = class("RotationAction")
local RoleShakeAction = class("RoleShakeAction")
local AddGhostShadowAction = class("AddGhostShadowAction")
local RemoveGhostShadowAction = class("RemoveGhostShadowAction")
local ReplaceBackgroundAction = class("ReplaceBackgroundAction")
local LevelAdjustAction = class("LevelAdjustAction")
local CallRoleAction = class("CallRoleAction")
local RemoveRoleAction = class("RemoveRoleAction")
local EffectAdjustAction = class("EffectAdjustAction")


local winSize = cc.Director:getInstance():getVisibleSize();

--创建帧动作
function FrameActionFactory.create(spell, frameData)
    local type = frameData.action.type
    
    if type == FrameActionType.MOVE_FORWARD then
        return MoveForwardAction.new(spell, frameData)
    elseif type == FrameActionType.PLAY_ACTION then
        return PlayMotionAction.new(spell, frameData)
    elseif type == FrameActionType.PLAY_EFFECT then
        return PlayEffectAction.new(spell, frameData)
    elseif type == FrameActionType.FLY_EFFECT then
        return FlyAction.new(spell, frameData)
    elseif type == FrameActionType.HURT then
        return HurtAction.new(spell, frameData)
    elseif type == FrameActionType.MOVE_BACK then
        return MoveBackAction.new(spell, frameData)
    elseif type == FrameActionType.BLACK_SCREEN then
        return BlackScreenAction.new(spell, frameData)
    elseif type == FrameActionType.PLAY_SOUND then
        return PlaySoundAction.new(spell, frameData)
    elseif type == FrameActionType.SHAKE then
        return ShakeAction.new(spell, frameData)
    elseif type == FrameActionType.MOVE_MAP then
        return MoveMapAction.new(spell, frameData)
    elseif type == FrameActionType.ZOOM_MAP then
        return ZoomMapAction.new(spell, frameData)
    elseif type == FrameActionType.MAP_RESET then
        return MapResetAction.new(spell, frameData)
    elseif type == FrameActionType.FOCUS then
        return FocusAction.new(spell, frameData)
    elseif type == FrameActionType.JUMP then
        return JumpAction.new(spell, frameData)
    elseif type == FrameActionType.JUMP_BACK then
        return JumpBackAction.new(spell, frameData)
    elseif type == FrameActionType.HIDE_ROLE then
        return HideRoleAction.new(spell, frameData)
    elseif type == FrameActionType.SPEED_ADJUST then
        return SpeedAdjustAction.new(spell, frameData)
    elseif type == FrameActionType.ADD_AFTERIMAGE then
        return AddAfterimageAction.new(spell, frameData)
    elseif type == FrameActionType.REMOVE_AFTERIAGE then
        return RemoveAfterimageAction.new(spell, frameData)
    elseif type == FrameActionType.RISE then
        return RiseAction.new(spell, frameData)
    elseif type == FrameActionType.FALL then
        return FallAction.new(spell, frameData)
    elseif type == FrameActionType.FLY_OUT then
        return FlyOutAction.new(spell, frameData)
    elseif type == FrameActionType.CHANGE_COLOR then
        return ChangeColorAction.new(spell, frameData)
    elseif type == FrameActionType.CHANGE_POSITION then
        return ChangePositionAction.new(spell, frameData)
    elseif type == FrameActionType.BODY_SEPARATE then
        return BodySeparateAction.new(spell, frameData)
    elseif type == FrameActionType.MISSILE then
        return MissileAction.new(spell, frameData)
    elseif type == FrameActionType.CREATE_COPY then
        return CreateCopyAction.new(spell, frameData)
    elseif type == FrameActionType.REMOVE_COPY then
        return RemoveCopyAction.new(spell, frameData)
    elseif type == FrameActionType.FLY_OFF then
        return FlyOffAction.new(spell, frameData)
    elseif type == FrameActionType.ROTATION then
        return RotationAction.new(spell, frameData)
    elseif type == FrameActionType.ROLE_SHAKE then
        return RoleShakeAction.new(spell, frameData)
    elseif type == FrameActionType.ADD_GHOST_SHADOW then
        return AddGhostShadowAction.new(spell, frameData)
    elseif type == FrameActionType.REMOVE_GHOST_SHADOW then
        return RemoveGhostShadowAction.new(spell, frameData)
    elseif type == FrameActionType.REPLACE_BACKGROUND then
        return ReplaceBackgroundAction.new(spell, frameData)
    elseif type == FrameActionType.LEVEL_ADJUST then
        return LevelAdjustAction.new(spell, frameData)
    elseif type == FrameActionType.CALL_ROLE then
        return CallRoleAction.new(spell, frameData)
    elseif type == FrameActionType.REMOVE_ROLE then
        return RemoveRoleAction.new(spell, frameData)
    elseif type == FrameActionType.EFFECT_ADJUST then
        return EffectAdjustAction.new(spell, frameData)
    elseif type == FrameActionType.FINISH then

    end
    return nil
end


--将帧转换为时间
local function transFrameToSecend(frame)
    return frame/30
end

--获得动作的控制的角色列色
local function getControlRoles(spell, frameData, roles)
    local roles = roles or {}
    local action = frameData.action
    local ids = string.split(action.controlIds, ",")
    if action.controlIds == "-1" then
        local targets = spell:getAttackTargets()
        for _, target in ipairs(targets) do
            table.insert(roles, target)
        end
    else
        local uniqueIds = {}
        for _, id in ipairs(ids) do
            local exist = false
            for _, id2 in ipairs(uniqueIds) do
                if id == id2 then
                    exist = true
                    break
                end
            end
            if not exist then
                table.insert(uniqueIds,id)
            end
        end
        for _, id in ipairs(uniqueIds) do
            if id == "" then
                table.insert(roles, spell:getExecutor())
            else
                local role = spell:getCopyByID(id)
                if not role then
                    role = spell:getTempRole(id)
                end
                if role then
                    table.insert(roles,role)
                end
            end
        end
    end
    return roles
end
----------------------------FrameAction---------------------------
--模板类，其他类参考此类
function FrameAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

--为编辑器提供的方法
function FrameAction:setFrame(frame)
end

function FrameAction:dispose()
end

function FrameAction:run(followSpell)
end


----------------------------PlayEffectAction---------------------------
function PlayEffectAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function PlayEffectAction:setFrame(frame)
    self:addEffect(true)
end
local effectstorage = {}
local function cacheEffectForEditor(eff)
    effectstorage[#effectstorage + 1] = eff
end
local function clearCacheEffects()
    for i, eff in ipairs(effectstorage) do
        eff:getParent():removeChild(eff, true)
    end
    effectstorage = {}
end
function PlayEffectAction:addEffect(editorFlag)
    local action = self._frameData.action
    local scale = tonumber(action.scale)
    local scaleX 
    local position = cc.p(action.x, action.y);
    local executorSide = self._spell:getExecutor():getInfo().side
    if executorSide == RoleInfo.SIDE_RIGHT then
        position.x = -position.x
        if scale then
            scaleX = -scale
        else
            scaleX = -1
        end
    end
    
    if LD_EDITOR then
        if not cc.FileUtils:getInstance():isFileExist(action.effect .. ".animate.plist") then
            Message.show("不存在此特效文件：" .. action.effect)
            return
        end
    end
    
    local flipX = action.flipX == 1 and -1 or 1
    
    local effs = {}
    
    local function createEff(individualScaleX, isCallRole)
        local individualScaleX = individualScaleX or scaleX
        local eff
        if editorFlag then
            eff = SimpleEffect.new(action.effect, true,action.effectSpeed, action.blendSrc, action.blendDst)
            if not isCallRole then
                cacheEffectForEditor(eff)
            end
        else
            if action.duration and action.duration > 0 then
                eff = SimpleEffect.new(action.effect, true,action.effectSpeed, action.blendSrc, action.blendDst, action.duration, nil, nil, true)
            else
                eff = SimpleEffect.new(action.effect, false,action.effectSpeed, action.blendSrc, action.blendDst, nil, nil, nil, true)
            end
        end
        if not editorFlag and action.id and action.id ~= "" then
            local id = self._spell:getSpellData().index .. "_" .. action.id
            eff.name = id
        end
        if scale and scale ~= 1 then
            eff:setScale(scale)
        end
        if individualScaleX then
            eff:setScaleX(individualScaleX)
        end
        if flipX == -1 then
            eff:setScaleX(eff:getScaleX() * flipX)
        end
        local rotation = action.rotation
        if rotation and rotation ~= 0 then
            if executorSide == RoleInfo.SIDE_RIGHT then
                rotation = -rotation
            end
            eff:setRotation(rotation);

            table.insert(effs,eff)
        end
        return eff
    end
    
    local showInMap = action.showInMap == 1 and true or false

    if action.coord == CoordSystemType.SCREEN_CENTER
        or action.coord == CoordSystemType.MY_TEAM_CENTER
        or action.coord == CoordSystemType.OPPO_TEAM_CENTER then
        local eff = createEff()
        position = PositionHelper.getPositionForEffect(action.coord,position,executorSide)
        self._spell:getBattle():getMap():addEffect(eff, position, action.effectLevel,action.effectLevelAddition)
    elseif action.coord == CoordSystemType.ATTACK_POS or action.coord == CoordSystemType.ATTACK_BOTTOM_POS then
        local roles = {}

        if action.controlIds and action.controlIds ~= "" then
            roles = getControlRoles(self._spell, self._frameData, roles)
        else
            table.insert(roles,self._spell:getExecutor())
        end

        if self._spell:getBodySeparateMgr() then
            local ghosts = self._spell:getBodySeparateMgr():getGhosts()
            for i, ghost in ipairs(ghosts) do
                table.insert(roles, ghost)
            end
        end
        for i, role in ipairs(roles) do
            local individualScaleX
            local position = cc.p(action.x, action.y);
            if role:getDirection() == Role.DIRECTION_LEFT then
                position.x = -position.x
                if scale then
                    individualScaleX = -scale
                else
                    individualScaleX = -1
                end
            elseif showInMap then
                if scale then
                    individualScaleX = scale
                else
                    individualScaleX = 1
                end
            end
            local eff = createEff(individualScaleX, role:getInfo().callId)
            local pt = PositionHelper.getPositionForEffect(action.coord,position,executorSide, role, nil, nil, showInMap)
            if showInMap then
                self._spell:getBattle():getMap():addEffect(eff, pt, action.effectLevel,action.effectLevelAddition)
            else
                role:addEffect(eff, pt, action.effectLevel,action.effectLevelAddition)
            end
        end

    elseif action.coord == CoordSystemType.BEATTACK_POS or action.coord == CoordSystemType.BEATTACK_BOTTOM_POS then
        local targets = self._spell:getAttackTargets()
        for _, target in ipairs(targets) do
            local eff = createEff()
            local pt = PositionHelper.getPositionForEffect(action.coord,position,executorSide, target, nil, action.bodyLocation, showInMap)
            if showInMap then
                self._spell:getBattle():getMap():addEffect(eff, pt, action.effectLevel,action.effectLevelAddition)
            else
                target:addEffect(eff, pt, action.effectLevel,action.effectLevelAddition)
            end
        end
    end
end

function PlayEffectAction:dispose()
    clearCacheEffects()
end

function PlayEffectAction:run(followSpell)
    self:addEffect(false)
end

----------------------------HurtAction---------------------------
function HurtAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function HurtAction:setFrame(frame)
    local action = self._frameData.action
    if action.effect ~= "" then
        PlayEffectAction.addEffect(self,true)
    end
    if action.coord ~= CoordSystemType.ATTACK_POS and action.coord ~= CoordSystemType.ATTACK_BOTTOM_POS then
        local targets = self._spell:getAttackTargets()
        local motion = action.motion or MotionType.HURT
        if motion ~= "" then
           for _, target in ipairs(targets) do
                target:executeMotion(motion,nil,nil,nil,action.startFrame)
           end
        end
    end
end
function HurtAction:run(followSpell)
    local action = self._frameData.action
    if action.effect ~= "" then
        PlayEffectAction.addEffect(self,false)
    end
    
    local motion = action.motion or MotionType.HURT
    if motion ~= "" then
        local loop = -1
        if action.playStandWhenEnd == 0 then
            loop = 0
        end
        
        self._spell:takeEffect(1, motion, loop, action.startFrame, action.bloodX, action.bloodY)
        
        if loop == 0 then
            local hasFollow = self._spell:getTemplate():checkHasKeyFrameOfType(self._frameData.__layerData:getKeyFrameLength(self._frameData)+self._frameData.index, FrameActionType.HURT)
            if not hasFollow then
                self._needReset = true
                local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
                local function resetMotion()
                    if not self._needReset then return end
                    local targets = self._spell:getAttackTargets()
                    for _, target in ipairs(targets) do
                        if not target:getSpellExecuting() then
                            if not target:getIsMoving() then
                                target:executeMotion(MotionType.PREPARE)
                            end
                        end
                    end
                end
                local proxyRole = self._spell:getAttackTargets()[1]
                local delayCall = BattleCustomActions.DelayCallAction.new(resetMotion, frameCount)
                proxyRole:executeCustomAction(delayCall)

                if #self._spell:getAttackTargets() == 1 then
                    local onMotionChanged
                    onMotionChanged = function (event)
                        proxyRole:removeEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
                        self._needReset = nil
                    end

                    proxyRole:addEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
                end
            end
        end
    else
        self._spell:takeEffect(1, nil, nil, nil, action.bloodX, action.bloodY)
    end
end
function HurtAction:dispose()
    local action = self._frameData.action
    
    clearCacheEffects()

    if action and action.coord ~= CoordSystemType.ATTACK_POS and action.coord ~= CoordSystemType.ATTACK_BOTTOM_POS then
        local targets = self._spell:getAttackTargets()
        for _, target in ipairs(targets) do
            target:executeMotion(MotionType.PREPARE)
        end
    end
end

----------------------------FlyAction---------------------------
function FlyAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function FlyAction:setFrame(frame)
    self._action = self:run()
end


function FlyAction:dispose()
    self._spell:getBattle():removeCustomAction(self._action)
end

function FlyAction:run(followSpell)
    local fly = BattleCustomActions.FlyAction.new(self._spell, self._frameData)
    self._spell:getBattle():executeCustomAction(fly)
    
    return fly
end

----------------------------MoveForwardAction---------------------------
function  MoveForwardAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function MoveForwardAction:setFrame(frame)
    self:run()
end

function MoveForwardAction:run(followSpell)
    local action = self._frameData.action

    local position = cc.p(action.toX, action.toY);
    if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
        position.x = -position.x
    end
    
    if action.coord == CoordSystemType.SCREEN_CENTER then
        position = cc.pAdd(PositionHelper.getCenter(),position)
    elseif action.coord == CoordSystemType.MY_TEAM_CENTER then
        if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(PositionHelper.getRightCenter(),position)
        else
            position = cc.pAdd(PositionHelper.getLeftCenter(),position)
        end
    elseif action.coord == CoordSystemType.OPPO_TEAM_CENTER then
        if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(PositionHelper.getLeftCenter(),position)
        else
            position = cc.pAdd(PositionHelper.getRightCenter(),position)
        end
    elseif action.coord == CoordSystemType.ATTACK_POS or action.coord == CoordSystemType.ATTACK_BOTTOM_POS then
        local role = self._spell:getExecutor()
        position = cc.pAdd(cc.p(role:getPosition()),position)
    elseif action.coord == CoordSystemType.BEATTACK_POS or action.coord == CoordSystemType.BEATTACK_BOTTOM_POS then
        local targets = self._spell:getAttackTargets()
        local role = targets and targets[1]
        if role then
            position = cc.pAdd(cc.p(role:getOriginPosition()),position)
        end
    end

    local role = self._spell:getExecutor()
    local motion = action.motion or MotionType.RUN
    motion = motion ~= "" and motion or MotionType.RUN
    role:executeMotion(motion)
    local startPt = cc.p(role:getPosition())
    local move = BattleCustomActions.MoveAction.new(role,startPt,position,self._frameData.__layerData:getKeyFrameLength(self._frameData), nil, nil, nil, true)

    role:executeCustomAction(move)
    self._action = move
end

function MoveForwardAction:dispose()
    local role = self._spell:getExecutor()
    role:removeCustomAction(self._action)
    
    role:setPosition(PositionHelper.getLeft(role:getInfo().position))
    role:executeMotion(MotionType.PREPARE)
end

----------------------------MoveBackAction---------------------------
function  MoveBackAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function MoveBackAction:setFrame(frame)
end

function MoveBackAction:run(followSpell)
    local action = self._frameData.action
    local role = self._spell:getExecutor()
    
    local move = nil
    
    if followSpell then
        position = self._spell:getAttackTargetPosition()
        if role:getInfo().side == RoleInfo.SIDE_LEFT then
            position.x = position.x - PositionHelper.JOIN_SPELL_DIS - PositionHelper.JOIN_SPELL_RUN_AWAY_TO
        else
            position.x = position.x + PositionHelper.JOIN_SPELL_DIS + PositionHelper.JOIN_SPELL_RUN_AWAY_TO
        end
        
        local startPt = cc.p(role:getPosition())
        move = BattleCustomActions.MoveAction.new(role,startPt,position,self._frameData.__layerData:getKeyFrameLength(self._frameData)+10)
    else
        move = BattleCustomActions.MoveAction.createMoveBack(role, self._frameData.__layerData:getKeyFrameLength(self._frameData))
    end
    local motion = action.motion or MotionType.RUN
    motion = motion ~= "" and motion or MotionType.RUN
    role:executeMotion(motion)
    role:executeCustomAction(move)
    self._action = move
end

function MoveBackAction:dispose()
end

----------------------------PlayMotionAction---------------------------
function  PlayMotionAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function PlayMotionAction:setFrame(frame)
    local action = self._frameData.action
    if action.motion and action.motion ~= "" then
        local roles = {}

        if action.controlIds and action.controlIds ~= "" then
            roles = getControlRoles(self._spell, self._frameData, roles)
        else
            table.insert(roles,self._spell:getExecutor())
        end
        for i, role in ipairs(roles) do
            role:executeMotion(action.motion, action.transition,nil,nil,action.startFrame)
        end
    end
end

function PlayMotionAction:dispose()
    local role = self._spell:getExecutor()
    role:executeMotion(MotionType.PREPARE)
end

function PlayMotionAction:run(followSpell)
    local action = self._frameData.action
    
    if action.motion and action.motion ~= "" then
        local roles = {}
        
        if action.controlIds and action.controlIds ~= "" then
            roles = getControlRoles(self._spell, self._frameData, roles)
        else
            table.insert(roles,self._spell:getExecutor())
        end
        
        if self._spell:getBodySeparateMgr() then
            local ghosts = self._spell:getBodySeparateMgr():getGhosts()
            for i, ghost in ipairs(ghosts) do
                table.insert(roles, ghost)
            end
        end
        
        local loop = -1
        if action.playStandWhenEnd == 0 and action.loop ~= 1 then
            loop = 0
        end
        
        for i, role in ipairs(roles) do
            role:executeMotion(action.motion, action.transition, loop,nil, action.startFrame)
            
            if action.loop ~= 1 then
                local onNotionComplete
                local onMotionChanged
                onNotionComplete = function (event)
                    if action.playStandWhenEnd == nil or action.playStandWhenEnd ~= 0 then
                        if not role:getIsMoving() then
                            role:executeMotion(MotionType.PREPARE)
                        end
                    end
                    role:removeEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
                    role:removeEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
                end

                onMotionChanged = function (event)
                    role:removeEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
                    role:removeEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
                end

                role:addEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
                role:addEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
            end
        end
    end
end



----------------------------PlaySoundAction---------------------------
function  PlaySoundAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function PlaySoundAction:setFrame(frame)
end

function PlaySoundAction:dispose()
end

function PlaySoundAction:run(followSpell)
    local action = self._frameData.action
    
    if action.sound and action.sound ~= "" and PLATFORM ~= "win32" then
        AudioEngine.playEffect("music/bt_sound/" .. action.sound .. ".mp3")
    end
end


----------------------------BlackScreenAction---------------------------
function  BlackScreenAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function BlackScreenAction:setFrame(frame)
    local action = self._frameData.action
    local color
    if action.colorR and action.colorG and action.colorB then
        color = cc.c3b(action.colorR,action.colorG,action.colorB)
    end
    self._spell:getBattle():getMap():setBlackScreen(action.alpha, color)
end

function BlackScreenAction:dispose()
    self._spell:getBattle():getMap():setBlackScreen(0)
end

function BlackScreenAction:run(followSpell)
    local action = self._frameData.action
    if action.alpha == 0 and (action.toAlpha == nil or action.toAlpha == 0) then return end
    
    local autoReset = not (self._spell:getSpellData().isActive or self._spell:getSpellData().isJoin or followSpell)
    if autoReset then
        local hasFollow = self._spell:getTemplate():checkHasKeyFrameOfType(self._frameData.__layerData:getKeyFrameLength(self._frameData)+self._frameData.index, FrameActionType.BLACK_SCREEN)
        autoReset = not hasFollow;
    end
    local color
    if action.colorR and action.colorG and action.colorB then
        color = cc.c3b(action.colorR,action.colorG,action.colorB)
    end
    local black = BattleCustomActions.BlackScreenAction.new(self._spell:getBattle():getMap(),action.alpha,action.toAlpha, self._frameData.__layerData:getKeyFrameLength(self._frameData),color,autoReset)
    self._spell:getBattle():executeCustomAction(black)
end

----------------------------ShakeAction---------------------------
function  ShakeAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function ShakeAction:setFrame(frame)
    self:run()
end

function ShakeAction:dispose()
    self._spell:getBattle():removeCustomAction(self._shake)
end

function ShakeAction:run(followSpell)
    local action = self._frameData.action
    
    local shake = BattleCustomActions.ShakeAction.new(self._spell:getBattle():getMap(),action.strength,self._frameData.__layerData:getKeyFrameLength(self._frameData),action.decay)
    self._spell:getBattle():executeCustomAction(shake)
    self._shake = shake
end

----------------------------MoveMapAction---------------------------
function  MoveMapAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function MoveMapAction:setFrame(frame)
    self:run()
end

function MoveMapAction:dispose()
    local camera = self._spell:getBattle():getMap():getCamera()
    camera:reset()
end

function MoveMapAction:run(followSpell)
    if self._spell.tailActionsIgnored_camera then return end
    local action = self._frameData.action
    local camera = self._spell:getBattle():getMap():getCamera()
    local offsetX = action.offsetX
    if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
        offsetX = -offsetX
    end
    
    local forceCenter = action.forceCenter == 1 and true or false
    camera:moveTo(camera:getPositionX()+offsetX, camera:getPositionY(), transFrameToSecend(self._frameData.__layerData:getKeyFrameLength(self._frameData)),action.tween, forceCenter);
end

----------------------------ZoomMapAction---------------------------
function  ZoomMapAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function ZoomMapAction:setFrame(frame)
    self:run()
end

function ZoomMapAction:dispose()
    local camera = self._spell:getBattle():getMap():getCamera()
    camera:reset()
end

function ZoomMapAction:run(followSpell)
    if self._spell.tailActionsIgnored_camera then return end
    local action = self._frameData.action
    local camera = self._spell:getBattle():getMap():getCamera()
    local position = cc.p(action.centerX, action.centerY)
    if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
        position.x = -position.x
    end
    position = PositionHelper.getPositionByCoordType(action.coord,position,self._spell:getExecutor(), nil, self._spell:getExecutor():getInfo().side)
    position = camera:getScreenPoint(position)
    
    local forceCenter = action.forceCenter == 1 and true or false
    local zoom = action.zoom > 1 and action.zoom or 1
    camera:zoomTo(zoom, transFrameToSecend(self._frameData.__layerData:getKeyFrameLength(self._frameData)),action.tween,position,forceCenter);
end

----------------------------MapResetAction---------------------------
function  MapResetAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function MapResetAction:setFrame(frame)
    self:run()
end

function MapResetAction:dispose()
    local camera = self._spell:getBattle():getMap():getCamera()
    camera:reset()
end

function MapResetAction:run(followSpell)
    if self._spell.tailActionsIgnored_camera then return end
--    if followSpell then
--        return
--    end
    local action = self._frameData.action
    local forceCenter = action.forceCenter == 1 and true or false
    self._spell:getBattle():getMap():resetCamera(transFrameToSecend(self._frameData.__layerData:getKeyFrameLength(self._frameData)),action.tween, forceCenter)
end

----------------------------FocusAction---------------------------
function  FocusAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function FocusAction:setFrame(frame)
    self:run()
end

function FocusAction:dispose()
    local camera = self._spell:getBattle():getMap():getCamera()
    camera:reset()
end

function FocusAction:run(followSpell)
    if self._spell.tailActionsIgnored_camera then return end
    local action = self._frameData.action
    local camera = self._spell:getBattle():getMap():getCamera()
    
    local position
    if action.toX and action.toY then
        position = cc.p(action.toX, action.toY);
    else
        position = self._spell:getExecutor():getCenterPositionInMap()
    end
    if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
        position.x = -position.x
    end
    local role = self._spell:getExecutor()
    if action.coord == CoordSystemType.BEATTACK_POS or action.coord == CoordSystemType.BEATTACK_BOTTOM_POS then
        local targets = self._spell:getAttackTargets()
        role = targets and targets[1]
    end
    if action.coord == CoordSystemType.MIDDLE_ATTACK_BEATTACK then
        local targets = self._spell:getAttackTargets()
        local attacker = self._spell:getExecutor()
        local beattacker = targets and targets[1]
        if beattacker then
            local centerPos = cc.pSub(beattacker:getCenterPositionInMap(),attacker:getCenterPositionInMap())
            centerPos = cc.pAdd(attacker:getCenterPositionInMap(),cc.p(centerPos.x/2, centerPos.y/2))
            position = cc.pAdd(centerPos,position)
        end
    else
        position = PositionHelper.getPositionByCoordType(action.coord,position,role, nil, self._spell:getExecutor():getInfo().side)
    end
    
    local forceCenter = action.forceCenter == 1 and true or false
    local zoom = action.zoom > 1 and action.zoom or 1
    camera:lookAt(position, zoom, transFrameToSecend(self._frameData.__layerData:getKeyFrameLength(self._frameData)),action.tween,forceCenter)
end


----------------------------JumpAction---------------------------
function  JumpAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function JumpAction:setFrame(frame)
    self:run()
end

function JumpAction:run(followSpell)
    local action = self._frameData.action

    local position = cc.p(action.toX, action.toY);
    if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
        position.x = -position.x
    end

    if action.coord == CoordSystemType.SCREEN_CENTER then
        position = cc.pAdd(PositionHelper.getCenter(),position)
    elseif action.coord == CoordSystemType.MY_TEAM_CENTER then
        if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(PositionHelper.getRightCenter(),position)
        else
            position = cc.pAdd(PositionHelper.getLeftCenter(),position)
        end
    elseif action.coord == CoordSystemType.OPPO_TEAM_CENTER then
        if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(PositionHelper.getLeftCenter(),position)
        else
            position = cc.pAdd(PositionHelper.getRightCenter(),position)
        end
    elseif action.coord == CoordSystemType.ATTACK_POS or action.coord == CoordSystemType.ATTACK_BOTTOM_POS then
        local role = self._spell:getExecutor()
        position = cc.pAdd(cc.p(role:getPosition()),position)
    elseif action.coord == CoordSystemType.BEATTACK_POS or action.coord == CoordSystemType.BEATTACK_BOTTOM_POS then
        local targets = self._spell:getAttackTargets()
        local role = targets and targets[1]
        if role then
            position = cc.pAdd(cc.p(role:getPosition()),position)
        end
    end

    local role = self._spell:getExecutor()
    local motion = action.motion or MotionType.JUMP
    role:executeMotion(motion, nil, nil, nil, action.startFrame)
    
    local onNotionComplete
    local onMotionChanged
    
    onNotionComplete = function (event)
        if not role:getIsMoving() then
            role:executeMotion(MotionType.PREPARE)
        end
        role:removeEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
        role:removeEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
    end
    
    onMotionChanged = function (event)
        role:removeEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
        role:removeEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
    end

    role:addEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
    role:addEventListener(Role.EVENT_MOTION_CHANGED, onMotionChanged)
    
    local startPt = cc.p(role:getPosition())
    local jump = BattleCustomActions.JumpAction.new(role,
        startPt,
        position,
        self._frameData.__layerData:getKeyFrameLength(self._frameData), 
        false, 
        action.takeOffPoint)

    role:executeCustomAction(jump)
    self._action = jump
end

function JumpAction:dispose()
    if self._action then
        self._action:giveup()
    end
    local role = self._spell:getExecutor()
    role:removeCustomAction(self._action)
    
    role:setPosition(PositionHelper.getLeft(role:getInfo().position))
    role:executeMotion(MotionType.PREPARE)
end

----------------------------JumpBackAction---------------------------
function  JumpBackAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function JumpBackAction:setFrame(frame)
    local targets = self._spell:getAttackTargets()
    local role = targets and targets[1]
    if role then
        local position = cc.pAdd(cc.p(role:getPosition()),cc.p(-160,0))
        self._spell:getExecutor():setPosition(position)
    end
    self:run()
end

function JumpBackAction:run(followSpell)
    local action = self._frameData.action
    local role = self._spell:getExecutor()

    local position
    local jump
    if followSpell then
        position = self._spell:getAttackTargetPosition()
        if role:getInfo().side == RoleInfo.SIDE_LEFT then
            position.x = position.x - PositionHelper.JOIN_SPELL_DIS - PositionHelper.JOIN_SPELL_RUN_AWAY_TO
        else
            position.x = position.x + PositionHelper.JOIN_SPELL_DIS + PositionHelper.JOIN_SPELL_RUN_AWAY_TO
        end
    else
        if role:getInfo().side == RoleInfo.SIDE_LEFT then
            position = PositionHelper.getLeft(role:getInfo().position)
        else
            position = PositionHelper.getRight(role:getInfo().position)
        end
    end
    
    local motion = action.motion or MotionType.JUMP
    role:executeMotion(motion, nil, nil, nil, action.startFrame)
    local startPt = cc.p(role:getPosition())

    jump = BattleCustomActions.JumpAction.new(role,startPt,position,self._frameData.__layerData:getKeyFrameLength(self._frameData), true,action.takeOffPoint)

    role:executeCustomAction(jump)
    self._action = jump
end

function JumpBackAction:dispose()
    if self._action then
        self._action:giveup()
    end
    local role = self._spell:getExecutor()
    role:removeCustomAction(self._action)
    
    role:setPosition(PositionHelper.getLeft(role:getInfo().position))
    role:executeMotion(MotionType.PREPARE)
end

----------------------------HideRoleAction---------------------------
function  HideRoleAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function HideRoleAction:setFrame(frame)

end

function HideRoleAction:run(followSpell)
    local action = self._frameData.action
    local role = self._spell:getExecutor()
    
    local hasFollow = self._spell:getTemplate():checkHasKeyFrameOfType(self._frameData.__layerData:getKeyFrameLength(self._frameData)+self._frameData.index, FrameActionType.HIDE_ROLE)
    local autoReset = not hasFollow;
    
    local hide = BattleCustomActions.HideRoleAction.new(role, self._frameData.__layerData:getKeyFrameLength(self._frameData), autoReset)
    role:executeCustomAction(hide)
end

function HideRoleAction:dispose()
end


----------------------------SpeedAdjustAction---------------------------
function  SpeedAdjustAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function SpeedAdjustAction:setFrame(frame)
    self:run()
end

function SpeedAdjustAction:run(followSpell)
    if self._spell.tailActionsIgnored_speed then return end
    local action = self._frameData.action

    local speed = BattleCustomActions.SpeedAdjustAction.new(action.fromSpeed, action.toSpeed, self._frameData.__layerData:getKeyFrameLength(self._frameData),action.tween)
    self._spell:getBattle():executeCustomAction(speed)
    self._speedAction = speed
end

function SpeedAdjustAction:dispose()
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    BattleMgr.setSpeed(nil,1)
    if self._speedAction then
        self._spell:getBattle():removeCustomAction(self._speedAction)
        self._speedAction = nil
    end
end


----------------------------AddAfterimageAction---------------------------
function  AddAfterimageAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function AddAfterimageAction:setFrame(frame)
    self:run()
end

function AddAfterimageAction:run(followSpell)
--    local action = self._frameData.action
    local role = self._spell:getExecutor()

    role:showAfterimage()
end

function AddAfterimageAction:dispose()
    local role = self._spell:getExecutor()
    role:clearAfterimage()
end

----------------------------RemoveAfterimageAction---------------------------
function  RemoveAfterimageAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function RemoveAfterimageAction:setFrame(frame)

end

function RemoveAfterimageAction:run(followSpell)
    local role = self._spell:getExecutor()
    role:clearAfterimage()
end

function RemoveAfterimageAction:dispose()
end

----------------------------RiseAction---------------------------
function  RiseAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function RiseAction:setFrame(frame)
    self:run()
end

function RiseAction:run(followSpell)
    if self._spell._firstRiseFrameIndex == self._frameData.index then
        return
    end
    local action = self._frameData.action
    local roles = {}

    if action.controlIds and action.controlIds ~= "" and action.targetType ~= 2 then
        roles = getControlRoles(self._spell, self._frameData, roles)
    else
        if action.targetType == 2 then
            local targets = self._spell:getAttackTargets()
            for i, m in ipairs(targets) do
                table.insert(roles,m)
            end
        else
            local role = self._spell:getExecutor()
            table.insert(roles,role)
        end
    end
    
    local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
    
    local acts = {}
    for i, role in ipairs(roles) do
    --TODO @gavin
        if role and role.getPositionH then
            local act = BattleCustomActions.RiseAndFallAction.new(role, role:getPositionH(), action.height,frameCount,action.tween)
            role:executeCustomAction(act)
            acts[#acts+1] = act
        end
    end
    self._acts = acts
end

function RiseAction:dispose()
    if self._acts then
        for i, act in ipairs(self._acts) do
            if act._role == self._spell:getExecutor() then
                act._role:setPositionH(0)
                act._role:removeCustomAction(act)
            end
        end
    end
    self._acts = nil
end

----------------------------FallAction---------------------------
function  FallAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function FallAction:setFrame(frame)
--    self:run()
end

function FallAction:run(followSpell)
    local action = self._frameData.action
    
    local roles = {}

    if action.controlIds and action.controlIds ~= "" and action.targetType ~= 2 then
        roles = getControlRoles(self._spell, self._frameData, roles)
    else
        if action.targetType == 2 then
            local targets = self._spell:getAttackTargets()
            for i, m in ipairs(targets) do
                table.insert(roles,m)
            end
        else
            local role = self._spell:getExecutor()
            table.insert(roles,role)
        end
    end
    
    local destHeight = action.height
    if self._spell._lastFallFrameIndex == self._frameData.index then
        destHeight = self._spell:getFollowSpell():getTemplate().targetInitHeight
    end
    local unlockFlag
    if self._frameData == self._spell:getTemplate():getLastKeyFrameByType(FrameActionType.FALL) then
        unlockFlag = true
    end
    for i, role in ipairs(roles) do
    --TODO @gavin
        if role and role.getPositionH then
            local act = BattleCustomActions.RiseAndFallAction.new(role, role:getPositionH(), destHeight,self._frameData.__layerData:getKeyFrameLength(self._frameData),action.tween, unlockFlag, self._spell)
            role:executeCustomAction(act)
            unlockFlag = nil --交由其中一个来解锁
        end
    end
end

function FallAction:dispose()
end


----------------------------FlyOutAction---------------------------
function  FlyOutAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function FlyOutAction:setFrame(frame)
    local action = self._frameData.action
    self:run(nil,action.testHeight)
end

function FlyOutAction:run(followSpell, testHeight)
    local action = self._frameData.action
    local role = self._spell:getExecutor()
    if action.targetType == 2 then
        local targets = self._spell:getAttackTargets()
        role = targets and targets[1]
    end
    if testHeight then
        role:setPositionH(testHeight)
    end
    local act = BattleCustomActions.FlyOutAction.new(role, action.speed, action.direction, action.friction,action.gravity)
    role:executeCustomAction(act)
    self._act = act
end

function FlyOutAction:dispose()
    if self._act then
        self._act:giveup()
        local position
        if self._act._role:getInfo().side == RoleInfo.SIDE_LEFT then
            position = PositionHelper.getLeft(self._act._role:getInfo().position)
        else
            position = PositionHelper.getRight(self._act._role:getInfo().position)
        end
        self._act._role:setPositionX(position.x)
        self._act._role:setPositionH(0)
        self._act._role:removeCustomAction(self._act)
        self._act = nil
    end
end


----------------------------ChangeColorAction---------------------------
function  ChangeColorAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function ChangeColorAction:setFrame(frame)
    self:run()
end

function ChangeColorAction:run(followSpell)
    local action = self._frameData.action
    local roles = {}

    if action.controlIds and action.controlIds ~= "" then
        roles = getControlRoles(self._spell, self._frameData, roles)
    else
        table.insert(roles,self._spell:getExecutor())
    end
    
    for i, role in ipairs(roles) do
        role:setColor(cc.c3b(action.colorR,action.colorG,action.colorB))
    end
end

function ChangeColorAction:dispose()
    local role = self._spell:getExecutor()
    role:setColor(nil)
end

----------------------------ChangePositionAction---------------------------
function  ChangePositionAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function ChangePositionAction:setFrame(frame)
    self:run()
end

function ChangePositionAction:run(followSpell)
    local action = self._frameData.action

    local role = self._spell:getExecutor()
    if action.targetType == 2 then
        local targets = self._spell:getAttackTargets()
        role = targets and targets[1]
    end

    if action.reset == 1 then
        if role:getInfo().side == RoleInfo.SIDE_RIGHT then
            role:setDirection(Role.DIRECTION_LEFT)
        else
            role:setDirection(Role.DIRECTION_RIGHT)
        end
        role:setPosition(role:getOriginPosition())
        if not role:isDead() then
            role:setBarVisible(true)
        end
        role:setRotation(0)
        role:addRotationAfterimageAction();
        role:addPositionAfterimageAction()
    else

        local roles = {}

        if action.controlIds and action.controlIds ~= "" and action.targetType ~= 2 then
            roles = getControlRoles(self._spell, self._frameData, roles)
        else
            if action.targetType == 2 then
                local targets = self._spell:getAttackTargets()
                for i, m in ipairs(targets) do
                    table.insert(roles,m)
                end
            else
                table.insert(roles,role)
            end
        end
        for i, role in ipairs(roles) do
            local position = cc.p(action.toX, action.toY);
            if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
                position.x = -position.x
            end

            if action.coord == CoordSystemType.SCREEN_CENTER then
                position = cc.pAdd(PositionHelper.getCenter(),position)
            elseif action.coord == CoordSystemType.MY_TEAM_CENTER then
                if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
                    position = cc.pAdd(PositionHelper.getRightCenter(),position)
                else
                    position = cc.pAdd(PositionHelper.getLeftCenter(),position)
                end
            elseif action.coord == CoordSystemType.OPPO_TEAM_CENTER then
                if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
                    position = cc.pAdd(PositionHelper.getLeftCenter(),position)
                else
                    position = cc.pAdd(PositionHelper.getRightCenter(),position)
                end
            elseif action.coord == CoordSystemType.ATTACK_POS or action.coord == CoordSystemType.ATTACK_BOTTOM_POS then
                local role = self._spell:getExecutor()
                position = cc.pAdd(role:getOriginPosition(),position)
            elseif action.coord == CoordSystemType.BEATTACK_POS or action.coord == CoordSystemType.BEATTACK_BOTTOM_POS then
                if action.targetType == 2 then
                    position = cc.pAdd(role:getOriginPosition(),position)
                else
                    local targets = self._spell:getAttackTargets()
                    local role = targets and targets[1]
                    if role then
                        position = cc.pAdd(role:getOriginPosition(),position)
                    end
                end
            end
            local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
            if frameCount == 1 then
                role:setPosition(position);
            else
                local startPt = cc.p(role:getPosition())
                local move = BattleCustomActions.MoveAction.new(role,startPt,position,frameCount, nil,nil,nil,nil,nil, true)

                role:executeCustomAction(move)
            end
            
            role:addPositionAfterimageAction()
            if action.direction == 1 or action.direction == 2 then
                role:setDirection(action.direction)
            end
            if action.hideBar and action.hideBar == 1 then
                role:setBarVisible(false)
            end
            if action.rotation and action.rotation ~= 0 then
                role:setRotation(action.rotation)
                role:addRotationAfterimageAction();
            end
        end
    end
end

function ChangePositionAction:dispose()
    local action = self._frameData.action
    if not action then return end
    local role = self._spell:getExecutor()
    if action.targetType == 2 then
        local targets = self._spell:getAttackTargets()
        role = targets and targets[1]
    end
    if role:getInfo().side == RoleInfo.SIDE_RIGHT then
        role:setDirection(Role.DIRECTION_LEFT)
        role:setPosition(PositionHelper.getRight(role:getInfo().position))
    else
        role:setDirection(Role.DIRECTION_RIGHT)
        role:setPosition(PositionHelper.getLeft(role:getInfo().position))
    end
    role:setBarVisible(true)
    role:setRotation(0)
end



----------------------------BodySeparateAction---------------------------
function BodySeparateAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function BodySeparateAction:setFrame(frame)
end

function BodySeparateAction:run(followSpell)
    local action = self._frameData.action
    if action.option == 1 then
        local targets = self._spell:getAttackTargets()
        if #targets > 1 then
            local others = {}
            for i = 2, #targets do --从第2个开始算
                table.insert(others,targets[i])
            end
            self._spell:bodySeparateStart(others, targets[1])
        end
        
    else
        self._spell:bodySeparateFinish()
    end
end

function BodySeparateAction:dispose()
end

----------------------------MissileAction---------------------------
function MissileAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function MissileAction:setFrame(frame)
    self._action = self:run()
end


function MissileAction:dispose()
    self._spell:getBattle():removeCustomAction(self._action)
end

function MissileAction:run(followSpell)
    local missile = BattleCustomActions.MissileAction.new(self._spell, self._frameData)
    self._spell:getBattle():executeCustomAction(missile)

    return missile
end

----------------------------CreateCopyAction---------------------------
function  CreateCopyAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function CreateCopyAction:setFrame(frame)
    self:run()
end

function CreateCopyAction:run(followSpell)
    local action = self._frameData.action
    if action.copyId == "" then
        return
    end
    local role = self._spell:getExecutor()
    local copy = role:clone(false)
    self._spell:addCopy(action.copyId, copy)
    
    if action.motion == "" then
        copy:executeMotion(role:getCurrentMotion())
    else
        copy:executeMotion(action.motion)
    end
    
    if action.direction == 0 then
        copy:setDirection(role:getDirection())
    else
        copy:setDirection(action.direction)
    end
    local tempRole = role
    if action.coord == CoordSystemType.BEATTACK_POS or action.coord == CoordSystemType.BEATTACK_BOTTOM_POS then
        local targets = self._spell:getAttackTargets()
        tempRole = targets and targets[1]
    end
    local position
    if tempRole then
        position = PositionHelper.getPositionByCoordType(action.coord,cc.p(action.x, action.y),tempRole, nil, self._spell:getExecutor():getInfo().side)
    end
    if position then
        copy:setPosition(position)
    end
end

function CreateCopyAction:dispose()
    clearCacheEffects()
    self._spell:clearCopies()
end

----------------------------RemoveCopyAction---------------------------
function  RemoveCopyAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function RemoveCopyAction:setFrame(frame)

end

function RemoveCopyAction:run(followSpell)
    local action = self._frameData.action
    local ids = string.split(action.copyIds, ",")
    if ids and #ids > 0 then
        for _, copyId in ipairs(ids) do
        	if copyId ~= "" then
                self._spell:removeCopyByID(copyId)
        	end
        end
    end
end

function RemoveCopyAction:dispose()
end

----------------------------FlyOffAction---------------------------
function  FlyOffAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function FlyOffAction:setFrame(frame)
--    self:run()
end

function FlyOffAction:run(followSpell)
    local action = self._frameData.action
    
    local roles = self._spell:getAttackTargets()
    local executorSide = self._spell:getExecutor():getInfo().side
    
--    local acts = {}
    local unlockFlag
    if self._frameData == self._spell:getTemplate():getLastKeyFrameByType(FrameActionType.FLY_OFF) then
        unlockFlag = true
    end
    for i, role in ipairs(roles) do
    
        local pt
        local endX
        if executorSide == RoleInfo.SIDE_RIGHT then
            pt = role:convertToNodeSpace(cc.p(0, 0))
            if LD_EDITOR then
                pt = role:convertToNodeSpace(cc.p((winSize.width-960)/2, 0))
            end
            endX = pt.x + 50
        else
            pt = role:convertToNodeSpace(cc.p(winSize.width, 0))
            if LD_EDITOR then
                pt = role:convertToNodeSpace(cc.p(winSize.width - (winSize.width-960)/2, 0))
            end
            endX = pt.x - 50
        end
        
        local function onCompelte()
            if not role:isDead() then
                role:setBarVisible(true)
            end
        end
        
        local startX = role:getPositionXInner()
        local startH = role:getPositionH()
        
        role:setBarVisible(false)
        
        local phase1 = BattleCustomActions.DriftAction.new(role, startX, endX, startH, action.hitWallHeight, action.phase1Duration, action.phase1Motion, 0)
        local delay1 = BattleCustomActions.DelayCallAction.new(ni, 1)
        local phase2 = BattleCustomActions.DriftAction.new(role, endX, endX, action.hitWallHeight, 0, action.phase2Duration, action.phase2Motion, 0, ActionEaseType.EaseExponentialIn)
        local delay2 = BattleCustomActions.DelayCallAction.new(ni, 3)
        local phase3 = BattleCustomActions.DriftAction.new(role, endX, 0, 0,0, action.phase3Duration, action.phase3Motion, -1, nil, MotionType.PREPARE, unlockFlag, self._spell)
        
        local act = BattleCustomActions.SequenceAction.new({phase1, delay1, phase2, delay2, phase3}, onCompelte);
        role:executeCustomAction(act)
        
        unlockFlag = nil
    end
end

function FlyOffAction:dispose()
end


----------------------------RotationAction---------------------------
function  RotationAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function RotationAction:setFrame(frame)
    self:run()
end

function RotationAction:run(followSpell)

    local action = self._frameData.action
    local roles
    if action.targetType == 2 then
        roles = self._spell:getAttackTargets()
    else
        roles = {}
        if action.controlIds and action.controlIds ~= "" then
            roles = getControlRoles(self._spell, self._frameData, roles)
        else
            table.insert(roles, self._spell:getExecutor())
        end
    end

    local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
    local acts = {}
    for i, role in ipairs(roles) do
        local act = BattleCustomActions.InnerRotationAction.new(role, role:getRotationInner(), action.innerRotation,frameCount)
        role:executeCustomAction(act)
        acts[#acts+1] = act
    end
    self._acts = acts
end

function RotationAction:dispose()
    if self._acts then
        for i, act in ipairs(self._acts) do
            if act._role == self._spell:getExecutor() then
                act._role:setRotationInner(0)
                act._role:removeCustomAction(act)
            end
        end
    end
    self._acts = nil
end

----------------------------RoleShakeAction---------------------------
function  RoleShakeAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function RoleShakeAction:setFrame(frame)
    self:run()
end

function RoleShakeAction:dispose()
    if self._shakes then
        for _, shake in ipairs(self._shakes) do
            shake._target:removeCustomAction(shake)
        end
        self._shakes = nil
    end
end

function RoleShakeAction:run(followSpell)
    local action = self._frameData.action
    
    local targets = self._spell:getAttackTargets()
    self._shakes = {}
    for _, target in ipairs(targets) do
        local shake = BattleCustomActions.RoleShakeAction.new(target:getBody(),action.strength,self._frameData.__layerData:getKeyFrameLength(self._frameData),action.decay)
        target:executeCustomAction(shake)
        table.insert(self._shakes, shade)
    end
end


----------------------------AddGhostShadowAction---------------------------
function  AddGhostShadowAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function AddGhostShadowAction:setFrame(frame)
    self:run()
end

function AddGhostShadowAction:run(followSpell)
    local role = self._spell:getExecutor()

    role:showGhostShadow()
end

function AddGhostShadowAction:dispose()
    local role = self._spell:getExecutor()
    role:stopGhostShadow()
end

----------------------------RemoveGhostShadowAction---------------------------
function  RemoveGhostShadowAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function RemoveGhostShadowAction:setFrame(frame)

end

function RemoveGhostShadowAction:run(followSpell)
    local role = self._spell:getExecutor()
    role:stopGhostShadow()
end

function RemoveGhostShadowAction:dispose()
end

----------------------------ReplaceBackgroundAction---------------------------
function ReplaceBackgroundAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function ReplaceBackgroundAction:setFrame(frame)
    local action = self._frameData.action
    if LD_EDITOR then
        if not cc.FileUtils:getInstance():isFileExist(action.effect .. ".animate.plist") then
            Message.show("不存在此特效文件：" .. action.effect)
            return
        end
    end
    self._spell:getBattle():getMap():removeReplaceBackground()
    
    local eff = SimpleEffect.new(action.effect, true)
    eff:setPosition(cc.p(PositionHelper.getCenter().x - self._spell:getBattle():getMap():getViewport().x, PositionHelper.getCenter().y))
    eff:setScale(action.scale)
    self._spell:getBattle():getMap():replaceBackground(eff)
end

function ReplaceBackgroundAction:dispose()
    self._spell:getBattle():getMap():removeReplaceBackground()
end

function ReplaceBackgroundAction:run(followSpell)
    local action = BattleCustomActions.ReplaceBackgroundAction.new(self._spell:getBattle():getMap(), self._frameData)
    self._spell:getBattle():executeCustomAction(action)
end

----------------------------LevelAdjustAction---------------------------
function  LevelAdjustAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function LevelAdjustAction:setFrame(frame)
    self:run()
end

function LevelAdjustAction:dispose()
end

function LevelAdjustAction:run(followSpell)
    local action = self._frameData.action
    
    local role = self._spell:getExecutor()
    role:setAdditionY(action.additionY)
--
--    local targets = self._spell:getAttackTargets()
--    self._shakes = {}
--    for _, target in ipairs(targets) do
--        local shake = BattleCustomActions.RoleShakeAction.new(target:getBody(),action.strength,self._frameData.__layerData:getKeyFrameLength(self._frameData),action.decay)
--        target:executeCustomAction(shake)
--        table.insert(self._shakes, shade)
--    end
end

----------------------------CallRoleAction---------------------------
function CallRoleAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function CallRoleAction:setFrame(frame)
    self:run()
end


function CallRoleAction:dispose()
    local action = self._frameData.action
    self._spell:removeTempRoleById(action.callId)
end

function CallRoleAction:run()
    local action = self._frameData.action
    local exist = self._spell:getTempRole(action.callId)
    if exist then
        Message.show("已存在相同的角色ID:" .. action.callId)
        return
    end
    local roleInfo = RoleInfo.new()
    roleInfo.callId = action.callId
    roleInfo:setResPath(action.rolePath)
    local role = self._spell:addTempRole(roleInfo, true)
    if role then
        local tempRole
        local position = cc.p(action.x, action.y)
        local direction = action.direction
        if self._spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
            direction = direction == Role.DIRECTION_LEFT and Role.DIRECTION_RIGHT or Role.DIRECTION_LEFT
            position.x = -position.x
        end
        
        if action.coord == CoordSystemType.ATTACK_POS or action.coord == CoordSystemType.ATTACK_BOTTOM_POS then
            tempRole = self._spell:getExecutor()
        elseif action.coord == CoordSystemType.BEATTACK_POS or action.coord == CoordSystemType.BEATTACK_BOTTOM_POS then
            local targets = self._spell:getAttackTargets()
            tempRole = targets and targets[1]
        end
        local position = PositionHelper.getPositionByCoordType(action.coord,position,tempRole, nil, self._spell:getExecutor():getInfo().side)
        
        role:executeMotion(action.motion)
        role:setPosition(position)
        
        
        role:setDirection(direction)
        role:refreshDepth(role:getPositionY())
        self._role = role
    end
end

----------------------------RemoveRoleAction---------------------------
function RemoveRoleAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function RemoveRoleAction:setFrame(frame)
    self:run()
end


function RemoveRoleAction:dispose()
end

function RemoveRoleAction:run()
    local action = self._frameData.action
    self._spell:removeTempRoleById(action.controlId)
end
----------------------------EffectAdjustAction---------------------------
function EffectAdjustAction:ctor(spell, frameData)
    self._spell = spell
    self._frameData = frameData
end

function EffectAdjustAction:setFrame(frame)
--    self:run()
end


function EffectAdjustAction:dispose()
end

function EffectAdjustAction:run()
    local action = self._frameData.action
    local effect = EffectMgr.getEffect(self._spell:getSpellData().index .. "_" .. action.controlId)
    if effect then
        local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
        local duration = BattleCustomActions.SECOND_PER_FRAME * frameCount
        local executorSide = self._spell:getExecutor():getInfo().side
        
        local adjust = BattleCustomActions.EffectAdjustAction.new(effect, duration, executorSide, action.toAlpha, 
            action.toScaleX, action.toScaleY, action.offsetX, action.offsetY, action.toRotation, action.anchorX, action.anchorY)
        self._spell:getBattle():executeCustomAction(adjust)
        effect:attachCustomAction(adjust)
    end
end


--编辑器专用
function FrameActionFactory.resetForEditor()
    clearCacheEffects()
end

--------------------------return FrameActionFactory-----------------------------
return FrameActionFactory