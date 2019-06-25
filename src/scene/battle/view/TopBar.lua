local CharacterInfoDal = require("src/dal/character")
local Localized = require("src/localized")
local ArenaBattleTopPanel = require("src/scene/battle/view/ArenaBattleTopPanel")
local TopBar = class("BattleTopBar",function () 
    return cc.Node:create() 
end)

local winSize = cc.Director:getInstance():getVisibleSize()
local scheduler = cc.Director:getInstance():getScheduler()
local SIDE_LEFT = 1
local SIDE_RIGHT = 2
local DESIGN_WIDTH = 960

---------------------TopBar------------------------
function TopBar:ctor()
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    local MapData = require("src/scene/battle/data/MapData")
    self._battle = BattleMgr.getBattle()
    self._battleData = self._battle:getBattleData()
    
    local scale = winSize.width/DESIGN_WIDTH
    
    if self._battleData.type == GameType.GAME_TOURNAMENT then --竞技场
        local arenaPanel = ArenaBattleTopPanel.new(self._battleData)
        arenaPanel:setAnchorPoint(0.5, 1)
        arenaPanel:setPosition(winSize.width/2,winSize.height)
        arenaPanel:setScale(scale)
        self:addChild(arenaPanel)
    else --战役副本
        local wavePanel = cc.Node:create()
        wavePanel:setScale(scale)
        wavePanel:setPosition(winSize.width/2,winSize.height - 33 * scale)
        self:addChild(wavePanel)

        local middle = cc.Sprite:createWithSpriteFrameName("ui/battle/ui_battle_line.png")
        wavePanel:addChild(middle)

        local middlenum = cc.LabelAtlas:_create(self._battleData.mapData.currWave,"ui/common/battle_wave_num.png",25,35,49)
        middlenum:setPosition(middle:getPositionX()-38,middle:getPositionY()-15)
        wavePanel:addChild(middlenum)
        local middlenum2 = cc.LabelAtlas:_create(self._battleData.mapData.maxWave,"ui/common/battle_wave_num.png",25,35,49)
        middlenum2:setPosition(middle:getPositionX()+12,middle:getPositionY()-15)
        wavePanel:addChild(middlenum2)

        self._onWaveChanged = function (event)
            middlenum:setString(self._battleData.mapData.currWave)
        end

        self._battleData.mapData:addEventListener(MapData.EVENT_WAVE_CHANGE, self._onWaveChanged)
    end
    

    local function onNodeEvent(event)
        if "exit" == event then
            self._battleData.mapData:removeEventListener(MapData.EVENT_WAVE_CHANGE, self._onWaveChanged)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end
return TopBar