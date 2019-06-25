
local SpellModel = require("src/scene/battle/data/SpellModel")
local FrameActionFactory = require("src/scene/battle/mode/FrameActionFactory")
local FrameState = require("src/scene/battle/mode/FrameState")
local EventProtocol = require("src/utils/EventProtocol")
local MotionType = require("src/scene/battle/mode/MotionType")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local BuffData = require("src/scene/battle/data/BuffData")
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local Role = require("src/scene/battle/mode/Role")
local GlobalEventDispatcher = require("src/scene/battle/manager/GlobalEventDispatcher")
local HitNumberPlayer = require("src/scene/battle/manager/HitNumberPlayer")
local BattleCustomActions = require("src/scene/battle/mode/BattleCustomActions")
local EffectPreloader = require("src/scene/battle/utils/EffectPreloader")

require("src/gameutils")

--Spell也是一个CustomAction
local Spell = class("Spell")

--起手技开始
Spell.EVENT_SPELL_JOIN_START = "eventSpellJoinStart"
Spell.EVENT_SPELL_COMPLETE = "eventSpellComplete"
Spell.EVENT_HURT_DONE = "eventHurtDone" --所有伤害执行完毕
Spell.EVENT_HALF = "eventHalf" --执行到一半时触发
Spell.EVENT_JOIN_SPELL = "eventJoinSpell" --连携技发动时机事件
Spell.EVENT_DAMAGE = "eventDamage" --造成伤害时触发

Spell.EMPTY_SPELL_ID = 0--空技能ID

local winSize = cc.Director:getInstance():getVisibleSize()

function Spell:ctor(spellData)
    EventProtocol.extend(self)

    self.type = "Spell"
    self.finished = false

    self._spellData = spellData
    if Spell.EMPTY_SPELL_ID ~= spellData.spellId then
        self._template = SpellModel.getSpellDataById(spellData.performId)
        if not self._template then
            if not LD_EDITOR then
                local TipText = require("src/ui/tiptext")
                local str = "找不到技能表现, 表现id=" .. spellData.performId .. ", 技能id=" .. spellData.spellId
                TipText:show(str)
                print(str)
            end
        else
            EffectPreloader.preloadSpell(self._template)
        end
    end
    self._frameActions = {}
    self._tempRoles = {}

    self._currentFrame = 0
    if Spell.EMPTY_SPELL_ID == spellData.spellId or not self._template then
        self._maxFrame = 10 --空技能定为10帧长度
    else
        self._maxFrame = self._template:getMaxFrameLength()
        self._hurtSegmentNum = self._template:getHurtSegmentNum()
        self._framesDictionary = {}
        local layers = self._template:getLayers()
        for i, layer in ipairs(layers) do
            local frames = layer:getFrames()
            for j, frame in ipairs(frames) do
                if frame.type == FrameState.WEIGHT_KEY_FRAME then
                    local list = self._framesDictionary[frame.index] or {}
                    self._framesDictionary[frame.index] = list
                    table.insert(list,frame)
                end
            end
        end
    end
    self._halfFrame = math.floor(self._maxFrame/2)
    self._currentSegment = 0 --技能生效处于第几段（主要应用于分段掉血）
    self._elapsed = 0

    self._beFightBackFrame = -1
    self._joinSpellComeOutFrameIndex = self._maxFrame --后继连携技出来的时机
    self._hurtDoneFrameIndex = self._maxFrame --所有伤害执行完毕

    if spellData.hasFightBack then
        self._beFightBackComplete = false
        local moveBackFrame
        if self._template then
            moveBackFrame = self._template:getLastKeyFrameByType(FrameActionType.MOVE_BACK)
        end
        if moveBackFrame then
            self._beFightBackFrame = moveBackFrame.index - 1
        else
            self._beFightBackFrame = self._maxFrame - 1
        end
    end
end

