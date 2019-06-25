
local Localized = require("src/localized")
local Spell = require("src/scene/battle/mode/Spell")
local Tweener = require("src/base/tweener")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local BattleData = require("src/scene/battle/data/BattleData")

local winSize = cc.Director:getInstance():getVisibleSize()

---------------------------JoinEffectBarItem-----------------------
local JoinEffectBarItem = class("JoinEffectBarItem", function ()
    return cc.Node:create()
end)

function JoinEffectBarItem:ctor(index)
    self._index = index
    if index < 5 then
        local line = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_line_avatar.png")
        line:setPosition(31,-2)
        self:addChild(line, 0)
    end
    
    local back = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_bg_avatar2.png")
    self:addChild(back, 0)
    
    local stencil = cc.DrawNode:create();
    stencil:drawSolidCircle(cc.p(0, 0),20,0,30, 1.0, 1.0, cc.c4f(0,0,0,0))

    local clipper = cc.ClippingNode:create()
    self:addChild(clipper,2)
    clipper:setStencil(stencil);
    self._clipper = clipper
end

function JoinEffectBarItem:setRoleInfo(roleInfo)
    self._roleInfo = roleInfo
    local function showIcon()
        local effect = createEffect("effect/ef_ui/fight/combo_activate", 0.14, nil, nil, nil, nil, true)
        effect:setBlendFunc(gl.ONE, gl.ONE)
        effect:setPosition(-1, 1)
        self:addChild(effect, 3)
        self._iconEffect = effect

        local iconPath = ResourceManager:getInstance():getIconPath(roleInfo:getTemplate().res_head)
        local icon = cc.Sprite:createWithSpriteFrameName(iconPath)
        icon:setScale(0.6)
        self._clipper:addChild(icon)
        self._icon = icon
    end

    if self._index == 1 then
        showIcon()
    else
        local delivery = createEffect("effect/ef_ui/fight/skill_line", 0.12, false, nil, nil, nil, true)
        delivery:setPosition(-31, -2)
        delivery:setBlendFunc(gl.ONE, gl.ONE)
        self._delivery = delivery
        self:addChild(delivery, 3)
        
        local bomb = createEffect("effect/ef_ui/fight/combo_effect", 0.12, true, nil, nil, nil, true)
        bomb:setPosition(0, 0)
        bomb:setBlendFunc(gl.ONE, gl.ONE)
        self:addChild(bomb, 3)

        local action = cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(showIcon))
        self:runAction(action)
    end
end
function JoinEffectBarItem:getRoleInfo()
    return self._roleInfo
end

function JoinEffectBarItem:clear()
    if self._iconEffect then
        self:removeChild(self._iconEffect,true)
        self._iconEffect = nil
    end
    if self._icon then
        self._clipper:removeChild(self._icon,true)
        self._icon = nil
    end
    if self._delivery then
        self:removeChild(self._delivery,true)
        self._delivery = nil
    end
end

---------------------------JoinEffectBar-----------------------
local itemGap = 68
local JoinEffectBar = class("JoinEffectBar", function ()
    return cc.Node:create()
end)

function JoinEffectBar:ctor()
    self._items = {}
    self._index = 1
    self:setContentSize(cc.size(itemGap*4,50))
    self:setAnchorPoint(0, 0.5)
    
    local damagesTitle = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_text_damage.png")
    damagesTitle:setPosition(itemGap*4 + 100,-4)
    self:addChild(damagesTitle)
    self._damagesTitle = damagesTitle
    self._damagesTitle:setVisible(false)
    
    local damagesValue = cc.LabelAtlas:_create("0","ui/common/ui_fight_no_damage.png",30,50,string.byte("0"))
    damagesValue:setPosition(damagesTitle:getPositionX()+damagesTitle:getContentSize().width/2,damagesTitle:getPositionY() + 5)
    damagesValue:setAnchorPoint(cc.p(0,0.5))
    self:addChild(damagesValue)
    self._damagesValue = damagesValue
    self._damagesValue:setVisible(false)
    
    self:initItems()
    self:setItemsVisible(false)
    
    local function onNodeEvent(event)
        if "exit" == event then
            self:clear()
            if self._tweener then
                self._tweener:kill()
                self._tweener = nil
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function JoinEffectBar:initItems()
    for i = 1, 5 do
        local item = JoinEffectBarItem.new(i)
        self:addChild(item)  
        table.insert(self._items,item) 
        item:setPositionX((i -1) * itemGap)
    end
end

function JoinEffectBar:setItemsVisible(value)
    for i, item in ipairs(self._items) do
        item:setVisible(value)
    end
