local SpellSelectWin = class("SpellSelectWin", require("components.BaseWindow"))
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local CustomButton = require("components.CustomButton")
local StringUtil = require("util.StringUtil")
local SpellsDataHelper = require("spellgen.helper.SpellsDataHelper")
local LabelValue = require("spellgen.view.LabelValue")
local model = require("spellgen.model.BattleSimulateModel")
local CanselAndResum = require("src/spellgen/view/CanselAndResum")

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



--------------------AddSpellWin-----------------------

local AddSpellWin = class("AddSpellWin", require("components.BaseWindow"))
function AddSpellWin:ctor(callback)
    local size = cc.size(300,300)
    AddSpellWin.super.ctor(self, size)
    
    local label = ccui.Text:create("技能id：", "Airal", 14)
    label:setColor(cc.c4b(220,220,220,255))
    label:setPosition(size.width/2-60,-70)
    self:addChild(label)
    
    local input = TextInput.new(cc.size(120,30))
    input:setPosition(size.width/2+30,-70)
    self:addChild(input)
    
    self:setTitle("添加新技能")
    
    local function addHandler(target)
        local id = tonumber(StringUtil.trim(input:getText()))
        if id == nil then
            Alert.alert("技能id不合法")
            return
        end
        if callback then
            local data = {id=id}
            if EditorSpellModel.addSpell(data) then
                callback(data)
                self:hide()
            else
                Alert.alert("已存在相同的技能id")
            end
        end
    end
    
    local addBtn = CustomButton.new("添加",addHandler)
    addBtn:setPosition(155,-246)
    self:addChild(addBtn)
end


--------------------SpellSelectWin-----------------------

