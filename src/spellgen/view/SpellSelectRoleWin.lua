local SpellSelectRoleWin = class("SpellSelectRoleWin", require("components.BaseWindow"))

local FileBrowseList = require "components.FileBrowseList"
local CustomButton = require("components.CustomButton")
local Role = require("src/scene/battle/mode/Role")
local MotionType = require("src/scene/battle/mode/MotionType")
local RoleInfo = require("src/scene/battle/data/RoleInfo")
local LabelValue = require("spellgen.view.LabelValue")
local MotionSelector = require("spellgen.view.MotionSelector")


function SpellSelectRoleWin:ctor(callback, type)
    local size = cc.size(600,500)
    SpellSelectRoleWin.super.ctor(self, size)
    local rect = self:getContentRect()

    self:setTitle("角色选择");

    local previewSize = cc.size(346,313)

    local function onFileSelected(item)
        local file = item:getFileData()
        if file.isDirectory == false then
            if file.extension == "ExportJson" then
                self._selectFilePath = file.relative .. "/" .. file.fileName
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(self._selectFilePath)
                if not self._role then
                    local roleInfo = RoleInfo.new()
                    roleInfo.position = 5
                    roleInfo.indexId = 1000001
                    roleInfo.side = RoleInfo.SIDE_LEFT
                    roleInfo:setResPath(self._selectFilePath)

                    local role = Role.new(roleInfo)
                    role:setPosition(previewSize.width/2,50)
                    self._preview:addChild(role)
                    self._role = role
                end
                self._role:setArmature(self._selectFilePath)

                self._motionSelector:setRolePath(self._selectFilePath)

                local labelstr = custom.CustomArmatureHelper:getLabels(self._role:getArmature():getAnimation():getAnimationData())
                local labels = string.split(labelstr, "_=+")
                if self._currentMotion ~= labels[1] then
                    self._currentMotion = labels[1]
                elseif labels[2] then
                    self._currentMotion = labels[2]
                end
                self._role:executeMotion(self._currentMotion)
                self._motionSelector:setText(self._currentMotion)
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

    local callId = LabelValue.new("角色Id:", LabelValue.TYPE_EDIT,nil)
    callId:setPosition(preview:getPositionX()+30, preview:getPositionY() - 40)
    self:addChild(callId);
    self._callId = callId

    local function onMotionChange(target)
        self._role:executeMotion(target:getText())
    end

    local motionSelector = MotionSelector.new("动作:", onMotionChange)
    motionSelector:setPosition(callId:getPositionX()+215, callId:getPositionY())
    self:addChild(motionSelector);
    self._motionSelector = motionSelector



    local function onCommitHandler(target)
        if self._role == nil then
            Message.show("请选择角色")
            return
        end
        local callId = tostring(self._callId:getValue())
        if callId == nil or callId == "" then
            Message.show("请输入角色ID")
            return
        end

        local motion = self._motionSelector:getText()
        if motion == "" then
            Message.show("请选择默认动作")
            return
        end

        if callback then
            local data = {
                rolePath = self._selectFilePath,
                callId = callId,
                motion = motion
            }
            callback(data,type)
        end
        self:hide()
    end

    local commitBtn = CustomButton.new("确 定",onCommitHandler)
    commitBtn:setPosition(405,-438)
    self:addChild(commitBtn)
end

return SpellSelectRoleWin