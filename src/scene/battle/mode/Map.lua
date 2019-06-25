
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local Camera = require("src/scene/battle/mode/Camera")
local MapLayer = require("src/scene/battle/mode/MapLayer")
local MapConfigModel = require("src/scene/battle/data/MapConfigModel")
local CurtainView = require("src/scene/battle/view/CurtainView")
local DramaViewII = require("src/scene/battle/view/DramaViewII")
local EffectMgr = require("src/scene/battle/manager/EffectMgr")

local Map = class("Map",function () 
    return cc.Layer:create() 
end)


local winSize = cc.Director:getInstance():getVisibleSize();

Map.MAIN_Z_BACKGROUND = -900000 --背景层
Map.MAIN_Z_ROLE_BACK = -800000 --角色背后层
Map.MAIN_Z_ROLE = -700000 --角色层
Map.MAIN_Z_ROLE_FRONT = 100000 -- 角色前面层

Map.LAYER_Z_BACK = 500000
Map.LAYER_Z_MAIN = 600000 --活动层
Map.LAYER_Z_FRONT = 700000
Map.LAYER_Z_TOP = 900000

function Map:ctor(viewport, mapData, mapSize, tweenMgr)
    self._tweenMgr = tweenMgr
    if LD_EDITOR and not MAP_EDITOR then
        mapSize = cc.size(5000,800)
    else
        
        if MAP_EDITOR then
            self._mapConfigData = MapConfigModel.getMapDataById(mapData.mapId)
        else
            local resId = mapData:getResId()
            self._mapConfigData = MapConfigModel.getMapDataById(resId)
        end
        
        if not mapSize then
            mapSize = cc.size(self._mapConfigData.width,self._mapConfigData.height)
        end
    end
    self._mapSize = mapSize
    local tempSize = cc.size(mapSize.width,mapSize.height)
    
    if tempSize.width > 1136 then tempSize.width = 1136 end
    local scale = 1
    
        if viewport.height > tempSize.height or viewport.width > tempSize.width then
            if viewport.height/tempSize.height > viewport.width/tempSize.width then
                scale = viewport.height/tempSize.height
                self:setScale(scale)
                self:setPositionX(-viewport.width*(scale-1)/2)
                viewport.height = tempSize.height
            else
                scale = viewport.width/tempSize.width
                self:setScale(scale)
                viewport.width = tempSize.width
                viewport.height = tempSize.height/scale
            end
        end
--    end
    
    self._mapScale = scale
    
    PositionHelper.setCenter(cc.p(viewport.x + viewport.width/2, viewport.y + viewport.height/2))
    self._viewport = viewport
    self._roles = {}
    self._units = {}
    self._originY = 0
    self:setAnchorPoint(0,0)
    
    local activeLayer = cc.Node:create()
    activeLayer:setAnchorPoint(0,0)
    self:addChild(activeLayer, Map.LAYER_Z_MAIN)
    self._activeLayer = activeLayer
    
    local replaceBackgroundLayer = cc.Node:create()
    replaceBackgroundLayer:setAnchorPoint(0,0)
    self:addChild(replaceBackgroundLayer, Map.LAYER_Z_MAIN)
    self._replaceBackgroundLayer = replaceBackgroundLayer
    
    local container = cc.Node:create()
    container:setAnchorPoint(0,0)
    self:addChild(container, Map.LAYER_Z_MAIN)
    self._container = container 
    
    self:setMapData(mapData)
    
    local topUnrestrictedLayer = cc.Node:create()
    topUnrestrictedLayer:setAnchorPoint(0,0)
    self:addChild(topUnrestrictedLayer, Map.LAYER_Z_TOP)
    self._topUnrestrictedLayer = topUnrestrictedLayer
    
    local function onExitHandler(event)
        if "exit" == event then
            EffectMgr.removeEffectByContainer(self._container)
            if self._camera then
                self._camera:dispose()
                self._camera = nil
            end
        end
    end
    
    self:registerScriptHandler(handler)
end

function Map:setBattle(battle)
    self._battle = battle
end

function Map:getBattle()
    return self._battle
end

function Map:setMapData(data)
    self._data = data
    if LD_EDITOR and not MAP_EDITOR then
        if self._back then
            self:removeChild(self._back, true)
        end
        local back = cc.Sprite:create("ui/map1.png")
        back:setAnchorPoint(0,0)
        self._activeLayer:addChild(back,Map.MAIN_Z_BACKGROUND)
        self._back = back
        self._layers = {}
    else
        self:buildLayers()
    end  
    self._camera = Camera.new(self)  
