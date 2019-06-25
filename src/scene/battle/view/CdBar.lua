local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local CdBar = class("CdBar",function () 
    return cc.Node:create() 
end)
local cdtotaltime = 30 
local begintime = 22
local scheduler = cc.Director:getInstance():getScheduler()
function CdBar:ctor()
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.SKILL_ICON)
    ResourceManager:getInstance():loadPlistByType(ResourceModuleType.ICON)
    local back  = cc.Sprite:createWithSpriteFrameName("ui/battle/jioncdbar.png")
    back:setPosition(0,0)
    self:addChild(back)
    self._pausetime = 0

    local progressSprite = cc.Sprite:createWithSpriteFrameName("ui/battle/jioncdbargray.png")
    progressSprite:setPosition(back:getPositionX(),back:getPositionY())
    self:addChild(progressSprite)

    local progressSprite1 = cc.Sprite:createWithSpriteFrameName("ui/battle/jioncdbarblue.png")
    self._progressSprite1 = progressSprite1
    local progressSprite2 = cc.Sprite:createWithSpriteFrameName("ui/battle/jioncdbarred.png")
    self._progressSprite2 = progressSprite2

    local cdbarblue = cc.ProgressTimer:create(progressSprite1)
    cdbarblue:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    cdbarblue:setBarChangeRate(cc.p(1,0))
    cdbarblue:setMidpoint(cc.p(0,0))
    cdbarblue:setPercentage(0)
    self:addChild(cdbarblue,10)
    cdbarblue:setPosition(back:getPositionX(),back:getPositionY())
    self._cdbarblue = cdbarblue

    local cdbarred = cc.ProgressTimer:create(progressSprite2)
    cdbarred:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    cdbarred:setBarChangeRate(cc.p(1,0))
    cdbarred:setMidpoint(cc.p(1,0))
    cdbarred:setPercentage(99.99)
    self:addChild(cdbarred,5)
    cdbarred:setPosition(back:getPositionX(),back:getPositionY())
    cdbarred:setVisible(false)
    self._cdbarred = cdbarred
    self._cd = begintime 

    local function onExitHandler(event)
        if "enter" == event then
            self._schedulerEntry = scheduler:scheduleScriptFunc(handler(self,self.refresh),1/33,false)
        end
        if "exit" == event then
            if self._schedulerEntry then
                scheduler:unscheduleScriptEntry(self._schedulerEntry)
                self._schedulerEntry = nil
            end
        end
    end

    self:registerScriptHandler(onExitHandler)
end
function CdBar:refresh(dt)
    local maxcd = cdtotaltime
    local speed = BattleMgr.getGlobalSpeed() 
    if speed == GameSpeedType.GAME_SPEED_DOUBLE then    
        self._cd = self._cd + 2*(1/33)
    else
        self._cd = self._cd + 1*(1/33)
    end
    self._cd = math.max(self._cd ,0)
    self._cd = math.min(self._cd ,cdtotaltime)
    local cd = self._cd
    self._cdbarblue:stopAllActions() 
    local actionadd = cc.ProgressTo:create(0.1,cd/maxcd*100) 
    self._cdbarblue:runAction(actionadd)
    self._pausetime = self._pausetime -(1/33)
    self._pausetime = math.max(self._pausetime ,0)
    if self._pausetime >= 0.5 then
        self._cdbarred:setVisible(true)
    else
    self._cdbarred:setVisible(false)
    end
    self._cdbarred:stopAllActions() 
    local actiondel = cc.ProgressTo:create(0.1,(maxcd -self._cd)/maxcd*100)
    self._cdbarred:runAction(actiondel)
end
function CdBar:setCd(data)
    local maxcd = cdtotaltime
    if data then
        self._cd = self._cd + data
    end
    self._cd = math.max(self._cd ,0)
    self._cd = math.min(self._cd ,cdtotaltime)
    self._cdbarblue:stopAllActions() 
    local actionadd = cc.ProgressTo:create(0.2,self._cd/maxcd*100)
    self._cdbarblue:runAction(actionadd)
    self._cdbarred:stopAllActions() 
    local actiondel = cc.ProgressTo:create(0.2,(maxcd -self._cd)/maxcd*100)
    self._cdbarred:runAction(actiondel)
    if not self._schedulerEntry then
        self._schedulerEntry = scheduler:scheduleScriptFunc(handler(self,self.refresh),1/33,false)
    end
end
function CdBar:pausefresh(data)
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
        self._schedulerEntry = nil
    end 
    self._cdbarred:setVisible(true)
    self._pausetime = 1.0
    self:setCd(data)
end
function CdBar:isCdFull()
    --if self._cd >= cdtotaltime then
    return true
    --else
    --return false
    --end 
end
return CdBar