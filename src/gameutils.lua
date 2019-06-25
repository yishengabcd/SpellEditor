require("src/Config")
require("src/utils/stringutil")

GameUtils = {}

--游戏中的文字字体
FONT_TYPE = {
    DEFAULT_FONT = "HelveticaNeue",
    DEFAULT_FONT_BOLD = "HelveticaNeue-Bold"
}
--游戏中的文字颜色
--在美术资源UI目录下ld_arts/ui/colout.png
FONT_COLOUR = {
    FONT_COLOUR_BLACK = cc.c3b(0, 0, 0),--黑色
    FONT_COLOUR_WHITE = cc.c3b(255,255,255), --白色
    FONT_COLOUR_RED = cc.c3b(255, 70, 5),--红色
    FONT_COLOUR_PINK_1 = cc.c3b(227, 205, 150), --粉色
    FONT_COLOUR_PINK_2 = cc.c3b(243, 190, 110), --粉色
    FONT_COLOUR_PINK_3 = cc.c3b(243, 213, 136), --粉色
    FONT_COLOUR_BROWN = cc.c3b(215, 185, 155), --咖啡色
    FONT_COLOUR_GREEN = cc.c3b(85, 220, 85), --绿色
    FONT_COLOUR_BLUE = cc.c3b(173, 210, 249), --蓝色
    FONT_COLOUR_QUALITY_WHITE = cc.c3b(255, 255, 255), --品质白
    FONT_COLOUR_QUALITY_GREEN = cc.c3b(0, 255, 0), --品质绿
    FONT_COLOUR_QUALITY_BLUE = cc.c3b(39, 201, 242), --品质蓝  
    FONT_COLOUR_QUALITY_PURPLE = cc.c3b(101, 83, 182), --品质紫  
    FONT_COLOUR_QUALITY_ORANGE = cc.c3b(254, 171, 65), --品质橙
    FONT_COLOUR_QUALITY_GOLD = cc.c3b(255, 255, 84), --品质金
}

function getColorByQuality(quality)
    if quality == ItemQualityType.ITEM_QUALITY_GREEN then
        return FONT_COLOUR.FONT_COLOUR_QUALITY_GREEN
    elseif quality == ItemQualityType.ITEM_QUALITY_BLUE then
        return FONT_COLOUR.FONT_COLOUR_QUALITY_BLUE
    elseif quality == ItemQualityType.ITEM_QUALITY_PURPLE then
        return FONT_COLOUR.FONT_COLOUR_QUALITY_PURPLE
    elseif quality == ItemQualityType.ITEM_QUALITY_ORANGE then
        return FONT_COLOUR.FONT_COLOUR_QUALITY_ORANGE
    elseif quality == ItemQualityType.ITEM_QUALITY_GOLD then
        return FONT_COLOUR.FONT_COLOUR_QUALITY_GOLD
    else
        return FONT_COLOUR.FONT_COLOUR_QUALITY_WHITE
    end
end

function GameUtils:new()
    print("GameUtils:new")
    local o = {}
    if Config.DEBUG then 
        o.m_vsn =  "1.0.0"
    else
        o.m_vsn =  getVersion() --app版本号，不是代码版本号
    end
    print("app版本号:" .. o.m_vsn)
    setmetatable(o,self)
    self.__index = self
    math.randomseed(os.time())
    
    return o

end

function GameUtils:getAppVersion()
    return self.m_vsn
end

function GameUtils:getInstance()
    if self.instance == nil then 
        self.instance = self:new()
    end
    return self.instance
end

function GameUtils:purgeGameUtils()
	self.instace = nil
end


function GameUtils:scaleToFitScreen(target, subW, subH)
    if subH == nil then 
        subH = 0
    end
    if subW == nil then
        subW = 0
    end
    local rate = 1
    local size = target:getContentSize()
    local winSize = cc.Director:getInstance():getWinSize()
    size.width = size.width - subW
    size.height = size.height - subH
    if size.width > winSize.width or size.height > winSize.height then
    	local rateW = winSize.width / size.width
    	local rateH = winSize.height / size.height
    	rate = math.min(rateH, rateW)
    	target:setScale(rate)
        local px, py = target:getPosition()
    end
    return rate
end

function GameUtils:printTab(tab)
  for i,v in pairs(tab) do
--    if type(v) == "table" then
--      print("table",i,"{")
--      self:printTab(v)
--      print("}")
--    else
--     print(v)
--    end
    print("key:" .. i .. " v:" .. v)
  end
end

---------------
--全局方法
---------------

-- 获取基类的某个方法
-- table C++类或者lua table
-- methodName 函数名，也可以是成员变量名
-- return 基类的函数或成员变量值（如果methodName为变量名）
--          nil 表示找不到
function getSuperMethod(table, methodName)
    local mt = getmetatable(table)
    local method = nil
    while mt and not method do
        method = mt[methodName]
        if not method then
            local index = mt.__index
            if index and type(index) == "function" then
                method = index(mt, methodName)
            elseif index and type(index) == "table" then
                method = index[methodName]
            end
        end
        mt = getmetatable(mt)
    end
    return method
end

--把图片变为灰白的，可以传plist路径进来，也可以传sprite进来

