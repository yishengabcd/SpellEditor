local LoaderType = require("src/scene/loading/loadertype")

local LoaderManager = class("LoaderManager")
local scheduler = cc.Director:getInstance():getScheduler()

function LoaderManager:ctor(onComplete, onProgress)
    self._onComplete = onComplete
    self._onProgress = onProgress
    self._waitList = {}
end

--list结构：{type=type, path=path}
function LoaderManager:appendList(list)
    if list then
        for _, loader in ipairs(list) do
            table.insert(self._waitList,loader)
        end
    end
end

function LoaderManager:start()
    self._count = 0
    self:loadNext()
end

function LoaderManager:loadOne()
    local data = self._waitList[self._count]
    
    if data then
        local function onLoaded()
            if self._onProgress then
                local total = #self._waitList
                local progress = self._count/total
                self._onProgress(progress)
                self:loadNext()
            end
        end
        if data.type == LoaderType.IMAGE then
            cc.Director:getInstance():getTextureCache():addImageAsync(data.path, onLoaded)
        elseif data.type == LoaderType.SKELETON then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(data.path, onLoaded)
        end
    else
        self:loadComplete()
    end
end

function LoaderManager:loadNext()
    local total = #self._waitList
    self._count = self._count + 1
    if self._count > total then
        self:loadComplete()
    else
        local schedulerEntry
        local function delay(dt)
            self:loadOne()
            scheduler:unscheduleScriptEntry(schedulerEntry)
        end

        schedulerEntry = scheduler:scheduleScriptFunc(delay, 1/30, false)
    end
end

function LoaderManager:loadComplete()
    if self._onComplete then
        self._onComplete()
    end
end

return LoaderManager