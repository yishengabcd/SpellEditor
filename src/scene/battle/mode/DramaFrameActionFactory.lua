local SimpleEffect = require("src/scene/battle/view/SimpleEffect")
local Map = require("src/scene/battle/mode/Map")
local DramaFrameActionType = require("src/scene/battle/mode/DramaFrameActionType")
local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local MotionType = require("src/scene/battle/mode/MotionType")
local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local Role = require("src/scene/battle/mode/Role")
local ActionEaseType = require("src/scene/battle/mode/ActionEaseType")
local DramaModel = require("src/scene/battle/data/DramaModel")

local DramaFrameActionFactory = {}
--出于性能考虑，以下FrameAction未采用继承方式
--设计以下类的原因是适配编辑器和正式战斗的关系，使两种情型可以共存
local FrameAction = class("FrameAction")
local RoleInitAction = class("RoleInitAction")
local RoleAddAction = class("RoleAddAction")
local RoleMoveAction = class("RoleMoveAction")
local RoleSpeakAction = class("RoleSpeakAction")
local PlayMotionAction = class("PlayMotionAction")
local PlayEffectAction = class("PlayEffectAction")
local FlyAction = class("FlyAction")
local PlaySoundAction = class("PlaySoundAction")
local MoveMapAction = class("MoveMapAction")
local ZoomMapAction = class("ZoomMapAction")
local FocusAction = class("FocusAction")
local MissileAction = class("MissileAction")
local AddAfterimageAction = class("AddAfterimageAction")
local RemoveAfterimageAction = class("RemoveAfterimageAction")
local RiseAction = class("RiseAction")
local FallAction = class("FallAction")
local ChangePositionAction = class("ChangePositionAction")
local RotationAction = class("RotationAction")
local ShakeAction = class("ShakeAction")
local BlackScreenAction = class("BlackScreenAction")
local ReplaceBackgroundAction = class("ReplaceBackgroundAction")
local RoleDisappearAction = class("RoleDisappearAction")
local CurtainAction = class("CurtainAction")
local DialogAction = class("DialogAction")

local winSize = cc.Director:getInstance():getVisibleSize();

--创建帧动作
function DramaFrameActionFactory.create(movie, frameData)
    local type = frameData.action.type
    
    if type == DramaFrameActionType.ROLE_INIT then
        return RoleInitAction.new(movie, frameData)
    elseif type == DramaFrameActionType.ROLE_ADD then
        return RoleAddAction.new(movie, frameData)
    elseif type == DramaFrameActionType.ROLE_MOVE then
        return RoleMoveAction.new(movie, frameData)
    elseif type == DramaFrameActionType.ROLE_SPEAK then
        return RoleSpeakAction.new(movie, frameData)
    elseif type == DramaFrameActionType.PLAY_ACTION then
        return PlayMotionAction.new(movie, frameData)
    elseif type == DramaFrameActionType.PLAY_EFFECT then
        return PlayEffectAction.new(movie, frameData)
    elseif type == DramaFrameActionType.FLY_EFFECT then
        return FlyAction.new(movie, frameData)
    elseif type == DramaFrameActionType.PLAY_SOUND then
        return PlaySoundAction.new(movie, frameData)
    elseif type == DramaFrameActionType.MOVE_MAP then
--        return MoveMapAction.new(movie, frameData)
    elseif type == DramaFrameActionType.ZOOM_MAP then
