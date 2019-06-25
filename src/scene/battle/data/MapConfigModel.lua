
local MapConfigDataExtend = require("src/scene/battle/mode/MapConfigDataExtend")

local MapConfigModel = {}
local _inited

--加载技能配置信息
function MapConfigModel.load()
    if _inited then return end
    _inited = true
    local mapDatas = require("data/EditorMapsData")
    for i, v in ipairs(mapDatas) do
        MapConfigDataExtend.extend(v)
    end

    MapConfigModel._mapDatas = mapDatas
end

function MapConfigModel.getMapDatas()
    return MapConfigModel._mapDatas
end

--获得指定id的技能配置数据
function MapConfigModel.getMapDataById(id)
    for i, v in ipairs(MapConfigModel._mapDatas) do
        if v.id == id then
            return v
        end
    end
    return nil
end

return MapConfigModel