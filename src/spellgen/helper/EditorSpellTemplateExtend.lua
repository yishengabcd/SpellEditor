--用于扩展技能数据表的功能,增加方法和辅助字段，以方便重用及适应编辑器需求等
--这里定义的方法或属性是针对编辑器的，不专属于编辑器的功能需要在SpellTemplateExtend类里添回
local EditorSpellTemplateExtend = {}
local LayerExtend = {}

local FrameState = require("src/scene/battle/mode/FrameState")
local SpellTemplateExtend = require("scene/battle/mode/SpellTemplateExtend")
local EventProtocol = require("src/utils/EventProtocol")

function EditorSpellTemplateExtend.extend(spellData)

    --增加图层，index为nil时，添加图层到最后
    function spellData:insertLayer(index)
        if self.layers == nil then
            self.layers = {}
        end
        local layer = {layerName = self:getNextLayerName()}
        SpellTemplateExtend.LayerExtend.extend(layer,spellData)
        LayerExtend.extend(layer,spellData)
        local len = #self.layers
        local index = index or len
        if index > len + 1 then
            index = len + 1
        end
        table.insert(self.layers,index,layer)
        return layer, index
    end
    --用已有图层数据增加
    function spellData:insertLayerWithLayerdata(layerdata,index)
        if self.layers == nil then
            self.layers = {}
        end
        --local layer = {layerName = self:getNextLayerName()}
        local layer = layerdata
        SpellTemplateExtend.LayerExtend.extend(layer,spellData)
        LayerExtend.extend(layer,spellData)
        local len = #self.layers
        local index = index or len
        if index > len + 1 then
            index = len + 1
        end
        table.insert(self.layers,index,layer)
        return layer, index
    end

    function spellData:removeLayer(layer)
        if self.layers then
            for i, v in ipairs(self.layers) do
                if v == layer then
                    layer:removeAllEventListeners()
                    return table.remove(self.layers,i), i
                end
            end
        end
        return nil
    end


    function spellData:getNextLayerName()
        if self.layerIndex == nil then
            self.layerIndex = 1
        else
            self.layerIndex = self.layerIndex + 1
        end
        return "图层" .. self.layerIndex
    end
    --在指定位置将所有图层插入指定帧数
    function spellData:insertColumn(index, count)
        local count = count or 1
        for i, layer in ipairs(self:getLayers()) do
            if layer:getFrameState(index) ~= FrameState.NOTHINE then
                layer:insertFrame(index, count)
            end
        end
    end
    --在指定位置将所有图层删除指定帧数
    function spellData:deleteColumn(index, count)
        local count = count or 1
        for i, layer in ipairs(self:getLayers()) do
            if layer:getFrameState(index) ~= FrameState.NOTHINE then
                layer:deleteFrame(index, count)
            end
        end
    end
    
    function spellData:replaceFrames(layerIndex, startFrameIndex, sourceframes)
        local layers = self:getLayers()
        local count = #sourceframes
        local length = sourceframes.length --复制的时候记录的length
        local sourceIndex = 1
        local newLayers = {}
        for i = layerIndex, layerIndex - count + 1, -1 do
            local layer = layers[i]
            local layerIndex
            if not layer then
                layer,layerIndex = self:insertLayer(1)
                newLayers[#newLayers + 1] = {layer = layer, layerIndex = layerIndex}
            end
            --先清除原来的所有的关健帧
            for j = startFrameIndex, startFrameIndex + length - 1 do
                layer:removeCachedFrame(j)
            end
            
            local sourceLayerFrames = sourceframes[sourceIndex]
            for j, mem in ipairs(sourceLayerFrames) do
                if mem.type == FrameState.WEIGHT_KEY_FRAME or mem.type == FrameState.EMPTY_KEY_FRAME then
                    layer:setFrameByData(startFrameIndex + mem.index - 1, mem)
                end
            end
            
            local endFrameState = layer:getFrameState(startFrameIndex + length - 1)
            
            if endFrameState == FrameState.NOTHINE then
                layer:insertFrame(startFrameIndex + length - 1)
            else
                local nextFrameState = layer:getFrameState(startFrameIndex + length)
                if nextFrameState == FrameState.WEIGHT_LAST_FRAME or nextFrameState == FrameState.EMPTY_LAST_FRAME then
                    layer:setKeyFrame(startFrameIndex + length, true)
--                    if endFrameState == FrameState.EMPTY_END_FRAME or endFrameState == FrameState.WEIGHT_END_FRAME then
--                    
--                    end
                end
            end
            
            sourceIndex = sourceIndex + 1
        end
        
        return newLayers;
    end

    for i, v in ipairs(spellData:getLayers()) do
        LayerExtend.extend(v,spellData)
    end
end

--扩展图层功能
--index指的是第几帧
--self.frames只存储关键帧和结束帧，不存储其他帧；其他帧通过计算获得

function LayerExtend.extend(layerData,spellData)
    layerData.__spellData = spellData
    EventProtocol.extend(layerData)

    -- isEmpty 是否建立空白关键帧
    -- 返回帧数据
    function layerData:setKeyFrame(index,isEmpty, newFrame)
        local frames = self:getFrames()
        if not newFrame then
            for i, v in ipairs(frames) do
                if v.index == index then
                    if isEmpty then
                        v.type = FrameState.EMPTY_KEY_FRAME
                    else
                        local lastFrame = frames[i - 1]
                        if lastFrame and lastFrame.type == FrameState.WEIGHT_KEY_FRAME then
                            v.type = FrameState.WEIGHT_KEY_FRAME
                        else
                            v.type = FrameState.EMPTY_KEY_FRAME
                        end
                    end
                    return v
                end
            end
        end
        --如果帧列表中不存在该帧数据
        local frame = {index=index, type=FrameState.EMPTY_KEY_FRAME,__layerData = self}
        if newFrame then
            newFrame.__layerData = self
            frame = newFrame
        end
        local prevFrame
        local lastFrame
        for i = #frames, 1, -1 do
            local v = frames[i]
            if v.index < index then
                prevFrame = v
                lastFrame = frames[i+1]
                break
            end
        end
        if prevFrame then
            if (prevFrame.type == FrameState.WEIGHT_KEY_FRAME or prevFrame.type == FrameState.WEIGHT_END_FRAME) and isEmpty ~= true then
                if not newFrame then
                    frame.type = FrameState.WEIGHT_KEY_FRAME
                end
            end

            if prevFrame.type == FrameState.EMPTY_END_FRAME or prevFrame.type == FrameState.WEIGHT_END_FRAME then
                table.remove(frames)
            end
        end

        if lastFrame and isEmpty and lastFrame.type == FrameState.WEIGHT_END_FRAME then
            lastFrame.type = FrameState.EMPTY_END_FRAME
        end

        table.insert(frames,frame)
        self:sortFrames()
        return frame
    end

    --返回true或false，表示成功或失败
    function layerData:cancelKeyFrame(index)
        local frames = self:getFrames()
        for i, v in ipairs(frames) do
            if v.index == index then
                if v.type == FrameState.WEIGHT_KEY_FRAME or v.type == FrameState.EMPTY_KEY_FRAME then
                    if v.index ~= 1 then
                        table.remove(frames,i)
                        if i == #frames+1 then--说明上面代码删除是最后一帧
                            self:insertFrame(index)
                        else
                            local lastFrame = frames[i]
                            --如果影响了结束帧，将结束帧删除了重新添加
                            if lastFrame and lastFrame.type == FrameState.EMPTY_END_FRAME or lastFrame.type == FrameState.WEIGHT_END_FRAME then
                                table.remove(frames,i)
                                self:insertFrame(lastFrame.index)
                            end
                        end
                        return true
                    else --第一帧
                        if v.type == FrameState.WEIGHT_KEY_FRAME then
                            v.type = FrameState.EMPTY_KEY_FRAME
                            v.action = nil
                            local lastFrame = frames[i+1]
                            --如果影响了结束帧，将结束帧删除了重新添加
                            if lastFrame and lastFrame.type == FrameState.EMPTY_END_FRAME or lastFrame.type == FrameState.WEIGHT_END_FRAME then
                                table.remove(frames,i+1)
                                self:insertFrame(lastFrame.index)
                            end
                    end
                    end
                end
            end
        end
        return false
    end
    
    function layerData:removeCachedFrame(index)
        local frames = self:getFrames()
        for i, v in ipairs(frames) do
            if v.index == index then
                table.remove(frames,i)
                return
            end
        end
    end

    --如果是在中间的帧中插入帧，则总是在index之后延长帧
    --如果是在新的位置插入帧，则延长时间轴到该帧
    --count插入帧的数据
    function layerData:insertFrame(index,count)
        local count = count or 1
        local frames = self:getFrames()
        local lastFrame = frames[#frames]
        if lastFrame and lastFrame.index < index then
            if lastFrame.type == FrameState.WEIGHT_END_FRAME or lastFrame.type == FrameState.EMPTY_END_FRAME then
                lastFrame.index = index
            elseif lastFrame.type == FrameState.WEIGHT_KEY_FRAME or lastFrame.type == FrameState.EMPTY_KEY_FRAME then
                local frame = {index = index, __layerData = self}
                if lastFrame.type == FrameState.WEIGHT_KEY_FRAME then
                    frame.type = FrameState.WEIGHT_END_FRAME
                else
                    frame.type = FrameState.EMPTY_END_FRAME
                end
                table.insert(frames,frame)
                self:sortFrames()
            end
        else
            for i, v in ipairs(frames) do
                if v.index > index or (v.index == index and (v.type == FrameState.WEIGHT_END_FRAME or v.type == FrameState.EMPTY_END_FRAME)) then --大于插入位置的帧全部后移
                    v.index = v.index + count
                end
            end
        end
    end

    function layerData:deleteFrame(index, count)
        local count = count or 1
        local frames = self:getFrames()

        local function deleteOne(index)
            for i = #frames, 1, -1 do
                local v = frames[i]

                if v.index > index then
                    v.index = v.index - 1
                elseif v.index == index then
                    local nextFrame = frames[i + 1]
                    if nextFrame and nextFrame.index == index then
                        if nextFrame.type == FrameState.EMPTY_KEY_FRAME 
                            or nextFrame.type == FrameState.WEIGHT_KEY_FRAME then
                            table.remove(frames,i)
                            break
                        elseif nextFrame.type == FrameState.WEIGHT_END_FRAME or nextFrame.type == FrameState.EMPTY_END_FRAME then
                            table.remove(frames,i + 1)
                        end
                    elseif nextFrame == nil and index ~= 1 then
                        table.remove(frames,i)
                        local prevFrame = frames[i - 1]
                        if prevFrame then
                            self:insertFrame(index - 1)
                        end
                    end
                end
            end
        end


        for i = 1, count do
            deleteOne(index)
        end
    end

    --检查是否在以在指定的帧上添加动作
    function layerData:checkAddAction(frameIndex)
        local state = self:getFrameState(frameIndex)
        if state == FrameState.WEIGHT_KEY_FRAME 
            or state == FrameState.WEIGHT_LAST_FRAME
            or state == FrameState.WEIGHT_END_FRAME then
            return 1
        end
        return 0
    end

    --添加动作到指定帧
    --返回帧数据
    function layerData:addAction(frameIndex, action)
        local state = self:getFrameState(frameIndex)
        local frame = self:getKeyFrame(frameIndex)
        if frame == nil then
            frame = self:setKeyFrame(frameIndex, true)
        else

        end
        frame.action = action
        frame.type = FrameState.WEIGHT_KEY_FRAME

        self:changeFrames(frame, action.__defaultFrame)

        local event = {name=Event.CHANGED}
        self:dispatchEvent(event)

        return frame
    end
    --不带默认长度的添加
    function layerData:addActionWithNoDeafult(frameIndex, action)
        if action == nil then
        return 
        end
        local state = self:getFrameState(frameIndex)
        local frame = self:getKeyFrame(frameIndex)
        if frame == nil then
            frame = self:setKeyFrame(frameIndex, true)
        else

        end
        frame.action = action
        frame.type = FrameState.WEIGHT_KEY_FRAME

        --self:changeFrames(frame, action.__defaultFrame)

        local event = {name=Event.CHANGED}
        self:dispatchEvent(event)

        return frame
    end

    --添加动作时变更相关帧
    function layerData:changeFrames(keyFrame, count)
        local nextCacheFrame = self:getNextCacheFrame(keyFrame)
        if nextCacheFrame then
            if nextCacheFrame.type == FrameState.WEIGHT_END_FRAME or nextCacheFrame.type == FrameState.EMPTY_END_FRAME then
                nextCacheFrame.type = FrameState.WEIGHT_END_FRAME
                if count and count > 1  and nextCacheFrame.index < keyFrame.index + count then
                    nextCacheFrame.index = keyFrame.index + count - 1
                    return
                end
            end
        end

        if keyFrame.index == self:getLastFrameIndex() and count > 1 then --如果是最后一帧，则在最后延长相应帧数
            self:insertFrame(keyFrame.index + count - 1)
            return
        end

        for idx = keyFrame.index + 1, keyFrame.index + count do
            local state = self:getFrameState(idx)
            if state == FrameState.WEIGHT_KEY_FRAME or state == FrameState.EMPTY_KEY_FRAME then
                --遇到关键帧时，不做任务处理
                return
            end
            if keyFrame.index + count == idx then --最后一帧
                self:setKeyFrame(idx, true)
            end
        end
    end
    
    function layerData:setFrameByData(index, frameData)
        frameData.index = index
        self:setKeyFrame(index, nil, frameData)
    end

    --按帧索引从小到大进行排序
    function layerData:sortFrames()
        local frames = self:getFrames()
        table.sort(frames,function (a,b) 
            if a.index < b.index then 
                return true 
            else
                return false
            end
        end)
    end
end

return EditorSpellTemplateExtend