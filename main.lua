local ADDON_NAME = 'NewMapPins'
local ADDON_VERSION = 'X'
local EVENT_NAMESPACE = ADDON_NAME..'_EVENT_NAMESPACE'

local function _t(filename)
	return ('/%s/textures/%s'):format(ADDON_NAME, filename)
end

local function _getFileName()
    return GetMapTileTexture():match('[^\\/]+$'):lower():gsub('%.dds$', ''):gsub('_[0-9]+$', '')
end

-- ----------------------------------------------------------------------------

-- Q: what 1..21 means? No 20?
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

local DELVE_BOSSES = 1
local DELVE_BOSSES_DONE = 2
local SKYSHARDS = 3
local SKYSHARDS_DONE = 4
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


local PinTypes = {}

PinTypes[DELVE_BOSSES] = {
	name = MAP_PINS_SI_DELVE_BOSSES,  -- TODO: think about direct GetText vs late evaluation
	maxDistance = 0.05,
	level = 30,
	texture = '/esoui/art/icons/poi/poi_groupboss_incomplete.dds',
	size = 25,
	coords = 'Bosses',
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['Bosses'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local achievementId, criterionIndex = pinDatum[3], pinDatum[4]
			local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
			if numCompleted ~= numRequired then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = {achievementId, criterionIndex},
				}
			end
		end

		return out
	end
}
-- TODO: STYLE IT LATER
PinTypes[DELVE_BOSSES_DONE] = {
	name = MAP_PINS_SI_DELVE_BOSSES_DONE,
	maxDistance = 0.05,
	level = 30,  -- TODO: never used yet
	texture = '/esoui/art/icons/poi/poi_groupboss_complete.dds',
	size = 25,
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['Bosses'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local achievementId, criterionIndex = pinDatum[3], pinDatum[4]
			local description, numCompleted, numRequired = GetAchievementCriterion(achievementId, criterionIndex)
			if numCompleted == numRequired then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = {achievementId, criterionIndex},
				}
			end
		end

		return out
	end
}

PinTypes[SKYSHARDS] = {
	name = MAP_PINS_SI_SKYSHARDS,
	maxDistance = 0.05,
	level = 100,
	texture = _t('Skyshard_1.dds'),
	size = 28,
	getPins = function(self)
		local map = _getFileName()
		local pinData = MP['SkyShards'][map]

		if not pinData then return end  -- TODO: add diagnostic warn

		local out = {}
		for i = 1, #pinData do
			local pinDatum = pinData[i]
			local skyshardId = pinDatum[5]  -- TODO: what about 3 and 4? Why logic in legacy is so complex? Ask about DumbSkyshardFix
			local skyshardDiscoveryStatus = GetSkyshardDiscoveryStatus(skyshardId)
			if skyshardDiscoveryStatus ~= SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					tag = skyshardId,
				}
			end
		end

		return out
	end
}

PinTypes[SKYSHARDS_DONE] = {
	name = MAP_PINS_SI_SKYSHARDS_DONE,
	maxDistance=0.05,level=100,texture='/esoui/art/tutorial/gamepad/achievement_categoryicon_skyshards.dds',
	size = 28,  -- 1.38 * 20 - does 0.02 actually matter?
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
					tag = skyshardId,
				}
			end
		end

		return out
	end
}

