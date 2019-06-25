local RoleMotionEditWin = class("RoleMotionEditWin", require("components.BaseWindow"))

local FileBrowseList = require "components.FileBrowseList"
local CustomButton = require("components.CustomButton")
local BattleSimulateModel = require("spellgen.model.BattleSimulateModel")
local Role = require("src/scene/battle/mode/Role")
local MotionType = require("src/scene/battle/mode/MotionType")
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local DragableSprite = require("components.DragableSprite")
local RoleConfigModel = require("src/scene/battle/data/RoleConfigModel")
local SpellsDataHelper = require("spellgen.helper.SpellsDataHelper")
local LabelValue = require("spellgen.view.LabelValue")
local EffectLevelSelector = require("spellgen.view.EffectLevelSelector")
local EffectSelectWin = require("spellgen.view.EffectSelectWin")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")


-----------------------PartItem----------------------
local PartItem = class("PartItem",function () 
    return cc.Node:create() 
end)

PartItem.HEIGHT = 28
PartItem.WIDTH = 153
local itemStartX = -26
local itemStartY = 330

function PartItem:ctor(partData, onClickHandler)
    self._partData = partData;
    self:setSelected(false)

    local nameTxt = ccui.Text:create(partData.name,"Airal",14)
    nameTxt:setPosition(0,0)
    self:addChild(nameTxt,1)
    self._nameTxt = nameTxt
    
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        local pt = self:getParent():convertToNodeSpace(location)
        local rect = self:getBoundingBox()
        rect.x = rect.x - self:getContentSize().width/2
        rect.y = rect.y - self:getContentSize().height/2
        if cc.rectContainsPoint(rect,pt) then
            if onClickHandler then
                if not self._selected then
                    onClickHandler(self)
                end
            end
            return true
        end
        return false
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function PartItem:setSelected(value)
    if self._selected ~= value then
        local path;
        self._selected = value
        if self._selected then
            path = "ui/timeline/layer_b_s.png"
        else
            path = "ui/timeline/layer_b_n.png"
        end
        if self._back then
            self:removeChild(self._back,true)
        end
        local back = cc.Sprite:createWithSpriteFrameName(path)
        self:addChild(back, 0)
        self._back = back
        self:setContentSize(back:getContentSize())
    end
end
function PartItem:refresh()
    self._nameTxt:setString(self._partData.name)
end

function PartItem:getData()
    return self._partData
end
-----------------------EditPanel----------------------
local EditPanel = class("RoleMotionEditPanel",function () return cc.Node:create() end)

function EditPanel:ctor(onRefreshHandler)
    self._onRefreshHandler = onRefreshHandler
    self._partItems = {}
    
    local detailPanel = cc.Node:create()
    detailPanel:setPosition(170,itemStartY - 50)
    self:addChild(detailPanel)
    self._detailPanel = detailPanel
    
    local function onSelectEffect(data,type)
        local partDatas = RoleConfigModel.getPartsOfMotion(self._rolePath,self._motion)
        if not partDatas then
            partDatas = {}
            RoleConfigModel.setPartsOfMotion(self._rolePath,self._motion, partDatas)
        end
        local partData = {}
        partData.effect = data.effect
        partData.name = data.name
        partData.x = 0
        partData.y = 0
        partData.scale = 1
        partData.effectLevel = 1
        partData.effectSpeed = 1
        table.insert(partDatas, partData)
        local item = self:addItem(partData)
        self:selectItem(item)
        self:layoutItems()
        
        self:onDataChanged()
    end
    
    local function onAddBtnClick(target)
        if self._rolePath and self._motion then
            local win = EffectSelectWin.new(onSelectEffect,FrameActionType.PLAY_EFFECT, true)
            win:show(true)
        end
    end
    
    local function onDeleteBtnClick(target)
        if self._rolePath and self._motion and self._selectedItem then
            for i, item in ipairs(self._partItems) do
                if item == self._selectedItem then
                    local partDatas = RoleConfigModel.getPartsOfMotion(self._rolePath,self._motion)
                    table.remove(partDatas,i)
                    table.remove(self._partItems,i)
                    self:removeChild(self._selectedItem,true)
                    self:onDataChanged()
                    break
                end
            end
            self:clearPartDetailView()
            self._selectedItem = nil
            self:layoutItems()
        end
    end
    
    local addBtn = CustomButton.new("增加", onAddBtnClick) 
    addBtn:setPosition(-75,0)
    self:addChild(addBtn)
    
    local deleteBtn = CustomButton.new("删除", onDeleteBtnClick) 
    deleteBtn:setPosition(addBtn:getPositionX()+100,addBtn:getPositionY())
    self:addChild(deleteBtn)
end

function EditPanel:onDataChanged()
    if self._onRefreshHandler then
        self._onRefreshHandler()
    end
    if self._selectedItem then
        self._selectedItem:refresh()
    end
end

