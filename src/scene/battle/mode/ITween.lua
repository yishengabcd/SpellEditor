--缓动接口
local ITween = class("ITween")
local TweenFunction = require("src/scene/battle/mode/TweenFunction")

--duration 持续的时间，不能为0
function ITween:ctor(duration, tweenType)
    self._duration = duration 
    self._elapsed = 0
    self._tweenType = tweenType
    self.isDone = false
end

function ITween:step(dt)
    self._elapsed = self._elapsed + dt
    local time = math.max(0, math.min(1, self._elapsed/self._duration))
    if self._tweenType then
        time = TweenFunction[self._tweenType](time)
    end
    self:update(time)
    if self._elapsed >= self._duration then
        self.isDone = true
    end
end

function ITween:update(time) 
    error("子类需要覆盖此方法:ITween:update(time)")
end


return ITween