end

function JoinEffectBar:append(spell, side)
    self._spell = spell
    if self._side ~= side or not spell:getSpellData().isJoin then
        self:clear()
        self._index = 1
        self._damageTotal = 0
        self.damageCount = 0
        self._damagesValue:setString("")
    end
    self._side = side
    
    local withskilldata = spell:getSpellData().withSkill
    if #withskilldata < 1 and self._index == 1 and (not spell:getFollowSpell()) then 
        return
    end
    
    self:setItemsVisible(true)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    
    if side == RoleInfo.SIDE_RIGHT or self._index == 1 or BattleData.autoBattle or BattleMgr.getBattleData().type == GameType.GAME_TOURNAMENT then
        local exist = nil
        if BattleData.autoBattle and self._index ~= 1 then
            local item = self._items[self._index - 1]
            if item:getRoleInfo() == spell:getExecutor():getInfo() then
                exist = true
            end
        end
        if not exist then
            local item = self._items[self._index]
            item:setRoleInfo(spell:getExecutor():getInfo())
            self._index = self._index + 1
        end
    end

    local function onDamageNumJump()
        self._damagesValue:setString(math.floor(self.damageCount))
    end
    
    local onDamage
    onDamage = function (event)
        self._damageTotal = self._damageTotal + event.damage
        if self._tweener then
            self._tweener:kill()
            self._tweener = nil
        end
        self._damagesTitle:setVisible(true)
        self._damagesValue:setVisible(true)
        self._tweener = Tweener.new(self, 0.2, "damageCount", self._damageTotal, onDamageNumJump, onDamageNumJump)
        if event.last then
            local effect = createEffect("effect/ef_ui/fight/damage", 0.1, true, nil, nil, nil, true)
            effect:setPosition(self._damagesValue:getPositionX() + self._damagesValue:getContentSize().width/2, self._damagesValue:getPositionY() - 20)
            self:addChild(effect)
        end
    end
    
    self._handler1 = spell:addEventListener(Spell.EVENT_DAMAGE, onDamage)
end
function JoinEffectBar:showIconByRoleInfo(roleInfo)
    local item = self._items[self._index]
    item:setRoleInfo(roleInfo)
    self._index = self._index + 1
end
function JoinEffectBar:getNextItem()
    return self._items[self._index]
end
function JoinEffectBar:clear()
    for i, item in ipairs(self._items) do
        item:clear()
    end
    self:setItemsVisible(false)
    self._damagesTitle:setVisible(false)
    self._damagesValue:setVisible(false)
    
    if self._spell and self._handler1 then
        self._spell:removeEventListener(Spell.EVENT_DAMAGE, self._handler1)
        self._spell = nil
        self._handler1 = nil
    end
end

---------------------------JoinStatePanel-----------------------
local JoinStatePanel = class("JoinStatePanel", function ()
    return cc.Node:create()
end)

function JoinStatePanel:ctor()
end

function JoinStatePanel:show(spell)
    self:clear()
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    local speedScale = BattleMgr.getGlobalSpeed()
    if speedScale == 0 then
        speedScale = 1
    end
    local state = spell:getSpellData():getSkillEffectTemplate().state_type
    local str 
    if state == 1 then
        str = Localized.lang.battle_join_spell_stateone
    elseif state == 2 then
        str = Localized.lang.battle_join_spell_statetwo
    elseif state == 3 then
        str = Localized.lang.battle_join_spell_statethree
    elseif state == 10 then
        str = Localized.lang.battle_join_spell_statefour
    elseif state == 11 then
        str = Localized.lang.battle_join_spell_statefive 
    end
    if str then
        local back = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_title_state.png")
        self:addChild(back, 0)
        self._back = back

        local function showStateName()
            local name = cc.Label:createWithSystemFont(str, FONT_TYPE.DEFAULT_FONT_BOLD, 18)
            name:setColor(cc.c3b(255,255,255))
            name:setPosition(back:getPositionX(), back:getPositionY())
            self:addChild(name, 0)
            self._name = name
            self._showNameEff = nil
            local function removeStateName()
                self:clear();
            end

            name:runAction(cc.Sequence:create(cc.DelayTime:create(2.6/speedScale), cc.CallFunc:create(removeStateName)))
        end

        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1/speedScale),cc.CallFunc:create(showStateName)))

        local showNameEff = createEffect("effect/ef_ui/fight/state",0.15/speedScale,true, nil, nil, nil, true)
        showNameEff:setBlendFunc(gl.ONE, gl.ONE)
        showNameEff:setPosition(back:getPositionX(), back:getPositionY() - 2)
        self:addChild(showNameEff, 1)
        self._showNameEff = showNameEff;
    end
