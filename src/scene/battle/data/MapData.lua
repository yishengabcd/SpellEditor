local LoaderType = require("src/scene/loading/loadertype")
local MapConfigModel = require("src/scene/battle/data/MapConfigModel")
local MapItemType = require("src/scene/battle/mode/MapItemType")
local MapData = class("MapData")

MapData.mapId = 1000
MapData.mapPic = "ui/map1.png"
MapData.mapType = 1
MapData.storyId = 1
MapData.maxWave = 1
MapData.currWave = 1
MapData.collectNum = 0
MapData.playerUnitInfo = nil --玩家单位数据
MapData.roleUnitInfos = nil --角色类型的单位列表（英雄，怪物）,不包含玩家本人
MapData.drops = nil --掉落的物品列表
MapData.isFirstEnter = nil --是否是第一次进入
MapData.isPasted = nil --是否已经通关

MapData.EVENT_WAVE_CHANGE = "eventWaveChange"
MapData.EVENT_COLLECT = "eventCollect"

function MapData:ctor()
    local EventProtocol = require("src/utils/EventProtocol")
    EventProtocol.extend(self)
    self.roleUnitInfos = {}
    self.drops = {}
end

function MapData:setCurrWave(value)
    if self.currWave ~= value then
        self.currWave = value
        self:dispatchEvent({name=MapData.EVENT_WAVE_CHANGE})
    end
end

function MapData:setCollectNum(value)
    if self.collectNum ~= value then
        self.collectNum = value
        self:dispatchEvent({name=MapData.EVENT_COLLECT})
    end
end

function MapData:buildBattleData()
    local battleData = require("src/scene/battle/data/BattleData").new()
    battleData.fighting = false
    battleData.myTeam = self.playerUnitInfo.team
    battleData.mapData = self
    battleData.roleInfos = {}
    battleData.maxLevel = self.playerUnitInfo.maxLevel
    
    local unitInfos = {self.playerUnitInfo, self:getNearestUnitInfo()}
    for k, v in ipairs(unitInfos) do
    	local infos = v:toRoleInfos()
        for i, info in ipairs(infos) do
            info.myTeamMaxLevel = battleData.maxLevel
            table.insert(battleData.roleInfos,info)
    	end
    end
    
    battleData:resolveFormations()
    return battleData
end

--获得玩家单位的X坐标
function MapData:getPlayerUnitX()
    if self.playerUnitInfo then
        return self.playerUnitInfo.x
    end
    return nil
end

function MapData:getNearestUnitInfo()
    local player = self.playerUnitInfo
    if player then
        local playerX = player.x
        local x = 9999999
        local destData
        for k, v in ipairs(self.roleUnitInfos) do
            if v.x < x then
                x = v.x
                destData = v
            end
        end
        return destData
    end
end

function MapData:removeRoleUnitInfo(unitInfo)
    for i, v in ipairs(self.roleUnitInfos) do
        if v == unitInfo then
            table.remove(self.roleUnitInfos,i)
            break
        end
    end
end

function MapData:refreshMapData()
    local left = #self.roleUnitInfos
    if self.maxWave < left then
        self.maxWave = left
    end
    self:setCurrWave(self.maxWave - left + 1)
end

--获得要预加载的资源
function MapData:getPreloadList()
    local resId
    if self.mapId == 1 then
        resId = 3
    else
        local mapTpl = require("src/entities/templatemanager"):getMapTplById(self.mapId)
        assert(mapTpl,"Can't find mapTpl, id = " .. self.mapId)
        resId = mapTpl.map_res_id
    end
    
    
    local list = {}
    local mapConfigData = MapConfigModel.getMapDataById(resId)
    for i, layerData in ipairs(mapConfigData.layers) do
        self:getLayerPreloadList(layerData,list)
    end
    return list
end
function MapData:getLayerPreloadList(layerData, list)
    for i, data in ipairs(layerData.items) do
        if data.type == MapItemType.IMAGE then
            local path = data.path
            if not MAP_EDITOR then
                path = string.gsub(data.path, "%.[%a%d]+$", "")
                path = path .. ".pvr.ccz"
            end
            table.insert(list,{type=LoaderType.IMAGE, path=path})
        elseif data.type == MapItemType.EFFECT then
--            local effectSpeed = data.effectSpeed or 1
        elseif data.type == MapItemType.SKELETON then
            table.insert(list,{type=LoaderType.SKELETON, path=data.path})
        end
    end
end
function MapData:getResId()
    return self._appointResId or self:getTemplate().map_res_id
end
--指定资源ID
function MapData:appointResId(value)
    self._appointResId = value
end
function MapData:getTemplate()
    return require("src/entities/templatemanager"):getMapTplById(self.mapId)
end

return MapData