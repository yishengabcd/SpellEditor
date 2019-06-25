local MapItemType = require("src/scene/battle/mode/MapItemType")
local MapItemBehaviorPerformer = require("src/scene/battle/mode/MapItemBehaviorPerformer")
local MapItemRollPerformer = require("src/scene/battle/mode/MapItemRollPerformer")
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")
local BuildingTitle = require("src/ui/main/buildingTitle")

local MapLayer = class("MapLayer",function ()
    return cc.Node:create()
end)

local winSize = cc.Director:getInstance():getVisibleSize();

function MapLayer:ctor(layerData, map)
    self._layerData = layerData
    self._map = map
    self.speed = layerData.speed
    self._items = {}
    self._particleItems = {}
    self._rollers = {}
    self._buildings = {}
    self._showing = true
    
    self:setAnchorPoint(0,0)
    self:buildItems()
    
    local function onNodeEvent(event)
        for i, item in ipairs(self._items) do
            if item.data.type == MapItemType.SKELETON then
                ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(item.data.path)
        	end
        end
        if "exit" == event then
            for i, roller in ipairs(self._rollers) do
                roller:dispose()
            end
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function MapLayer:refreshItemsVisible()
    if #self._particleItems < 1 then return end
    local left = self:convertToNodeSpace(cc.p(0, 0)).x
    local right = self:convertToNodeSpace(cc.p(winSize.width, 0)).x
    
    for i, particle in ipairs(self._particleItems) do
        local l = particle.data.leftWidth or 1000
        local r = particle.data.rightWidth or 1000
        if particle:getPositionX() + r < left or particle:getPositionX() - l > right then
            particle:setVisible(false)
        else
            particle:setVisible(true)
        end
    end
end

function MapLayer:buildItems()
    self._items = {}
    self._particleItems = {}
    for i, data in ipairs(self._layerData.items) do
        self:addItemByData(data)
    end
end

function MapLayer:addItemByData(data, index)
    local index = index or #self._items+1
    
    if (data.xSpeed ~= 0 and data.xDistance ~= 0) or (data.ySpeed ~= 0 and data.yDistance ~= 0) then
        local roller = MapItemRollPerformer.new(data, self)
        table.insert(self._rollers, roller)
        roller:start()
    else
        local view = self:createItem(data)
        view:setPosition(data.x, data.y)
        
        self:addItem(view,index)
        
        local buildingTitle
        if data.buildingType and data.buildingType ~= 0
            and (data.type == MapItemType.IMAGE or data.type == MapItemType.SKELETON) then
            
            table.insert(self._buildings, view)

            if data.hideTitle ~= 1 then
                buildingTitle = BuildingTitle.new(data.buildingType)
                self:addChild(buildingTitle)
            end
        end

        if buildingTitle then
            if data.titleX then
                buildingTitle:setPositionX(data.x + data.titleX)
            end
            if data.titleY then
                buildingTitle:setPositionY(data.y + data.titleY)
            end
        end
        
        if data.behaviors and #data.behaviors > 0 then
            MapItemBehaviorPerformer.perform(view,data)
        end
    end
end

function MapLayer:addItem(view, index)
    local index = index or #self._items+1
    self:addChild(view)
    table.insert(self._items,index, view)
    if view.data.type == MapItemType.PARTICLE then
        table.insert(self._particleItems, view)
    end
end

function MapLayer:removeItem(view)
    for i, mem in ipairs(self._items) do
        if mem == view then
            table.remove(self._items, i)
            if view.data.type == MapItemType.PARTICLE then
                for j, particle in ipairs(self._particleItems) do
                    if view == particle then
                        table.remove(self._particleItems, j)
                        break;
                    end
                end
            end
            self:removeChild(view,true)
            return
        end
    end
end

function MapLayer:createItem(data)
    local view
    if data.type == MapItemType.IMAGE then
        local path = data.path
        if not MAP_EDITOR then
            path = string.gsub(data.path, "%.[%a%d]+$", "")
            path = path .. ".pvr.ccz"
        end
        view = cc.Sprite:create(path)
--        view:getTexture():setAntiAliasTexParameters()
    elseif data.type == MapItemType.EFFECT then
        local effectSpeed = data.effectSpeed or 1
        view = SimpleEffect.new(data.name, true, effectSpeed, nil, nil, nil, nil, true)
    elseif data.type == MapItemType.SKELETON then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(data.path)
        local n = string.gsub(data.path, "%.[%a%d]+$", "")
        n = string.gsub(n,".+/","")
        
        view = customext.MyArmature:create(n)
        view:getArmature():getAnimation():play("stand")
        view:getArmature():setAnchorPoint(0,0)
        view:setContentSize(view:getArmature():getContentSize())
--        view:setExposureParams(cc.vec3(2.9,1.4,1.4))
    elseif data.type == MapItemType.PARTICLE then
        view = cc.ParticleSystemQuad:create(data.path)
        if data.positionType then
            view:setPositionType(data.positionType)
        end
    end
    view.data = data
    view:setScaleX(data.scaleX or 1)
    view:setScaleY(data.scaleY or 1)
    view:setRotation(data.rotation or 0)
    view:setAnchorPoint(0,0)
    return view
end

function MapLayer:showOrHide(value, duration)
    local duration = duration or 0.3
    if self._showing == value then return end
    self._showing = value
    for i, sp in ipairs(self._items) do
        sp:stopAllActions()
        if value then
            if duration == 0 then
                sp:setOpacity(255)
            else
                sp:runAction(cc.FadeIn:create(duration))
            end
            
            if sp.data.type == MapItemType.PARTICLE then
                sp:setVisible(true)
            end
        else
            if duration == 0 then
                sp:setOpacity(0)
            else
                sp:runAction(cc.FadeOut:create(duration))
            end
            if sp.data.type == MapItemType.PARTICLE then
                sp:setVisible(false)
            end
        end
    end
end

function MapLayer:getBuildingUnderPoint(pt)
    local pt = self:convertToNodeSpace(pt)
    for i=#self._buildings, 1, -1 do
        local item = self._buildings[i]
        local rect
        if item.data.hitRect and item.data.hitRect ~= "" then
            local arr = string.split(item.data.hitRect,",")
            if #arr == 4 then
                local x = tonumber(arr[1])
                local y = tonumber(arr[2])
                local w = tonumber(arr[3])
                local h = tonumber(arr[4])
                if x and y and w and h then
                    rect = cc.rect(x,y,w,h)
                end
            end
        end
        if not rect then
            rect = cc.rect(item:getPositionX(),item:getPositionY(),item:getContentSize().width,item:getContentSize().height)
        end
        if cc.rectContainsPoint(rect,pt) then
            return item
        end
    end
end

function MapLayer:getDisplayRect()
    local bl
    local tr
    if MAP_EDITOR then 
        bl = self:convertToNodeSpace(cc.p((winSize.width - 960)/2,(winSize.height - 640)/2))
        tr = self:convertToNodeSpace(cc.p(winSize.width - (winSize.width - 960)/2,winSize.height-(winSize.height - 640)/2))
    else
        bl = self:convertToNodeSpace(cc.p(0,0))
        tr = self:convertToNodeSpace(cc.p(winSize.width, winSize.height))
    end
    return cc.rect(bl.x,bl.y,tr.x - bl.x, tr.y - bl.y)
end

function MapLayer:getMap()
    return self._map
end

function MapLayer:getLayerData()
    return self._layerData
end

function MapLayer:getBuildings()
    return self._buildings
end

return MapLayer