PinTypes[LOREBOOKS] = {
	name = MAP_PINS_SI_LOREBOOKS,
	maxDistance=0.05,level=100,texture=_t('Lorebook_1.dds'),tint=ZO_ColorDef:New(.6,.6,1,.8),
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
	end
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
PinTypes[TREASURE_MAPS] = {
	name = MAP_PINS_SI_TREASURE_MAPS,
	maxDistance = 0.05,
	level = 101,
	-- texture = function(self) return self.m_PinTag.texture end,
	-- def_texture = _texture('Treasure_1.dds'),
	size = 28,
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
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
				-- local pinTag = { [1] = i, [2] = itemData.slotIndex, texture = atlasIndex }

				out[#out+1] = {
					x = pinDatum[1],
					y = pinDatum[2],
					atlasIndex = atlasIndex,
					tag = nil,  -- TODO
				}
			end
		end

		return out
	end,
	-- TODO: d('You can find ''..itemData.name..'' in this zone')
}

PinTypes[TREASURE_CHESTS] = {
	name = MAP_PINS_SI_TREASURE_CHESTS,
	maxDistance = 0.05,
	level = 100,
	-- texture = _t('Chest_1.dds'),
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	size = 22,
	tint = ZO_ColorDef:New(1, 1, 1, .8),  -- tint=ZO_ColorDef:New(.8,.8,.5,.9)
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
	end

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

PinTypes[UNKNOWN_POI] = {
	name = MAP_PINS_SI_UNKNOWN_POI,
	maxDistance = 0.05,
	level = 10,
	-- texture = function(self) return self.m_PinTag.texture end,
	-- def_texture = '/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds',
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	size = 40,
	tint = ZO_ColorDef:New(.7, .7, .7, .6),
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

					--check if data is missing
					if extras == 1 or extras == 2 then
						if not data or not data[poiIndex] then
							extras = nil
						end
					end

					-- local pinTag={[1] = i, name = objectiveName, texture = icon}

					-- TODO: simplify, move out, it only works in english?
					local function GetSetDescription(setData)
						if setData then
							local itemLink=('|H1:item:%d:370:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h'):format(setData[1])
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

					local desc
					if extras == 1 then	 -- Mundus
						desc = GetAbilityDescription(data[poiIndex])
					elseif extras == 2 then  -- Crafting station
						desc, desc = GetSetDescription(data[poiIndex])  -- TODO
					end

					-- TODO: is norm > 0 really needed?
					if (not isDiscovered and (normalizedX > 0 or normalizedY > 0)) or extras then
						out[#out+1] = {
							x = normalizedX,
							y = normalizedY,
						}
						-- TODO: size thing is weird
						-- local size = (BUI and BUI.name == 'BanditsUserInterface' and BUI.init.MiniMap) and 40 * BUI.Vars.PinScale/100 or 40
						-- ZO_MapPin.PIN_DATA[id].size = size
					end
				end
			end
		end

		return out
	end
}

local function AchievementHandler(achievements)
	return function(self)
		local map = _getFileName()
		local data = MP['Achievements'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local pinsPotentionallyExist = false
		local out = {}
		for index, achievementId in pairs(achievements) do
			local achievementData = data[achievementId]
			if achievementData then
				pinsPotentionallyExist = true
				for _, pinData in pairs(achievementData) do
					local x, y, criterionIndex = pinData[1], pinData[2], pinData[3]

					local completed
					if self.sv.Show[achievementId] then  -- pins of these achievements are always shown TODO: research which
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
							-- TODO: tag?
						}
					end
				end
			end
		end

		return pinsPotentionallyExist and out
	end
end

PinTypes[UNDAUNTED] = {
	name = MAP_PINS_SI_UNDAUNTED,
	-- texture = '/esoui/art/icons/crafting_beer_003.dds',
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	maxDistance = 0.05,
	level = 101,
	size = 20,
	-- 	[704] = {name='pinType_This_One\'s_On_Me', texture='/esoui/art/icons/crafting_beer_003.dds'},
	-- [1082] = {name='pinType_Undaunted_Rescuer', texture='/esoui/art/icons/ability_warrior_007.dds'},
	getPins = AchievementHandler({704, 1082}),
}

PinTypes[WORLD_ACHIEVEMENTS] = {
	name = MAP_PINS_SI_WORLD_ACHIEVEMENTS,
	-- texture = '/esoui/art/progression/progression_indexicon_world_up.dds',
	maxDistance = 0.05,
	level = 101,
	size = 20,  -- TODO: Lightbringer size 25!
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,

	-- [10]={section=true,name='World_achievements',id={},pin={},texture='/esoui/art/progression/progression_indexicon_world_up.dds',
	-- 	[872]={name='pinType_I_like_M\'aiq',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_066.dds',k=1},
	-- 	[873]={name='pinType_Lightbringer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1.25},
	-- 	[716]={name='pinType_Peacemaker',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/ability_healer_017.dds',k=1},
	-- },

	getPins = AchievementHandler({872, 873, 716}),
}

PinTypes[ORSINIUM] = {
	name = MAP_PINS_SI_ORSINIUM,
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds',
	maxDistance = 0.05,
	level = 101,
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	size = 20,
	-- [11]={section=true,name='Orsinium',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds',	--'/esoui/art/icons/store_orsiniumdlc_collectable.dds',
	-- 	[1247]={name='pinType_One_Last_Brawl',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_010.dds',k=1},
	-- 	[1316]={name='pinType_Orsinium_Patron',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_024.dds',k=1,},
	-- 	[1250]={name='pinType_Wrothgar_Relic_Hunter',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_008.dds',k=1},
	-- },
	getPins = AchievementHandler({1247, 1316, 1250}),

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

PinTypes[THIEVES_GUILD] = {
	name = MAP_PINS_SI_THIEVES_GUILD,
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds',
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
	getPins = AchievementHandler({1383, 1349}),
}

PinTypes[MORROWIND] = {
	name = MAP_PINS_SI_MORROWIND,
	texture = '/esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds',
	-- [13]={section=true,name='Morrowind',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds',	--'/esoui/art/icons/store_morrowind_collectable.dds',
	-- 	[1824]={name='pinType_Vivec_Lessons',done=false,ach=true,maxDistance=0.05,level=100,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1,tint=ZO_ColorDef:New(.8,.8,.8,.8)},
	-- 	[1712]={name='pinType_Ancestral_Tombs',done=false,ach=true,maxDistance=0.05,level=30,texture='/esoui/art/icons/poi/poi_crypt_incomplete.dds',k=1},
	-- 	[1827]={name='pinType_Pilgrim\'s_Path',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_vvardenfel_032.dds',k=1},
	-- },
	maxDistance = 0.05,
	level = 101,  -- TODO: different levels! + tints
	size = 20,
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	getPins = AchievementHandler({1824, 1712, 1827}),

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
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_summerset_up.dds',

	-- [14]={section=true,name='Summerset',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_summerset_up.dds',	--'/esoui/art/icons/store_summerset_collectable.dds',
	-- 	[2099]={name='pinType_Summerset_Relics',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/quest_strosmkai_open_treasure_chest.dds',k=1},
	-- 	[2211]={name='pinType_Message_in_Bottle',done=false,ach=true,maxDistance=0.05,level=100,texture='/esoui/art/icons/crafting_stoneware_bottle_003.dds',k=1},
	-- 	[2171]={name='pinType_Summerset_world_event',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1.25,def_texture='/esoui/art/icons/achievement_su_rds_01.dds'},
	-- },

	maxDistance = 0.05,
	level = 101,  -- TODO: different levels! + tints + size
	size = 20,
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	getPins = AchievementHandler({2099, 2211, 2171}),

	-- showOnlyFor = {
	-- 	['summerset_base'] = true,
	-- 	['shimmerene_base'] = true,
	-- },
}

PinTypes[TIME_RIFTS] = {
	name = MAP_PINS_SI_TIME_RIFTS,
	maxDistance = 0.05,
	level = 101,
	texture = _t('Treasure_1-2.dds'),
	size = 36,
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

		-- TODO: listen for some quest event to update pins
	end
}

PinTypes[SHRINES] = {
	name = MAP_PINS_SI_SHRINES,
	maxDistance = 0.05,
	level = 101,
	-- texture = '/esoui/art/icons/poi/poi_daedricruin_incomplete.dds',
	size = 25,

	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,

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
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 2,  -- Oily = Foul
	[6] = 4,  -- Mystic = Salt
	[7] = 3,  -- Running = River
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

		-- TODO: is FishingBugFix needed?
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

PinTypes[FISHING_NODES] = {
	name = MAP_PINS_SI_FISHING_NODES,
	maxDistance = 0.05,
	level = 101,
	-- texture = '/esoui/art/icons/achievements_indexicon_fishing_up.dds',
	size = 25,
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	getPins = function(self)
		local map = _getFileName()
		local data = MP['FishingNodes'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local nodesToShow
		if self.sv.AllFish then
			nodesToShow = {true, true, true, true}
		else
			-- TODO: meh
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

PinTypes[CLOCKWORK_CITY] = {
	name = MAP_PINS_SI_CLOCKWORK_CITY,
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_cwc_up.dds',
	texture = '/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds',

	-- [18]={section=true,name='pinType_Clockwork_City',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_cwc_up.dds',	--'/art/fx/texture/clockworksigil.dds',
	-- 	[1958]={name='pinType_Precursor_Maker',texture='/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds',def_texture='/esoui/art/icons/achievement_update16_001.dds'},
	-- },
	maxDistance = 0.05,
	level = 101,
	size = 20,
	-- atlas = _t('dummy8x2.dds'),
	-- atlasW = 8,
	-- atlasH = 2,
	getPins = AchievementHandler({1958}),

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
	texture = '/esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds',
	-- [19]={section=true,name='pinType_Murkmire',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds',	--'/esoui/art/icons/store_murkmiredlc_collectable.dds',
	-- 	[2320]={name='pinType_Chronic_Chronogler',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_stylematerial.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_museum.dds'},
	-- 	[2341]={name='pinType_Poems_of_Nothing',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1},
	-- 	[2355]={name='pinType_Achievement_quests',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/tutorial/gamepad/gp_icon_new.dds',k=1},	--esoui/art/floatingmarkers/quest_icon.dds
	-- 	[2330]={name='pinType_Surreptitiously_Shadowed',done=false,ach=true,maxDistance=0.05,level=111,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_shadowscale_wisdom.dds'},
	-- 	[2358]={name='pinType_Swamp_Rescuer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/death/death_soulreservoir_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_rescue_villagers.dds'},
	-- 	[2357]={name='pinType_Vine-Tongue_Traveler',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Lorebook_1-2.dds',k=1,def_texture='/esoui/art/icons/mh_hedgeguardian_strang.dds'},
	-- },

	getPins = AchievementHandler({2320, 2341, 2355, 2330, 2358, 2357}),
}

PinTypes[ELSWEYR] = {
	name = MAP_PINS_SI_ELSWEYR,
	texture = '/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds',
	-- [20]={section=true,name='pinType_Elsweyr',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds',
	-- 	[2463]={name='pinType_Mural_Mender',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_els_museum_mural.dds',k=1},
	-- 	[2534]={name='pinType_Pieces_of_History',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_museum_tapestry.dds',k=1},
	-- 	[2619]={name='pinType_Theater_Critic',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1,def_texture='/esoui/art/icons/quest_book_003.dds'},
	-- 	[2621]={name='pinType_Legacy_Slayer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_familyofpirates.dds',k=1},
	-- 	[2620]={name='pinType_Grappling_Bow_Pathfinder',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_grappletreasures.dds',k=1},
	-- },

	getPins = AchievementHandler({2463, 2534, 2619, 2621, 2620}),
}

PinTypes[VOLENDRUNG] = {
	name = MAP_PINS_SI_VOLENDRUNG,
	texture = '/esoui/art/miscellaneous/help_icon.dds',
	size = 25,
	maxDistance = 0.05,
	level = 30,

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
	end
}

PinTypes[MARKARTH] = {
	name = MAP_PINS_SI_MARKARTH,
	texture = '/esoui/art/treeicons/tutorial_indexicon_markarth_up.dds',
	-- [22]={section=true,name='pinType_Markarth',id={},pin={},texture='/esoui/art/treeicons/tutorial_indexicon_markarth_up.dds',
	-- 	[2927]={name='pinType_Red_Eagle\'s_Flight',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u28_jump_flavor.dds',k=1},
	-- 	[2851]={name='pinType_Offerings_to_the_Old_Spirits',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u28_reach_flavor.dds',k=1},
	-- 	[2964]={name='pinType_A_friend_in_deed',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/ability_u26_vampire_infection_stage4.dds',k=1},
	-- },

	getPins = AchievementHandler({2927, 2851, 2964}),
}

PinTypes[GREYMOOR] = {
	name = MAP_PINS_SI_GREYMOOR,
	texture = '/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds',
	-- [23]={section=true,name='pinType_Greymoor',id={},pin={},texture='/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds',
	-- 	[2669]={name='pinType_Instrumental_Triumph',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_u26_skyrim_sounds_of_success.dds'},
	-- 	[2759]={name='Mining_Sample_Collector',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/poi/poi_mine_compete.dds',k=1,def_texture='/esoui/art/icons/achievement_u26_skyrim_minerquest.dds'},
	-- },

	getPins = AchievementHandler({2669, 2759}),
}

PinTypes[ANTIQUITIES] = {
	name = MAP_PINS_SI_ANTIQUITIES,
	texture = '/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds',
	-- [24]={section=true,name='pinType_Antiquities',id={},pin={},texture='/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds', k=1.40,
	-- 	[70]={name='pinType_Antiquity_Leads'},
	-- },-- this doesn't need to be 70 but it's used to display hidden Leads

	size = 28,
	maxDistance = 0.05,
	level = 101,

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
				}
			end
		end

		return out
	end

	-- TODO: name = ZO_CachedStrFormat("<<C:1>>",GetAntiquityName(pinData[3]))
}

PinTypes[BLACKWOOD] = {
	name = MAP_PINS_SI_BLACKWOOD,
	texture = '/esoui/art/treeicons/tutorial_idexicon_blackwood_up.dds',
	-- [25]={section=true,name='pinType_Blackwood',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_blackwood_up.dds',
	-- 	[3083]={name='pinType_Lost_in_Wilds',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor4.dds',k=1},
	-- 	[3081]={name='pinType_Bane_of_Sul-Xan',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor2.dds',k=1},
	-- 	[3082]={name='pinType_Most_Admired',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_rds.dds',k=1},
	-- 	[74]={name='pinType_Random_Encounters',done=false,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1},
	-- 	[3080]={name='pinType_Leyawiin_Master_Burglar',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor1.dds',k=1},
	-- },

	getPins = AchievementHandler({3083, 3081, 3082, 74, 3080}),
}

PinTypes[IMPERIAL_CITY] = {
	name = MAP_PINS_SI_IMPERIAL_CITY,
	texture = '/esoui/art/compass/ava_imperialcity_neutral.dds',
	-- [26]={section=true,name='pinType_Imperial_City',id={},pin={},texture='/esoui/art/compass/ava_imperialcity_neutral.dds',
	-- 	[76]={name='pinType_IC_Bosses',done=false,maxDistance=0.05,level=101,texture='/esoui/art/icons/poi/poi_groupboss_incomplete.dds',k=1.25},
	-- 	[77]={name='pinType_IC_Respawns',done=false,maxDistance=0.05,level=101,texture='/esoui/art/death/death_soulreservoir_icon.dds',k=1},
	-- 	[1270]={name='pinType_Cunning_Scamp',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_ic_telvarscamp.dds',k=1},
	-- 	[1272]={name='pinType_Trove_Scamp',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_ic_treasurescamp.dds',k=1},
	-- },

	getPins = AchievementHandler({76, 77, 1270, 1272}),

}

PinTypes[PORTALS] = {
	name = MAP_PINS_SI_PORTALS,
	texture = '/esoui/art/icons/poi/poi_portal_complete.dds',
	maxDistance = 0.05,
	level = 30,
	size = 25.2,  -- TODO: 0.2?

	-- atlas = _t('dummy8x2.dds'),
	-- atlasW = 8,
	-- atlasH = 2,

	getPins = function(self)
		local map = _getFileName()
		local data = MP['Portals'][map]

		if not data then return end  -- TODO: add diagnostic warn

		local out = {}
		for index, pinDatum in ipairs(data) do
			out[#out+1] = {
				x = pinDatum[1],
				y = pinDatum[2],
				-- atlasIndex = pinDatum[3],
			}
		end

		return out
	end
}

PinTypes[HIGH_ISLE] = {
	name = MAP_PINS_SI_HIGH_ISLE,
	texture = '/esoui/art/treeicons/tutorial_idexicon_highisle_up.dds',
	-- [28]={section=true,name='pinType_High_Isle',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_highisle_up.dds',
	-- 	[3298]={name='pinType_Seeker_of_the_Green',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u34_flavor4_druid.dds',k=1},
	-- 	[3424]={name='pinType_No_Regrets',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/tutorial/gamepad/gp_icon_new.dds',k=1,def_texture='/esoui/art/icons/u34_flavor5_drunkedleap.dds'},
	-- 	[3299]={name='pinType_Inventor_of_Adventure',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_u34_rds.dds'},
	-- 	[3295]={name='pinType_Gonfalon_Bays_Master_Burglar',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/servicetooltipicons/servicetooltipicon_bagvendor.dds',k=1,def_texture='/esoui/art/icons/achievement_u34_flavor1_lockbox.dds'},
	-- },

	getPins = AchievementHandler({3298, 3424, 3299, 3295}),
}

PinTypes[FIRESONG] = {
	name = MAP_PINS_SI_FIRESONG,
	texture = '/esoui/art/treeicons/tutorial_idexicon_firesong_up.dds',
	-- [29]={section=true,name='pinType_Firesong',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_firesong_up.dds',
	-- 	[3502]={name='pinType_The_Best_of_Friends',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor1.dds',k=1},
	-- 	[3503]={name='pinType_Ferret_the_Hunters',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor2.dds',k=1},
	-- 	[3504]={name='pinType_Firestarter',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor3.dds',k=1},
	-- 	[3505]={name='pinType_A_Joyous_Dance',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor4.dds',k=1},
	-- },

	getPins = AchievementHandler({3502, 3503, 3504, 3505}),
}

PinTypes[NECROM] = {
	name = MAP_PINS_SI_NECROM,
	texture = '/esoui/art/treeicons/tutorial_idexicon_necrom_up.dds',
	-- [30]={section=true,name='pinType_Necrom',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_necrom_up.dds',
	-- 	[3678]={name='pinType_Syzygy',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor4.dds',k=1},
	-- 	[3677]={name='pinType_Tomes_of_Uknown_Color',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor3.dds',k=1},
	-- 	[3675]={name='pinType_Grave_Discoveries',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor1.dds',k=1},
	-- 	[3749]={name='pinType_Slaughtered_by_Tentacles',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/u38_slaughtered_apocrypha.dds',k=1},
	-- },

	getPins = AchievementHandler({3678, 3677, 3675, 3749}),
}

PinTypes[GOLD_ROAD] = {
	name = MAP_PINS_SI_GOLD_ROAD,
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_goldroad_up.dds',
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	size = 20,
	maxDistance = 0.05,
	level = 101,
	-- children = {  TODO: atlas
    --     [3968] = { texture = '/esoui/art/icons/achievement_u42_zone_flavor1.dds' },
    --     [4040] = { texture = '/esoui/art/icons/achievement_u42_rds.dds' },
    --     [4041] = { texture = '/esoui/art/icons/u42_wandering_world_boss.dds' },
	-- },

	getPins = AchievementHandler({3968, 4040, 4041}),

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
	-- texture = '/esoui/art/treeicons/tutorial_idexicon_goldroad_up.dds',
	atlas = _t('dummy8x2.dds'),
	atlasW = 8,
	atlasH = 2,
	maxDistance = 0.05,
	level = 101,
	size = 20,
	-- {
	-- 	[4432] = {texture='/esoui/art/icons/achievement_u46_zone_flavor1.dds'},
	-- 	[4433] = {texture='/esoui/art/icons/achievement_u46_zone_flavor2.dds'},
	-- 	[4434] = {texture='/esoui/art/icons/achievement_u46_zone_flavor3.dds'},
	-- 	[4435] = {texture='/esoui/art/icons/achievement_u46_zone_flavor4.dds'},
	-- 	[4455] = {texture='/esoui/art/icons/u48_zone_flavor1.dds'},
	-- 	[4456] = {texture='/esoui/art/icons/u48_zone_flavor2.dds'},
	-- 	[4457] = {texture='/esoui/art/icons/u48_zone_flavor3.dds'},
	-- },
	getPins = AchievementHandler({4432, 4433, 4434, 4435, 4455, 4456, 4457}),
}

PinTypes[DYNAMIC_ENCOUNTERS] = {
	name = MAP_PINS_SI_DYNAMIC_ENCOUNTERS,
	texture = '/esoui/art/icons/mapkey/mapkey_dynamic_world_event.dds',

	size = 24,
	maxDistance = 0.05,
	level = 100,

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
	end
}

local PinsNirn = {[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true,[20]=true,[22]=true,[23]=true,[24]=true,[25]=true,[27]=true,[28]=true,[29]=true,[30]=true,[31]=true,[32]=true,[33]=true}
local PinsAva = {[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[17]=true,[21]=true}
local PinsImperial = {[3]=true,[5]=true,[7]=true,[8]=true,[17]=true,[26]=true}

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

	--[[
	if WORLD_MAP_FILTERS.pvePanel then
		if WORLD_MAP_FILTERS.pvePanel.checkBoxPool then
			WORLD_MAP_FILTERS.pvePanel.checkBoxPool.parent=ZO_WorldMapFiltersPvEContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual('ZO_WorldMapFiltersPvEContainer',ZO_WorldMapFiltersPvE,'ZO_ScrollContainer'):GetNamedChild('ScrollChild')
			for i,control in pairs(WORLD_MAP_FILTERS.pvePanel.checkBoxPool.m_Active) do
				control:SetParent(WORLD_MAP_FILTERS.pvePanel.checkBoxPool.parent)
			end
			if ZO_WorldMapFiltersPvECheckBox1 then
				local valid,point,control,relPoint,x,y=ZO_WorldMapFiltersPvECheckBox1:GetAnchor(0)
				if control==WORLD_MAP_FILTERS.pvePanel.control then
					ZO_WorldMapFiltersPvECheckBox1:SetAnchor(point,ZO_WorldMapFiltersPvEContainerScrollChild,relPoint,x,y)
				end
			end
		end

		if WORLD_MAP_FILTERS.pvePanel.comboBoxPool then
			WORLD_MAP_FILTERS.pvePanel.comboBoxPool.parent=ZO_WorldMapFiltersPvEContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual('ZO_WorldMapFiltersPvEContainer',ZO_WorldMapFiltersPvE,'ZO_ScrollContainer'):GetNamedChild('ScrollChild')
			for i,control in pairs(WORLD_MAP_FILTERS.pvePanel.comboBoxPool.m_Active) do
				control:SetParent(WORLD_MAP_FILTERS.pvePanel.comboBoxPool.parent)
			end
			if ZO_WorldMapFiltersPvEComboBox1 then
				local valid,point,control,relPoint,x,y=ZO_WorldMapFiltersPvEComboBox1:GetAnchor(0)
				if control==WORLD_MAP_FILTERS.pvePanel.control then
					ZO_WorldMapFiltersPvEComboBox1:SetAnchor(point,ZO_WorldMapFiltersPvEContainerScrollChild,relPoint,x,y)
				end
			end
		end
		if ZO_WorldMapFiltersPvEContainer then ZO_WorldMapFiltersPvEContainer:SetAnchorFill() end
	end

	if WORLD_MAP_FILTERS.pvpPanel then
		if WORLD_MAP_FILTERS.pvpPanel.checkBoxPool then
			WORLD_MAP_FILTERS.pvpPanel.checkBoxPool.parent=ZO_WorldMapFiltersPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual('ZO_WorldMapFiltersPvPContainer',ZO_WorldMapFiltersPvP,'ZO_ScrollContainer'):GetNamedChild('ScrollChild')
			for i,control in pairs(WORLD_MAP_FILTERS.pvpPanel.checkBoxPool.m_Active) do
				control:SetParent(WORLD_MAP_FILTERS.pvpPanel.checkBoxPool.parent)
			end
			if ZO_WorldMapFiltersPvPCheckBox1 then
				local valid,point,control,relPoint,x,y=ZO_WorldMapFiltersPvPCheckBox1:GetAnchor(0)
				if control==WORLD_MAP_FILTERS.pvpPanel.control then
					ZO_WorldMapFiltersPvPCheckBox1:SetAnchor(point,ZO_WorldMapFiltersPvPContainerScrollChild,relPoint,x,y)
				end
			end
		end
		if WORLD_MAP_FILTERS.pvpPanel.comboBoxPool then
			WORLD_MAP_FILTERS.pvpPanel.comboBoxPool.parent=ZO_WorldMapFiltersPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual('ZO_WorldMapFiltersPvPContainer',ZO_WorldMapFiltersPvP,'ZO_ScrollContainer'):GetNamedChild('ScrollChild')
			for i,control in pairs(WORLD_MAP_FILTERS.pvpPanel.comboBoxPool.m_Active) do
				control:SetParent(WORLD_MAP_FILTERS.pvpPanel.comboBoxPool.parent)
			end
			if ZO_WorldMapFiltersPvPComboBox1 then
				local valid,point,control,relPoint,x,y=ZO_WorldMapFiltersPvPComboBox1:GetAnchor(0)
				if control==WORLD_MAP_FILTERS.pvpPanel.control then
					ZO_WorldMapFiltersPvPComboBox1:SetAnchor(point,ZO_WorldMapFiltersPvPContainerScrollChild,relPoint,x,y)
				end
			end
		end
		if ZO_WorldMapFiltersPvPContainer then ZO_WorldMapFiltersPvPContainer:SetAnchorFill() end
	end

	if WORLD_MAP_FILTERS.imperialPvPPanel then
		if WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool then
			WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool.parent=ZO_WorldMapFiltersImperialPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual('ZO_WorldMapFiltersImperialPvPContainer',ZO_WorldMapFiltersImperialPvP,'ZO_ScrollContainer'):GetNamedChild('ScrollChild')
			for i,control in pairs(WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool.m_Active) do
				control:SetParent(WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool.parent)
			end
			if ZO_WorldMapFiltersImperialPvPCheckBox1 then
				local valid,point,control,relPoint,x,y=ZO_WorldMapFiltersImperialPvPCheckBox1:GetAnchor(0)
				if control==WORLD_MAP_FILTERS.imperialPvPPanel.control then
					ZO_WorldMapFiltersImperialPvPCheckBox1:SetAnchor(point,ZO_WorldMapFiltersImperialPvPContainerScrollChild,relPoint,x,y)
				end
			end
		end
		if WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool then
			WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool.parent=ZO_WorldMapFiltersImperialPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual('ZO_WorldMapFiltersImperialPvPContainer',ZO_WorldMapFiltersImperialPvP,'ZO_ScrollContainer'):GetNamedChild('ScrollChild')
			for i,control in pairs(WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool.m_Active) do
				control:SetParent(WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool.parent)
			end
			if ZO_WorldMapFiltersImperialPvPComboBox1 then
				local valid,point,control,relPoint,x,y=ZO_WorldMapFiltersImperialPvPComboBox1:GetAnchor(0)
				if control==WORLD_MAP_FILTERS.imperialPvPPanel.control then
					ZO_WorldMapFiltersImperialPvPComboBox1:SetAnchor(point,ZO_WorldMapFiltersImperialPvPContainerScrollChild,relPoint,x,y)
				end
			end
		end
		if ZO_WorldMapFiltersImperialPvPContainer then ZO_WorldMapFiltersImperialPvPContainer:SetAnchorFill() end
	end
	--]]
end

local function _getFormattedMapPlayerPosition()
    local x, y = GetMapPlayerPosition('player')
	return string.format('%.3f,%.3f', x, y):gsub('0%.', '.')
end

local LOC = '%s={{%s,%s}},'
local LOC1 = '{%s,%s},'
local LOC2 = '%s={%s},'

function addon:AddSlashCommands()
    -- TODO: check commands
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
	end

	local function onCheckboxChange(checkbox, checked)
		local type = self.checkboxToType[checkbox]
		-- df('MapPins checkbox type %d changed to %s', type, tostring(checked))
		self.sv[type] = checked
		self:UpdatePins(type)
	end

	local panels = {
		['pvePanel'] = PinsNirn,
		['pvpPanel'] = PinsAva,
		['imperialPvPPanel'] = PinsImperial,
	}

	for panelName, pinsData in pairs(panels) do
		for i in pairs(pinsData) do
			local label = self:GetCheckboxTypeLabel(i)
			df('Creating checkbox for id %d type, label: %s', i, label)
			AddCheckBox(WORLD_MAP_FILTERS[panelName], i, label, onCheckboxChange)
		end
	end
end

function addon:GetCheckboxTypeLabel(type)  -- TODO: actual names, translated
	-- return ('Text %d'):format(type)
	return GetString(PinTypes[type].name)
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

function addon:SomeRefresh(panel)  -- TODO: rename
	-- local panel = WORLD_MAP_FILTERS[panelName]

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

		if not control:IsHidden() then
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

function addon:SetCheckboxTypeHidden(type, hidden)
	for checkbox, type_ in pairs(self.checkboxToType) do
		if type == type_ then
			checkbox:SetHidden(hidden)
		end
	end
end

function addon:UpdatePins(type)
	self:RemovePins(type)

	-- TODO: decide how to implement feature to hide checkboxes
	-- TODO: not perfect because it takes more than accectable, can split getPins into 2 methods \
	-- TODO: and even cache results for slow queries
	local pins = PinTypes[type].getPins(self)
	self:SetCheckboxTypeHidden(type, not pins)

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
	if not desc then df('Type %d does not exist yet', pinType) return end  -- TODO: temporary
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
end

function addon:OnMapChanged()
	local newMapId = GetCurrentMapId()
	df('loaded mapId %s, new mapId %s', tostring(self.loadedMapId), tostring(newMapId))
	if newMapId == self.loadedMapId then return end

	self:UpdateAllPins()
	self.loadedMapId = newMapId

	self:SomeRefresh(WORLD_MAP_FILTERS.currentPanel)
end

function addon:UpdateAllPins()
	for pinType = 1, self.filterCount do
		self:UpdatePins(pinType)
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