function EditPanel:selectItem(item)
    if self._selectedItem and self._selectedItem ~= item then
        self._selectedItem:setSelected(false)
    end
    self._selectedItem = item
    if item then
        item:setSelected(true)
        self:showPartDetail(item:getData())
    end
end

function EditPanel:setData(rolePath, motion)
    self._rolePath = rolePath
    self._motion = motion
    
    self:clearParts()
    self:clearPartDetailView()
    self._selectedItem = nil
    
    if rolePath == nil or motion == nil then
        return
    end
    
    local parts = RoleConfigModel.getPartsOfMotion(rolePath,motion)
    
    if parts then
        for i, part in ipairs(parts) do
            self:addItem(part)
        end
        self:layoutItems()
    end 
end

function EditPanel:addItem(partData)
    local function onItemClick(item)
        self:selectItem(item)
    end
    local btn = PartItem.new(partData,onItemClick)
    self:addChild(btn);
    btn:setPositionX(itemStartX)
    table.insert(self._partItems,btn)
    
    return btn
end
function EditPanel:layoutItems()
    for i, item in ipairs(self._partItems) do
    	item:setPositionY(itemStartY - 32*i)
    end
end


function EditPanel:showPartDetail(partData)
    
    self:clearPartDetailView()
    
    local function onChange(target)
        partData.name = self._partNameTxt:getValue()
        partData.effect = self._effectNameTxt:getValue()
        partData.x = tonumber(self._xEditor:getValue()) or partData.x
        partData.y = tonumber(self._yEditor:getValue()) or partData.y
        partData.scale = tonumber(self._scaleEditor:getValue()) or partData.scale
        partData.effectLevel = self._levelEditor:getValue2()
        partData.effectSpeed = tonumber(self._speedEditor:getValue()) or partData.effectSpeed
        
        self:onDataChanged()
    end

    local labelX = 0
    
    local partNameTxt = LabelValue.new("部件名称：", LabelValue.TYPE_EDIT)
    partNameTxt:setPosition(labelX-13, 0)
    self._detailPanel:addChild(partNameTxt);
    partNameTxt:setValue(partData.name)
    self._partNameTxt = partNameTxt
    
    local effectNameTxt = LabelValue.new("技能名称：", LabelValue.TYPE_EDIT)
    effectNameTxt:setPosition(labelX-13, partNameTxt:getPositionY() - 35)
    self._detailPanel:addChild(effectNameTxt);
    effectNameTxt:setValue(partData.effect)
    self._effectNameTxt = effectNameTxt

    local xEditor = LabelValue.new("x:", LabelValue.TYPE_EDIT,onChange)
    xEditor:setPosition(labelX-13,effectNameTxt:getPositionY() - 35)
    self._detailPanel:addChild(xEditor);
    xEditor:setValue(partData.x)
    self._xEditor = xEditor

    local yEditor = LabelValue.new("y:", LabelValue.TYPE_EDIT,onChange)
    yEditor:setPosition(labelX-13,xEditor:getPositionY() - 35)
    self._detailPanel:addChild(yEditor);
    yEditor:setValue(partData.y)
    self._yEditor = yEditor

    local scaleEditor = LabelValue.new("scale:", LabelValue.TYPE_EDIT,onChange)
    scaleEditor:setPosition(labelX-13,yEditor:getPositionY() - 35)
    self._detailPanel:addChild(scaleEditor);
    scaleEditor:setValue(partData.scale)
    self._scaleEditor = scaleEditor


    local levelEditor = LabelValue.new("层次:", LabelValue.TYPE_EFFECT_LEVEL,onChange)
    levelEditor:setPosition(labelX-13,scaleEditor:getPositionY() - 35)
    self._detailPanel:addChild(levelEditor);
    levelEditor:setValue(EffectLevelSelector.getStringByType(partData.effectLevel))
    self._levelEditor = levelEditor

    local speedEditor = LabelValue.new("特效速度:", LabelValue.TYPE_EDIT,onChange)
    speedEditor:setPosition(labelX-13,levelEditor:getPositionY() - 35)
    self._detailPanel:addChild(speedEditor);
    speedEditor:setValue(partData.effectSpeed or 1)
    self._speedEditor = speedEditor
end

function EditPanel:clearPartDetailView()
    self._detailPanel:removeAllChildren(true)
end

function EditPanel:clearParts()
    for _, btn in ipairs(self._partItems) do
    	btn:getParent():removeChild(btn, true)
    end
    self._partItems = {}
end

-----------------------RoleMotionEditWin----------------------
local amaturePt

local LAYER_Z_ROLE_BACK = -99999 --角色后面层
local LAYER_Z_ROLE = -89999 --角色层
local LAYER_Z_BUFF = -79999 --buff层
local LAYER_Z_FRONT = -69999 --角色前面层

