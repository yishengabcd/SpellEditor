local RoleInfo = class("RoleInfo")
local EventProtocol = require("src/utils/EventProtocol")

RoleInfo.SIDE_LEFT = 1
RoleInfo.SIDE_RIGHT = 2

--以下代码仅用于表明该对象含有的属性，并使开发时增加代码提示
RoleInfo.unitId = 1 --地图中的单位的id
RoleInfo.idOfDrama = nil --剧情编辑里设置的id
RoleInfo.callId = nil --编辑器里调用出来的角色的id
RoleInfo.type = 1--角色类型，见CreatureType
RoleInfo.position = 1
--RoleInfo.indexId = 1 --战斗角色的唯一性id
RoleInfo.team = 1--红队蓝队，见TeamType
RoleInfo.side = RoleInfo.SIDE_LEFT
RoleInfo.maxHp = 1000
RoleInfo.hp = 1000--当前生命值
RoleInfo.mp = 0 --怒气值
RoleInfo.lineup = 1 --前3后2 或 前2后3
RoleInfo.buffs=nil
RoleInfo.unitX = nil --该角色所在的单位的X坐标
RoleInfo.level = 1
RoleInfo.myTeamMaxLevel = 0 --玩家队伍最大等级
RoleInfo.preparing = nil

RoleInfo.tplId = 1

--英雄专有的属性
RoleInfo.uid = 1
RoleInfo.areaId = 1
RoleInfo.isDead = nil
--end

RoleInfo.EVENT_MP_CHANGE = "eventMpChange" --怒气变化
RoleInfo.EVENT_ADD_BUFF = "eventAddBuff" --添加buff
RoleInfo.EVENT_INVOKE_BUFF = "eventInvokeBuff" --buff生效
RoleInfo.EVENT_REMOVE_BUFF = "eventRemoveBuff" --移除buff
RoleInfo.EVENT_HP_CHANGE = "eventHpChange" --掉血（这里只针对怪物boss头像显示，实际掉血在role中的removeHp函数）
RoleInfo.EVENT_DIE = "eventDie"
RoleInfo.EVENT_PREPARE_STATE_CHANGED = "eventPrepareStateChanged"

function RoleInfo:ctor()
    EventProtocol.extend(self)
    self.buffs = {}
end

function RoleInfo:getResPath()
    return self._resPath
end

--临时使用，最终版应是从模板中读取
function RoleInfo:setResPath(value)
    self._resPath = value
end

function RoleInfo:changeMp(dest)
--    if offset == 0 then return end
--    local dest = self.mp + offset
--    if dest < 0 then
--        dest = 0
--    elseif dest > 10000 then
--        dest = 10000
--    end
    if self.mp == dest then return end
    
    self.mp = dest
    self:dispatchEvent({name=RoleInfo.EVENT_MP_CHANGE})
end

function RoleInfo:die()
    self.isDead = true
    self:dispatchEvent({name=RoleInfo.EVENT_DIE})
end

--设置是否处于蓄力状态
function RoleInfo:setPreparing(value)
    if self.preparing ~= value then
        self.preparing = value
        self:dispatchEvent({name=RoleInfo.EVENT_PREPARE_STATE_CHANGED})
    end
end

--buff相关

function RoleInfo:addBuff(buffData)
    local exist = false
    for i, member in ipairs(self.buffs) do
        if member.buffId == buffData.buffId then
    	   member:setCount(member.count+1)
    	   exist = true
    	end
    end
    if not exist then
        table.insert(self.buffs,buffData)
    end
    self:dispatchEvent({name=RoleInfo.EVENT_ADD_BUFF, data = buffData})
end

function RoleInfo:removeBuff(buffData)
    for i, member in ipairs(self.buffs) do
        if member.buffId == buffData.buffId then
            if member.count > 1 then
                member:setCount(member.count-1)
            else
                table.remove(self.buffs,i)
            end
            break
        end
    end
    self:dispatchEvent({name=RoleInfo.EVENT_REMOVE_BUFF, data = buffData})
end

function RoleInfo:invokeBuff(buffData)
    self:dispatchEvent({name=RoleInfo.EVENT_INVOKE_BUFF, data = buffData})
end

-----------
--TODO zdxiong
function RoleInfo:refreshHp()
    if LD_EDITOR then return end
    if self.type == CreatureType.CREATURE_MONSTER then
        local monstertpl =  require("src/entities/templatemanager"):getMonster(self.tplId)
        if monstertpl.is_boss == 1 then
            local Hpdata = {}
            Hpdata.currentHp = self.hp
            Hpdata.MaxHp = self.maxHp
            self:dispatchEvent({name=RoleInfo.EVENT_HP_CHANGE, data = Hpdata}) 
        end
    end
end
-----------
function RoleInfo:getTemplate()
    if self.type == CreatureType.CREATURE_HERO then
        local hero = require("src/entities/templatemanager"):getHero(self.tplId)
        --可能是引导英雄
        if hero.tplList then
            return hero.tplList[self.level]
        else
            return hero
        end
    elseif self.type == CreatureType.CREATURE_MONSTER then
        return require("src/entities/templatemanager"):getMonster(self.tplId)
    end
end

function RoleInfo:isBoss()
    return self.type == CreatureType.CREATURE_MONSTER and self:getTemplate().is_boss == 1
end

function RoleInfo:isHero()
    return self.type == CreatureType.CREATURE_HERO
end

function RoleInfo:getResPathFromTemplate()
    local template = self:getTemplate()
    if not template then return nil end
    local res = template.res_animation
--    if self.type == CreatureType.CREATURE_HERO then
--        res = require("src/entities/templatemanager"):getHero(self.tplId).res_animation
--    elseif self.type == CreatureType.CREATURE_MONSTER then
--        local monster = require("src/entities/templatemanager"):getMonster(self.tplId)
--        if not monster then
--            print("error: can't find monster id:" .. self.tplId)
--            return 
--        end
--        res = require("src/entities/templatemanager"):getMonster(self.tplId).res_animation
--    end
    return "animation/" .. res .. "/" .. res .. ".ExportJson"
end

return RoleInfo