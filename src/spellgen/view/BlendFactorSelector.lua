
local CustomButton = require("components.CustomButton")
local BlendFactor = require("src/scene/battle/mode/BlendFactor")


local SelectWindow = class("BlendSelectWindow",require("components.BaseWindow"))

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
    SelectWindow.super.hide(self)
    TextInput.setTextInputVisible(true)
    _instance = nil;
end

function SelectWindow.showMenu(items, onItemSelect,target)
    if _instance then
        _instance:hide()
    end
    _instance = SelectWindow.new(items, onItemSelect)
    _instance:show();
    TextInput.setTextInputVisible(false)
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

--------------------------------BlendFactorSelector--------------------------------------


local BlendFactorSelector = class("BlendFactorSelector", function () 
    return cc.Node:create() 
end)

function BlendFactorSelector:ctor(onChangeHandler, isSrc)
    self._onChangeHandler = onChangeHandler
    local function onBtnClick(target)
        local menuItems
        if isSrc then
            menuItems = BlendFactor.getSrcKeys()
        else
            menuItems = BlendFactor.getDestKeys()
        end
        SelectWindow.showMenu(menuItems,function (label) 
            self:setText(label, true) 
        end,
        target)
    end

    local btn = CustomButton.new("NONE", onBtnClick)
    btn:loadTextures("ui/file_button_d.png", "ui/file_button_s.png", "")
    btn:setScaleX(0.8)
    btn:setPositionX(23)
    self:addChild(btn)
    self._button = btn

    self:setText("NONE")
end

function BlendFactorSelector:setText(label, trigger)
    self._button:setTitleText(label)

    if self._onChangeHandler  and trigger then
        self._onChangeHandler(self)
    end
end

function BlendFactorSelector:getText()
    return self._button:getTitleText()
end

return BlendFactorSelector