PLATFORM_WIN32 = "win32"
PLATFORM_MAC = "mac"

PLATFORM = PLATFORM_MAC

if PLATFORM == PLATFORM_MAC then
    RES_ROOT =  "/Users/huangyisheng/Documents/manor/client/Editor/LdEditor/res/"
else
    RES_ROOT =  "./res"
end

--配置右边角色路径
--CONFIG_LEFT_ROLE = "animation/boys/girl.ExportJson"
--CONFIG_RIGHT_ROLE = "animation/LD-Nanzhanshi/LD-Nanzhanshi.ExportJson"
CONFIG_LEFT_ROLE = "animation/hr004/hr004.ExportJson"
CONFIG_RIGHT_ROLE = "animation/hr004/hr004.ExportJson"
--美术资源路径，完整路径，所有的"\"都要改为"/",以“/”结束
ARTS_ROOT =  "/Users/huangyisheng/Documents/manor/ld_arts/"

LD_EDITOR = true --技能编辑标识
MAP_EDITOR = false --地图编辑标识
NON_AUTO_SAVE = true
