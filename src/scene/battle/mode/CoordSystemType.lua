
--坐标系统类型，定义了战斗中的各个参考点类型
local CoordSystemType = {}

CoordSystemType.SCREEN_CENTER = 1   --屏幕中心点
CoordSystemType.MY_TEAM_CENTER = 2  --已方中心点
CoordSystemType.OPPO_TEAM_CENTER = 3 --对方中心点
CoordSystemType.ATTACK_POS = 4 --攻击者坐标点
CoordSystemType.BEATTACK_POS = 5   --受攻者坐标点
CoordSystemType.ATTACK_BOTTOM_POS = 6--"攻击者坐标",
CoordSystemType.BEATTACK_BOTTOM_POS = 7--"受击者坐标"
CoordSystemType.MIDDLE_ATTACK_BEATTACK = 8--"攻与受中间"

CoordSystemType.PLACE_MAP = 10001   --地图中
CoordSystemType.PLACE_ROLE = 10002  --角色身上

return CoordSystemType