local ImageButton = require("components.ImageButton")
local CustomButton = require("components.CustomButton")
local ContextMenu = require("components.ContextMenu")
local FrameState = require("src/scene/battle/mode/FrameState")
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local PreviewWindow = require("spellgen.view.PreviewWindow")
local CanselAndResum = require("src/spellgen/view/CanselAndResum")

local winSize = cc.Director:getInstance():getVisibleSize()
local TIMELINE_HEIGHT = 28 --每条时间轴的高度
local FRAME_WIDTH = 11 --每帧宽度

local timelineViewport = nil
local layerViewport = nil
local rulerViewport = nil

local MIN_FRAME_NUM = 72 --每条时间轴显示的最小帧数
local EXPANSION_FRAME_EACH_TIME = 50 --每次帧数不足时，需要扩展的帧数
local EXPANSION_CONDITION = 10 --扩展帧数的触发条件
local timelineFrameNum --时间轴上当前需要显示的帧的数量


local Menu = {
    FRAME_SET_KEY_FRAME = "设置为关键帧",
    FRAME_SET_EMPTY_KEY_FRAME = "设置为空白关键帧",
    FRAEM_CANCEL_KEY_FRAME = "取消关键帧",
    FRAEM_COPY = "复制帧",
    FRAEM_PASTE = "粘贴帧",
    FRAME_INSERT_FRAME = "插入帧",
    FRAME_DELETE_FRAME = "删除帧",
    FRAME_INSERT_FRAME5 = "插入5帧",
    FRAME_DELETE_FRAME5 = "删除5帧",
    FRAME_INSERT_COLUMN = "插入1列",
    FRAME_DELETE_COLUMN = "删除1列",
    FRAME_INSERT_COLUMN5 = "插入5列",
    FRAME_DELETE_COLUMN5 = "删除5列"
}

local TimelinePanel = class("TimelinePanel", function () 
    return cc.Node:create()
end)


---------------------------FrameView------------------------
local FrameView = class("FrameView", function () return cc.Node:create() end)

function FrameView:ctor(onClickHandler)
    self:setAnchorPoint(0,1)
    --self.menu=Menu
end

function FrameView:setType(type)
    if self._type == type then
        return
    end
    local path = "ui/timeline/frame_s".. type .. ".png"
    if self._sprite == nil then 
        local sp = cc.Sprite:createWithSpriteFrameName(path)
        sp:setAnchorPoint(0,1)
        self:addChild(sp, 1)
        self._sprite = sp;
    end
    self._sprite:setTexture(path)
    self._type = type
end

function FrameView:getType()
    return self._type
end

function FrameView:setSelected(value)
    if self._selected ~= value then
        self._selected = value
        if value then
            if self._selectedView == nil then
                local sp = cc.Sprite:create("ui/timeline/frame_selected.png")
                sp:setAnchorPoint(0,1)
                self:addChild(sp,100)
                self._selectedView = sp
            end
        else
            if self._selectedView then
                self:removeChild(self._selectedView,true)
                self._selectedView = nil
            end 
        end
    end
end

function FrameView:setColor(color)  
    self._sprite:setColor(color)
end


---------------------------SingleTimeline------------------------
local SingleTimeline = class("SingleTimeline", function () return cc.Node:create() end)

