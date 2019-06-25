local CustomButton = require("components.CustomButton")
local ContextMenu = require("components.ContextMenu")
local SpellSelectWin = require("spellgen.view.SpellSelectWin")
local SpellsDataHelper = require("spellgen.helper.SpellsDataHelper")

local EditorSpellModel = require("spellgen.model.EditorSpellModel")
local FrameActionDataBuilder = require("spellgen.helper.FrameActionDataBuilder")
local FrameActionType = require("src/scene/battle/mode/FrameActionType")
local BattleMgr = require("src/scene/battle/manager/BattleMgr")
local RoleAndMapWin = require("spellgen.view.RoleAndMapWin")
local RoleEditWin = require("spellgen.view.RoleEditWin")
local JoinSpellEditWin = require("spellgen.view.JoinSpellEditWin")
local RoleMotionEditWin = require("spellgen.view.RoleMotionEditWin")

local EffectSelectWin = require("spellgen.view.EffectSelectWin")
local PreviewWindow = require("spellgen.view.PreviewWindow")
local CanselAndResum = require("src/spellgen/view/CanselAndResum")
local SpellSelectRoleWin = require("spellgen.view.SpellSelectRoleWin")

local SpellGenTopBar = class("SpellGenTopBar", function ()
    return ccui.HBox:create()
end)
local Btns = {
    SaveMenu = "保存",
    EditMenu = "编辑",
    EventMenu = "事件",
    PreviewMenu = "预览",
}
--用于排序菜单项
local MenuSort = {
    Btns.SaveMenu,Btns.EditMenu, Btns.EventMenu, Btns.PreviewMenu
}

local EditMenuItems = 
    {
        SpellSelectMenu = "技能选择",
        RoleAndMapMenu = "角色选择",
        RoleEditMenu = "角色坐标编辑",
        RoleMotionEditMenu = "角色动作编辑",
        JoinSpellEditMenu = "连携效果编辑",
        CancelEdit = "撤销操作",
        ReturnEdit = "还原操作"
    }

local EventMenuItems = 
    {
        MoveForward = "冲向目标",
        Action = "调用动作",
        Effect = "调用特效",
        FlyEffect = "飞行特效",
        Hurt = "受击",
        MoveBack = "返回原点",
        BlackScreen = "黑屏",
        Sound = "播放音效",
        Shake = "震屏",
        MoveMap = "地图移动",
        ZoomMap = "地图缩放",
        MapReset = "地图还原",
        Focus = "聚焦",
        Jump = "跳向目标",
        JumpBack = "跳回原地",
        HideRole = "隐藏角色",
        SpeedAdjust = "速度调节",
        AddAfterimage = "添加残影",
        RemoveAfterimage = "移除残影",
        Rise = "上升",
        Fall = "下落",
        FlyOut = "飞出",
        ChangeColor = "变色",
        ChangePosition = "改变位置",
        BodySeparate = "分身",
        Missile = "导弹",
        CreateCopy = "创建分身",
        RemoveCopy = "移除分身",
        FlyOff = "击退",
        Rotation = "内部旋转",
        RoleShake = "角色震动",
        AddGhostShadow = "添加残影2",
        RemoveGhostShadow = "移除残影2",
        ReplaceBackground = "更换背景",
        LevelAdjust = "层次调整",
        CallRole = "添加角色",
        RemoveRole = "移除角色",
        EffectAdjust = "特效调整",
        Finish = "完成"
    }
local PreviewMenuItems = 
    {
        PreviewCurrentSpellMenu = "预览当前技能",
        PreviewBattleConfigMenu = "预览配置战斗"
    }