--        return ZoomMapAction.new(movie, frameData)
    elseif type == DramaFrameActionType.FOCUS then
        return FocusAction.new(movie, frameData)
    elseif type == DramaFrameActionType.MISSILE then
        return MissileAction.new(movie, frameData)
    elseif type == DramaFrameActionType.ADD_AFTERIMAGE then
        return AddAfterimageAction.new(movie, frameData)
    elseif type == DramaFrameActionType.REMOVE_AFTERIAGE then
        return RemoveAfterimageAction.new(movie, frameData)
    elseif type == DramaFrameActionType.RISE then
        return RiseAction.new(movie, frameData)
    elseif type == DramaFrameActionType.FALL then
        return FallAction.new(movie, frameData)
    elseif type == DramaFrameActionType.CHANGE_POSITION then
        return ChangePositionAction.new(movie, frameData)
    elseif type == DramaFrameActionType.ROTATION then
        return RotationAction.new(movie, frameData)
    elseif type == DramaFrameActionType.SHAKE then
        return ShakeAction.new(movie, frameData)
    elseif type == DramaFrameActionType.BLACK_SCREEN then
        return BlackScreenAction.new(movie, frameData)
    elseif type == DramaFrameActionType.REPLACE_BACKGROUND then
        return ReplaceBackgroundAction.new(movie, frameData)
    elseif type == DramaFrameActionType.ROLE_DISAPPEAR then
        return RoleDisappearAction.new(movie, frameData)
    elseif type == DramaFrameActionType.CURTAIN then
        return CurtainAction.new(movie, frameData)
    elseif type == DramaFrameActionType.DIALOG then
        return DialogAction.new(movie, frameData)
    end
    return nil
end


--将帧转换为时间
local function transFrameToSecend(frame)
    return frame/30
end

----------------------------FrameAction---------------------------
--模板类，其他类参考此类
function FrameAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

--为编辑器提供的方法
function FrameAction:setFrame(frame)
end

function FrameAction:dispose()
end

function FrameAction:run()
end


----------------------------RoleInitAction---------------------------
function RoleInitAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RoleInitAction:setFrame(frame)
    self:run()
end


function RoleInitAction:dispose()
    if self._role then
        self._movie:removeRole(self._role)
        self._role = nil
    end
end

function RoleInitAction:run()
    local action = self._frameData.action
    local exist = self._movie:getRole(action.idOfDrama)
    if exist and LD_EDITOR then
        Message.show("已存在相同的角色ID:" .. action.idOfDrama)
        return
    end
    local roleInfo = RoleInfo.new()
    roleInfo.idOfDrama = action.idOfDrama
    roleInfo:setResPath(action.rolePath)
    roleInfo.team = action.team
    local role = self._movie:addRole(roleInfo, action.motion)
    if role then
        role:executeMotion(action.motion)
        role:setDirection(action.direction)
        role:setPosition(action.x, action.y)
        role:refreshDepth(action.y)
        self._role = role
    end
end

----------------------------RoleAddAction---------------------------
function RoleAddAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RoleAddAction:setFrame(frame)
    self:run()
end

function RoleAddAction:dispose()
    if self._role then
        self._movie:removeRole(self._role)
        self._role = nil
    end
end

function RoleAddAction:run()
   RoleInitAction.run(self)
end

----------------------------RoleMoveAction---------------------------
function  RoleMoveAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RoleMoveAction:setFrame(frame)
    self:run()
end

function RoleMoveAction:run()
    local action = self._frameData.action
    local position = cc.p(action.x, action.y);
    local role = self._movie:getRole(action.controlId)
    if role then
        role:executeMotion(action.motion)
        local startPt = cc.p(role:getPosition())
        local endMotion = nil--action.endMotion
        local move = BattleCustomActions.MoveAction.new(role,startPt,position,self._frameData.__layerData:getKeyFrameLength(self._frameData), nil, endMotion, nil)
        role:executeCustomAction(move)
    end
end
function RoleMoveAction:gotoDest()
    local action = self._frameData.action
    local position = cc.p(action.x, action.y);
    local role = self._movie:getRole(action.controlId)
    if role then
--        role:executeMotion(action.endMotion)
        role:setDirection(role:getPositionX() - position.x > 0 and Role.DIRECTION_LEFT or Role.DIRECTION_RIGHT)
        role:setPosition(position)
        role:refreshDepth(action.y)
    end
