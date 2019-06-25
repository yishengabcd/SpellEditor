
local BattleProxy = require("src/dal/battleproxy")
local Spell = require("src/scene/battle/mode/Spell")
local EventProtocol = require("src/utils/EventProtocol")
local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local PositionHelper = require("src/scene/battle/mode/PositionHelper")
local BuffMgr = require("src/scene/battle/manager/BuffMgr")


--处理技能释放的时机、顺序等逻辑
local SpellMgr = {}
EventProtocol.extend(SpellMgr)
--TODO ZDX 
SpellMgr.EVENT_HAVE_WITHSKILL = "EVENT_HAVE_WITHSKILL"--连协技面板弹出通知
local _battle
local _spells       --待执行技能列表
local _spellIndex = 0 --记录技能的索引，值递增
local _endFlag = false
local _speed = 1
local _executingSpells = {} --记录正在执行并且还不能启动下一个技能（有可能伤害还没有触发完）的列表
local _workingSpells = {}--记录正在工作状态的技能的列表（技能可能已经完成了伤害的处理，但是有可能还在工作中，比如角色往回跑等）
local _isFreeTime = true
function SpellMgr.setup(battle)
    if _battle then
        SpellMgr.dispose()
    end
    BuffMgr.setup(battle)

    _battle = battle
    _spells = {}

    BattleProxy:addEventListener(BattleProxy.EVENT_INVOKE_SKILL, SpellMgr.onInvokeSkill)
    BattleProxy:addEventListener(BattleProxy.EVENT_CAST_SKILL, SpellMgr.onCastSkillHandler)
end

--收到释放技能事件
function SpellMgr.onInvokeSkill(event) 
    SpellMgr.addSpell(event.data)
end

--使用技能的结果返回
function SpellMgr.onCastSkillHandler(event)
    local executor = _battle:getRole(_battle:getBattleData().myTeam, event.data.executorIndex)
    if executor then
        executor:prepare()
    end
end