end

function Map:resetCamera(duration, tween, forceCenter)
    self._camera:reset(duration, tween, forceCenter)
end
function Map:resetCenter(centerX)
    self._viewport.x = centerX - self._viewport.width/2
    PositionHelper.setCenter(cc.p(centerX, PositionHelper.getCenter().y))
end

function Map:buildLayers()
    self._layers = {}
    for i, layerData in ipairs(self._mapConfigData.layers) do
        local layer = self:addLayerByData(layerData, i)
        if layerData.isActive == 1 then
            self._mainLayer = layer
        end
    end
end

function Map:addLayerByData(layerData, i)
    local layer = MapLayer.new(layerData, self)
    
    if layerData.isActive == 1 then
        self._activeLayer:addChild(layer, Map.MAIN_Z_BACKGROUND)
    else
        if self._mainLayer then
            self:addChild(layer, Map.LAYER_Z_FRONT + i)
        else
            self:addChild(layer, Map.LAYER_Z_BACK + i)
        end
        table.insert(self._layers, layer)
    end
    return layer
end

--设置活动层的坐标
function Map:setContainerPosition(x, y)
    self._container:setPosition(x,y)
    self._activeLayer:setPosition(x,y)
    for i, layer in ipairs(self._layers) do
        layer:setPosition(x*layer.speed,y);
        layer:refreshItemsVisible()
    end
    if self._mainLayer then
        self._mainLayer:refreshItemsVisible()
    end
end
function Map:setContainerScale(value)
    self._container:setScale(value)
    self._activeLayer:setScale(value)
    for i, layer in ipairs(self._layers) do
        layer:setScale(value);
    end
end

--添加角色到地图中
function Map:addRole(role)
    table.insert(self._roles, role)
    self._container:addChild(role,Map.MAIN_Z_ROLE)
    role:setMap(self)
end

--将角色从地图中移除
function Map:removeRole(role)
    for i, mem in ipairs(self._roles) do
    	if mem == role then
    	   table.remove(self._roles,i)
            self._container:removeChild(role, true)
    	   return
    	end
    end
end

function Map:addUnit(unit)
    table.insert(self._units,unit)
    self._container:addChild(unit,Map.MAIN_Z_ROLE)
    unit:setMap(self);
end

function Map:removeUnit(unit)
    for i, mem in ipairs(self._units) do
        if mem == unit then
            table.remove(self._units,i)
            self._container:removeChild(unit, true)
            return
        end
    end
end

--队伍行走时，收集掉落的物品
function Map:collectDrops(x)
    local list = {}
    for i, unit in ipairs(self._units) do
        if unit.collectable then
            if unit:getPositionX() < x then
                table.insert(list,unit)
            end
        end
    end
    for i, unit in ipairs(list) do
        unit:onCollect()
    end
end

function Map:collectAllDrops()
    local list = {}
    for i, unit in ipairs(self._units) do
        if unit.collectable then
            table.insert(list,unit)
        end
    end
    for i, unit in ipairs(list) do
        unit:onCollect()
    end
end

--在地图上添加特效
--level 显示在哪个层次，1表示在人物上层，-1表示在人物下层
function Map:addEffect(effect,position,level, levelAddition)
    local levelAddition = levelAddition or 0
    effect:setPosition(position)
    local z = level == -1 and Map.MAIN_Z_ROLE_BACK or Map.MAIN_Z_ROLE_FRONT
    self._container:addChild(effect, z+levelAddition)
    if effect.name then
        EffectMgr.addEffect(effect.name,effect,self._container)
    end
end

function Map:bringToFront(effect)
    effect:setLocalZOrder(Map.MAIN_Z_ROLE_FRONT)
end

function Map:sendToBack(effect)
    effect:setLocalZOrder(Map.MAIN_Z_ROLE_BACK)
end

function Map:removeEffect(effect)
    self._container:removeChild(effect, true)
end

function Map:replaceBackground(effect)
    self._replaceBackgroundLayer:removeAllChildren(true)
    self._replaceBackgroundLayer:addChild(effect)
end

function Map:removeReplaceBackground()
    self._replaceBackgroundLayer:removeAllChildren(true)
end

