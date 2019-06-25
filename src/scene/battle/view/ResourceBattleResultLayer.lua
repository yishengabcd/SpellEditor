
local BattleDal = require("src/dal/battle")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local Localized = require("src/localized")
local ResourceDal = require("src/dal/resource")
local ArenaFightInfo = require("src/entities/arenafightinfo")
local ResourceDal = require("src/dal/resource")
local CharacterDal = require("src/dal/character")

local ResourceBattleResultLayer = class("ResourceBattleResultLayer",function () 
    return cc.Layer:create()
end)

local winSize = cc.Director:getInstance():getVisibleSize()
local DESIGN_WIDTH = 960

function ResourceBattleResultLayer:ctor()
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.SETTLEMENT)

    local function exitFun()
        BattleDal:onBattleEndToWin()
        BattleMgr.disposeCurrentBattle()
        SceneManager:getInstance():switchSceneByType(SceneType.MAIN)
    end
    local function onTouchBegan(touch, event)
        return not self._effectPlaying
    end

    local function onTouchEnd(touch, event)
        if self._effectPlaying then
            return
        end
        
        exitFun()
        self:removeFromParent()
        return true
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function ResourceBattleResultLayer:show(parent, isWin, _battleData)
    local scale = winSize.width/DESIGN_WIDTH
    local container = cc.Node:create()
    container:setScale(scale)
    container:setPosition(winSize.width/2, winSize.height/2)

    parent:addChild(self)

    local block = cc.Sprite:create()
    block:setAnchorPoint(0,0)
    block:setTextureRect(cc.rect(0,0,winSize.width,winSize.height))
    block:setColor(FONT_COLOUR.FONT_COLOUR_BLACK)
    block:setOpacity(180)
    self:addChild(block)

    self:addChild(container)
    
        
    local vs = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_icon_vs.png")
    container:addChild(vs)
        

    local actions = {}

    local ArenaBattleTopPanel = require("src/scene/battle/view/ArenaBattleTopPanel")

    local leftInfo = {}
    if _battleData.arenaIsReplay then
        leftInfo.arenaRedNickname = _battleData.arenaRedNickname
        leftInfo.arenaRedLevel = _battleData.arenaRedLevel
        leftInfo.arenaRedHeadId = _battleData.arenaRedHeadId
    else
        leftInfo.arenaRedNickname = CharacterDal:getInfo().nickname
        leftInfo.arenaRedLevel = CharacterDal:getInfo().level
        leftInfo.arenaRedHeadId = CharacterDal:getInfo().headId
    end

    local left = ArenaBattleTopPanel.createLeftPanel(leftInfo)
    if isWin then
        local flag = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_arena_text_win.png")
        flag:setPosition(-210,35)
        left:addChild(flag)
    else
        local flag = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_arena_text_lose.png")
        flag:setPosition(-210,35)
        left:addChild(flag)
    end
    left:setPosition(-DESIGN_WIDTH/2, 28)
    container:addChild(left)


    local rightInfo = {}
    if _battleData.arenaIsReplay then
        rightInfo.arenaBlueNickname = _battleData.arenaBlueNickname
        rightInfo.arenaBlueType = nil
        rightInfo.arenaBlueLevel = _battleData.arenaBlueLevel
        rightInfo.arenaBlueHeadId = _battleData.arenaBlueHeadId
    else
        --require("src/entities/metadata")
        if _battleData.type == GameType.GAME_RESOURCE then
            rightInfo.arenaBlueNickname = ResourceDal:getSearchPlayerInfo().nickname
            rightInfo.arenaBlueType = nil
            rightInfo.arenaBlueLevel = ResourceDal:getSearchPlayerInfo().level
            rightInfo.arenaBlueHeadId = ResourceDal:getSearchPlayerInfo().headId

        elseif _battleData.type == GameType.GAME_EXPEDITION then
            local ExpeditionDal = require("src/dal/expedition")
            local lastTargetLevelId = ExpeditionDal.lastTargetLevelId
            local info = ExpeditionDal:getLevelInfo(lastTargetLevelId)

            rightInfo.arenaBlueNickname = info.nickname
            rightInfo.arenaBlueType = nil
            rightInfo.arenaBlueLevel = info.level
            rightInfo.arenaBlueHeadId = info.head_id
        end
    end



    local right = ArenaBattleTopPanel.createRightPanel(rightInfo)
    if isWin then
        local flag = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_arena_text_lose.png")
        flag:setPosition(220,35)
        right:addChild(flag)
    else
        local flag = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_arena_text_win.png")
        flag:setPosition(220,35)
        right:addChild(flag)
    end
    right:setPosition(DESIGN_WIDTH/2, 28)
    container:addChild(right)

    local moveLeft = cc.MoveTo:create(0.15,cc.p(0, left:getPositionY()))
    left:runAction(moveLeft)
    local moveRight = cc.MoveTo:create(0.15,cc.p(0, right:getPositionY()))
    right:runAction(moveRight)
    self._effectPlaying = true
    local function delayFunc()
        self._effectPlaying = false
        self:doTextEffect()
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(delayFunc)))
end

function ResourceBattleResultLayer:doTextEffect()
    local ret = cc.Label:createWithSystemFont(Localized.lang.hero_press_any_key_continue, FONT_TYPE.DEFAULT_FONT, 20)
    ret:setPosition(winSize.width/2, 30)
    self:addChild(ret)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
    ret:runAction(action)
end

return ResourceBattleResultLayer