
local CustomButton = require("components.CustomButton")
local ActionEaseType = require("src/scene/battle/mode/ActionEaseType")


local SelectWindow = class("SelectWindow",require("components.BaseWindow"))

local winSize = cc.Director:getInstance():getVisibleSize()

local _instance = nil;

local ITEM_WIDTH = 178
local ITEM_HEIGHT = 28
local GAP_TOP = 35
local GAP_LEFT = 10

function SelectWindow:ctor(items, onItemSelect)
    local h = math.floor((#items-1)/4+1)* ITEM_HEIGHT
    local function onItemClick(target)
        if onItemSelect then
            onItemSelect(target:getTitleText())
            self:hide()
        end
    end
    
    for i, v in ipairs(items) do
        local btn = CustomButton.new(v, onItemClick)
        btn:loadTextures("ui/file_button_d.png", "ui/file_button_s.png", "")
        btn:setPositionX(GAP_LEFT + btn:getContentSize().width/2 + ((i-1) % 4)*ITEM_WIDTH)
        btn:setPositionY(-GAP_TOP-btn:getContentSize().height/2 - btn:getContentSize().height*math.floor((i - 1)/4))
        self:addChild(btn, 1)
    end
    
    local size = cc.size(ITEM_WIDTH * 4 +GAP_LEFT*2, h+GAP_TOP+GAP_LEFT)
    SelectWindow.super.ctor(self, size)
    
    self:setContentSize(size)
    self:setAnchorPoint(0,0)
end

function SelectWindow:hide()
    TextInput.setTextInputVisible(true)
    SelectWindow.super.hide(self)
    _instance = nil;
end

function SelectWindow.showMenu(items, onItemSelect,target)
    if _instance then
        _instance:hide()
    end
    TextInput.setTextInputVisible(false)
    _instance = SelectWindow.new(items, onItemSelect)
    _instance:show();
    if target then
        local pt = target:convertToWorldSpace(cc.p(0,0))
        if pt.y - _instance:getContentSize().height < 0 then
            pt.y = pt.y + _instance:getContentSize().height + target:getContentSize().height
        end
        if pt.x + _instance:getContentSize().width > winSize.width then
            pt.x = winSize.width - _instance:getContentSize().width
        end
        _instance:setPosition(pt)
    end
    
    return _instance
end

--------------------------------ActionEaseSelector--------------------------------------

local menuItems = {}
table.insert(menuItems,ActionEaseType.None)
table.insert(menuItems,ActionEaseType.EaseIn)
table.insert(menuItems,ActionEaseType.EaseOut)
table.insert(menuItems,ActionEaseType.EaseInOut)
table.insert(menuItems,ActionEaseType.EaseExponentialIn)
table.insert(menuItems,ActionEaseType.EaseExponentialOut)
table.insert(menuItems,ActionEaseType.EaseExponentialInOut)
table.insert(menuItems,ActionEaseType.EaseSineIn)
table.insert(menuItems,ActionEaseType.EaseSineOut)
table.insert(menuItems,ActionEaseType.EaseSineInOut)
--table.insert(menuItems,ActionEaseType.EaseElastic)
--table.insert(menuItems,ActionEaseType.EaseElasticIn)
--table.insert(menuItems,ActionEaseType.EaseElasticOut)
--table.insert(menuItems,ActionEaseType.EaseElasticInOut)
--table.insert(menuItems,ActionEaseType.EaseBounce)

table.insert(menuItems,ActionEaseType.EaseQuadraticActionIn)
table.insert(menuItems,ActionEaseType.EaseQuadraticActionOut)
table.insert(menuItems,ActionEaseType.EaseQuadraticActionInOut)
table.insert(menuItems,ActionEaseType.EaseQuarticActionIn)
table.insert(menuItems,ActionEaseType.EaseQuarticActionOut)
table.insert(menuItems,ActionEaseType.EaseQuarticActionInOut)

local ActionEaseSelector = class("ActionEaseSelector", function () 
    return cc.Node:create() 
end)

function ActionEaseSelector:ctor(onChangeHandler)
    self._onChangeHandler = onChangeHandler
    local function onBtnClick(target)
       
        SelectWindow.showMenu(menuItems,function (label) 
            self:setText(label, true) 
        end,
        target)
    end

    local btn = CustomButton.new(ActionEaseType.None, onBtnClick)
    btn:loadTextures("ui/file_button_d.png", "ui/file_button_s.png", "")
    btn:setScaleX(0.8)
    btn:setPositionX(23)
    self:addChild(btn)
    self._button = btn

    self:setText(ActionEaseType.None)
end

function ActionEaseSelector:setText(label, trigger)
    self._button:setTitleText(label)

    if self._onChangeHandler  and trigger then
        self._onChangeHandler(self)
    end
end

function ActionEaseSelector:getText()
    return self._button:getTitleText()
end

return ActionEaseSelector