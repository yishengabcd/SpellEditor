
--连携效果编辑窗口
local JoinSpellEditWin = class("JoinSpellEditWin",require("components.BaseWindow"))

local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local CustomButton = require("components.CustomButton")
local StringUtil = require("util.StringUtil")
local SpellsDataHelper = require("spellgen.helper.SpellsDataHelper")
local LabelValue = require("spellgen.view.LabelValue")
local model = require("spellgen.model.BattleSimulateModel")
local CoordSelector = require("spellgen.view.CoordSelector")
local MotionType = require("scene.battle.mode.MotionType")

local instance = nil
local ITEM_WIDTH = 180
local ITEM_HEIGHT = 35
local ITEM_GAP = 3


--------------------Item-----------------------

local Item = class("SpellSelectItem", require("components.CustomButton"))

function Item:ctor(spellData, onSelect)
    self._spellData = spellData
    self._onSelect = onSelect
    self._selected = false;
    
    Item.super.ctor(self, spellData.id, handler(self,self.onClick))
    
    self:loadTextures("ui/file_button_u.png", "ui/file_button_d.png", "")
    
end

function Item:onClick(target)
    if self._selected then
        self:setSelected(false)
    else
        self:setSelected(true)
    end

    if self._onSelect then
        self._onSelect(self);
    end
end

function Item:setSelected(value)
    if self._selected ~= value then
        if self._selected then
            self._selected = false
            self:loadTextureNormal("ui/file_button_u.png")
        else
            self._selected = true
            self:loadTextureNormal("ui/file_button_s.png")
        end
    end
end

function Item:refreshData()
    self:setTitleText(self._spellData.id)
end
function Item:getSelected()
    return self._selected
end

function Item:getSpellData()
    return self._spellData
end




--------------------JoinSpellEditWin-----------------------

