
--TweenMgr
local TweenMgr = class("TweenMgr")

function TweenMgr:ctor()
    self._tweeners = {}
end

--添加缓动对象到列表中
--t 类型为ITween
function TweenMgr:addTween(t)
    table.insert(self._tweeners, t)
end

--更新缓动状态
function TweenMgr:step(dt)
    if self._paused then return end
    local deletes = {}
    for i, t in ipairs(self._tweeners) do
        if self._disposed then
            return
        end
        if t.isDone then
            table.insert(deletes, i)--放入删除队列中
        else
            t:step(dt)
        end
    end

    --将标记为删除的动作从列表中删除
    for i = #deletes, 1, -1 do
        table.remove(self._tweeners,deletes[i])
    end
end

--将缓动对象从列表中移除
function TweenMgr:remove(t)
    for i, v in ipairs(self._tweeners) do
        if v == t then
            table.remove(self._tweeners,i)
            break
        end
    end
end

function TweenMgr:setPaused(value)
    self._paused = value
end

function TweenMgr:clear()
    self._actions = {}
end

function TweenMgr:dispose()
    self._disposed = true
    self:clear()
end

return TweenMgr

