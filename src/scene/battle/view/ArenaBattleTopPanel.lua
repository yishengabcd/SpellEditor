local ItemSlot = require("src/ui/bag/itemslot")
local ArenaFightInfo = require("src/entities/arenafightinfo")

local ArenaBattleTopPanel = class("ArenaBattleTopPanel", function ()  
    return cc.Node:create()
end)

function ArenaBattleTopPanel:ctor(battleData)
    ------center
    local centerBack = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_bg_vs.png")
    centerBack:setPosition(0, -85)
    self:addChild(centerBack)
    
    local vs = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_icon_vs.png")
    vs:setPosition(0, -46)
    self:addChild(vs)
    
    ------left
    local panel = ArenaBattleTopPanel.createLeftPanel(battleData)
    self:addChild(panel)    
    ------right
    local panel = ArenaBattleTopPanel.createRightPanel(battleData)
    self:addChild(panel)  
end

function ArenaBattleTopPanel.createLeftPanel(battleData)
    local panel = cc.Node:create()
    panel:setAnchorPoint(1, 1)
    
    local nameBackL = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_bg_redTeam.png")
    nameBackL:setPosition(-200,-53)
    panel:addChild(nameBackL)

    local nameTxtL = cc.Label:createWithSystemFont(battleData.arenaRedNickname,FONT_TYPE.DEFAULT_FONT,18)
    nameTxtL:setColor(cc.c3b(255, 255, 255))
    nameTxtL:setPosition(nameBackL:getPositionX(), nameBackL:getPositionY() + 12)
    panel:addChild(nameTxtL)

    local levelBackL = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_bg_lv.png")
    levelBackL:setPosition(-280,-80)
    panel:addChild(levelBackL)

    local levelFlagL = cc.Sprite:createWithSpriteFrameName("ui/common/ui_city_icon_lv.png")
    levelFlagL:setPosition(levelBackL:getPositionX() - 17,levelBackL:getPositionY() + 8)
    panel:addChild(levelFlagL)

    local levelTxtL = cc.Label:createWithSystemFont(battleData.arenaRedLevel,FONT_TYPE.DEFAULT_FONT,18)
    levelTxtL:setColor(cc.c3b(255, 232, 188))
    levelTxtL:setPosition(levelFlagL:getPositionX() + 40, levelFlagL:getPositionY() - 3)
    panel:addChild(levelTxtL)

    local tpl = require("src/entities/templatemanager"):getMountInfo(battleData.arenaRedHeadId)
    local iconL = ItemSlot:createBagItem(nil, self)
    iconL:setIcon(tpl.icon)
    iconL:setPosition(-400,-90)
    panel:addChild(iconL)
    
    return panel
end

function ArenaBattleTopPanel.createRightPanel(battleData)
    local panel = cc.Node:create()
    panel:setAnchorPoint(0, 1)

    local nameBackR = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_bg_blueTeam.png")
    nameBackR:setPosition(200,-53)
    panel:addChild(nameBackR)

    local nickname = ArenaBattleTopPanel.transCharacterName(battleData.arenaBlueType, battleData.arenaBlueNickname)
    local nameTxtR = cc.Label:createWithSystemFont(nickname,FONT_TYPE.DEFAULT_FONT,18)
    nameTxtR:setColor(cc.c3b(255, 255, 255))
    nameTxtR:setPosition(nameBackR:getPositionX(), nameBackR:getPositionY() + 12)
    panel:addChild(nameTxtR)

    local levelBackR = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_arena_bg_lv.png")
    levelBackR:setPosition(280,-80)
    panel:addChild(levelBackR)

    local levelFlagR = cc.Sprite:createWithSpriteFrameName("ui/common/ui_city_icon_lv.png")
    levelFlagR:setPosition(levelBackR:getPositionX() - 20,levelBackR:getPositionY() + 8)
    panel:addChild(levelFlagR)

    local levelTxtR = cc.Label:createWithSystemFont(battleData.arenaBlueLevel,FONT_TYPE.DEFAULT_FONT,18)
    levelTxtR:setColor(cc.c3b(255, 232, 188))
    levelTxtR:setPosition(levelFlagR:getPositionX() + 40, levelFlagR:getPositionY() - 3)
    panel:addChild(levelTxtR)

    local tpl = require("src/entities/templatemanager"):getMountInfo(battleData.arenaBlueHeadId)
    local iconR = ItemSlot:createBagItem(nil, self)
    iconR:setIcon(tpl.icon)
    iconR:setPosition(322,-90)
    panel:addChild(iconR)

    return panel
end

function ArenaBattleTopPanel.transCharacterName(type, nickname)
    return require("src/dal/arena"):getRobotName(nickname, type)
end

return ArenaBattleTopPanel