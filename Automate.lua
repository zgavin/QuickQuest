local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local AVAILABLE = [=[Interface\GossipFrame\AvailableQuestIcon]=]
local COMPLETE = [=[Interface\GossipFrame\ActiveQuestIcon]=]

function addon:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if(not IsShiftKeyDown()) then
			func(...)
		end
	end
end

addon:Register('GOSSIP_SHOW', function()
	for index = 1, NUMGOSSIPBUTTONS do
		local button = _G['GossipTitleButton' .. index]

		if(button and button:IsVisible()) then
			local icon = _G['GossipTitleButton' .. index .. 'GossipIcon']

			if(button.type == 'Available' and icon:GetTexture() == AVAILABLE) then
				return button:Click()
			elseif(button.type == 'Active' and icon:GetTexture() == COMPLETE) then
				return button:Click()
			end
		end
	end
end)

addon:Register('QUEST_DETAIL', function()
	if(QuestGetAutoAccept()) then
		HideUIPanel(QuestFrame)
	else
		AcceptQuest()
	end
end)

addon:Register('QUEST_PROGRESS', function()
	if(IsQuestCompletable()) then
		CompleteQuest()
	end
end)

addon:Register('QUEST_COMPLETE', function(...)
	if(GetNumQuestChoices() <= 1) then
		GetQuestReward(QuestFrameRewardPanel.itemChoice)
	end
end)

addon:Register('QUEST_AUTOCOMPLETE', function()
	for index = 1, GetNumAutoQuestPopUps() do
		local quest, type = GetAutoQuestPopUp(index)

		if(type == 'COMPLETE') then
			ShowQuestComplete(GetQuestLogIndexByID(quest))
		end
	end
end)

addon:Register('ITEM_PUSH', function(bag)
	-- This is some weird shit
	if(bag > 0) then
		bag = bag - CharacterBag0Slot:GetID() + 1
	end

	for slot = 1, GetContainerNumSlots(bag) do
		local _, id, active = GetContainerItemQuestInfo(bag, slot)
		if(id and not active) then
			UseContainerItem(bag, slot)
		end
	end
end)