function Spell:setBattle(battle)
    self._battle = battle
    if self._template then
        local lastHurtFrame = self._template:getLastKeyFrameByType(FrameActionType.HURT)
        if lastHurtFrame then
            local addition = lastHurtFrame.__layerData:getKeyFrameLength(lastHurtFrame)
            addition = addition < 3 and addition or 3
            self._hurtDoneFrameIndex = lastHurtFrame.index + 2 --+ addition
        end

        self._isStandSpell = self._template:isStandSpell()
        local hurt = self._template:getFirstKeyFrameByType(FrameActionType.HURT)
        if hurt then
            self._firstHurtFrameIndex = hurt.index
        end
        if not self._isStandSpell then 
            local targets = self:getAttackTargets()
            local target = targets[1]
            self._targetPosition = cc.p(target:getPosition())

            if self._joinSpellComeOutFrameIndex == self._maxFrame then
                local comeOutFrame = lastHurtFrame
                if not comeOutFrame then
                    comeOutFrame = self._template:getLastKeyFrameByType(FrameActionType.MOVE_BACK)
                    if not comeOutFrame then
                        comeOutFrame = self._template:getLastKeyFrameByType(FrameActionType.JUMP_BACK)
                    end
                end
                if comeOutFrame then
                    self._joinSpellComeOutFrameIndex = comeOutFrame.index
                end
                if self._joinSpellComeOutFrameIndex < self._hurtDoneFrameIndex + 1 then
                    self._joinSpellComeOutFrameIndex = self._hurtDoneFrameIndex + 1
                end
            end
        end

        if self._spellData:getDamageSegment() ~= self._hurtSegmentNum then
            if not LD_EDITOR then
                local msg = "技能掉血段数：" .. self._hurtSegmentNum .. "  实际掉血段数：" .. self._spellData:getDamageSegment() .. " 技能id：" .. self._spellData.spellId
                print(msg)
                local TipText = require("src/ui/tiptext")
                TipText:show(msg)
            end
        end
    end
end

function Spell:execute(dt)
    self:refreshWaitFlag()
    if self._waitFlag then return end
    if self._beFightBackFrame == self._currentFrame and not self._beFightBackComplete then --等待反击执行完成后再继续
        return
    end
    if self._paused then
        return
    end
    
    if not LD_EDITOR and self:playAutoSpellStartEffect() then
        return
    end
    self._elapsed = self._elapsed + dt
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    local reach = math.floor(self._elapsed/0.0333*BattleMgr.DEFAULT_SPEED)
    while self._currentFrame < reach and not self.finished do
        self:runFrame()
        if self._beFightBackFrame == self._currentFrame then
            if self._fightBackSpell then
                self:startFightBack(self._fightBackSpell)
            end
            break
        end
    end
    if not self._joinSpellFlashed and self._spellData.isJoin then
        self:checkJoinSpellFlash()
    end
