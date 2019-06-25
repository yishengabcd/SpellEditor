local FrameActionType = {}

FrameActionType.MOVE_FORWARD = 1        --冲向目标
FrameActionType.PLAY_ACTION = 2         --调用动作
FrameActionType.PLAY_EFFECT = 3         --调用特效
FrameActionType.FLY_EFFECT = 4          --飞行特效（直线运动）
FrameActionType.HURT = 5                --技能生效
FrameActionType.MOVE_BACK = 6           --返回原点
FrameActionType.BLACK_SCREEN = 7        --黑屏
FrameActionType.PLAY_SOUND = 8          --播放音效
FrameActionType.SHAKE = 9               --震屏
FrameActionType.MOVE_MAP = 10           --移动地图
FrameActionType.ZOOM_MAP = 11           --缩放地图
FrameActionType.MAP_RESET = 12          --地图还原
FrameActionType.FOCUS = 13              --聚焦
FrameActionType.JUMP =14                --跳向目标
FrameActionType.JUMP_BACK =15           --跳回原地
FrameActionType.HIDE_ROLE = 16          --隐藏角色
FrameActionType.SPEED_ADJUST = 17       --速度调节
FrameActionType.ADD_AFTERIMAGE = 18     --添加残影
FrameActionType.REMOVE_AFTERIAGE = 19   --移除残影
FrameActionType.RISE = 20               --上升
FrameActionType.FALL = 21               --下落
FrameActionType.FLY_OUT = 22            --飞出（受速度、摩擦力、重力加速度等影响）
FrameActionType.CHANGE_COLOR = 23       --改变攻击者的效果
FrameActionType.CHANGE_POSITION = 24    --改变位置
FrameActionType.BODY_SEPARATE = 25      --分身
FrameActionType.MISSILE = 26            --导弹
FrameActionType.CREATE_COPY = 27        --创建分身
FrameActionType.REMOVE_COPY = 28        --移除分身
FrameActionType.FLY_OFF = 29            --击退(飞出)
FrameActionType.ROTATION = 30           --旋转
FrameActionType.ROLE_SHAKE = 31         --角色震动
FrameActionType.ADD_GHOST_SHADOW = 32     --添加残影2
FrameActionType.REMOVE_GHOST_SHADOW = 33   --移除残影2
FrameActionType.REPLACE_BACKGROUND = 34    --更换背景
FrameActionType.LEVEL_ADJUST = 35          --层次调整
FrameActionType.CALL_ROLE = 36             --添加角色
FrameActionType.REMOVE_ROLE = 37             --添加角色
FrameActionType.EFFECT_ADJUST = 38         --特效调整


FrameActionType.FINISH = 99             --完成

return FrameActionType