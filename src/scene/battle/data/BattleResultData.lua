local BattleResultData = class("BattleResultData")

--以下代码仅用于表明该对象含有的属性，并使开发时增加代码提示
BattleResultData.winTeam = 1
BattleResultData.drops = {
--[[
    {tplId = 1, count = 999},{tplId = 2, count = 999} ...
--]]
}
--end


function BattleResultData:ctor()
end

return BattleResultData