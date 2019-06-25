--用于扩展技能数据表的功能,增加方法和辅助字段，以方便重用及适应编辑器需求等
local MapConfigDataExtend = {}
local LayerExtend = {}
MapConfigDataExtend.LayerExtend = LayerExtend

function MapConfigDataExtend.extend(mapData)

    function mapData:getLayers()
        if self.layers == nil then
            self.layers = {}
        end
        return self.layers
    end

    function mapData:getIndexOfLayer(layer)
        for i, v in ipairs(self.layers) do
            if v == layer then
                return i
            end
        end
        return 0
    end
    for i, v in ipairs(mapData:getLayers()) do
        LayerExtend.extend(v,mapData)
    end
end

--扩展图层功能
function LayerExtend.extend(layerData,mapData)
    layerData.__mapData = mapData

    function layerData:getItems()
        if self.items == nil then
            self.items = {}
        end
        return self.items
    end

    --扩展每一帧的功能或属性
    local items = layerData:getItems()
    for i, frame in ipairs(items) do
        frame.__layerData = layerData
    end

    function layerData:getMapData()
        return self.__mapData
    end
end

return MapConfigDataExtend