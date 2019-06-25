local Localized = require("src/localized")
local Scale3Sprite = require("src/base/ui/scale3sprite")

local DramaView = class("DramaView", function ()
    return cc.Layer:create()
end)

DramaView._pause = nil

local winSize = cc.Director:getInstance():getVisibleSize()
local scheduler = cc.Director:getInstance():getScheduler()

local SIDE_LEFT = 1
local SIDE_RIGHT = 2

local HEAD_WIDTH = 400 --头像占位宽
--玩家昵称，用于替换剧情中的{nickname}
local nickname = nil

function DramaView:start(dramas, callback, auto)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.COMMON)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.STORY)
    self._dramas = dramas
    self._callback = callback
    self._count = 1
    self._auto = auto
    nickname = require("src/dal/character"):getInfo().nickname
    
    local block = cc.LayerColor:create(cc.c4b(0,0,0,125))
    self:addChild(block)
    
    local container = cc.Node:create()
    container:setAnchorPoint(0, 0)
    self:addChild(container)
    self._container = container
    
--    local back = cc.Sprite:createWithSpriteFrameName("ui/story/ui_story_bg_text.png")
--    back:setAnchorPoint(cc.p(0,0))
--    container:addChild(back, 1)
--    self._back = back
    
    local backWidth = 1136
    if winSize.height/winSize.width > 640/960 - 0.01 then
        backWidth = 960
    end
    
    local back = Scale3Sprite:createWithSpriteName("ui/common/ui_story_bg_left.png","ui/common/ui_story_bg_m.png","ui/common/ui_story_bg_right.png")
    back:setAnchorPoint(cc.p(0,0))
    container:addChild(back, 1)
    back:setContentSize(cc.size(backWidth, 0))
    self._back = back
    
    container:setScale(winSize.width/back:getContentSize().width)
    
    local nameBack = cc.Sprite:createWithSpriteFrameName("ui/story/ui_story_bg_name.png")
    nameBack:setPositionY(192)
    container:addChild(nameBack, 1)
    self._nameBack = nameBack
    
    local name = cc.Label:createWithSystemFont("", FONT_TYPE.DEFAULT_FONT, 28)
    name:setColor(cc.c3b(255,255,255))
    container:addChild(name, 1)
    name:setPositionY(nameBack:getPositionY())
    self._name = name
    
    local words = cc.Label:createWithSystemFont("", FONT_TYPE.DEFAULT_FONT, 28)
    words:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    words:setColor(cc.c3b(243,219,195))
    words:setAnchorPoint(cc.p(0,1))
    words:setPosition(120,150)
    words:setDimensions(back:getContentSize().width - 240,0)
    container:addChild(words, 1)
    self._words = words
    
    local clickTip = cc.Sprite:createWithSpriteFrameName("ui/story/ui_story_icon_skip.png")
    clickTip:setPosition(back:getContentSize().width - 60,45)
    container:addChild(clickTip, 1)
    
    self:showOne()
    
    local function onTouchBegan(touch, event)
        if self._pause then
            return
        end
        self:showNext()
        return true
    end
    
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function DramaView:showOne()
    local drama = self._dramas[self._count]
    
    local name = drama["npc_name" .. Localized.type]:formatKeyValue({nickname = nickname})
    local words = drama["npc_words" .. Localized.type]:formatKeyValue({nickname = nickname})
    self._name:setString(name)
    self._words:setString(words)
    
    local headUrl = "ui/npc/" .. drama.npc_avatar_res .. ".pvr.ccz"
    if self._headUrl ~= headUrl then
        if self._head then
            self._container:removeChild(self._head,true)
            self._head = nil
        end
        local head = cc.Sprite:create(headUrl)
        head:setAnchorPoint(cc.p(0.5, 0))
        self._container:addChild(head, 0)
        self._head = head
    end

    if drama.position == SIDE_LEFT then
        self._nameBack:setPositionX(180)
        if self._head then
            self._head:setPosition(HEAD_WIDTH/2, 60)
        end
    else
        self._nameBack:setPositionX(self._back:getContentSize().width - 180)
        if self._head then
            self._head:setPosition(self._back:getContentSize().width -HEAD_WIDTH/2, 60)
            self._head:setScaleX(-1)
        end
    end
    self._name:setPositionX(self._nameBack:getPositionX())
    local autoTime = 4;
    if self._auto then
        autoTime = 2
    end
    local function timeOut()
        if self._pause then
            return
        end
        if self._schedulerEntry then
            scheduler:unscheduleScriptEntry(self._schedulerEntry)
            self._schedulerEntry = nil
        end
        self:showNext()
    end
    self._schedulerEntry = scheduler:scheduleScriptFunc(timeOut,autoTime,false)
end

function DramaView:showNext()
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
        self._schedulerEntry = nil
    end
    self._count = self._count + 1
    if self._count > #self._dramas then
        self._callback()
    else
        self:showOne()
    end
end

function DramaView:pause()
    self._pause = true
end

function DramaView:resume()
    self._pause = false
end

return DramaView