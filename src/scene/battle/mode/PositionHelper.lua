local PositionHelper = {}

local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
local RoleInfo = require("src/scene/battle/data/RoleInfo")

PositionHelper.FORMATION_5_3_2 = 1; --5人阵型前3后2
PositionHelper.FORMATION_5_2_3 = 2; --5人阵型前2后3
PositionHelper.FORMATION_6_3_3 = 3; --6人阵型前3后3

local center
local leftCenter
local rightCenter
local lefts
local rights

local TEAM_CENTER_Y = 306 --队伍中心点的Ｙ坐标
local TEAM_DIS_HALF = 264 --两个队伍的距离的一半

--后面的633、532这样的数字表示阵型，如532表示5人站位，前3后2
local TEAM_CENTER_Y633 = 306 --队伍中心点的Ｙ坐标
local TEAM_DIS_HALF633 = 264 --两个队伍的距离的一半

local TEAM_CENTER_Y532 = 384
local TEAM_DIS_HALF532 = 240

local TEAM_CENTER_Y523 = 357
local TEAM_DIS_HALF523 = 266

PositionHelper.JOIN_SPELL_DIS = 600 --连携技（和主动技）发动时，发动者与被攻击者的距离
PositionHelper.JOIN_SPELL_COME_OUT_FROM = 10 --连携技跑出来的位置距发动点的距离
PositionHelper.JOIN_SPELL_RUN_AWAY_TO = 500 --连携技跑出去的位置距发动点的距离

--各个站位离中心点的水平距离以及离底部的垂直距离
local ROLE_POS633_1 = {x=202,y=306}
local ROLE_POS633_2 = {x=134,y=232}
local ROLE_POS633_3 = {x=198,y=150}
local ROLE_POS633_4 = {x=383,y=316}
local ROLE_POS633_5 = {x=289,y=223}
local ROLE_POS633_6 = {x=400,y=134}

local ROLE_POS532_1 = {x=115,y=400-80+10}
local ROLE_POS532_2 = {x=190,y=284-80+10}
local ROLE_POS532_3 = {x=292,y=195-80+10}
local ROLE_POS532_5 = {x=309,y=377-80+10}
local ROLE_POS532_6 = {x=380,y=275-80+10}
local ROLE_POS532_4 = {x=0,y=0} --前3后2时，第4个位为空

local ROLE_POS523_1 = {x=138,y=307-80+40}
local ROLE_POS523_2 = {x=210,y=207-80+40}
local ROLE_POS523_3 = {x=0,y=0} --前2后3时，第3个位为空
local ROLE_POS523_4 = {x=282,y=377-80+40}
local ROLE_POS523_5 = {x=331,y=275-80+40}
local ROLE_POS523_6 = {x=384,y=160-80+40}

----以上是美术一开始时定的位标，应后续有自动拉开间距的需求，以及增加了地图单元的概念，所以加入了以下相对于单元的参考坐标点

--以地图单元作参考的坐标偏移值
local ROLE_POSITIONS_BY_UNIT633 = {
    {x=ROLE_POS633_1.x - ROLE_POS633_2.x,y=ROLE_POS633_1.y},
    {x=0,y=ROLE_POS633_2.y},
    {x=ROLE_POS633_3.x - ROLE_POS633_2.x,y=ROLE_POS633_3.y},
    {x=ROLE_POS633_4.x - ROLE_POS633_2.x,y=ROLE_POS633_4.y},
    {x=ROLE_POS633_5.x - ROLE_POS633_2.x,y=ROLE_POS633_5.y},
    {x=ROLE_POS633_6.x - ROLE_POS633_2.x,y=ROLE_POS633_6.y}
}

local ROLE_POSITIONS_BY_UNIT532 = {
    {x=0,y=ROLE_POS532_1.y},
    {x=ROLE_POS532_2.x - ROLE_POS532_1.x,y=ROLE_POS532_2.y},
    {x=ROLE_POS532_3.x - ROLE_POS532_1.x,y=ROLE_POS532_3.y},
    {x=ROLE_POS532_4.x - ROLE_POS532_1.x,y=ROLE_POS532_4.y},
    {x=ROLE_POS532_5.x - ROLE_POS532_1.x,y=ROLE_POS532_5.y},
    {x=ROLE_POS532_6.x - ROLE_POS532_1.x,y=ROLE_POS532_6.y}
}

