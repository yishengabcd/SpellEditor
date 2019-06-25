
--残影管理（跟随效果）
local AfterimageMgr = class("AfterimageMgr")

AfterimageMgr.ACTION_TYPE_POSITION = 1
AfterimageMgr.ACTION_TYPE_MOTION = 2
AfterimageMgr.ACTION_TYPE_DIRECTION = 3
AfterimageMgr.ACTION_TYPE_HEIGHT = 4
AfterimageMgr.ACTION_TYPE_ROTATION = 5
AfterimageMgr.ACTION_TYPE_ROTATION_INNER = 6 --内部旋转

function AfterimageMgr:ctor(role)
    self._role = role
    self._count = 0
    self._shadows = {}
    self._actions = {}
end

function AfterimageMgr:setParams(value)
    self._interval = 3
    self._shadowNum = 3
    if #self._shadows == 0 then
        local father = self._role
        local alphaGap = (150 - 50)/self._shadowNum
        for i = 1,self._shadowNum do
            local shadow = father:clone(true)
            self._role:getMap():addRole(shadow)
            shadow:setOpacity(150 - i * alphaGap, cc.c3b(255,0,0))
--            shadow:setShadowFather(self._role)
            shadow:executeMotion(self._role:getCurrentMotion())
            shadow:setPosition(self._role:getPosition())
            shadow:refreshDepth(shadow:getPositionY())
            father = shadow
            table.insert(self._shadows,shadow)
        end
    end
end

function AfterimageMgr:setVisible(value)
    for i, shadow in ipairs(self._shadows) do
        shadow:setVisible(value)
    end
end

function AfterimageMgr:update(dt)
    if #self._shadows == 0 then
        return
    end
    self._count = self._count + 1
    local index = 1
    local len = #self._actions
    local deleteCount = 0
    while index < len + 1 do
        local action = self._actions[index]
        index = index+1
        local past = self._count - action.frame
        if past < 0 then
            break
        end
        if (self._shadowNum - 1)*self._interval < past then
            deleteCount = deleteCount + 1
        elseif past%self._interval == 0 then
            local role = self._shadows[past/self._interval+1]

            if action.type == AfterimageMgr.ACTION_TYPE_POSITION then
                role:setPosition(action.x,action.y)
                role:refreshDepth(role:getPositionY())
            elseif action.type == AfterimageMgr.ACTION_TYPE_MOTION then
                role:executeMotion(action.motion,action.durationTo,action.loop,action.nextName,action.startFrame)
            elseif action.type == AfterimageMgr.ACTION_TYPE_DIRECTION then
                role:setDirection(action.dir)
            elseif action.type == AfterimageMgr.ACTION_TYPE_HEIGHT then
                role:setPositionH(action.height)
            elseif action.type == AfterimageMgr.ACTION_TYPE_ROTATION then
                role:setRotation(action.rotation)
            elseif action.type == AfterimageMgr.ACTION_TYPE_ROTATION_INNER then
                role:setRotationInner(action.rotation)
            end
        end
    end
    if deleteCount > 0 then
        for i = 1, deleteCount do
            table.remove(self._actions,1)
        end
    end
end

function AfterimageMgr:addAction(data)
    data.frame = self._count+3--加3指的是在当前帧之后的第3帧生效
    table.insert(self._actions, data)
end

function AfterimageMgr:clear()
    for i, shadow  in ipairs(self._shadows) do
        self._role:getMap():removeRole(shadow)
    end
    self._shadows = {}
    self._actions = {}
end

return AfterimageMgr