local frameActionMapping = {
    [FrameActionType.MOVE_FORWARD] = EventMenuItems.MoveForward,
    [FrameActionType.PLAY_ACTION] = EventMenuItems.Action,
    [FrameActionType.PLAY_EFFECT] = EventMenuItems.Effect,
    [FrameActionType.FLY_EFFECT] = EventMenuItems.FlyEffect,
    [FrameActionType.HURT] = EventMenuItems.Hurt,
    [FrameActionType.MOVE_BACK] = EventMenuItems.MoveBack,
    [FrameActionType.BLACK_SCREEN] = EventMenuItems.BlackScreen,
    [FrameActionType.PLAY_SOUND] = EventMenuItems.Sound,
    [FrameActionType.SHAKE] = EventMenuItems.Shake,
    [FrameActionType.MOVE_MAP] = EventMenuItems.MoveMap,
    [FrameActionType.ZOOM_MAP] = EventMenuItems.ZoomMap,
    [FrameActionType.MAP_RESET] = EventMenuItems.MapReset,
    [FrameActionType.FOCUS] = EventMenuItems.Focus,
    [FrameActionType.JUMP] = EventMenuItems.Jump,
    [FrameActionType.JUMP_BACK] = EventMenuItems.JumpBack,
    [FrameActionType.HIDE_ROLE] = EventMenuItems.HideRole,
    [FrameActionType.SPEED_ADJUST] = EventMenuItems.SpeedAdjust,
    [FrameActionType.ADD_AFTERIMAGE] = EventMenuItems.AddAfterimage,
    [FrameActionType.REMOVE_AFTERIAGE] = EventMenuItems.RemoveAfterimage,
    [FrameActionType.RISE] = EventMenuItems.Rise,
    [FrameActionType.FALL] = EventMenuItems.Fall,
    [FrameActionType.FLY_OUT] = EventMenuItems.FlyOut,
    [FrameActionType.CHANGE_COLOR] = EventMenuItems.ChangeColor,
    [FrameActionType.CHANGE_POSITION] = EventMenuItems.ChangePosition,
    [FrameActionType.BODY_SEPARATE] = EventMenuItems.BodySeparate,
    [FrameActionType.MISSILE] = EventMenuItems.Missile,
    [FrameActionType.CREATE_COPY] = EventMenuItems.CreateCopy,
    [FrameActionType.REMOVE_COPY] = EventMenuItems.RemoveCopy,
    [FrameActionType.FLY_OFF] = EventMenuItems.FlyOff,
    [FrameActionType.ROTATION] = EventMenuItems.Rotation,
    [FrameActionType.ROLE_SHAKE] = EventMenuItems.RoleShake,
    [FrameActionType.ADD_GHOST_SHADOW] = EventMenuItems.AddGhostShadow,
    [FrameActionType.REMOVE_GHOST_SHADOW] = EventMenuItems.RemoveGhostShadow,
    [FrameActionType.REPLACE_BACKGROUND] = EventMenuItems.ReplaceBackground,
    [FrameActionType.LEVEL_ADJUST] = EventMenuItems.LevelAdjust,
    [FrameActionType.CALL_ROLE] = EventMenuItems.CallRole,
    [FrameActionType.REMOVE_ROLE] = EventMenuItems.RemoveRole,
    [FrameActionType.EFFECT_ADJUST] = EventMenuItems.EffectAdjust,
    [FrameActionType.FINISH] = EventMenuItems.Finish
}

function SpellGenTopBar.getFrameActionName(type)
    return frameActionMapping[type]
end


function SpellGenTopBar:ctor()
    local function onBtnClick(target)
        if target:getTitleText() == Btns.EditMenu then
            self:showEditMenu(target)
            --点击编辑不能让撤销还原为空
        elseif target:getTitleText() == Btns.SaveMenu then
            SpellsDataHelper.save()
            CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.NULLTYPE)
            --点击保存清除所有撤销还原表
            CanselAndResum:ClearAllCansel()
            CanselAndResum:ClearAllResum()
            CanselAndResum:ClearAllCanselEvent()
            CanselAndResum:ClearAllResumEvent()
            CanselAndResum:ClearAllCanselLayer()
            CanselAndResum:ClearAllResumLayer()
        elseif target:getTitleText() == Btns.EventMenu then
            self:showEventMenu(target)
            CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.EVENTTYPE)
            CanselAndResum:ClearAllCanselLayer()
            CanselAndResum:ClearAllResumLayer()
        elseif target:getTitleText() == Btns.PreviewMenu then
            self:showPreviewMenu(target)
            --CanselAndResum:setCurrentEdittype(CanselAndResum.Enum.NULLTYPE)
           -- CanselAndResum:ClearAllCanselLayer()
            --CanselAndResum:ClearAllResumLayer()
        end
    end
    for key, var in ipairs(MenuSort) do
        local btn = CustomButton.new(var, onBtnClick)
        self:addChild(btn)
    end
    self.EventMenuItems = EventMenuItems
    self._playing = false
end

