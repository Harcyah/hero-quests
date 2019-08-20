
ZoneQuests = {}
ZoneQuests.__index = ZoneQuests

function ZoneQuests:Create(id, name)
	local this = {
		id = id,
		name = name,
		done = false
	}
	setmetatable(this, ZoneQuests)
	return this
end

local ZONE_QUESTS = {
	ZoneQuests:Create(1198, "Stormsong Valley"),
	ZoneQuests:Create(896, "Drustvar"),
	ZoneQuests:Create(895, "Tiragarde Sound"),
	ZoneQuests:Create(1193, "Zuldazar"),
	ZoneQuests:Create(1194, "Nazmir"),
	ZoneQuests:Create(1195, "Vol'dun"),
	ZoneQuests:Create(1462, "Mechagon Island"),
	ZoneQuests:Create(1355, "Nazjatar")
}

local function debug(str)
	DEFAULT_CHAT_FRAME:AddMessage('[debug] ' .. str, 0, 1, 0);
end

local function error(str)
	DEFAULT_CHAT_FRAME:AddMessage('[error] ' .. str, 1, 0, 0);
end

local function IsValidWorldQuest(questId)
	local isWorldQuest = QuestUtils_IsQuestWorldQuest(questId);
	if (isWorldQuest == false) then
		return false
	end

	local isComplete = IsQuestComplete(questId);
	if (isComplete == true) then
		return false
	end

	local hasRewards = GetNumQuestLogRewards(questId) > 0;
	if (hasRewards == false) then
		return false
	end

	local hasQuestData = HaveQuestData(questId)
	if (hasQuestData == false) then
		error(format('quest %d has no Quest data', questId))
		return false
	end

	local hasRewardData = HaveQuestRewardData(questId)
	if (hasRewardData == false) then
		error(format('quest %d has no Reward data', questId))
		return false
	end

	return isWorldQuest and not isComplete and hasRewards and hasQuestData and hasRewardData
end

local function PrintWorldQuestsOfRegion(zoneId, zoneName)
	local quests = C_TaskQuest.GetQuestsForPlayerByMapID(zoneId);

	if quests and #quests > 0 then
		for i, quest in ipairs(quests) do
			local questId = quest.questId;
			if (IsValidWorldQuest(questId)) then
				local questTitle = C_TaskQuest.GetQuestInfoByQuestID(questId);
				local itemIndex = QuestUtils_GetBestQualityItemRewardIndex(questId);
				local _, _, _, _, _, itemId, rewardItemLevel = GetQuestLogRewardInfo(itemIndex, questId);
				local _, itemLink, _, itemLevel, _, _, _, _, _, _, _, classId, _ = GetItemInfo(itemId);
				if (classId == LE_ITEM_CLASS_WEAPON or classId == LE_ITEM_CLASS_ARMOR) then
					local link = string.gsub(itemLink, ':' .. itemLevel .. ':', ':' .. rewardItemLevel .. ':')
					DEFAULT_CHAT_FRAME:AddMessage('[' .. zoneName .. '] > ' .. questTitle .. ' rewards : ' .. link, 0.976, 0.501, 0.062);
				end
			end
		end
	end
end

local playerReady = false
local chatReady = false

local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("UPDATE_CHAT_WINDOWS");
frame:RegisterEvent("QUEST_LOG_UPDATE");

frame:SetScript("OnEvent", function(self, event, ...)

	if (event == "PLAYER_ENTERING_WORLD") then
		playerReady = true
	end

	if (event == "UPDATE_CHAT_WINDOWS") then
		chatReady = true
	end

	if (event == "QUEST_LOG_UPDATE" and playerReady and chatReady) then
		for i, zq in ipairs(ZONE_QUESTS) do
			if (not zq.done) then
				PrintWorldQuestsOfRegion(zq.id, zq.name);
				zq.done = true
			end
		end
	end

end)
