local FrameActionDataBuilder = {}

local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local CoordSystemType = require("src/scene/battle/mode/CoordSystemType")
local MotionType = require("src/scene/battle/mode/MotionType")
local Role = require("src/scene/battle/mode/Role")
local ActionEaseType = require("src/scene/battle/mode/ActionEaseType")

function FrameActionDataBuilder.create(type, params)
    local action = {
        type = type
    } 
    if type == FrameActionType.MOVE_FORWARD then
        action.coord = CoordSystemType.BEATTACK_BOTTOM_POS --坐标参考点
--        action.duration = 0.3 --改为读取帧数 
        action.toX = -160 --前往的Ｘ坐标
        action.toY = 0  --前往的Ｙ坐标
        action.motion = MotionType.RUN --动作名称
        action.__defaultFrame = 10 --默认长度
    elseif type == FrameActionType.PLAY_ACTION then
        action.controlIds = nil --控制的对象,为空时表时只控制技能发动者
        action.motion = nil--MotionType.RUN --动作名称
        action.loop = 0 --是否循环播放,1是0非
        action.transition = -1 --从上一个动作到下一个动作的过渡帧
        action.playStandWhenEnd = 1--结束后是否播放站立动作
        action.startFrame = 1 --从第几帧开始播
--        action.keepTime = 0 --最后一帧定格时间
        action.__defaultFrame = 9 --默认长度
    elseif type == FrameActionType.PLAY_EFFECT then
        action.id = nil --特效ID
        action.controlIds = nil --控制的对象,为空时表时只控制技能发动者
        action.coord = params.coord --坐标参考点
        action.x = 0
        action.y = 0
        action.__defaultFrame = params.__defaultFrame
        action.scale = 1
        action.effect = params.effect --特效名称
        action.effectLevel = 1 --1表示角色前面，-1表示角色后面
        action.effectSpeed = 1 --特效播放速度
        action.effectLevelAddition = 0 --特效层级加成
        action.blendSrc = -1 --源混合因子
        action.blendDst = -1 --目标混合因子
        action.rotation = 0 --旋转角度
        action.bodyLocation = 0 --是否以实际身体作为参考，当角色飘移时，坐标是不变的，而是内部的身体在移动
        action.showInMap = 0 --是否显示在地图中,1是0非，只能以角色坐标为参考点时有效
        action.flipX = 0  --是否水平翻转1或0
    elseif type == FrameActionType.FLY_EFFECT then
        action.fromCoord = CoordSystemType.ATTACK_POS
        action.fromY = 0
        action.fromX = 0
        action.fromScale = 1
        
        action.toCoord = CoordSystemType.BEATTACK_POS
        action.toX = 0
        action.toY = 0
        action.toScale = 1
        action.toBodyLocation = 0 --是否以实际身体作为参考
        
--        action.duration = 0.3 --改为读时间轴长度
        action.effect = params.effect
        action.effectSpeed = 1 --特效播放速度
        action.blendSrc = -1 --源混合因子
        action.blendDst = -1 --目标混合因子
        action.duration = 0 --特效持续播放时间(秒)，为0时播放一次自动移除，大于0时，以该时间为准，时间结束即自动移除
        
        action.__defaultFrame = 6
    elseif type == FrameActionType.HURT then
        action.motion = MotionType.HURT --动作名称
        action.coord = params.coord --坐标参考点
        action.x = 0
        action.y = 0
        action.__defaultFrame = params.__defaultFrame
        action.scale = 1
        action.effect = params.effect --特效名称
        action.effectLevel = 1 --1表示角色前面，-1表示角色后面
        action.effectSpeed = 1 --特效播放速度
        action.blendSrc = -1 --源混合因子
        action.blendDst = -1 --目标混合因子
        action.playStandWhenEnd = 1--结束后是否播放站立动作
        action.bloodX = 0--掉血位置偏移X
        action.bloodY = 0--掉血位置偏移X
        action.startFrame = 1 --从第几帧开始播
    elseif type == FrameActionType.MOVE_BACK then
        action.__defaultFrame = 9
        action.motion = MotionType.RUN --动作名称
    elseif type == FrameActionType.BLACK_SCREEN then
        action.colorR = 0
        action.colorG = 0
        action.colorB = 0
        action.alpha = 0    --半透明度
        action.toAlpha = 255
--        action.duration = 0.3   --持续时间
        action.__defaultFrame = 9
    elseif type == FrameActionType.PLAY_SOUND then
        action.sound = ""
        action.__defaultFrame = 1
    elseif type == FrameActionType.SHAKE then
        action.strength = 20 --强度，以像素为单位