end

function JoinStatePanel:clear()
    if self._back then
        self:removeChild(self._back,true)
        self._back = nil
    end
    if self._name then
        self:removeChild(self._name,true)
        self._name = nil
    end
    self:stopAllActions()
end


--连携技能效果展示栏（技能名称、图标等出现效果）
local JoinSpellBar2 = class("JoinSpellBar2", function () 
    return cc.Node:create() 
end)

---------------------------JoinSpellBar2-----------------------
local barSize = nil
function JoinSpellBar2:ctor()
    self:setAnchorPoint(0,0)
    
    local centerContainer = cc.Node:create()
    centerContainer:setAnchorPoint(cc.p(0, 0))
    self._centerContainer = centerContainer
    self:addChild(centerContainer)
    
    local joinEffectBar = JoinEffectBar.new()
    joinEffectBar:setPosition(winSize.width/2 - joinEffectBar:getContentSize().width/2, winSize.height - 74)
    self:addChild(joinEffectBar)
    self._joinEffectBar = joinEffectBar
    
    local joinStatePanel = JoinStatePanel.new()
    joinStatePanel:setPosition(winSize.width/2 ,joinEffectBar:getPositionY() -  80)
    self:addChild(joinStatePanel)
    self._joinStatePanel = joinStatePanel
    
    self._count = 0
end

function JoinSpellBar2:append(spell)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    local speedScale = BattleMgr.getGlobalSpeed()
    
    local spellData = spell:getSpellData()
    local roleInfo = spell:getExecutor():getInfo()
    self._count = self._count + 1
    
    self:clearCenter();
    self:clearTop();
    self:stopAllActions();
    
    local winSize = cc.Director:getInstance():getVisibleSize()
    
    local spellNameBack = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_fight_title_skill.png")
    spellNameBack:setAnchorPoint(cc.p(0.5,0.5))
    spellNameBack:setPosition(winSize.width/2,winSize.height - 42)
    self:addChild(spellNameBack, 0)
    self._spellNameBack = spellNameBack
    
    local function showSpellName()
        if self._spellNameBack then
            local name = cc.Label:createWithSystemFont(spellData:getTemplate()["name" .. Localized.type], FONT_TYPE.DEFAULT_FONT_BOLD, 28)
            name:setColor(cc.c3b(112,43,0))
            name:setPosition(spellNameBack:getPositionX(), spellNameBack:getPositionY() + 9)
            self:addChild(name, 0)
            self._name = name

            self._showNameEff = nil

            local function removeSpellName()
                self:clearTop();
            end

            name:runAction(cc.Sequence:create(cc.DelayTime:create(2.6/speedScale), cc.CallFunc:create(removeSpellName)))
        end
    end
    
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1/speedScale),cc.CallFunc:create(showSpellName)))
    
    local showNameEff = createEffect("effect/ef_ui/fight/skill_name",0.08/speedScale,true, nil, nil, nil, true)
    showNameEff:setScale(2)
    showNameEff:setBlendFunc(gl.ONE, gl.ONE)
    showNameEff:setPosition(spellNameBack:getPositionX(), spellNameBack:getPositionY() - 2)
    self:addChild(showNameEff, 1)
    self._showNameEff = showNameEff;
    
    self._joinEffectBar:append(spell, roleInfo.side)
    
end

function JoinSpellBar2:clearTop()
    if self._showNameEff then
        self:removeChild(self._showNameEff,true)
        self._showNameEff = nil
    end
    if self._spellNameBack then
        self:removeChild(self._spellNameBack,true)
        self._spellNameBack = nil
    end
    if self._name then
        self:removeChild(self._name,true)
        self._name = nil
    end
end

function JoinSpellBar2:clearCenter()
    self._centerContainer:removeAllChildren(true)
end
--显示技能造成的状态
function JoinSpellBar2:showJoinState(spell)
    self._joinStatePanel:show(spell)
end

function JoinSpellBar2:clear()
    self:clearCenter();
    self:clearTop()
    self:clearJoinIcons()
    self._joinStatePanel:clear()
    self._count = 0
end
function JoinSpellBar2:clearJoinIcons()
    self._joinEffectBar:clear()
end
function JoinSpellBar2:showIconByRoleInfo(roleInfo)
    self._joinEffectBar:showIconByRoleInfo(roleInfo)
end
function JoinSpellBar2:getNextJoinItem()
    return self._joinEffectBar:getNextItem()
end

return JoinSpellBar2