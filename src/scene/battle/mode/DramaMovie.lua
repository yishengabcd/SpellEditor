local DramaFrameActionFactory = require("src/scene/battle/mode/DramaFrameActionFactory")
local DramaFrameActionType = require("src/scene/battle/mode/DramaFrameActionType")
local FrameState = require("src/scene/battle/mode/FrameState")
local Role = require("src/scene/battle/mode/Role")
local CustomAMGR = require("src/scene/battle/manager/CustomAMGR")
local EventProtocol = require("src/utils/EventProtocol")

local DramaMovie = class("DramaMovie")
DramaMovie.EVENT_COMPLETE = "eventComplete"

function DramaMovie:ctor(template)
    self._template = template
    EventProtocol.extend(self)
    self._frameActions = {}
    self._roles = {}
    self._customAmgr = CustomAMGR.new()

    self._currentFrame = 0
    self._elapsed = 0
    
    self._framesDictionary = {}
    local layers = self._template:getLayers()
    self._maxFrame = self._template:getMaxFrameLength()
    for i, layer in ipairs(layers) do
        local frames = layer:getFrames()
        for j, frame in ipairs(frames) do
            if frame.type == FrameState.WEIGHT_KEY_FRAME then
                local list = self._framesDictionary[frame.index] or {}
                self._framesDictionary[frame.index] = list
                table.insert(list,frame)
            end
        end
    end
end

function DramaMovie:start()
    self:executeCustomAction(self)
end

function DramaMovie:execute(dt)
    self._elapsed = self._elapsed + dt
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    local reach = math.floor(self._elapsed/0.0333*BattleMgr.DEFAULT_SPEED)
    while self._currentFrame < reach and not self.finished do
        self:runFrame()
    end
end

function DramaMovie:runFrame()
    if self.finished then
        return
    end
    if self._currentFrame == 0 then
    end

    self._currentFrame = self._currentFrame + 1
    if self._currentFrame > self._maxFrame then
        self.finished = true
        self:dispatchEvent({name=DramaMovie.EVENT_COMPLETE})
        return
    end
    if self._template then
        local frames = self._framesDictionary[self._currentFrame]
        if frames then
            for i, frame in ipairs(frames) do
                if frame.action.type ~= DramaFrameActionType.ROLE_INIT  then
                    local action = DramaFrameActionFactory.create(self, frame)
                    if action then
                        table.insert(self._frameActions, action)
                        action:run()
                    end
                end
            end
        end
    end
end

function DramaMovie:canReplace(action) 
    return false
end

function DramaMovie:giveup()
end

function DramaMovie:addRole(roleInfo, defaultMotion)
    local role = self._roles[roleInfo.idOfDrama]
    if not role then
        role = Role.new(roleInfo, true, nil, nil, true, defaultMotion, true)
        self._roles[roleInfo.idOfDrama] = role
        self._map:addRole(role)
    end
    return role
end

function DramaMovie:removeRole(role)
    if role then
        role:clearAfterimage()
        self._roles[role:getInfo().idOfDrama] = nil
        self._map:removeRole(role)
    end
end


function DramaMovie:executeCustomAction(action)
    self._customAmgr:act(action)
end

function DramaMovie:removeCustomAction(action)
    self._customAmgr:removeAction(action)
end

function DramaMovie:getRole(id)
    return self._roles[id]
end

function DramaMovie:setMap(map)
    self._map = map
    self:initAllRoles(1)
end

function DramaMovie:getMap()
    return self._map
end
function DramaMovie:getTemplate()
    return self._template;
end

function DramaMovie:refresh()
    self:setFrame(self._currentFrame)
end

--为编辑器提供的方法
function DramaMovie:setFrame(frame)
    self:clean()
    self:initAllRoles(frame)
    local layers = self._template:getLayers()
    for i, layer in ipairs(layers) do
        local keyFrame = layer:getKeyFrame(frame)
        if keyFrame and keyFrame.type == FrameState.WEIGHT_KEY_FRAME 
            and keyFrame.action.type ~= DramaFrameActionType.ROLE_INIT 
            and keyFrame.action.type ~= DramaFrameActionType.ROLE_ADD then
            local action = DramaFrameActionFactory.create(self, keyFrame)
            if action then
                action:setFrame(frame)
                table.insert(self._frameActions, action)
            end
        end
    end
    self._currentFrame = frame
end

function DramaMovie:initAllRoles(frameIndex)
    local frames = self._template:getAllKeyFramesOfType(DramaFrameActionType.ROLE_INIT)
    for i, frame in ipairs(frames) do
        local action = DramaFrameActionFactory.create(self, frame)
        if action then
            action:setFrame(1)
            table.insert(self._frameActions, action)
        end
    end
    
    frames = self._template:getAllKeyFramesOfType(DramaFrameActionType.ROLE_ADD)
    for i, frame in ipairs(frames) do
        if frameIndex >= frame.index then
            local action = DramaFrameActionFactory.create(self, frame)
            if action then
                action:setFrame(1)
                table.insert(self._frameActions, action)
            end
        end
    end
    
    frames = self._template:getAllKeyFramesOfType(DramaFrameActionType.ROLE_DISAPPEAR)
    for i, frame in ipairs(frames) do
        if frameIndex >= frame.index then
            local action = DramaFrameActionFactory.create(self, frame)
            if action then
                action:setFrame(1)
                table.insert(self._frameActions, action)
            end
        end
    end
    local moves = self._template:getAllKeyFrameBefore(DramaFrameActionType.ROLE_MOVE, frameIndex)
    local changePositions = self._template:getAllKeyFrameBefore(DramaFrameActionType.CHANGE_POSITION, frameIndex)
    frames = {}
    if moves then
        frames = moves
    end
    if changePositions then
        for i, frame in ipairs(changePositions) do
        	table.insert(frames, frame)
        end
    end
    if #frames > 0 then
        table.sort(frames,function (a, b) return a.index < b.index end)
        for i, frame in ipairs(frames) do
            if frame.index + frame.__layerData:getKeyFrameLength(frame) <= frameIndex then
--                if frame.action.type == DramaFrameActionType.ROLE_MOVE then
--                elseif frame.action.type == DramaFrameActionType.CHANGE_POSITION then
--                end
                local action = DramaFrameActionFactory.create(self, frame)
                if action and action.gotoDest then
                    action:gotoDest()
                end
            end
        end
    end
end

function DramaMovie:clean()
    for i, v in ipairs(self._frameActions) do
        v:dispose()
    end
    self._frameActions = {}
end

function DramaMovie:dispose()
    if self._customAmgr then
        self._customAmgr:dispose()
        self._customAmgr=nil
    end
end


return DramaMovie