end

function RoleMoveAction:dispose()
end

----------------------------RoleSpeakAction---------------------------
function RoleSpeakAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RoleSpeakAction:setFrame(frame)
    self:run()
end


function RoleSpeakAction:dispose()
end

function RoleSpeakAction:run()
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        local words = DramaModel.getDialogue(action.dialogueId)
        if words then
            local move = BattleCustomActions.RoleSpeakAction.new(role,self._frameData.__layerData:getKeyFrameLength(self._frameData), words, action)
            role:executeCustomAction(move)
        end
    end
end

----------------------------PlayEffectAction---------------------------
function PlayEffectAction:ctor(movie, frameData)
    self._movie = movie
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
    local position = cc.p(action.x, action.y);

    if LD_EDITOR then
        if not cc.FileUtils:getInstance():isFileExist(action.effect .. ".animate.plist") then
            Message.show("不存在此特效文件：" .. action.effect)
            return
        end
    end

    local function createEff(needCache)
        local eff
        if editorFlag then
            eff = SimpleEffect.new(action.effect, true,action.effectSpeed, action.blendSrc, action.blendDst)
            if needCache then
                cacheEffectForEditor(eff)
            end
        else
            if action.duration and action.duration > 0 then
                eff = SimpleEffect.new(action.effect, true,action.effectSpeed, action.blendSrc, action.blendDst, action.duration, nil, true, true)
            else
                eff = SimpleEffect.new(action.effect, false,action.effectSpeed, action.blendSrc, action.blendDst, nil, nil, true, true)
            end
        end
        if scale and scale ~= 1 then
            eff:setScale(scale)
        end
        local rotation = action.rotation
        if rotation and rotation ~= 0 then
            eff:setRotation(rotation);
        end
        return eff
    end
    if action.coord == CoordSystemType.PLACE_ROLE then
        local role = self._movie:getRole(action.controlId)
        if role then
            local eff = createEff()
            role:addEffect(eff, position, action.effectLevel)
        end
    else
        local eff = createEff(true)
        self._movie:getMap():addEffect(eff, position, action.effectLevel)
    end
end

function PlayEffectAction:dispose()
    clearCacheEffects()
end

function PlayEffectAction:run()
    self:addEffect(false)
end


----------------------------FlyAction---------------------------
function FlyAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function FlyAction:setFrame(frame)
    self._action = self:run()
end


function FlyAction:dispose()
    self._movie:removeCustomAction(self._action)
end

function FlyAction:run()
    local action = self._frameData.action
    local startPt = cc.p(action.fromX, action.fromY)
    local endPt = cc.p(action.toX,action.toY)
    local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
    local executorSide = action.fromX > action.toX and RoleInfo.SIDE_RIGHT or RoleInfo.SIDE_LEFT
    local fly = BattleCustomActions.SingleFlyAction.new(self._movie:getMap(), action.effect, startPt, endPt, frameCount, action.fromScale, action.toScale, executorSide, action.effectSpeed, nil, nil, true)
    self._movie:executeCustomAction(fly)

    return fly
end


----------------------------PlayMotionAction---------------------------
function  PlayMotionAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function PlayMotionAction:setFrame(frame)
    local action = self._frameData.action
    if action.motion and action.motion ~= "" then
        local role = self._movie:getRole(action.controlId)
        if role then
            role:executeMotion(action.motion, 1, nil,nil,action.startFrame)
        end
    end
end

function PlayMotionAction:dispose()
end

function PlayMotionAction:run()
    local action = self._frameData.action
    if action.motion and action.motion ~= "" then
        local role = self._movie:getRole(action.controlId)
        if role then
            local loop = -1
            if action.playStandWhenEnd == 0 and action.loop ~= 1 then
                loop = 0
            end
            role:executeMotion(action.motion, nil, loop,nil, action.startFrame)
            local endMotion = action.endMotion or MotionType.PREPARE

            if action.loop ~= 1 then
                local onMotionChanged
                local onNotionComplete
                onNotionComplete = function (event)
                    if action.playStandWhenEnd == nil or action.playStandWhenEnd ~= 0 then
                        role:executeMotion(endMotion)
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
function  PlaySoundAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function PlaySoundAction:setFrame(frame)
end