function SpellSelectWin:ctor()
    local size = cc.size(800,500)
    SpellSelectWin.super.ctor(self, size)
    local rect = self:getContentRect()
    
    local listback = ccui.Scale9Sprite:create(cc.rect(3,3,26,26),"ui/win_back2.png")
    listback:setAnchorPoint(0,1)
    
    listback:setContentSize(cc.size(ITEM_WIDTH+20,rect.height))
    listback:setPosition(rect.x,rect.y)
    
    self:addChild(listback)
    
    self:setTitle("技能选择")
    
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
    
    local spellIdLabel = ccui.Text:create("技能id：", "Airal", 14)
    spellIdLabel:setColor(cc.c3b(220,220,220))
    spellIdLabel:setPosition(size.width/2-110,-70)
    self:addChild(spellIdLabel)
    
    local input = TextInput.new(cc.size(120,30),nil, true)
    input:setPosition(spellIdLabel:getPositionX()+90,spellIdLabel:getPositionY())
    self:addChild(input)
    
    self._spellIdTxt = input
    
    local leftRoleNumEditor = LabelValue.new("左边人数:", LabelValue.TYPE_EDIT,nil)
    leftRoleNumEditor:setPosition(spellIdLabel:getPositionX()+20, spellIdLabel:getPositionY() - 40)
    self:addChild(leftRoleNumEditor);
    leftRoleNumEditor:setValue(1)
    self._leftRoleNumEditor = leftRoleNumEditor

    local rightRoleNumEditor = LabelValue.new("右边人数:", LabelValue.TYPE_EDIT,nil)
    rightRoleNumEditor:setPosition(leftRoleNumEditor:getPositionX(), leftRoleNumEditor:getPositionY() - 30)
    self:addChild(rightRoleNumEditor);
    rightRoleNumEditor:setValue(1)
    self._rightRoleNumEditor = rightRoleNumEditor
    
    local function onTextChanged(target)
        if self._selectedItem and self._selectedItem:getSpellData() then
            self._selectedItem:getSpellData().isActive = tonumber(self._isActiveEditor:getValue()) or self._selectedItem:getSpellData().isActive
            self._selectedItem:getSpellData().targetInitHeight = tonumber(self._targetInitHeightEditor:getValue()) or self._selectedItem:getSpellData().targetInitHeight
            self._selectedItem:getSpellData().hitBackFrame = tonumber(self._hitBackFrameCountEditor:getValue()) or self._selectedItem:getSpellData().hitBackFrame
            self._selectedItem:getSpellData().getUpFrame = tonumber(self._getUpFrameEditor:getValue())
            self._selectedItem:getSpellData().lieDownJoin = tonumber(self._lieDownJoinEditor:getValue())
        end
    end
    
    local isActiveEditor = LabelValue.new("是否是主动技:", LabelValue.TYPE_EDIT,onTextChanged)
    isActiveEditor:setPosition(rightRoleNumEditor:getPositionX()+20, rightRoleNumEditor:getPositionY() - 40)
    self:addChild(isActiveEditor);
    if self._selectedItem and self._selectedItem:getSpellData() then
        isActiveEditor:setValue(self._selectedItem:getSpellData().isActive)
    end
    self._isActiveEditor = isActiveEditor
    
    local targetInitHeightEditor = LabelValue.new("怪物初始高度:", LabelValue.TYPE_EDIT,onTextChanged)
    targetInitHeightEditor:setPosition(isActiveEditor:getPositionX(), isActiveEditor:getPositionY() - 40)
    self:addChild(targetInitHeightEditor);
    if self._selectedItem and self._selectedItem:getSpellData() then
        targetInitHeightEditor:setValue(self._selectedItem:getSpellData().targetInitHeight)
    end
    self._targetInitHeightEditor = targetInitHeightEditor
    
    local hitBackFrameCountEditor = LabelValue.new("击退连携帧:", LabelValue.TYPE_EDIT,onTextChanged)
    hitBackFrameCountEditor:setPosition(targetInitHeightEditor:getPositionX(), targetInitHeightEditor:getPositionY() - 40)
    self:addChild(hitBackFrameCountEditor);
    if self._selectedItem and self._selectedItem:getSpellData() then
        hitBackFrameCountEditor:setValue(self._selectedItem:getSpellData().hitBackFrame)
    end
    self._hitBackFrameCountEditor = hitBackFrameCountEditor
    
    local getUpFrameEditor = LabelValue.new("倒地起身帧:", LabelValue.TYPE_EDIT,onTextChanged)
    getUpFrameEditor:setPosition(isActiveEditor:getPositionX()+300, isActiveEditor:getPositionY())
    self:addChild(getUpFrameEditor);
    if self._selectedItem and self._selectedItem:getSpellData() then
        getUpFrameEditor:setValue(self._selectedItem:getSpellData().getUpFrame)
    end
    self._getUpFrameEditor = getUpFrameEditor
    
    local lieDownJoinEditor = LabelValue.new("倒地连携帧:", LabelValue.TYPE_EDIT,onTextChanged)
    lieDownJoinEditor:setPosition(getUpFrameEditor:getPositionX(), getUpFrameEditor:getPositionY() - 40)
    self:addChild(lieDownJoinEditor);
    if self._selectedItem and self._selectedItem:getSpellData() then
        lieDownJoinEditor:setValue(self._selectedItem:getSpellData().lieDownJoin)
    end
    self._lieDownJoinEditor = lieDownJoinEditor
    
    local descLabel = ccui.Text:create("说明：\n1､是否是主动技栏，如果是主动技或连携技时填1,\n反之填0", "Airal", 14)
    descLabel:setColor(cc.c3b(220,220,220))
    descLabel:setPosition(hitBackFrameCountEditor:getPositionX()+72,hitBackFrameCountEditor:getPositionY() - 50)
    self:addChild(descLabel)
    
    --修改技能id
    local function onAlterBtnClick(target)
        if self._selectedItem then
            local id = tonumber(StringUtil.trim(input:getText()))
            if id == nil then
                Alert.alert("技能id不合法")
                return
            end
            if EditorSpellModel.isExist(id) then
                Alert.alert("该技能id已存在")
                return
            end
            self._selectedItem:getSpellData().id = id
            self._selectedItem:refreshData()
        end
    end
    
    local alterBtn = CustomButton.new("修改", onAlterBtnClick)
    alterBtn:setPosition(input:getPositionX()+120,input:getPositionY())
    self:addChild(alterBtn)
    
    
    --添加技能回调
    local function onAddSpell(data)
        local item = self:addSpell(data)
        self:layoutSpells();
        item:setSelected(true)
        self:onItemSelect(item)
    end
    
    --技能面板上的按钮点击回调方法
    local function onBtnClick(target)
        if target == self._addBtn then
            local addWin = AddSpellWin.new(onAddSpell)
            addWin:show(true)
            addWin:setPositionY(addWin:getPositionY() - 200)
        elseif target == self._editBtn then
            if self._selectedItem then
                model.leftRoleNum = tonumber(self._leftRoleNumEditor:getValue()) or 1
                model.rightRoleNum = tonumber(self._rightRoleNumEditor:getValue()) or 1
                if model.leftRoleNum < 1 then
                    model.leftRoleNum = 1
                elseif model.leftRoleNum > 6 then
                    model.leftRoleNum = 6
                end
                if model.rightRoleNum < 1 then
                    model.rightRoleNum = 1
                elseif model.rightRoleNum > 6 then
                    model.rightRoleNum = 6
                end
                EditorSpellModel.setEditSpell(self._selectedItem:getSpellData())
                self:hide();
            else
                Alert.alert("请选择要编辑的技能")
            end
            CanselAndResum:ClearAllCansel()
            CanselAndResum:ClearAllResum()
            CanselAndResum:ClearAllCanselEvent()
            CanselAndResum:ClearAllResumEvent()
            CanselAndResum:ClearAllCanselLayer()
            CanselAndResum:ClearAllResumLayer()
        elseif target == self._delBtn then
            if self._selectedItem then
                local function confirmDel(ret)
                    if ret == Confirm.YES then
                        self:removeSpell(self._selectedItem)
                        self:layoutSpells()
                    end
                end
                Confirm.confirm("是否确定删除该技能？",confirmDel)
            else
                Alert.alert("请选择需要删除的技能")
            end
        elseif target == self._saveBtn then
            SpellsDataHelper.save()
        end
    end
    
    local btn = CustomButton.new("新增", onBtnClick)
    btn:setPosition(280,-460)
    self:addChild(btn)
    self._addBtn = btn;
    
    btn = CustomButton.new("编辑该技能", onBtnClick)
    btn:setPosition(400,-460)
    self:addChild(btn)
    self._editBtn = btn;
    
    btn = CustomButton.new("删除", onBtnClick)
    btn:setPosition(520,-460)
    self:addChild(btn)
    self._delBtn = btn;
    
    btn = CustomButton.new("保存", onBtnClick)
    btn:setPosition(640,-460)
    self:addChild(btn)
    self._saveBtn = btn;