end
function Spell:runFrame()
    if self.finished then
        return
    end
    if self._currentFrame == 0 then
        if (self._spellData.isActive or self._spellData:isWithSkill()) or self._spellData.isJoin then --主动技 
            self:hideUnrelatedRoles()--隐藏所有其他不相关角色
            self:hideBuffs()
        end
        GlobalEventDispatcher:dispatchEvent({name=GlobalEventDispatcher.EVENT_SPELL_START, data=self})
        if not self._locked then
            self._locked = true
            self:lockTargets()
        end
        self:lockForSpecialAction()
        if self._spellData.isJoin then --解除连携技启动前的锁定
            self:unlockTargets()
        end
        if self._spellData.isActive and not self._spellData.isJoin then
            self:getExecutor():changeMp(0)
        end
        if not self._spellData.isFightBack then
            self:resetTargetsPosition()
        end
        self:getExecutor():setBarVisible(false)
        self:getExecutor():setVisible(true)
        self:getExecutor():fadeIn()
        self:getExecutor():setSpellExecuting(true)
        --        self:getExecutor():setNeedHideFlag(false)
        if self._spellData.isActive or (not LD_EDITOR and not self._spellData.isJoin and (self._spellData:getTemplate() and (self._spellData:getTemplate().release_type == 3 or  self._spellData:getTemplate().release_type == 4)))then
            GlobalEventDispatcher:dispatchEvent({name=GlobalEventDispatcher.EVENT_JOIN_SPELL_FLASH, data=self})
        end
        if not self._spellData.isJoin then
            HitNumberPlayer.reset()
        end
    end

    self._currentFrame = self._currentFrame + 1

    if self._currentFrame > self._hurtDoneFrameIndex then
        if not self._hurtDoneEventSended then
            self._hurtDoneEventSended = true
            self:processBuff()
            self:dispatchEvent({name=Spell.EVENT_HURT_DONE})
            if self._currentFrame > self._maxFrame then
                return
            end
        end
    end

    if self._currentFrame > self._joinSpellComeOutFrameIndex or (self._executorRoleInfo and self._executorRoleInfo.isDead) then
        --        if self._isStandSpell and not self._JoinSpellEventSended then
        if not self._JoinSpellEventSended then
            self._JoinSpellEventSended = true
            self:dispatchEvent({name=Spell.EVENT_JOIN_SPELL})
            self._isJoinSpellTimePast = true
            if self._currentFrame > self._maxFrame then
                return
            end
        end
    end

    if self._currentFrame > self._maxFrame or (self._executorRoleInfo and self._executorRoleInfo.isDead) then
        self.finished = true
        if self._locked then
            self._locked = nil
            self:unlockTargets()
        end
        self:getExecutor():setBarVisible(true)
        --        if self:getExecutor():getNeedHideFlag() then
        --            self:getExecutor():setNeedHideFlag(false)
        --            self:getExecutor():setVisible(false)
        --        end
        self:dispatchEvent({name=Spell.EVENT_SPELL_COMPLETE})
        return
    elseif self._currentFrame == self._halfFrame then
        self:dispatchEvent({name=Spell.EVENT_HALF})
    end
    if self._template then
        local frames = self._framesDictionary[self._currentFrame]
        if frames then
            for i, frame in ipairs(frames) do
                local action = FrameActionFactory.create(self, frame)
                if action then
                    if self._spellData.isFightBack then
                        if frame.action.type == FrameActionType.MOVE_FORWARD 
                            or frame.action.type == FrameActionType.MOVE_BACK
                            or frame.action.type == FrameActionType.JUMP
                            or frame.action.type == FrameActionType.JUMP_BACK then
                        else
                            action:run()
                            table.insert(self._frameActions, action)
                        end
                    else
                        table.insert(self._frameActions, action)
                        action:run(self._followSpell)
                    end
                end
            end
        end
    end
end

function Spell:checkJoinSpellFlash()
--    if self._isStandSpell and self._firstHurtFrameIndex then
    if self._firstHurtFrameIndex then
        local index = self._firstHurtFrameIndex - 5
        if index < 2 then index = 2 end
        if self._currentFrame > index then
            self._joinSpellFlashed = true
            GlobalEventDispatcher:dispatchEvent({name=GlobalEventDispatcher.EVENT_JOIN_SPELL_FLASH, data=self})
        end
        return 
    end
    do return end
    
    local role = self:getExecutor()
    local executorSide = role:getInfo().side
    local pt = role:convertToWorldSpace(cc.p(0,0))
    local pauseLine = winSize.width/10
    if LD_EDITOR then
        pauseLine = (winSize.width - 960)/2+960/10
    end

    if executorSide == RoleInfo.SIDE_RIGHT then
        pauseLine = winSize.width - pauseLine
    end
--    if (executorSide == RoleInfo.SIDE_LEFT and pt.x > pauseLine) or (executorSide == RoleInfo.SIDE_RIGHT and pt.x < pauseLine) then
        self._joinSpellFlashed = true
--        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
--        BattleMgr.pause()
--        self._paused = true
--
--        local function onCallback()
--            BattleMgr.resume()
--            self._paused = false
--        end
--
--        local eff = SimpleEffect.new("effect/ef_ui/lianxieshanguang", false, 0.5, gl.ONE, gl.ONE, nil, nil, true)
--        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
--        local speedScale = BattleMgr.getGlobalSpeed()
--        self._battle:getMap():runAction(cc.Sequence:create(cc.DelayTime:create(0.8/speedScale), cc.CallFunc:create(onCallback)))
--
--        local pt
--        if executorSide == RoleInfo.SIDE_RIGHT then
--            eff:setScaleY(2)
--            eff:setScaleX(-2)
--            pt = role:getHeadPosition()
--            pt = cc.p(-pt.x, pt.y)
--            pt = cc.pAdd(pt, cc.p(-60,-40))
--        else
--            eff:setScale(2)
--            pt = role:getHeadPosition()
--            pt = cc.pAdd(pt, cc.p(60,-40))
--        end
--
--        role:addEffect(eff, pt, -1)

        GlobalEventDispatcher:dispatchEvent({name=GlobalEventDispatcher.EVENT_JOIN_SPELL_FLASH, data=self})
