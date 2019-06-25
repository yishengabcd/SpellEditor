
local CustomButton = require("components.CustomButton")
local ContextMenu = require("components.ContextMenu")
local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
--参考坐标选择组件

local menuItems = 
    {
        SCREEN_CENTER = "屏幕中心点",
        MY_TEAM_CENTER = "已方中心点",
        OPPO_TEAM_CENTER = "对方中心点",
        ATTACK_POS = "攻击者中心点",
        BEATTACK_POS = "受击者中心点",
        ATTACK_BOTTOM_POS = "攻击者坐标",
        BEATTACK_BOTTOM_POS = "受击者坐标",
        MIDDLE_ATTACK_BEATTACK = "攻与受中间",
        PLACE_MAP = "地图",
        PLACE_ROLE = "角色"
    }
--类型映射表
local typeMapping = 
{
        [menuItems.SCREEN_CENTER] = CoordSystemType.SCREEN_CENTER,
        [menuItems.MY_TEAM_CENTER] = CoordSystemType.MY_TEAM_CENTER,
        [menuItems.OPPO_TEAM_CENTER] = CoordSystemType.OPPO_TEAM_CENTER,
        [menuItems.ATTACK_POS] = CoordSystemType.ATTACK_POS,
        [menuItems.BEATTACK_POS] = CoordSystemType.BEATTACK_POS,
        [menuItems.ATTACK_BOTTOM_POS] = CoordSystemType.ATTACK_BOTTOM_POS,
        [menuItems.BEATTACK_BOTTOM_POS] = CoordSystemType.BEATTACK_BOTTOM_POS,
        [menuItems.MIDDLE_ATTACK_BEATTACK] = CoordSystemType.MIDDLE_ATTACK_BEATTACK,
        [menuItems.PLACE_MAP] = CoordSystemType.PLACE_MAP,
        [menuItems.PLACE_ROLE] = CoordSystemType.PLACE_ROLE
}
local typeMapping2 = {}

for v in pairs(typeMapping) do
    typeMapping2[typeMapping[v]] = v
end
    
local CoordSelector = class("CoordSelector", function () 
    return cc.Node:create() 
end)

function CoordSelector:ctor(onChangeHandler, filter)
    self._onChangeHandler = onChangeHandler
    local function onBtnClick(target)
        local menus = {}
        if filter == 1000 then
            table.insert(menus,menuItems.PLACE_MAP)
            table.insert(menus,menuItems.PLACE_ROLE)
        else
            table.insert(menus,menuItems.SCREEN_CENTER)
            table.insert(menus,menuItems.MY_TEAM_CENTER)
            table.insert(menus,menuItems.OPPO_TEAM_CENTER)
            table.insert(menus,menuItems.ATTACK_POS)

            if filter ~= 1 then
                table.insert(menus,menuItems.BEATTACK_POS)
            end

            table.insert(menus,menuItems.ATTACK_BOTTOM_POS)
            if filter ~= 1 then
                table.insert(menus,menuItems.BEATTACK_BOTTOM_POS)
            end

            if filter == 2 then
                table.insert(menus,menuItems.MIDDLE_ATTACK_BEATTACK)
            end
        end
        
        ContextMenu.showMenu(menus,function (label) 
            self:setText(label, true) 
        end,
        target)
    end
    
    local btn = CustomButton.new(menuItems.SCREEN_CENTER, onBtnClick)
    self:addChild(btn)
    self._button = btn
    
    self:setText(menuItems.SCREEN_CENTER)
end

function CoordSelector:setText(label, trigger)
    self._button:setTitleText(label)
    self._type = typeMapping[label]
    
    if self._onChangeHandler  and trigger then
        self._onChangeHandler(self)
    end
end

function CoordSelector:getText()
    return self._button:getTitleText()
end

function CoordSelector:getType()
    return self._type
end

function CoordSelector.getStringByType(type)
    return typeMapping2[type]
end

return CoordSelector