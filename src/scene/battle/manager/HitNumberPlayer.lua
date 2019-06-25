
--连击数显示
local HitNumberPlayer = {}

local RoleInfo = require("src/scene/battle/data/RoleInfo")
local HitNumberEffect = require("src/scene/battle/view/HitNumberEffect")

local _scene
local _side

local _count = 0
local _leftView
local _rightView

local winSize = cc.Director:getInstance():getVisibleSize();

function HitNumberPlayer.setup(scene)
    _scene = scene
end

function HitNumberPlayer.increase(count, spell)
    do return end
    if LD_EDITOR then return end
    local side = spell:getExecutor():getInfo().side == RoleInfo.SIDE_RIGHT and RoleInfo.SIDE_LEFT or RoleInfo.SIDE_RIGHT
    if side ~= _side then
        HitNumberPlayer.reset()
    end
    
    _side = side
    _count = _count + count
    if _count > 1 then
        if side == RoleInfo.SIDE_LEFT then
            if not _leftView then
                _leftView = HitNumberEffect.new()
                _leftView:setPosition(winSize.width/6, winSize.height-120)
                _scene:addChild(_leftView)
            end
            _leftView:setNumber(_count)
        else
            if not _rightView then
                _rightView = HitNumberEffect.new()
                _rightView:setPosition(winSize.width*5/6, winSize.height-120)
                _scene:addChild(_rightView)
            end
            _rightView:setNumber(_count)
        end
    end
end

function HitNumberPlayer.reset()
    if _leftView then
        _leftView:disappear()
        _leftView = nil
    end
    if _rightView then
        _rightView:disappear()
        _rightView = nil
    end
    _side = nil
    _count = 0
end

function HitNumberPlayer.dispose()
    _leftView = nil
    _rightView = nil
    _side = nil
    _count = 0
end

return HitNumberPlayer