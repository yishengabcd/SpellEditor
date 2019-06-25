
local CustomButton = require("components.CustomButton")
local ContextMenu = require("components.ContextMenu")

local menuItems = 
    {
        ROLE_FRONT = "人物前面",
        ROLE_BACK = "人物后面"
    }
--类型映射表
local typeMapping = 
    {
        [menuItems.ROLE_FRONT] = 1,
        [menuItems.ROLE_BACK] = -1
    }
local typeMapping2 = {}

for v in pairs(typeMapping) do
    typeMapping2[typeMapping[v]] = v
end

local EffectLevelSelector = class("EffectLevelSelector", function () 
    return cc.Node:create() 
end)

function EffectLevelSelector:ctor(onChangeHandler)
    self._onChangeHandler = onChangeHandler
    local function onBtnClick(target)
        local menus = {}
        table.insert(menus,menuItems.ROLE_FRONT)
        table.insert(menus,menuItems.ROLE_BACK)

        ContextMenu.showMenu(menus,function (label) 
            self:setText(label, true) 
        end,
        target)
    end

    local btn = CustomButton.new(menuItems.ROLE_FRONT, onBtnClick)
    self:addChild(btn)
    self._button = btn

    self:setText(menuItems.ROLE_FRONT)
end

function EffectLevelSelector:setText(label, trigger)
    self._button:setTitleText(label)
    self._type = typeMapping[label]

    if self._onChangeHandler  and trigger then
        self._onChangeHandler(self)
    end
end

function EffectLevelSelector:getText()
    return self._button:getTitleText()
end

function EffectLevelSelector:getType()
    return self._type
end

function EffectLevelSelector.getStringByType(type)
    local type = type or 1
    return typeMapping2[type]
end

return EffectLevelSelector