--    end
end

--当要攻击的对像正处于释放技能状态时，要设置技能为等待状态
function Spell:refreshWaitFlag()
    if self._waitInvalid then return end
    local wait
    if self:getExecutor().lockCount > 0 or self:getExecutor():getSpellExecuting() then
        wait = true
    end
    if not wait then
        local targets = self:getAttackTargets()
        for i, target in ipairs(targets) do
            if target:getSpellExecuting() then
                wait = true;
                break;
            end
        end
    end

    self._waitFlag = wait

    if not wait then
        self._waitInvalid = true
    end
end

--播放自动技能特效
function Spell:playAutoSpellStartEffect()
    if self._autoSpellEffPlaying then
        return true
    elseif self._autoSpellEffPlayed then
        return false
    end
    if not self._template then
        return false
    end

    if self._spellData:getTemplate().release_type == 3 then
    
        local BattleMgr = require("src/scene/battle/manager/BattleMgr")
        local function onCallback()
            self._autoSpellEffPlaying = nil
            local black = BattleCustomActions.BlackScreenAction.new(self:getBattle():getMap(),200, 0, 5, cc.c3b(0,0,0))
            BattleMgr.executeCustomAction(black)
        end

        local role = self:getExecutor()
        local eff = SimpleEffect.new("effect/ef_tongyong/fadong4", false, 0.8, gl.ONE, gl.ONE, nil, onCallback)
        local black = BattleCustomActions.BlackScreenAction.new(self:getBattle():getMap(),0, 200, 5, cc.c3b(0,0,0))
        BattleMgr.executeCustomAction(black)

        if role:getInfo().side == RoleInfo.SIDE_RIGHT then
            eff:setScaleY(2)
            eff:setScaleX(-2)
        else
            eff:setScale(2)
        end
        --引导时要用tag，先隐藏特效
        eff:setTag(101)
        local pt = cc.pAdd(role:getCenterPosition(), cc.p(-5,-28))
        role:addEffect(eff, pt)
        self._autoSpellEffPlaying = true
        self._autoSpellEffPlayed = true

        AudioEngine.playEffect(ResourceManager:getInstance():getBattleEffectSound("jinengfadong"))
        return true
    end
    return false
end

function Spell:canReplace(action) 
    return false
end

function Spell:giveup()
    if self._locked then
        self._locked = nil
        self:unlockTargets()
    end
end

--使技能生效（针对掉血）
function Spell:takeEffect(count, motion, motionLoop,startFrame,bloodX, bloodY)
    local count = count or 1
    local damageCount = 0
    for i = 1, count do
        self._currentSegment = self._currentSegment + 1
        local damages = self._spellData:getDamageData(self._currentSegment)
        if damages then
            HitNumberPlayer.increase(count,self)
            for j, damage in ipairs(damages) do
                local role = self._battle:getRole(damage.targetTeam,damage.targetPosition)
                if role then
                    role:removeHp(damage.realHp, damage.hp, damage.damageType, bloodX, bloodY)
                    damageCount = damageCount + damage.hp
                    print("removeHp:spellId" .. self._spellData.spellId .. " realHp=" .. damage.realHp .. " displayHp=" .. damage.hp .. " roleSide=" .. role:getInfo().side .. " rolePos=" .. role:getInfo().position .. " leftHp=" .. role:getInfo().hp)
                    if motion and damage.hp > 0 then
                        if motionLoop and motionLoop == 0 then
                            role:executeMotion(motion,nil,motionLoop,nil,startFrame)
                        else
                            role:executeMotion(motion,nil,nil,MotionType.PREPARE,startFrame)
                        end
                    end
                end
            end
        end
        local damage = self._spellData.sucks[self._currentSegment]
        if damage then
            local role = self._battle:getRole(damage.targetTeam,damage.targetPosition)
            if role then
                role:removeHp(damage.realHp, damage.hp, damage.damageType)
                print("--吸血removeHp:spellId" .. self._spellData.spellId .. " realHp=" .. damage.realHp .. " displayHp=" .. damage.hp .. " roleSide=" .. role:getInfo().side .. " rolePos=" .. role:getInfo().position .. " leftHp=" .. role:getInfo().hp)
            end
        end
        if self._currentSegment == 1 then --第1次生效时，处理附加的效果
            self:takeEffectAdditional()
        end
    end
    self:dispatchDamageEffect(damageCount)
    if self._template then
        if self._hurtSegmentNum <= self._currentSegment then--说明掉血时机已经全部用完了
            if self._locked then
                self._locked = nil
                self:unlockTargets(true)
            end
        end
    end
