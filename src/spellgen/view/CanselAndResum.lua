local EventProtocol = require("src/utils/EventProtocol")
local CanselAndResum = {}
local tb={}
local tr={}
local eb={}
local er={}
local lb={}
local lr={}
CanselAndResum.Enum={
    TIMELINETYPE = "timeline",--时间轴的操作
    EVENTTYPE = "eventtype",--事件添加的操作
    LAYERTYPE = "layertype",--图层操作
    NULLTYPE = "nulltype"--没有撤销还原的部件
}
local currenedittype = CanselAndResum.Enum.TIMELINETYPE
EventProtocol.extend(CanselAndResum)

CanselAndResum.CANSEL = "Cansel" --取消前面操作
CanselAndResum.RESUM = "Resum" --恢复操作
CanselAndResum.CANSELEVENT = "CanselEvent" --取消事件添加操作
CanselAndResum.RESUMEVENT = "ResumEvent" --恢复事件添加操作
CanselAndResum.CANSELLAYER = "CanselLayer" --取消前面操作
CanselAndResum.RESUMLAYER = "ResumLayer" --恢复操作

function CanselAndResum:setCurrentEdittype(type)
    currenedittype = type     
end

function CanselAndResum.Cansel(type)
    local event={}
    if currenedittype == CanselAndResum.Enum.TIMELINETYPE then
        event = {name = CanselAndResum.CANSEL}
    elseif currenedittype == CanselAndResum.Enum.EVENTTYPE then
        event = {name = CanselAndResum.CANSELEVENT}
    elseif  currenedittype == CanselAndResum.Enum.LAYERTYPE then
        event = {name = CanselAndResum.CANSELLAYER}
    else
    end
    CanselAndResum:dispatchEvent(event)
end   

function CanselAndResum.Resum(type)
    local event={}
    if currenedittype == CanselAndResum.Enum.TIMELINETYPE then
        event = {name = CanselAndResum.RESUM}
    elseif currenedittype == CanselAndResum.Enum.EVENTTYPE then
        event = {name = CanselAndResum.RESUMEVENT}
    elseif  currenedittype == CanselAndResum.Enum.LAYERTYPE then
        event = {name = CanselAndResum.RESUMLAYER}
    else
    end
    CanselAndResum:dispatchEvent(event)
end

function CanselAndResum:SetCurrentEnumType(type)
    table.insert(tb,type)
    if table.getn(tb) >= 6 then
        table.remove(tb,1)
    end
end

function CanselAndResum:SetCurrentEnumResum(type)
    table.insert(tr,type)
    if table.getn(tr) >= 6 then
        table.remove(tr,1)
    end
end

function CanselAndResum:SetCurrentEnumEvent(type)
    table.insert(eb,type)
    if table.getn(eb) >= 6 then
        table.remove(eb,1)
    end
end

function CanselAndResum:SetCurrentEnumEventResum(type)
    table.insert(er,type)
    if table.getn(er) >= 6 then
        table.remove(er,1)
    end
end

function CanselAndResum:SetCurrentEnumLayer(type)
    table.insert(lb,type)
    if table.getn(lb) >= 6 then
        table.remove(lb,1)
    end
end

function CanselAndResum:SetCurrentEnumLayerResum(type)
    table.insert(lr,type)
    if table.getn(lr) >= 6 then
        table.remove(lr,1)
    end
end

function CanselAndResum:GetCurrentEnumLayer() 
    return table.remove(lb)
end

function CanselAndResum:GetCurrentEnumResumLayer() 
    return table.remove(lr)
end

function CanselAndResum:GetCurrentEnum() 
    return table.remove(tb)
end

function CanselAndResum:GetCurrentEnumResum()
    return table.remove(tr)
end

function CanselAndResum:GetCurrentEnumEvent() 
    return table.remove(eb)
end

function CanselAndResum:GetCurrentEnumResumEvent() 
    return table.remove(er)
end

function CanselAndResum:ClearAllCansel()
    tb={}
end

function CanselAndResum:ClearAllResum()
    tr={}
end

function CanselAndResum:ClearAllCanselEvent()
    eb={}
end

function CanselAndResum:ClearAllResumEvent()
    er={}
end

function CanselAndResum:ClearAllCanselLayer()
    lb={}
end

function CanselAndResum:ClearAllResumLayer()
    lr={}
end
return CanselAndResum