
local SkeletonLoadMgr = class("SkeletonLoadMgr")

local loadList = {} --正在加载的和等待加载的列表
local loadedMap = {} --已经加载好的列表
local handlers = {} --存储所有回调方法
local loading = false

local scheduler = cc.Director:getInstance():getScheduler()
local _schedulerEntry
local _schedulerEntry2

local function insertUniqueObj(arr, obj)
    local exist
    for _, mem in ipairs(arr) do
        if mem == obj then
            exist = true
        end
    end
    if not exist then
        table.insert(arr,obj)
    end
end

function SkeletonLoadMgr.load(path, complete)
    local flag = loadedMap[path]
    if flag then
        complete()
        return
    end
    
    insertUniqueObj(loadList,path)
    local handler = handlers[path]
    if not handler then
        handler = {}
        handlers[path] = handler
    end
    insertUniqueObj(handler,complete)
    
    if loading == false then
        SkeletonLoadMgr.startLoad()
    end
end

function SkeletonLoadMgr.startLoad()
    loading = true
    local function delay(dt)
        scheduler:unscheduleScriptEntry(_schedulerEntry2)
        SkeletonLoadMgr.loadOne()
        _schedulerEntry2 = nil
    end
    _schedulerEntry2 = scheduler:scheduleScriptFunc(delay,3,false)
end

function SkeletonLoadMgr.loadOne()
    loading = true
    local path = loadList[1]
    local function onLoaded(percent)
        _schedulerEntry = scheduler:scheduleScriptFunc(SkeletonLoadMgr.onOneLoaded,0.05,false)
    end
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(path, onLoaded)
end

function SkeletonLoadMgr.onOneLoaded()

    if _schedulerEntry then
        scheduler:unscheduleScriptEntry(_schedulerEntry)
        _schedulerEntry = nil
    end
    
    loading = false
    
    local path = loadList[1]
    loadedMap[path] = true
    
    local handler = handlers[path]
    if handler then
        for _, fun in ipairs(handler) do
        	fun()
        end
        handlers[path] = nil
    end
    
    table.remove(loadList,1)
    
    if #loadList > 0 then
        SkeletonLoadMgr.loadOne()
    end
end

function SkeletonLoadMgr.purge()

end

return SkeletonLoadMgr