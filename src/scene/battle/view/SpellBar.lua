local CharacterDal = require("src/dal/character")
local BattleProxy = require("src/dal/battleproxy")
local EnterFrameMgr = require("src/scene/battle/manager/EnterFrameMgr")
local MapDal = require("src/dal/map")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local SpellMgr = require("src/scene/battle/manager/SpellMgr")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local BattleData = require("src/scene/battle/data/BattleData")
local Localized = require("src/localized")
local RichLabel = require("src/ui/richlabel")
local HeroDal = require("src/dal/hero")
local TipsLayer = require("src/ui/tiplayer")
local BlendFactor = require("src/scene/battle/mode/BlendFactor")
local BattleDal = require("src/dal/battle")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local Tweener = require("src/base/tweener")
local Button = require("src/ui/button")
local EventProtocol = require("src/utils/EventProtocol")
local ColorRenderer = require("src/ui/colorrenderer")
local BattleSettingPanel = require("src/scene/battle/view/BattleSettingPanel")
local SpellBar = class("BattleSpellBar", function () 
    return cc.Node:create() 
end)

SpellBar.EVENT_USE_WITHSKILL = "EVENT_USE_WITHSKILL"

local SPELL_ITEM_W
local scheduler = cc.Director:getInstance():getScheduler()

---------------------SpellItem------------------------

local SpellItem = class("BattleSpellItem", function () 
    return cc.Node:create() 
end)

function SpellItem:ctor()
    self._activity = false
    
    local back = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_bg_avatar.png")
    self:addChild(back, 0)
    self._back = back
    
    self:setContentSize(back:getContentSize())
    
    local hightLight = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_light_avatar.png")
    hightLight:setPosition(-25,25)
    self:addChild(hightLight, 0)
    
    local function onNodeEvent(event)
        if "exit" == event then
            if self._onDieHandler and self._info then
                self._info:removeEventListener(RoleInfo.EVENT_DIE, self._onDieHandler)
                self._onDieHandler = nil
            end 
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function SpellItem:setRoleInfo(info)
    self._info = info
    if info then
        local tpl = info:getTemplate()
        if tpl then
            local iconName = tpl.res_head .. "-2"
            local icon = cc.Sprite:createWithSpriteFrameName(ResourceManager:getInstance():getIconPath(iconName))
            icon:setAnchorPoint(0.5, 0)
            icon:setPositionY(-56)
            self:addChild(icon, 3)
            icon:setVisible(false)
            self._icon = icon
            self:setContentSize(icon:getContentSize())
            
            local iconDef = cc.Sprite:createWithSpriteFrameName(ResourceManager:getInstance():getIconPath( tpl.res_head .. "-1"))
            iconDef:setColor(cc.c3b(100,100,100))
            iconDef:setAnchorPoint(0.5, 0)
            iconDef:setPositionY(-36)
            self:addChild(iconDef, 3)
            self._iconDef = iconDef
            
            local stencil = cc.Sprite:createWithSpriteFrameName(ResourceManager:getInstance():getIconPath(iconName))
            stencil:setAnchorPoint(0.5, 0)

            local clipper = cc.ClippingNode:create()
            self:addChild(clipper, 3)
            
            clipper:setStencil(stencil);
            clipper:setAnchorPoint(0, 0)
            clipper:setAlphaThreshold(0.5)
            clipper:setContentSize(icon:getContentSize())
            clipper:setPosition(0,icon:getPositionY())
            clipper:setVisible(false)
            self._clipper = clipper
            
            local cover = cc.Sprite:create()
            cover:setAnchorPoint(0.5, 0)
            cover:setTextureRect(cc.rect(-icon:getContentSize().width/2, 0, icon:getContentSize().width, icon:getContentSize().height))
            cover:setColor(cc.c3b(0,0,0))
            cover:setOpacity(150)
            self._cover = cover
            
            clipper:addChild(cover)

            if info.isDead then
                self:setDead()
            else
                self._onDieHandler = function (event)
                    self:setDead()
                end

                info:addEventListener(RoleInfo.EVENT_DIE, self._onDieHandler)
            end
        end
    else
        local lock = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_icon_lock.png")
        self:addChild(lock, 1)
    end
