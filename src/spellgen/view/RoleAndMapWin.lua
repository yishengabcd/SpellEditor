local RoleAndMapWin = class("RoleAndMapWin", require("components.BaseWindow"))

local FileBrowseList = require "components.FileBrowseList"
local CustomButton = require("components.CustomButton")
local BattleSimulateModel = require("spellgen.model.BattleSimulateModel")
local Role = require("src/scene/battle/mode/Role")
local MotionType = require("src/scene/battle/mode/MotionType")
local EditorSpellModel = require("spellgen.model.EditorSpellModel")

function RoleAndMapWin:ctor(callback, type)
    local size = cc.size(600,500)
    RoleAndMapWin.super.ctor(self, size)
    local rect = self:getContentRect()

    self:setTitle("角色选择");

    local previewSize = cc.size(346,313)

    local function onFileSelected(item)
        local file = item:getFileData()
        if file.isDirectory == false then
            if file.extension == "ExportJson" then
                self._selectFilePath = file.relative .. "/" .. file.fileName
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(self._selectFilePath)
                self._role:setArmature(self._selectFilePath)
                self._role:executeMotion(MotionType.PREPARE)
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
    
    local role = Role.new(BattleSimulateModel.getPreviewRoleInfo())
    role:setPosition(previewSize.width/2,50)
    preview:addChild(role)
    self._role = role


    local function onCommitHandler(target)
        if self._selectFilePath then
            if target == self._changeLeftBtn then
                EditorSpellModel.changeLeftRole(self._selectFilePath)
            else 
                EditorSpellModel.changeRightRole(self._selectFilePath)
            end
        end
--        self:hide()
    end
    
    local changeLeftBtn = CustomButton.new("更换左边角色",onCommitHandler)
    changeLeftBtn:setPosition(325,-438)
    self:addChild(changeLeftBtn)
    self._changeLeftBtn = changeLeftBtn
    
    local changeRightBtn = CustomButton.new("更换右边角色",onCommitHandler)
    changeRightBtn:setPosition(485,-438)
    self:addChild(changeRightBtn)
    self._changeRightBtn = changeRightBtn

--    local commitBtn = CustomButton.new("确 定",onCommitHandler)
--    commitBtn:setPosition(405,-438)
--    self:addChild(commitBtn)

end

return RoleAndMapWin