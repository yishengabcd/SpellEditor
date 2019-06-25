
local EventProtocol = require("src/utils/EventProtocol")

--全局事件派发器
local GlobalEventDispatcher = {}
GlobalEventDispatcher.EVENT_JOIN_SPELL_FLASH = "eventJoinSpellFlash" --连携技出现时暂停时的闪光特效播放时派发
GlobalEventDispatcher.EVENT_SPELL_START = "eventSpellStart" --技能开始


EventProtocol.extend(GlobalEventDispatcher)

return GlobalEventDispatcher