function PlaySoundAction:dispose()
end

function PlaySoundAction:run()
    local action = self._frameData.action

    if action.sound and action.sound ~= "" and PLATFORM ~= "win32" then
        AudioEngine.playEffect("music/bt_sound/" .. action.sound .. ".mp3")
    end
end


----------------------------BlackScreenAction---------------------------
function  BlackScreenAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function BlackScreenAction:setFrame(frame)
    local action = self._frameData.action
    local color
    if action.colorR and action.colorG and action.colorB then
        color = cc.c3b(action.colorR,action.colorG,action.colorB)
    end
    self._movie:getMap():setBlackScreen(action.alpha, color)
end

function BlackScreenAction:dispose()
    self._movie:getMap():setBlackScreen(0)
end

function BlackScreenAction:run()
    local action = self._frameData.action
    if action.alpha == 0 and (action.toAlpha == nil or action.toAlpha == 0) then return end
    local autoReset = true
    if autoReset then
        local hasFollow = self._movie:getTemplate():checkHasKeyFrameOfType(self._frameData.__layerData:getKeyFrameLength(self._frameData)+self._frameData.index, DramaFrameActionType.BLACK_SCREEN)
        autoReset = not hasFollow;
    end
    local color
    if action.colorR and action.colorG and action.colorB then
        color = cc.c3b(action.colorR,action.colorG,action.colorB)
    end
    local black = BattleCustomActions.BlackScreenAction.new(self._movie:getMap(),action.alpha,action.toAlpha, self._frameData.__layerData:getKeyFrameLength(self._frameData),color,autoReset)
    self._movie:executeCustomAction(black)
end

----------------------------ShakeAction---------------------------
function  ShakeAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function ShakeAction:setFrame(frame)
    self:run()
end

function ShakeAction:dispose()
    self._movie:removeCustomAction(self._shake)
    self._movie:getMap():setPositionY(self._movie:getMap():getOriginY())
end

function ShakeAction:run()
    local action = self._frameData.action

    local shake = BattleCustomActions.ShakeAction.new(self._movie:getMap(),action.strength,self._frameData.__layerData:getKeyFrameLength(self._frameData),action.decay)
    self._movie:executeCustomAction(shake)
    self._shake = shake
end

----------------------------MoveMapAction---------------------------
function  MoveMapAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function MoveMapAction:setFrame(frame)
    self:run()
end

function MoveMapAction:dispose()
    local camera = self._movie:getMap():getCamera()
    camera:reset()
end

function MoveMapAction:run()
    local action = self._frameData.action
    local camera = self._movie:getMap():getCamera()
    local offsetX = action.offsetX
    if self._movie:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
        offsetX = -offsetX
    end

    local forceCenter = action.forceCenter == 1 and true or false
    camera:moveTo(camera:getPositionX()+offsetX, camera:getPositionY(), transFrameToSecend(self._frameData.__layerData:getKeyFrameLength(self._frameData)),action.tween, forceCenter);
end

----------------------------ZoomMapAction---------------------------
function  ZoomMapAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function ZoomMapAction:setFrame(frame)
    self:run()
end

function ZoomMapAction:dispose()
    local camera = self._movie:getMap():getCamera()
    camera:reset()
end