end

function SpellSelectWin:addSpell(v)
    local item = Item.new(v, handler(self, self.onItemSelect))
    self._inner:addChild(item)
    table.insert(self._items,item)
    return item
end

function SpellSelectWin:removeSpell(item)
    for i, v in ipairs(self._items) do
    	if v == item then
    	   EditorSpellModel.removeSpell(v:getSpellData())
            self._inner:removeChild(v, true)
            table.remove(self._items,i)
    	   break
    	end
    end
    self._selectedItem = nil
    self:onItemSelect(nil)
end

function SpellSelectWin:layoutSpells()
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


function SpellSelectWin:onItemSelect(item)
    if self._selectedItem ~= item then
        if self._selectedItem then
            self._selectedItem:setSelected(false)
        end
    end
    if item and item:getSelected() then
        self._selectedItem = item
        self._spellIdTxt:setText(item:getSpellData().id)
        if self._isActiveEditor then 
            self._isActiveEditor:setValue(item:getSpellData().isActive or "")
        end
        if self._targetInitHeightEditor then
            self._targetInitHeightEditor:setValue(item:getSpellData().targetInitHeight or "")
        end
        if self._hitBackFrameCountEditor then
            self._hitBackFrameCountEditor:setValue(item:getSpellData().hitBackFrame or "")
        end
        if self._getUpFrameEditor then
            self._getUpFrameEditor:setValue(item:getSpellData().getUpFrame or "")
        end
        if self._lieDownJoinEditor then
            self._lieDownJoinEditor:setValue(item:getSpellData().lieDownJoin or "")
        end
    else
        self._selectedItem = nil
        self._spellIdTxt:setText("")
    end
end

return SpellSelectWin