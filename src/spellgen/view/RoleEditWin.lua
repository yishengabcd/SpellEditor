local RoleEditWin = class("RoleEditWin", require("components.BaseWindow"))

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

local amaturePt

function RoleEditWin:ctor(callback, type)
    local size = cc.size(600,500)
    RoleEditWin.super.ctor(self, size)
    local rect = self:getContentRect()

    self:setTitle("角色关键点编辑");

    local previewSize = cc.size(346,313)
    amaturePt = cc.p(previewSize.width/2,50)
    
    local function setPositionInArmature(node, pt)
        local pt = cc.pAdd(amaturePt,pt)
        node:setPosition(pt)
    end
    
    local function getPositionInArmature(node)
        local pt = cc.p(node:getPosition())
        pt = cc.pSub(pt,amaturePt)
        return pt
    end

    local function onFileSelected(item)
        local file = item:getFileData()
        if file.isDirectory == false then
            if file.extension == "ExportJson" then
                local path = file.relative .. "/" .. file.fileName;
                self._editPath = path
                
                if self._armature then
                    self._preview:removeChild(self._armature, true)
                end

                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
                local n = string.gsub(path, "%.[%a%d]+$", "")
                local n = string.gsub(n,".+/","")
                local armature = ccs.Armature:create(n);
                armature:setAnchorPoint(0.5,0)
                armature:setPosition(amaturePt)
                self._preview:addChild(armature, 0)
                armature:getAnimation():play(MotionType.PREPARE)
                self._armature = armature
                
                self._bottomCircle:setVisible(true)
                self._hitCircle:setVisible(true)
                self._topCircle:setVisible(true)
                
                local pt1,pt2,pt3 = RoleConfigModel.getKeyPositions(path)
                if pt1 == nil then
                    pt1 = cc.p(0,0)
                    pt2 = cc.p(0,armature:getContentSize().height/2)
                end
                if pt3 == nil then
                    pt3 = cc.p(0,armature:getContentSize().height)
                end
                setPositionInArmature(self._bottomCircle, pt1)
                setPositionInArmature(self._hitCircle, pt2)
                setPositionInArmature(self._topCircle,pt3)
                self._dustEditor:setValue(RoleConfigModel.getShowDustFlag(path))
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
    preview:addChild(listback)  
    
    local bottomCircle = DragableSprite.new("ui/bottomPoint.png")
    preview:addChild(bottomCircle,100)
    self._bottomCircle = bottomCircle
    bottomCircle:setVisible(false)
    
    local hitCircle = DragableSprite.new("ui/hitPoint.png")
    preview:addChild(hitCircle,100)
    self._hitCircle = hitCircle
    hitCircle:setVisible(false)
    
    local topCircle = DragableSprite.new("ui/topPoint.png")
    preview:addChild(topCircle,100)
    self._topCircle = topCircle
    topCircle:setVisible(false)


    local function onCommitHandler(target)
        if self._armature then
            local data = {}
            data[1] = getPositionInArmature(self._bottomCircle).x
            data[2] = getPositionInArmature(self._bottomCircle).y
            data[3] = getPositionInArmature(self._hitCircle).x
            data[4] = getPositionInArmature(self._hitCircle).y
            data[5] = getPositionInArmature(self._topCircle).x
            data[6] = getPositionInArmature(self._topCircle).y
            data["dustFlag"] =  tonumber(self._dustEditor:getValue()) or RoleConfigModel.getShowDustFlag(self._editPath)
            
            RoleConfigModel.getRolesPositions()[self._editPath] = data
            
            SpellsDataHelper.saveRolesData()
        end
    end
    local function onTextChanged(target)
    end
    
    local dustEditor = LabelValue.new("行走显示尘土(1是0非):", LabelValue.TYPE_EDIT,onTextChanged)
    dustEditor:setPosition(400, -380)
    self:addChild(dustEditor);
    self._dustEditor = dustEditor

    local commitBtn = CustomButton.new("保 存",onCommitHandler)
    commitBtn:setPosition(405,-438)
    self:addChild(commitBtn)

end

return RoleEditWin