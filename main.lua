local ADDON_NAME = 'NewMapPins'
local ADDON_VERSION = 'X'
local EVENT_NAMESPACE = ADDON_NAME..'_EVENT_NAMESPACE'

local function _t(filename)
	return ('/%s/textures/%s'):format(ADDON_NAME, filename)
end

local function _getFileName()
    return GetMapTileTexture():match('[^\\/]+$'):lower():gsub('%.dds$', ''):gsub('_[0-9]+$', '')
end

local function GetCroppedAchievementInfo(id)
    local name, _, _, icon = GetAchievementInfo(id)
    return (name:gsub('<<player{([^/}]+)/[^}]+}>>', '%1')), icon
end

local function ShowInformationTooltip(icon, name, ...)
	if IsInGamepadPreferredMode() then
		error('Not implemented')
		-- ZO_MapLocationTooltip_Gamepad:LayoutIconStringLine(ZO_MapLocationTooltip_Gamepad.tooltip, icon, zo_strformat("<<1>>", name), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapLocationTooltipWayshrineHeader"))
		-- if desc then
		-- 	ZO_MapLocationTooltip_Gamepad:LayoutIconStringLine(ZO_MapLocationTooltip_Gamepad.tooltip, nil, zo_strformat("<<1>>", desc), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapRecallCost"))
		-- end
		-- if desc1 then
		-- 	ZO_MapLocationTooltip_Gamepad:LayoutIconStringLine(ZO_MapLocationTooltip_Gamepad.tooltip, nil, zo_strformat("<<1>>", desc1), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapRecallCost"))
		-- end
	else
		-- InformationTooltip:AddLine(text, '', r, g, b, lineAnchor, modifyTextType, textAlignment, setToFullSize, minWidth, lineSpacing)
		InformationTooltip:AddLine(zo_strformat('<<1>> <<2>>',zo_iconFormat(icon, 24, 24), name), 'ZoFontGameOutline', ZO_SELECTED_TEXT:UnpackRGB())

		local texts = {...}
		for i = 1, table.maxn(texts) do
			ZO_Tooltip_AddDivider(InformationTooltip)
			InformationTooltip:AddLine(zo_strformat('<<1>>', texts[i]), '', ZO_HIGHLIGHT_TEXT:UnpackRGB())
		end
	end
end

local function GetSlotIndexForTrophyItemId(bagId, wantedItemId)
	for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, bagId)) do
		if itemData and itemData.itemType == ITEMTYPE_TROPHY then
			local itemId = GetItemId(bagId, itemData.slotIndex)
			if itemId == wantedItemId then
				return itemData.slotIndex
			end
		end
	end
end

-- ----------------------------------------------------------------------------

-- TODO: what 1..21 means? No 20?  #default_filters_initial
local DEFAULTS = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = false,
    [5] = true,
    [6] = false,
    [7] = true,
    [8] = true,
    [9] = false,
    [10] = false,
    [11] = false,
    [12] = false,
    [13] = false,
    [14] = false,
    [15] = false,
    [16] = false,
    [17] = false,
    [18] = false,
    [19] = false,
    [21] = true,
    TimeBreachClosed = {},
    Show = {},
    ColorLore = false,
    AllFish = false
}

local DEFAULTS_GLOBAL = {
    pinsize = 20,
}

local DEFAULT_PIN_SIZE = 20

-- TODO: #rearrange_pin_type_indices #add_new_pin_type
local DELVE_BOSSES = 1
local DELVE_BOSSES_DONE = 2
local SKYSHARDS = 3
local SKYSHARDS_DONE = 4  -- TODO: #skyshards_done_placeholder
local LOREBOOKS = 5
-- local LOREBOOKS_DONE = 1005
local TREASURE_MAPS = 6
local TREASURE_CHESTS = 7
local UNKNOWN_POI = 8
local UNDAUNTED = 9
local WORLD_ACHIEVEMENTS = 10
local ORSINIUM = 11
local THIEVES_GUILD = 12
local MORROWIND = 13
local SUMMERSET = 14
local TIME_RIFTS = 15
local SHRINES = 16
local FISHING_NODES = 17
local CLOCKWORK_CITY = 18
local MURKMIRE = 19
local ELSWEYR = 20
local VOLENDRUNG = 21
local MARKARTH = 22
local GREYMOOR = 23
local ANTIQUITIES = 24
local BLACKWOOD = 25
local IMPERIAL_CITY = 26
local PORTALS = 27
local HIGH_ISLE = 28
local FIRESONG = 29
local NECROM = 30
local GOLD_ROAD = 31
local SEASONS_OF_THE_WORM_CULT = 32
local DYNAMIC_ENCOUNTERS = 33

local PANEL_PVE = 'pvePanel'
local PANEL_PVP = 'pvpPanel'
local PANEL_IC = 'imperialPvPPanel'

-- local function _simpleCoordinatesFrom(table)
-- 	return function(self, canvas)
-- 		local map = _getFileName()
-- 		local pinData = MP[table][map]
-- 		for i = 1, #pinData do
-- 			local pinDatum = pinData[i]
-- 			canvas:Add(pinDatum[1], pinDatum[2], 0, 0, 32, 32, nil, {i, map})
-- 		end
-- 	end
-- end


local DUMMY_ITEM_LINK = '|H1:item:%d:359:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h'


local PinTypes = {}

PinTypes[DELVE_BOSSES] = {
	name = MAP_PINS_SI_DELVE_BOSSES,  -- TODO: think about direct GetText vs late evaluation
	labelIcon = '/esoui/art/icons/poi/poi_groupboss_incomplete.dds',  -- TODO: avoid duplication?
	maxDistance = 0.05,
	level = 30,
	texture = '/esoui/art/icons/poi/poi_groupboss_incomplete.dds',
	size = 25,
	coords = 'Bosses',
	panels = {PANEL_PVE, PANEL_PVP},
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['Bosses'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local achievementId, criterionIndex = pinDatum[3], pinDatum[4]
			local itemIds = pinDatum[5]
			local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
			if numCompleted ~= numRequired then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = {achievementId, criterionIndex, itemIds},
				}
			end
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			df('test test')
			local name, description, points, icon, completed, date, time = GetAchievementInfo(tag[1])

			local text1, text2
			if tag[3] then
				local temp = {'  Set items:'}
				for _, itemId in pairs(tag[3]) do
					temp[#temp+1] = DUMMY_ITEM_LINK:format(itemId)
				end
				text2 = table.concat(temp, '\n')
			else
				if tag[2] then
					text1 = GetAchievementCriterion(tag[1], tag[2])
				end
			end

			if tag[2] then
				name = ('[%d] %s'):format(tag[2], name)
			end

			ShowInformationTooltip(icon, name, text1, text2)
		end,
	},
}
-- TODO: STYLE IT LATER
PinTypes[DELVE_BOSSES_DONE] = {
	name = MAP_PINS_SI_DELVE_BOSSES_DONE,
	labelIcon = '/esoui/art/icons/poi/poi_groupboss_complete.dds',
	maxDistance = 0.05,
	level = 30,  -- TODO: never used yet
	texture = '/esoui/art/icons/poi/poi_groupboss_complete.dds',
	size = 25,
	panels = {PANEL_PVE, PANEL_PVP},
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['Bosses'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local achievementId, criterionIndex = pinDatum[3], pinDatum[4]
			local itemIds = pinDatum[5]
			local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
			if numCompleted == numRequired then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = {achievementId, criterionIndex, itemIds},
				}
			end
		end

		return out
	end,
	tooltip = PinTypes[DELVE_BOSSES].tooltip,
}

PinTypes[SKYSHARDS] = {
	name = MAP_PINS_SI_SKYSHARDS,
	labelIcon = _t('Skyshard_1.dds'),
	maxDistance = 0.05,
	level = 100,
	texture = _t('Skyshard_1.dds'),  -- TODO: #skyshard_seen_texture
	size = 28,
	panels = {PANEL_PVE, PANEL_PVP, PANEL_IC},
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['SkyShards'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local skyshardId = pinDatum[5]  -- TODO: what about 3 and 4? Why logic in legacy is so complex? Ask about DumbSkyshardFix #skyshard_parent_map_fix #skyshard_tooltip_legacy_fields
			local skyshardDiscoveryStatus = GetSkyshardDiscoveryStatus(skyshardId)
			if skyshardDiscoveryStatus ~= SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = {pinDatum[3], pinDatum[4], skyshardId},
				}
			end
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local name, description, points, icon, completed, date, time = GetAchievementInfo(tag[1])
			local text = GetSkyshardHint(tag[3])  -- TODO: is it OK?
			-- if tag[2] then text = GetAchievementCriterion(tag[1], tag[2]) end  -- TODO: is it OK?

			if tag[2] then
				name = ('[%d] %s'):format(tag[2], name)
			end

			ShowInformationTooltip(icon, name, text)
		end,
	},
}

PinTypes[SKYSHARDS_DONE] = {  -- TODO: #pintypes_skyshards_done_comment
	name = MAP_PINS_SI_SKYSHARDS_DONE,
	labelIcon = '/esoui/art/mappins/skyshard_complete.dds',
	maxDistance = 0.05,
	level = 100,
	texture = '/esoui/art/tutorial/gamepad/achievement_categoryicon_skyshards.dds',
	size = 28,  -- 1.38 * 20 - does 0.02 actually matter?
	panels = {PANEL_PVE, PANEL_PVP},
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['SkyShards'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local skyshardId = pinDatum[5]  -- TODO: what about 3 and 4? Why logic in legacy is so complex? Ask about DumbSkyshardFix
			local skyshardDiscoveryStatus = GetSkyshardDiscoveryStatus(skyshardId)
			if skyshardDiscoveryStatus == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = {pinDatum[3], pinDatum[4], skyshardId},
				}
			end
		end

		return out
	end,
	tooltip = PinTypes[SKYSHARDS].tooltip,
}

PinTypes[LOREBOOKS] = {
	name = MAP_PINS_SI_LOREBOOKS,
	labelIcon = _t('Lorebook_1.dds'),
	maxDistance = 0.05,
	level = 100,
	texture = _t('Lorebook_1.dds'),
	tint = ZO_ColorDef:New(.6, .6, 1, .8),
	panels = {PANEL_PVE, PANEL_PVP, PANEL_IC},
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['Lorebooks'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local collectionIndex, bookIndex = pinDatum[3], pinDatum[4]
			local title, icon, known, bookId = GetLoreBookInfo(1, collectionIndex, bookIndex)
			if not known then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = bookId,
				}
			end
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local categoryIndex, collectionIndex, bookIndex = GetLoreBookIndicesFromBookId(tag)
			local title, icon, known, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)

			local name = ('[%d] %s'):format(bookIndex, title)

			ShowInformationTooltip(icon, name)
		end,
	},
}

-- PinTypes_[LOREBOOKS_DONE] = {
--  name = MAP_PINS_SI_LOREBOOKS_DONE,
-- 	maxDistance=0.05,level=30,texture=texture('Lorebook_2.dds'),k=1,tint=ZO_ColorDef:New(.6,.6,1,.8)
--  coords = 'Lorebooks',
-- }

local TREASURE_MAP_TEXTURES = {
	['staff']    = 5,
    ['2hsword']  = 6,
    ['bow']      = 7,
    ['1haxe']    = 8,
    ['shield']   = 9,
    ['2haxe']    = 10,
    ['dagger']   = 11,
    ['1hhammer'] = 12,
    ['1hsword']  = 13,
    ['2hhammer'] = 14,
}