function SingleTimeline:ctor(data)
    self._data = data
    self:setAnchorPoint(0,1)
    self._frames = {}

    for i = 1, timelineFrameNum do
        self:addFrame(data:getFrameState(i))
    end

    self:layoutFrames()

    local function onDataChanged(event)
        self:refreshFrames()
    end

    data:addEventListener(Event.CHANGED, onDataChanged)
    local function onNodeEvent(event)
        if "exit" == event then
            self._data:removeEventListener(Event.CHANGED,onDataChanged)
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function SingleTimeline:addFrame(type, index)
    local frame = FrameView.new()
    frame:setType(type)
    self:addChild(frame)

    local pos = index or (#self._frames+1)
    table.insert(self._frames,pos,frame)
end

function SingleTimeline:layoutFrames()
    for i, frame in ipairs(self._frames) do
        frame:setPositionX((i-1)*FRAME_WIDTH)
    end

    self:setContentSize(cc.size(#self._frames * FRAME_WIDTH,0))
end

function SingleTimeline:expansion(count)
    for i = 1, count do
        self:addFrame(FrameState.NOTHINE)
    end
    self:layoutFrames();
end

function SingleTimeline:refreshFrames()
    for i, v in ipairs(self._frames) do
        v:setType(self._data:getFrameState(i))
    end
end

function SingleTimeline:getData()
    return self._data
end

function SingleTimeline:getFrames()
    return self._frames
end


---------------------------LayerView------------------------

local LayerView = class("LayerView",function () 
    return cc.Node:create() 
end)

LayerView.HEIGHT = 28
LayerView.WIDTH = 153

function LayerView:ctor(layerData)
    self._layerData = layerData;
    self:setSelected(false)
    self:setAnchorPoint(0, 1)

    local nameTxt = ccui.Text:create(layerData.layerName,"Airal",14)
    nameTxt:setPosition(40,-TIMELINE_HEIGHT/2)
    self:addChild(nameTxt,1)
    self._nameTxt = nameTxt
    self._nameTxt:setString(self._layerData.layerName)
end

function LayerView:refreshLayerName()
    self._nameTxt:setString(self._layerData.layerName)
end

function LayerView:setSelected(value)
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
        back:setAnchorPoint(0,1)
        self:addChild(back)
        self._back = back
    end
end
function LayerView:getData()
    return self._layerData
end


---------------------------FrameCopyPasteControl------------------------
local FrameCopyPasteControl = {}

function FrameCopyPasteControl:setup(timeline)
    self._timeline = timeline
end

function FrameCopyPasteControl:copy(lineIdx, startFrameIndex, endFrameIndex,lineCount)
    self._cacheLayers = {}
    self._cacheLayers.length = endFrameIndex - startFrameIndex + 1
    local lineCount = lineCount or 1
    
    local startLine = #self._timeline._lines - lineIdx
    for i = startLine, startLine - lineCount + 1, -1 do
        local line = self._timeline._lines[i]
        if line then
            local layerData = line:getData()
            local newLayer = {}
            local allFrames = layerData:getFrames()
            for j = startFrameIndex, endFrameIndex do
                for _, frame in ipairs(allFrames) do
                	if frame.index == j and (frame.type == FrameState.EMPTY_KEY_FRAME or frame.type == FrameState.WEIGHT_KEY_FRAME) then
                	   local newFrame = table.deepcopy(frame)
                        newFrame.index = j - startFrameIndex + 1
                        table.insert(newLayer, newFrame)
                        break
                	end
                end
            end
            local st = layerData:getFrameState(startFrameIndex)
            if st == FrameState.EMPTY_LAST_FRAME 
                or st == FrameState.WEIGHT_LAST_FRAME
                or st == FrameState.EMPTY_END_FRAME
                or st == FrameState.WEIGHT_END_FRAME
            then
                local frame = layerData:getKeyFrame(startFrameIndex)
                local newFrame = table.deepcopy(frame)
                newFrame.index = 1
                table.insert(newLayer, newFrame)
            elseif st == FrameState.NOTHINE then
                local newFrame = {index=1, type=FrameState.EMPTY_KEY_FRAME}
                newFrame.index = 1
                table.insert(newLayer, newFrame)
            end
            self._cacheLayers[#self._cacheLayers + 1] = newLayer
        end
    end
end


function FrameCopyPasteControl:paste(layerIndex, startFrameIndex)
    if self._timeline and self._timeline._spellData and self._cacheLayers then
        local newLayers = self._timeline._spellData:replaceFrames(#self._timeline._lines - layerIndex, startFrameIndex, table.deepcopy(self._cacheLayers))
        if #newLayers > 0 then
            for _, mem in ipairs(newLayers) do
                self._timeline:addLayer(mem.layer, mem.layerIndex)
            end
            self._timeline:layoutLayers()
        end
    end
end

---------------------------TimelinePanel------------------------
function TimelinePanel:ctor()
    self.menu=Menu
    local back = ccui.Scale9Sprite:create(cc.rect(190,35,135,105),"ui/timeline/back.png")
    back:setAnchorPoint(0,0)
    self:addChild(back, -10000)
    back:setContentSize(cc.size(winSize.width,back:getContentSize().height+winSize.height-680))

    --timelines
    timelineViewport = cc.rect(158,15,winSize.width-158 - 20,110+winSize.height-680)

    local function scrollView2DidScroll()
        if self._mouseDown then
            self._scrolling = true
        end
        local y = self._scrollViewLines:getContainer():getPositionY()
        self._scrollViewLayers:getContainer():setPositionY(y)

        local x = self._scrollViewLines:getContainer():getPositionX()
        self._scrollViewRuler:getContainer():setPositionX(x)
    end
    local function scrollView2DidZoom()
    end


    self._lines = {}
    local scrollViewLines = CustomScrollView.new(cc.size(timelineViewport.width,timelineViewport.height), cc.SCROLLVIEW_DIRECTION_BOTH)
    scrollViewLines:registerScriptHandler(scrollView2DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    scrollViewLines:registerScriptHandler(scrollView2DidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)    
    self._scrollViewLines = scrollViewLines
    self:addChild(scrollViewLines,1)
    scrollViewLines:setPosition(timelineViewport.x,timelineViewport.y)


    --layers

    local function layersScroll()
        local y = self._scrollViewLayers:getContainer():getPositionY()
        self._scrollViewLines:getContainer():setPositionY(y)
    end

    layerViewport = cc.rect(1, 15, 153,110+winSize.height-680)
    self._layers = {}
    local scrollViewLayers = CustomScrollView.new(cc.size(layerViewport.width,layerViewport.height))
    scrollViewLayers:registerScriptHandler(layersScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._scrollViewLayers = scrollViewLayers
    self:addChild(scrollViewLayers,1)
    scrollViewLayers:setPosition(layerViewport.x,layerViewport.y)

    --ruler

    self._rulerMarks = {}
    local function rulerScroll()
        local x = self._scrollViewRuler:getContainer():getPositionX()
        self._scrollViewLines:getContainer():setPositionX(x)
    end

    rulerViewport = cc.rect(timelineViewport.x, timelineViewport.y+timelineViewport.height, timelineViewport.width,24)
    local scrollViewRuler = CustomScrollView.new(cc.size(rulerViewport.width,rulerViewport.height), cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    scrollViewRuler:registerScriptHandler(rulerScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._scrollViewRuler = scrollViewRuler
    self:addChild(scrollViewRuler,1)
    scrollViewRuler:setPosition(rulerViewport.x,rulerViewport.y)

    local cursor = cc.Sprite:create("ui/timeline/cursor.png")
    scrollViewRuler:addChild(cursor, 1)
    cursor:setPositionY(-10)
    cursor:setPositionX(5)
    self._cursor = cursor

    local function onMouseDown(touch, event)
        if not self._spellData then
            return false
        end
        self._mouseDown = true
        return true
    end    
    local function onMouseUp(touch, event)
        if not self._spellData then
            return
        end
        if self._scrolling == false then
            local location = touch:getLocation()
            local pt = self:convertToNodeSpace(location)
            if cc.rectContainsPoint(timelineViewport, pt) then
                self:onFrameClick(pt, 0)
            else
                if cc.rectContainsPoint(layerViewport, pt) then
                    self:onLayerPanelClick(pt)
                end
            end
        end
        self._mouseDown = false
        self._scrolling = false
    end 

    local listener2 = cc.EventListenerTouchOneByOne:create()
    listener2:registerScriptHandler(onMouseDown,cc.Handler.EVENT_TOUCH_BEGAN)
    listener2:registerScriptHandler(onMouseUp,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener2, self)

    local function onMouseRightButtonUp(event)
        if not self._spellData then
            return
        end
        if self._scrolling == false then
            local pt = cc.p(event:getCursorX(), event:getCursorY())
            if cc.rectContainsPoint(timelineViewport, pt) then
                if event:getMouseButton() == 1 then
                    self:onFrameClick(pt, 1)
                end
            end
        end
    end 

    local listener3 = cc.EventListenerMouse:create()
    listener3:registerScriptHandler(onMouseRightButtonUp,cc.Handler.EVENT_MOUSE_UP)
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener3, self)
    
    local function onKeyPressed(keyCode, event)
        if self._selectedFrame and (keyCode == 12 or keyCode == 13) then
            self._shiftPressed = true
        end
    end

    local function onKeyReleased(keyCode, event)
        if not self._selectedFrame or not self._frameControlFunc then return end
        if keyCode == 89 then
            self._frameControlFunc(Menu.FRAME_INSERT_FRAME)
        elseif keyCode == 73 then
            self._frameControlFunc(Menu.FRAME_DELETE_FRAME)
        elseif keyCode == 116 then --"["
            self._frameControlFunc(Menu.FRAME_DELETE_COLUMN)
        elseif keyCode == 118 then --"]"
            self._frameControlFunc(Menu.FRAME_INSERT_COLUMN)
        elseif keyCode == 12 or keyCode == 13 then
            self._shiftPressed = false
        end
    end
    local keyListener = cc.EventListenerKeyboard:create()
    keyListener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    keyListener:registerScriptHandler(onKeyReleased,cc.Handler.EVENT_KEYBOARD_RELEASED)
    eventDispatcher:addEventListenerWithSceneGraphPriority(keyListener, self)

    --图层操作按钮

    local addLayerBtn = ImageButton.new("ui/timeline/add_layer.png", function (target)
        if self._spellData then
            local insertIdx = #self._spellData:getLayers() + 1
            if self._selectedLayer then
                insertIdx = self._spellData:getIndexOfLayer(self._selectedLayer:getData())
                insertIdx = insertIdx+1
            end
            local index,layer = self:addLayer(self._spellData:insertLayer(insertIdx))
            self:layoutLayers()
            --操作图层时清空事件和时间轴撤销还原表
            CanselAndResum:ClearAllCanselEvent()
            CanselAndResum:ClearAllResumEvent()
            CanselAndResum:ClearAllCansel()
            CanselAndResum:ClearAllResum()
            CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.LAYERTYPE)
            CanselAndResum:SetCurrentEnumLayer({["type"]="add",["index"]=index,["layer"]=layer})
        end
    end)
    addLayerBtn:setPosition(100,8)
    self:addChild(addLayerBtn)

    local delLayerBtn = ImageButton.new("ui/timeline/del_layer.png", function (target)
        if self._spellData then
            if self._selectedLayer then
                local layer, index = self._spellData:removeLayer(self._selectedLayer:getData())
                if layer then
                    self:removeLayerByIndex(index)
                    self._selectedLayer = nil
                    self:layoutLayers()
                    CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.LAYERTYPE)
                    CanselAndResum:SetCurrentEnumLayer({["type"]="del",["index"]=index,["layer"]=layer})
                end
            end
        end
        CanselAndResum:ClearAllCanselEvent()
        CanselAndResum:ClearAllResumEvent()
        CanselAndResum:ClearAllCansel()
        CanselAndResum:ClearAllResum()
        CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.LAYERTYPE)
    end)
    delLayerBtn:setPosition(130,8)
    self:addChild(delLayerBtn)

    local function onRenameTextChanged(target)
        if self._selectedLayer then
            self._selectedLayer:getData().layerName = target:getText()
            self._selectedLayer:refreshLayerName()
        end
    end
    local input = TextInput.new(cc.size(80,14), onRenameTextChanged, 100, 10)
    input:setAnchorPoint(0,0.5)
    input:setPosition(45,8)
    self:addChild(input)
    self._renameInput = input

    self._scrolling = false
    self._mouseDown = false
end


function TimelinePanel:setEditSpell(spell)
    self._spellData = spell
    FrameCopyPasteControl:setup(self)
    self:reset()

    timelineFrameNum = self._spellData:getMaxFrameLength() + 20
    if timelineFrameNum < MIN_FRAME_NUM then
        timelineFrameNum = MIN_FRAME_NUM
    end

    local layers = spell:getLayers()
    for i, v in ipairs(layers) do
        self:addLayer(v)
    end

    self:layoutLayers()
end

function TimelinePanel:selectMultipleFrames(startLine, startFrame, endLine, endFrame)
    self:canceMultipFrames()
    self._selectRect = {startLine=startLine, startFrame=startFrame, endLine=endLine, endFrame=endFrame}
    self._selectedFrames = {}
    
    for i = startLine, endLine do
        local line = self._lines[#self._lines - i]
        for j = startFrame, endFrame do
            local frame = line:getFrames()[j]
            self._selectedFrames[#self._selectedFrames + 1] = frame
            frame:setColor(cc.c3b(200,100,100))
        end
    end
end

function TimelinePanel:isInSelectedRect(lineIdx, frameIndex)
    if self._selectRect then
        if lineIdx >= self._selectRect.startLine and lineIdx <= self._selectRect.endLine then
            if frameIndex >= self._selectRect.startFrame and frameIndex <= self._selectRect.endFrame then
                return true
            end 
        end
    end
    return false
end

function TimelinePanel:canceMultipFrames()
    self._selectRect = nil
    if self._selectedFrames then
        for _, frame in ipairs(self._selectedFrames) do
            frame:setColor(cc.c3b(255,255,255))
        end
    end
    self._selectedFrames = nil
end

--点击某一帧时的处理
function TimelinePanel:onFrameClick(pt, mouseType)
    local layerPt = self._scrollViewLines:getRealContainer():convertToNodeSpace(pt)
    local lineIdx = math.floor(-layerPt.y/TIMELINE_HEIGHT)
    local line = self._lines[#self._lines - lineIdx]
    local target
    local targettype
    local action
    local deletnum =1
    local frameIndex
    local preframeIndex
    local keyframelen = 0
    local totalnum =0--记录删除列的时候删除的关键帧数量
    local coulm={}--删除列时被删除的关键帧参数记录
    CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.TIMELINETYPE)
    --点击时间轴清空图层添加撤销还原表
    CanselAndResum:ClearAllCanselLayer()
    CanselAndResum:ClearAllResumLayer()
    --CanselAndResum:SetCurrentEnumType({["spelldata"]=self._spellData})
    if line then
        local linePt = line:convertToNodeSpace(pt)
        frameIndex = math.floor(linePt.x/FRAME_WIDTH) + 1
        local frames = line:getFrames()
        target = line:getFrames()[frameIndex]
        if target == nil then
            return
        elseif target ~= nil then 
            targettype = target:getType()
        end
        local lineData = line:getData()
        if lineData ~= nil then
            if lineData:getKeyFrame(frameIndex) ~= nil and lineData:getKeyFrame(frameIndex).action ~= nil then
                action =lineData:getKeyFrame(frameIndex).action
                keyframelen = line:getData():getKeyFrameLength(line:getData():getKeyFrame(frameIndex))
            end
        end
        preframeIndex = frameIndex -1
        if targettype == FrameState.WEIGHT_KEY_FRAME or targettype == FrameState.EMPTY_KEY_FRAME then
            preframeIndex = frameIndex
            if preframeIndex < 1 then
                preframeIndex =1
            end
        end
        for i =frameIndex+1,#frames,1 do
            local nexttarget = frames[i]
            if nexttarget == nil then break end
            local nexttartype = nexttarget:getType()
            if nexttartype ~= FrameState.WEIGHT_KEY_FRAME and nexttartype ~= FrameState.EMPTY_KEY_FRAME then
                deletnum = deletnum+1
                if deletnum >5 then
                    deletnum = 5
                end
            else break
            end
        end

        local delcoulmnumber = frameIndex +4
        if delcoulmnumber > #frames then
            delcoulmnumber = #frames
        end
        for i, layer in ipairs(self._spellData:getLayers()) do
            for j=frameIndex ,delcoulmnumber ,1 do
                if layer:getFrameState(j) == FrameState.WEIGHT_KEY_FRAME or layer:getFrameState(j) == FrameState.EMPTY_KEY_FRAME then
                    -----每一层的处理
                    local layerkeyframe = layer:getKeyFrame(j)
                    local frameaction
                    if (layerkeyframe ~= nil) then
                        frameaction = layerkeyframe.action 
                    end
                    local framelen = layer:getKeyFrameLength(layerkeyframe)
                    local abc = framelen+j-frameIndex
                    if  abc <6 then
                        totalnum = totalnum+1
                        local coulmnum ={["layernum"]=i,["linenum"]= j,["frmaeaction"]=frameaction}
                        table.insert(coulm,coulmnum)
                    end
                end
            end
        end
    end

    local function onMenuClick(label)
        if label == Menu.FRAME_SET_KEY_FRAME then
            line:getData():setKeyFrame(frameIndex)
            line:refreshFrames()
            self:expansion(frameIndex)
            CanselAndResum:SetCurrentEnumType({["type"]=Menu.FRAME_SET_KEY_FRAME,["line"]=line,["frameindex"]=frameIndex,
                ["deletenumber"]=0,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_SET_EMPTY_KEY_FRAME then
            line:getData():setKeyFrame(frameIndex, true)
            line:refreshFrames()
            self:expansion(frameIndex)
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAME_SET_EMPTY_KEY_FRAME,["line"]=line,["frameindex"]=frameIndex,
                ["deletenumber"]=0,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAEM_CANCEL_KEY_FRAME then
            line:getData():cancelKeyFrame(frameIndex)
            line:refreshFrames()
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAEM_CANCEL_KEY_FRAME,["line"]=line,["frameindex"]=frameIndex,
                ["deletenumber"]=0,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_INSERT_FRAME then
            line:getData():insertFrame(frameIndex)
            line:refreshFrames()
            self:expansion(line:getData():getLastFrameIndex())
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAME_INSERT_FRAME,["line"]=line,["frameindex"]=frameIndex,
                ["deletenumber"]=0,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_DELETE_FRAME then
            line:getData():deleteFrame(frameIndex)
            line:refreshFrames()
            self:setSelectedFrame(target,line:getData(), frameIndex, lineIdx)
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAME_DELETE_FRAME,["line"]=line,["frameindex"]=preframeIndex,
                ["deletenumber"]=1,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_INSERT_FRAME5 then
            line:getData():insertFrame(frameIndex, 5)
            line:refreshFrames()
            self:expansion(line:getData():getLastFrameIndex())
            CanselAndResum:SetCurrentEnumType( { ["type"]=Menu.FRAME_INSERT_FRAME5,["line"]=line,["frameindex"]=frameIndex,
                ["deletenumber"]=0,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_DELETE_FRAME5 then
            line:getData():deleteFrame(frameIndex,5)
            line:refreshFrames()
            self:setSelectedFrame(target,line:getData(), frameIndex, lineIdx)
            CanselAndResum:SetCurrentEnumType({ ["type"]=Menu.FRAME_DELETE_FRAME5,["line"]=line,["frameindex"]=preframeIndex,
                ["deletenumber"]=deletnum,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_INSERT_COLUMN then
            self._spellData:insertColumn(frameIndex, 1)
            self:refreshAllLayer()
            self:expansion(line:getData():getLastFrameIndex())
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAME_INSERT_COLUMN,["line"]=line,["frameindex"]=frameIndex,
                ["deletenumber"]=0,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_INSERT_COLUMN5 then
            self._spellData:insertColumn(frameIndex, 5)
            self:refreshAllLayer()
            self:expansion(line:getData():getLastFrameIndex())
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAME_INSERT_COLUMN5,["line"]=line,["frameindex"]=frameIndex,
                ["deletenumber"]=0,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] =nil,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_DELETE_COLUMN then
            self._spellData:deleteColumn(frameIndex, 1)
            self:refreshAllLayer()
            self:setSelectedFrame(target,line:getData(), frameIndex, lineIdx)
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAME_DELETE_COLUMN,["line"]=line,["frameindex"]=preframeIndex,
                ["deletenumber"]=1,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] = coulm,["totalnum"]=totalnum})
        elseif label == Menu.FRAME_DELETE_COLUMN5 then
            self._spellData:deleteColumn(frameIndex, 5)
            self:refreshAllLayer()
            self:setSelectedFrame(target,line:getData(), frameIndex, lineIdx)
            CanselAndResum:SetCurrentEnumType( {["type"]=Menu.FRAME_DELETE_COLUMN5,["line"]=line,["frameindex"]=preframeIndex,
                ["deletenumber"]=deletnum,["action"]=action,["targettype"]=targettype,["keyframelen"]=keyframelen,["coulm"] = coulm,["totalnum"]=totalnum})
        elseif label == Menu.FRAEM_COPY then
            if self:isInSelectedRect(lineIdx, frameIndex) then
                FrameCopyPasteControl:copy(self._selectRect.startLine,self._selectRect.startFrame,self._selectRect.endFrame,self._selectRect.endLine - self._selectRect.startLine + 1)
            else
                FrameCopyPasteControl:copy(lineIdx,frameIndex,frameIndex,1)
            end
            
        elseif label == Menu.FRAEM_PASTE then
            FrameCopyPasteControl:paste(lineIdx,frameIndex)
            self:refreshAllLayer()
        end
        BattleMgr.refresh()
    end

    self._frameControlFunc = onMenuClick;
    --撤销后有点击时间轴操作则无法还原到撤销前
    CanselAndResum:ClearAllResum()
    local menus = {}
    --local type = target:getType()
    table.insert(menus,Menu.FRAME_DELETE_COLUMN5)
    table.insert(menus,Menu.FRAME_DELETE_COLUMN)

    table.insert(menus,Menu.FRAME_INSERT_COLUMN5)
    table.insert(menus,Menu.FRAME_INSERT_COLUMN)

    if targettype ~= FrameState.NOTHINE then
        table.insert(menus,Menu.FRAME_DELETE_FRAME5)
        table.insert(menus,Menu.FRAME_DELETE_FRAME)
    end
    table.insert(menus,Menu.FRAME_INSERT_FRAME5)
    table.insert(menus,Menu.FRAME_INSERT_FRAME)
    table.insert(menus,Menu.FRAEM_COPY)
    table.insert(menus,Menu.FRAEM_PASTE)

    if targettype == FrameState.WEIGHT_KEY_FRAME or targettype == FrameState.EMPTY_KEY_FRAME then
        table.insert(menus,Menu.FRAEM_CANCEL_KEY_FRAME)
    else
        --        table.insert(menus,Menu.FRAME_SET_KEY_FRAME)
        table.insert(menus,Menu.FRAME_SET_EMPTY_KEY_FRAME)
    end

    self._cursor:setPositionX(frameIndex*FRAME_WIDTH - FRAME_WIDTH/2)

    if mouseType == 1 then --右键
        ContextMenu.showMenu(menus,onMenuClick,target)
    end
    if self._shiftPressed and self._selectedFrame and self._selectedLineIdx and self._selectedFrameIndex then
        if not self:isInSelectedRect(lineIdx, frameIndex) then
            self:selectMultipleFrames(self._selectedLineIdx,self._selectedFrameIndex,lineIdx,frameIndex)
        end
    else
        if not self:isInSelectedRect(lineIdx, frameIndex) then
            self:canceMultipFrames()
        end
    end
    self:setSelectedFrame(target, line:getData(), frameIndex, lineIdx)
end

--刷新所有图层的帧的状态
function TimelinePanel:refreshAllLayer()
    for i, line in ipairs(self._lines) do
        line:refreshFrames()
    end
end

function TimelinePanel:setSelectedFrame(frame, layer, frameIndex, lineIdx)
    if self._selectedFrame and self._selectedFrame ~= frame then
        self._selectedFrame:setSelected(false)
    end

    self._selectedFrame = frame
    self._selectedLineIdx = lineIdx
    self._selectedFrameIndex = frameIndex

    if self._selectedFrame then
        self._selectedFrame:setSelected(true)
    end

    EditorSpellModel.setSelectedFrame(layer,frameIndex)
end

function TimelinePanel:cancelSelectFrames()
    if self._selectedFrame then
        self._selectedFrame:setSelected(false)
        self._selectedFrame = nil
    end
end

function TimelinePanel:onLayerPanelClick(pt)
    local layerPt = self._scrollViewLayers:getRealContainer():convertToNodeSpace(pt)
    local lineIdx = math.floor(-layerPt.y/TIMELINE_HEIGHT)
    local layer = self._layers[#self._layers - lineIdx]
    --把撤销还原当前操作模块设置为图层
    CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.LAYERTYPE)
    if layer then
        if self._selectedLayer ~= layer then
            if self._selectedLayer then
                self._selectedLayer:setSelected(false)
            end
            self._selectedLayer = nil
            self._renameInput:setText(layer:getData().layerName)
            self._selectedLayer = layer
            self._selectedLayer:setSelected(true)
        end
    end
end

function TimelinePanel:addLayer(data,index)
    local index = index or (#self._lines + 1)
    local line = SingleTimeline.new(data)
    self._scrollViewLines:addChild(line)
    table.insert(self._lines,index,line)

    local layer = LayerView.new(data)
    self._scrollViewLayers:addChild(layer)
    table.insert(self._layers, index, layer)
    CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.LAYERTYPE)
    return index,layer
end

function TimelinePanel:removeLayerByIndex(index)
    self:setSelectedFrame(nil)
    local line = table.remove(self._lines, index)
    self._scrollViewLines:removeChild(line, true)

    local layer = table.remove(self._layers, index)
    self._scrollViewLayers:removeChild(layer, true)
    CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.LAYERTYPE)
    --CanselAndResum:SetCurrentEnumLayer({["type"]="del",["index"]=index,["layer"]=layer})
end

function TimelinePanel:layoutLayers()
    local height = 0
    for i, line in ipairs(self._lines) do
        line:setPosition(0, -TIMELINE_HEIGHT*(#self._lines - i + 1)+TIMELINE_HEIGHT)
        height  = height + TIMELINE_HEIGHT
    end

    local width = timelineFrameNum*FRAME_WIDTH
    for i, layer in ipairs(self._layers) do
        layer:setPosition(0, -TIMELINE_HEIGHT*(#self._layers - i + 1)+TIMELINE_HEIGHT)
    end

    self._scrollViewLines:updateView(cc.size(width,height))
    self._scrollViewLayers:updateView(cc.size(LayerView.WIDTH,height))
    self._scrollViewRuler:updateView(cc.size(width, rulerViewport.height))

    self:refreshRulerView()
end
--扩展时间轴的长度
function TimelinePanel:expansion(frameIndex)
    if timelineFrameNum - frameIndex <  EXPANSION_CONDITION then
        for i, line in ipairs(self._lines) do
            line:expansion(EXPANSION_FRAME_EACH_TIME)
        end
        timelineFrameNum = timelineFrameNum + EXPANSION_FRAME_EACH_TIME
        self:layoutLayers()
    end

end

function TimelinePanel:refreshRulerView()
    local startIdx = #self._rulerMarks/2 + 1
    local endIdx = math.floor(timelineFrameNum/10)

    for i = startIdx, endIdx do
        local text = ccui.Text:create(i*10, "Airal",11)
        local posX = i * FRAME_WIDTH * 10 - FRAME_WIDTH/2
        text:setPositionX(posX)
        text:setPositionY(-8)
        self._scrollViewRuler:addChild(text)
        table.insert(self._rulerMarks, text)

        local sp = cc.Sprite:createWithSpriteFrameName("ui/timeline/mark.png")
        sp:setPositionX(posX)
        sp:setPositionY(-18)
        sp:setAnchorPoint(1,0.5)
        self._scrollViewRuler:addChild(sp)
        table.insert(self._rulerMarks, sp)
    end
end

function TimelinePanel:reset()
    for i, line in ipairs(self._lines) do
        line:removeFromParent(true)
    end
    for i, layer in ipairs(self._layers) do
        layer:removeFromParent(true)
    end

    if self._rulerMarks then
        for i, v  in ipairs(self._rulerMarks) do
            v:removeFromParent(true)
        end
    end
    self._lines = {}
    self._layers = {}
    self._selectedLayer = nil
    self._rulerMarks = {}
    self._cursor:setPositionX(FRAME_WIDTH/2)
    self._scrolling = false
    self._mouseDown = false
    self._selectedFrame = nil
    self._frameControlFunc = nil
    self._selectRect = nil
    self._selectedFrames = nil
    self._shiftPressed = false
end

return TimelinePanel