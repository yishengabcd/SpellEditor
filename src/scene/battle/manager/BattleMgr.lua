
--战斗对外接口类，提供战斗功能的相关接口
local BattleMgr = {}

local Battle = require("src/scene/battle/mode/Battle")
local Map = require("src/scene/battle/mode/Map")
local BattleData = require("src/scene/battle/data/BattleData")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local EnterFrameMgr = require("src/scene/battle/manager/EnterFrameMgr")
local TweenMgr = require("src/scene/battle/manager/TweenMgr")
local SpellData = require("src/scene/battle/data/SpellData")
local SpellModel = require("src/scene/battle/data/SpellModel")
local SpellMgr = require("src/scene/battle/manager/SpellMgr")
local Spell = require("src/scene/battle/mode/Spell")
local MapDal = require("src/dal/map")
local BattleSpeedMgr = require("src/scene/battle/manager/BattleSpeedMgr")
local BattleProxy = require("src/dal/battleproxy")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local BattleDal = require("src/dal/battle")
local TowerDal = require("src/dal/tower")
local EffectMgr = require("src/scene/battle/manager/EffectMgr")

if LD_EDITOR then
    BattleMgr.DEFAULT_SPEED = 1
else
    BattleMgr.DEFAULT_SPEED = 1.25
end

--剧情和战斗采用的是不同的播放速度
function BattleMgr.setDefaultSpeed(speed, isReset)
    if isReset then
        if BattleMgr.speedCache then
            BattleMgr.DEFAULT_SPEED = BattleMgr.speedCache
            BattleMgr.speedCache = nil
        end
    else
        if not BattleMgr.speedCache then
            BattleMgr.speedCache = BattleMgr.DEFAULT_SPEED
        end
        BattleMgr.DEFAULT_SPEED = speed
    end
    local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
    BattleCustomActions.setFrameRateBySpeed(BattleMgr.DEFAULT_SPEED)
    _speed = BattleSpeedMgr.getSpeed()*BattleMgr.DEFAULT_SPEED
end

local TipLoading
if not LD_EDITOR then
    TipLoading = require("src/ui/tiploading")
end

local scheduler = cc.Director:getInstance():getScheduler()
local _schedulerEntry
local _battleData;
local _onBattleStart;
local _battle
local _scene
local _speed = 1
local _pauseCount = 0
local _enterMapFlag

local tweenMgr

local _editing = false --是否处于编辑状态
local _inited --是否已经初始化
local _resultData --战斗结果数据
local _settlementData --战斗结算

function BattleMgr.init()
    if _inited then return end
    _inited = true
    
    SpellModel.load()
    
    local function onBattleInited(event)
        event.data.fighting = true
        if _battle and _enterMapFlag then
            BattleMgr.updateBattleData(event.data)
        else
            local function onSceneInited()
                if event.data.type == GameType.GAME_TOURNAMENT or event.data.arenaIsReplay  then
                    local schedulerEntry
                    
                    local function delayPlaySpell()
                        BattleProxy:readArenaFollowPackages()
                        scheduler:unscheduleScriptEntry(schedulerEntry)
                    end
                    schedulerEntry = scheduler:scheduleScriptFunc(delayPlaySpell,1,false)
                end
            end
            BattleMgr.battlePrepare(event.data, onSceneInited)
        end
    end
    function onBattleEnd(event)
        _resultData = event.data
        SpellMgr.setEndFlag(true)
        BattleMgr.onSpellComplete()
    end
    
    local function onBattleSettlement(event)
        _settlementData = event.data
    end
    
    BattleProxy:addEventListener(BattleProxy.EVENT_BATTLE_INITED, onBattleInited)
    BattleProxy:addEventListener(BattleProxy.EVENT_BATTLE_END, onBattleEnd)
    BattleProxy:addEventListener(BattleProxy.EVENT_GET_SETTLEMENT, onBattleSettlement)
    TowerDal:addEventListener(TowerDal.TOWER_SETTLEMENT, onBattleSettlement)
    