end

function Spell:markCanIgnoreTailActions()
    self._canIgnoreTailActions = true
end
--忽略部分尾部动作。当下一个技能已经启动时，旧技能的某些动作会影响到新的技能（如镜头动作）
function Spell:ignoreTailActions(nextSpell)
    --    if self._canIgnoreTailActions then
    if nextSpell:hasCameraAction() then
        self.tailActionsIgnored_camera = true
    end
    if nextSpell:hasSpeedAction() then
        self.tailActionsIgnored_speed = true
    end
    --    end
end

--该技能是否有摄像头操作
function Spell:hasCameraAction()
    if self._template then
        local action = self._template:getLastKeyFrameByType(FrameActionType.ZOOM_MAP)
        action = action or self._template:getLastKeyFrameByType(FrameActionType.MOVE_MAP)
        action = action or self._template:getLastKeyFrameByType(FrameActionType.FOCUS)
        if action then
            return true
        end
    end
    return false
end
--该技能是否有速度调节操作
function Spell:hasSpeedAction()
    if self._template then
        local action = self._template:getLastKeyFrameByType(FrameActionType.SPEED_ADJUST)
        if action then
            return true
        end
    end
    return false
end

--附加反击技能
function Spell:attachFightBack(spell)
    self._fightBackSpell = spell
    local onSpellComlete
    onSpellComlete = function (event)
        self._beFightBackComplete = true
        spell:removeEventListener(Spell.EVENT_SPELL_COMPLETE, onSpellComlete)
    end
    spell:addEventListener(Spell.EVENT_SPELL_COMPLETE, onSpellComlete)
    if self._beFightBackFrame == self._currentFrame then
        self:startFightBack(spell)
    end
end

--设置后面跟着的连携技
function Spell:setFollowSpell(spell)
    self._followSpell = spell
    spell:setPreviousSpell(self)
    
    if not self._template then return end
    
    if spell._firstRiseFrameIndex and spell:getTemplate().targetInitHeight and spell:getTemplate().targetInitHeight > 0 then
        local fall = self._template:getLastKeyFrameByType(FrameActionType.FALL)
        if fall then
            self._lastFallFrameIndex = fall.index
            self._joinSpellComeOutFrameIndex = self._lastFallFrameIndex - spell._firstRiseFrameIndex + fall.__layerData:getKeyFrameLength(fall) - 1 
        end
    else
        local flyOff = self._template:getLastKeyFrameByType(FrameActionType.FLY_OFF)
        if flyOff then
            local hitBackFrame = spell:getTemplate().hitBackFrame or 0
            local duration = flyOff.action.phase1Duration + flyOff.action.phase2Duration + flyOff.action.phase3Duration
            local BattleMgr = require("src/scene/battle/manager/BattleMgr")
            self._joinSpellComeOutFrameIndex = flyOff.index + math.floor(duration/0.0333*BattleMgr.DEFAULT_SPEED) - hitBackFrame
        else
            local getUpFrame = self._template.getUpFrame
            if getUpFrame and getUpFrame > 0 then
                local lieDownJoin = spell:getTemplate().lieDownJoin or 0
                self._joinSpellComeOutFrameIndex = getUpFrame - lieDownJoin
            end
        end
    end
    
    if self._joinSpellComeOutFrameIndex > self._maxFrame then
        self._joinSpellComeOutFrameIndex = self._maxFrame
    end
    
    if self._joinSpellComeOutFrameIndex < self._hurtDoneFrameIndex + 1 then
        self._joinSpellComeOutFrameIndex = self._hurtDoneFrameIndex + 1
    end