function Map:playCurtain(words)
    self:removeCurtain()
    self._curtainView = CurtainView.new(words)
    self._curtainView:setPosition(self._viewport.width/2, self._viewport.height/2)
    self._topUnrestrictedLayer:addChild(self._curtainView)
    return self._curtainView
end
function Map:removeCurtain()
    if self._curtainView then
        self._topUnrestrictedLayer:removeChild(self._curtainView, true)
        self._curtainView = nil
    end
end

function Map:playDramaMovieDialog(data)
    if not self._dramaViewII then
        
        local parent
        if LD_EDITOR then
            self._dramaViewII = DramaViewII.new(cc.size(self._viewport.width, self._viewport.height))
            parent = self._topUnrestrictedLayer
        else
            self._dramaViewII = DramaViewII.new()
            parent = cc.Director:getInstance():getRunningScene()
        end
        parent:addChild(self._dramaViewII, 100)
    end
    self._dramaViewII:play(data)
end
function Map:removeDramaMovieDialog()
    if self._dramaViewII then
        self._dramaViewII:removeFromParent()
        self._dramaViewII = nil
    end
end

--黑屏, alpha 0-255，值越大越黑
function Map:setBlackScreen(alpha, color3b)
    local color3b = color3b or cc.c3b(0,0,0)
    if alpha and alpha > 0 then
        if self._blackBlock == nil then
            local sp = cc.Sprite:create()
            local rect = cc.rect(0,0,winSize.width*4,winSize.height*4)
            sp:setTextureRect(rect)
            sp:setPosition(self._viewport.x + self._viewport.width/2,self._viewport.y + self._viewport.height/2)
            
            self._container:addChild(sp, Map.MAIN_Z_ROLE_BACK)
            self._blackBlock = sp
        end
        self._blackBlock:setOpacity(alpha)
        self._blackBlock:setColor(color3b)
        self:setSceneColor(color3b)
    else
        if self._blackBlock then
            self._container:removeChild(self._blackBlock,true)
            self._blackBlock = nil
            self:setSceneColor(nil)
        end
    end
end

function Map:setSceneColor(cl)
    local visible = cl == nil and true or false 
    for i, layer in ipairs(self._layers) do
        if layer:getLayerData().hideInBattle == 1 then
            layer:setVisible(visible)
        end
    end
end

function Map:showOrHideCloseLayer(value, duration)
    for i, layer in ipairs(self._layers) do
        if layer:getLayerData().hideInBattle == 1 then
            layer:showOrHide(value, duration)
        end
    end
end

function Map:setUnitDepth(target, y)
    target:setLocalZOrder(Map.MAIN_Z_ROLE - y + 1000)
end

function Map:setOriginY(value)
    self._originY = value
end
function Map:getOriginY()
    return self._originY
end

function Map:getViewport()
    return self._viewport
end
function Map:getContainer()
    return self._container
end
function Map:getMainLayer()
    return self._mainLayer
end
function Map:getCamera()
    return self._camera
end
function Map:getDisplayRect()
    local bl
    local tr
    if MAP_EDITOR then 
        bl = self._container:convertToNodeSpace(cc.p((winSize.width - 960)/2,(winSize.height - 640)/2))
        tr = self._container:convertToNodeSpace(cc.p(winSize.width - (winSize.width - 960)/2,winSize.height-(winSize.height - 640)/2))
    else
        bl = self._container:convertToNodeSpace(cc.p(0,0))
        tr = self._container:convertToNodeSpace(cc.p(winSize.width, winSize.height))
    end
    return cc.rect(bl.x,bl.y,tr.x - bl.x, tr.y - bl.y)
end
function Map:getTweenMgr()
    if self._tweenMgr then return self._tweenMgr end
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    return BattleMgr.getTweenMgr()
end
function Map:setTweenMgr(tweenMgr)
    self._tweenMgr = tweenMgr
end

function Map:getBuildingUnderPoint(pt)
    local building = self._mainLayer:getBuildingUnderPoint(pt)
    if not building then
        for i = #self._layers,  1, -1 do
            local layer = self._layers[i]
            building = layer:getBuildingUnderPoint(pt)
            if building then
                return building
            end
        end
    end
    
    return building
end

function Map:getTopUnrestrictedLayer()
    return self._topUnrestrictedLayer
end

function Map:getMapScale()
    return self._mapScale;
end

--地图的尺寸
function Map:getMapSize()
    return self._mapSize
end


return Map