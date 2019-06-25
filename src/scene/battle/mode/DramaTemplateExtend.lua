--用于扩展技能数据表的功能,增加方法和辅助字段，以方便重用及适应编辑器需求等
local DramaTemplateExtend = {}
local LayerExtend = {}
DramaTemplateExtend.LayerExtend = LayerExtend

local FrameState = require("src/scene/battle/mode/FrameState")

function DramaTemplateExtend.extend(dramaData)
    function dramaData:getLayers()
        if self.layers == nil then
            self.layers = {}
        end
        return self.layers
    end

    function dramaData:getIndexOfLayer(layer)
        for i, v in ipairs(self.layers) do
            if v == layer then
                return i
            end
        end
        return 0
    end
    -- 最大的有效帧数
    function dramaData:getMaxFrameLength()
        local layers = self:getLayers()
        local len = 0
        for i, v in ipairs(layers) do
            if v:getLastFrameIndex() > len then
                len = v:getLastFrameIndex()
            end
        end
        return len
    end
    function dramaData:getLastKeyFrameByType(actionType)
        local frames = self:getAllKeyFramesOfType(actionType)
        if #frames > 0 then
            table.sort(frames,function (a, b) return a.index > b.index end)
            return frames[1]
        end
        return nil
    end

    function dramaData:getFirstKeyFrameByType(actionType)
        local frames = self:getAllKeyFramesOfType(actionType)
        if #frames > 0 then
            table.sort(frames,function (a, b) return a.index > b.index end)
            return frames[#frames]
        end
        return nil
    end
    
    function dramaData:getAllKeyFrameBefore(actionType, index)
        local frames = self:getAllKeyFramesOfType(actionType)
        if #frames > 0 then
            local befores = {}
            for i, frame in ipairs(frames) do
            	if frame.index < index then
            	   table.insert(befores, frame)
            	end
            end
            if #befores > 0 then
                table.sort(befores,function (a, b) return a.index < b.index end)
                return befores
            end
        end
        return nil
    end
    --检查指定帧是否包含指定的动作类型关键帧
    function dramaData:checkHasKeyFrameOfType(frameIndex, actionType)
        local layers = self:getLayers()
        for i, layer in ipairs(layers) do
            local frames = layer:getFrames()
            for j, frame in ipairs(frames) do
                if frame.index == frameIndex and frame.type == FrameState.WEIGHT_KEY_FRAME then
                    local action = frame.action
                    if action and action.type == actionType then
                        return true
                    end
                end
            end
        end
        return false
    end
    function dramaData:checkHasBeforeFrameOfType(frameIndex, actionType)
        local layers = self:getLayers()
        for i, layer in ipairs(layers) do
            local frame = layer:getKeyFrame(frameIndex)
            if frame then
                local action = frame.action
                if action and action.type == actionType then
                    return true
                end
            end
        end
        return false
    end
    
    function dramaData:getAllKeyFramesOfType(actionType)
        local layers = self:getLayers()
        local ret = {}
        for i, layer in ipairs(layers) do
            local frames = layer:getFrames()
            for j, frame in ipairs(frames) do
                if frame.type == FrameState.WEIGHT_KEY_FRAME then
                    local action = frame.action
                    if action and action.type == actionType then
                        table.insert(ret,frame)
                    end
                end
            end
        end
        return ret
    end
    for i, v in ipairs(dramaData:getLayers()) do
        LayerExtend.extend(v,dramaData)
    end
end

--扩展图层功能
--index指的是第几帧
--self.frames只存储关键帧和结束帧，不存储其他帧；其他帧通过计算获得

function LayerExtend.extend(layerData,dramaData)
    layerData.__dramaData = dramaData

    function layerData:getFrames()
        if self.frames == nil then
            self.frames = {{type=FrameState.EMPTY_KEY_FRAME, index=1, __layerData = self}}--新建立图层时，默认第一帧为空白关键帧
        end
        return self.frames
    end

    --扩展每一帧的功能或属性
    local frames = layerData:getFrames()
    for i, frame in ipairs(frames) do
        frame.__layerData = layerData
    end

    --获得指定关键帧的长度（即关键帧及其延长帧的数量
    function layerData:getKeyFrameLength(keyFrame)
        local frames = self:getFrames()
        local nextFrame

        for i, frame in ipairs(frames) do
            if frame.index > keyFrame.index then
                nextFrame = frame
                break
            end
        end
        if nextFrame then
            local count = nextFrame.index - keyFrame.index
            if nextFrame.type == FrameState.WEIGHT_END_FRAME then
                count = count + 1
            end
            return count
        else
            return 1
        end
    end

    function layerData:getFrameState(index)
        if index > self:getLastFrameIndex() then
            return FrameState.NOTHINE
        end

        local frames = self:getFrames()

        for i = #frames, 1, -1 do
            local v = frames[i]

            if v.index < index then
                if v.type == FrameState.EMPTY_KEY_FRAME then
                    return FrameState.EMPTY_LAST_FRAME
                elseif v.type == FrameState.WEIGHT_KEY_FRAME then
                    return FrameState.WEIGHT_LAST_FRAME
                else
                    return FrameState.NOTHINE -- 理论上不会走到这里
                end
            elseif v.index == index then
                return v.type
            end
        end
    end

    --获得指定位置所属的关键帧（如果该位置是关键帧，则返回该帧，否则返回上一个关键帧）
    function layerData:getKeyFrame(frameIndex)
        local state = self:getFrameState(frameIndex)
        if state == FrameState.NOTHINE then
            return nil
        end
        local frames = self:getFrames()

        for i = #frames, 1, -1 do
            local v = frames[i]

            if v.index < frameIndex or v.index == frameIndex then
                if v.type == FrameState.WEIGHT_KEY_FRAME or v.type == FrameState.EMPTY_KEY_FRAME then
                    return v
                end
            end
        end
        return nil
    end
    --获得下一个存储的帧
    function layerData:getNextCacheFrame(frame)
        local frames = self:getFrames()
        for i, v in ipairs(frames) do
            if v == frame then
                return frames[i+1]
            end
        end
        return nil
    end
    --返回最后一帧的位置
    function layerData:getLastFrameIndex()
        local frames = self:getFrames()
        local lastFrame = frames[#frames]
        if lastFrame then
            return lastFrame.index
        end
        return 0
    end

    function layerData:getDramaData()
        return self.__dramaData
    end
end

return DramaTemplateExtend