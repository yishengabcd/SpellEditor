
local BattleDal = require("src/dal/battle")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local Localized = require("src/localized")
local ArenaFightInfo = require("src/entities/arenafightinfo")

local ArenaBattleResultLayer = class("ArenaBattleResultLayer",function () 
    return cc.Layer:create()
end)

local winSize = cc.Director:getInstance():getVisibleSize()
local DESIGN_WIDTH = 960

function ArenaBattleResultLayer:ctor()
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
        if self._promotePanel then
            self._promotePanel:removeFromParent()
            self._promotePanel = nil

            self._promoteBlock:removeFromParent()
            self._promoteBlock = nil
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

function ArenaBattleResultLayer:show(parent, battleData)
    self._battleData = battleData
    local scale = winSize.width/DESIGN_WIDTH
    local container = cc.Node:create()
    container:setScale(scale)
    container:setPosition(winSize.width/2, winSize.height/2)


    parent:addChild(self)

    if not battleData:isAllDeadOfOneSide() then --如果两边都没有完成死亡，说明是超时了
        local timeOverBack = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_bg_timeover.png")
        container:addChild(timeOverBack)

        local tips =cc.LabelTTF:create(Localized.lang.battle_arena_time_over, FONT_TYPE.DEFAULT_FONT_BOLD, 26)
        tips:enableStroke(cc.c3b(255,84,0), 3)
        container:addChild(tips)
        tips:setAnchorPoint(cc.p(0.5,0.5))
        tips:setColor(cc.c3b(255,255,255))
        self:addChild(container)
    else
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

        local left = ArenaBattleTopPanel.createLeftPanel(battleData)
        if battleData.arenaIsWin then
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

        local right = ArenaBattleTopPanel.createRightPanel(battleData)
        if battleData.arenaIsWin then
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

        if battleData.arenaIsWin and not battleData.arenaIsPromote then
            
            local medalBack = cc.Sprite:createWithSpriteFrameName("ui/settlement/ui_login_littleTitle.png")
            medalBack:setPosition(-DESIGN_WIDTH/2 - 100,-90)
            container:addChild(medalBack)

            local medalNode = cc.Node:create()

            container:addChild(medalNode)

            local medalTitle = cc.Label:createWithSystemFont(Localized.lang.battle_arena_honor_title,FONT_TYPE.DEFAULT_FONT,18)
            medalTitle:setColor(cc.c3b(0, 255, 42))
            medalNode:addChild(medalTitle)

            local medalValue = cc.Label:createWithSystemFont("+" .. battleData.arenaMedal,FONT_TYPE.DEFAULT_FONT,18)
            medalValue:setColor(cc.c3b(255, 255, 255))
            medalNode:addChild(medalValue)
            local w = medalTitle:getContentSize().width + medalValue:getContentSize().width
            medalTitle:setPositionX(medalTitle:getContentSize().width/2 - w/2)
            medalValue:setPosition(medalTitle:getPositionX() + medalTitle:getContentSize().width/2 + medalValue:getContentSize().width/2, medalTitle:getPositionY())

            medalNode:setPosition(DESIGN_WIDTH/2 + 100, medalBack:getPositionY())

            local action = cc.MoveTo:create(0.15,cc.p(0, medalBack:getPositionY()))
            medalBack:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), action))

            local action = cc.MoveTo:create(0.15,cc.p(0, medalNode:getPositionY()))
            medalNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), action))

            local rankTips = cc.Label:createWithSystemFont(string.format(Localized.lang.battle_arena_rank_up,battleData.arenaRank), FONT_TYPE.DEFAULT_FONT,30)
            rankTips:setColor(cc.c3b(255, 90, 0))
            rankTips:setPosition(0, -winSize.height/2/scale - 50)
            container:addChild(rankTips)

            local action = cc.MoveTo:create(0.2,cc.p(rankTips:getPositionX(), -150))
            rankTips:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), action))
        end

        local function showPromotePanel()
            ResourceManager:getInstance():loadPlistByType(ResourceModuleType.ARENA)

            local promoteBlock = cc.Sprite:create()
            promoteBlock:setAnchorPoint(0,0)
            promoteBlock:setTextureRect(cc.rect(0,0,winSize.width,winSize.height))
            promoteBlock:setColor(FONT_COLOUR.FONT_COLOUR_BLACK)
            promoteBlock:setOpacity(180)
            self:addChild(promoteBlock)
            self._promoteBlock = promoteBlock

            local promotePanel = cc.Node:create()
            promotePanel:setScale(scale)
            promotePanel:setPosition(winSize.width/2,winSize.height/2)
            self:addChild(promotePanel)
            self._promotePanel = promotePanel

            local back = cc.Sprite:create("res/image/ui/common/ui_arena_bg_tips.png")
            promotePanel:addChild(back)
            
            local info = ArenaFightInfo.new()
            info.groupId = battleData.arenaGroupId
            local group = info:getTeam()
            local team = Localized.lang["arena_team" .. group]
            if not team then
                team = Localized.lang.arena_team6
            end
            local step = info:getStep()

            local icon = cc.Sprite:createWithSpriteFrameName("ui/arena/ui_arena_icon_" .. group ..".png")
            promotePanel:addChild(icon)
            icon:setPosition(0, 40)

            local stepBg = cc.Sprite:createWithSpriteFrameName("ui/arena/ui_arena_bg_" .. group .. ".png")
            promotePanel:addChild(stepBg)
            stepBg:setPosition(32, icon:getPositionY() - 15)

            local stepIcon = cc.Sprite:createWithSpriteFrameName("ui/arena/ui_arena_icon_group" .. step .. ".png")
            promotePanel:addChild(stepIcon)
            stepIcon:setPosition(stepBg:getPosition())


            local tips = cc.Label:createWithSystemFont(Localized.lang.battle_arena_promote:format(team .. Localized.lang["arena_step" .. step]),FONT_TYPE.DEFAULT_FONT,23)
            tips:setPosition(0, -40)
            tips:setColor(cc.c3b(255,255,255))
            promotePanel:addChild(tips)
        end
        local function onEffectComplete()
            self._effectPlaying = false
            self:doTextEffect()
            if battleData.arenaIsWin and battleData.arenaIsPromote then
                showPromotePanel()
            end
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(onEffectComplete)))
    end
end

function ArenaBattleResultLayer:doTextEffect()
    local ret = cc.Label:createWithSystemFont(Localized.lang.hero_press_any_key_continue, FONT_TYPE.DEFAULT_FONT, 20)
    ret:setPosition(winSize.width/2, 30)
    self:addChild(ret)
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(0.5), cc.FadeIn:create(0.5)))
    ret:runAction(action)
end

return ArenaBattleResultLayer