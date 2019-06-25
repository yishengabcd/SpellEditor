local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local SpellBar = require("src/scene/battle/view/SpellBar")
local TopBar = require("src/scene/battle/view/TopBar")
local BattleData = require("src/scene/battle/data/BattleData")
local MapData = require("src/scene/battle/data/MapData")
local GlobalEventDispatcher = require("src/scene/battle/manager/GlobalEventDispatcher")
local JoinSpellBar2 = require("src/scene/battle/view/JoinSpellBar2")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local HitNumberPlayer = require("src/scene/battle/manager/HitNumberPlayer")
local MapDal = require("src/dal/map")
local CdBar = require("src/scene/battle/view/CdBar")
local SpellMgr = require("src/scene/battle/manager/SpellMgr")
local DramaMovieView = require("src/scene/battle/view/DramaMovieView")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local Timer = require("src/base/timer")
local ChatFloatPanel = require("src/ui/chat/chatfloatpanel")
local winSize = cc.Director:getInstance():getVisibleSize()

local BattleScene = class("BattleScene",function()
    return cc.Scene:create()
end)

--是否等待连携，新手用
BattleScene._waitForWith = nil
BattleScene._chatFloatPanel = nil

function BattleScene:ctor()
end

function BattleScene:showBattleView(delayMove)
    self._spellBarShowed = true
    self._joinSpellBarShowed = false
    self._dalid1 = nil
    local battleData = BattleMgr.getBattleData()
    BattleMgr.startBattle(battleData, delayMove)

    local battle = BattleMgr.getBattle()
    self._map = battle:getMap()
    self:addChild(self._map)
    self._battle = battle
    BattleMgr.setScene(self)

    HitNumberPlayer.setup(self)
    
    local function onSpellSelected(spellItem)
        local roleInfo = spellItem:getRoleInfo()
        local particle = cc.ParticleSystemQuad:create("particles/login03.plist")
        particle:setScale(1)
        particle:setBlendFunc(gl.ONE,gl.ONE)
        local pt1 = cc.p(spellItem:getPosition())
        pt1.y = pt1.y + 90
        particle:setPosition(pt1.x, pt1.y)
        self:addChild(particle)
        
        local joinItem = self._joinSpellBar:getNextJoinItem()
        local pt2 = joinItem:convertToWorldSpace(cc.p(0, 0))
        
        local control1
        local control2
        local randX = 300
        if pt1.x > pt2.x then
            control1 = cc.p(pt1.x + randX, pt1.y + 200)
            control2 = cc.p(pt2.x-randX/2, pt2.y - 200)
        else
            control1 = cc.p(pt1.x - randX, pt1.y + 200)
            control2 = cc.p(pt2.x+randX/2, pt2.y - 200)
        end
        local bezier ={
            control1,
            control2,
            pt2
        }

        local bezierTo = cc.BezierTo:create(0.5, bezier)

        local function onMoveEnd()
            self:removeChild(particle,true)
            self._joinSpellBar:showIconByRoleInfo(roleInfo)
        end
        particle:runAction(cc.Sequence:create(bezierTo, cc.CallFunc:create(onMoveEnd)))
    end

    local spellBar = SpellBar.new(onSpellSelected)
    self:addChild(spellBar)
    self._spellBar = spellBar


    --用于显示技能名称
    local spellNameLayer = cc.Layer:create()
    self:addChild(spellNameLayer)
    self.spellNameLayer = spellNameLayer

    local scale = winSize.width/960

    local topBar = TopBar.new()
    self:addChild(topBar)
    self._topBar = topBar

    if self._battle:getBattleData().type == GameType.GAME_STORY then --战役副本

        local collectView = cc.Node:create()
        collectView:setPosition(winSize.width - 150*scale,winSize.height - 30*scale)
        collectView:setScale(scale)
        self:addChild(collectView)
        self._collectView = collectView

        local spbg = ccui.Scale9Sprite:createWithSpriteFrameName("ui/battle/chest_base_map.png")
        spbg:setCapInsets(cc.rect(50,10,50,5))
        spbg:setContentSize(cc.size(150,40))
        spbg:setAnchorPoint(cc.p(0.2,0.5))
        collectView:addChild(spbg)
        local sp = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_box.png")
        collectView:addChild(sp)
        local spplus = cc.Sprite:createWithSpriteFrameName("ui/battle/combo_jiahao.png")
        spplus:setPositionX(sp:getPositionX()+sp:getContentSize().width/2 + spplus:getContentSize().width/2)
        collectView:addChild(spplus)
        local collectNumTxt = cc.LabelAtlas:_create("0","ui/common/battle_remove_hp_common.png",31,29,string.byte("0"))
        collectNumTxt:setPosition(spplus:getPositionX()+spplus:getContentSize().width/2,0)
        collectNumTxt:setAnchorPoint(cc.p(0,0.5))
        collectView:addChild(collectNumTxt)
        self._collectNumTxt = collectNumTxt
    end

    self._battleData = battle:getBattleData()

    local joinSpellBar = JoinSpellBar2.new()
    self:addChild(joinSpellBar)

    self._joinSpellBar = joinSpellBar
    --self._joinSpellBar:setVisible(false)
    
    local chatFloatPanel = ChatFloatPanel.new()
    chatFloatPanel:setPosition(20*scale, winSize.height - 60*scale)
    chatFloatPanel:setScale(scale)
    self:addChild(chatFloatPanel)
    self._chatFloatPanel = chatFloatPanel

    self.onFightStateChanged = function (event)
        self:setFightingState(self._battleData.fighting)
    end

    self.onCollectNumChanged = function (event)
        if self._collectNumTxt then
            local mapData = self._battleData.mapData
            self._collectNumTxt:setString(tostring(self._battleData.mapData.collectNum))
        end
    end

    self.onSpellStart = function (event)
        local spellData = event.data:getSpellData()
        local roleInfo = event.data:getExecutor():getInfo()

        if not spellData.isJoin then
            self:clearJoinIcons()
        end

        if spellData.castType ~= SkillCastType.SKILL_CAST_WITH then
            self:throttleJoinSpellBar(false,true)
            self:throttleSpellBar(true)
        end

        if roleInfo.side == RoleInfo.SIDE_LEFT then
            if spellData.nextCastType == SkillCastType.SKILL_CAST_WITH or spellData.isActive then
                self:throttleJoinSpellBar(true,false)
                self:throttleSpellBar(false)
            end
        end
    end

    self.onJoinSpellFlash = function (event)
        local spell = event.data

        local function delayShowEffect()
            local roleInfo = spell:getExecutor():getInfo()
            self._joinSpellBar:append(spell)
        end
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        local speedScale = BattleMgr.getGlobalSpeed()
        spell:getExecutor():runAction(cc.Sequence:create(cc.DelayTime:create(0.2/speedScale), cc.CallFunc:create(delayShowEffect)))
    end
    
    self._battleData:addEventListener(BattleData.EVENT_FIGHTING_STATE, self.onFightStateChanged)
    self._battleData.mapData:addEventListener(MapData.EVENT_COLLECT, self.onCollectNumChanged)
    GlobalEventDispatcher:addEventListener(GlobalEventDispatcher.EVENT_SPELL_START, self.onSpellStart)
    GlobalEventDispatcher:addEventListener(GlobalEventDispatcher.EVENT_JOIN_SPELL_FLASH, self.onJoinSpellFlash)
    self._id1 = SpellMgr:addEventListener(SpellMgr.EVENT_HAVE_WITHSKILL, handler(self,self.onShowJoinPanel)) 

    local function onNodeEvent(event)
        if "exit" == event then
            self._battleData:removeEventListener(BattleData.EVENT_FIGHTING_STATE, self.onFightStateChanged)
            self._battleData.mapData:removeEventListener(MapData.EVENT_COLLECT, self.onCollectNumChanged)
            GlobalEventDispatcher:removeEventListener(GlobalEventDispatcher.EVENT_SPELL_START, self.onSpellStart)
            GlobalEventDispatcher:removeEventListener(GlobalEventDispatcher.EVENT_JOIN_SPELL_FLASH, self.onJoinSpellFlash)
            if self._id1 then
                self._id1 = SpellMgr:removeEventListener(SpellMgr.EVENT_HAVE_WITHSKILL, self._id1)
                self._id1 = nil
            end
            HitNumberPlayer.dispose()
            local EffectPreloader = require("src/scene/battle/utils/EffectPreloader")
            EffectPreloader.clear()
        elseif "enter" == event then
        end
    end

    self:registerScriptHandler(onNodeEvent)

    self.onFightStateChanged()
    self.onCollectNumChanged()
    self:checkNovice()
