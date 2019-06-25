local Map = require("src/scene/battle/mode/Map")
local MapConfigModel = require("src/scene/battle/data/MapConfigModel")
local DramaMovie = require("src/scene/battle/mode/DramaMovie.lua")
local DramaMovieMgr = require("src/scene/battle/manager/DramaMovieMgr")
local DramaModel = require("src/scene/battle/data/DramaModel") 
local MapData = require("src/scene/battle/data/MapData")

local winSize = cc.Director:getInstance():getVisibleSize()

local DramaMovieView = class("DramaMovieView",function()
    return cc.Node:create()
end)

function DramaMovieView:ctor(plotTemplate, onDramaMovieComplete, mapData)
    self:setAnchorPoint(0, 0)
    local dramaData = DramaModel.getDramaDataById(plotTemplate.plot_resource_id)
    local movie = DramaMovie.new(dramaData)
    DramaMovieMgr.setMovie(movie)
    self._movie = movie

    local rect = cc.rect(0,0,winSize.width,winSize.height)
    
    if plotTemplate.is_edit_map == 1 then
        mapData = MapData.new()
        mapData.mapId = 99999
        mapData:appointResId(dramaData.mapResId)
    end

    local map = Map.new(rect, mapData, nil, DramaMovieMgr.getTweenMgr())
    map:setPosition(0,0)
    map:setOriginY(0)
    map:showOrHideCloseLayer(false, 0)
    map:getCamera():lookAt(cc.p(dramaData.mapX, map:getCamera():getPositionY()), 1)
    self:addChild(map)
    self._map = map

    movie:setMap(map)

    local function onMovieComplete(event)
        DramaMovieMgr.getMovie():removeEventListener(DramaMovie.EVENT_COMPLETE, self._onMovieComplete)
        self._onMovieComplete = nil
        if onDramaMovieComplete then
            onDramaMovieComplete()
        end
    end
    self._onMovieComplete = onMovieComplete
    DramaMovieMgr.getMovie():addEventListener(DramaMovie.EVENT_COMPLETE, self._onMovieComplete)

    local function onNodeEvent(event)
        if "exit" == event then
            if self._onMovieComplete then
                DramaMovieMgr.getMovie():removeEventListener(DramaMovie.EVENT_COMPLETE, self._onMovieComplete)
                self._onMovieComplete = nil
            end
            DramaMovieMgr.disposeCurrentMovie()
            self:removeChild(self._map, true)
        elseif "enter" == event then
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function DramaMovieView:play()
    self._movie:start() 
    local BattleMgr = require("src/scene/battle/manager/BattleMgr") 
    BattleMgr.setDefaultSpeed(1)
end

function DramaMovieView:switchIn(parent, onMiddle, onEnd)
    self:switchOut(parent,onMiddle,onEnd)
end
function DramaMovieView:switchOut(parent, onMiddle, onEnd)
    local sp = cc.Sprite:create();
    sp:setAnchorPoint(0,0)
    sp:setTextureRect(cc.rect(0,0,winSize.width, winSize.height))
    sp:setColor(FONT_COLOUR.FONT_COLOUR_BLACK)
    parent:addChild(sp, 9999999)
    sp:setOpacity(0)
    
    local function onMiddleHandler()
        if onMiddle then
            local BattleMgr = require("src/scene/battle/manager/BattleMgr") 
            BattleMgr.setDefaultSpeed(nil, true)
            local BattleSpeedMgr = require("src/scene/battle/manager/BattleSpeedMgr") 
            BattleSpeedMgr.setSpeed(nil, nil, nil)
            onMiddle()
        end
    end
    
    local function onFadeOutComplete()
        parent:removeChild(sp, true)
        onEnd()
    end
    
    sp:runAction(cc.Sequence:create(cc.FadeIn:create(0.7), cc.CallFunc:create(onMiddleHandler), cc.FadeOut:create(0.7), cc.CallFunc:create(onFadeOutComplete)))
end

return DramaMovieView