end

--更新战斗数据，如果当前在副本中行走时触发战斗，则利用新的战斗数据更新原来的副本中的角色数据
function BattleMgr.updateBattleData(data)
    _battle:getBattleData():copyFromRealBattleData(data)
    for _, role in pairs(_battle:getRoles()) do
        role:updateDatas()
    end
    SpellMgr.setEndFlag(false)
    BattleProxy:sendBattleReady()
end

function BattleMgr.battlePrepare(data, onBattleStart, enterMapFlag)
    _battleData = data
    _onBattleStart = onBattleStart
    _enterMapFlag = enterMapFlag
    SceneManager:getInstance():switchSceneByType(SceneType.BATTLE)
end

--开始一场战斗，切换到战斗场景
function BattleMgr.startBattle(data, delayMove)
    BattleMgr.setDefaultSpeed(nil, true)
    SpellMgr.setEndFlag(false)
    if not _enterMapFlag then
        local function onDelay()
            BattleProxy:sendBattleReady()
        end
        local Timer = require("src/base/timer")
        Timer.delayCall(1,onDelay)
    end
    
    local winSize = cc.Director:getInstance():getVisibleSize()
    local startX = data.mapData:getPlayerUnitX()
    
    if startX then
        startX = startX + PositionHelper.getLeftUnitBetweenCenter() - winSize.width/2
    else
        startX = 0
    end
    local rect = cc.rect(startX,0,winSize.width,winSize.height)
    local battle = Battle.new(data, rect)
    BattleMgr.setBattle(battle)
    
    local mapTemplate = data.mapData:getTemplate()
    if mapTemplate and mapTemplate.music and mapTemplate.music ~= "" then
        SoundManager.playMusic("music/b_music/" .. mapTemplate.music .. ".mp3")
    else
        SoundManager.stopMusic()
    end
    
    if not tweenMgr then
        tweenMgr = TweenMgr.new()
    end
    if _onBattleStart then
        _onBattleStart(delayMove)
        _onBattleStart = nil
    end
end