function RoleMotionEditWin:ctor(callback, type)
    local size = cc.size(1050,600)
    RoleMotionEditWin.super.ctor(self, size)
    local rect = self:getContentRect()
    self._parts = {}

    self:setTitle("角色动作编辑（增加部件）");

    local previewSize = cc.size(346,313)
    amaturePt = cc.p(previewSize.width/2,50)

    local function onFileSelected(item)
        local file = item:getFileData()
        if file.isDirectory == false then
            if file.extension == "ExportJson" then
                local path = file.relative .. "/" .. file.fileName;
                self._editPath = path

                if self._armature then
                    self:clearParts()
                    self._preview:removeChild(self._armature, true)
                end

                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
                local n = string.gsub(path, "%.[%a%d]+$", "")
                local n = string.gsub(n,".+/","")
                local armature = ccs.Armature:create(n);
                armature:setAnchorPoint(0.5,0)
                armature:setPosition(amaturePt)
                self._preview:addChild(armature, LAYER_Z_ROLE)
                self._armature = armature
                self:showLabels(armature:getAnimation():getAnimationData())
            end
        end
    end

    local fileList = FileBrowseList.new(RES_ROOT,
        onFileSelected,
        {"ExportJson"},nil, rect.height)

    self:addChild(fileList);
    fileList:setPosition(rect.x, rect.y - rect.height)

    local preview = cc.Node:create();
    preview:setAnchorPoint(0,0)
    preview:setPosition(225,rect.y - previewSize.height)
    self:addChild(preview)
    self._preview = preview

    local listback = ccui.Scale9Sprite:create(cc.rect(3,3,26,26),"ui/win_back2.png")
    listback:setAnchorPoint(0,0)
    listback:setContentSize(previewSize)
    preview:addChild(listback,-999999999)  
    
    local partsback = ccui.Scale9Sprite:create(cc.rect(3,3,26,26),"ui/win_back2.png")
    partsback:setAnchorPoint(0,0)
    partsback:setPosition(370,0)
    partsback:setContentSize(cc.size(160,previewSize.height))
    partsback:setOpacity(100)
    preview:addChild(partsback,-999999999)
    
    local editPanel = EditPanel.new(handler(self,self.refresh))
    editPanel:setPosition(475,0)
    preview:addChild(editPanel,-999999999)
    self._editPanel = editPanel


    local function onCommitHandler(target)
        SpellsDataHelper.saveRolesMotionsData()
    end

    local commitBtn = CustomButton.new("保 存",onCommitHandler)
    commitBtn:setPosition(975,-558)
    self:addChild(commitBtn)
    
    self._labelBtns = {}
end

function RoleMotionEditWin:refresh()
    self:setMotion(self._currentMotion, true)
end

function RoleMotionEditWin:showLabels(animationData)
    self:removeLabels()
    
    local function onLabelClick(target)
        local motion = target:getTitleText()
        self:setMotion(motion)
    end
    
    local labelstr = custom.CustomArmatureHelper:getLabels(animationData)
    local labels = StringUtil.split(labelstr, "_=+")
    
    local sx = -10
    local sy = -20
    local column = 7
    for i, v in ipairs(labels) do
        if v ~= "" then
            local btn = CustomButton.new(v, onLabelClick)
            btn:setPosition(sx+btn:getContentSize().width/2 + (btn:getContentSize().width+3)*(math.fmod(i -1, column)),
                sy-btn:getContentSize().height/2 - (btn:getContentSize().height+10)*(math.floor((i-1)/column)))
            self._preview:addChild(btn);
            self._labelBtns[i] = btn;
        end
    end
    self:setMotion(labels[1])
end

function RoleMotionEditWin:setMotion(motion, editing)
    self._currentMotion = motion
    self._armature:getAnimation():play(motion, -1);
    self:clearParts();
    self:addParts();
    if not editing then
        self._editPanel:setData(self._editPath,motion)
    end
end
function RoleMotionEditWin:clearParts()
    for i, part in ipairs(self._parts) do
        self._preview:removeChild(part, true)
    end
    self._parts = {}
end

function RoleMotionEditWin:addParts()
    local partsData = RoleConfigModel.getPartsOfMotion(self._editPath,self._currentMotion)
    
    if partsData then
        for i, partData in ipairs(partsData) do
            local speed = partData.effectSpeed or 1
            local effect = SimpleEffect.new(partData.effect, true, speed)
            if partData.effectLevel == -1 then
                self._preview:addChild(effect, LAYER_Z_ROLE_BACK)
            else
                self._preview:addChild(effect, LAYER_Z_FRONT)
            end
            effect:setScale(partData.scale)
            local pt = cc.pAdd(amaturePt,cc.p(partData.x,partData.y))
            effect:setPosition(pt)
            
            table.insert(self._parts, effect)
        end
        
    end
end

function RoleMotionEditWin:removeLabels()
    for i, btn in ipairs(self._labelBtns) do
    	btn:getParent():removeChild(btn, true)
    end
    self._labelBtns = {}
end

return RoleMotionEditWin