function JoinSpellEditWin:ctor()
    local size = cc.size(800,600)
    JoinSpellEditWin.super.ctor(self, size)
    local rect = self:getContentRect()
    
    local listback = ccui.Scale9Sprite:create(cc.rect(3,3,26,26),"ui/win_back2.png")
    listback:setAnchorPoint(0,1)
    
    listback:setContentSize(cc.size(ITEM_WIDTH+20,rect.height))
    listback:setPosition(rect.x,rect.y)
    
    self:addChild(listback)
    
    self:setTitle("连携技出场效果编辑")
    
    local listHeight = rect.height;
    self._listHeight = listHeight

    local scrollView2 = cc.ScrollView:create()
    
    local function scrollView2DidScroll()
    end
    local function scrollView2DidZoom()
    end

    scrollView2:setViewSize(cc.size(ITEM_WIDTH+20,listHeight))
    scrollView2:ignoreAnchorPointForPosition(true)

    scrollView2:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView2:setClippingToBounds(true)
    scrollView2:setBounceable(true)
    scrollView2:setDelegate()
    scrollView2:registerScriptHandler(scrollView2DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    scrollView2:registerScriptHandler(scrollView2DidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)    


    local container = cc.Node:create()
    local inner = cc.Node:create()
    
    self._items = {}
    self._scrollView = scrollView2
    self._container = container
    self._inner = inner
    
    container:addChild(inner)
    scrollView2:setContainer(container)
    self:addChild(scrollView2,1)
    scrollView2:setPosition(rect.x,rect.y - rect.height)
    
    for i, v in ipairs(EditorSpellModel.getSpells()) do
        self:addSpell(v)
    end
    
    self:layoutSpells();
    
    
    local contentPanel = cc.Node:create()
    contentPanel:setAnchorPoint(0,1)
    contentPanel:setPosition(rect.x + 330,rect.y - 20)
    self:addChild(contentPanel)
    self._contentPanel = contentPanel
    
    
    local function onCommitHandler(target)
        if self._spellData then
            self._spellData.joinData = self._editingData
            SpellsDataHelper.save()
        end
    end
    
    local function onClearHandler(target)
        if self._spellData then
            self._spellData.joinData = nil
            SpellsDataHelper.save()
        end
    end

    local commitBtn = CustomButton.new("保 存",onCommitHandler)
    commitBtn:setPosition(542,-161)
    self:addChild(commitBtn)
    
    local clearBtn = CustomButton.new("清 除",onClearHandler)
    clearBtn:setPosition(commitBtn:getPositionX() + 115, commitBtn:getPositionY())
    self:addChild(clearBtn)
end

function JoinSpellEditWin:addSpell(v)
    local item = Item.new(v, handler(self, self.onItemSelect))
    self._inner:addChild(item)
    table.insert(self._items,item)
    return item
end


function JoinSpellEditWin:layoutSpells()
    table.sort(self._items,function (a,b) 
        if a:getSpellData().id < b:getSpellData().id then 
            return true 
        else
            return false
        end
    end)
    
    local height = 0
    for i, item in ipairs(self._items) do
        item:setPosition(item:getContentSize().width/2, -(item:getContentSize().height+ITEM_GAP)*i+item:getContentSize().height/2)
        height  = height + item:getContentSize().height+ITEM_GAP
    end
    
    self._inner:setContentSize(ITEM_WIDTH,height)
    self._inner:setPositionY(height)

    self._container:setContentSize(ITEM_WIDTH,height)
    self._container:setPositionY(self._listHeight - height)

    self._scrollView:updateInset()
end


function JoinSpellEditWin:onItemSelect(item)
    if self._selectedItem ~= item then
        if self._selectedItem then
            self._selectedItem:setSelected(false)
        end
    end
    if item and item:getSelected() then
        self._selectedItem = item
        self:showContent(item:getSpellData())
    else
        self._selectedItem = nil
        self:clearContent()
    end
end

function JoinSpellEditWin:showContent(spellData)
    self:clearContent()
    
    self._spellData = spellData
    
    local labelX = 0
    local data = spellData.joinData
    if not data then
        data = {}
        data.motion = MotionType.RUN
        data.isLoop = 1
        data.startFrame = 1
        data.toX = -400
        data.duration = 10
    end
    
    self._editingData = data
    

    local function onChange(target)
        data.motion = self._motionNameEditor:getValue()
        data.isLoop = tonumber(self._isLoopEditorEditor:getValue()) or data.isLoop
        data.startFrame = tonumber(self._startFrameEditor:getValue()) or data.startFrame
        data.toX = tonumber(self._xEditor:getValue()) or data.toX
        data.duration = tonumber(self._durationEditor:getValue()) or data.duration
    end

    local motionNameEditor = LabelValue.new("动作名称:", LabelValue.TYPE_EDIT,onChange)
    motionNameEditor:setPosition(labelX-13, 0)
    self._contentPanel:addChild(motionNameEditor);
    motionNameEditor:setValue(data.motion)
    self._motionNameEditor = motionNameEditor
    
    local isLoopEditor = LabelValue.new("动作循环(1是0非):", LabelValue.TYPE_EDIT,onChange)
    isLoopEditor:setPosition(labelX-13, motionNameEditor:getPositionY() - 30)
    self._contentPanel:addChild(isLoopEditor);
    isLoopEditor:setValue(data.isLoop)
    self._isLoopEditorEditor = isLoopEditor
    
    local startFrameEditor = LabelValue.new("动作开始帧:", LabelValue.TYPE_EDIT,onChange)
    startFrameEditor:setPosition(labelX-13,isLoopEditor:getPositionY() - 30)
    self._contentPanel:addChild(startFrameEditor);
    startFrameEditor:setValue(data.startFrame)
    self._startFrameEditor = startFrameEditor
    
    local xEditor = LabelValue.new("与目标距离X:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,startFrameEditor:getPositionY() - 30)
    self._contentPanel:addChild(xEditor);
    xEditor:setValue(data.toX)
    self._xEditor = xEditor
    
    local durationEditor = LabelValue.new("持续帧数:", LabelValue.TYPE_EDIT,onChange)
    durationEditor:setPosition(labelX-13,xEditor:getPositionY() - 30)
    self._contentPanel:addChild(durationEditor);
    durationEditor:setValue(data.duration)
    self._durationEditor = durationEditor
    
    
    local descLabel = ccui.Text:create("说明：\n1､可先在src/BattleConfig.lua文件中设置战斗过程\n2､当连携效果参数调整后，点击保存\n3､预览配置战斗\4､点清除按钮，删除连携效果", "Airal", 14)
    descLabel:setColor(cc.c3b(220,220,220))
    descLabel:setAnchorPoint(0,1)
    descLabel:setPosition(147, 12)
    self._contentPanel:addChild(descLabel)
end

function JoinSpellEditWin:clearContent()
    self._contentPanel:removeAllChildren(true)
    self._spellData = nil
end

return JoinSpellEditWin