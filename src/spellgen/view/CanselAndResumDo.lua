local CanselAndResum = require("src/spellgen/view/CanselAndResum")
local TimelinePanel = require("spellgen.view.TimelinePanel")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local FrameState = require("src/scene/battle/mode/FrameState")
local SpellGenTopBar = require("spellgen/view/SpellGenTopBar")
local EffectSelectWin = require("spellgen.view.EffectSelectWin")
local FrameActionDataBuilder = require("spellgen.helper.FrameActionDataBuilder")
local CanselAndResumDo =class("CanselAndResumDo", function () 
    return cc.Node:create()
end)

function CanselAndResumDo:ctor(_timeline,_topBar)
    local timeline = _timeline
    if timeline == nil then 
        return
    end
    local topBar = _topBar
    if topBar == nil then
        return  
    end
    local Menu = timeline.menu
    local EventMenuItems = topBar.EventMenuItems
    local function onCansel()
        local tv = {}
        tv =  CanselAndResum:GetCurrentEnum()
        if tv == nil then 
            return 
        end
       
        local label,line,frameIndex ,delenum ,action,targettype,keyframelen, coulm,totalnum= tv["type"],tv["line"],tv["frameindex"],tv["deletenumber"],
            tv["action"],tv["targettype"],tv["keyframelen"],tv["coulm"],tv["totalnum"]
           
        if label ==nil then
            return
        end
        if line == nil then
            return
        end
        local target = line:getFrames()[frameIndex]
        local preframeIndex = frameIndex -1
        if preframeIndex < 1 then
            preframeIndex = 1
        end
        if label == Menu.FRAME_SET_KEY_FRAME then
            line:getData():cancelKeyFrame(frameIndex)
            line:refreshFrames()
        elseif label == Menu.FRAME_SET_EMPTY_KEY_FRAME then
            line:getData():cancelKeyFrame(frameIndex)
            line:refreshFrames()
        elseif label == Menu.FRAEM_CANCEL_KEY_FRAME then
            line:getData():setKeyFrame(frameIndex, true)
            if action ~= nil then
                line:getData():addActionWithNoDeafult(frameIndex,action)
            else
                line:refreshFrames()
            end
            --line:refreshFrames()
            timeline:expansion(frameIndex)
        elseif label == Menu.FRAME_INSERT_FRAME then
            line:getData():deleteFrame(frameIndex)
            line:refreshFrames()
            timeline:setSelectedFrame(target)
        elseif label == Menu.FRAME_DELETE_FRAME then
            if targettype == FrameState.EMPTY_KEY_FRAME or targettype == FrameState.WEIGHT_KEY_FRAME then
                if keyframelen <= 1 then
                    line:getData():insertFrame(frameIndex-1)
                    line:getData():cancelKeyFrame(frameIndex)
                    line:getData():setKeyFrame(frameIndex, true)
                    CanselAndResum:ClearAllCansel()
                    if action ~= nil then
                        line:getData():addActionWithNoDeafult(frameIndex,action)
                    else
                        line:refreshFrames()
                    end
                else
                    line:getData():insertFrame(frameIndex)
                    line:refreshFrames()
                end
            else 
                line:getData():insertFrame(frameIndex)
                line:refreshFrames()
            end
            timeline:expansion(line:getData():getLastFrameIndex())
        elseif label == Menu.FRAME_INSERT_FRAME5 then
            line:getData():deleteFrame(frameIndex,5)
            line:refreshFrames()
            timeline:setSelectedFrame(target)
        elseif label == Menu.FRAME_DELETE_FRAME5 then
            if targettype == FrameState.EMPTY_KEY_FRAME or targettype == FrameState.WEIGHT_KEY_FRAME then
                if keyframelen <= delenum then
                    line:getData():insertFrame(frameIndex-1, delenum)
                    line:getData():cancelKeyFrame(frameIndex)
                    line:getData():setKeyFrame(frameIndex, true)
                    CanselAndResum:ClearAllCansel()
                    if action ~= nil then
                        line:getData():addActionWithNoDeafult(frameIndex,action)
                    else
                        line:refreshFrames()
                    end
                else
                    line:getData():insertFrame(frameIndex,delenum)
                    line:refreshFrames()
                end
            else 
                line:getData():insertFrame(frameIndex, delenum)
                line:refreshFrames()
            end
            timeline:expansion(line:getData():getLastFrameIndex())
        elseif label == Menu.FRAME_INSERT_COLUMN then
            timeline._spellData:deleteColumn(frameIndex, 1)
            timeline:refreshAllLayer()
            timeline:setSelectedFrame(target)
        elseif label == Menu.FRAME_INSERT_COLUMN5 then
            timeline._spellData:deleteColumn(frameIndex, 5)
            timeline:refreshAllLayer()
            timeline:setSelectedFrame(target)
        elseif label == Menu.FRAME_DELETE_COLUMN then
            timeline._spellData:insertColumn(frameIndex, 1)
            if coulm ~= nil or totalnum >0 then
                for i, layer in ipairs(timeline._spellData:getLayers()) do
                    for h=1,totalnum,1 do
                        local hd = coulm[h]["layernum"]
                        if i == coulm[h]["layernum"] then
                            layer:setKeyFrame(coulm[h]["linenum"],true)
                            layer:addActionWithNoDeafult(coulm[h]["linenum"],coulm[h]["frmaeaction"])
                        end
                    end
                end
            end
            timeline:refreshAllLayer()
            timeline:expansion(line:getData():getLastFrameIndex())
        elseif label == Menu.FRAME_DELETE_COLUMN5 then
            --删除关键帧还原时在编辑帧前面一帧操作
            timeline._spellData:insertColumn(frameIndex, 5)
            if coulm ~= nil or totalnum >0 then
              for i, layer in ipairs(timeline._spellData:getLayers()) do
                for h=1,totalnum,1 do
                  local hd = coulm[h]["layernum"]
                  if i == coulm[h]["layernum"] then
                   layer:setKeyFrame(coulm[h]["linenum"],true)
                    layer:addActionWithNoDeafult(coulm[h]["linenum"],coulm[h]["frmaeaction"])
                  end
                end
             end
            end
            timeline:refreshAllLayer()
            timeline:expansion(line:getData():getLastFrameIndex())
        end
        CanselAndResum:SetCurrentEnumResum(tv)
        BattleMgr.refresh()
    end 

    local function onResum()
        local tv = {}
        tv =  CanselAndResum:GetCurrentEnumResum()
        if tv == nil then 
            return 
        end
        local label,line,frameIndex ,deletnum = tv["type"],tv["line"],tv["frameindex"],tv["deletenumber"]
        if label ==nil then
            return
        end
        if line == nil then
            return
        end
        local target = line:getFrames()[frameIndex]
        local preframeIndex = frameIndex -1
        if preframeIndex < 1 then
            preframeIndex = 1
        end
        if label == Menu.FRAME_SET_KEY_FRAME then
            line:getData():setKeyFrame(frameIndex)
            line:refreshFrames()
            timeline:expansion(frameIndex)
        elseif label == Menu.FRAME_SET_EMPTY_KEY_FRAME then
            line:getData():setKeyFrame(frameIndex, true)
            line:refreshFrames()
            timeline:expansion(frameIndex)
        elseif label == Menu.FRAEM_CANCEL_KEY_FRAME then
            line:getData():cancelKeyFrame(frameIndex)
            line:refreshFrames()
        elseif label == Menu.FRAME_INSERT_FRAME then
            line:getData():insertFrame(frameIndex)
            line:refreshFrames()
            timeline:expansion(line:getData():getLastFrameIndex())
        elseif label == Menu.FRAME_DELETE_FRAME then
            line:getData():deleteFrame(frameIndex)
            line:refreshFrames()
            --TimelinePanel:setSelectedFrame(target)
        elseif label == Menu.FRAME_INSERT_FRAME5 then
            line:getData():insertFrame(frameIndex, 5)
            line:refreshFrames()
            timeline:expansion(line:getData():getLastFrameIndex())
        elseif label == Menu.FRAME_DELETE_FRAME5 then
            line:getData():deleteFrame(frameIndex,5)
            line:refreshFrames()
            --TimelinePanel:setSelectedFrame(target)
        elseif label == Menu.FRAME_INSERT_COLUMN then
            timeline._spellData:insertColumn(frameIndex, 1)
            timeline:refreshAllLayer()
            timeline:expansion(line:getData():getLastFrameIndex())
        elseif label == Menu.FRAME_INSERT_COLUMN5 then
            timeline._spellData:insertColumn(frameIndex, 5)
            timeline:refreshAllLayer()
            timeline:expansion(line:getData():getLastFrameIndex())
        elseif label == Menu.FRAME_DELETE_COLUMN then
            timeline._spellData:deleteColumn(frameIndex, 1)
            timeline:refreshAllLayer()
            --TimelinePanel:setSelectedFrame(target)
        elseif label == Menu.FRAME_DELETE_COLUMN5 then
            timeline._spellData:deleteColumn(frameIndex, 5)
            timeline:refreshAllLayer()
            --TimelinePanel:setSelectedFrame(target)
        end
        BattleMgr.refresh()
    end 
    ----------------- 事件添加操作撤销和还原----------------------------- 
    local function onCanselEvent()
        local tv = {}
        tv =  CanselAndResum:GetCurrentEnumEvent()
        if tv == nil then 
            return 
        end
        local label = tv["type"]
        if label == nil then
            return  
        end 

        local selectedLayer, frameIndex = EditorSpellModel.getSelectedFrame()
        if selectedLayer == nil then
            Message.show("请选择要在哪一帧添加")
            return
        end

        local keyFrame = selectedLayer:getKeyFrame(frameIndex)
        local keyframeIndex 
        local action
        if keyFrame ~= nil then
            keyframeIndex = keyFrame.index
            action = keyFrame.action
        else 
            return 
        end

        selectedLayer:cancelKeyFrame(keyframeIndex)
        selectedLayer:setKeyFrame(keyframeIndex,true)
        timeline:refreshAllLayer()
        CanselAndResum:SetCurrentEnumEventResum({["tv"]=tv,["action"]= action})
    end

    local function onResumEvent()
        local tv = {}
        tv =  CanselAndResum:GetCurrentEnumResumEvent()
        if tv == nil then 
            return 
        end

        local label ,action= tv["tv"]["type"],tv["action"]
        if label == nil or action == nil then
            return  
        end 

        local selectedLayer, frameIndex = EditorSpellModel.getSelectedFrame()
        if selectedLayer == nil then
            Message.show("请选择要在哪一帧添加")
            return
        end
        if selectedLayer:checkAddAction(frameIndex) == 1 then
            Message.show("该帧已经存在动作")
            return
        end

        local needRefresh = true
        if label == EventMenuItems.Finish or label == EventMenuItems.MoveBack or label == EventMenuItems.BlackScreen then
            needRefresh = false
        end
        selectedLayer:addAction(frameIndex, action)
        EventGlobal:dispatchEvent({name = "AddAction"})
        if needRefresh then
            BattleMgr.getBattle():refresh();
        end
    end
    -------------------------图层操作撤销还原-----------------------
    local function onCanselLayer()
        local tv = {}
        tv =  CanselAndResum:GetCurrentEnumLayer()
        if tv == nil then 
            return 
        end
        local lb ,index,layer=tv["type"],tv["index"],tv["layer"]
        if layer == nil or layer== nil then
            return 
        end
        if lb == "add" then
            if timeline._spellData then
                local _layer, _index = timeline._spellData:removeLayer(layer:getData())
                if _layer then
                    timeline:removeLayerByIndex(_index)
                    timeline._selectedLayer = nil
                    timeline:layoutLayers()
                end
            end
        elseif lb == "del" then 
            if timeline._spellData then
                local layerData ,inDex = timeline._spellData:insertLayerWithLayerdata(layer,index)
                --layerData = layer
                timeline:addLayer(layerData,inDex)
                timeline:refreshAllLayer()
                timeline:layoutLayers()
            end
        end
        CanselAndResum:SetCurrentEnumLayerResum(tv)
    end

    local function onResumLayer()
        local tv = {}
        tv =  CanselAndResum:GetCurrentEnumResumLayer()
        if tv == nil then 
            return 
        end
        local lb ,index,layer=tv["type"],tv["index"],tv["layer"]
        if lb == "add" then
            if timeline._spellData then
                local _layer, _index = timeline._spellData:insertLayer(index)
                if _layer then
                    timeline:addLayer(_layer,_index)
                    --timeline._selectedLayer = nil
                    timeline:layoutLayers()
                end
            end
        elseif lb == "del" then 
            if timeline._spellData then
                local layerData ,inDex = timeline._spellData:removeLayer(layer)
                timeline:removeLayerByIndex(index)
                timeline._selectedLayer = nil
                timeline:layoutLayers()
            end
        end 
    end

    local function onNodeEvent(event)
        if "exit" == event then
            CanselAndResum:removeEventListener(CanselAndResum.CANSEL,onCansel)
            CanselAndResum:removeEventListener(CanselAndResum.RESUM,onResum)
            CanselAndResum:removeEventListener(CanselAndResum.CANSELEVENT,onCanselEvent)
            CanselAndResum:removeEventListener(CanselAndResum.RESUMEVENT,onResumEvent)
            CanselAndResum:removeEventListener(CanselAndResum.CANSELLAYER,onCanselLayer)
            CanselAndResum:removeEventListener(CanselAndResum.RESUMLAYER,onResumLayer)
        end
    end
    CanselAndResum:addEventListener(CanselAndResum.CANSEL,onCansel)
    CanselAndResum:addEventListener(CanselAndResum.RESUM,onResum)
    CanselAndResum:addEventListener(CanselAndResum.CANSELEVENT,onCanselEvent)
    CanselAndResum:addEventListener(CanselAndResum.RESUMEVENT,onResumEvent)
    CanselAndResum:addEventListener(CanselAndResum.CANSELLAYER,onCanselLayer)
    CanselAndResum:addEventListener(CanselAndResum.RESUMLAYER,onResumLayer)
    self:registerScriptHandler(onNodeEvent)
end
return CanselAndResumDo