-- TODO: kinda meh because you have to keet it and table above in sync with atlas...
-- TODO: it can be not required, see `tooltip` question
local TREASURE_MAPS_ICONS = {
	_t('Treasure_1.dds'),
	_t('Treasure_2.dds'),
	_t('Treasure_3.dds'),
	_t('Treasure_4.dds'),
	'esoui/art/icons/gear_reach_staff_c.dds',
    'esoui/art/icons/gear_reach_2hsword_c.dds',
    'esoui/art/icons/gear_reach_bow_c.dds',
    'esoui/art/icons/gear_reach_1haxe_c.dds',
    'esoui/art/icons/gear_reach_shield_c.dds',
    'esoui/art/icons/gear_reach_2haxe_c.dds',
    'esoui/art/icons/gear_reach_dagger_c.dds',
    'esoui/art/icons/gear_reach_1hhammer_c.dds',
    'esoui/art/icons/gear_reach_1hsword_c.dds',
    'esoui/art/icons/gear_reach_2hhammer_c.dds',
}

PinTypes[TREASURE_MAPS] = {
	name = MAP_PINS_SI_TREASURE_MAPS,
	labelIcon = _t('Treasure_1.dds'),
	maxDistance = 0.05,
	level = 101,
	-- texture = function(self) return self.m_PinTag.texture end,
	size = 28,
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	panels = {PANEL_PVE, PANEL_PVP},
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['TreasureMaps'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		-- TODO: have not checked if it can be optimized further
		local backpackTrophies = {}
		for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
			if itemData and itemData.itemType == ITEMTYPE_TROPHY then
				local itemId = GetItemId(BAG_BACKPACK, itemData.slotIndex)
				backpackTrophies[itemId] = itemData  -- TODO: it overwrites (OK imo, reevaluate later) 
			end
		end

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local itemId, someIdentifier = pinDatum[3], pinDatum[4]

			local itemData = backpackTrophies[itemId]
			if itemData then
				local atlasIndex = 1
				if type(pinData[4]) == 'string' then
					atlasIndex = TREASURE_MAP_TEXTURES[someIdentifier]
				elseif pinData[4] then
					atlasIndex = itemData.stackCount > 1 and 4 or 3
				else
					atlasIndex = 2
				end

				if not atlasIndex then error('No texture selected') end

				-- TODO: tint

				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					atlasIndex = atlasIndex,
					tag = {itemId, atlasIndex},
				}
			end
		end

		return out
	end,
	-- TODO: d('You can find ''..itemData.name..'' in this zone')
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			-- local atlasIndex = tag[2]
			-- local mapIcon = TREASURE_MAPS_ICONS[atlasIndex]  -- TODO: should it show same icon as on map or just item icon?

			local bagId = BAG_BACKPACK
			local slotIndex = GetSlotIndexForTrophyItemId(bagId, tag[1])
			local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, functionalQuality, displayQuality = GetItemInfo(bagId, slotIndex)
			local name = ('%s (%d)'):format(GetItemName(bagId, slotIndex), stack)

			ShowInformationTooltip(icon, name)
		end,
	},
}

PinTypes[TREASURE_CHESTS] = {
	name = MAP_PINS_SI_TREASURE_CHESTS,
	labelIcon = _t('Chest_1.dds'),
	maxDistance = 0.05,
	level = 100,
	-- texture = _t('Chest_1.dds'),
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	size = 22,
	tint = ZO_ColorDef:New(1, 1, 1, .8),  -- tint=ZO_ColorDef:New(.8,.8,.5,.9)
	panels = {PANEL_PVE, PANEL_PVP, PANEL_IC},
	getPins = function(self)
		local map = _getFileName()
		local data = MP['Chests'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local x, y = GetMapPlayerPosition('player')  -- TODO
		local k = GetMapContentType() == MAP_CONTENT_DUNGEON and 4 or 1  -- TODO

		-- TODO: move outside
		local function isAbilityUnlocked(abilityId)
			return select(6, GetSkillAbilityInfo(GetSpecificSkillAbilityKeysByAbilityId(abilityId)))
		end
		local findersKeepersUnlocked = isAbilityUnlocked(74580)

		local chestTypesToDraw = findersKeepersUnlocked and 2 or 1

		local out = {}
		for chestType = 1, chestTypesToDraw do
			local coords = data[chestType]

			if coords then
				for i = 1, #coords do
					local pinDatum = coords[i]
					-- if math.abs(pinDatum[1] - x) < 0.08 * k and math.abs(pinDatum[2] - y) < 0.08 * k then
					-- TODO: how this updates?
					if true then
						out[#out+1] = {
							x = pinDatum[1],
							y = pinDatum[2],
							atlasIndex = chestType,
						}
					end
				end
			end
		end

		return out
	end,
	--[[
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local icon
			local name
			local text

			ShowInformationTooltip(icon, name, text)
		end,
	},
	--]]

	-- TODO tint, CustomPins
	-- if mapData then
	-- 	local FindersKeepers=IsAbilityUnlocked(74580)
	-- 	for chType, chData in pairs(mapData) do
	-- 		for chest, pinData in pairs(chData) do
	-- 			if math.abs(pinData[1]-x)<ChestsRange*mult and math.abs(pinData[2]-y)<ChestsRange*mult then
	-- 				if chType==2 and FindersKeepers then
	-- 					CustomPins[i].tint=ZO_ColorDef:New(.6,.6,1,.8)
	-- 					PinManager:CreatePin(id,{i,pinData[1], pinData[2]},pinData[1],pinData[2])
	-- 				elseif chType==1 then
	-- 					CustomPins[i].tint=ZO_ColorDef:New(1,1,1,.8)
	-- 					PinManager:CreatePin(id,{i,pinData[1], pinData[2]},pinData[1],pinData[2])
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- 	CustomPins[i].tint=ZO_ColorDef:New(1,1,1,.8)
	-- end
	-- mapData=CustomChestData[subzone]
	-- if mapData then
	-- 	CustomPins[i].tint=ZO_ColorDef:New(.4,1,.4,.8)
	-- 	for chest, pinData in pairs(mapData) do
	-- 		if math.abs(pinData[1]-x)<ChestsRange*mult and math.abs(pinData[2]-y)<ChestsRange*mult then
	-- 			PinManager:CreatePin(id,{i,pinData[1], pinData[2]},pinData[1],pinData[2])
	-- 		end
	-- 	end
	-- 	CustomPins[i].tint=ZO_ColorDef:New(1,1,1,.8)
	-- end
}

local UNKNOWN_POI_FILTER_TOOLTIP_TEXT = zo_iconFormat('/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds', 24, 24)..' '..GetString(SI_GAMEPAD_PLAYER_PROGERSS_BAR_UNKNOWN_ZONE)..'\n'  -- Unknown POI
									  ..zo_iconFormat('/esoui/art/icons/poi/poi_crafting_incomplete.dds', 24, 24)..' '..GetString(SI_SPECIALIZEDITEMTYPE213)..'\n'  -- Crafting station description
									  ..zo_iconFormat('/esoui/art/icons/poi/poi_mundus_incomplete.dds', 24, 24)..' '..GetString(SI_ZONECOMPLETIONTYPE12)  -- Mundus description

-- TODO: time it
local poiIds = {}
for i = 1, 20000 do
	local zoneIndex, poiIndex = GetPOIIndices(i)
	if not poiIds[zoneIndex] then
		poiIds[zoneIndex] = {}
	end

	poiIds[zoneIndex][poiIndex] = i
end

local DUMMY_ITEM_LINK_2 = '|H1:item:%d:370:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h'

-- TODO: simplify, move out, it only works in english? #localization_move
local function GetSetDescription(setData)
	if setData then
		local itemLink = DUMMY_ITEM_LINK_2:format(setData[1])
		local _, setName, numBonuses = GetItemLinkSetInfo(itemLink)
		local setBonuses = zo_strformat('|cEEEEEE<<1>> traits required|r\n', setData[2])
		local numRequired, Description
		for i = 1, numBonuses do
			numRequired, Description = GetItemLinkSetBonusInfo(itemLink, false, i)
			Description = string.gsub(Description,'%d+ %w+ Health','|cFF2222%1|r')
			Description = string.gsub(Description,'%d+ %w+ Stamina','|c22FF22%1|r')
			Description = string.gsub(Description,'%d+ %w+ Magicka','|c5555EE%1|r')
			Description = string.gsub(Description,'%d+ Health %w+','|cFF2222%1|r')
			Description = string.gsub(Description,'%d+ Stamina %w+','|c22FF22%1|r')
			Description = string.gsub(Description,'%d+ Magicka %w+','|c5555EE%1|r')
			Description = string.gsub(Description,'%d+ Spell Damage','|c5555EE%1|r')
			Description = string.gsub(Description,'%d+ Weapon Damage','|cBBBBBB%1|r')
			Description = string.gsub(Description,'%d+ %w+ Critical','|cBB33BB%1|r')
			setBonuses = setBonuses..Description..(i < numBonuses and '\n' or '')
		end
		return zo_strformat('<<1>> set (<<2>> items)', setName, numRequired), setBonuses
	else
		return '', ''
	end
end

PinTypes[UNKNOWN_POI] = {  -- TODO: unknown POIs include known mundus stones and crafting stations for some reason :/
	name = MAP_PINS_SI_UNKNOWN_POI,
	labelIcon = '/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds',
	filterTooltip = UNKNOWN_POI_FILTER_TOOLTIP_TEXT,
	maxDistance = 0.05,
	level = 10,
	-- texture = function(self) return self.m_PinTag.texture end,
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	size = 40,
	tint = ZO_ColorDef:New(.7, .7, .7, .6),
	panels = {PANEL_PVE, PANEL_PVP, PANEL_IC},
	getPins = function(self)
		local zoneIndex = GetCurrentMapZoneIndex()
		local zoneId = GetZoneId(zoneIndex)
		local data = MP['UnknownPOI'][zoneId]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}
		for poiIndex = 1, GetNumPOIs(zoneIndex) do
			local poiType = GetPOIType(zoneIndex, poiIndex)
			if poiType ~= POI_TYPE_HOUSE then
				local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
				if objectiveName ~= '' then
					local normalizedX, normalizedY, _, icon, _, _, isDiscovered = GetPOIMapInfo(zoneIndex, poiIndex)
					local extras = nil  -- 1 = Mundus, 2 = Crafting Station
					if icon:find('mundus') then extras = 1 end
					if icon:find('crafting') then extras = 2 end

					-- check if data is missing
					if extras == 1 or extras == 2 then
						if not data or not data[poiIndex] then
							extras = nil
						end
					end

					-- TODO: is norm > 0 really needed? #poi_map_info_outside_map
					if (not isDiscovered and (normalizedX > 0 or normalizedY > 0)) or extras then
						out[#out+1] = {
							x = normalizedX,
							y = normalizedY,
							atlasIndex = 1,  -- TODO
							tag = {zoneIndex, poiIndex, extras, data[poiIndex]},
						}
						-- TODO: size thing is weird
						-- local size = (BUI and BUI.name == 'BanditsUserInterface' and BUI.init.MiniMap) and 40 * BUI.Vars.PinScale/100 or 40
						-- ZO_MapPin.PIN_DATA[id].size = size
					end
				end
			end
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local zoneIndex, poiIndex, extras, data = tag[1], tag[2], tag[3], tag[4]
			local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
			local normalizedX, normalizedY, _, icon, _, _, isDiscovered = GetPOIMapInfo(zoneIndex, poiIndex)

			local name = objectiveName

			local text
			if extras == 1 then	 -- Mundus
				text = zo_strformat('<<C:1>>', GetAbilityDescription(data))
			elseif extras == 2 then  -- Crafting station
				name, text = GetSetDescription(data)
			end

			ShowInformationTooltip(icon, name, text)
		end,
	},
}

