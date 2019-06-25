
local BuffData = require("src/scene/battle/data/BuffData")
local SimpleEffect = require("src/scene/battle/view/SimpleEffect")

local BuffEffect = class("BuffEffect",function () 
    return cc.Node:create();
end)

function BuffEffect:ctor(buffData, resPath)
    self._buffData = buffData
    
    local effect = SimpleEffect.new(resPath, true, 0.5)
    effect:setScale(2)
    self:addChild(effect)
    
--    local countTxt = cc.LabelAtlas:_create("0","ui/common/battle_remove_hp_common.png",31,29,string.byte("0"))
--    countTxt:setPosition(20,-15)
--    self:addChild(countTxt)
--    self._countTxt = countTxt
--    countTxt:setVisible(false)
--    
--    self._onCountChanged = function (event)
--        if self._buffData.count > 1 then
--            self._countTxt:setString(tostring(self._buffData.count))
--            self._countTxt:setVisible(true)
--        else
--            self._countTxt:setVisible(false)
--        end
--    end
--    
--    self._buffData:addEventListener(BuffData.EVENT_COUNT_CHANGED, self._onCountChanged)
--
--    local function onNodeEvent(event)
--        if "exit" == event then
--            self._buffData:removeEventListener(BuffData.EVENT_COUNT_CHANGED, self._onCountChanged)
--        end
--    end
--
--    self:registerScriptHandler(onNodeEvent)
end

function BuffEffect:getBuffData()
    return self._buffData
end

return BuffEffect