--每一个技能执行完成后会调用些方法
function BattleMgr.onSpellComplete(event)
    if _resultData then
        if SpellMgr.isAllComplete() then
            local isWin =  _resultData.winTeam == _battle:getBattleData().myTeam and true or false
        
            local BuffMgr = require("src/scene/battle/manager/BuffMgr")
            BuffMgr.process()
        
            _scene:clearJoinIcons()
            
            if _battleData.type == GameType.GAME_TOURNAMENT then
                local function onPlayWinComplete()
                    if _battleData.arenaIsReplay then
                        BattleDal:onBattleEndToWin()
                        BattleMgr.disposeCurrentBattle()
                        SceneManager:getInstance():switchSceneByType(SceneType.MAIN)
                    else
                        local ArenaBattleResultLayer = require("src/scene/battle/view/ArenaBattleResultLayer")
                        local resultLayer = ArenaBattleResultLayer.new()
                        resultLayer:show(_scene, _battleData)
                    end
                end
                local Timer = require("src/base/timer")
                Timer.delayCall(3,onPlayWinComplete)
                
                _battle:playVictory(_resultData.winTeam)
                _resultData = nil
            elseif _battleData.type == GameType.GAME_TOWER  then
                local function onPlayWinComplete()
                    local TowerResultLayer = require("src/scene/battle/view/settlement/TowerResultLayer")
                    local resultLayer = TowerResultLayer.new()
                    resultLayer:setData(isWin, _settlementData)
                    resultLayer:show(_scene)
                end
                local Timer = require("src/base/timer")
                Timer.delayCall(3,onPlayWinComplete)

                _battle:playVictory(_resultData.winTeam)
                _resultData = nil
            elseif _battleData.type == GameType.GAME_STORY 
                or _battleData.type == GameType.GAME_DEVILDOM_FEMALE
                or _battleData.type == GameType.GAME_DEVILDOM_MALE
                or _battleData.type == GameType.GAME_DEVILDOM_WITH then

                local MapMgr = require("src/scene/battle/manager/MapMgr")

                local position = require("src/scene/battle/mode/PositionHelper").getRightCenter()
                for _, dropInfo in ipairs(_resultData.drops) do
                    MapMgr.dropItem(dropInfo,position)
                end
                local hasNext;
                hasNext = _resultData.winTeam == _battle:getBattleData().myTeam and MapMgr.moveToNext()

                if hasNext then
                    _resultData = nil
                    SpellMgr.setEndFlag(false)
                else
                    _battle:playVictory(_resultData.winTeam)
                    
                    if isWin then
                        AudioEngine.playEffect(ResourceManager:getInstance():getUiSound("win"))
                    end

                    local schedulerEntry
                    
                    local function showResultWin()
                        _battle:getMap():collectAllDrops()

                        if _settlementData.win then
                            local BattleWinWindow = require("src/scene/battle/view/settlement/battlewinwindow")
                            BattleWinWindow:show(_settlementData, _battleData)
                        else
                            local BattleFailWindow = require("src/scene/battle/view/settlement/battlefailwindow")
                            BattleFailWindow:show(_settlementData)
                        end

                        if not LD_EDITOR then
                            MapDal:sendExitMap()
                        end
                    end
                    
                    local function delayForPlayVictory(dt)
                        scheduler:unscheduleScriptEntry(schedulerEntry)
                        
                        local poltTemplate
                        if isWin and not _battleData.mapData.isPasted then
                            local mapTpl = _battleData.mapData:getTemplate()
                            if mapTpl and mapTpl.plot_exit and mapTpl.plot_exit ~= 0 then
                                poltTemplate = require("src/entities/templatemanager"):getPlot(mapTpl.plot_exit)
                            end
                        end
                        if poltTemplate then
                            BattleMgr.stopSchedule()
                            _scene:playDramaMovieWhenExitMap(showResultWin, poltTemplate)
                         else
                            showResultWin()
                         end
                    end
                    _resultData = nil
                    --如果是新手引导战斗直接返回
                    local NoviceDal = require("src/dal/novice")
                    if _battle and _battle:getBattleData().mapData.mapId == 200 and NoviceDal:getForceNoviceStep() == NoviceForceType.NOVICE_FORCE_FIRST_FIGHT then
                        return
                    end
                    schedulerEntry = scheduler:scheduleScriptFunc(delayForPlayVictory,3,false)
                end
            elseif _battleData.type == GameType.GAME_RESOURCE then
                local function onPlayWinComplete()
                    BattleDal:onBattleEndToWin()
                    local ResourceBattleResultLayer = require("src/scene/battle/view/ResourceBattleResultLayer")
                    local resultLayer = ResourceBattleResultLayer.new()
                    local isWin = false
                    if _resultData.winTeam == 1 then
                        isWin = true
                    end
                    resultLayer:show(_scene, isWin, _battleData)
                    _resultData = nil
                end
                local Timer = require("src/base/timer")
                Timer.delayCall(2,onPlayWinComplete)
                _battle:playVictory(_resultData.winTeam)
            elseif _battleData.type == GameType.GAME_EXPEDITION then
                local function onPlayWinComplete()
                    local ResourceBattleResultLayer = require("src/scene/battle/view/ResourceBattleResultLayer")
                    local resultLayer = ResourceBattleResultLayer.new()
                    local isWin = false
                    if _resultData.winTeam == 1 then
                        isWin = true
                    end
                    resultLayer:show(_scene, isWin, _battleData)
                    _resultData = nil
                end
                local Timer = require("src/base/timer")
                Timer.delayCall(2,onPlayWinComplete)
                _battle:playVictory(_resultData.winTeam)
            end
        end
    end
end