--        action.duration = 0.3 --持续时间
        action.decay = 0.85 --衰减系数
        action.__defaultFrame = 9
    elseif type == FrameActionType.MOVE_MAP then
        action.offsetX = -160 --移动的距离
--        action.coord = CoordSystemType.BEATTACK_BOTTOM_POS --坐标参考点
--        action.toX = -160 --前往的Ｘ坐标
--        action.toY = 0  --前往的Ｙ坐标
        action.tween = ActionEaseType.None
        action.forceCenter = 0 --是否强制居中（0或1,0表示非强制，1表示强制）
        action.__defaultFrame = 9
    elseif type == FrameActionType.ZOOM_MAP then
        action.zoom = 1.2 --缩放的最终比例
        action.centerX = 0 --缩放中心点Ｘ
        action.centerY = 0 --缩放中心点Ｙ
        action.coord = CoordSystemType.SCREEN_CENTER
        action.tween = ActionEaseType.None
        action.forceCenter = 0 --是否强制居中（0或1,0表示非强制，1表示强制）
        action.__defaultFrame = 9
    elseif type == FrameActionType.MAP_RESET then
        action.tween = ActionEaseType.None
        action.__defaultFrame = 9
        action.forceCenter = 0 --是否强制居中（0或1,0表示非强制，1表示强制）
    elseif type == FrameActionType.FOCUS then
        action.coord = CoordSystemType.ATTACK_POS --坐标参考点
        action.toX = 0
        action.toY = 0
        action.tween = ActionEaseType.None
        action.zoom = 1
        action.forceCenter = 0 --是否强制居中（0或1,0表示非强制，1表示强制）
        action.__defaultFrame = 9
    elseif type == FrameActionType.JUMP then
        action.coord = CoordSystemType.BEATTACK_BOTTOM_POS --坐标参考点
