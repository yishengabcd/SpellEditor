local BattleSimulateModel = {}
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local SpellData = require("src/scene/battle/data/SpellData")
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local BattleData = require("src/scene/battle/data/BattleData")
local MapData = require("src/scene/battle/data/MapData")
local BattleConfig


BattleSimulateModel.leftRoleNum = 1
BattleSimulateModel.rightRoleNum = 1

--创建战斗的模拟数据
function BattleSimulateModel.createBattleData(side)
    local battleData = BattleData.new()
    battleData.mapData = MapData.new()
    
    local roles = {}
    
    local role = RoleInfo.new()
    role.position = 4
    role.side = side
    role.team = role.side
    role.hp = 30000
    role.maxHp = 30000
    role.actionTime = 1000
    role.actionTimeLength = role.actionTime
    role:setResPath(EditorSpellModel.getEditSpell().leftRolePath or CONFIG_LEFT_ROLE)
    table.insert(roles,role)
    
    do 
        local tempSide = role.side
        local tempRes = role:getResPath()

        if BattleSimulateModel.leftRoleNum > 1 then
            role = RoleInfo.new()
            role.position = 0
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.leftRoleNum > 2 then
            role = RoleInfo.new()
            role.position = 1
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.leftRoleNum > 3 then
            role = RoleInfo.new()
            role.position = 2
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.leftRoleNum > 4 then
            role = RoleInfo.new()
            role.position = 5
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.leftRoleNum > 5 then
            role = RoleInfo.new()
            role.position = 5
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end
    end

    role = RoleInfo.new()
    role.position = 4
    if side == RoleInfo.SIDE_RIGHT then
        role.side = RoleInfo.SIDE_LEFT
    else
        role.side = RoleInfo.SIDE_RIGHT
    end
    role.hp = 30000
    role.maxHp = 30000
    role.actionTime = 1000
    role.actionTimeLength = role.actionTime
    role.team = role.side
    role:setResPath(EditorSpellModel.getEditSpell().rightRolePath or CONFIG_RIGHT_ROLE)
    
    table.insert(roles,role)
    
    
    do 
        local tempSide = role.side
        local tempRes = role:getResPath()

        if BattleSimulateModel.rightRoleNum > 1 then
            role = RoleInfo.new()
            role.position = 0
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.rightRoleNum > 2 then
            role = RoleInfo.new()
            role.position = 1
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.rightRoleNum > 3 then
            role = RoleInfo.new()
            role.position = 2
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.rightRoleNum > 4 then
            role = RoleInfo.new()
            role.position = 3
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end

        if BattleSimulateModel.rightRoleNum > 5 then
            role = RoleInfo.new()
            role.position = 5
            role.hp = 30000
            role.maxHp = 30000
            role.actionTime = 1000
            role.actionTimeLength = role.actionTime
            role.side = tempSide
            role.team = tempSide
            role:setResPath(tempRes)
            table.insert(roles,role)
        end
    end
    
    battleData.roleInfos = roles
    return battleData
end

--创建技能的模拟数据
function BattleSimulateModel.createSpellData(side, battleData)
    local side = side or 1
    local spellData = SpellData.new()
    spellData.spellId = EditorSpellModel.getEditSpell().id
    spellData.performId = spellData.spellId
    spellData.fromTeam = side
    spellData.fromPosition = 4
    spellData.isActive = EditorSpellModel.getEditSpell().isActive == 1 and true or false
    
    local targetTeam = side == RoleInfo.SIDE_LEFT and RoleInfo.SIDE_RIGHT or RoleInfo.SIDE_LEFT--目标队伍
    local targetPositions = {}
    if battleData then
        for i, roleInfo in ipairs(battleData.roleInfos) do
            if roleInfo.team == targetTeam then
                table.insert(targetPositions,roleInfo.position)
            end
        end
    else
        targetPositions[1] = 4
    end
    
    spellData.actions = BattleSimulateModel.createHurtDatas(targetPositions,targetTeam)
    
    return spellData
end

local function transformSide(configSide, settingSide)
    if settingSide == 1 then
        return configSide
    end
    if configSide == RoleInfo.SIDE_LEFT then
        return RoleInfo.SIDE_RIGHT
    end
    return RoleInfo.SIDE_LEFT
end

--根据BattleConfig.lua中的配置创建战斗数据
function BattleSimulateModel.createBattleDataOfBattle(side)

    local battleData = BattleData.new()
    battleData.mapData = MapData.new()
    
    package.loaded["src/BattleConfig"] = nil
    BattleConfig = require("src/BattleConfig")
    
    local function findRole(roles, side, pos)
        for _, role in ipairs(roles) do
        	if role.side == side and role.position == pos then
        	   return true
        	end
        end
        return false
    end
    
    local roles = {}
    for _, line in ipairs(BattleConfig) do
        local role = RoleInfo.new()
        role.position = line.pos
        role.side = transformSide(line.side,side)
        role.team = role.side
        role.hp = 30000
        role.maxHp = 30000
        role.actionTime = line.actionTime or 1000
        role.actionTimeLength = role.actionTime
        role:setResPath(line.body)
        if not findRole(roles, role.side, role.position) then
            table.insert(roles,role)
        end
    end

    battleData.roleInfos = roles
    return battleData
end
--根据BattleConfig.lua中的配置创建技能数据列表
function BattleSimulateModel.createSpellDatasOfBattle(side)
    local side = side or 1
    
    local spellDatas = {}
    for _, line in ipairs(BattleConfig) do
        if line.spell ~= 0 then
            local spellData = SpellData.new()
            spellData.spellId = line.spell
            spellData.performId = spellData.spellId
            spellData.fromTeam = transformSide(line.side,side)
            spellData.fromPosition = line.pos
            spellData.isActive = line.isActive == 1 and true or false
            spellData.isJoin = line.isJoin == 1 and true or false
            spellData.actions = BattleSimulateModel.createHurtDatas({line.targetPos},transformSide(line.targetSide,side))
            
            table.insert(spellDatas,spellData)
        end
    end

    return spellDatas
end

--创建伤害数据
function BattleSimulateModel.createHurtDatas(targetPositions, targetTeam, type)
    local type = type or GameActionType.GAME_ACTION_REMOVE_HP
    local actions = {}
    for i, targetPos in ipairs(targetPositions) do
    	local action = {}
        action.targetPosition = targetPos
        action.targetTeam = targetTeam
        action.type = type
        action.damages = {}
        for j = 1, 30 do
            local damage = {}
            damage.damageType = 1
            damage.realHp = 100 * j
            damage.hp = damage.realHp
            
            table.insert(action.damages,damage)
        end
    	table.insert(actions,action)
    end
    
    return actions
end
--获取更换角色时用于预览的RoleInfo
function BattleSimulateModel.getPreviewRoleInfo()
    local previewRoleInfo = RoleInfo.new()
    previewRoleInfo.position = 5
    previewRoleInfo.indexId = 1000000
    previewRoleInfo.side = RoleInfo.SIDE_LEFT
    if EditorSpellModel.getEditSpell() then
        previewRoleInfo:setResPath(EditorSpellModel.getEditSpell().leftRolePath or CONFIG_LEFT_ROLE)
    end
    return previewRoleInfo
end


return BattleSimulateModel