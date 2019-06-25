--残影2管理（残留效果）
local GhostShadowMgr = class("GhostShadowMgr")

local scheduler = cc.Director:getInstance():getScheduler()

function GhostShadowMgr:ctor(role)
    self._role = role
    self._producing = false
    self._shadows = {}
end

function GhostShadowMgr:start()
    self._producing = true
    self._elapsed = 0
    self._index = 0
    
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
        self._schedulerEntry = nil
    end
    
    local function update(dt)
        for i = #self._shadows, 1, -1 do
            local shadow = self._shadows[i]
            local opacity = shadow:getOpacity()
            opacity = opacity - 25
            if opacity > 0 then
                shadow:setOpacity(opacity)
            else
                table.remove(self._shadows, i)
                self._role:getMap():removeRole(shadow)
            end
        end
        if self._producing then
            self._elapsed = self._elapsed + dt
            local index = math.floor(self._elapsed / 0.13)
            if index > self._index then
                self._index = index
                local shadow = self._role:clone(true)
                self._role:getMap():addRole(shadow)
                shadow:setOpacity(180)
                shadow:executeMotion(self._role:getCurrentMotion())
                shadow:setPosition(self._role:getPosition())
                shadow:gotoAndPause(self._role:getCurrentFrameIndex())
                shadow:refreshDepth(shadow:getPositionY() + 1)
                table.insert(self._shadows,shadow)
            end
        end
    end
    self._schedulerEntry = scheduler:scheduleScriptFunc(update,1/60, false)
end

function GhostShadowMgr:stop()
    self._producing = false
end

function GhostShadowMgr:setVisible(value)
    for i, shadow in ipairs(self._shadows) do
        shadow:setVisible(value)
    end
end

function GhostShadowMgr:dispose()
    self._producing = false
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
        self._schedulerEntry = nil
    end
end


return GhostShadowMgr