local ROLE_POSITIONS_BY_UNIT523 = {
    {x=0,y=ROLE_POS523_1.y},
    {x=ROLE_POS523_2.x - ROLE_POS523_1.x,y=ROLE_POS523_2.y},
    {x=ROLE_POS523_3.x - ROLE_POS523_1.x,y=ROLE_POS523_3.y},
    {x=ROLE_POS523_4.x - ROLE_POS523_1.x,y=ROLE_POS523_4.y},
    {x=ROLE_POS523_5.x - ROLE_POS523_1.x,y=ROLE_POS523_5.y},
    {x=ROLE_POS523_6.x - ROLE_POS523_1.x,y=ROLE_POS523_6.y}
}

local winSize = cc.Director:getInstance():getVisibleSize()
if LD_EDITOR then
    winSize.width = 960
    winSize.height = 640
end

local winWidth = winSize.width>1136 and 1136 or winSize.width
winWidth = winWidth<960 and 960 or winWidth

local _formationLeft = PositionHelper.FORMATION_6_3_3
local _formationRight = PositionHelper.FORMATION_6_3_3
local _leftUnitBetweenCenter --单位距中心点距离
local _rightUnitBetweenCenter

function PositionHelper.initFormation(formationLeft, formationRight)
    _formationLeft = formationLeft or _formationLeft
    _formationRight = formationRight or _formationRight
    
    if _formationLeft == PositionHelper.FORMATION_6_3_3 then
        _leftUnitBetweenCenter = (winWidth - 960)/2 + ROLE_POS633_2.x
    elseif _formationLeft == PositionHelper.FORMATION_5_3_2 then
        _leftUnitBetweenCenter = (winWidth - 960)/2 + ROLE_POS532_1.x
    elseif _formationLeft == PositionHelper.FORMATION_5_2_3 then
        _leftUnitBetweenCenter = (winWidth - 960)/2 + ROLE_POS523_1.x
    end

    if _formationRight == PositionHelper.FORMATION_6_3_3 then
        _rightUnitBetweenCenter = (winWidth - 960)/2 + ROLE_POS633_2.x
    elseif _formationRight == PositionHelper.FORMATION_5_3_2 then
        _rightUnitBetweenCenter = (winWidth - 960)/2 + ROLE_POS532_1.x
    elseif _formationRight == PositionHelper.FORMATION_5_2_3 then
        _rightUnitBetweenCenter = (winWidth - 960)/2 + ROLE_POS523_1.x
    end
end

--设置中心点
function PositionHelper.setCenter(pt, formationLeft, formationRight)
    center = pt
    
    if _formationLeft == PositionHelper.FORMATION_6_3_3 then
        leftCenter = cc.p(pt.x - _leftUnitBetweenCenter - TEAM_DIS_HALF633 + ROLE_POS633_2.x, TEAM_CENTER_Y633)
    elseif _formationLeft == PositionHelper.FORMATION_5_3_2 then
        leftCenter = cc.p(pt.x - _leftUnitBetweenCenter - TEAM_DIS_HALF532 + ROLE_POS532_1.x, TEAM_CENTER_Y532)
    elseif _formationLeft == PositionHelper.FORMATION_5_2_3 then
        leftCenter = cc.p(pt.x - _leftUnitBetweenCenter - TEAM_DIS_HALF523 + ROLE_POS523_1.x, TEAM_CENTER_Y523)
    end
    
    if _formationRight == PositionHelper.FORMATION_6_3_3 then
        rightCenter = cc.p(pt.x + _rightUnitBetweenCenter + TEAM_DIS_HALF633 - ROLE_POS633_2.x, TEAM_CENTER_Y633)
    elseif _formationRight == PositionHelper.FORMATION_5_3_2 then
        rightCenter = cc.p(pt.x + _rightUnitBetweenCenter + TEAM_DIS_HALF532 - ROLE_POS532_1.x, TEAM_CENTER_Y532)
    elseif _formationRight == PositionHelper.FORMATION_5_2_3 then
        rightCenter = cc.p(pt.x + _rightUnitBetweenCenter + TEAM_DIS_HALF523 - ROLE_POS523_1.x, TEAM_CENTER_Y523)
    end

    
    local leftUnitX = pt.x - _leftUnitBetweenCenter
    local rightUnitX = pt.x + _rightUnitBetweenCenter
    
    lefts = {}
    rights = {}
    for i = 1, 6 do 
        if _formationLeft == PositionHelper.FORMATION_6_3_3 then
            lefts[i] = cc.p(leftUnitX - ROLE_POSITIONS_BY_UNIT633[i].x, ROLE_POSITIONS_BY_UNIT633[i].y)
        elseif _formationLeft == PositionHelper.FORMATION_5_3_2 then
            lefts[i] = cc.p(leftUnitX - ROLE_POSITIONS_BY_UNIT532[i].x, ROLE_POSITIONS_BY_UNIT532[i].y)
        elseif _formationLeft == PositionHelper.FORMATION_5_2_3 then
            lefts[i] = cc.p(leftUnitX - ROLE_POSITIONS_BY_UNIT523[i].x, ROLE_POSITIONS_BY_UNIT523[i].y)
        end

        if _formationRight == PositionHelper.FORMATION_6_3_3 then
            rights[i] = cc.p(rightUnitX + ROLE_POSITIONS_BY_UNIT633[i].x, ROLE_POSITIONS_BY_UNIT633[i].y)
        elseif _formationRight == PositionHelper.FORMATION_5_3_2 then
            rights[i] = cc.p(rightUnitX + ROLE_POSITIONS_BY_UNIT532[i].x, ROLE_POSITIONS_BY_UNIT532[i].y)
        elseif _formationRight == PositionHelper.FORMATION_5_2_3 then
            rights[i] = cc.p(rightUnitX + ROLE_POSITIONS_BY_UNIT523[i].x, ROLE_POSITIONS_BY_UNIT523[i].y)
        end
    end