end

function SpellItem:setDead()
    self._clipper:setVisible(false)
    self._icon:setVisible(false)
    self._iconDef:setVisible(true)
    if not self._deadIcon then
        local deadIcon = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_icon_herodeath.png")
        deadIcon:setPosition(0, 0)
        self:addChild(deadIcon, 3)
        self._deadIcon = deadIcon
    end
end

function SpellItem:setSelected(value)
    if self._icon then
        if value then
            ColorRenderer:changeToHl(self._icon)
        else
            ColorRenderer:changeToNormal(self._icon)
        end
    end
end

function SpellItem:setCoverScale(value)
    if self._cover and self._activity then
        self._cover:setScaleY(value)
    end
end

function SpellItem:setActivity(value)
    if self._activity == value then return end
    self._activity = value
    if not self._activity then
        self._cover:setScaleY(1)
        if self._activityEffect then
            self:removeChild(self._activityEffect,true)
            self._activityEffect = nil
        end
        self._iconDef:setVisible(true)
        self._icon:setVisible(false)
        self._clipper:setVisible(false)
    else
        self._cover:setScaleY(0)
        if not self._activityEffect then
            local eff = createEffect("effect/ef_ui/fight/skill_activate", 0.08,nil, nil, nil, nil, true)
            eff:setBlendFunc(gl.ONE, gl.ONE)
            self:addChild(eff, 1)
            self._activityEffect = eff
        end
        self._iconDef:setVisible(false)
        self._icon:setVisible(true)
        self._clipper:setVisible(true)
    end
end

function SpellItem:getActivity()
    return self._activity
end

function SpellItem:resetOnFightingStateChanged()

end

function SpellItem:getRoleInfo()
    return self._info
end

---------------------SpellBar------------------------
SpellBar._isNovice = nil
SpellBar._enabelTouch = nil

