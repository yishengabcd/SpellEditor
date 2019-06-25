local DramaFrameActionType = {}

DramaFrameActionType.ROLE_INIT = 1           --角色初始化
DramaFrameActionType.ROLE_ADD = 2            --添加角色
DramaFrameActionType.ROLE_MOVE = 3           --角色移动
DramaFrameActionType.ROLE_SPEAK = 4          --说话
DramaFrameActionType.PLAY_ACTION = 5         --调用动作
DramaFrameActionType.PLAY_EFFECT = 6         --调用特效
DramaFrameActionType.FLY_EFFECT = 7          --飞行特效（直线运动）
DramaFrameActionType.PLAY_SOUND = 8          --播放音效
DramaFrameActionType.MOVE_MAP = 9            --移动地图
DramaFrameActionType.ZOOM_MAP = 10           --缩放地图
DramaFrameActionType.FOCUS = 11              --聚焦
DramaFrameActionType.MISSILE = 12            --导弹
DramaFrameActionType.ADD_AFTERIMAGE = 13     --添加残影
DramaFrameActionType.REMOVE_AFTERIAGE = 14   --移除残影
DramaFrameActionType.RISE = 15               --上升
DramaFrameActionType.FALL = 16               --下落
DramaFrameActionType.CHANGE_POSITION = 17    --改变位置
DramaFrameActionType.ROTATION = 19           --旋转
DramaFrameActionType.SHAKE = 20              --震屏
DramaFrameActionType.BLACK_SCREEN = 21       --黑屏
DramaFrameActionType.REPLACE_BACKGROUND = 22 --更换背景
DramaFrameActionType.ROLE_DISAPPEAR = 23     --角色消失
DramaFrameActionType.CURTAIN = 24            --黑屏字幕
DramaFrameActionType.DIALOG = 25             --底部半身像对白

return DramaFrameActionType