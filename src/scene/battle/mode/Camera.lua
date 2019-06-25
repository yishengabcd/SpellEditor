
local Map = nil

local ActionEaseType = require("src/scene/battle/mode/ActionEaseType")
local ITween = require("src/scene/battle/mode/ITween")
local EnterFrameMgr = require("src/scene/battle/manager/EnterFrameMgr")

local _currentMove
local _currentZoom

----------------------CameraMove----------------------
local CameraMove = class("CameraMove", ITween)

function CameraMove:ctor(camera, destX, destY, duration, tweenType,forceCenter)
    self._camera = camera
    self._cameraX = camera:getPositionX()
    self._cameraY = camera:getPositionY()
    self._destX = destX
    self._destY = destY
    self._diffX = destX - self._cameraX
    self._diffY = destY - self._cameraY
    self._forceCenter = forceCenter
    
    CameraMove.super.ctor(self, duration, tweenType)
end

function CameraMove:update(time)
    local x = self._cameraX + self._diffX*time
    local y = self._cameraY + self._diffY*time
    self._camera:setPosition(x,y,self._forceCenter)
end


----------------------CameraZoom----------------------
local CameraZoom = class("CameraZoom", ITween)

function CameraZoom:ctor(camera, destZoom, duration, tweenType,scalePoint,forceCenter)
    self._camera = camera
    self._cameraZoom = camera:getZoom()
    self._destZoom = destZoom
    self._diffZoom = destZoom - self._cameraZoom
    self._scalePoint = scalePoint
    self._forceCenter = forceCenter

    CameraZoom.super.ctor(self, duration, tweenType)
end

function CameraZoom:update(time)
    local zoom = self._cameraZoom + self._diffZoom*time
    self._camera:setZoom(zoom,self._scalePoint,self._forceCenter)
end

----------------------Camera----------------------
--处理地图缩放，移动等逻辑
local Camera = class("Camera")

local winSize = cc.Director:getInstance():getVisibleSize();

function Camera:ctor(map)
    if Map == nil then
        Map = require("src/scene/battle/mode/Map")
    end
    self._map = map
    self._viewport = cc.rect(0,0,map:getViewport().width,map:getViewport().height)
    self._zoom = 1
    self._positionX = 0
    self._positionY = 0
    self._mapScale = map:getMapScale();
    self._scalePoint = cc.p(self._viewport.width/2,self._viewport.height/2)
    
    self:reset()
end


function Camera:zoomTo(value,duration,tweenType, scalePoint,forceCenter)
    if _currentZoom then
        self._map:getTweenMgr():remove(_currentZoom)
        _currentZoom = nil
    end
    if duration and duration > 0 then
        local zoom = CameraZoom.new(self, value, duration, tweenType,scalePoint,forceCenter)
        self._map:getTweenMgr():addTween(zoom)
        _currentZoom = zoom
    else
        self:setZoom(value,scalePoint,forceCenter)    
    end
end


function Camera:moveTo(x, y,duration,tweenType,forceCenter)
    if _currentMove then
        self._map:getTweenMgr():remove(_currentMove)
        _currentMove = nil
    end
    if duration and duration > 0 then
        local move = CameraMove.new(self, x, y, duration, tweenType, forceCenter)
        self._map:getTweenMgr():addTween(move)
        _currentMove = move
    else
        self:setPosition(x,y,forceCenter)
    end
    
end

--forceCenter 是否强制居中
function Camera:setZoom(value,scalePoint,forceCenter)
    if self._zoom ~= value then
        local scalePoint = scalePoint or self._scalePoint
        self._map:setContainerScale(value)
        
        local t = 1/self._zoom - 1/value
        local offsetX = (self._viewport.width/2 - scalePoint.x)*t
        local offsetY = (self._viewport.height/2 - scalePoint.y)*t
        self._zoom = value
        self:setPosition(self._positionX - offsetX, self._positionY - offsetY, forceCenter)
    end
end

--forceCenter 是否强制居中，为true时，不考虑是否超出地图边缘，将指定坐标强行显示在中间
function Camera:setPosition(x, y, forceCenter)
    local mapSize = self._map:getMapSize()
    local tempX = (self._viewport.width/2 - x*self._zoom)--/self._mapScale
    local tempY = (self._viewport.height/2 - y*self._zoom)--/self._mapScale
    
    if not forceCenter then
        if tempX > 0 then
            tempX = 0
        elseif tempX < self._viewport.width - mapSize.width*self._zoom then
            tempX = self._viewport.width - mapSize.width*self._zoom
        end

        if tempY > 0 then
            tempY = 0
        elseif tempY < self._viewport.height - mapSize.height*self._zoom then
            tempY = self._viewport.height - mapSize.height*self._zoom
        end
    end

    self._map:setContainerPosition(tempX, tempY)

    self._positionX = (self._viewport.width/2 - tempX)/self._zoom
    self._positionY = (self._viewport.height/2 - tempY)/self._zoom
end

--聚焦某一点
function Camera:lookAt(pt, zoom, duration,tweenType, forceCenter)
    self:zoomTo(zoom,duration,tweenType,nil, forceCenter)
    self:moveTo(pt.x,pt.y,duration,tweenType, forceCenter)
end

--重置
function Camera:reset(duration,tweenType, forceCenter)
    local mapViewport = self._map:getViewport()
    self:lookAt(cc.p(mapViewport.x + mapViewport.width/2, mapViewport.y + mapViewport.height/2), 1, duration,tweenType, forceCenter)
end

--跟踪指定显示对象
function Camera:follow(target,type,offsetX,offsetY)
    self._followTarget = target
    self._followOffsetX = offsetX or 0
    self._followOffsetY = offsetY or 0
    
    EnterFrameMgr.register(self)
end

function Camera:cancelFollow()
    self._followTarget = nil
    EnterFrameMgr.unregister(self)
end

function Camera:enterFrame(dt)
    if self._followTarget then
        local x,y = self._followTarget:getPosition()
        x = x - self._followOffsetX
        y = y - self._followOffsetY
    end
end

function Camera:getPositionX()
    return self._positionX
end
function Camera:getPositionY()
    return self._positionY
end
function Camera:getZoom()
    return self._zoom
end

--获得地图中某点在屏幕中的坐标
function Camera:getScreenPoint(mapPt)
    local x = self._viewport.width/2 - (self._positionX - mapPt.x)*self._zoom
    local y = self._viewport.height/2 -(self._positionY - mapPt.y)*self._zoom
    return cc.p(x,y)
end

function Camera:dispose()
    self:cancelFollow()
end

return Camera