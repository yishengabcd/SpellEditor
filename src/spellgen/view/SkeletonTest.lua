local SkeletonTest = {}

local Role = require("src/scene/battle/mode/Role")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local MotionType = require("src/scene/battle/mode/MotionType")

local roles = {}
local winSize = cc.Director:getInstance():getVisibleSize()
local paths = {}
local roleIndex = 1
table.insert(paths,"res/animation/hr001/hr001.ExportJson")
table.insert(paths,"res/animation/hr002/hr002.ExportJson")
table.insert(paths,"res/animation/hr003/hr003.ExportJson")
table.insert(paths,"res/animation/hr004/hr004.ExportJson")
--table.insert(paths,"res/animation/hr005/hr005.ExportJson")
--table.insert(paths,"res/animation/hr006/hr006.ExportJson")
table.insert(paths,"res/animation/hr007/hr007.ExportJson")
table.insert(paths,"res/animation/hr009/hr009.ExportJson")
--table.insert(paths,"res/animation/hr010/hr010.ExportJson")
--table.insert(paths,"res/animation/hr015/hr015.ExportJson")
--table.insert(paths,"res/animation/hr021/hr021.ExportJson")
table.insert(paths,"res/animation/hr024/hr024.ExportJson")
table.insert(paths,"res/animation/hr026/hr026.ExportJson")
table.insert(paths,"res/animation/hr028/hr028.ExportJson")

function SkeletonTest.increaseArmature()
    local roleInfo = RoleInfo.new()
    roleInfo:setResPath(paths[math.ceil(math.random() * #paths)])
    local role = Role.new(roleInfo)
    role:setPosition(math.random()*winSize.width,math.random() *( winSize.height - 200))
    
    cc.Director:getInstance():getRunningScene():addChild(role)
    
    table.insert(roles, role)
    
    local motions = {MotionType.PREPARE, MotionType.RUN,MotionType.DIE, MotionType.HURT, MotionType.STAND}
    
    local function onNotionComplete(event)
        role:executeMotion(motions[math.floor(math.random() * #motions + 1)])
    end

    role:addEventListener(Role.EVENT_MOTION_COMPLETE, onNotionComplete)
    role:executeMotion(MotionType.STAND)
end

function SkeletonTest.decreaseArmature()
    if #roles > 1 then
        local role = roles[1]
        cc.Director:getInstance():getRunningScene():removeChild(role,true)
        table.remove(roles, 1)
    end
end

function SkeletonTest.clear()
    for i, role in ipairs(roles) do
        cc.Director:getInstance():getRunningScene():removeChild(role,true)   	
    end
    roles = {}
end

function SkeletonTest.changeRole()
    roleIndex = roleIndex + 1
    if roleIndex > #paths then
        roleIndex = 1
    end
    SkeletonTest.clear()
    SkeletonTest.increaseArmature()
end



return SkeletonTest