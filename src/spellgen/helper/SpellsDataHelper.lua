local SpellsDataHelper = {}
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local RoleConfigModel = require("src/scene/battle/data/RoleConfigModel")

function SpellsDataHelper.save()
    local str = table.serialize(EditorSpellModel.getSpells(), nil, 2)
    str = "local EditorSpellsData = " ..str .. "\nreturn EditorSpellsData"
    local file = assert(io.open(RES_ROOT.."/data/EditorSpellsData.lua","w"))
    if file then
        file:write(str)
        file:close()
        Message.show("保存成功")
    else
        Alert.alert("保存失败")
    end
    
    local fileBackup = assert(io.open(RES_ROOT.."/data/EditorSpellsData_backup.lua","w"))
    if fileBackup then
        fileBackup:write(str)
        fileBackup:close()
    end
    
    SpellsDataHelper.saveSpellSegment()
end

--保存角色关键点数据
function SpellsDataHelper.saveRolesData()
    local str = table.serialize(RoleConfigModel.getRolesPositions(), nil, 1)
    str = "local EditorRolesData = " ..str .. "\nreturn EditorRolesData"
    local file = assert(io.open(RES_ROOT.."/data/EditorRolesData.lua","w"))
    if file then
        file:write(str)
        file:close()
        Message.show("保存成功")
    else
        Alert.alert("保存失败")
    end

end

function SpellsDataHelper.saveRolesMotionsData()
    local str = table.serialize(RoleConfigModel.getRolesMotionsData(),nil,2)
    str = "local EditorRoleMotionData = " ..str .. "\nreturn EditorRoleMotionData"
    local file = assert(io.open(RES_ROOT.."/data/EditorRoleMotionData.lua","w"))
    if file then
        file:write(str)
        file:close()
        Message.show("保存成功")
    else
        Alert.alert("保存失败")
    end
end

--保存技能段数
function SpellsDataHelper.saveSpellSegment()
    local spells = EditorSpellModel.getSpells()
    
    table.sort(spells,function (a,b) 
        if a.id < b.id then 
            return true 
        else
            return false
        end
    end)
    local str = ""
    for i, spell in ipairs(spells) do
    	local seg = spell:getHurtSegmentNum()
    	str = str .. "技能ID:" .. spell.id .. " 段数:" .. seg .. "\n"
    end
    
    local file = assert(io.open(RES_ROOT.."/data/spellSegment.txt","w"))
    if file then
        file:write(str)
        file:close()
    end
end

return SpellsDataHelper