--地图元素的行为类型
local MapItemBehaviorType = {}

MapItemBehaviorType.MOVE = 1 --移动到某坐标
MapItemBehaviorType.SCALE = 2 --放大缩小
MapItemBehaviorType.OPACITY = 3 --透明度变化
MapItemBehaviorType.MOTION = 4 --骨骼动画播放动作

MapItemBehaviorType.SPACE = 100 --空白


return MapItemBehaviorType