function SpellBar:ctor(onSpellSelected)
    self._enabelTouch = true
    self._onSpellSelected = onSpellSelected
    EventProtocol.extend(self)
    local battle = BattleMgr.getBattle()
    self._battle = battle
    local battleData = battle:getBattleData()

    local winSize = getWinSize()
    
    local scale = winSize.width/960

    local autoBtn = Button:createButton("ui/battle/ui_fight_btn.png", nil, nil, self.onMenuHandler, self, scale)
    autoBtn:setScale(scale)
    autoBtn:setAnchorPoint(0.5,0.5)
    autoBtn:setPositionX(winSize.width - 53 * scale)
    autoBtn:setPositionY(48*scale)
    autoBtn:setTitleText(Localized.lang.battle_auto_btn_title)
    autoBtn:setTitleFontSize(23)
    autoBtn:setFontColor(cc.c3b(255, 255, 255))
    self:addChild(autoBtn)
    autoBtn:enableStroke(cc.c3b(131, 83, 0), 2)
    autoBtn:setFontName(FONT_TYPE.DEFAULT_FONT_BOLD)
    self._autoBtn = autoBtn

    local pauseBtn = Button:createButton("ui/battle/ui_fight_btn.png",nil,nil,self.onMenuHandler,self)
    pauseBtn:setAnchorPoint(0.5,0.5)
    pauseBtn:setPosition(135*scale, autoBtn:getPositionY())
    local pauseBtnTitle = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_pause.png")
    pauseBtnTitle:setPosition(pauseBtn:getContentSize().width/2,pauseBtn:getContentSize().height/2)
    pauseBtn:addChild(pauseBtnTitle)
    self:addChild(pauseBtn)
    self._pauseBtn = pauseBtn
    
    local speedBtn = Button:createButton("ui/battle/ui_fight_btn.png",nil,nil,self.onMenuHandler,self)
    speedBtn:setAnchorPoint(0.5,0.5)
    speedBtn:setPosition(50*scale, autoBtn:getPositionY())
    self:addChild(speedBtn)
    local speedBtnTimeSign = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_x.png")
    speedBtnTimeSign:setPosition(18,speedBtn:getContentSize().height/2)
    speedBtn:addChild(speedBtnTimeSign)
    local speedsprite = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_no1.png")
    speedsprite:setPosition(40,speedBtnTimeSign:getPositionY())
    speedBtn:addChild(speedsprite)
    self._speedBtn = speedBtn

    
    if self._battle:getBattleData().type == GameType.GAME_TOURNAMENT then
        autoBtn:setVisible(false)
        speedBtn:setVisible(false)
    end


    self._battleSpeedUp = function(event)
        
        if BattleData.speedType == GameSpeedType.GAME_SPEED_DOUBLE then
            BattleMgr.setSpeed(2)
            speedsprite:setSpriteFrame("ui/battle/ui_fight_no2.png")
        else
            BattleMgr.setSpeed(1)
            speedsprite:setSpriteFrame("ui/battle/ui_fight_no1.png")
        end
    end
    self._battleSpeedUp(nil)

    self._battleAutoUp = function(event)
        if BattleData.autoBattle then 
            if not self._autoBattleEffect then
                local autoBattleEffect = createEffect("effect/ef_ui/fight/speed_up",0.15, nil, nil, nil, nil, true)
                autoBattleEffect:setScale(1.1)
                autoBattleEffect:setBlendFunc(gl.ONE, gl.ONE)
                autoBattleEffect:setPosition(self._autoBtn:getContentSize().width/2-1.5, self._autoBtn:getContentSize().height/2+2.5)
                self._autoBtn:addChild(autoBattleEffect)
                self._autoBattleEffect = autoBattleEffect
            end
        else 
            if self._autoBattleEffect then
                self._autoBtn:removeChild(self._autoBattleEffect)
                self._autoBattleEffect = nil
            end
        end
    end
    self._battleAutoUp(nil)
    
    local scale2 = winSize.width/1024
    local gap = 123*scale2
    self._items = {}
    
    local centerX = pauseBtn:getPositionX() + (autoBtn:getPositionX() - pauseBtn:getPositionX())/2
    for i=1, 5  do
        local item = SpellItem.new()
        item:setPosition(centerX + (i - 3)*gap,60*scale2)
        item:setScale(scale2)
        self:addChild(item)
        table.insert(self._items,item)
    end

    if battleData.formationLeft == PositionHelper.FORMATION_5_2_3 then
        self._items[1]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 0))
        self._items[2]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 1))
        self._items[3]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 3))
        self._items[4]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 4))
        self._items[5]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 5))
    else
        self._items[1]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 0))
        self._items[2]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 1))
        self._items[3]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 2))
        self._items[4]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 4))
        self._items[5]:setRoleInfo(battleData:getRoleInfoBySide(RoleInfo.SIDE_LEFT, 5))
    end
    
    local function onTouchBegan(touch, event)
        if not self._enabelTouch then return false end
        if self._selectSpellTweener then
            self._selectSpellTweener:kill()
            self._selectSpellTweener = nil 
            
            local location = touch:getLocation()
            local pt = self:convertToNodeSpace(location)
            for i, item in ipairs(self._items) do
                if item:getActivity() then
                    local rect = cc.rect(item:getPositionX()-item:getContentSize().width/2*scale2,item:getPositionY()-49*scale2,item:getContentSize().width*scale2,item:getContentSize().height*scale2)
                    if cc.rectContainsPoint(rect,pt) then
                        self._selectedItem = item
                        self._selectedItem:setSelected(true)
                        BattleProxy:sendUseSpell(item:getRoleInfo().position, item.skill_id)
                        self:deactivateItems()
                        self:dispatchEvent({name=SpellBar.EVENT_USE_WITHSKILL})
                        
                        local function onResumeBattle(dt)
                            BattleMgr.resume()
                        end
                        local function onEffectComplete()
                            if self._onSpellSelected then
                                self._onSpellSelected(item)
                            end
                            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(onResumeBattle)))
                        end
