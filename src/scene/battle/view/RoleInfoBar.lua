
local RoleInfo = require("src/scene/battle/data/RoleInfo")
--角色血条、等级、行动条等
local RoleInfoBar = class("RoleInfoBar", function () 
    return cc.Sprite:create()
end)

local scheduler = cc.Director:getInstance():getScheduler()

---------------------BuffIcon------------------------
local BuffIcon = class("BuffIcon", function ()
    return cc.Node:create()
end)

function BuffIcon:ctor(buffData)
    self._buffData = buffData
    local sp = cc.Sprite:createWithSpriteFrameName(ResourceManager:getInstance():getIconPath(buffData:getTemplate().res_icon))
    self:addChild(sp)
end

function BuffIcon:getBuffData()
    return self._buffData
end

---------------------BuffIconContainer------------------------
local BuffIconContainer = class("BuffIconContainer", function ()
    return cc.Node:create()
end)

function BuffIconContainer:ctor(info)
    self._roleInfo = info
    self:setAnchorPoint(0, 0.5)
    self._icons = {}
end

function BuffIconContainer:addBuff(buffData)
    local template = buffData:getTemplate()
    if template.show_icon ~= 1 then return end
    
    for i, icon in ipairs(self._icons) do
        if icon:getBuffData():getTemplate().res_icon == template.res_icon then
            return
        end
    end
    local icon = BuffIcon.new(buffData)
    icon:setScale(0.7)
    self:addChild(icon)
    table.insert(self._icons,icon)
    
    self:layout()
end

function BuffIconContainer:removeBuff(buffData)
    local template = buffData:getTemplate()
    if template.show_icon ~= 1 then return end
    
    for i, buff in ipairs(self._roleInfo.buffs) do
    	if buff:getTemplate().res_icon == template.res_icon then
    	   return
    	end
    end
    
    for i, icon in ipairs(self._icons) do
        if icon:getBuffData():getTemplate().res_icon == template.res_icon then
            self:removeChild(icon)
            table.remove(self._icons,i)
            break
        end
    end
    self:layout()
end

function BuffIconContainer:clearBuffIcons()
    for i, icon in ipairs(self._icons) do
        self:removeChild(icon, true)
    end
    self._icons = {}
end

function BuffIconContainer:layout()
    for i, icon in ipairs(self._icons) do
        icon:setPositionX((i - 1) * 20)
        if i > 4 then
            icon:setVisible(false)
        end
    end
end



---------------------BloodBar------------------------
local BloodBar = class("BloodBar", function ()
    return cc.Node:create()
end)

function BloodBar:ctor(isEnemy)
    self._isEnemy = isEnemy
    
    local fadeKey
    if self._isEnemy then
        fadeKey = "ui/battle/blood_red.png"
    else
        fadeKey = "ui/battle/blood_green.png"
    end
    local fadeSprite = cc.Sprite:createWithSpriteFrameName(fadeKey)
    self._fadeSprite = fadeSprite
    local bloodFade = cc.ProgressTimer:create(fadeSprite)
    bloodFade:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    bloodFade:setBarChangeRate(cc.p(1,0))
    bloodFade:setMidpoint(cc.p(0, 0))
    bloodFade:setPercentage(99.99)
    bloodFade:setOpacity(120)
    self:addChild(bloodFade)
    self._bloodFade = bloodFade
    
    local progressSprite
    if self._isEnemy then
        progressSprite = cc.Sprite:createWithSpriteFrameName("ui/battle/blood_red.png")
    else
        progressSprite = cc.Sprite:createWithSpriteFrameName("ui/battle/blood_green.png")
    end
    self._progressSprite = progressSprite
    
    local blood = cc.ProgressTimer:create(progressSprite)
    blood:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    blood:setBarChangeRate(cc.p(1,0))
    blood:setMidpoint(cc.p(0,0))
    blood:setPercentage(99.99)
    self:addChild(blood)
    self._blood = blood
    
    local function onExitHandler(event)
        if "exit" == event then
            if self._schedulerEntry then
                scheduler:unscheduleScriptEntry(self._schedulerEntry)
                self._schedulerEntry = nil
            end
        end
    end
    
    self:registerScriptHandler(onExitHandler)
end

