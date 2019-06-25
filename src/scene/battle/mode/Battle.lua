
local Map = require("src/scene/battle/mode/Map")
local Role = require("src/scene/battle/mode/Role")
local Spell = require("src/scene/battle/mode/Spell")
local CustomAMGR = require("src/scene/battle/manager/CustomAMGR")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local MotionType = require("src/scene/battle/mode/MotionType")
local EventProtocol = require("src/utils/EventProtocol")

local Battle = class("Battle")
Battle.EVENT_BATTLE_ROLE_DIE = "EVENT_BATTLE_ROLE_DIE"

function Battle:ctor(battleData,rect)
    EventProtocol.extend(self)
    self._battleData = battleData
    self._frame = 1 --战斗当前的所处的帧
    self._roles = {}
    self._customAmgr = CustomAMGR.new()
    
    local map = Map.new(rect,battleData.mapData)
    map:setBattle(self)
    self._map = map
    
    for i, v in ipairs(battleData.roleInfos) do
        self:addRole(v)
    end
end

function Battle:addRole(roleInfo, force)
    local key = roleInfo.team.."_"..roleInfo.position
    local role = self._roles[key]
    if not role or force then
        role = Role.new(roleInfo)
        self._roles[roleInfo.team.."_"..roleInfo.position] = role
        self._map:addRole(role)
    end
end

function Battle:removeRole(role)
    self._battleData:removeRoleInfo(role:getInfo())
    for key, mem in pairs(self._roles) do
    	if mem == role and role:getInfo().unitId == mem:getInfo().unitId then
    	   self._roles[key] = nil
    	   break
    	end
    end
    self._map:removeRole(role)
end

function Battle:executeCustomAction(action)
    self._customAmgr:act(action)
end

function Battle:removeCustomAction(action)
    self._customAmgr:removeAction(action)
end

--执行技能
function Battle:executeSpell(spell)
    self._spell = spell
    self:executeCustomAction(spell)
end

--播放胜利动作
function Battle:playVictory(winTeam)
    for key, mem in pairs(self._roles) do
        if mem:getInfo().team == winTeam and mem:getInfo().type == CreatureType.CREATURE_HERO then
            mem:executeMotion(MotionType.VICTORY,nil, 0)
            mem:showReadyEffect(false)
        end
        if not LD_EDITOR then
            local template = mem:getInfo():getTemplate()
            if template and template.sound_win and template.sound_win ~= "" then
                local sound = "music/bt_sound/" .. template.sound_win .. ".mp3"
                AudioEngine.playEffect(sound)
            end
        end
    end
end

--获得可以连携的英雄
function Battle:getCanJoinRoles(executor)
    local result = {}
    local template = executor:getTemplate()
    if template then
        for i, role in pairs(self._roles) do
            if role:getInfo().team == executor:getInfo().team and role ~= executor then
                local roleTemp = role:getTemplate()
                if roleTemp then
                    local types
                    local withHero = tonumber(roleTemp.with_hero_type_ids)
                    if withHero then
                        types = {}
                        types[1] = withHero
                    else
                        types = string.split(roleTemp.with_hero_type_ids,"|")
                    end
                    for k, t in ipairs(types) do
                        if template.hero_type_id == tonumber(t) then
                            table.insert(result,role)
                            break
                        end
                    end
                end
            end
        end
    end
    return result
end

--编辑器方法
function Battle:executeSpellForEditor(spellData)
    local spell = Spell.new(spellData)
    spell:setBattle(self)
    self._spell = spell
end
--为编辑器写的方法
function Battle:setFrame(frame)
    self._frame = frame
    if self._spell then 
        self._spell:setFrame(frame)
    end
end
--为编辑器写的方法
function Battle:refresh()
    if self._spell then 
        self._spell:refresh()
    end
end

function Battle:getRole(team, pos)
    return self._roles[team.."_"..pos]
end

function Battle:getRoles()
    return self._roles
end
function Battle:getLeftRoles()
    local roles = {}
    for i, role in pairs(self._roles) do
    	if role:getInfo().side == RoleInfo.SIDE_LEFT then
            table.insert(roles, role)
    	end
    end
    return roles
end

function Battle:getRightRoles()
    local roles = {}
    for i, role in pairs(self._roles) do
        if role:getInfo().side == RoleInfo.SIDE_RIGHT then
            table.insert(roles, role)
        end
    end
    return roles
end

function Battle:getMap()
    return self._map
end

function Battle:getBattleData()
    return self._battleData
end
function Battle:resetMap()
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    BattleMgr.setSpeed(nil,1)
    self._map:setBlackScreen(0)--恢复屏幕
    self._map:setPositionY(self._map:getOriginY())
end
function Battle:resetRoles(executor)
    for i, role in pairs(self._roles) do
        if not role:isDead() and not role:getSpellExecuting() then
            if role ~= executor then
                if executor:getInfo().side == role:getInfo().side then
                    role:setPosition(role:getOriginPosition())
                else
                    role:moveBack()
                end
                role:setPositionH(0)
                role:setRotationInner(0)
                role:setTeamDirection()
                role:refreshDepth(role:getPositionY())
                role:addPositionAfterimageAction()
                role:executeMotion(MotionType.PREPARE)
                role:setBarVisible(true)
--                role:setVisible(true)
                role:fadeIn()
                role:setBuffVisible(true)
            else
                role:executeMotion(MotionType.PREPARE)
            end
        end
    end
end

function Battle:dispose()
    if self._customAmgr then
        self._customAmgr:dispose()
        self._customAmgr=nil
    end
end

function Battle:sendRoleDieEvent(role)
    self:dispatchEvent({name = Battle.EVENT_BATTLE_ROLE_DIE, data = role})
end

return Battle