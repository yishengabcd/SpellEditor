
local MapItemRollPerformer = class("MapItemRollPerformer")

local scheduler = cc.Director:getInstance():getScheduler()
local winSize = cc.Director:getInstance():getVisibleSize();

function MapItemRollPerformer:ctor(data, layer)
    self._data = data
    self._layer = layer
    self._items = {}
end

function MapItemRollPerformer:start()
    if self._schedulerEntry then return end
    
    self._xDistance = math.abs(self._data.xDistance) - 1
    self._yDistance = math.abs(self._data.yDistance)
    local rect = self._layer:getDisplayRect()
    
    while true do
        local item = self:tryAddItem(rect)
        if not item then
            break
        end
    end

    local function onUpdate(dt)
        local rect = self._layer:getDisplayRect()
        if self._data.xSpeed ~= 0 then
            for _, item in ipairs(self._items) do
                item:setPositionX(item:getPositionX() + self._data.xSpeed)
            end
        elseif self._data.ySpeed ~= 0 then
            for _, item in ipairs(self._items) do
                item:setPositionY(item:getPositionY() + self._data.ySpeed)
            end
        end
        self:tryRemoveItem(rect)
        while true do
            local item = self:tryAddItem(rect)
            if not item then
                break
            end
        end
    end
    self._schedulerEntry = scheduler:scheduleScriptFunc(onUpdate,1/60, false)
end

function MapItemRollPerformer:tryAddItem(rect)
    if self._data.xSpeed ~= 0 then
        if #self._items > 0 then
            local lastItem = self._items[#self._items]
            
            if self._data.xSpeed > 0 then
                local x = lastItem:getPositionX() - self._xDistance
                if x > rect.x - self._data.originalWidth*self._data.scaleX then
                    local item = self._layer:createItem(self._data)
                    self:addItem(item,x,self._data.y)
                    return item
                end
            else
                local x = lastItem:getPositionX() + self._xDistance
                if x < rect.x + rect.width then
                    local item = self._layer:createItem(self._data)
                    self:addItem(item,x,self._data.y)
                    return item
                end
            end
            
            local firstItem = self._items[1]
            if self._data.xSpeed > 0 then
                local x = firstItem:getPositionX() + self._xDistance
                if x < rect.x + rect.width then
                    local item = self._layer:createItem(self._data)
                    self:addItem(item,x,self._data.y, 1)
                    return item
                end
            else
                local x = firstItem:getPositionX() - self._xDistance
                if x > rect.x - self._data.originalWidth*self._data.scaleX then
                    local item = self._layer:createItem(self._data)
                    self:addItem(item,x,self._data.y, 1)
                    return item
                end
            end
        else
            local item = self._layer:createItem(self._data)
            local x
            if self._data.xSpeed > 0 then
                x = rect.x + rect.width - self._data.originalWidth*self._data.scaleX
            else
                x = rect.x
            end
            self:addItem(item,x,self._data.y)
            return item
        end
    elseif self._data.ySpeed ~= 0 then
        if #self._items > 0 then
            local lastItem = self._items[#self._items]

            if self._data.ySpeed > 0 then
                local y = lastItem:getPositionY() - self._yDistance
                if y > rect.y - self._data.originalHeight*self._data.scaleY then
                    local item = self._layer:createItem(self._data)
                    self:addItem(item,self._data.x,y)
                    return item
                end
            else
                local y = lastItem:getPositionY() + self._yDistance
                if y < rect.y + rect.height then
                    local item = self._layer:createItem(self._data)
                    self:addItem(item,self._data.x, y)
                    return item
                end
            end
        else
            local item = self._layer:createItem(self._data)
            local y
            if self._data.ySpeed > 0 then
                y = rect.y + rect.height - self._data.originalHeight*self._data.scaleY
            else
                y = rect.y
            end
            self:addItem(item,self._data.x,y)
            return item
        end
    end
    return nil
end
function MapItemRollPerformer:tryRemoveItem(rect)
    for i = #self._items, 1, -1 do
        local item = self._items[i]
        if self._data.xSpeed ~= 0 then
            if item:getPositionX() > rect.x + rect.width + 300 or item:getPositionX() < rect.x - self._data.originalWidth*self._data.scaleX - 300 then
                self:removeItem(item, i)
            end
        elseif self._data.ySpeed ~= 0 then
            if item:getPositionY() > rect.y + rect.height or item:getPositionY() < rect.y - self._data.originalHeight*self._data.scaleY then
                self:removeItem(item, i)
            end
        end
    end
end

function MapItemRollPerformer:addItem(item, x, y, index)
    local index = index or #self._items + 1
    self._layer:addItem(item)
    item:setPosition(x,y)
    table.insert(self._items, index, item)
end
function MapItemRollPerformer:removeItem(item, index)
    self._layer:removeItem(item)
    table.remove(self._items, index)
end

function MapItemRollPerformer:dispose()
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
        self._schedulerEntry = nil
    end
end

return MapItemRollPerformer