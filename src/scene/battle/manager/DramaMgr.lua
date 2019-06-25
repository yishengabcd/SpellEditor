
local DramaView = require("src/scene/battle/view/DramaView")
local DramaMgr = {}

local _mapData
local _mapTpl
local _dramaIndex
local _callback
local _dramaView
local _dramaDatas

function DramaMgr.setMapData(mapData)
    _mapData = mapData
    if mapData then
        _mapTpl = mapData:getTemplate()
    else
        _mapTpl = nil
    end
    _dramaIndex = 1
    _dramaDatas = nil
end

function DramaMgr.checkTriggerDrama(x)
    
    if _dramaIndex > 3 then return false end
    if _dramaDatas and #_dramaDatas == 0 then
        return false
    end

    
    if _mapTpl then
        if _mapTpl["story_x" .. _dramaIndex] < x and _mapTpl["story_id" .. _dramaIndex] > 0 then
            return true
        end
    end
    return false
end

--播放剧情
function DramaMgr.playDramaById(dramaId, callback, container)
    local dramas = require("src/entities/templatemanager"):getDramas(dramaId)
    if dramas then
        _callback = callback
        container = container or cc.Director:getInstance():getRunningScene()
        _dramaView = DramaView.new()
        _dramaView:start(dramas, DramaMgr.onDramaComplete)
        container:addChild(_dramaView, 100)--z要比连携技能面板大，要在面板之上
    end
end

--针对地图中行走时触发的剧情
function DramaMgr.start(callback)
    _callback = callback
    
    local dramas = _dramaDatas
    if not dramas then
        dramas = require("src/entities/templatemanager"):getDramas(_mapTpl["story_id" .. _dramaIndex])
    end
    
    _dramaIndex = _dramaIndex + 1
    _dramaDatas = require("src/entities/templatemanager"):getDramas(_mapTpl["story_id" .. _dramaIndex])
    
    if #dramas == 0 then
        _callback()
        return false
    end
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    
    _dramaView = DramaView.new()
    _dramaView:start(dramas, DramaMgr.onDramaComplete, require("src/scene/battle/data/BattleData").autoBattle)
    
    BattleMgr.getScene():addChild(_dramaView,70)
    return true
end

function DramaMgr.onDramaComplete()
    if _dramaView then
        _dramaView:getParent():removeChild(_dramaView, true)
        _dramaView = nil
    end
    if _callback then
        local callback = _callback
        _callback = nil
        callback()
    end
end

function DramaMgr.getDramaView()
    return _dramaView
end

return DramaMgr