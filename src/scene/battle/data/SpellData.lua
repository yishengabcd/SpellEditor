local SpellData = class("SpellData")

--以下代码仅用于表明该对象含有的属性，并使开发时增加代码提示
SpellData.turn = 0 --第几回合
SpellData.index = 1 --索引ID
SpellData.spellId = 1
SpellData.performId = nil --技能表现id
SpellData.fromTeam = 1
SpellData.fromPosition = 1
SpellData.isActive = true --是否是主动技
SpellData.isJoin = false --是否是连携技
SpellData.buffs = nil
SpellData.castType = 1
SpellData.nextCastType = 0 --下一个技能的类型
SpellData.hasFightBack = nil  --有没有产生反击
SpellData.isFightBack = false --是否是反击
SpellData.level = 1 --技能等级
SpellData.actions = --技能造成的影响
{
    --影响1
    {
            targetPosition = 100,--目标id
            targetTeam = 2,--目标队伍
            type = 1, --见GameActionType

            --加血特有
            cureType = 1,
            hpAddReal = 100,--实际加血量
            hpAdd = 200,--加血量

            --减血特有
            damages = {
                {
                    damageType = 1,
                    realHp = 100,--实际掉血量
                    hp = 200,--掉血量
                },
                {
                    damageType = 1,
                    realHp = 100,--实际掉血量
                    hp = 200,--掉血量
                },
                --....
            },
            --BUFF
            buffType = 1,
            buffDuration = 2,--持续回合数
            
            --ADD_MP or REMOVE_MP
            mp = 90,
            
    },
    --影响2
    {
        
    }
    --影响3､4､5...
    
}
--吸血特有
SpellData.sucks={
--    {
--        targetPosition = 100,--目标id
--        targetTeam = 2
--        damageType = 1,
--        realHp = 100,--实际掉血量
--        hp = 200,--掉血量
--    },
--    {
--        targetPosition = 100,--目标id
--        targetTeam = 2
--        damageType = 1,
--        realHp = 100,--实际掉血量
--        hp = 200,--掉血量
--    },
--....
}
--end
--TODO ZDX 
SpellData.withSkill = {} --技能触发的连协技
function SpellData:ctor()
    self.isActive = false
    self.isJoin = false
    self.buffs = {}
    self.withSkill = {} 
end

--将某些属性的值修改为模板的配置数据
function SpellData:updateWithTemplate()
    local template = self:getTemplate()
    if template then
--        self.isActive = template.release_type == 2 and true or false
        self.isJoin = self.castType == SkillCastType.SKILL_CAST_WITH and true or false
        local effectTpl = self:getSkillEffectTemplate()
        if effectTpl then
            self.performId = tonumber(effectTpl.res)
        end
    end
end
--获得减血的段数（即有几段掉血）
function SpellData:getDamageSegment()
--    if self._segment then
--        return self._segment
--    end
--    self._segment = 0
--    for i, action in ipairs(self.actions) do
--        if action.type == GameActionType.GAME_ACTION_REMOVE_HP then
--            self._segment = #action.damages
--            return self._segment
--        end
--    end
    return #self:getDamageDatasAsSegment()
end

--获得某一段的掉血的数据
--返回数组或nil，数组包含该段中对所有单位造成的伤害
function SpellData:getDamageData(segment)
    return self:getDamageDatasAsSegment()[segment]
end
--将伤害数据以分段的格式返回
function SpellData:getDamageDatasAsSegment()
    if self._damages then
        return self._damages
    end
    self._damages = {}
    for i, action in ipairs(self.actions) do
        if action.type == GameActionType.GAME_ACTION_REMOVE_HP or action.type == GameActionType.GAME_ACTION_ADD_HP then
            local segment = #action.damages
            for j = 1, segment do 
                local seg = self._damages[j]--取得相应段
                if not seg then
                    seg = {}
                    self._damages[j] = seg
                end

                --为每段掉血增加target属性
                local damage = action.damages[j] 
                damage.targetPosition = action.targetPosition 
                damage.targetTeam = action.targetTeam  
                            
                table.insert(seg,damage)
            end
        end
    end
    return self._damages
end

function SpellData:isConcurrent()
    if LD_EDITOR then return false end
    local template = self:getTemplate()
    if template then
    
    end
    return false
end
function SpellData:getTemplate()
    return require("src/entities/templatemanager"):getSkillById(self.spellId)
end
function SpellData:getSkillEffectTemplate()
    local tpl = require("src/entities/templatemanager"):getSkillEffectTpl(self.spellId)
    if tpl then
        return tpl.skillList[self.level]
    end
    return nil
end

--TODO ZDX 获取技能连带的连协技
function SpellData:getWithSkill()
    return self.withSkill
end
function SpellData:isWithSkill()
    if self.withSkill and getTableSize(self.withSkill) >= 1 then
    return true 
    else
    return false
    end
end
return SpellData