function ZoomMapAction:run()
    local action = self._frameData.action
    local camera = self._movie:getMap():getCamera()
    local position = cc.p(action.centerX, action.centerY)
    if self._movie:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
        position.x = -position.x
    end
    position = PositionHelper.getPositionByCoordType(action.coord,position,self._movie:getExecutor(), nil, self._movie:getExecutor():getInfo().side)
    position = camera:getScreenPoint(position)

    local forceCenter = action.forceCenter == 1 and true or false
    local zoom = action.zoom > 1 and action.zoom or 1
    camera:zoomTo(zoom, transFrameToSecend(self._frameData.__layerData:getKeyFrameLength(self._frameData)),action.tween,position,forceCenter);
end

----------------------------FocusAction---------------------------
function  FocusAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function FocusAction:setFrame(frame)
    self:run()
end

function FocusAction:dispose()
--    local camera = self._movie:getMap():getCamera()
--    camera:reset()
end

function FocusAction:run()
    local action = self._frameData.action
    local camera = self._movie:getMap():getCamera()

    local position =  cc.p(action.x, action.y);

    local forceCenter = action.forceCenter == 1 and true or false
    local zoom = action.zoom > 1 and action.zoom or 1
    camera:lookAt(position, zoom, transFrameToSecend(self._frameData.__layerData:getKeyFrameLength(self._frameData)),action.tween,forceCenter)
end


----------------------------AddAfterimageAction---------------------------
function  AddAfterimageAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function AddAfterimageAction:setFrame(frame)
    self:run()
end

function AddAfterimageAction:run()
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        role:showAfterimage()
    end
end

function AddAfterimageAction:dispose()
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        role:clearAfterimage()
    end
end

----------------------------RemoveAfterimageAction---------------------------
function  RemoveAfterimageAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RemoveAfterimageAction:setFrame(frame)
end

function RemoveAfterimageAction:run()
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        role:clearAfterimage()
    end
end

function RemoveAfterimageAction:dispose()
end

----------------------------RiseAction---------------------------
function  RiseAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RiseAction:setFrame(frame)
    self:run()
end

function RiseAction:run()
    if self._movie._firstRiseFrameIndex == self._frameData.index then
        return
    end
    local action = self._frameData.action
    local roles = {}

    if action.controlIds and action.controlIds ~= "" and action.targetType ~= 2 then
        roles = getControlRoles(self._movie, self._frameData, roles)
    else
        if action.targetType == 2 then
            local targets = self._movie:getAttackTargets()
            for i, m in ipairs(targets) do
                table.insert(roles,m)
            end
        else
            local role = self._movie:getExecutor()
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
            if act._role == self._movie:getExecutor() then
                act._role:setPositionH(0)
                act._role:removeCustomAction(act)
            end
        end
    end
    self._acts = nil
end

----------------------------FallAction---------------------------
function  FallAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function FallAction:setFrame(frame)
--    self:run()
end

function FallAction:run()
    local action = self._frameData.action

    local roles = {}

    if action.controlIds and action.controlIds ~= "" and action.targetType ~= 2 then
        roles = getControlRoles(self._movie, self._frameData, roles)
    else
        if action.targetType == 2 then
            local targets = self._movie:getAttackTargets()
            for i, m in ipairs(targets) do
                table.insert(roles,m)
            end
        else
            local role = self._movie:getExecutor()
            table.insert(roles,role)
        end
    end

    local destHeight = action.height
    if self._movie._lastFallFrameIndex == self._frameData.index then
        destHeight = self._movie:getTemplate().targetInitHeight
    end
    local unlockFlag
    if self._frameData == self._movie:getTemplate():getLastKeyFrameByType(DramaFrameActionType.FALL) then
        unlockFlag = true
    end
    for i, role in ipairs(roles) do
        --TODO @gavin
        if role and role.getPositionH then
            local act = BattleCustomActions.RiseAndFallAction.new(role, role:getPositionH(), destHeight,self._frameData.__layerData:getKeyFrameLength(self._frameData),action.tween, unlockFlag, self._movie)
            role:executeCustomAction(act)
            unlockFlag = nil --交由其中一个来解锁
        end
    end
end