end

--预加载完成后调用
function BattleScene:buildView()
    SceneManager:getInstance():cleanupResource();
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.BATTLE)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.ICON)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.COMMON)
    
    PositionHelper.initFormation(BattleMgr.getBattleData().formationLeft, BattleMgr.getBattleData().formationRight)
    
    local battleData = BattleMgr.getBattleData()
    local poltTemplate
    if battleData.mapData.isFirstEnter then
        local mapTpl = battleData.mapData:getTemplate()

        if mapTpl and mapTpl.plot_enter and mapTpl.plot_enter ~= 0 then
            poltTemplate = require("src/entities/templatemanager"):getPlot(mapTpl.plot_enter)
        end
    end
    
    if poltTemplate then
        local function onDramaMovieComplete()
            self:showBattleView(0.8)
            local function onSwitchMiddle()
                self._dramaMovieView:setVisible(false)
            end
            local function onSwitchEnd()
                self:removeChild(self._dramaMovieView,true)
                self._dramaMovieView = nil
            end
            self._dramaMovieView:switchOut(self, onSwitchMiddle, onSwitchEnd)
        end
        local function playDramaMovie()
            self._dramaMovieView:play()
        end
        local dramaMovieView = DramaMovieView.new(poltTemplate, onDramaMovieComplete,battleData.mapData)
        self:addChild(dramaMovieView, 9)
        self._dramaMovieView = dramaMovieView
        Timer.delayCall(1.5,playDramaMovie)
    else
        self:showBattleView()
    end
