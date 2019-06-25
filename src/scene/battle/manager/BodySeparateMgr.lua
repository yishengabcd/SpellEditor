
--分身管理
local BodySeparateMgr = class("BodySeparateMgr")

function BodySeparateMgr:ctor(source)
    self._source = source
    self._ghosts = {}
end

function BodySeparateMgr:start(targets, sourceTarget)
    self._targets = targets
    self._sourceTarget = sourceTarget
    
    local Role = require("src/scene/battle/mode/Role")
    local roleInfo = self._source:getInfo()
    local motion = self._source:getCurrentMotion()
    
    for i, target in ipairs(targets) do
        local ghost = Role.new(roleInfo, true)

        self._source:getMap():addRole(ghost)
        ghost:executeMotion(motion)
        local offsetPt = cc.pSub(cc.p(self._source:getPosition()),cc.p(self._sourceTarget:getPosition()))
        local destPt = cc.pAdd(cc.p(target:getPosition()),offsetPt)
        ghost:setPosition(destPt)
--        ghost:setPosition(self._source:getPosition())
--        local moveTo = cc.MoveTo:create(0.2,destPt)
--        ghost:runAction(moveTo)
        ghost:refreshDepth(destPt.y)
        
        table.insert(self._ghosts,ghost)
    end
end

function BodySeparateMgr:finish()
    for i, ghost in ipairs(self._ghosts) do
        self._source:getMap():removeRole(ghost)
    end
end

function BodySeparateMgr:getGhosts()
    return self._ghosts
end

return BodySeparateMgr