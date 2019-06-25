local EffectSelectWin = class("EffectSelectWin", require("components.BaseWindow"))

local FileBrowseList = require "components.FileBrowseList"
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")
local CustomButton = require("components.CustomButton")
local CoordSelector = require("spellgen.view.CoordSelector")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
local LabelValue = require("spellgen.view.LabelValue")

function EffectSelectWin:ctor(callback, type, motion)
    local size = cc.size(600,500)
    EffectSelectWin.super.ctor(self, size)
    local rect = self:getContentRect()
    
    local title = "添加特效"
    if type == FrameActionType.FLY_EFFECT then
        title = title .. "(飞行)"
    elseif type == FrameActionType.HURT then
        title = title .. "(受击)"
    elseif type == FrameActionType.MISSILE then
        title = title .. "(导弹)"
    elseif type == FrameActionType.REPLACE_BACKGROUND then
        title = title .. "(背景)"
    end
    if motion then
        title = "添加角色部件"
    end
    self:setTitle(title);
    
    local previewSize = cc.size(346,190)

    local function onFileSelected(item)
        local file = item:getFileData()
        if file.isDirectory == false then
            if file.extension == "plist" then
                
                if self._eff then
                    self._preview:removeChild(self._eff, true)
                end
                local name = string.gsub(file.relative .. "/" .. file.fileName, ".animate.plist", "")
                local eff = SimpleEffect.new(name, true)
                eff:setPosition(previewSize.width/2,previewSize.height/2)
                eff:setScale(0.3)
                self._preview:addChild(eff)
                self._eff = eff
                
                self._effNameTxt:setString(name)
                self._frameNumTxt:setString(eff:getFrameNum())
            end
        end
    end
    
    local fileList = FileBrowseList.new(RES_ROOT,
        onFileSelected,
        {"plist"},{"effect"},rect.height,{"animate.plist"})

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
    
    
    local effLabel = ccui.Text:create("特效名称：", "Airal", 14)
    effLabel:setAnchorPoint(1,0.5)
    effLabel:setColor(cc.c3b(220,220,220))
    effLabel:setPosition(preview:getPositionX()+100,preview:getPositionY() -30)
    self:addChild(effLabel)

    local effName = ccui.Text:create("", "Airal", 14)
    effName:setColor(cc.c3b(220,220,220))
    effName:setPosition(effLabel:getPositionX()+10,effLabel:getPositionY())
    effName:setAnchorPoint(0,0.5)
    self:addChild(effName)
    self._effNameTxt = effName
    
    local frameNumLabel = ccui.Text:create("帧数：", "Airal", 14)
    frameNumLabel:setColor(cc.c3b(220,220,220))
    frameNumLabel:setAnchorPoint(1,0.5)
    frameNumLabel:setPosition(effLabel:getPositionX(),effLabel:getPositionY() - 25)
    self:addChild(frameNumLabel)

    local frameNumTxt = ccui.Text:create("", "Airal", 14)
    frameNumTxt:setColor(cc.c3b(220,220,220))
    frameNumTxt:setPosition(frameNumLabel:getPositionX()+10,frameNumLabel:getPositionY())
    frameNumTxt:setAnchorPoint(0,0.5)
    self:addChild(frameNumTxt)
    self._frameNumTxt = frameNumTxt
    
    local coordLabel = ccui.Text:create("参考点：", "Airal", 14)
    coordLabel:setColor(cc.c3b(220,220,220))
    coordLabel:setAnchorPoint(1,0.5)
    coordLabel:setPosition(frameNumLabel:getPositionX(),frameNumLabel:getPositionY() - 35)
    self:addChild(coordLabel)
    
    local coordSelector = CoordSelector.new()
    coordSelector:setPosition(coordLabel:getPositionX() + 50,coordLabel:getPositionY())
    self:addChild(coordSelector)
    self._coordSelector = coordSelector
    
    if motion then
        local nameEditor = LabelValue.new("部件名称:", LabelValue.TYPE_EDIT,nil)
        nameEditor:setPosition(frameNumLabel:getPositionX(),frameNumLabel:getPositionY() - 30)
        self:addChild(nameEditor);
        nameEditor:setValue("部件")
        self._nameEditor = nameEditor
        
        coordSelector:setVisible(false)
        coordLabel:setVisible(false)
    end
    
    if type == FrameActionType.HURT then
        coordSelector:setText(CoordSelector.getStringByType(CoordSystemType.BEATTACK_POS))
    end
    
    local descLabel = ccui.Text:create("说明：\n1､受击可以不选择特效\n2､飞行特效不用在此选择参考点", "Airal", 14)
    descLabel:setColor(cc.c3b(220,220,220))
    descLabel:setAnchorPoint(1,0.5)
    descLabel:setPosition(frameNumLabel:getPositionX()+152,frameNumLabel:getPositionY() - 91)
    self:addChild(descLabel)
    
    
    local function onCommitHandler(target)
        if self._eff == nil and type ~= FrameActionType.HURT then
            Message.show("请选择要添加的特效")
            return
        end
        
        if callback then
            local frameNum = tonumber(self._frameNumTxt:getString())
            if frameNum == nil or frameNum < 1 then
                frameNum = 1
            end
            local data = {__defaultFrame = frameNum, 
                effect = self._effNameTxt:getString(),
                coord = self._coordSelector:getType()
            }
            if motion then
                data.name = self._nameEditor:getValue()
            end
            callback(data,type)
        end
        self:hide()
    end
    
    local commitBtn = CustomButton.new("确 定",onCommitHandler)
    commitBtn:setPosition(405,-438)
    self:addChild(commitBtn)
    
end


return EffectSelectWin