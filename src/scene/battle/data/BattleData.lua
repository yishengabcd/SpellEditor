local BattleData = class("BattleData")

local EventProtocol = require("src/utils/EventProtocol")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local LoaderType = require("src/scene/loading/loadertype")

--以下代码仅用于表明该对象含有的属性，并使开发时增加代码提示
BattleData.type = 1 --见GameType
BattleData.roleInfos = {} --vector of RoleInfo
BattleData.myTeam = 1 --自己所在的队伍
BattleData.fighting = false --是否处于战斗中（或者仅是在地图中行走）
BattleData.mapData = nil --地图相关数据
BattleData.maxLevel = 0 --自己队伍的英雄的最高等级
BattleData.hpSupplies = nil --每波战斗结束后的血量补给

BattleData.formationLeft = 1 --左边队伍的阵型
BattleData.formationRight = 1 --右边队伍的阵型

--全局变量
BattleData.autoBattle = false
BattleData.speedType = 1
--------------------------

--------竞技场相关----------
BattleData.arenaIsReplay = nil --是否重放
BattleData.arenaIsWin = nil
BattleData.arenaIsPromote = nil --是否是晋级赛
BattleData.arenaGroupId = nil
BattleData.arenaRank = nil --胜利后的排名
BattleData.arenaMedal = nil --胜利后获得的荣誉
BattleData.arenaRedUid = nil --红队玩家id
BattleData.arenaRedNickname = nil
BattleData.arenaRedLevel = nil
BattleData.arenaRedHeadId = nil
BattleData.arenaBlueType = nil --蓝对类型
BattleData.arenaBlueUid = nil --红队玩家id
BattleData.arenaBlueNickname = nil
BattleData.arenaBlueLevel = nil
BattleData.arenaBlueHeadId = nil
--end

BattleData.EVENT_FIGHTING_STATE = "eventFightingState"


function BattleData:ctor()
    EventProtocol.extend(self)
end

function BattleData:setFighting(value)
    if self.fighting ~= value then
        self.fighting = value
        self:dispatchEvent({name=BattleData.EVENT_FIGHTING_STATE})
    end
end

function BattleData:addRoleInfo(info)
    table.insert(self.roleInfos,info)
end

function BattleData:removeRoleInfo(info)
    for i, mem in ipairs(self.roleInfos) do
    	if mem == info then
    	   table.remove(self.roleInfos,i)
    	   return
    	end
    end
end

function BattleData:getRoleInfo(team, position)
    for i, roleInfo in ipairs(self.roleInfos) do
    	if roleInfo.team == team and roleInfo.position == position then
    	   return roleInfo
    	end
    end
    return nil
end

function BattleData:getRoleInfoBySide(side, position)
    for i, roleInfo in ipairs(self.roleInfos) do
        if roleInfo.side == side and roleInfo.position == position then
            return roleInfo
        end
    end
    return nil
end

function BattleData:isAllDeadOfOneSide()
    local leftLive
    local rightLive
    for i, mem in ipairs(self.roleInfos) do
        if not mem.isDead then
            if mem.side == RoleInfo.SIDE_LEFT then
                leftLive = true
            else
                rightLive = true
            end
        end
    end
    if leftLive and rightLive then
        return false
    end
    return true
end

--从真实的战斗数据中复制数据
--当玩家进入副本时，通过副本中的单位，构建了BattleData，这份数据只满足地图中显示、行走使用
--因此需要将触发战斗时产生的新的BattleData同步过来
function BattleData:copyFromRealBattleData(data)
    self:setFighting(data.fighting)
    self.type = data.type
    for _, roleInfo in ipairs(self.roleInfos) do
        for _, fromRoleInfo in ipairs(data.roleInfos) do
    		if roleInfo.unitId == fromRoleInfo.unitId and roleInfo.position == fromRoleInfo.position then
                roleInfo.maxHp = fromRoleInfo.maxHp
                roleInfo.hp = fromRoleInfo.hp
    		end
    	end
    end
end

--确定阵型
function BattleData:resolveFormations()
    local PositionHelper = require("src/scene/battle/mode/PositionHelper")
    for i, roleInfo in ipairs(self.roleInfos) do
        if roleInfo.side == RoleInfo.SIDE_LEFT then
            if roleInfo.lineup == 0 then
                self.formationLeft = PositionHelper.FORMATION_5_2_3
            else
                self.formationLeft = PositionHelper.FORMATION_5_3_2
            end
        else
            if roleInfo.type == CreatureType.CREATURE_HERO then
                if roleInfo.lineup == 0 then
                    self.formationRight = PositionHelper.FORMATION_5_2_3
                else
                    self.formationRight = PositionHelper.FORMATION_5_3_2
                end
            else
                self.formationRight = PositionHelper.FORMATION_6_3_3
            end
        end
    end
end

function BattleData:getPreloadList()
    local list = {}
    for i, roleInfo in ipairs(self.roleInfos) do
        self:getRolePreloadList(roleInfo, list)
        table.insert(list,{type=LoaderType.SKELETON, path=roleInfo:getResPath()})
    end
    return list
end

function BattleData:getRolePreloadList(roleInfo, list)

end

return BattleData