function SpellGenTopBar:showEditMenu(target)
    local function onMenuItemClick(label)
        if label == EditMenuItems.SpellSelectMenu then
            local win = SpellSelectWin.new()
            win:show(true)
            CanselAndResum:ClearAllCansel()
            CanselAndResum:ClearAllResum()
            CanselAndResum:ClearAllCanselEvent()
            CanselAndResum:ClearAllResumEvent()
            CanselAndResum:ClearAllCanselLayer()
            CanselAndResum:ClearAllResumLayer()
        elseif label == EditMenuItems.RoleAndMapMenu then
            if EditorSpellModel.getEditSpell() then
                local win = RoleAndMapWin.new()
                win:show(true)
            else
                Message.show("请先选择技能")
            end
        elseif label == EditMenuItems.RoleEditMenu then
            local win = RoleEditWin.new()
            win:show(true)
        elseif label == EditMenuItems.RoleMotionEditMenu then
            local win = RoleMotionEditWin.new()
            win:show(true)
        elseif label == EditMenuItems.JoinSpellEditMenu then
            local win = JoinSpellEditWin.new()
            win:show(true)
        elseif label == EditMenuItems.CancelEdit then
            --撤销上一步操作（限时间轴）
            CanselAndResum:Cansel()
        elseif label == EditMenuItems.ReturnEdit then
            --还原撤销
            CanselAndResum:Resum()
        end
    end

    local menu = {
        EditMenuItems.SpellSelectMenu,
        EditMenuItems.RoleAndMapMenu,
        EditMenuItems.RoleEditMenu,
        EditMenuItems.RoleMotionEditMenu,
        EditMenuItems.JoinSpellEditMenu,
        EditMenuItems.CancelEdit,
        EditMenuItems.ReturnEdit
    }
    ContextMenu.showMenu(menu, onMenuItemClick,target)
end