--        action.duration = 0.3 --改为读取帧数 
        action.takeOffPoint = 0 --起跳点（毫秒）
        action.motion = MotionType.JUMP
        action.startFrame = 1 --从第几帧开始播
        action.toX = -160 --前往的Ｘ坐标
        action.toY = 0  --前往的Ｙ坐标
        action.__defaultFrame = 10 --默认长度
    elseif type == FrameActionType.JUMP_BACK then
        action.motion = MotionType.JUMP
        action.startFrame = 1 --从第几帧开始播
        action.takeOffPoint = 0 --起跳点（毫秒）
        action.__defaultFrame = 9
    elseif type == FrameActionType.HIDE_ROLE then
        action.__defaultFrame = 9
    elseif type == FrameActionType.SPEED_ADJUST then
        action.fromSpeed = 1
        action.toSpeed = 1
        action.tween = ActionEaseType.None
        action.__defaultFrame = 9
    elseif type == FrameActionType.ADD_AFTERIMAGE then
        action.__defaultFrame = 1
    elseif type == FrameActionType.REMOVE_AFTERIAGE then
        action.__defaultFrame = 1   
    elseif type == FrameActionType.RISE then
        action.controlIds = nil --控制的对象,为空时表时只控制技能发动者
        action.targetType = 1 --作用目标类型,1 表示攻击者，2表示受击者
        action.height = 100 --高度位置
        action.tween = ActionEaseType.None
        action.__defaultFrame = 9 
    elseif type == FrameActionType.FALL then
        action.controlIds = nil --控制的对象,为空时表时只控制技能发动者
        action.targetType = 1 --作用目标类型,1 表示攻击者，2表示受击者
        action.height = 0 --高度位置
        action.tween = ActionEaseType.EaseExponentialIn
        action.__defaultFrame = 9
    elseif type == FrameActionType.FLY_OUT then
        action.targetType = 2 --作用目标类型,1 表示攻击者，2表示受击者
        action.direction = 180 --方向
        action.gravity = 9.8 --重力加速度系数
        action.speed = 10 --发射速度
        action.friction = 0 --摩擦力
        action.testHeight = 200 --测试高度
        action.__defaultFrame = 1
    elseif type == FrameActionType.CHANGE_COLOR then
        action.controlIds = nil --控制的对象,为空时表时只控制技能发动者
        action.colorR = 255
        action.colorG = 255
        action.colorB = 0
        action.__defaultFrame = 1
    elseif type == FrameActionType.CHANGE_POSITION then
        action.controlIds = nil --控制的对象,为空时表时只控制技能发动者
        action.targetType = 1 --作用目标类型,1 表示攻击者，2表示受击者
        action.direction = 0 --朝向，0不变，1左，2右
        action.coord = CoordSystemType.ATTACK_POS --坐标参考点
        action.toX = 0
        action.toY = 0
        action.hideBar = 1 --是否隐藏血条
        action.reset = 0 --是否是复位，为1时其他所有参数无效
        action.rotation = 0 
        action.__defaultFrame = 1
    elseif type == FrameActionType.BODY_SEPARATE then
        action.option = 1
        action.__defaultFrame = 1
    elseif type == FrameActionType.MISSILE then
        action.fromCoord = CoordSystemType.ATTACK_POS
        action.fromY = 0
        action.fromX = 0
        action.fromScale = 1

        action.toCoord = CoordSystemType.BEATTACK_POS
        action.toX = 0
        action.toY = 0
        action.toScale = 1

        action.effect = params.effect
        action.effectSpeed = 1 --特效播放速度
        action.blendSrc = -1 --源混合因子
        action.blendDst = -1 --目标混合因子
        
        action.tween = ActionEaseType.None
        action.controlPoint1X = 200
        action.controlPoint1Y = 200
        action.controlPoint2X = -200
        action.controlPoint2Y = 200
        
        action.effectLevel1 = 1
        action.effectLevel2 = 1

        action.__defaultFrame = 6
    elseif type == FrameActionType.CREATE_COPY then
        action.__defaultFrame = 1
        action.copyId = "" --分身ID
        action.motion = "" --动作名称
        action.coord = CoordSystemType.ATTACK_BOTTOM_POS --坐标参考点
        action.x = 0
        action.y = 0
        action.direction = 0 --朝向，0同主体，1左，2右
    elseif type == FrameActionType.REMOVE_COPY then
        action.__defaultFrame = 1
        action.copyIds = ""
    elseif type == FrameActionType.FLY_OFF then
        action.hitWallHeight = 100 --撞墙高度
        
        action.phase1Duration = 0.15 --阶段1时间（飞出到撞墙时间）
        action.phase1Motion = "" --阶段1动作
        
        action.phase2Duration = 0.2 --阶段2时间（落下时间）
        action.phase2Motion = "" --阶段2动作
        
        action.phase3Duration = 0.3 --阶段3时间（回到原位时间）
        action.phase3Motion = "" --阶段3动作
        
        action.__defaultFrame = 1
    elseif type == FrameActionType.ROTATION then
        action.controlIds = nil --控制的对象,为空时表时只控制技能发动者
        action.targetType = 2 --作用目标类型,1 表示攻击者，2表示受击者
        action.innerRotation = 90 --旋转角度
        action.__defaultFrame = 3
    elseif type == FrameActionType.ROLE_SHAKE then
        action.strength = 20 --强度，以像素为单位
        action.decay = 0.85 --衰减系数
        action.__defaultFrame = 9
    elseif type == FrameActionType.ADD_GHOST_SHADOW then
        action.__defaultFrame = 1
    elseif type == FrameActionType.REMOVE_GHOST_SHADOW then
        action.__defaultFrame = 1   
    elseif type == FrameActionType.REPLACE_BACKGROUND then
        action.x = 0
        action.y = 0
        action.fadeIn = 0.1 --淡入时间
        action.fadeOut = 0.1 --淡出时间
        action.effect = params.effect --特效名称
        action.scale = 1
        action.__defaultFrame = 20
    elseif type == FrameActionType.LEVEL_ADJUST then
        action.additionY = 0 --加成高度
        action.__defaultFrame = 1
    elseif type == FrameActionType.CALL_ROLE then
        action.x = 0
        action.y = 0
        action.coord = CoordSystemType.ATTACK_BOTTOM_POS --坐标参考点
        action.direction = Role.DIRECTION_RIGHT
        action.motion = params.motion
        action.callId = params.callId
        action.rolePath = params.rolePath
        action.__defaultFrame = 1
    elseif type == FrameActionType.REMOVE_ROLE then
        action.controlId = nil 
        action.__defaultFrame = 1
    elseif type == FrameActionType.EFFECT_ADJUST then
        action.controlId = nil 
        action.toAlpha = nil
        action.toScaleX = nil
        action.toScaleY = nil
        action.offsetX = nil
        action.offsetY = nil
        action.anchorX = nil
        action.anchorY = nil
        action.toRotation = nil
        action.__defaultFrame = 10
    elseif type == FrameActionType.FINISH then
        action.__defaultFrame = 1
    else
        Message.show("未定义动作")
    end
    
   return action
end
return FrameActionDataBuilder