function BloodBar:setCurrentHp(hp, maxHp)
    self._blood:stopAllActions()
    if not self._isEnemy then
        if hp/maxHp < 0.2 then
            self._progressSprite:setSpriteFrame("ui/battle/blood_red.png")
        elseif hp/maxHp > 0.5 then
            self._progressSprite:setSpriteFrame("ui/battle/blood_green.png")
        else
            self._progressSprite:setSpriteFrame("ui/battle/blood_yellow.png")
        end
    end
    if self._blood:getPercentage() == 100 then
        self._blood:setPercentage(99.999)
    end
    local action = cc.ProgressTo:create(0.1,hp/maxHp*100)
    self._blood:runAction(action)
    self._hp = hp
    self._maxHp = maxHp
    
    if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
    end
    
    local function setFadeBlood(dt)
       -- if self._schedulerEntry then
        scheduler:unscheduleScriptEntry(self._schedulerEntry)
        self._schedulerEntry = nil
        --end 
        if not self._isEnemy then
            if self._hp/self._maxHp < 0.2 then
                self._fadeSprite:setSpriteFrame("ui/battle/blood_red.png")
            elseif self._hp/self._maxHp > 0.5 then
                self._fadeSprite:setSpriteFrame("ui/battle/blood_green.png")
            else
                self._fadeSprite:setSpriteFrame("ui/battle/blood_yellow.png")
            end
        end

        self._bloodFade:stopAllActions()
        local action = cc.ProgressTo:create(0.5,self._hp/self._maxHp*100)
        self._bloodFade:runAction(action)
    end
    self._schedulerEntry = scheduler:scheduleScriptFunc(setFadeBlood,0.7,false)
end


---------------------RoleInfoBar------------------------

function RoleInfoBar:ctor(info)
    local back = cc.Sprite:createWithSpriteFrameName("ui/battle/di2_bloodbar.png")
    --back:setContentSize(cc.size(76.5,13))
    self:addChild(back)
    
    local isEnemy = info.side == RoleInfo.SIDE_RIGHT
    local bloodBar = BloodBar.new(isEnemy)
    bloodBar:setPosition(-1.5, 1.2)
    self:addChild(bloodBar)
    
    local actionBar = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("ui/battle/blood_blue.png"))
    actionBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    actionBar:setMidpoint(cc.p(0,0))
    actionBar:setBarChangeRate(cc.p(1,0))
    actionBar:setPercentage(0)
    actionBar:setPosition(bloodBar:getPositionX(), -3.5)
    self:addChild(actionBar)
    actionBar:setVisible(false)
    
    local buffBar = BuffIconContainer.new(info)
    buffBar:setPosition(-30, 21)
    self:addChild(buffBar)
    self._buffBar = buffBar
    
    local levelBackKey
    if isEnemy then
        if info.myTeamMaxLevel > 0 and info.level - info.myTeamMaxLevel > 2 then
            levelBackKey = "ui/battle/digital_red.png"
        else
            levelBackKey = "ui/battle/digital_red.png"
        end
    else
        levelBackKey = "ui/battle/digital_green.png"
    end
    local levelBack = cc.Sprite:createWithSpriteFrameName(levelBackKey)
    levelBack:setPosition(-48,0)
    self:addChild(levelBack,10)

    local levelTxt = ccui.Text:create()
    levelTxt:setString(tostring(info.level))
    levelTxt:setFontSize(14)
    levelTxt:setFontName(FONT_TYPE.DEFAULT_FONT_BOLD)
    levelTxt:setColor(cc.c3b(225,215,180))
    levelTxt:setPosition(levelBack:getPositionX(),levelBack:getPositionY()+2)
    self:addChild(levelTxt,15)

    self._bloodBar = bloodBar
end

function RoleInfoBar:setCurrentHp(hp, maxHp)
    self._bloodBar:setCurrentHp(hp,maxHp)
end

function RoleInfoBar:addBuffIcon(buffData)
    if self._buffBar then
        self._buffBar:addBuff(buffData)
    end
end

function RoleInfoBar:removeBuffIcon(buffData)
    if self._buffBar then
        self._buffBar:removeBuff(buffData)
    end
end

function RoleInfoBar:clearBuffIcons()
    if self._buffBar then
        self._buffBar:clearBuffIcons()
    end
end


return RoleInfoBar