end

function BattleScene:playDramaMovieWhenExitMap(callback, plotTemplate)
    local function onDramaMovieComplete()
        callback()
    end
    
    local dramaMovieView = DramaMovieView.new(plotTemplate, onDramaMovieComplete,self._battleData.mapData)
    dramaMovieView:setVisible(false)
    self:addChild(dramaMovieView, 9)
    
    local function onSwitchMiddle()
        dramaMovieView:setVisible(true)
    end
    local function onSwitchEnd()
        dramaMovieView:play()
    end
    dramaMovieView:switchIn(self, onSwitchMiddle, onSwitchEnd)
end

--获得需要预加载的资源
function BattleScene:getPreloadList()
    local battleData = BattleMgr.getBattleData()
    local mapData = battleData.mapData
    local mapLoaderList = mapData:getPreloadList()
    local roleLoaderList = battleData:getPreloadList()
    for _, mem in ipairs(roleLoaderList) do
        table.insert(mapLoaderList,mem)
    end
    return mapLoaderList
end

function BattleScene:clearJoinIcons()
    if self._joinSpellBar then
        self._joinSpellBar:clearJoinIcons()
    end
end

function BattleScene:setFightingState(fighting)
    if not self._joinSpellBarShowed then
        self:throttleSpellBar(fighting)
    end
    if not fighting then
        self:throttleJoinSpellBar(false)
        self._spellBar:setFightingState(fighting)
    end
    self._battle:getMap():showOrHideCloseLayer(not fighting)
end

function BattleScene:throttleSpellBar(value)
    if self._spellBarShowed == value then return end
    self._spellBarShowed = value
    
    if self._spellBarThrottleAction then
        self:stopAction(self._spellBarThrottleAction)
        self._spellBarThrottleAction = nil
    end
    
    local action
    if value then
        action = cc.MoveTo:create(0.1,cc.p(self._spellBar:getPositionX(), 0))
    else
        action = cc.MoveTo:create(0.1,cc.p(self._spellBar:getPositionX(), -200))
    end
    local function complate()
        self._spellBarThrottleAction = nil
    end
    action = cc.Sequence:create(action,cc.CallFunc:create(complate))
    self._spellBarThrottleAction = action
    
    self._spellBar:runAction(action)
end

function BattleScene:throttleJoinSpellBar(value,clearFlag)
    if self._joinSpellBarShowed == value then 
        if clearFlag then
            self._joinSpellBar:clear()
        end
        return 
    end
    
    self._joinSpellBarShowed = value

    if clearFlag then
        self._joinSpellBar:clear()
    end
end

function BattleScene:getCollectBox()
    return self._collectView
end
--每个技能执行完伤害显示技能
function BattleScene:onShowJoinPanel(event)
    local data = event.data
        local guideFlag = self._waitForWith --新手指引
        --新手引导时先设置连携不可点，引导点时再设为可点
        if guideFlag then
--            self._spellBar:setEnabelTouch(false)
        end

    local spell = data[2]
    if  not BattleData.autoBattle and self._battle:getBattleData().type ~= GameType.GAME_TOURNAMENT then 
        self._spellBar:onSpellJoinTrigger(spell, data[1])
    end
    self._joinSpellBar:showJoinState(spell)
end

------------新手引导添加 begin--------------

--检查新手引导
function BattleScene:checkNovice()
    local NoviceDal = require("src/dal/novice")
    local MapMgr = require("src/scene/battle/manager/MapMgr")
    --新手战斗
    if NoviceDal:getForceNoviceStep() == NoviceForceType.NOVICE_FORCE_FIRST_FIGHT and MapMgr.getMapData().mapId == 200 then
        local novice = require("src/ui/novice/novicefirstfight").new(self)
        novice:show(self)
        self._waitForWith = true
        self._spellBar:setIsNovice()
        self._collectView:setVisible(false)
        self._chatFloatPanel:setVisible(false)
    end
end

function BattleScene:setSpellBarVisible(value)
    self._spellBar:setVisible(value)
end

function BattleScene:getSpellBar()
    return self._spellBar
end

------------新手引导添加 end--------------


return BattleScene
