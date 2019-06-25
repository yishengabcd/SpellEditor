
--[[
编辑器战斗预览功能配置
{side=1, pos=0, body="animation/boys/girl.ExportJson", spell=1,targetSide=2,targetPos=4, isJoin=1, isActive=1},
如上1行配置了一个技能，多行表示多个技能，

side=1 表示左边
side=2 表示右边
pos 为0时表示第1个站位，为1时表示第2个站位，以此类推
body 骨骼动画资源路径
spell 技能ID,spell=0时，仅放置角色在场景中，不触发技能
targetSide=2 技能的攻击目标在哪边，值为1表示左边，值为2表示右边
targetPos 技能的攻击目标站位，同pos
isJoin 是否是连携技,1表示是连携技,0或不填该属性表示非连携技
isActive 是否是主动技, 1表示是主动技,0或不填该属性表示非主动技(如果isActive和isJoin同时为1时,则只有isJoin生效，即该技能为连携技)

-- 两个短线，表示注释该行代码
--]]
local BattleConfig = {

--        {side=1, pos=2, body="animation/hr006/hr006.ExportJson", spell=61, targetSide=2, targetPos=1, isActive=0, actionTime=1000},
--        {side=1, pos=1, body="animation/hr001/hr001.ExportJson", spell=14, targetSide=2, targetPos=1, isActive=0, actionTime=1000},
--        {side=1, pos=0, body="animation/hr028/hr028.ExportJson", spell=284, targetSide=2, targetPos=1, isJoin=1},

--        {side=1, pos=2, body="animation/hr024/hr024.ExportJson", spell=242, targetSide=2, targetPos=3, isActive=0, actionTime=1000},
        {side=1, pos=4, body="animation/hr026/hr026.ExportJson", spell=260, targetSide=2, targetPos=1, isJoin=0},
        {side=2, pos=1, body="animation/ms021/ms021.ExportJson", spell=10301, targetSide=1, targetPos=3, actionTime=1500},
        {side=1, pos=3, body="animation/hr001/hr001.ExportJson", spell=11, targetSide=2, targetPos=1, isJoin=0},
        {side=1, pos=2, body="animation/hr024/hr024.ExportJson", spell=242, targetSide=2, targetPos=1, isActive=0, actionTime=1000},
--        {side=1, pos=0, body="animation/hr027/hr027.ExportJson", spell=274, targetSide=2, targetPos=1, isJoin=1},
        
--        {side=1, pos=2, body="animation/hr009/hr009.ExportJson", spell=94, targetSide=2, targetPos=1, isJoin=1, actionTime=1000},
--        {side=1, pos=0, body="animation/hr007/hr007.ExportJson", spell=72, targetSide=2, targetPos=1, isJoin=1},
--        {side=1, pos=3, body="animation/hr006/hr006.ExportJson", spell=62, targetSide=2, targetPos=1, isJoin=1},
        
--        {side=1, pos=3, body="animation/hr004/hr004.ExportJson", spell=43, targetSide=2, targetPos=1, isJoin=1},
--        {side=1, pos=5, body="animation/hr007/hr007.ExportJson", spell=73, targetSide=2, targetPos=1, isJoin=1},
--        {side=1, pos=5, body="animation/hr026/hr026.ExportJson", spell=262, targetSide=2, targetPos=1, isJoin=1},
--		{side=1, pos=4, body="animation/hr010/hr010.ExportJson", spell=105, targetSide=2, targetPos=4, isJoin=1},
        
        --{side=1, pos=1, body="animation/hr001/hr001.ExportJson", spell=1004, targetSide=2, targetPos=4, isActive=1},
        --{side=2, pos=1, body="animation/LD-Nanzhanshi/LD-Nanzhanshi.ExportJson", spell=2, targetSide=1, targetPos=0},
        {side=2, pos=3, body="animation/ms001/ms001.ExportJson", spell=0, targetSide=1, targetPos=1, actionTime=4000},
        {side=2, pos=0, body="animation/ms001/ms001.ExportJson", spell=0, targetSide=1, targetPos=0, actionTime=5000},
        
}

return BattleConfig