--                        local eff = createEffect("effect/ef_ui/fight/click", 0.06, true, nil,nil,nil,true);
--                        eff:setScale(2)
--                        eff:setPosition(-10, 5)
--                        eff:setBlendFunc(gl.ONE, gl.ONE)
--                        item:addChild(eff, 999)
--                        
--                        
--                        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(onEffectComplete)))
                        onEffectComplete()
                        
                        return true
                    end
                end
            end
            if self._spell then
                BattleMgr.resume()
                self:deactivateItems()
                self._spell:setJoinSpellSelecting(false)
                self._spell = nil
            end
        end
        return false
    end

    local function ontouchMoved(touch, event)

    end
    local function onTouchEnded(touch, event)
        if self._selectedItem then
            self._selectedItem:setSelected(false)
            self._selectedItem = nil
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(ontouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    BattleProxy:addEventListener(BattleProxy.EVENT_SPEED_UPDATA, self._battleSpeedUp)
    BattleProxy:addEventListener(BattleProxy.EVENT_AUTO_UPDATA, self._battleAutoUp)
    local function onExitHandler(event)
        if "exit" == event then
            if self._battleSpeedUp then
                BattleProxy:removeEventListener(BattleProxy.EVENT_SPEED_UPDATA, self._battleSpeedUp)
                BattleProxy:removeEventListener(BattleProxy.EVENT_AUTO_UPDATA, self._battleAutoUp)
                self._battleSpeedUp = nil
                self._battleAutoUp = nil
            end
        end
    end

    self:registerScriptHandler(onExitHandler)
end

function SpellBar:setFightingState(value) 
    if not value then
        for _, item in pairs(self._items) do
            item:resetOnFightingStateChanged()
        end
    end
end


function SpellBar:onMenuHandler(sender)
    if sender == self._autoBtn then
        if BattleData.autoBattle then
            BattleProxy:sendBattleAutoUpdata(false)
        else 
            BattleProxy:sendBattleAutoUpdata(true)
        end
    elseif sender == self._pauseBtn then
        local panel = BattleSettingPanel.new(self._battle)
        panel:show()
    elseif sender == self._speedBtn then
        if BattleData.speedType == GameSpeedType.GAME_SPEED_NORMAL then
            BattleProxy:sendBattleSpeedUpdata(GameSpeedType.GAME_SPEED_DOUBLE)
        elseif BattleData.speedType == GameSpeedType.GAME_SPEED_DOUBLE then
            BattleProxy:sendBattleSpeedUpdata(GameSpeedType.GAME_SPEED_NORMAL)
        end
    else
    end
end
function SpellBar:getItemByPosition(position)
    for i, item in ipairs(self._items) do
    	if item:getRoleInfo() and item:getRoleInfo().position == position then
    	   return item
    	end
    end
    return nil
end
function SpellBar:deactivateItems()
    for i, item in ipairs(self._items) do
        item:setActivity(false)
    end
end
function SpellBar:onSpellJoinTrigger(spell, joinData)
    if self._selectSpellTweener then
        self._selectSpellTweener:kill()
        self._selectSpellTweener = nil        
    end
    
    for i = 1,#joinData do  
        local item = self:getItemByPosition(joinData[i].hero_position)
        if item then
            item:setActivity(true)
            item.skill_id = joinData[i].skill_id
        end
    end
    
    self._spell = spell 
    spell:setJoinSpellSelecting(true)
    BattleMgr.pause()
    
    local function onSelectSpellCdProcess()
        for i, item in ipairs(self._items) do
            item:setCoverScale(self.selectSpellTime)
        end
    end
    local function onSelectSpellCdComplete()
        spell:setJoinSpellSelecting(false)
        BattleMgr.resume()
        self:deactivateItems()
        self._selectSpellTweener = nil
    end
    self.selectSpellTime = 0
    self._selectSpellTweener = Tweener.new(self, 1.5, "selectSpellTime", 1, onSelectSpellCdProcess, onSelectSpellCdComplete)
    if self._isNovice then
        self._selectSpellTweener:pause()
    end
end

function SpellBar:getItemByIndex(index)
    return self._items[index]
end

function SpellBar:setEnabelTouch(value)
    self._enabelTouch = value
end

function SpellBar:setIsNovice()
    self._isNovice = true
    self._autoBtn:setVisible(false)
    self._speedBtn:setVisible(false)
    self._pauseBtn:setVisible(false)
end

return SpellBar