function spriteToGray(value)
	if type(value) == "string" then
        return spriteBecomeGray(cc.Sprite:createWithSpriteFrameName(value))
    else
        return spriteBecomeGray(value)
	end
end

--场景切换时，不会派发事件
function sendEvent(event)
    if type(event) == "string" then
        local e = cc.EventCustom:new(event)
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(e)
    else
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
    end
end

--监听事件，要和removeEventListener配对
function addEventListenerWithFixedPriority(eventlistener, index)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(eventlistener,index)
end

function removeEventListener(eventlistener)
    cc.Director:getInstance():getEventDispatcher():removeEventListener(eventlistener)
end

function addEventListenerWithSceneGraphPriority(listener,node)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,node)
end

--播放按钮声音
function playBtnEffect()
    AudioEngine.preloadEffect("music/ui_sound/btn_click.mp3")
    AudioEngine.playEffect("music/ui_sound/btn_click.mp3")
end

--用于包装回调函数，使其可以自身实例
--eg:ui.skill.skillwindow中：
--HeroDal:addEventListener(HeroDal.EVENT_SKILLPOINTINFO_CALLBACK, handler(self, self.onSkillPointUpdate))
function handler(target, method)
    return function(...)
        return method(target, ...)
    end
end

--取得table元素个数
function getTableSize(t)
    if not t then
        return 0
    end
    local index = 0
    for k, v in pairs(t) do
    	index = index + 1
    end
    return index
end
--------------
-- 与c++交互
--------------
function GameUtils:sendHttpRequest(url, cid, tryTimes)
    if not tryTimes then
        tryTimes = 5
    end
    httpClient(url, tryTimes, cid, "runCallBackFunc")
end

--注册到c++的回调方法id
G_CALLBACKFUNC_ID = 1       
G_CALLBACKFUNC_LIST = {}
G_SC_CALLBACKFUNC_LIST = {}

--后续扩展
local CALLBACKFUNC_TYPE_DEFAULT = 0

function GameUtils:addCallbackFun(func, type, data)
    G_CALLBACKFUNC_ID = G_CALLBACKFUNC_ID + 1
    if G_CALLBACKFUNC_LIST[G_CALLBACKFUNC_ID] == nil then
        G_CALLBACKFUNC_LIST[G_CALLBACKFUNC_ID] = {
            callback_func = func,
            callback_type = type or CALLBACKFUNC_TYPE_DEFAULT,
            callback_data = data,
            print("add c++ callback func_id:" .. G_CALLBACKFUNC_ID)
        }
    end
    return G_CALLBACKFUNC_ID
end

function delCallBackFunc(func_id)
    if G_CALLBACKFUNC_LIST[func_id] ~= nil then
        G_CALLBACKFUNC_LIST[func_id] = nil
        print("remove c++ callback 2 func_id:" .. func_id)
    end
end

function runCallBackFunc(func_id, ...)
    print("runCallBackFunc id:" .. func_id)
    if G_CALLBACKFUNC_LIST[func_id] ~= nil then
        if(G_CALLBACKFUNC_LIST[func_id].callback_func) then
            if G_CALLBACKFUNC_LIST[func_id].callback_data then
                G_CALLBACKFUNC_LIST[func_id].callback_func(G_CALLBACKFUNC_LIST[func_id].callback_data, ...)
            else
                G_CALLBACKFUNC_LIST[func_id].callback_func(...)
            end
            
        end
    else
        print("no register callback func_id:" .. func_id)
    end
end

function testCallback(func_id, code, content)
    print("func_id:" .. func_id .. " code:" .. code)
end


---------------------------
--@return #table 
function getWinSize()
	return cc.Director:getInstance():getWinSize()
end

---------------------------------
--通讯
---------------------------------


---------------------------
--@return #packetout 发送包
function getPacketout(code, size)
    return client.PacketOut:new(code, size, getMemoryPool())
end

function sendPacketout(packetout)
    sendPacketOut(packetout)
end

function removeScCallbackFun(code)
    G_SC_CALLBACKFUNC_LIST[code] = nil
end

function addScCallbackFun(code, func, target)
    if not code then
        local debuger = require("src/luadebug/luadebuger")
        debuger:showError("协议号为空》》》》 ")
        error("error: sc callback code has register:" .. code, 1)
        return
    end 
    if G_SC_CALLBACKFUNC_LIST[code] == nil then
        G_SC_CALLBACKFUNC_LIST[code] = {
            callback_func = func,
            callback_target = target,
        }
    else
        error("error: sc callback code has register:" .. code, 1)
    end
end

function runScCallBackFunc(func_id, ...)
    if G_SC_CALLBACKFUNC_LIST[func_id] ~= nil then
        if(G_SC_CALLBACKFUNC_LIST[func_id].callback_func) then
            if G_SC_CALLBACKFUNC_LIST[func_id].callback_target then
                G_SC_CALLBACKFUNC_LIST[func_id].callback_func(G_SC_CALLBACKFUNC_LIST[func_id].callback_target, ...)
            else
                G_SC_CALLBACKFUNC_LIST[func_id].callback_func(...)
            end

        end
    else
        print("no register sc callback code:" .. func_id)
    end
end

