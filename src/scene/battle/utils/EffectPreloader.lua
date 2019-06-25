local EffectPreloader = class("EffectPreloader")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")

local Loader = class("Loader")

function Loader:ctor(plist, texturePath)
    self._plist = plist
    self._texturePath = texturePath
end

function Loader:load(callback)
    self._callback = callback
--    require("socket")  
--    local t1 =socket.gettime()
    
    local function imageLoaded(texture)
        if self._callback then
            self._callback(self)
        end
--        local t2 = socket.gettime()
--        print("t1=" .. t1 .. " t2=" .. t2 .. "t2-t1=" .. (t2 - t1))
    end

    cc.Director:getInstance():getTextureCache():addImageAsync(self._texturePath, imageLoaded)
end

function Loader:cancel()
    self._canceled = true
end

function Loader:getCanceled()
    return self._canceled
end

function Loader:getPlistPath()
    return self._plist
end


local _loaderArray = {}
local _loaderHashMap = {}
local _loaderIndex = 1
local _loading = nil
local _loadedHashMap = {}

function EffectPreloader.loadAsync(plist, texturePath)
    do return end
    if _loaderHashMap[plist] then return end
    
    local loader = Loader.new(plist, texturePath)
    _loaderArray[#_loaderArray + 1] = loader
    _loaderHashMap[plist] = loader
    
    if not _loading then
        _loading = true
        EffectPreloader.loadOne()
    end
end

function EffectPreloader.loadOne()
    local loader = _loaderArray[_loaderIndex]
    if loader:getCanceled() or (_loaderHashMap[loader:getPlistPath()] and _loaderHashMap[loader:getPlistPath()] ~= loader) then
        EffectPreloader.loadNext()
    else
        loader:load(EffectPreloader.onOneLoadComplete)
    end
end

function EffectPreloader.loadNext()
    _loaderIndex = _loaderIndex + 1
    if _loaderIndex > #_loaderArray then
        _loading = false
    else
        EffectPreloader.loadOne()
    end
end

function EffectPreloader.onOneLoadComplete(loader)
    local plist = loader:getPlistPath()
    if _loaderHashMap[plist] then
        _loadedHashMap[plist] = true
        EffectPreloader.loadNext()
    end
end

function EffectPreloader.isLoaded(plist)
    return _loadedHashMap[plist]
end

function EffectPreloader.setLoadedOfPlist(plist)
    local loader = _loaderHashMap[plist]
    if loader then
        loader:cancel()
    end
    _loadedHashMap[plist]  = true
end

function EffectPreloader.recycleEffect(plist)
    _loaderHashMap[plist] = nil
    _loadedHashMap[plist] = nil
end

function EffectPreloader.preloadSpell(template)
    local layers = template:getLayers()
    for i, layer in ipairs(layers) do
        local frames = layer:getFrames()
        for j, frame in ipairs(frames) do
            local name = nil
            if frame.action then
                if frame.action.type == FrameActionType.PLAY_EFFECT
                    or frame.action.type == FrameActionType.FLY_EFFECT
                    or frame.action.type == FrameActionType.HURT
                    or frame.action.type == FrameActionType.MISSILE then

                    EffectPreloader.loadAsyncByName(frame.action.effect)
                end
            end
        end
    end
end

function EffectPreloader.loadAsyncByName(effectName)
    if not effectName or effectName == "" then return end
    local plist = effectName .. ".animate.plist"
    local texturePath = effectName .. ".pvr.ccz"
    EffectPreloader.loadAsync(plist, texturePath)
end

function EffectPreloader.clear()
    _loadedHashMap = {}
    _loaderIndex = 1
    _loaderArray = {}
    _loaderHashMap = {}
    _loading = nil
end

return EffectPreloader