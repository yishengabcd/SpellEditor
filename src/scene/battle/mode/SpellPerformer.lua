
local MotionType = require("src/scene/battle/mode/MotionType")
local FrameState = require("src/scene/battle/mode/FrameState")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local Role
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")


local SpellPerformer = class("SpellPerformer")

local scheduler = cc.Director:getInstance():getScheduler()
local _schedulerEntry

function SpellPerformer:ctor(role)
    self._role = role
    if not Role then
        Role = require("src/scene/battle/mode/Role")
    end
end
function SpellPerformer:perform(performId)
    self._performId = performId
    self:stopScheduler()
    self._currentFrame = 0
    
    local SpellModel = require("src/scene/battle/data/SpellModel")
    SpellModel.load()
    
    self._role:executeMotion(MotionType.PREPARE)
    self._role:setColor(nil)
    
    if performId and SpellModel.getSpellDataById(performId) then
        _schedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.update), 1/30, false)
        self._template = SpellModel.getSpellDataById(performId)
        self._maxFrame = self._template:getMaxFrameLength()
    end
end

function SpellPerformer:update(dt)
    self._currentFrame = self._currentFrame + 1

    if self._currentFrame > self._maxFrame then
--        self:perform(self._performId)
        self:stopScheduler()
        self._role:executeMotion(MotionType.PREPARE)
        return
    end
    local layers = self._template:getLayers()
    for i, layer in ipairs(layers) do
        local frames = layer:getFrames()
        for j, frame in ipairs(frames) do
            if frame.index == self._currentFrame and frame.type == FrameState.WEIGHT_KEY_FRAME then
                local action = frame.action
                if action then
                    local type = action.type
                    if type == FrameActionType.MOVE_FORWARD then
                        self._role:executeMotion(MotionType.RUN)
                    elseif type == FrameActionType.PLAY_ACTION then
                        if action.motion and action.motion ~= "" then
                            local loop = -1
                            if action.playStandWhenEnd == 0 then
                                loop = 0
                            end
                            self._role:executeMotion(action.motion, action.transition, loop,nil, action.startFrame)

                            self._onPlayNotionComplete = function (event)
                                if action.playStandWhenEnd == nil or action.playStandWhenEnd ~= 0 then
                                    self._role:executeMotion(MotionType.PREPARE)
                                end
                                self._role:removeEventListener(Role.EVENT_MOTION_COMPLETE, self._onPlayNotionComplete)
                                self._onPlayNotionComplete = nil
                            end

                            self._role:addEventListener(Role.EVENT_MOTION_COMPLETE, self._onPlayNotionComplete)
                        end
                    elseif type == FrameActionType.JUMP then
                        local motion = action.motion or MotionType.JUMP
                        self._role:executeMotion(motion, nil, nil, nil, action.startFrame)


                        self._onJumpNotionComplete = function (event)
                            self._role:executeMotion(MotionType.PREPARE)
                            self._role:removeEventListener(Role.EVENT_MOTION_COMPLETE, self._onJumpNotionComplete)
                            self._onJumpNotionComplete = nil
                        end

                        self._role:addEventListener(Role.EVENT_MOTION_COMPLETE, self._onJumpNotionComplete)
                    elseif type == FrameActionType.CHANGE_COLOR then
                    elseif type == FrameActionType.PLAY_EFFECT then
                        if action.coord == CoordSystemType.ATTACK_POS or action.coord == CoordSystemType.ATTACK_BOTTOM_POS then
                            local scale = tonumber(action.scale)
                            local position = cc.p(action.x, action.y);

                            local eff = SimpleEffect.new(action.effect, false,action.effectSpeed, action.blendSrc, action.blendDst)
                            if scale and scale ~= 1 then
                                eff:setScale(scale)
                            end
                            if action.rotation and action.rotation ~= 0 then
                                eff:setRotation(action.rotation);
                            end
                            local pt = PositionHelper.getPositionForEffect(action.coord,position, RoleInfo.SIDE_LEFT, self._role)
                            self._role:addEffect(eff, pt, action.effectLevel)
                        end
                    end
                end
            end
        end
    end
end

function SpellPerformer:stopScheduler()
    if _schedulerEntry then
        scheduler:unscheduleScriptEntry(_schedulerEntry)
        _schedulerEntry = nil
    end

    if self._onPlayNotionComplete then
        self._role:removeEventListener(Role.EVENT_MOTION_COMPLETE, self._onPlayNotionComplete)
        self._onPlayNotionComplete = nil
    end
    if self._onJumpNotionComplete then
        self._role:removeEventListener(Role.EVENT_MOTION_COMPLETE, self._onJumpNotionComplete)
        self._onJumpNotionComplete = nil
    end
end

function SpellPerformer:dispose()
    self:stopScheduler()
end

return SpellPerformer