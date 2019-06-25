local MapUnitInfo = class("MapUnitInfo")

MapUnitInfo.uqid = 1 --唯一id
MapUnitInfo.x = 0
MapUnitInfo.y = 0
MapUnitInfo.team = 1--红队、蓝队
MapUnitInfo.type = 1--MapUnitType
MapUnitInfo.maxLevel = 0
MapUnitInfo.lineup = 1 --前3后2 或 前2后3

--if type == MONSTER or type == HERO 
MapUnitInfo.members = {
    --[[格式说明
    {
    tplId = 0,--模板id
    position = 0,--站位
    uid = 1, --用户ID
    heroId = 1,--英雄ID
    maxHp = 1,
    hp = 1,
    mp=1,
    level=1,
    buffs={
        {
        buffId=1,
        buffLevel=1
        }
    }
    },
    ...
    --]]
    }
    
    --if type == DROP 
 MapUnitInfo.dropFromUnitId = 1 --所属怪物组(英雄)唯一ID
 MapUnitInfo.dropFromPosition = 1 --位置
 MapUnitInfo.dropCollected = false --标识是否已经被收集了的
 MapUnitInfo.dropItems={
    --[[
        {
        tplId=1,
        count=1
        }
    --]]
 }
function MapUnitInfo:toRoleInfos()
    local roleInfos = {}
    local RoleInfo = require("src/scene/battle/data/RoleInfo")
    for k, v in ipairs(self.members) do
        local roleInfo = RoleInfo.new()
        roleInfo.unitId = self.uqid
        roleInfo.team = self.team
        roleInfo.side = roleInfo.team
        roleInfo.position = v.position
        roleInfo.unitX = self.x
        roleInfo.maxHp = v.maxHp
        roleInfo.hp = v.hp
        roleInfo.mp = v.mp
        roleInfo.level = v.level
        roleInfo.lineup = self.lineup
        if self.type == MapUnitType.MAP_UNIT_PLAYER then
            roleInfo.type = CreatureType.CREATURE_HERO
            roleInfo.tplId = v.tplId
            roleInfo.uid = v.uid
            roleInfo.areaId = 0
        elseif self.type == MapUnitType.MAP_UNIT_MONSTER then
            roleInfo.type = CreatureType.CREATURE_MONSTER
            roleInfo.tplId = v.tplId
        end
        roleInfo:setResPath(roleInfo:getResPathFromTemplate())
        table.insert(roleInfos,roleInfo)
    end
    return roleInfos
end

return MapUnitInfo