end

function Spell:getFollowSpell()
    return self._followSpell
end

--设置自己所跟随的前面的技能
function Spell:setPreviousSpell(spell)
    self._previousSpell = spell
    if self._template and self._template.targetInitHeight and self._template.targetInitHeight > 0 then
        local rise = self._template:getFirstKeyFrameByType(FrameActionType.RISE)
        if rise then
            self._firstRiseFrameIndex = rise.index
        end
    end
end

function Spell:getPreviousSpell()
    return self._previousSpell
end

--连携技出手时间是否已经过去
function Spell:isJoinSpellTimePast()
    return self._isJoinSpellTimePast
end
function Spell:startFightBack(spell)
    local function onCallback()
        self._battle:executeSpell(spell)
    end

    local role = spell:getExecutor()
    local eff = SimpleEffect.new("effect/hr_fanji", false, 0.5, gl.ONE, gl.ONE, nil, onCallback)

    if role:getInfo().side == RoleInfo.SIDE_RIGHT then
        eff:setScaleY(2)
        eff:setScaleX(-2)
    else
        eff:setScale(2)
    end

    local pt = cc.pAdd(role:getCenterPosition(), cc.p(-5,-28))
    role:addEffect(eff, pt)
end

function Spell:processBuff()
    local BuffMgr = require("src/scene/battle/manager/BuffMgr")
    for i, buffData in ipairs(self._spellData.buffs) do
        BuffMgr.cache(buffData)
    end
end

function Spell:resetTargetsPosition()
    local targets = self:getAttackTargets()
    for i, role in ipairs(targets) do
        role:setPosition(role:getOriginPosition())
    end
end

--使技能生效（针对技能附加的效果，如增加怒气值等） 
function Spell:takeEffectAdditional()
    for i, action in ipairs(self._spellData.actions) do
        if action.type == GameActionType.GAME_ACTION_ADD_MP 
            or action.type == GameActionType.GAME_ACTION_REMOVE_MP then
            local role = self._battle:getRole(action.targetTeam,action.targetPosition)
            if role then
                role:changeMp(action.mp)
            end
        elseif action.type == GameActionType.GAME_ACTION_ADD_BUFF then
            local role = self._battle:getRole(action.targetTeam,action.targetPosition)
            if role then
            end
        end
    end
end

--将所有要攻击的对象设置为锁定状态（处于锁定状态的角色会被限制某些行为，如死亡时不会立即被移除）
function Spell:lockTargets()
    if self._template then
        local damages = self._spellData:getDamageData(1)--取第1段伤害来找攻击的对象
        if damages then
            for j, damage in ipairs(damages) do
                local role = self._battle:getRole(damage.targetTeam,damage.targetPosition)
                if role then
                    role.lockCount = role.lockCount + 1
                end
            end
        end
    end
end
--解除锁定
function Spell:unlockTargets(lastHurt)
    if self._template then
        local damages = self._spellData:getDamageData(1)--取第1段伤害来找攻击的对象
        if damages then
            for j, damage in ipairs(damages) do
                local role = self._battle:getRole(damage.targetTeam,damage.targetPosition)
                if role then
                    role.lockCount = role.lockCount - 1
                
                    if lastHurt then
                        if role:getInfo().isDead and role:getInfo():isBoss() then
                            self:playBossDieEffects(role)
                        end
                    end
                end
            end
        end
    end
end

--针对特殊的动作对受击者进行锁定
function Spell:lockForSpecialAction()
    if self._template then
        local action = self._template:getLastKeyFrameByType(FrameActionType.FALL)
        if action then
            self:lockTargets()
        end
        action = self._template:getLastKeyFrameByType(FrameActionType.FLY_OFF)
        if action then
            self:lockTargets()
        end
    end
end


--开始分身
--targets list of Role
function Spell:bodySeparateStart(targets,sourceTarget)
    if not self._bodySeparateMgr and targets and #targets > 0 then
        local BodySeparateMgr = require("src/scene/battle/manager/BodySeparateMgr")
        self._bodySeparateMgr = BodySeparateMgr.new(self:getExecutor())
        self._bodySeparateMgr:start(targets, sourceTarget)
    end
end

