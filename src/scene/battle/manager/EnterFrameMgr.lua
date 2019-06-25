local EnterFrameMgr = {}

local list = {}

-- 返回0时，表示不存在
local function getMemberIndex(member)
    for i, v in ipairs(list) do
    	if v == member then
    	   return i
    	end
    end
    return 0
end

--member必需是是含有enterFrame(self)方法的对象
function EnterFrameMgr.register(member)
    if getMemberIndex(member) == 0 then
        table.insert(list,member)
    end
end

function EnterFrameMgr.unregister(member)
    local idx = getMemberIndex(member)
    if idx ~= 0 then
        table.remove(list,idx)
    end
end

--每帧执行，该方法在初始化时由系统级方法调用，其他地方请勿调用
function EnterFrameMgr.onEnterFrame(dt)
    for i, member in ipairs(list) do
    	member:enterFrame(dt)
    end
end

return EnterFrameMgr