--添加技能到等待列表中
function SpellMgr.addSpell(spellData)
    _spellIndex = _spellIndex + 1
    spellData.index = _spellIndex

    local spell = Spell.new(spellData)
    spell:setBattle(_battle)
    if spellData.isFightBack then --如果是反击，将其附加到上一个技能里
        local hostSpell
        for i=#_spells, 1, -1 do
            local spell = _spells[i]
            if spell:getSpellData().hasFightBack then
                hostSpell = spell
                break
            end
        end
        if not hostSpell then
            for i=#_executingSpells, 1, -1 do
                local spell = _executingSpells[i]
                if spell:getSpellData().hasFightBack then
                    hostSpell = spell
                    break
                end
            end
        end
        if hostSpell then
            hostSpell:attachFightBack(spell)
        end
    else
        if spellData.isJoin then
            spell:lockTargets()--锁定，不让其死亡，在该技能执行时解除锁定

            local prevSpell = _spells[#_spells]
            if not prevSpell then
                prevSpell = _executingSpells[#_executingSpells]
            end

            if prevSpell then
                prevSpell:setFollowSpell(spell)
            end
        end
        table.insert(_spells,spell)

        if #_executingSpells == 0 then
            SpellMgr.tryExecuteNextSpell()
        else
            local lastSpell = _executingSpells[#_executingSpells]
            if lastSpell:isJoinSpellTimePast() then
                SpellMgr.tryExecuteNextSpell()
            end
        end
        if spell:isConcurrent() and _spells[1] == spell then
            table.remove(_spells,1)
            SpellMgr.executeSpell(spell)
        end
    end
end

function SpellMgr.tryExecuteNextSpell()
    if #_spells > 0 then
        local spell = _spells[1]
        table.remove(_spells,1)
        SpellMgr.executeSpell(spell)
    else
        _isFreeTime = true
    end
end


function SpellMgr.executeSpell(spell)
    if _battle then
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        BattleMgr.setSpeed(nil,1)
        _isFreeTime = false

--        if not spell:getSpellData().isJoin then
            SpellMgr.ignoreOldSpellsTailActions(spell)
--        end

        _executingSpells[#_executingSpells + 1] = spell
        _workingSpells[#_workingSpells + 1]=spell

        spell:addEventListener(Spell.EVENT_HURT_DONE, SpellMgr.onOneSpellHurtDone)
        spell:addEventListener(Spell.EVENT_SPELL_COMPLETE, SpellMgr.onOneSpellComlete)
        _battle:executeSpell(spell)
        spell:refreshWaitFlag()
        BuffMgr.process()

        if not spell:isConcurrent() then
            spell:addEventListener(Spell.EVENT_HALF, SpellMgr.onOneSpellHalf)
            spell:addEventListener(Spell.EVENT_JOIN_SPELL, SpellMgr.onJoinSpellTime)
            spell:getExecutor():cancelPrepareState()
        end

        if (spell:getSpellData().isActive or spell:getSpellData():isWithSkill()) and not spell:getSpellData().isJoin and not spell:isConcurrent() then --主动技 
            --            _battle:getMap():setBlackScreen(255)--设置为黑屏
--            spell:hideUnrelatedRoles()--隐藏所有其他不相关角色
--            spell:hideBuffs()
--            if not spell:isStandSpell() then
--                local targets = spell:getAttackTargets()
--                local target = targets and targets[1]
--                local disX = -PositionHelper.JOIN_SPELL_DIS;
--                if spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT then
--                    disX = PositionHelper.JOIN_SPELL_DIS
--                end
--                if target then
--                    spell:getExecutor():setPosition(target:getPositionX() + disX, target:getPositionY())
--                end
--                spell:getExecutor():addPositionAfterimageAction()
--            end
        end
        if spell:getSpellData().isActive or spell:getSpellData():isWithSkill() or spell:getSpellData().isJoin then
--            SoundManager.setMusicVolume(0)
        end
    end
end

function SpellMgr.executeJoinSpell(prevSpell, nextSpell)
    local nextSpell = _spells[1]
    table.remove(_spells,1)
    prevSpell:showAllRoles()
    SpellMgr.removeExecutingSpell(prevSpell)
--    nextSpell:hideUnrelatedRoles()
--    nextSpell:hideBuffs()
    SpellMgr.executeSpell(nextSpell)
end

function SpellMgr.removeExecutingSpell(spell)
    spell:markCanIgnoreTailActions()
    for i, mem in ipairs(_executingSpells) do
        if mem == spell then
            table.remove(_executingSpells,i)
            break
        end
    end
end
function SpellMgr.removeWorkingSpell(spell)
    for i, mem in ipairs(_workingSpells) do
        if mem == spell then
            table.remove(_workingSpells,i)
            break
        end
    end
end

--忽略旧技能的尾部动作
function SpellMgr.ignoreOldSpellsTailActions(exception)
    for _, spell in ipairs(_workingSpells) do
        if spell ~= exception then
            spell:ignoreTailActions(exception)
        end
    end
end

--是否有跟着有连携技
function SpellMgr.hasJoinSpellAfter()
    if #_spells > 0 then
        local nextSpell = _spells[1]
        return nextSpell:getSpellData().isJoin
    end
    return false
end

--技能执行到一半时的处理函数
function SpellMgr.onOneSpellHalf(event)
    event.target:removeEventListener(Spell.EVENT_HALF, SpellMgr.onOneSpellHalf)
    SpellMgr:dispatchEvent({name=Spell.EVENT_HALF, spell=event.target})
end

function SpellMgr.onOneSpellHurtDone(event)
    local  spell = event.target
    local role = spell:getExecutor()
    local isConcurrent = spell:isConcurrent()

    event.target:removeEventListener(Spell.EVENT_HURT_DONE, SpellMgr.onOneSpellHurtDone)
    --TODO ZDX 每次技能伤害计算完发出一个连协面板显示事件（技能跟有连协调技能才发，否则不发）
    local withskilldata = spell:getSpellData().withSkill
    if getTableSize(withskilldata) >= 1 or spell:getFollowSpell() then 
        local withData = {}
        withData[1] = withskilldata 
        withData[2] = spell
        SpellMgr:dispatchEvent({name=SpellMgr.EVENT_HAVE_WITHSKILL,data=withData})    
    end

    if isConcurrent then
        SpellMgr.sendSpellComplete(spell)
        SpellMgr.removeExecutingSpell(spell)
    else
        if #_spells > 0 then
            local nextSpell = _spells[1]
            if not nextSpell:getSpellData().isJoin and not SpellMgr.isPlayingActiveOrJoinSpell(spell) and not spell:getJoinSpellSelecting() then 
                if not spell:getSpellData().isJoin and not spell:getSpellData().isActive and not spell:getSpellData().hasFightBack then--当是最后的一个连携技时，交由onOneSpellComlete处理
                    spell:setProcessed()
                    SpellMgr.sendSpellComplete(spell)
                    SpellMgr.removeExecutingSpell(spell)
                    SpellMgr.tryExecuteNextSpell()
                end
            end
        else
            if not SpellMgr.isPlayingActiveOrJoinSpell(spell) and not spell:getJoinSpellSelecting() then
                if not spell:getSpellData().isJoin and not spell:getSpellData().isActive and not spell:getSpellData().hasFightBack then--当是最后的一个连携技时，交由onOneSpellComlete处理
                    spell:setProcessed()
                    SpellMgr.sendSpellComplete(spell)
                    SpellMgr.removeExecutingSpell(spell)
                end
            end
        end
    end
    SpellMgr:dispatchEvent({name=Spell.EVENT_HURT_DONE})
    
    BuffMgr.process()
end

--当前技能执行完成
function SpellMgr.onOneSpellComlete(event)
    print("------onOneSpellComlete" .. event.target:getSpellData().spellId)
    local  spell = event.target
    local role = spell:getExecutor()
    local isConcurrent = spell:isConcurrent()

    if not isConcurrent then
        role:setSpellExecuting(false)
    end

    event.target:removeEventListener(Spell.EVENT_SPELL_COMPLETE, SpellMgr.onOneSpellComlete)
    spell:getExecutor():clearAfterimage()
    spell:getExecutor():stopGhostShadow()

    for _, mem in ipairs(_executingSpells) do
        mem:refreshWaitFlag()
    end

    SpellMgr.removeWorkingSpell(spell)


    if not isConcurrent then
        if #_spells > 0 then
            local nextSpell = _spells[1]
            if not nextSpell:getSpellData().isJoin and not spell:getProcessed() then 
                if  not SpellMgr.isPlayingActiveOrJoinSpell(spell)  then
                    spell:setProcessed()
                    print("1------EVENT_SPELL_COMPLETE" .. event.target:getSpellData().spellId)
                    SpellMgr.sendSpellComplete(spell)
                    SpellMgr.tryExecuteNextSpell()
                    _battle:resetMap()
                    _battle:resetRoles(spell:getExecutor())
                end
            end
        else
            if not SpellMgr.isPlayingActiveOrJoinSpell(spell) then
                if not spell:getProcessed() then
                    spell:setProcessed()
                    print("2------EVENT_SPELL_COMPLETE" .. event.target:getSpellData().spellId)
                    SpellMgr.sendSpellComplete(spell)
--                    SoundManager.setMusicVolume(1)
                end
                _battle:resetMap()
                _battle:resetRoles(spell:getExecutor())
            end
        end
        SpellMgr.removeExecutingSpell(spell)
        if spell:getFollowSpell() and not spell:getFollowSpell().finished then
--            spell:getExecutor():setVisible(false)
            spell:getExecutor():fadeOut()
        end
        SpellMgr:dispatchEvent({name=Spell.EVENT_SPELL_COMPLETE, data = spell})
    end
end

--是否正在播放主动技或连携技
function SpellMgr.isPlayingActiveOrJoinSpell(exceptant)
    if #_executingSpells == 0 then return false end
    for i, spell in ipairs(_executingSpells) do
        if spell ~= exceptant and (spell:getSpellData().isJoin or spell:getSpellData().isActive or spell:getSpellData():isWithSkill()) then
            return true
        end
    end
    return false
end
--连携技发动时间
function SpellMgr.onJoinSpellTime(event)
    event.target:removeEventListener(Spell.EVENT_JOIN_SPELL, SpellMgr.onJoinSpellTime)

    if #_spells > 0 then
        local nextSpell = _spells[1]
        local prevSpell = event.target
        if nextSpell:getSpellData().isJoin and prevSpell:getFollowSpell() then--如果下一个技能是连携技，不启动行动倒计时，直接执行下一个技能
            local action = BattleCustomActions.JoinSpellComeOut.new(prevSpell, nextSpell)
            action = BattleCustomActions.SequenceAction.new({action},SpellMgr.executeJoinSpell, prevSpell, nextSpell)
            _battle:executeCustomAction(action)
            _battle:getMap():resetCamera(0.2)
            SpellMgr.ignoreOldSpellsTailActions(nextSpell)
        end
    end
end
function SpellMgr.sendSpellComplete(spell)
    if not LD_EDITOR then
        local HitNumberPlayer = require("src/scene/battle/manager/HitNumberPlayer")
        HitNumberPlayer.reset()

        if #_spells == 0 or not _spells[1]:getSpellData().isJoin then
            BattleProxy:sendSpellComplete(spell:getSpellData().turn)
        end
    end
end

function SpellMgr.update(dt)
    if _battle then
        local roles = _battle:getRoles()

        
    end
end

--没有播技能
function SpellMgr.isFreeTime()
    return _isFreeTime
end

function SpellMgr.isAllComplete()
    if not _endFlag or #_workingSpells > 0 or #_spells > 0 then
        return false
    end
    return true
end

--设置为战斗结束标识
function SpellMgr.setEndFlag(value)
    _endFlag = value
end

--编辑器里需要用到
function SpellMgr.getExecutingSpells()
    return _executingSpells
end

function SpellMgr.dispose()
    BuffMgr.dispose();
    if _battle then
        BattleProxy:removeEventListener(BattleProxy.EVENT_INVOKE_SKILL, SpellMgr.onInvokeSkill)
        BattleProxy:removeEventListener(BattleProxy.EVENT_CAST_SKILL, SpellMgr.onCastSkillHandler)
        _battle = nil
    end
    _spells = nil
    if #_executingSpells > 0 then
        for i, spell in ipairs(_executingSpells) do
            spell:removeEventListener(Spell.EVENT_HURT_DONE, SpellMgr.onOneSpellHurtDone)
            spell:removeEventListener(Spell.EVENT_SPELL_COMPLETE, SpellMgr.onOneSpellComlete)
            spell:removeEventListener(Spell.EVENT_HALF, SpellMgr.onOneSpellHalf)
            spell:removeEventListener(Spell.EVENT_JOIN_SPELL, SpellMgr.onJoinSpellTime)
        end
    end
    _executingSpells = {}
    _workingSpells = {}
end
return SpellMgr