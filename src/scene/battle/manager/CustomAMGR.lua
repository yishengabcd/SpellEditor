
--CustomAMGR(CustomActionManager)
local CustomAMGR = class("CustomAMGR")

local EnterFrameMgr = require("src/scene/battle/manager/EnterFrameMgr")


--[[动作示例说明，所有动作必需包含IAction的所有属性和方法
--IAction只是动作类编写的模板，考虑到性能和语言本身等因素，其他动作不需要继承IAction，但需按此标准编写

local IAction = class("IAction")

function IAction:ctor()
    self.type = "IAction"--返回类型,通常作为canReplace方法的判断依据.
    self.finished = false--标记该动作是否已经完成,如果完成了,则该动作会从CustomAMGR队列中删除 
end

--每间隔一帧时间(游戏里大约是1/30秒)会被调用一次,直到finished为true
function IAction:execute(dt)
end

--返回true时,旧的动作会被放弃,新的动作会生效,否则新旧动作共存
function IAction:canReplace(action) 
    return false
end

--放弃该动作的执行
function IAction:giveup()
end

--]]


function CustomAMGR:ctor(manualStart)
    self._actions = {}
    if not manualStart then
        EnterFrameMgr.register(self)
    end
end

--执行指定动作
--如果存在可替换的动作，将之替换，否则将新动作添加到列表最后
function CustomAMGR:act(action)
    local oldAction;
    local replaced = false
    local actions = self._actions
    local index = #actions
    
    while index > 0 do
        oldAction = actions[index]
        if oldAction:canReplace(action) then
            actions[index] = action
            oldAction:giveup()
            replaced = true
            break
        end
        index = index - 1
    end
    if replaced == false then
        table.insert(actions, action)
    end
end

--每帧调用一次，由EnterFrameMgr调用
function CustomAMGR:enterFrame(dt)
    local deletes = {}
    for i, action in ipairs(self._actions) do
        if self._disposed then
            return
        end
        if action.finished then
            table.insert(deletes, i)--放入删除队列中
        else
            action:execute(dt)
        end
    end
    
    --将标记为删除的动作从列表中删除
    for i = #deletes, 1, -1 do
        table.remove(self._actions,deletes[i])
    end
end

function CustomAMGR:clearActions()
    for i, action in ipairs(self._actions) do
    	action:giveup()
    end
    self._actions = {}
end

function CustomAMGR:removeAction(action)
    for i, v in ipairs(self._actions) do
        if v == action then
            table.remove(self._actions,i)
            break
        end
    end
end

function CustomAMGR:getActions()
    return self._actions
end

function CustomAMGR:dispose()
    self._disposed = true
    self:clearActions() 
    EnterFrameMgr.unregister(self)
end

return CustomAMGR