function BattleMgr.setBattle(battle)
    _battle = battle
    if not tweenMgr then
        tweenMgr = TweenMgr.new()
    end
    SpellMgr.setup(_battle)
    SpellMgr:addEventListener(Spell.EVENT_SPELL_COMPLETE, BattleMgr.onSpellComplete)
    
    if _schedulerEntry then
        scheduler:unscheduleScriptEntry(_schedulerEntry)
    end
    _schedulerEntry = scheduler:scheduleScriptFunc(BattleMgr.onEnterFrame,1/60, false)
    BattleMgr.setSpeed(1,1,1)
end

function BattleMgr.onEnterFrame(dt)
    local dt = _speed * dt
    SpellMgr.update(dt)
    if tweenMgr then
        tweenMgr:step(dt)
    end
    EnterFrameMgr.onEnterFrame(dt)
end

--设置技能的播放速度
function BattleMgr.setSpeed(speedGlobal, speedInside, speedTemp)
    BattleSpeedMgr.setSpeed(speedGlobal, speedInside, speedTemp)
    _speed = BattleSpeedMgr.getSpeed()
end

function BattleMgr.resetSpeed()

end

function BattleMgr.getSpeed()
    return _speed
end

function BattleMgr.getGlobalSpeed()
    return BattleSpeedMgr.getGlobalSpeed()
end

function BattleMgr.pause()
    _pauseCount = _pauseCount + 1
    _speed = 0
    BattleSpeedMgr.pause()
end

function BattleMgr.resume()
    _pauseCount = _pauseCount - 1
    if _pauseCount > 0 then return false end
    _pauseCount = 0
    BattleSpeedMgr.resume()
    _speed = BattleSpeedMgr.getSpeed()*BattleMgr.DEFAULT_SPEED
    return true
end

function BattleMgr.stopSchedule()
    if _schedulerEntry then
        scheduler:unscheduleScriptEntry(_schedulerEntry)
        _schedulerEntry = nil
    end
end

function BattleMgr.disposeCurrentBattle()
    if not LD_EDITOR then
--        cc.SpriteFrameCache:destroyInstance()
        TipLoading:show(3.0,100.0)
    end
    EffectMgr.clear()
    BattleMgr.stopSchedule()
    SpellMgr:removeEventListener(Spell.EVENT_SPELL_COMPLETE, BattleMgr.onSpellComplete)
    tweenMgr:dispose()
    tweenMgr = nil
    SpellMgr.dispose()
    BattleSpeedMgr.clear()
    
    _pauseCount = 0
    BattleMgr.setSpeed(1,1,1)
    BattleSpeedMgr.resume()
    
    if _battle then
        _battle:dispose()
        _battle = nil
    end
end

function BattleMgr.executeCustomAction(action)
    _battle:executeCustomAction(action)
end
function BattleMgr.removeCustomAction(action)
    _battle:removeCustomAction(action)
end

function BattleMgr.executeSpell(spellData)
    SpellMgr.addSpell(spellData)
end

function BattleMgr.setScene(scene)
    _scene = scene
end

function BattleMgr.getScene()
    return _scene
end

function BattleMgr.getBattleData()
    return _battleData
end

function BattleMgr.getBattle()
    return _battle
end

function BattleMgr.getTweenMgr()
    if not tweenMgr then
        tweenMgr = TweenMgr.new()
    end
    return tweenMgr
end

--为编辑器加的方法
function BattleMgr.setEditing(value)
    _editing = value
end
--为编辑器加的方法
function BattleMgr.executeSpellForEditor(spellData)
    if _editing then
        _battle:executeSpellForEditor(spellData)
    end
end
--为编辑器加的方法
function BattleMgr.setFrameForEditor(frame)
    if _editing then
        _battle:setFrame(frame)
    end
end
--为编辑器加的方法
function BattleMgr.refresh()
    if _editing then
        _battle:refresh()
    end
end

return BattleMgr