end

function PositionHelper.getCenter()
    return center
end

--左边队伍中心点
function PositionHelper.getLeftCenter()
    return leftCenter
end

--右边队伍中心点
function PositionHelper.getRightCenter()
    return rightCenter
end

--左边指定位置的坐标
function PositionHelper.getLeft(pos)
    return lefts[pos+1]
end

--右边指定位置的坐标
function PositionHelper.getRight(pos)
    return rights[pos+1]
end

--根据参考坐标类型获得在地图中的坐标
--type CoordSystemType
--offset Point
--role Role，type为ATTACK_POS或BEATTACK_POS时，必需传入role
function PositionHelper.getPositionByCoordType(type, offset, role, bodyLocation, executorSide)
    local position = offset or cc.p(0, 0)

    if type == CoordSystemType.SCREEN_CENTER then
        position = cc.pAdd(center,position)
    elseif type == CoordSystemType.MY_TEAM_CENTER then
        if executorSide == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(rightCenter,position)
        else
            position = cc.pAdd(leftCenter,position)
        end
    elseif type == CoordSystemType.OPPO_TEAM_CENTER then
        if executorSide == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(leftCenter,position)
        else
            position = cc.pAdd(rightCenter,position)
        end
    elseif role then
        if type == CoordSystemType.ATTACK_POS then
            local centerInMap = role:getCenterPositionInMap()
            if role:getInfo().side == RoleInfo.SIDE_RIGHT then
                local pt = role:getCenterPosition()
                centerInMap.x = centerInMap.x - pt.x*2
            end
            position = cc.pAdd(centerInMap, position)
        elseif type == CoordSystemType.BEATTACK_POS then
            position = cc.pAdd(role:getCenterPositionInMap(bodyLocation), position)
        elseif type == CoordSystemType.ATTACK_BOTTOM_POS then
            position = cc.pAdd(cc.p(role:getPosition()), position)
        elseif type == CoordSystemType.BEATTACK_BOTTOM_POS then
            position = cc.pAdd(cc.p(role:getPosition()), position)
        end
    end

    return position
end

