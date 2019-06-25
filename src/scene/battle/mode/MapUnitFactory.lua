
local BattleSpeedMgr = require("src/scene/battle/manager/BattleSpeedMgr")
local ItemSlot = require("src/ui/bag/itemslot")

local MapUnit = class("MapUnit", function () return cc.Node:create() end)
local DropUnit = class("DropUnit", function () return cc.Node:create() end)


------------------------MapUnitFactory------------------
local MapUnitFactory = {}
MapUnitFactory.DropUnit = DropUnit

function MapUnitFactory.create(info)
    local unit = DropUnit.new(info)
    return unit
end

------------------------MapUnit------------------
function MapUnit:ctor(info)
    self._info = info
end

function MapUnit:setMap(map)
    self._map = map
end

function MapUnit:getInfo()
    return self._info
end

------------------------DropUnit------------------
function DropUnit:ctor(info)
    self._info = info
    self.collectable = true
end

function DropUnit:setMap(map)
    self._map = map
    
    local tpl = require("src/entities/templatemanager"):getItemTplById(self._info.tplId)

    local item = ItemSlot:create()
    item:setAnchorPoint(0.5,0.5)
    item:setScale(0.5)
    item:setTpl(tpl)
    item:setStack(self._info.count)
    self:setContentSize(item:getContentSize())
    self:addChild(item)
    
--    local sp = cc.Sprite:createWithSpriteFrameName("ui/icons/box01.png")
--    self:addChild(sp)
--    self:setContentSize(sp:getContentSize())
    
    local function onExitHandler(event)
        if "exit" == event then
            BattleSpeedMgr.removeMember(self)
            self._speedAction = nil
        end
    end

    self:registerScriptHandler(onExitHandler)
    
    local destY = math.random()*100 - 50
    local height = math.abs(destY)+50
    destY = destY - 80
    
    map:setUnitDepth(self, self:getPositionY()+destY)
    
    local action = cc.JumpBy:create(0.8*height/100,cc.p(math.random()*100 - 50,destY), height,1)
    local action1 = cc.JumpBy:create(0.1,cc.p(0,0), 20*height/100,1)
    action = cc.Sequence:create(action,action1)

    local speedAction = cc.Speed:create(action,1)
    self._speedAction = speedAction
--    BattleSpeedMgr.addMember(self)
    self:runAction(speedAction)
    
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        local pt = self:convertToNodeSpace(location)
        local rect = cc.rect(-self:getContentSize().width/2,-self:getContentSize().height/2,self:getContentSize().width,self:getContentSize().height)
        if cc.rectContainsPoint(rect,pt) then
            self:onCollect()
            return true
        end
        return false
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function DropUnit:onCollect()
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    
    local pt = self:convertToWorldSpace(cc.p(0,0))
--    local sp = cc.Sprite:createWithSpriteFrameName("ui/icons/box01.png")
--    sp:setPosition(pt.x, pt.y)
--    BattleMgr.getScene():addChild(sp)
    
    local tpl = require("src/entities/templatemanager"):getItemTplById(self._info.tplId)

    local sp = ItemSlot:create()
    sp:setAnchorPoint(0.5,0.5)
    sp:setScale(0.5)
    sp:setTpl(tpl)
    sp:setStack(self._info.count)
    self:setContentSize(sp:getContentSize())
    sp:setPosition(pt.x, pt.y)
    BattleMgr.getScene():addChild(sp)
    
    local x, y = BattleMgr.getScene():getCollectBox():getPosition()
    local action = cc.MoveTo:create(0.4, cc.p(x,y))
    local call = cc.CallFunc:create(function () 
        self._speedAction = nil
        sp:getParent():removeChild(sp, true) 
        if BattleMgr.getBattle() and BattleMgr.getBattle():getBattleData().mapData then
            local mapData = BattleMgr.getBattle():getBattleData().mapData
            mapData:setCollectNum(mapData.collectNum + 1)
        end
    end)
    action = cc.Sequence:create(action,call)
    sp:runAction(action)
    
    self._map:removeUnit(self);
end
function DropUnit:getInfo()
    return self._info
end

function DropUnit:setSpeed(speed)
    if self._speedAction then
        self._speedAction:setSpeed(speed)
    end
end

----------------------------------------------------------
return MapUnitFactory