function SpellGenTopBar:showEventMenu(target)
    if EditorSpellModel.getEditSpell() == nil then
        Message.show("请先选择要编辑的技能")
        return
    end
    local function onMenuItemClick(label)
        local selectedLayer, frameIndex = EditorSpellModel.getSelectedFrame()
        if selectedLayer == nil then
            Message.show("请选择要在哪一帧添加")
            return
        end
        if selectedLayer:checkAddAction(frameIndex) == 1 then
            Message.show("该帧已经存在动作")
            return
        end
        
        local action
        
        local function onSelectEffect(data,type)
            action = FrameActionDataBuilder.create(type,data)
            selectedLayer:addAction(frameIndex, action)
            EventGlobal:dispatchEvent({name = "AddAction"})
            BattleMgr.getBattle():refresh();
        end
        
        local function onRoleSelected(data, type)
            action = FrameActionDataBuilder.create(type,data)
            selectedLayer:addAction(frameIndex, action)
            EventGlobal:dispatchEvent({name = "AddAction"})
            BattleMgr.getBattle():refresh();
        end
        
        local needRefresh = true
        if label == EventMenuItems.MoveForward then
            action = FrameActionDataBuilder.create(FrameActionType.MOVE_FORWARD)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.MoveForward})
        elseif label == EventMenuItems.Action then
            action = FrameActionDataBuilder.create(FrameActionType.PLAY_ACTION)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Action})
        elseif label == EventMenuItems.Effect then
            local win = EffectSelectWin.new(onSelectEffect,FrameActionType.PLAY_EFFECT)
            win:show(true)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Effect})
        elseif label == EventMenuItems.FlyEffect then
            local win = EffectSelectWin.new(onSelectEffect,FrameActionType.FLY_EFFECT)
            win:show(true)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.FlyEffect})
        elseif label == EventMenuItems.Hurt then
            local win = EffectSelectWin.new(onSelectEffect,FrameActionType.HURT)
            win:show(true)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Hurt})
        elseif label == EventMenuItems.Finish then
            action = FrameActionDataBuilder.create(FrameActionType.FINISH)
            needRefresh = false
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Finish})
        elseif label == EventMenuItems.MoveBack then
            action = FrameActionDataBuilder.create(FrameActionType.MOVE_BACK)
            needRefresh = false
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.MoveBack})
        elseif label == EventMenuItems.BlackScreen then
            action = FrameActionDataBuilder.create(FrameActionType.BLACK_SCREEN)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.BlackScreen})
        elseif label == EventMenuItems.Sound then
            action = FrameActionDataBuilder.create(FrameActionType.PLAY_SOUND)
            needRefresh = false
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Sound})
        elseif label == EventMenuItems.Shake then
            action = FrameActionDataBuilder.create(FrameActionType.SHAKE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Shake})
        elseif label == EventMenuItems.MoveMap then
            action = FrameActionDataBuilder.create(FrameActionType.MOVE_MAP)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.MoveMap})
        elseif label == EventMenuItems.ZoomMap then
            action = FrameActionDataBuilder.create(FrameActionType.ZOOM_MAP)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.ZoomMap})
        elseif label == EventMenuItems.MapReset then
            action = FrameActionDataBuilder.create(FrameActionType.MAP_RESET)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.MapReset})
        elseif label == EventMenuItems.Focus then
            action = FrameActionDataBuilder.create(FrameActionType.FOCUS)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Focus})
        elseif label == EventMenuItems.Jump then
            action = FrameActionDataBuilder.create(FrameActionType.JUMP)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Jump})
        elseif label == EventMenuItems.JumpBack then
            action = FrameActionDataBuilder.create(FrameActionType.JUMP_BACK)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.JumpBack})
        elseif label == EventMenuItems.HideRole then
            action = FrameActionDataBuilder.create(FrameActionType.HIDE_ROLE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.HideRole})
        elseif label == EventMenuItems.SpeedAdjust then
            action = FrameActionDataBuilder.create(FrameActionType.SPEED_ADJUST)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.SpeedAdjust})
        elseif label == EventMenuItems.AddAfterimage then
            action = FrameActionDataBuilder.create(FrameActionType.ADD_AFTERIMAGE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.AddAfterimage})
        elseif label == EventMenuItems.RemoveAfterimage then
            action = FrameActionDataBuilder.create(FrameActionType.REMOVE_AFTERIAGE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.RemoveAfterimage})
        elseif label == EventMenuItems.Rise then
            action = FrameActionDataBuilder.create(FrameActionType.RISE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Rise})
        elseif label == EventMenuItems.Fall then
            action = FrameActionDataBuilder.create(FrameActionType.FALL)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Fall})
        elseif label == EventMenuItems.FlyOut then
            action = FrameActionDataBuilder.create(FrameActionType.FLY_OUT)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.FlyOut})
        elseif label == EventMenuItems.ChangeColor then
            action = FrameActionDataBuilder.create(FrameActionType.CHANGE_COLOR)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.ChangeColor})
        elseif label == EventMenuItems.ChangePosition then
            action = FrameActionDataBuilder.create(FrameActionType.CHANGE_POSITION)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.ChangePosition})
        elseif label == EventMenuItems.BodySeparate then
            action = FrameActionDataBuilder.create(FrameActionType.BODY_SEPARATE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.BodySeparate})
        elseif label == EventMenuItems.Missile then
            local win = EffectSelectWin.new(onSelectEffect,FrameActionType.MISSILE)
            win:show(true)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Missile})
        elseif label == EventMenuItems.CreateCopy then
            action = FrameActionDataBuilder.create(FrameActionType.CREATE_COPY)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.CreateCopy})
        elseif label == EventMenuItems.RemoveCopy then
            action = FrameActionDataBuilder.create(FrameActionType.REMOVE_COPY)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.RemoveCopy})
        elseif label == EventMenuItems.FlyOff then
            action = FrameActionDataBuilder.create(FrameActionType.FLY_OFF)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.FlyOff})
        elseif label == EventMenuItems.Rotation then
            action = FrameActionDataBuilder.create(FrameActionType.ROTATION)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.Rotation})
        elseif label == EventMenuItems.RoleShake then
            action = FrameActionDataBuilder.create(FrameActionType.ROLE_SHAKE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.RoleShake})
        elseif label == EventMenuItems.AddGhostShadow then
            action = FrameActionDataBuilder.create(FrameActionType.ADD_GHOST_SHADOW)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.AddGhostShadow})
        elseif label == EventMenuItems.RemoveGhostShadow then
            action = FrameActionDataBuilder.create(FrameActionType.REMOVE_GHOST_SHADOW)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.RemoveGhostShadow})
        elseif label == EventMenuItems.ReplaceBackground then
            local win = EffectSelectWin.new(onSelectEffect,FrameActionType.REPLACE_BACKGROUND)
            win:show(true)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.ReplaceBackground})
        elseif label == EventMenuItems.LevelAdjust then
            action = FrameActionDataBuilder.create(FrameActionType.LEVEL_ADJUST)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.LevelAdjust})
        elseif label == EventMenuItems.CallRole then
            local win = SpellSelectRoleWin.new(onRoleSelected, FrameActionType.CALL_ROLE)
            win:show(true)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.CallRole})
        elseif label == EventMenuItems.RemoveRole then
            action = FrameActionDataBuilder.create(FrameActionType.REMOVE_ROLE)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.RemoveRole})
        elseif label == EventMenuItems.EffectAdjust then
            action = FrameActionDataBuilder.create(FrameActionType.EFFECT_ADJUST)
            CanselAndResum:SetCurrentEnumEvent({["type"]= EventMenuItems.EffectAdjust})
        end
        
        if label ~= EventMenuItems.Effect 
            and label ~= EventMenuItems.FlyEffect 
            and label ~= EventMenuItems.Hurt 
            and label ~= EventMenuItems.Missile 
            and label ~= EventMenuItems.ReplaceBackground
            and label ~= EventMenuItems.CallRole then
            selectedLayer:addAction(frameIndex, action)
            EventGlobal:dispatchEvent({name = "AddAction"})
            if needRefresh then
                BattleMgr.getBattle():refresh();
            end
        end
    end

    local menu = {
        EventMenuItems.MoveForward,
        EventMenuItems.Action,
        EventMenuItems.Effect,
        EventMenuItems.FlyEffect,
        EventMenuItems.Hurt,
        --EventMenuItems.Finish,
        EventMenuItems.MoveBack,
        EventMenuItems.BlackScreen,
        EventMenuItems.Sound,
        EventMenuItems.Shake,
        EventMenuItems.MoveMap,
        EventMenuItems.ZoomMap,
        EventMenuItems.MapReset,
        EventMenuItems.Focus,
        EventMenuItems.Jump,
        EventMenuItems.JumpBack,
        EventMenuItems.HideRole,
        EventMenuItems.SpeedAdjust,
        EventMenuItems.AddAfterimage,
        EventMenuItems.RemoveAfterimage,
        EventMenuItems.Rise,
        EventMenuItems.Fall,
        --EventMenuItems.FlyOut,
        EventMenuItems.ChangeColor,
        EventMenuItems.ChangePosition,
        EventMenuItems.BodySeparate,
        EventMenuItems.Missile,
        EventMenuItems.CreateCopy,
        EventMenuItems.RemoveCopy,
        EventMenuItems.FlyOff,
        EventMenuItems.Rotation,
        EventMenuItems.RoleShake,
        EventMenuItems.AddGhostShadow,
        EventMenuItems.RemoveGhostShadow,
        EventMenuItems.ReplaceBackground,
        EventMenuItems.LevelAdjust,
        EventMenuItems.CallRole,
        EventMenuItems.RemoveRole,
        EventMenuItems.EffectAdjust
    }
    ContextMenu.showMenu(menu, onMenuItemClick,target)
