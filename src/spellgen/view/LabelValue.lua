
local CoordSelector = require("spellgen.view.CoordSelector")
local ActionEaseSelector = require("spellgen.view.ActionEaseSelector")
local EffectLevelSelector = require("spellgen.view.EffectLevelSelector")
local BlendFactorSelector = require("spellgen.view.BlendFactorSelector")

local LabelValue = class("LabelValue",function () 
    return cc.Node:create() 
end)

LabelValue.TYPE_READ = 1 --只用于显示
LabelValue.TYPE_EDIT = 2 --可以编辑
LabelValue.TYPE_COORD = 3 --参考坐标
LabelValue.TYPE_ACTION_EASE = 4 --动作缓动类型
LabelValue.TYPE_EFFECT_LEVEL = 5 --特效层次
LabelValue.TYPE_BLEND_FACTOR = 6 --混合模式

function LabelValue:ctor(labelStr, type, changeHandler, params, alwayShow)
    local type = type or LabelValue.TYPE_READ
    self._type = type
    self._value = ""
    
    local function onChangeHandler(target)
        if type == LabelValue.TYPE_EDIT then
            self:setValue(self._valueCom:getText())
        elseif type == LabelValue.TYPE_COORD then

        end
        if changeHandler then
            changeHandler(self)
        end
    end
    
    local label = ccui.Text:create(labelStr, "Airal", 14)
    label:setAnchorPoint(1,0.5)
    label:setColor(cc.c3b(220,220,220))
    self:addChild(label)

    if type == LabelValue.TYPE_READ then
        local valueLabel = ccui.Text:create("", "Airal", 14)
        valueLabel:setColor(cc.c3b(220,220,220))
        valueLabel:setPositionX(10)
        valueLabel:setAnchorPoint(0,0.5)
        self:addChild(valueLabel)
        self._valueCom = valueLabel
    elseif type == LabelValue.TYPE_EDIT then
        local input = TextInput.new(cc.size(120,30), onChangeHandler, alwayShow)
        input:setAnchorPoint(0,0.5)
        input:setPositionX(70)
        self:addChild(input)
        self._valueCom = input
    elseif type == LabelValue.TYPE_COORD then
        local filter = params and params.filterCoord or nil
        local coordSelector = CoordSelector.new(onChangeHandler, filter)
        coordSelector:setAnchorPoint(0,0.5)
        coordSelector:setPositionX(60)
        self:addChild(coordSelector)
        self._valueCom = coordSelector
    elseif type == LabelValue.TYPE_EFFECT_LEVEL then
        local selector = EffectLevelSelector.new(onChangeHandler)
        selector:setAnchorPoint(0,0.5)
        selector:setPositionX(60)
        self:addChild(selector)
        self._valueCom = selector
    elseif type == LabelValue.TYPE_ACTION_EASE then
        local actionEaseSelector = ActionEaseSelector.new(onChangeHandler)
        actionEaseSelector:setAnchorPoint(0,0.5)
        actionEaseSelector:setPositionX(60)
        self:addChild(actionEaseSelector)
        self._valueCom = actionEaseSelector 
    elseif type == LabelValue.TYPE_BLEND_FACTOR then
        local isSrc = params
        local blendFactorSelector = BlendFactorSelector.new(onChangeHandler,isSrc)
        blendFactorSelector:setAnchorPoint(0,0.5)
        blendFactorSelector:setPositionX(60)
        self:addChild(blendFactorSelector)
        self._valueCom = blendFactorSelector 
    end
end

function LabelValue:setValue(str)
    self._value = str
    if self._valueCom then
        if self._type == LabelValue.TYPE_READ then
            self._valueCom:setString(str)
        elseif self._type == LabelValue.TYPE_EDIT then
            self._valueCom:setText(str)
        elseif self._type == LabelValue.TYPE_COORD then
            self._valueCom:setText(str)
        elseif self._type == LabelValue.TYPE_EFFECT_LEVEL then
            self._valueCom:setText(str)
        elseif self._type == LabelValue.TYPE_ACTION_EASE then
            self._valueCom:setText(str)
        elseif self._type == LabelValue.TYPE_BLEND_FACTOR then
            self._valueCom:setText(str)
        end
    end
end

function LabelValue:getValue()
    if self._type == LabelValue.TYPE_ACTION_EASE or self._type == LabelValue.TYPE_BLEND_FACTOR then
        return self._valueCom:getText()
    end
    return self._value
end
--第二个参数，当type == LabelValue.TYPE_COORD或LabelValue.TYPE_EFFECT_LEVEL时有效
function LabelValue:getValue2()
    if self._type == LabelValue.TYPE_COORD or self._type == LabelValue.TYPE_EFFECT_LEVEL then
        return self._valueCom:getType()
    end
end

return LabelValue