function FallAction:dispose()
end


----------------------------ChangePositionAction---------------------------
function  ChangePositionAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function ChangePositionAction:setFrame(frame)
    self:run()
end

function ChangePositionAction:run()
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        role:clearAfterimage()
        local position = cc.p(action.x, action.y);
        local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
        if frameCount == 1 then
            role:setPosition(position);
        else
            local startPt = cc.p(role:getPosition())
            local move = BattleCustomActions.MoveAction.new(role,startPt,position,frameCount, nil,nil,nil,nil,nil, true)

            role:executeCustomAction(move)
        end

        role:addPositionAfterimageAction()
        role:setDirection(action.direction)
        if action.rotation and action.rotation ~= 0 then
            role:setRotation(action.rotation)
            role:addRotationAfterimageAction();
        end
    end
end

function ChangePositionAction:gotoDest()
    local action = self._frameData.action
    local position = cc.p(action.x, action.y);
    local role = self._movie:getRole(action.controlId)
    if role then
        role:setDirection(action.rotation)
        role:setPosition(position)
        role:refreshDepth(action.y)
    end
end

function ChangePositionAction:dispose()
local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        role:setRotation(0)
    end
end

----------------------------MissileAction---------------------------
function MissileAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function MissileAction:setFrame(frame)
    self._action = self:run()
end


function MissileAction:dispose()
--    self._movie:removeCustomAction(self._action)
end

function MissileAction:run()
    local action = self._frameData.action
--    function SingleMissileAction:ctor(map, effectString, startPt, endPt, frameCount, fromScale, toScale,
--    executorSide, speed, blendSrc, blendDst, tweenType,controlPoint1,controlPoint2, effectLevel1, effectLevel2)
    local startPt = cc.p(action.fromX, action.fromY)
    local endPt = cc.p(action.toX, action.toY)
    local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
    local executorSide = action.fromX > action.toX and RoleInfo.SIDE_RIGHT or RoleInfo.SIDE_LEFT
    local controlPoint1 = cc.p(action.controlPoint1X, action.controlPoint1Y)
    local controlPoint2 = cc.p(action.controlPoint2X, action.controlPoint2Y)
    
    local missile = BattleCustomActions.SingleMissileAction.new(self._movie:getMap(), 
        action.effect, startPt, endPt, frameCount, action.fromScale, action.toScale, 
        executorSide, action.effectSpeed, nil, nil, nil, controlPoint1, controlPoint2,
        action.effectLevel1, action.effectLevel2, true)
    self._movie:executeCustomAction(missile)

    return missile
end
----------------------------ReplaceBackgroundAction---------------------------
function ReplaceBackgroundAction:ctor(movie, frameData)
    self._movie = movie
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
    self._movie:getMap():removeReplaceBackground()

    local eff = SimpleEffect.new(action.effect, true, nil, nil, nil,nil,nil, true)
    eff:setPosition(cc.p(PositionHelper.getCenter().x - self._movie:getMap():getViewport().x, PositionHelper.getCenter().y))
    eff:setScale(action.scale)
    self._movie:getMap():replaceBackground(eff)
end

function ReplaceBackgroundAction:dispose()
    self._movie:getMap():removeReplaceBackground()
end

function ReplaceBackgroundAction:run()
    local action = BattleCustomActions.ReplaceBackgroundAction.new(self._movie:getMap(), self._frameData)
    self._movie:executeCustomAction(action)
end
----------------------------RoleDisappearAction---------------------------
function RoleDisappearAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RoleDisappearAction:setFrame(frame)
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        role:setVisible(false)
    end
end

function RoleDisappearAction:dispose()
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        role:setVisible(true)
    end
end

function RoleDisappearAction:run()
    local action = self._frameData.action
    local role = self._movie:getRole(action.controlId)
    if role then
        local function fadeOutEnd()
            self._movie:removeRole(role)
        end
        local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
        local action = BattleCustomActions.FadeOutAction.new(role, frameCount*0.033)
        action = BattleCustomActions.SequenceAction.new({action}, fadeOutEnd)

        role:executeCustomAction(action)
    end