--结束分身
function Spell:bodySeparateFinish()
    if self._bodySeparateMgr then
        self._bodySeparateMgr:finish()
        self._bodySeparateMgr = nil
    end
end

function Spell:getBodySeparateMgr()
    return self._bodySeparateMgr
end

--添加分身
function Spell:addCopy(copyId, role)
    if not self._copies then
        self._copies = {}
    end

    local temp = self._copies[copyId]
    if temp then
        self:removeCopyByID(copyId)
    end

    self._copies[copyId] = role
    self._battle:getMap():addRole(role)
end

--移除指定名字的分身
function Spell:removeCopyByID(copyId)
    if not self._copies then return end

    local role = self._copies[copyId]
    if role then
        self._battle:getMap():removeRole(role)
        self._copies[copyId] = nil
    end
end

--获得指定名字的分身
function Spell:getCopyByID(copyId)
    if not self._copies then return nil end
    return self._copies[copyId]
end

--清除所有的分身
function Spell:clearCopies()
    if not self._copies then return end

    for _, role  in pairs(self._copies) do
        self._battle:getMap():removeRole(role)
    end
    self._copies = {}
end


--获得所有的攻击目标(Role)
function Spell:getAttackTargets()
--TODO @gavin
--    if self._attackTargets then
--        return self._attackTargets
--    end

    local roles = {}
    self._attackTargets = roles

    local damages = self._spellData:getDamageData(1)--取第1段伤害来找攻击的对象
    if damages then
        for j, damage in ipairs(damages) do
            local role = self._battle:getRole(damage.targetTeam,damage.targetPosition)
            if role then
                table.insert(roles,role)
            end
        end
    end
    return self._attackTargets
end

--被攻击者的坐标
function Spell:getAttackTargetPosition()
    return self._targetPosition
end

--boss死亡时的附加效果，光效，减速等
function Spell:playBossDieEffects(role)
    local BattleMgr = require("src/scene/battle/manager/BattleMgr")
    
    local eff = SimpleEffect.new("effect/ef_tongyong/fangsheguang", false, 0.2, gl.ONE, gl.ONE, nil, nil, true)
    local viewport = BattleMgr.getBattle():getMap():getViewport()
    local size = eff:getContentSize()
    local scale
    if viewport.width/viewport.height > size.width/size.height then
        scale = viewport.width/size.width
    else
        scale = viewport.height/size.height
    end
    eff:setScale(scale)
    eff:setPosition(viewport.width/2, viewport.height/2)
    BattleMgr.getBattle():getMap():getTopUnrestrictedLayer():addChild(eff)
    
    BattleMgr.setSpeed(nil,nil,0.2)

    local function resetSpeed()
        BattleMgr.setSpeed(nil,nil,1)
    end
    BattleMgr.executeCustomAction(BattleCustomActions.DelayCallAction.new(resetSpeed, 11))
end

--隐藏与本技能无关的角色
function Spell:hideUnrelatedRoles()
    local targets = self:getAttackTargets()
    local roles = self._battle:getRoles()
    for _, role in pairs(roles) do
        if role ~= self:getExecutor() then
            local found = false
            for k, target in ipairs(targets) do
                if target == role then
                    found = true
                    break
                end
            end
            if not found then
                role:fadeOut()--setVisible(false)
                role:addPositionAfterimageAction()
            end
        end
    end
    if self._previousSpell then
        --        if self._previousSpell:getExecutor():getSpellExecuting() then
        --            self._previousSpell:getExecutor():setNeedHideFlag(true)
        --        else
        self._previousSpell:getExecutor():fadeIn()--setVisible(true)
        --        end
    end
end

function Spell:hideBuffs()
    local executor = self:getExecutor()
    executor:setBuffVisible(false)
    local targets = self:getAttackTargets()
    for i, target in ipairs(targets) do
        target:setBuffVisible(false)
    end
end
--将该技能标识为已经处理完成的（对外部而言已完成，其本身可能还在运行）
function Spell:setProcessed()
    if not self._joinSpellSelecting then
        self._endProcessed = true
    end
end
function Spell:getProcessed()
    return self._endProcessed
end
--设置是否正在选择连携技
function Spell:setJoinSpellSelecting(value)
    self._joinSpellSelecting = value
