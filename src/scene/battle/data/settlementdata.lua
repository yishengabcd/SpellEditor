local SettlementData = class("SettlementData")

--以下代码仅用于表明该对象含有的属性，并使开发时增加代码提示
SettlementData.mapType = 0
SettlementData.win = false
SettlementData.settlementId = 0
SettlementData.starType = 0
SettlementData.gradeType = 0
SettlementData.point = 0
SettlementData.goldBase = 0
SettlementData.goldAugment =0
SettlementData.expBase = 0
SettlementData.expAugment =0
SettlementData.expTotal = 0   --实际消耗经验
SettlementData.heroList = {}
SettlementData.drops = {}

function SettlementData:ctor()
end

return SettlementData