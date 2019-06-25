
--角色配置数据，比如关键点信息
local RoleConfigModel = {}

--角色的关键点坐标配置信息
local positions = require("data/EditorRolesData")
--角色的动作的配置信息
local motions = require("data/EditorRoleMotionData")

--获得关键坐标点
--返回两个点,第1个点为底部坐标点，第2个点为打击坐标点,第3个点是血条位置点
--不存在记录时，返回nil
function RoleConfigModel.getKeyPositions(filePath)
    local data = positions[filePath]
    if data then
        local pt3 = nil
        if data[5] then
            pt3 = cc.p(data[5], data[6])
        end
        return cc.p(data[1], data[2]),cc.p(data[3], data[4]),pt3
    end
    
    return nil
end

function RoleConfigModel.getShowDustFlag(filePath)
    local data = positions[filePath]
    if data then
        return data["dustFlag"]
    end

    return nil
end

function RoleConfigModel.getRolesPositions()
    return positions
end
--[[角色动作部件配置信息结构说明
local EditorRoleMotionData = {
    --角色1
    ["animation/hr001/hr001.ExportJson"] = {
        ["stand"]={
            {name="披风",x=0,y=0,scale=1,effect="effect/js/archer/fadong03.animate.plist",effectLevel=1,effectSpeed=1},--部件1
            {name="头巾",x=0,y=0,scale=1,effect="effect/js/archer/fadong03.animate.plist",effectLevel=1,effectSpeed=1},--部件2
            ...
        }
        ["prepare"]={
            ...
        }
    },
    --角色2
    ["animation/hr002/hr002.ExportJson"] = {
        ["stand"]={
            {x=0,y=0,scale=1,effect="effect/js/archer/fadong03.animate.plist",effectLevel=1,effectSpeed=1},--部件1
            {x=0,y=0,scale=1,effect="effect/js/archer/fadong03.animate.plist",effectLevel=1,effectSpeed=1},--部件2
            ...
        }
        ["prepare"]={
            ...
        }
    }
}
--]]


--获得一个角色的动作配置数据
function RoleConfigModel.getMotionData(filePath)
    return motions[filePath]
end

--获得指定角色的指定动作的部件数据
function RoleConfigModel.getPartsOfMotion(filePath, motion)
    local data = motions[filePath]
    if data then
        return data[motion]
    end
    return nil
end

--设置动作部件配置信息，编辑器专用
function RoleConfigModel.setPartsOfMotion(filePath, motion, data)
    local motionsData = motions[filePath]
    if not motionsData then
        motionsData = {}
        motions[filePath] = motionsData
    end
    motionsData[motion] = data
end

function RoleConfigModel.getRolesMotionsData()
    return motions
end
return RoleConfigModel