end


function SpellGenTopBar:showPreviewMenu(target)
    local function onMenuItemClick(label)
        if label == PreviewMenuItems.PreviewCurrentSpellMenu then
            self:showPreview()
            if EditorSpellModel.getEditSpell() and not NON_AUTO_SAVE then
                SpellsDataHelper.save()
            end
        elseif label == PreviewMenuItems.PreviewBattleConfigMenu then
            self:showPreview(true)
        end
    end

    local menu = {
        PreviewMenuItems.PreviewCurrentSpellMenu,
        PreviewMenuItems.PreviewBattleConfigMenu
    }
    ContextMenu.showMenu(menu, onMenuItemClick,target)
end

function SpellGenTopBar:showPreview(composite)
    local function onPreviewWinClose()
        if self._battle then
            BattleMgr.setBattle(self._battle)--restore
        end
    
        TextInput.setTextInputVisible(true)
        BattleMgr.setEditing(true)
        self._playing = false
    end
    
    if EditorSpellModel.getEditSpell() or composite then
        if self._playing == false then
            self._playing = true
            
            if EditorSpellModel.getEditSpell() then
                self._battle = BattleMgr.getBattle()--cache
            end
            local win = PreviewWindow.new(onPreviewWinClose,composite)
            win:show(true)
            TextInput.setTextInputVisible(false)
            BattleMgr.setEditing(false)
        end
    end
end


return SpellGenTopBar