local function AchievementHandler(achievements)
	return function(self)
		local map = _getFileName()
		local data = MP['Achievements'][map]

		if not data then return end  -- TODO: add diagnostic warn #getpins_nil_hides_checkbox

		local pinsPotentionallyExist = false
		local out = {}
		for index, achievementId in pairs(achievements) do
			local achievementData = data[achievementId]
			if achievementData then
				pinsPotentionallyExist = true
				for _, pinData in pairs(achievementData) do
					local x, y, criterionIndex = pinData[1], pinData[2], pinData[3]

					local completed
					if self.sv.Show[achievementId] then  -- pins of these achievements are always shown TODO: research which #force_show_completed_pins
						completed = false
					else
						if criterionIndex then
							local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
							completed = numCompleted >= numRequired
						else
							completed = IsAchievementComplete(achievementId)
						end
					end

					-- TODO: v move out, this must be filled on inventory change or full invventory scan
					local achievementItems = MP.AchievementItems

					local haveItem = (achievementItems[achievementId]
										and achievementItems[achievementId][criterionIndex]) and true or false

					if not (completed or haveItem) then
						out[#out+1] = {
							x = x,
							y = y,
							atlasIndex = index,  -- TODO: no default
							tag = {achievementId, criterionIndex}
						}
					end
				end
			end
		end

		return pinsPotentionallyExist and out
	end
end

local function _achievementTooltipBuilder(achievements)
	local temp = {}

	for achievementId, icon in pairs(achievements) do
		local name = GetCroppedAchievementInfo(achievementId)
		temp[#temp+1] = ('%s %s'):format(zo_iconFormat(icon, 24, 24), name)
	end

	return table.concat(temp, '\n')
end

local UNDAUNTER_ICONS = {
	[704] = '/esoui/art/icons/crafting_beer_003.dds',
	[1082] = '/esoui/art/icons/ability_warrior_007.dds',
}

PinTypes[UNDAUNTED] = {
	name = MAP_PINS_SI_UNDAUNTED,
	labelIcon = '/esoui/art/icons/crafting_beer_003.dds',
	-- texture = '/esoui/art/icons/crafting_beer_003.dds',
	filterTooltip = _achievementTooltipBuilder(UNDAUNTER_ICONS),
	atlas = _t('dummy8x2.dds'),  -- TODO  -- TODO: #per_pintype_atlas #atlas_layout_128x64
	atlasW = 8,
	atlasH = 2,
	maxDistance = 0.05,
	level = 101,
	size = 20,
	-- 	[704] = {name='pinType_This_One\'s_On_Me', texture=},
	-- [1082] = {name='pinType_Undaunted_Rescuer', texture=},
	panels = {PANEL_PVE},
	getPins = AchievementHandler({704, 1082}),
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local achievementId, criterionIndex = tag[1], tag[2]
			local name, description, points, icon, completed, date, time = GetAchievementInfo(tag[1])
			local text = description

			if criterionIndex then
				name = ('[%d] %s'):format(criterionIndex, name)
				text = GetAchievementCriterion(achievementId, criterionIndex)
			end

			ShowInformationTooltip(icon, name, text)
		end,
	},
}

-- TODO: move to strings?
local LIGHTBRINGER_TOOLTIP_BODY_TEXT = ('%s\n%s\n%s'):format(
	zo_strformat('|t24:24:<<4>>|t <<1>>', GetAchievementInfo(873)),  -- Lightbringer
	zo_strformat('|t24:24:<<4>>|t <<1>>', GetAchievementInfo(871)),  -- Give to Poor
	zo_strformat('|t24:24:<<4>>|t <<1>>', GetAchievementInfo(869))   -- Crime Pays
)