end
function Spell:getJoinSpellSelecting()
    return self._joinSpellSelecting
end

--显示所有的角色，在调用了hideUnrelatedRoles()方法后，可以通过此方法显示被隐藏的角色
function Spell:showAllRoles()
    local roles = self._battle:getRoles()
    for _, role in pairs(roles) do
--        role:setVisible(true)
          role:fadeIn()
    end
end


--为编辑器提供的方法
function Spell:setFrame(frame)
    self:clean()
    self:initAllRoles(frame)

    local layers = self._template:getLayers()
    for i, layer in ipairs(layers) do
        local keyFrame = layer:getKeyFrame(frame)
        if keyFrame and keyFrame.type == FrameState.WEIGHT_KEY_FRAME then
            local action = FrameActionFactory.create(self, keyFrame)
            if action then
                action:setFrame(frame)
                table.insert(self._frameActions, action)
            end
        end
    end
    self._currentFrame = frame
end
function Spell:dispatchDamageEffect(damage)
    if not damage or damage == 0 then return end
    local last
    if self._template then
        if self._hurtSegmentNum <= self._currentSegment then--说明掉血时机已经全部用完了
            last = true
        end
    end
    self:dispatchEvent({name=Spell.EVENT_DAMAGE, damage=damage, last = last})
end
--编辑器专用方法
function Spell:initAllRoles(frameIndex)
    local frames = self._template:getAllKeyFrameBefore(FrameActionType.CALL_ROLE, frameIndex)
    if frames and #frames > 0 then
        table.sort(frames,function (a, b) return a.index < b.index end)
        for i, frame in ipairs(frames) do
            if frame.index + frame.__layerData:getKeyFrameLength(frame) <= frameIndex then
                local action = FrameActionFactory.create(self, frame)
                if action then
                    action:setFrame(frameIndex)
                    table.insert(self._frameActions, action)
                end
            end
        end
    end
    
    local frames = self._template:getAllKeyFrameBefore(FrameActionType.REMOVE_ROLE, frameIndex)
    if frames and #frames > 0 then
        table.sort(frames,function (a, b) return a.index < b.index end)
        for i, frame in ipairs(frames) do
            if frame.index + frame.__layerData:getKeyFrameLength(frame) <= frameIndex then
                local action = FrameActionFactory.create(self, frame)
                if action then
                    action:setFrame(frameIndex)
                    table.insert(self._frameActions, action)
                end
            end
        end
    end
end

function Spell:addTempRole(roleInfo)
    local role = self._tempRoles[roleInfo.callId]
    if not role then
        role = Role.new(roleInfo, true)
        self._tempRoles[roleInfo.callId] = role
        self._battle:getMap():addRole(role)
    end
    return role
end

function Spell:removeTempRole(role)
    if role then
        self._tempRoles[role:getInfo().callId] = nil
        self._battle:getMap():removeRole(role)
    end
end

function Spell:removeTempRoleById(callId)
    local role = self._tempRoles[callId] 
    if role then
        self._tempRoles[callId] = nil
        self._battle:getMap():removeRole(role)
    end
end

function Spell:getTempRole(callId)
    return self._tempRoles[callId]
end
--为编辑器提供的方法
function Spell:refresh()
    self:setFrame(self._currentFrame)
end

function Spell:clean()
    for i, v in ipairs(self._frameActions) do
        v:dispose()
    end
    self._frameActions = {}
end


--获得技能的施放者(Role)
function Spell:getExecutor()
    if self._executor then
        return self._executor
    end
    self._executor = self._battle:getRole(self._spellData.fromTeam, self._spellData.fromPosition)
    self._executorRoleInfo = self._executor:getInfo()
    return self._executor
end

--是否是站着放法的（既没有跑回来或跳回来的动作的）
function Spell:isStandSpell()
    return self._isStandSpell
end

function Spell:getMoveForwardFrame()
    return self._template:getFirstKeyFrameByType(FrameActionType.MOVE_FORWARD)
end

function Spell:getSpellData()
    return self._spellData
end

function Spell:getTemplate()
    return self._template
end

--是否属于并行的播放的技能
function Spell:isConcurrent()
    return self._spellData:isConcurrent()
end

function Spell:getBattle()
    return self._battle
end

return Spell