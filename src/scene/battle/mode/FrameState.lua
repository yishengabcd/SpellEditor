local FrameState = {}

FrameState.NOTHINE = 0 --默认状态
FrameState.WEIGHT_KEY_FRAME = 1 --有内容的关键帧
FrameState.WEIGHT_LAST_FRAME = 2 --有内容的关建帧的延长帧
FrameState.WEIGHT_END_FRAME = 3 --有内容的关建帧的结束帧 
FrameState.EMPTY_KEY_FRAME = 4 --空白关键帧
FrameState.EMPTY_LAST_FRAME = 5 --空白关键帧的延长帧
FrameState.EMPTY_END_FRAME = 6 --空白关键帧的结束帧

return FrameState