PinTypes[WORLD_ACHIEVEMENTS] = {
	name = MAP_PINS_SI_WORLD_ACHIEVEMENTS,
	labelIcon = '/esoui/art/progression/progression_indexicon_world_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[872] = '/esoui/art/icons/achievement_066.dds',
		[873] = '/esoui/art/icons/perks_mages_guild_001.dds',  -- '/esoui/art/miscellaneous/help_icon.dds',
		[871] = '/esoui/art/icons/perks_mages_guild_004.dds',
		[869] = '/esoui/art/icons/item_generic_coinbag.dds',
		[716] = '/esoui/art/icons/ability_healer_017.dds',
		-- zo_strformat("|t24:24:<<2>>|t <<1>>\n", GetCroppedAchievementInfo(873))  -- Lightbringer
		-- zo_strformat("|t24:24:<<2>>|t <<1>>\n", GetCroppedAchievementInfo(871))  -- Give to Poor
		-- zo_strformat("|t24:24:<<2>>|t <<1>>", GetCroppedAchievementInfo(869))  -- Crime Pays
	}),
	maxDistance = 0.05,
	level = 101,
	size = 20,  -- TODO: Lightbringer size 25!
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,

	-- [10]={section=true,name='World_achievements',id={},pin={},texture='/esoui/art/progression/progression_indexicon_world_up.dds',
	-- 	[872]={name='pinType_I_like_M\'aiq',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_066.dds',k=1},
	-- 	[873]={name='pinType_Lightbringer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1.25},
	-- 	[716]={name='pinType_Peacemaker',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/ability_healer_017.dds',k=1},
	-- },

	panels = {PANEL_PVE},
	getPins = AchievementHandler({872, 873, 716}),
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local achievementId = tag[1]

			if achievementId == 873 then
				local icon = '/esoui/art/miscellaneous/help_icon.dds'
				local name = GetString(SI_JOURNAL_MENU_ACHIEVEMENTS)
				local text = LIGHTBRINGER_TOOLTIP_BODY_TEXT

				ShowInformationTooltip(icon, name, text)
			else
				-- TODO: it is default achievement route, creator in general is too complex tbh, maybe simplify it?
				PinTypes[UNDAUNTED].tooltip.creator(tag)
			end
		end,
	},
}

PinTypes[ORSINIUM] = {
	name = MAP_PINS_SI_ORSINIUM,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds',  -- '/esoui/art/icons/store_orsiniumdlc_collectable.dds'
	filterTooltip = _achievementTooltipBuilder({
		[1247] = 'esoui/art/icons/achievement_wrothgar_010.dds',
		[1316] = 'esoui/art/icons/achievement_wrothgar_024.dds',
		[1250] = 'esoui/art/icons/achievement_wrothgar_008.dds',
	}),
	maxDistance = 0.05,
	level = 101,
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	size = 20,
	-- [11]={section=true,name='Orsinium',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds',	
	-- 	[1247]={name='pinType_One_Last_Brawl',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_010.dds',k=1},
	-- 	[1316]={name='pinType_Orsinium_Patron',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_024.dds',k=1,},
	-- 	[1250]={name='pinType_Wrothgar_Relic_Hunter',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_008.dds',k=1},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({1247, 1316, 1250}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip

	-- showOnlyFor = {
	-- 	["argentmine2_base"] = true,
	-- 	["coldperchcavern_base"] = true,
	-- 	["honorsrestleft_base"] = true,
	-- 	["oldorsiniummap07_base"] = true,
	-- 	["orsinium_base"] = true,
	-- 	["thukozods_base"] = true,
	-- 	["wrothgar_base"] = true,
	-- }
}

-- have to do this because 1383 is a special case again  -- TODO: can somehow redo
local THIEVES_GUILD_1349_ACHIEVEMENT_HANDLER = AchievementHandler({1349})

PinTypes[THIEVES_GUILD] = {
	name = MAP_PINS_SI_THIEVES_GUILD,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		-- swapped order here, they were the other way  -- TODO: is it OK?
		[1349] = '/esoui/art/icons/perks_theives_guild_004.dds',
		[1383] = '/esoui/art/icons/achievement_thievesguild_044.dds',
	}),
	maxDistance = 0.05,
	level = 101,
	size = 20,
	-- [12]={section=true,name='Thieves_guild',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds',	--'/esoui/art/icons/store_thievesguilddlc_collectable.dds',
	-- 	[1383]={name='pinType_A_Cutpurse_Above',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_thievesguild_044.dds',k=1},
	-- 	[1349]={name='pinType_Breaking_And_Entering',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/perks_theives_guild_004.dds',k=1},
	-- },
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	panels = {PANEL_PVE},
	getPins = function(self)
		local map = _getFileName()
		local mapData = MP['Achievements'][map]
		local data = mapData and mapData[1383]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}
		for _, pinDatum in ipairs(data) do
			local achievementId, criterionIndex = pinDatum[3], pinDatum[4]

			-- >> basically a copy from AchievementHandler  -- TODO: DRY
			local completed
			if self.sv.Show[achievementId] then  -- pins of these achievements are always shown TODO: research which #force_show_completed_pins
				completed = false
			else
				if criterionIndex then
					local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
					completed = numCompleted >= numRequired
				else
					completed = IsAchievementComplete(achievementId)
				end
			end

			-- TODO: v move out, this must be filled on inventory change or full invventory scan
			local achievementItems = MP.AchievementItems

			local haveItem = (achievementItems[achievementId]
								and achievementItems[achievementId][criterionIndex]) and true or false

			if not (completed or haveItem) then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					atlasIndex = 2,  -- `2` because all 1349 pins will receive `1` in THIEVES_GUILD_1349_ACHIEVEMENT_HANDLER
					tag = {achievementId, criterionIndex}
				}
			end
			-- << basically a copy from AchievementHandler
		end

		-- TODO: can do nothing but implementing this monstrosity because of 1383...
		local someMorePins = THIEVES_GUILD_1349_ACHIEVEMENT_HANDLER(self)

		if someMorePins then
			for i = 1, #someMorePins do
				out[#out+1] = someMorePins[i]
			end
		end

		return out
	end,
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip  -- TODO: special case for 1383?
}

PinTypes[MORROWIND] = {
	name = MAP_PINS_SI_MORROWIND,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds',  -- '/esoui/art/icons/store_morrowind_collectable.dds'
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[1824] = _t('Scroll_1.dds'),  -- tint=ZO_ColorDef:New(.8,.8,.8,.8)}
		[1712] = '/esoui/art/icons/poi/poi_crypt_incomplete.dds',
		[1827] = '/esoui/art/icons/achievement_vvardenfel_032.dds',
	}),
	-- [13]={section=true,name='Morrowind',id={},pin={},
	-- 	[1824]={name='pinType_Vivec_Lessons',done=false,ach=true,maxDistance=0.05,level=100,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1,tint=ZO_ColorDef:New(.8,.8,.8,.8)},
	-- 	[1712]={name='pinType_Ancestral_Tombs',done=false,ach=true,maxDistance=0.05,level=30,texture='/esoui/art/icons/poi/poi_crypt_incomplete.dds',k=1},
	-- 	[1827]={name='pinType_Pilgrim\'s_Path',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_vvardenfel_032.dds',k=1},
	-- },
	maxDistance = 0.05,
	level = 101,  -- TODO: different levels! + tints
	size = 20,
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	panels = {PANEL_PVE},
	getPins = AchievementHandler({1824, 1712, 1827}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip

	-- showOnlyFor = {
	-- 	["balmora_base"] = true,
	-- 	["sadrithmora_base"] = true,
	-- 	["vivecstolms03_base"] = true,
	-- 	["viviccity_base"] = true,
	-- 	["vvardenfell_base"] = true,
	-- }
}

PinTypes[SUMMERSET] = {
	name = MAP_PINS_SI_SUMMERSET,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_summerset_up.dds',  -- '/esoui/art/icons/store_summerset_collectable.dds'
	filterTooltip = _achievementTooltipBuilder({
		[2099] = '/esoui/art/icons/quest_strosmkai_open_treasure_chest.dds',
		[2211] = '/esoui/art/icons/crafting_stoneware_bottle_003.dds',
		[2171] = '/esoui/art/icons/achievement_su_rds_01.dds',  -- TODO: k=1.25  -- '/esoui/art/miscellaneous/help_icon.dds'?
	}),
	-- [14]={section=true,name='Summerset',id={},pin={},
	-- 	[2099]={name='pinType_Summerset_Relics',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/quest_strosmkai_open_treasure_chest.dds',k=1},
	-- 	[2211]={name='pinType_Message_in_Bottle',done=false,ach=true,maxDistance=0.05,level=100,texture='/esoui/art/icons/crafting_stoneware_bottle_003.dds',k=1},
	-- 	[2171]={name='pinType_Summerset_world_event',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1.25,def_texture='/esoui/art/icons/achievement_su_rds_01.dds'},
	-- },

	maxDistance = 0.05,
	level = 101,  -- TODO: different levels! + tints + size
	size = 20,
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	panels = {PANEL_PVE},
	getPins = AchievementHandler({2099, 2211, 2171}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip

	-- showOnlyFor = {
	-- 	['summerset_base'] = true,
	-- 	['shimmerene_base'] = true,
	-- },
}

PinTypes[TIME_RIFTS] = {
	name = MAP_PINS_SI_TIME_RIFTS,
	labelIcon = _t('Treasure_1-2.dds'),
	maxDistance = 0.05,
	level = 101,
	texture = _t('Treasure_1-2.dds'),
	size = 36,
	panels = {PANEL_PVE},
	getPins = function(self)
		local map = _getFileName()
		local data = MP['TimeBreaches'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}

		local PSIJIC_SKILL_LINE_INDEX = 4  -- TODO: move out
		local rank, isAdvised, isActive, isDiscovered, isAccountSkill, isInTraining, isClassMastery = GetSkillLineDynamicInfo(SKILL_TYPE_GUILD, PSIJIC_SKILL_LINE_INDEX)
		-- local num = 1

		local function isTimeBreachClosed(mapName, index)  -- TODO: move out
			return self.sv.TimeBreachClosed[mapName] and self.sv.TimeBreachClosed[mapName][index]
		end

		for index, pinDatum in ipairs(data) do
			if pinDatum[3] == rank and not isTimeBreachClosed(map, index) then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
				}
			end
		end

		return out

		-- TODO: listen for some quest event to update pins #track_completed_pintype_enabled
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local icon = _t('Treasure_1-2.dds')
			local name = GetString(MAP_PINS_SI_TIME_RIFTS)

			ShowInformationTooltip(icon, name)
		end,
	},
}

local SHRINES_FILTER_TOOLTIP_TEXT = zo_iconFormat('/esoui/art/icons/ability_vampire_007.dds', 24, 24)..' '..GetString(SI_MONSTERSOCIALCLASS42)..'\n'
								  ..zo_iconFormat('/esoui/art/icons/ability_werewolf_010.dds', 24, 24)..' '..GetString(SI_MONSTERSOCIALCLASS45)

PinTypes[SHRINES] = {
	name = MAP_PINS_SI_SHRINES,
	labelIcon = '/esoui/art/icons/poi/poi_daedricruin_incomplete.dds',
	filterTooltip = SHRINES_FILTER_TOOLTIP_TEXT,
	maxDistance = 0.05,
	level = 101,
	size = 25,

	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,

	panels = {PANEL_PVE},
	getPins = function(self)
		local map = _getFileName()
		local data = MP['Shrines'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}

		for index, pinDatum in ipairs(data) do
			local shrineType = pinDatum[3]
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
				atlasIndex = shrineType,
			}
		end

		return out
	end
}

-- TODO: refactor completely
-- TODO: localization
local FISHING_NODE_TYPE = {
	['Lake']	= 1,
	['Foul']	= 2,
	['River']	= 3,
	['Salt']	= 4,
	['Oily']	= 5,
	['Mystic']	= 6,
	['Running']	= 7
}

local FISHING_BUCKET = {
	[1] = 1,
	[2] = 2, [5] = 2,  -- Oily = Foul
	[3] = 3, [7] = 3,  -- Running = River
	[4] = 4, [6] = 4,  -- Mystic = Salt
}

local function GetFishingNodeTypesLeftForAchievement(achievementId)
	local buckets = {false, false, false, false}
	-- local total = {Lake = 0, Foul = 0, River = 0, Salt = 0, Oily = 0, Mystic = 0, Running = 0}
	for criterionIndex = 1, GetAchievementNumCriteria(achievementId) do
		local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
		local waterName = string.match(description, '%(([^%(%)]+)%)$')
		local waterType = FISHING_NODE_TYPE[waterName]
		local bucket = FISHING_BUCKET[waterType]

		if numCompleted < numRequired then
			buckets[bucket] = true
		end

		-- TODO: is FishingBugFix needed? #zos_spelling_recheck
		-- if MP.FishingBugFix[achievementId] and MP.FishingBugFix[achievementId][criterionIndex] then
		-- 	total[ MP.FishingBugFix[achievementId][criterionIndex] ] = total[ MP.FishingBugFix[achievementId][criterionIndex] ] + numRequired - numCompleted
		-- else
		-- 	local waterType = string.match(description, '%(([^%(%)]+)%)$')
		-- end
	end
	-- total.Salt = total.Salt + total.Mystic
	-- total.Foul = total.Foul + total.Oily
	-- total.River = total.River + total.Running

	-- return {[1] = total.Foul > 0, [2] = total.River > 0, [3] = total.Salt > 0, [4] = total.Lake > 0}
	return buckets
end

local FISHING_NODE_TYPES = {
	[1] = '/esoui/art/icons/crafting_slaughterfish.dds',		-- Foul
	[2] = '/esoui/art/icons/crafting_fishing_river_betty.dds',	-- River
	[3] = '/esoui/art/icons/crafting_fishing_merringar.dds',	-- Salt
	[4] = '/esoui/art/icons/crafting_fishing_perch.dds',		-- Lake
}
local FISHING_FILTER_TOOLTIP_TEXT = zo_iconFormat(FISHING_NODE_TYPES[1], 24, 24)..' '..GetString(MAP_PINS_SI_FISHING_NODE_FOUL)..'\n'
								  ..zo_iconFormat(FISHING_NODE_TYPES[2], 24, 24)..' '..GetString(MAP_PINS_SI_FISHING_NODE_RIVER)..'\n'
								  ..zo_iconFormat(FISHING_NODE_TYPES[3], 24, 24)..' '..GetString(MAP_PINS_SI_FISHING_NODE_SALT)..'\n'
								  ..zo_iconFormat(FISHING_NODE_TYPES[4], 24, 24)..' '..GetString(MAP_PINS_SI_FISHING_NODE_LAKE)

PinTypes[FISHING_NODES] = {
	name = MAP_PINS_SI_FISHING_NODES,
	labelIcon = '/esoui/art/icons/achievements_indexicon_fishing_up.dds',
	filterTooltip = FISHING_FILTER_TOOLTIP_TEXT,
	maxDistance = 0.05,
	level = 101,
	size = 25,
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	panels = {PANEL_PVE, PANEL_PVP, PANEL_IC},
	getPins = function(self)
		local map = _getFileName()
		local data = MP['FishingNodes'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local nodesToShow
		if self.sv.AllFish then
			nodesToShow = {true, true, true, true}
		else
			-- TODO: meh #town_zone_legacy_fix
			local achievementId = MP.FishingZones[map] or MP.FishingZones[GetCurrentMapZoneIndex()]
			if not achievementId then return end

			nodesToShow = GetFishingNodeTypesLeftForAchievement(achievementId)
		end

		local out = {}
		for index, pinDatum in ipairs(data) do
			local fishingNodeType = pinDatum[3]
			if nodesToShow[fishingNodeType] then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					atlasIndex = fishingNodeType,
				}
			end
		end

		return out
	end
}

local PRECURSOR_TOOLTIP = {
	{criterionIndex = 1,  description = '  Alik\'r Desert: Yldzuun'},  -- TODO: english only?
	{criterionIndex = 4,  description = '  Alik\'r Desert: Santaki'},
	{criterionIndex = 6,  description = '  Alik\'r Desert: Aldunz'},
	{criterionIndex = 2,  description = '  Bangkorai: Klathzgar'},
	{criterionIndex = 3,  description = '  Rift: Avancheznel'},
	{criterionIndex = 7,  description = '  Eastmarch: Mzulft'},
	{criterionIndex = 8,  description = '  Stonefalls: Inner Sea Armature'},
	{criterionIndex = 9,  description = '  Deshaan: Mzithumz'},
	{criterionIndex = 5,  description = '  Deshaan: Lower Bthanual'},
	{criterionIndex = 14, description = 'Deshaan: Bthanual'},
	{criterionIndex = 10, description = 'Stros M\'Kai: Bthzark'},
	{criterionIndex = 11, description = 'Brass Bortress: Mechanical Fundament'},
	{criterionIndex = 12, description = 'Clockwork Base'},
	{criterionIndex = 13, description = 'Brass Bortress: Machine District'}
}

local function _buildTooltip(output, achievementId, tooltipData)
	for i = 1, #tooltipData do
		local data = tooltipData[i]

		local criterionIndex = data.criterionIndex
		local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)

		local color = 'EEEEEE'
		if numCompleted == numRequired then
			color = '33EE33'
		elseif MP.AchievementItems[achievementId] and MP.AchievementItems[achievementId][criterionIndex] then
			color = 'EEEE22'
		end

		local info = ('[|c%s%d|r] '):format(color, criterionIndex)

		output[#output+1] = info..data.description
	end

	return table.concat(output, '\n')
end

PinTypes[CLOCKWORK_CITY] = {
	name = MAP_PINS_SI_CLOCKWORK_CITY,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_cwc_up.dds',  -- '/art/fx/texture/clockworksigil.dds'

	filterTooltip = function()
		local temp = {zo_strformat("|t24:24:<<2>>|t <<1>>", GetCroppedAchievementInfo(1958))}

		_buildTooltip(temp, 1958, PRECURSOR_TOOLTIP)

		return table.concat(temp, '\n')
	end,

	texture = '/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds',

	-- [18]={section=true,name='pinType_Clockwork_City',id={},pin={},	
	-- 	[1958]={name='pinType_Precursor_Maker',texture='/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds',def_texture='/esoui/art/icons/achievement_update16_001.dds'},
	-- },
	maxDistance = 0.05,
	level = 101,
	size = 20,
	-- atlas = _t('dummy8x2.dds'),  -- TODO
	-- atlasW = 8,
	-- atlasH = 2,
	panels = {PANEL_PVE},
	getPins = AchievementHandler({1958}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip

	-- showOnlyFor = {
	-- 	["aldunz_base"] = true,
	-- 	["avancheznel_base"] = true,
	-- 	["brassfortress_base"] = true,
	-- 	["bthanual_base"] = true,
	-- 	["bthzark_base"] = true,
	-- 	["ccunderground_base"] = true,
	-- 	["clockwork_base"] = true,
	-- 	["innerseaarmature_base"] = true,
	-- 	["jaggerjaw_base"] = true,
	-- 	["lowerbthanuel_base"] = true,
	-- 	["mzithumz_base"] = true,
	-- 	["mzulft_base"] = true,
	-- 	["santaki_base"] = true,
	-- 	["yldzuun_base"] = true,
	-- }
}

PinTypes[MURKMIRE] = {
	name = MAP_PINS_SI_MURKMIRE,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds',  -- '/esoui/art/icons/store_murkmiredlc_collectable.dds'
	filterTooltip = _achievementTooltipBuilder({
		[2320] = '/esoui/art/icons/achievement_murkmire_museum.dds',  -- '/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_stylematerial.dds'
		[2341] = _t('Scroll_1.dds'),
		[2355] = '/esoui/art/tutorial/gamepad/gp_icon_new.dds',	 -- esoui/art/floatingmarkers/quest_icon.dds
		[2330] = '/esoui/art/icons/achievement_murkmire_shadowscale_wisdom.dds',  -- '/esoui/art/miscellaneous/help_icon.dds'
		[2358] = '/esoui/art/icons/achievement_murkmire_rescue_villagers.dds',  -- '/esoui/art/death/death_soulreservoir_icon.dds'
		[2357] = '/esoui/art/icons/mh_hedgeguardian_strang.dds',  -- _t('Lorebook_1-2.dds')
	}),
	texture = '/esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds',
	-- [19]={section=true,name='pinType_Murkmire',id={},pin={}, 
	-- 	[2320]={name='pinType_Chronic_Chronogler',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_stylematerial.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_museum.dds'},
	-- 	[2341]={name='pinType_Poems_of_Nothing',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1},
	-- 	[2355]={name='pinType_Achievement_quests',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/tutorial/gamepad/gp_icon_new.dds',k=1},	--esoui/art/floatingmarkers/quest_icon.dds
	-- 	[2330]={name='pinType_Surreptitiously_Shadowed',done=false,ach=true,maxDistance=0.05,level=111,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_shadowscale_wisdom.dds'},
	-- 	[2358]={name='pinType_Swamp_Rescuer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/death/death_soulreservoir_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_rescue_villagers.dds'},
	-- 	[2357]={name='pinType_Vine-Tongue_Traveler',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Lorebook_1-2.dds',k=1,def_texture='/esoui/art/icons/mh_hedgeguardian_strang.dds'},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({2320, 2341, 2355, 2330, 2358, 2357}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

PinTypes[ELSWEYR] = {
	name = MAP_PINS_SI_ELSWEYR,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[2463] = '/esoui/art/icons/achievement_els_museum_mural.dds',
		[2534] = '/esoui/art/icons/achievement_u24_museum_tapestry.dds',
		[2619] = '/esoui/art/icons/quest_book_003.dds',  -- _t('Scroll_1.dds')
		[2621] = '/esoui/art/icons/achievement_u24_familyofpirates.dds',
		[2620] = '/esoui/art/icons/achievement_u24_grappletreasures.dds',
	}),
	texture = '/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds',
	-- [20]={section=true,name='pinType_Elsweyr',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds',
	-- 	[2463]={name='pinType_Mural_Mender',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_els_museum_mural.dds',k=1},
	-- 	[2534]={name='pinType_Pieces_of_History',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_museum_tapestry.dds',k=1},
	-- 	[2619]={name='pinType_Theater_Critic',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1,def_texture='/esoui/art/icons/quest_book_003.dds'},
	-- 	[2621]={name='pinType_Legacy_Slayer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_familyofpirates.dds',k=1},
	-- 	[2620]={name='pinType_Grappling_Bow_Pathfinder',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_grappletreasures.dds',k=1},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({2463, 2534, 2619, 2621, 2620}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

PinTypes[VOLENDRUNG] = {
	name = MAP_PINS_SI_VOLENDRUNG,
	labelIcon = '/esoui/art/miscellaneous/help_icon.dds',
	texture = '/esoui/art/miscellaneous/help_icon.dds',
	size = 25,
	maxDistance = 0.05,
	level = 30,
	panels = {PANEL_PVP},
	getPins = function(self)
		local map = _getFileName()
		if map ~= 'ava_whole' then return end

		local data = MP['Volendrung']
		if not data then return end  -- TODO: add diagnostic warn

		local out = {}
		for index, pinDatum in ipairs(data) do
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
			}
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local icon = '/esoui/art/miscellaneous/help_icon.dds'
			local name = GetString(MAP_PINS_SI_VOLENDRUNG_SPAWN_LOCATION)

			ShowInformationTooltip(icon, name)
		end,
	},
}

PinTypes[MARKARTH] = {
	name = MAP_PINS_SI_MARKARTH,
	labelIcon = '/esoui/art/treeicons/tutorial_indexicon_markarth_up.dds',
	texture = '/esoui/art/treeicons/tutorial_indexicon_markarth_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[2927] = '/esoui/art/icons/achievement_u28_jump_flavor.dds',
		[2851] = '/esoui/art/icons/achievement_u28_reach_flavor.dds',
		[2964] = '/esoui/art/icons/ability_u26_vampire_infection_stage4.dds',
	}),
	-- [22]={section=true,name='pinType_Markarth',
	-- 	[2927]={name='pinType_Red_Eagle\'s_Flight',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u28_jump_flavor.dds',k=1},
	-- 	[2851]={name='pinType_Offerings_to_the_Old_Spirits',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u28_reach_flavor.dds',k=1},
	-- 	[2964]={name='pinType_A_friend_in_deed',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/ability_u26_vampire_infection_stage4.dds',k=1},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({2927, 2851, 2964}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

local INSTRUMENTS_TOOLTIP = {
	{criterionIndex = 2,  description = '  Nchuthnkarst: Lute of Blue Longing'},
	{criterionIndex = 3,  description = '  Blackreach: Chime of the Endless'},
	{criterionIndex = 4,  description = '  Shadowgreen: Tenderclaw '},
	{criterionIndex = 5,  description = '  Dragonhome: Shadow of Rahjin'},
	{criterionIndex = 6,  description = '  Chill Wind Depths: Lilytongue'},
	{criterionIndex = 7,  description = '  Labyrinthian: Sky talker'},
	{criterionIndex = 8,  description = '  Western Skryim: Long Fire'},
	{criterionIndex = 9,  description = '  Scraps: Hightmourn Dizi'},
	{criterionIndex = 10, description = 'Western Skryim: Jarlsbane'},
	{criterionIndex = 11, description = 'Western Skryim: King Thunder'},
	{criterionIndex = 12, description = 'Western Skryim: Jahar Fuso\'ja'},
	{criterionIndex = 13, description = 'Blackreach: Pan Flute of Morachellis'},
	{criterionIndex = 14, description = 'Blackreach: Reman War Drum'},
	{criterionIndex = 15, description = 'Blackreach: Ateian Fife'},
	{criterionIndex = 16, description = 'Western Skryim: Shiek-of-Silk'},
	{criterionIndex = 17, description = 'Western Skryim: Kothringi Leviathan Bugle'},
	{criterionIndex = 18, description = 'Western Skryim: Lodestone'},
	{criterionIndex = 19, description = 'Western Skryim: Dozzen Talharpa'},
}

local MINING_SAMPLE_TOOLTIP = {
	{criterionIndex = 1, description = 'Kelbarn\'s Mining Samples'},
	{criterionIndex = 2, description = 'Inguya\'s Mining Samples'},
	{criterionIndex = 3, description = 'Reeh-La\'s Mining Samples'},
	{criterionIndex = 4, description = 'Adanzda\'s Mining Samples'},
	{criterionIndex = 5, description = 'Ghamborz\'s Mining Samples'},
}

PinTypes[GREYMOOR] = {
	name = MAP_PINS_SI_GREYMOOR,
	labelIcon = '/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds',
	filterTooltip = function()
		local temp = {zo_strformat("|t24:24:<<2>>|t <<1>>", GetCroppedAchievementInfo(2759))}

		_buildTooltip(temp, 2759, MINING_SAMPLE_TOOLTIP)

		temp[#temp+1] = '|t300:8:/EsoUI/Art/Miscellaneous/horizontalDivider.dds|t'
		temp[#temp+1] = zo_strformat("|t24:24:<<2>>|t <<1>>", GetCroppedAchievementInfo(2669))

		_buildTooltip(temp, 2669, INSTRUMENTS_TOOLTIP)

		return table.concat(temp, '\n')
	end,
	texture = '/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds',
	-- [23]={section=true,name='pinType_Greymoor'
	-- 	[2669]={name='pinType_Instrumental_Triumph',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_u26_skyrim_sounds_of_success.dds'},
	-- 	[2759]={name='Mining_Sample_Collector',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/poi/poi_mine_compete.dds',k=1,def_texture='/esoui/art/icons/achievement_u26_skyrim_minerquest.dds'},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({2669, 2759}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

PinTypes[ANTIQUITIES] = {
	name = MAP_PINS_SI_ANTIQUITIES,
	labelIcon = '/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds',
	texture = '/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds',
	filterTooltip = zo_iconFormat('/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds', 24, 24)..GetString(MAP_PINS_SI_ANTIQUITY_LEADS),
	size = 28,
	maxDistance = 0.05,
	level = 101,
	panels = {PANEL_PVE},
	getPins = function(self)
		local map = _getFileName()
		local data = MP['Antiquities'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}
		for index, pinDatum in ipairs(data) do
			local antiquityId = pinDatum[3]
			if GetNumAntiquitiesRecovered(antiquityId) < 1 then  -- not DoesAntiquityHaveLead(antiquityId)
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = antiquityId,
				}
			end
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local icon = '/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds'

			local antiquityId = tag
			local name = ZO_CachedStrFormat('<<C:1>>', GetAntiquityName(antiquityId))

			ShowInformationTooltip(icon, name)
		end,
	},
	-- TODO: name = ZO_CachedStrFormat("<<C:1>>",GetAntiquityName(pinData[3]))
}

local BLACKWOOD_GET_ACHIEVEMENT_PINS = AchievementHandler({3083, 3081, 3082, 3080})  -- 74 is not achievement! Removed from here
PinTypes[BLACKWOOD] = {
	name = MAP_PINS_SI_BLACKWOOD,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_blackwood_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[3083] = '/esoui/art/icons/achievement_u30_flavor4.dds',
		[3081] = '/esoui/art/icons/achievement_u30_flavor2.dds',
		[3082] = '/esoui/art/icons/achievement_u30_rds.dds',
		[3080] = '/esoui/art/icons/achievement_u30_flavor1.dds',
		-- [74]   = '/esoui/art/miscellaneous/help_icon.dds',  -- TODO: ?
	})..'\n'..zo_iconFormat('/esoui/art/miscellaneous/help_icon.dds', 24, 24)..' '..GetString(MAP_PINS_SI_RANDOM_ENCOUNTERS),  -- TODO: HAVE NOT EXPECTED THAT
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_blackwood_up.dds',
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	-- [25]={section=true,name='pinType_Blackwood'
	-- 	[3083]={name='pinType_Lost_in_Wilds',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor4.dds',k=1},
	-- 	[3081]={name='pinType_Bane_of_Sul-Xan',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor2.dds',k=1},
	-- 	[3082]={name='pinType_Most_Admired',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_rds.dds',k=1},
	-- 	[74]={name='pinType_Random_Encounters',done=false,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1},
	-- 	[3080]={name='pinType_Leyawiin_Master_Burglar',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor1.dds',k=1},
	-- },
	panels = {PANEL_PVE},
	getPins = function(self)
		local out = BLACKWOOD_GET_ACHIEVEMENT_PINS(self)

		local map = _getFileName()
		local mapData = MP['Achievements'][map]
		local data = mapData and mapData[74]  -- TODO: separate! 74 is not an achievement

		if not data then  -- TODO: add diagnostic warn ?
			return out
		end

		out = out or {}

		for index, pinDatum in ipairs(data) do
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
				atlasIndex = 5,  -- first 4 - achievement based icons
				tag = {}
			}
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local achievementId = tag[1]

			if achievementId then
				-- TODO: it is default achievement route, if it will ever be refactored, do not forget about this one
				PinTypes[UNDAUNTED].tooltip.creator(tag)
			else  -- 74 special case (random encounter)
				local icon = '/esoui/art/treeicons/tutorial_idexicon_blackwood_up.dds'
				local name = GetString(MAP_PINS_SI_RANDOM_ENCOUNTER)

				ShowInformationTooltip(icon, name)
			end
		end,
	},
}

local IC_GET_ACHIEVEMENT_PINS = AchievementHandler({1270, 1272})
local IMPERIAL_CITY_TOOLTIP_TEXT = ('%s %s\n%s %s'):format(
	zo_iconFormat('/esoui/art/icons/poi/poi_groupboss_incomplete.dds', 24, 24), GetString(MAP_PINS_SI_IC_BOSSES),
	zo_iconFormat('/esoui/art/death/death_soulreservoir_icon.dds', 24, 24), GetString(MAP_PINS_SI_IC_RESPAWNS)
)
PinTypes[IMPERIAL_CITY] = {
	name = MAP_PINS_SI_IMPERIAL_CITY,
	labelIcon = '/esoui/art/compass/ava_imperialcity_neutral.dds',
	filterTooltip = IMPERIAL_CITY_TOOLTIP_TEXT..'\n'.._achievementTooltipBuilder({  -- TODO: refactor this mess
		[1270] = '/esoui/art/icons/achievement_ic_telvarscamp.dds',
		[1272] = '/esoui/art/icons/achievement_ic_treasurescamp.dds',
	}),
	-- texture = '/esoui/art/compass/ava_imperialcity_neutral.dds',
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	-- [26]={section=true,name='pinType_Imperial_City'
	-- 	[76]={name='pinType_IC_Bosses',done=false,maxDistance=0.05,level=101,texture='/esoui/art/icons/poi/poi_groupboss_incomplete.dds',k=1.25},
	-- 	[77]={name='pinType_IC_Respawns',done=false,maxDistance=0.05,level=101,texture='/esoui/art/death/death_soulreservoir_icon.dds',k=1},
	-- 	[1270]={name='pinType_Cunning_Scamp',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_ic_telvarscamp.dds',k=1},
	-- 	[1272]={name='pinType_Trove_Scamp',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_ic_treasurescamp.dds',k=1},
	-- },
	panels = {PANEL_IC},
	getPins = function(self)  -- TODO: function to chain pins (smth like providers to combine pin sources?)
		local out = IC_GET_ACHIEVEMENT_PINS(self)

		local map = _getFileName()
		if map ~= 'imperialcity_base' then  -- TODO: mapId
			return out
		end

		local data = MP.ImperialCity

		out = out or {}
		-- bosses
		for _, pinDatum in ipairs(data[1]) do
			local bossName = pinDatum[3]  -- TODO: tooltip
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
				atlasIndex = 3,  -- 1 and 2 should be for achievements
				tag = bossName,  -- TODO: it is in EN only now, can translate?
			}
		end
		-- spawns
		for _, pinDatum in ipairs(data[2]) do
			local allianceId = pinDatum[3]  -- TODO: color
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
				atlasIndex = 4,    -- 1 and 2 should be for achievements
			}
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		hasTooltip = function(tag)
			-- accounts for special case (77): if `tag` not defined, tooltip should not be shown
			return not not tag
		end,
		creator = function(tag)
			if type(tag) == 'string' then    -- 76 special case (bosses)
				local icon = '/esoui/art/icons/poi/poi_groupboss_incomplete.dds'
				local name = tag

				ShowInformationTooltip(icon, name)
			else
				-- TODO: it is default achievement route, if it will ever be refactored, do not forget about this one
				PinTypes[UNDAUNTED].tooltip.creator(tag)
			end
		end,
	},
}

local PORTAL_NAMES_MAPPING = {
	GetString(MAP_PINS_SI_PORTAL_CELESTIAL_RIFTS),
	GetString(MAP_PINS_SI_PORTAL_DARK_FISSURES),
	GetString(MAP_PINS_SI_PORTAL_OBLIVION_PORTALS),
	GetString(MAP_PINS_SI_PORTAL_SHADOW_FISSURES),
	GetString(MAP_PINS_SI_PORTAL_LAVA_LASHERS),
	GetString(MAP_PINS_SI_PORTAL_SOUL_REAPER),
}
local PORTAL_TOOLTIP_TEMPLATE = zo_iconFormat('/esoui/art/icons/poi/poi_portal_complete.dds', 24, 24)..' %s'

local PORTAL_NAMES = {
	GetString(MAP_PINS_SI_PORTAL_OBLIVION_PORTALS),
	GetString(MAP_PINS_SI_PORTAL_DARK_FISSURES),
	GetString(MAP_PINS_SI_PORTAL_CELESTIAL_RIFTS),
	GetString(MAP_PINS_SI_PORTAL_SHADOW_FISSURES),
	GetString(MAP_PINS_SI_PORTAL_LAVA_LASHERS),
	GetString(MAP_PINS_SI_PORTAL_SOUL_REAPER),
}

PinTypes[PORTALS] = {
	name = MAP_PINS_SI_PORTALS,
	labelIcon = '/esoui/art/icons/poi/poi_portal_complete.dds',
	filterTooltip = (function()
		local temp = {}

		for i = 1, #PORTAL_NAMES_MAPPING do
			temp[i] = PORTAL_TOOLTIP_TEMPLATE:format(PORTAL_NAMES_MAPPING[i])
		end

		return table.concat(temp, '\n')
	end)(),
	texture = '/esoui/art/icons/poi/poi_portal_complete.dds',
	maxDistance = 0.05,
	level = 30,
	size = 25.2,  -- TODO: 0.2?
	-- TODO: different icons for different portals?
	-- atlas = _t('dummy8x2.dds'),  -- TODO
	-- atlasW = 8,
	-- atlasH = 2,
	panels = {PANEL_PVE},
	getPins = function(self)
		local map = _getFileName()
		local data = MP['Portals'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}
		for index, pinDatum in ipairs(data) do
			local someIndex = pinDatum[3]
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
				-- atlasIndex = pinDatum[3],
				tag = someIndex,
			}
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local icon = '/esoui/art/icons/poi/poi_portal_complete.dds'
			local name = PORTAL_NAMES[tag]

			ShowInformationTooltip(icon, name)
		end,
	},
}

PinTypes[HIGH_ISLE] = {
	name = MAP_PINS_SI_HIGH_ISLE,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_highisle_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[3298] = '/esoui/art/icons/achievement_u34_flavor4_druid.dds',
		[3424] = '/esoui/art/icons/u34_flavor5_drunkedleap.dds',  -- '/esoui/art/tutorial/gamepad/gp_icon_new.dds'
		[3299] = '/esoui/art/icons/achievement_u34_rds.dds',  -- '/esoui/art/miscellaneous/help_icon.dds'
		[3295] = '/esoui/art/icons/achievement_u34_flavor1_lockbox.dds',  -- '/esoui/art/icons/servicetooltipicons/servicetooltipicon_bagvendor.dds'
	}),
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_highisle_up.dds',
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	-- [28]={section=true,name='pinType_High_Isle'
	-- 	[3298]={name='pinType_Seeker_of_the_Green',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u34_flavor4_druid.dds',k=1},
	-- 	[3424]={name='pinType_No_Regrets',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/tutorial/gamepad/gp_icon_new.dds',k=1,def_texture='/esoui/art/icons/u34_flavor5_drunkedleap.dds'},
	-- 	[3299]={name='pinType_Inventor_of_Adventure',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_u34_rds.dds'},
	-- 	[3295]={name='pinType_Gonfalon_Bays_Master_Burglar',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/servicetooltipicons/servicetooltipicon_bagvendor.dds',k=1,def_texture='/esoui/art/icons/achievement_u34_flavor1_lockbox.dds'},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({3298, 3424, 3299, 3295}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

PinTypes[FIRESONG] = {
	name = MAP_PINS_SI_FIRESONG,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_firesong_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[3502] = 'esoui/art/icons/achievement_u36_zone_flavor1.dds',
		[3503] = 'esoui/art/icons/achievement_u36_zone_flavor2.dds',
		[3504] = 'esoui/art/icons/achievement_u36_zone_flavor3.dds',
		[3505] = 'esoui/art/icons/achievement_u36_zone_flavor4.dds',
	}),
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_firesong_up.dds',
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	-- [29]={section=true,name='pinType_Firesong'
	-- 	[3502]={name='pinType_The_Best_of_Friends',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor1.dds',k=1},
	-- 	[3503]={name='pinType_Ferret_the_Hunters',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor2.dds',k=1},
	-- 	[3504]={name='pinType_Firestarter',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor3.dds',k=1},
	-- 	[3505]={name='pinType_A_Joyous_Dance',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor4.dds',k=1},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({3502, 3503, 3504, 3505}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

PinTypes[NECROM] = {
	name = MAP_PINS_SI_NECROM,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_necrom_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[3678] = '/esoui/art/icons/achievement_u38_flavor4.dds',
		[3677] = '/esoui/art/icons/achievement_u38_flavor3.dds',
		[3675] = '/esoui/art/icons/achievement_u38_flavor1.dds',
		[3749] = '/esoui/art/icons/u38_slaughtered_apocrypha.dds',
	}),
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_necrom_up.dds',
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	-- [30]={section=true,name='pinType_Necrom'
	-- 	[3678]={name='pinType_Syzygy',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor4.dds',k=1},
	-- 	[3677]={name='pinType_Tomes_of_Uknown_Color',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor3.dds',k=1},
	-- 	[3675]={name='pinType_Grave_Discoveries',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor1.dds',k=1},
	-- 	[3749]={name='pinType_Slaughtered_by_Tentacles',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/u38_slaughtered_apocrypha.dds',k=1},
	-- },
	panels = {PANEL_PVE},
	getPins = AchievementHandler({3678, 3677, 3675, 3749}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

PinTypes[GOLD_ROAD] = {
	name = MAP_PINS_SI_GOLD_ROAD,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_goldroad_up.dds',
	filterTooltip = _achievementTooltipBuilder({
    	[3968] = '/esoui/art/icons/achievement_u42_zone_flavor1.dds',
    	[4040] = '/esoui/art/icons/achievement_u42_rds.dds',
    	[4041] = '/esoui/art/icons/u42_wandering_world_boss.dds',
	}),
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	size = 20,
	maxDistance = 0.05,
	level = 101,
	panels = {PANEL_PVE},
	getPins = AchievementHandler({3968, 4040, 4041}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip

	-- getPins = function(self)
    --     local map = _getFileName()
    --     local data = MP['Achievements'][map]

    --     if not data then return end  -- TODO: add diagnostic warn

	-- 	local out = {}
    --     for index, achievementId in pairs({3968, 4040, 4041}) do
    --         local achData = data[achievementId]
    --         if achData then
    --             for _, pinData in pairs(achData) do
    --                 local x, y, criterionIndex = pinData[1], pinData[2], pinData[3]

    --                 local completed
	-- 				if self.sv.Show[achievementId] then  -- pins of these achievements are always shown TODO: research which
	-- 					completed = false
	-- 				else
	-- 					if criterionIndex then
	-- 						local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
	-- 						completed = numCompleted >= numRequired
	-- 					else
	-- 						completed = IsAchievementComplete(achievementId)
	-- 					end
	-- 				end

	-- 				-- TODO: v move out, this must be filled on inventory change or full invventory scan
	-- 				local AchievementItems = {[1712]={},[1250]={},[2099]={},[1958]={},[2320]={},[2463]={},[2534]={},[2669]={},[2759]={}}

    --                 local haveItem = (AchievementItems[achievementId]
    --                                   and AchievementItems[achievementId][criterionIndex]) and true or false

    --                 if not (completed or haveItem) then
    --                     out[#out+1] = {
    --                         x = x,
    --                         y = y,
	-- 						atlasIndex = index,  -- TODO: no default
    --                     }
    --                 end
    --             end
    --         end
    --     end

    --     return out
    -- end,
}

PinTypes[SEASONS_OF_THE_WORM_CULT] = {
	name = MAP_PINS_SI_SEASONS_OF_THE_WORM_CULT,
	labelIcon = '/esoui/art/treeicons/tutorial_idexicon_goldroad_up.dds',
	filterTooltip = _achievementTooltipBuilder({
		[4432] = 'esoui/art/icons/achievement_u46_zone_flavor1.dds',
		[4433] = 'esoui/art/icons/achievement_u46_zone_flavor2.dds',
		[4434] = 'esoui/art/icons/achievement_u46_zone_flavor3.dds',
		[4435] = 'esoui/art/icons/achievement_u46_zone_flavor4.dds',
		[4455] = 'esoui/art/icons/u48_zone_flavor1.dds',
		[4456] = 'esoui/art/icons/u48_zone_flavor2.dds',
		[4457] = 'esoui/art/icons/u48_zone_flavor3.dds',
	}),
	atlas = _t('dummy8x2.dds'),  -- TODO
	atlasW = 8,
	atlasH = 2,
	maxDistance = 0.05,
	level = 101,
	size = 20,
	panels = {PANEL_PVE},
	getPins = AchievementHandler({4432, 4433, 4434, 4435, 4455, 4456, 4457}),
	tooltip = PinTypes[UNDAUNTED].tooltip,  -- default achievements tooltip
}

PinTypes[DYNAMIC_ENCOUNTERS] = {
	name = MAP_PINS_SI_DYNAMIC_ENCOUNTERS,
	labelIcon = '/esoui/art/icons/mapkey/mapkey_dynamic_world_event.dds',
	texture = '/esoui/art/icons/mapkey/mapkey_dynamic_world_event.dds',

	size = 24,
	maxDistance = 0.05,
	level = 100,
	panels = {PANEL_PVE},
	getPins = function(self)
		local map = _getFileName()
		local data = MP['DynamicEncounters'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}
		for _, pinDatum in ipairs(data) do
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
			}
		end

		return out
	end,
	tooltip = {
		-- TODO: legacy ZOS way of doing this is kinda fragile and disconnect between tooltip and creator is possible :/
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		creator = function(tag)
			local icon = '/esoui/art/icons/mapkey/mapkey_dynamic_world_event.dds'
			local name = GetString(MAP_PINS_SI_DYNAMIC_ENCOUNTERS)

			ShowInformationTooltip(icon, name)
		end,
	},
}

-- ----------------------------------------------------------------------------

local addon = {}

function addon:Initialize()
    self.sv = ZO_SavedVars:New('MP_SavedVars', 2, nil, DEFAULTS)
	self.gsv = ZO_SavedVars:NewAccountWide('MP_SavedGlobal', 1, nil, DEFAULTS_GLOBAL)  -- SavedGlobal

    self.customChestData = ZO_SavedVars:NewAccountWide('MP_ChestData', 2, nil, {})
	self.customThievesTroveData = ZO_SavedVars:NewAccountWide('MP_ThievesTrove', 2, nil, {})

	self.pinManager = ZO_WorldMap_GetPinManager()

    self.lastAchievement = nil

    self:AddSlashCommands()

    self.filterCount = 33  -- TODO: can replace by something better?

    -- zo_callLater(function()
	-- 	local loadIndex = 0
	-- 	EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, 5, function()
	-- 		loadIndex = loadIndex + 1
	-- 		if loadIndex == 1 then self:LoadBosses() end
	-- 		if loadIndex == 2 then self:LoadSkyShards() end
	-- 		if loadIndex == 3 then self:LoadLorebooks() end
	-- 		if loadIndex == 4 then self:LoadTreasureMaps() end
	-- 		if loadIndex == 5 then self:LoadUnknownPOI() end
	-- 		if loadIndex == 6 then self:LoadChestData() end
	-- 		if loadIndex == 7 then self:LoadAchievements() end
	-- 		if loadIndex == 8 then self:LoadFishingNodes() end
	-- 		if loadIndex == 9 then
	-- 			EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
	-- 			self:CreateFilter()
	-- 			self:CreateSettingMenu()

	-- 			self:OnMapChanged()
	-- 			CALLBACK_MANAGER:RegisterCallback('OnWorldMapChanged', function() self:OnMapChanged() end)
	-- 			self:RegisterEvents()
	-- 		end
	-- 	end)
	-- end, 250)

	self:MakeFiltersScroll()
	self:AddFilterControls()

	self.surfaces = {}  -- TODO: temporary

	self.activeFilters = {}

	self:RegisterEvents()
end


function addon:MakeFiltersScroll()
	if not WORLD_MAP_FILTERS then return end

	-- local panels = {'pvePanel', 'pvpPanel', 'imperialPvPPanel'}

	local panelSuffixes = {
		pvePanel         = 'PvE',
		pvpPanel         = 'PvP',
		imperialPvPPanel = 'ImperialPvP',
	}

	local function _makePanelScroll(panelName, suffix)
		local panel = WORLD_MAP_FILTERS[panelName]

		if not panel then
			error(('No panel %s found'):format(panelName))
			return
		end

		local parentName = 'ZO_WorldMapFilters'..suffix
		local containerName = parentName..'Container'
		local container = _G[containerName] or WINDOW_MANAGER:CreateControlFromVirtual(containerName, _G[parentName], 'ZO_ScrollContainer')
		local containerScrollChild = container:GetNamedChild('ScrollChild')

		container:SetAnchorFill()

		if panel.checkBoxPool then
			panel.checkBoxPool.parent = containerScrollChild
			for i, control in pairs(panel.checkBoxPool.m_Active) do
				control:SetParent(panel.checkBoxPool.parent)
			end

			local checkBoxName = parentName..'CheckBox1'
			local checkBox = _G[checkBoxName]
			if checkBox then
				local valid, point, control, relPoint, x, y = checkBox:GetAnchor(0)
				if control == panel.control then
					checkBox:SetAnchor(point, containerScrollChild, relPoint, x, y)
				end
			end
		end

		if panel.comboBoxPool then
			panel.comboBoxPool.parent = containerScrollChild
			for i, control in pairs(panel.comboBoxPool.m_Active) do
				control:SetParent(panel.comboBoxPool.parent)
			end

			local comboBoxName             = parentName..'ComboBox1'
			local comboBox = _G[comboBoxName]
			if comboBox then
				local valid, point, control, relPoint, x, y = comboBox:GetAnchor(0)
				if control == panel.control then
					comboBox:SetAnchor(point, containerScrollChild, relPoint, x, y)
				end
			end
		end
	end

	for panelName, panelSuffix in pairs(panelSuffixes) do
		_makePanelScroll(panelName, panelSuffix)
	end
end

local function _getFormattedMapPlayerPosition()
    local x, y = GetMapPlayerPosition('player')
	return string.format('%.3f,%.3f', x, y):gsub('0%.', '.')
end

local LOC = '%s={{%s,%s}},'
local LOC1 = '{%s,%s},'
local LOC2 = '%s={%s},'

function addon:AddSlashCommands()
    -- TODO: check commands #loc_commands_data_format
    SLASH_COMMANDS['/loc'] = function()
		CHAT_ROUTER:AddSystemMessage(LOC:format(_getFileName(), _getFormattedMapPlayerPosition(), self.lastAchivement))
	end

	SLASH_COMMANDS['/loc1'] = function()
		CHAT_ROUTER:AddSystemMessage(LOC1:format(_getFormattedMapPlayerPosition(), self.lastAchievement))
	end

	SLASH_COMMANDS['/loc2'] = function()
		CHAT_ROUTER:AddSystemMessage(LOC2:format(_getFileName(), _getFormattedMapPlayerPosition()))
    end

    --	SLASH_COMMANDS['/mpdm']=function() SavedGlobal.dm=not SavedGlobal.dm d('Map Pins developer mode is now '..(SavedGlobal.dm and 'Enabled' or 'Disabled')) end

    SLASH_COMMANDS['/pinsize'] = function(n)
		n = tonumber(n)

		if n and n >= 16 and n <= 40 then
			self:SetPinSize(n)
		else
			CHAT_ROUTER:AddSystemMessage('Requested pin size is out of range (16-40)')
		end
	end

	SLASH_COMMANDS['/mpshow'] = function(n)
        n = tonumber(n)
		if not n then return end

        local show = self.sv.Show

        if show[n] then
            show[n] = nil
        else
            show[n] = true
        end
	end

	SLASH_COMMANDS['/mpallfish'] = function()
		self.sv.AllFish = not self.sv.AllFish
		df('AllFish: %s', tostring(self.sv.AllFish))
		-- self.pinManager:RefreshCustomPins(_G['pinType_Fishing_Nodes'])  -- TODO
	end
end

function addon:SetPinSize(newSize)
    error('Unimplemented')
end

--[[
function addon:LoadBosses()
end

function addon:LoadSkyshards()
end

function addon:LoadLorebooks()
end

function addon:LoadTreasureMaps()
end

function addon:LoadUnknownPOI()
end

function addon:LoadChestData()
end

function addon:LoadAchievements()
end

function addon:LoadFishingNodes()
end
--]]

-- Setup/Call AddCustomPin for filters
function addon:CreateFilter()
    -- local function AddPin(pin, pinLayout)
	-- 	local TooltipCreator = (not PinTooltipSupres[pin] and PinTooltipCreator or nil)
	-- 	local name = pinLayout.name
	-- 	pinLayout.size = pinLayout.size or self.gsv.pinsize * pinLayout.k
	-- 	self.pinManager:AddCustomPin(name, function() MapPinAddCallback(pin) end, nil, pinLayout, TooltipCreator)
	-- 	local id = _G[name]
	-- 	return id
	-- end

	-- for i = 1, self.filterCount do
	-- 	local filter = PinTypes[i]
	-- 	if filter then
	-- 		if filter.section then
	-- 			for i0, pinLayout in pairs(filter) do
	-- 				if type(pinLayout) == 'table' and pinLayout.name then
	-- 					PinTypes[i0] = pinLayout
	-- 					pinLayout.filter = i
	-- 					local id = AddPin(i0, pinLayout)
	-- 					filter.id[i0] = id
    --                     PinId[i0] = id
	-- 					table.insert(filter.pin, i0)
	-- 				end
	-- 			end
	-- 			self.pinManager:AddCustomPin(filter.name)
	-- 			self.filterIdToFilterIndex[_G[filter.name]] = i
	-- 		else
	-- 			local id = AddPin(i,filter)
    --             filter.id[i] = id
    --             PinId[i] = id
	-- 			self.filterIdToFilterIndex[id] = i
	-- 		end
	-- 		if not self.sv[i] then self.sv[i] = false end  -- TODO: in DEFAULTS there are only ~20 filters, but looks like there are 33 in total
	-- 	end
	-- end
end

-- Create LHAS Settings Menu
function addon:CreateSettingMenu()
end

-- Added out filters to the filter controls
function addon:AddFilterControls()
	-- local function GetCroppedAchievementInfo(id)
	-- 	local name, _, _, icon = GetAchievementInfo(id)
	-- 	local pos = string.find(name, '<<player')
	-- 	return pos and table.concat({string.sub(name,0,pos-1), string.match(string.sub(name,pos), '<<player{([%D]+)/[%D]+}>>([%D]*)')}) or name, icon
	-- end

	-- local function SetNameForMapPinGroup(i)
	-- 	local mapPinGroup = _G[CustomPins[i].name]
	-- 	local icon = zo_iconFormat((CustomPins[i].def_texture or CustomPins[i].texture), 24, 24)
	-- 	local name = CustomPins[i].ach and GetCroppedAchievementInfo(i) or Loc(string.gsub(CustomPins[i].name,'pinType_',''))
	-- 	ZO_CreateStringId('SI_MAPFILTER' .. mapPinGroup, icon..' '..name)
	-- 	return mapPinGroup
	-- end

	-- local function FilterCallback()
	-- 	RegisterEvents()
	-- end

	self.checkboxToType = {}

	-- GAMEPAD_WORLD_MAP_FILTERS
	-- TODO: reafactor
	local function AddCheckBox(panel, customType, label, callback)
		-- if not panel.checkBoxPool then
        -- 	panel.checkBoxPool = ZO_ControlPool:New('ZO_CheckButton', panel.control, 'CheckBox')
    	-- end

		local checkBox = panel.checkBoxPool:AcquireObject()
		ZO_CheckButton_SetLabelText(checkBox, label)
		ZO_CheckButton_SetToggleFunction(checkBox, callback)
		panel:AnchorControl(checkBox)

		self.checkboxToType[checkBox] = customType

		ZO_CheckButton_SetCheckState(checkBox, self.sv[customType])

		local desc = PinTypes[customType]
		if desc.filterTooltip then
			-- TODO: each tooltip has separate function, refactor
			checkBox:SetHandler('OnMouseEnter', function(ctrl)
				ZO_Tooltips_ShowTextTooltip(ctrl, LEFT, type(desc.filterTooltip) == 'string' and desc.filterTooltip or desc.filterTooltip())
			end)
			checkBox:SetHandler('OnMouseExit', ZO_Tooltips_HideTextTooltip)
		end

	end

	local function onCheckboxChange(checkbox, checked)
		local type = self.checkboxToType[checkbox]
		-- df('MapPins checkbox type %d changed to %s', type, tostring(checked))
		self.sv[type] = checked
		self:UpdatePins(type)
	end

	-- TODO: check if refactoring needed
	for type, desc in ipairs(PinTypes) do
		local label = self:GetPinTypeLabel(type)
		df('Creating checkbox for id %d type, label: %s', type, label)
		for _, panelName in ipairs(desc.panels) do
			AddCheckBox(WORLD_MAP_FILTERS[panelName], type, label, onCheckboxChange)
		end
	end
end

function addon:GetPinTypeLabel(type)  -- TODO: actual names, translated
	-- return ('Text %d'):format(type)
	local desc = PinTypes[type]
	local icon = zo_iconFormat(desc.labelIcon, 24, 24) or ''

	return '(n) '..icon..GetString(desc.name)
end

--[[
function addon:OnMapChanged()
    if not GAMEPAD_WORLD_MAP_FILTERS then return end

    -- Q: what 'i' is? TODO: better naming
	for mapPinGroup, i in pairs(self.filterIdToFilterIndex) do
        GAMEPAD_WORLD_MAP_FILTERS.currentPanel:SetPinFilter(mapPinGroup, self.sv[i] ~= false)
	end
end
--]]

function addon:ReanchorActiveFilters()  -- TODO: rename
	-- local panel = WORLD_MAP_FILTERS[panelName]
	local panel = WORLD_MAP_FILTERS.currentPanel

	-- global is not used in Map Pins
	if WORLD_MAP_FILTERS.currentPanel == WORLD_MAP_FILTERS.globalPanel then
		return
	end

	local scrollChildControl = panel.control:GetNamedChild('ContainerScrollChild')

	-- TODO: not ideal, but it will work, implement something better?
	local previousControl = scrollChildControl:GetChild(1)
	local lastOriginalControlIndex = #panel.pinFilterCheckBoxes + #panel.pinFilterOptionComboBoxes
	local maxBottom = 0
	for i = 2, lastOriginalControlIndex do
		local control = scrollChildControl:GetChild(i)
		local bottom = control:GetBottom()
		if bottom > maxBottom then
			previousControl = control
			maxBottom = bottom
		end
	end

	local previousOffsetX = panel.lastOffsetX
	for i = lastOriginalControlIndex+1, scrollChildControl:GetNumChildren() do
		local control = scrollChildControl:GetChild(i)

		-- TODO: decide implementation of hide/show
		-- local type = self.checkboxToType[checkbox]

		-- if PinTypes[type].showOnlyFor then
		-- 	if PinTypes[type].showOnlyFor[_getFileName()] then
		-- 		checkbox:SetHidden(false)
		-- 	else
		-- 		checkbox:SetHidden(true)
		-- 	end
		-- end

		local isActive = self.activeFilters[control]
		-- this implies that we should hide only inactive filter controls and show active AND all others (not owned by this addon)
		if isActive or isActive == nil then
			local offsetX = 0  -- all new checkboxes are at the same (0) offset
			control:ClearAnchors()
			control:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, offsetX - previousOffsetX, 8)

			previousControl = control
			previousOffsetX = offsetX
		end
	end
end

-- Setup the events that need fire
function addon:RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
		self:UpdateAllPins()
	end)

	CALLBACK_MANAGER:RegisterCallback('OnWorldMapChanged', function() self:OnMapChanged() end)
    CALLBACK_MANAGER:RegisterCallback('OnWorldMapModeChanged', function() self:OnMapChanged() end)
end

function addon:SetCheckboxTypeActive(type, active)
	for checkbox, type_ in pairs(self.checkboxToType) do
		if type == type_ then
			checkbox:SetHidden(not active)
			self.activeFilters[checkbox] = active  -- TODO: is there a better approach?
		end
	end
end

function addon:UpdatePins(type)
	self:RemovePins(type)

	if self.sv[type] then
		-- local success = self:AddPins(type)  -- TODO: decide how to implement feature to hide checkboxes
		self:AddPins(type)
	end
end

function addon:RemovePins(type)
	local canvas = self.surfaces[type]
	if canvas then
		canvas:Clear()
	end
end

function addon:AddPins(type_)
	self:InitializeCanvas(type_)

	local canvas = self.surfaces[type_]
	local map = _getFileName()
	local desc = PinTypes[type_]

	df('adding pins to map with file name %s', map)

	local pins = PinTypes[type_].getPins(self)
	df('%s pins affected', tostring(pins and #pins))
	if not pins then return end  -- early exit, no pins at all

	local size = desc.size or DEFAULT_PIN_SIZE  -- TODO: * scale 

	for i = 1, #pins do
		local pin = pins[i]
		canvas:Add(pin.x, pin.y, 0, 0, size, size, pin.atlasIndex or 1, pin.tag)
	end

	--[[
	if not PinTypes_[type_].coords then df('`coords` not found in (%d) %s', type_, GetString(PinTypes_[type_].name)) return end  -- TODO: remove afterwards, temporary plug

	if type(PinTypes_[type_].coords) == 'string' then
		local tbl = PinTypes_[type_].coords
		local pinData = MP[tbl][map]

		if not pinData then return end
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			canvas:Add(pinDatum[1], pinDatum[2], 0, 0, 32, 32, nil, {type_, i, map})
		end
	else
		df('Pin types with non-table coordinates not implemented yet')
	end
	--]]

	return true
end

function addon:InitializeCanvas(pinType)
	if self.surfaces[pinType] then return end

	local function _onMouseEnter(tag, surface, composite)
		df('mouse over type %d', pinType)
		composite:AnimateScale(surface, 1, 1.3, 150)
	end

	local function _onMouseExit(tag, surface, composite)
		df('mouse exit type %d', pinType)
		composite:AnimateScale(surface, 1.3, 1, 150)
	end

	-- local function _getTexture(type_)
	-- 	if PinTypes_[type_].texture and type(PinTypes_[type_].texture) == 'string' then
	-- 		return PinTypes_[type_].texture
	-- 	end

	-- 	if PinTypes_[type_].def_texture then
	-- 		return PinTypes_[type_].def_texture
	-- 	end

	-- 	return  '/esoui/art/icons/icon_missing.dds'
	-- end

	local surface = LibSurfaceTools.Tools.FlexRect(ZO_WorldMapContainer, nil, _onMouseEnter, _onMouseExit)
	self.surfaces[pinType] = surface

	local desc = PinTypes[pinType]
	if not desc then error('Type %d does not exist', pinType) return end  -- TODO: temporary

	if desc.texture then
		if type(desc.texture) == 'string' then
			surface:SetTexture(desc.texture)
		else
			surface:SetTexture('/esoui/art/icons/icon_missing.dds')  -- TODO: temrorary
		end
	elseif desc.atlas then
		-- TODO: separate quick check for debugging only
		if not (desc.atlasW and desc.atlasH) then error(('Atlas W or H is not set for %s'):format(PinTypes[pinType].name)) end
		surface:SetTexture(desc.atlas, desc.atlasW, desc.atlasH)
	else
		-- TODO: separate quick check for debugging only
		error(('Nor texture nor atlas is specified for %s'):format(GetString(PinTypes[pinType].name)))
	end

	if desc.tooltip then
		surface:AddTooltip(desc.tooltip)
	end

	if desc.level then
		-- TODO: level is common for all pins, but in legacy they could have different levels potentially
		-- TODO: have to see what pins are affected and what to do with that (likely not important at all) #draw_level
		local composite = surface.composite
		composite:SetDrawTier(DT_HIGH)
		composite:SetDrawLayer(DL_CONTROLS)
		composite:SetDrawLevel(desc.level)
	end
end

function addon:OnMapChanged()
	local newMapId = GetCurrentMapId()
	df('loaded mapId %s, new mapId %s', tostring(self.loadedMapId), tostring(newMapId))
	if newMapId == self.loadedMapId then return end

	self:UpdateAllPins()
	self:UpdateAllFiltersActivity()
	self:ReanchorActiveFilters()

	self.loadedMapId = newMapId
end

function addon:UpdateAllPins()
	for pinType = 1, self.filterCount do
		self:UpdatePins(pinType)
	end
end

function addon:UpdateAllFiltersActivity()
	df('UpdateAllFiltersVisibility')
	for pinType = 1, self.filterCount do
		-- TODO: decide how to implement feature to hide checkboxes
		-- TODO: not perfect because it takes more than accectable, can split getPins into 2 methods \
		-- TODO: and even cache results for slow queries
		local pins = PinTypes[pinType].getPins(self)
		self:SetCheckboxTypeActive(pinType, not not pins)
	end
end

-- ----------------------------------------------------------------------------

local function OnAddonLoad(_, addonName)
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)

    addon:Initialize()
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, OnAddonLoad)

MP = addon