--获得特效的坐标点（该坐标点可能是地图上的坐标点，也可能是角色身上的坐标点）
--type CoordSystemType
--offset Point
--executorSide 执行技能的角色在哪一边
--role Role，特效的作用目标（不一定执行技能的角色）type为ATTACK_POS或BEATTACK_POS时，必需传入role
function PositionHelper.getPositionForEffect(type, offset, executorSide, role, direction, bodyLocation, showInMap)

    local position = offset or cc.p(0, 0)
    
    if type == CoordSystemType.SCREEN_CENTER then
        position = cc.pAdd(center,position)
    elseif type == CoordSystemType.MY_TEAM_CENTER then
        if executorSide == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(rightCenter,position)
        else
            position = cc.pAdd(leftCenter,position)
        end
    elseif type == CoordSystemType.OPPO_TEAM_CENTER then
        if executorSide == RoleInfo.SIDE_RIGHT then
            position = cc.pAdd(leftCenter,position)
        else
            position = cc.pAdd(rightCenter,position)
        end
    elseif type == CoordSystemType.ATTACK_POS then
        local pt = role:getCenterPosition()
        pt = cc.p(pt.x, pt.y)
        if executorSide == RoleInfo.SIDE_RIGHT then
            pt.x = -pt.x
        end
        position = cc.pAdd(pt, position)
        if showInMap then
            position = cc.pAdd(position, cc.p(role:getPosition()))
        end
    elseif type == CoordSystemType.BEATTACK_POS then
        position = cc.pAdd(role:getCenterPosition(bodyLocation), position)
        if showInMap then
            position = cc.pAdd(position, cc.p(role:getPosition()))
        end
    elseif type == CoordSystemType.ATTACK_BOTTOM_POS then
        if showInMap then
            position = cc.pAdd(position, cc.p(role:getPosition()))
        end
    elseif type == CoordSystemType.BEATTACK_BOTTOM_POS then
        if showInMap then
            position = cc.pAdd(position, cc.p(role:getPosition()))
        end
    end

    return position
end

-- 根据地图中的指定的单位的x坐标，返回指定位置的角色的坐标
function PositionHelper.getPositionByUnitX(side, pos, x)
    local pos = pos + 1
    if side == RoleInfo.SIDE_LEFT then
        if _formationLeft == PositionHelper.FORMATION_6_3_3 then
            return cc.p(x - ROLE_POSITIONS_BY_UNIT633[pos].x, ROLE_POSITIONS_BY_UNIT633[pos].y)
        elseif _formationLeft == PositionHelper.FORMATION_5_3_2 then
            return cc.p(x - ROLE_POSITIONS_BY_UNIT532[pos].x, ROLE_POSITIONS_BY_UNIT532[pos].y)
        elseif _formationLeft == PositionHelper.FORMATION_5_2_3 then
            return cc.p(x - ROLE_POSITIONS_BY_UNIT523[pos].x, ROLE_POSITIONS_BY_UNIT523[pos].y)
        end
    else
        if _formationRight == PositionHelper.FORMATION_6_3_3 then
            return cc.p(x + ROLE_POSITIONS_BY_UNIT633[pos].x, ROLE_POSITIONS_BY_UNIT633[pos].y)
        elseif _formationRight == PositionHelper.FORMATION_5_3_2 then
            return cc.p(x + ROLE_POSITIONS_BY_UNIT532[pos].x, ROLE_POSITIONS_BY_UNIT532[pos].y)
        elseif _formationRight == PositionHelper.FORMATION_5_2_3 then
            return cc.p(x + ROLE_POSITIONS_BY_UNIT523[pos].x, ROLE_POSITIONS_BY_UNIT523[pos].y)
        end
    end
end

--根据某个角色的位置获得该角色所在的单位的X坐标
function PositionHelper.getUnitXByPos(side, pos, roleX)
    local pos = pos + 1
    if side == RoleInfo.SIDE_LEFT then
        if _formationLeft == PositionHelper.FORMATION_6_3_3 then
            return roleX + ROLE_POSITIONS_BY_UNIT633[pos].x
        elseif _formationLeft == PositionHelper.FORMATION_5_3_2 then
            return roleX + ROLE_POSITIONS_BY_UNIT532[pos].x
        elseif _formationLeft == PositionHelper.FORMATION_5_2_3 then
            return roleX + ROLE_POSITIONS_BY_UNIT523[pos].x
        end
    else
        if _formationRight == PositionHelper.FORMATION_6_3_3 then
            return roleX - ROLE_POSITIONS_BY_UNIT633[pos].x
        elseif _formationRight == PositionHelper.FORMATION_5_3_2 then
            return roleX - ROLE_POSITIONS_BY_UNIT532[pos].x
        elseif _formationRight == PositionHelper.FORMATION_5_2_3 then
            return roleX - ROLE_POSITIONS_BY_UNIT523[pos].x
        end
    end
end

--获得左侧队伍到中心点的距离
function PositionHelper.getLeftUnitBetweenCenter()
    return _leftUnitBetweenCenter
end

--获得右侧队伍到中心点的距离
function PositionHelper.getRightUnitBetweenCenter()
    return _rightUnitBetweenCenter
end


return PositionHelper