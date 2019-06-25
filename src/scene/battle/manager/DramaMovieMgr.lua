
--战斗对外接口类，提供战斗功能的相关接口
local DramaMovieMgr = {}

local EnterFrameMgr = require("src/scene/battle/manager/EnterFrameMgr")
local TweenMgr = require("src/scene/battle/manager/TweenMgr")
local DramaModel = require("src/scene/battle/data/DramaModel")

local scheduler = cc.Director:getInstance():getScheduler()
local _schedulerEntry
local tweenMgr = TweenMgr.new()

local _editing = false --是否处于编辑状态
local _inited --是否已经初始化
local _movie;
local _speed = 1

function DramaMovieMgr.init()
    if _inited then return end
    _inited = true

    DramaModel.load()
end

function DramaMovieMgr.setMovie(movie)
    _movie = movie
    if _schedulerEntry then
        scheduler:unscheduleScriptEntry(_schedulerEntry)
    end
    _schedulerEntry = scheduler:scheduleScriptFunc(DramaMovieMgr.onEnterFrame,1/60, false)
end

function DramaMovieMgr.onEnterFrame(dt)
--    local dt = _speed * dt
    tweenMgr:step(dt)
    EnterFrameMgr.onEnterFrame(dt)
end

function DramaMovieMgr.disposeCurrentMovie()
    if _schedulerEntry then
        scheduler:unscheduleScriptEntry(_schedulerEntry)
        _schedulerEntry = nil
    end
    tweenMgr:clear()
    if _movie then
        _movie:dispose()
        _movie = nil
    end
end

function DramaMovieMgr.getMovie()
    return _movie
end
function DramaMovieMgr.getTweenMgr()
    return tweenMgr
end

--为编辑器加的方法
function DramaMovieMgr.setEditing(value)
    _editing = value
end
--为编辑器加的方法
function DramaMovieMgr.setFrameForEditor(frame)
    if _editing then
        _movie:setFrame(frame)
    end
end
--为编辑器加的方法
function DramaMovieMgr.refresh()
    if _editing and _movie then
        _movie:refresh()
    end
end

return DramaMovieMgr