end

----------------------------RotationAction---------------------------
function  RotationAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function RotationAction:setFrame(frame)
    self:run()
end

function RotationAction:run()

    local action = self._frameData.action
    local roles
    if action.targetType == 2 then
        roles = self._movie:getAttackTargets()
    else
        roles = {}
        if action.controlIds and action.controlIds ~= "" then
            roles = getControlRoles(self._movie, self._frameData, roles)
        else
            table.insert(roles, self._movie:getExecutor())
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
            if act._role == self._movie:getExecutor() then
                act._role:setRotationInner(0)
                act._role:removeCustomAction(act)
            end
        end
    end
    self._acts = nil
end

----------------------------CurtainAction---------------------------
function  CurtainAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function CurtainAction:setFrame(frame)
    local action = self._frameData.action
    local words = DramaModel.getDialogue(action.dialogueId) or ""
    self._movie:getMap():playCurtain(words)
end

function CurtainAction:dispose()
    self._movie:getMap():removeCurtain()
end

function CurtainAction:run()
    local action = self._frameData.action
    local words = DramaModel.getDialogue(action.dialogueId) or ""
    local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
    local duration = BattleCustomActions.SECOND_PER_FRAME * frameCount
    local fadeIn = action.fadeIn
    local fadeOut = action.fadeOut
    local hasFollow = self._movie:getTemplate():checkHasKeyFrameOfType(frameCount+self._frameData.index, DramaFrameActionType.CURTAIN)
    local hasBefore = self._movie:getTemplate():checkHasBeforeFrameOfType(self._frameData.index - 1, DramaFrameActionType.CURTAIN)
    local autoClear = true
    if hasBefore then
        fadeIn = 0
    end
    if hasFollow then
        fadeOut = 0
        autoClear = false
    end
    local curtain = BattleCustomActions.CurtainAction.new(self._movie:getMap(),words, duration,fadeIn, fadeOut, autoClear)
    
    self._movie:executeCustomAction(curtain)
end

----------------------------DialogAction---------------------------
function  DialogAction:ctor(movie, frameData)
    self._movie = movie
    self._frameData = frameData
end

function DialogAction:buildData()
    local action = self._frameData.action
    if action.head == nil or action.head == "" 
        or action.name == nil or action.name == "" 
        or action.dialogueId == nil or action.dialogueId == "" then
        return nil
    end
    local words = DramaModel.getDialogue(action.dialogueId)
    if not words then
        return nil
    end
    local data = {}
    data.side = action.side
    data.head = action.head
    data.name = action.name
    data.words = words

    return data
end

function DialogAction:setFrame(frame)
    local data = self:buildData()
    if data then
        self._movie:getMap():playDramaMovieDialog(data)
    end
end

function DialogAction:dispose()
    self._movie:getMap():removeDramaMovieDialog()
end

function DialogAction:run()
    local data = self:buildData()
    if data then
        local action = self._frameData.action
        local frameCount = self._frameData.__layerData:getKeyFrameLength(self._frameData)
        local duration = BattleCustomActions.SECOND_PER_FRAME * frameCount
        local hasFollow = self._movie:getTemplate():checkHasKeyFrameOfType(frameCount+self._frameData.index, DramaFrameActionType.DIALOG)
        local autoClear = (not hasFollow) and true or false
        local dialog = BattleCustomActions.DramaMovieDialogAction.new(self._movie:getMap(), data, duration, autoClear)
        self._movie:executeCustomAction(dialog)
    end
end

--编辑器专用
function DramaFrameActionFactory.resetForEditor()
    clearCacheEffects()
end

--------------------------return DramaFrameActionFactory-----------------------------
return DramaFrameActionFactory