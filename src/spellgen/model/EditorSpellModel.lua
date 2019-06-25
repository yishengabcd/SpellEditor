local EditorSpellModel = {};
local EventProtocol = require("src/utils/EventProtocol")
EventProtocol.extend(EditorSpellModel)

--事件名称
EditorSpellModel.EDIT_SPELL_CHANGED = "editSpellChanged"
EditorSpellModel.LAYER_CHANGED = "layerChanged"
EditorSpellModel.FRAME_INDEX_CHANGED = "frameIndexChanged" --当前显示在时间轴的第几帧
EditorSpellModel.FRAME_SELECT = "frameSelect" --选择了某一帧（或取消选择）
EditorSpellModel.ROLE_CHANGED = "leftRoleChanged" --左边角色更换

local SpellModel = require("src/scene/battle/data/SpellModel")
local EditorSpellTemplateExtend = require("spellgen.helper.EditorSpellTemplateExtend")
local SpellTemplateExtend = require("src/scene/battle/mode/SpellTemplateExtend")
SpellModel.load();

--技能的编辑数据，描述了所有技能的编辑内容
local spells = SpellModel.getSpellDatas()

for i, v in ipairs(spells) do
    EditorSpellTemplateExtend.extend(v)
end

--[[
技能编辑数据结构设计
--local EditorSpellsData = {
--    {
--        id=1001,
--        layers = {
--            {
--                layerName = "图层1",
--                frames = { 
--                    {
--                        frame = 1,
--                        type = 1,
--                    }
--                }
--            }
--        }
--    }
--}
--
--return EditorSpellsData
--]]

local currEditSpell = nil


function EditorSpellModel.getSpells()
    return spells
end


function EditorSpellModel.addSpell(itemData)
    for i, v in ipairs(spells) do
    	if v.id == itemData.id then
    	   return false
    	end
    end
    table.insert(spells,itemData)
    SpellTemplateExtend.extend(itemData)
    EditorSpellTemplateExtend.extend(itemData)
    return true
end

function EditorSpellModel.removeSpell(itemData)
    for i, v in ipairs(spells) do
        if v.id == itemData.id then
            table.remove(spells,i)
            break;
        end
    end
end

function EditorSpellModel.isExist(id)
    for i, v in ipairs(spells) do
        if v.id == id then
            return true
        end
    end
    return false
end

function EditorSpellModel.setEditSpell(itemData)
    EditorSpellModel.reset()
    currEditSpell = itemData
    local event = {name=EditorSpellModel.EDIT_SPELL_CHANGED}
    EditorSpellModel:dispatchEvent(event)
end

function EditorSpellModel.getEditSpell()
    return currEditSpell
end

local selectedLayer = nil
local selectedFrameIndex = nil
local currentFrame = 1
--设置当前选择中图层和帧
function EditorSpellModel.setSelectedFrame(layer, frameIndex)
    selectedLayer = layer
    selectedFrameIndex = frameIndex
    
    if frameIndex then
        EditorSpellModel.setCurrentFrameIndex(frameIndex)
    end
    
    local event = {name = EditorSpellModel.FRAME_SELECT}
    EditorSpellModel:dispatchEvent(event)
end

--获得选择的帧的信息，返回帧所在的层和帧所在的索引
function EditorSpellModel.getSelectedFrame()
    return selectedLayer, selectedFrameIndex
end

--返回正在编辑的帧（选择的帧所属的关键帧）
function EditorSpellModel.getSelectedKeyFrame()
    if selectedLayer == nil or selectedFrameIndex == nil then
        return nil
    end
    return selectedLayer:getKeyFrame(selectedFrameIndex)
end

function EditorSpellModel.changeLeftRole(path)
    currEditSpell.leftRolePath = path
    local event = {name = EditorSpellModel.ROLE_CHANGED}
    EditorSpellModel:dispatchEvent(event)
end

function EditorSpellModel.changeRightRole(path)
    currEditSpell.rightRolePath = path
    local event = {name = EditorSpellModel.ROLE_CHANGED}
    EditorSpellModel:dispatchEvent(event)
end

function EditorSpellModel.setCurrentFrameIndex(index)
    if currentFrame ~= index then
        currentFrame = index
        local event = {name=EditorSpellModel.FRAME_INDEX_CHANGED}
        EditorSpellModel:dispatchEvent(event)
    end
end

function EditorSpellModel.reset()
    selectedLayer = nil
    selectedFrameIndex = nil
    currentFrame = 1
end

function EditorSpellModel.getCurrentFrameIndex()
    return currentFrame
end


return EditorSpellModel