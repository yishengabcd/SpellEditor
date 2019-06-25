
local MapData = require("src/scene/battle/data/MapData")
local MapDal = require("src/dal/map")
local MapUnitFactory = require("src/scene/battle/mode/MapUnitFactory")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local BattleProxy = require("src/dal/battleproxy")
local Timer = require("src/base/timer")

local MapMgr = {}

local _mapData
local _inited
local _started

function MapMgr.init()
    if _inited then return end
    _inited = true
    MapDal:addEventListener(MapDal.EVENT_ENTER_MAP, MapMgr.onEnterMap)
    MapDal:addEventListener(MapDal.EVENT_ADD_UNIT, MapMgr.onAddUnit)
    MapDal:addEventListener(MapDal.EVENT_BEGIN, MapMgr.onBegin)
    MapDal:addEventListener(MapDal.EVENT_DROP, MapMgr.onDrop)
    
    BattleProxy:addEventListener(BattleProxy.EVENT_HP_SUPPLY, MapMgr.onHpSupply)
end

function MapMgr.onEnterMap(event)
    _mapData = event.data
    _started = false
end

function MapMgr.onAddUnit(event)
    local unitInfo = event.data
    if unitInfo.type == MapUnitType.MAP_UNIT_PLAYER then
        _mapData.playerUnitInfo = unitInfo
    elseif unitInfo.type == MapUnitType.MAP_UNIT_MONSTER then
        table.insert(_mapData.roleUnitInfos,unitInfo)
    elseif unitInfo.type == MapUnitType.MAP_UNIT_DROP then
        table.insert(_mapData.drops,unitInfo)
    end
end

function MapMgr.onBegin(event)
    _mapData:refreshMapData()
    MapMgr.onMapStart()
    _started = true
end

function MapMgr.onDrop(event)   
    if _mapData and _mapData.drops then
        table.insert(_mapData.drops,event.data)
    end
end

function MapMgr.onMapStart()
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    local battleData = _mapData:buildBattleData();
    
    local function onBattleStart(delayMove)
        local function startMove()
            local DramaMgr = require("src/scene/battle/manager/DramaMgr")
            DramaMgr.setMapData(_mapData)

            local nextUnitInfo = _mapData:getNearestUnitInfo()
            if nextUnitInfo then
                local toX = nextUnitInfo.x - PositionHelper.getLeftUnitBetweenCenter()-PositionHelper.getRightUnitBetweenCenter()
                MapMgr.playerMoveTo(toX, nextUnitInfo, 40)
            end
        end
        if delayMove then
            Timer.delayCall(delayMove,startMove)
        else
            startMove()
        end
    end
    BattleMgr.battlePrepare(battleData, onBattleStart, true)
end

function MapMgr.checkAndDrop(unitId, pos, position)
    for i, info in ipairs(_mapData.drops) do
        if info.dropFromUnitId == unitId and info.dropFromPosition == pos then
            for j, itemInfo in ipairs(info.dropItems) do
                MapMgr.dropItem(itemInfo, position)
            end
   	    end
   end
--   MapMgr.dropItem({tplId=1,count=5},position)
end

function MapMgr.dropItem(info, position)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
--    for i = 1, info.count  do
        local MapUnitFactory = require("src/scene/battle/mode/MapUnitFactory")
        local drop = MapUnitFactory.DropUnit.new(info)
        drop:setPosition(position.x, position.y)
        BattleMgr.getBattle():getMap():addUnit(drop)
--    end
end


function MapMgr.onHpSupply(event)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")

    BattleMgr.getBattle():getBattleData().hpSupplies = event.data
end

function MapMgr.getMapData()
    return _mapData
end

--移动到下一个节点，能成功移动返回true，没有下一个怪物时返回false
function MapMgr.moveToNext()
    _mapData:removeRoleUnitInfo(_mapData:getNearestUnitInfo())--先把上一个移除了
    
    local nextUnitInfo = _mapData:getNearestUnitInfo()
    if nextUnitInfo then
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        
        local hpSupplies = BattleMgr.getBattle():getBattleData().hpSupplies
        if hpSupplies then
            for i, damage in ipairs(hpSupplies) do
                local role = BattleMgr.getBattle():getRole(damage.targetTeam,damage.targetPosition)
                if role then
                    role:removeHp(damage.realHp, damage.hp, damage.damageType)
                end
            end
            BattleMgr.getBattle():getBattleData().hpSupplies = nil
        end
        
        BattleMgr.getBattle():getBattleData():setFighting(false)
        local infos = nextUnitInfo:toRoleInfos()
        for i, info in ipairs(infos) do
            BattleMgr.getBattle():getBattleData():addRoleInfo(info)
            BattleMgr.getBattle():addRole(info, true)
        end
        _mapData:refreshMapData();
        local toX = nextUnitInfo.x - PositionHelper.getLeftUnitBetweenCenter()-PositionHelper.getRightUnitBetweenCenter()
        MapMgr.playerMoveTo(toX, nextUnitInfo)
        return true
    end
    return false
end

--移动玩家队伍至指定位置
function MapMgr.playerMoveTo(toX, nextUnitInfo, delayFrame)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    local function moveEnd()
        BattleMgr.getBattle():getMap():resetCenter(toX + PositionHelper.getLeftUnitBetweenCenter())
        MapDal:sendInteractObject(nextUnitInfo.uqid)
    end
    local unitInfo = _mapData.playerUnitInfo
    local startX = unitInfo.x
    local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
    local action = BattleCustomActions.TeamMoveAction.new(unitInfo, startX, toX, moveEnd, _mapData)
    if delayFrame then
        action = BattleCustomActions.SequenceAction.new({BattleCustomActions.DelayCallAction.new(nil, delayFrame), action})
    end
    BattleMgr.executeCustomAction(action)
end

return MapMgr