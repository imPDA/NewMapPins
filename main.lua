local ADDON_NAME = 'NewMapPins'
local ADDON_VERSION = 'X'
local EVENT_NAMESPACE = ADDON_NAME..'_EVENT_NAMESPACE'

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


----[[
-- TODO: currently only "name" part is used 
local PinTypes = {
	[1]={name='pinType_Delve_bosses',done=false,id={},pin={},maxDistance=0.05,level=30,texture='/esoui/art/icons/poi/poi_groupboss_incomplete.dds',k=1.25},--tint=ZO_ColorDef:New(1,1,1,1),
	[2]={name='pinType_Delve_bosses_done',done=true,id={},pin={},maxDistance=0.05,level=30,texture='/esoui/art/icons/poi/poi_groupboss_complete.dds',k=1.25},
	[3]={name='pinType_Skyshards',done=false,id={},pin={},maxDistance=0.05,level=100,texture='/'..ADDON_NAME..'/textures/Skyshard_1.dds',k=1.40},
	[4]={name='pinType_Skyshards_done',done=true,id={},pin={},maxDistance=0.05,level=100,texture='/esoui/art/tutorial/gamepad/achievement_categoryicon_skyshards.dds',k=1.38},
	[5]={name='pinType_Lore_books',done=false,id={},pin={},maxDistance=0.05,level=100,texture='/'..ADDON_NAME..'/textures/Lorebook_1.dds',k=1,tint=ZO_ColorDef:New(.6,.6,1,.8)},
--	[5]={name='pinType_Lore_books_done',done=true,id={},pin={},maxDistance=0.05,level=30,texture='/'..AddonName..'/textures/Lorebook_2.dds',k=1,tint=ZO_ColorDef:New(.6,.6,1,.8)},
	[6]={name='pinType_Treasure_Maps',done=false,id={},pin={},maxDistance=0.05,level=101,texture=function(self) return self.m_PinTag.texture end,def_texture='/'..ADDON_NAME..'/textures/Treasure_1.dds',k=1.4},
	[7]={name='pinType_Treasure_Chests',done=false,id={},pin={},maxDistance=0.05,level=100,texture='/'..ADDON_NAME..'/textures/Chest_1.dds',k=1.1,tint=ZO_ColorDef:New(1,1,1,.8)},	--,tint=ZO_ColorDef:New(.8,.8,.5,.9)
	[8]={name='pinType_Unknown_POI',done=false,id={},pin={},maxDistance=0.05,level=10,texture=function(self) return self.m_PinTag.texture end,def_texture='/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds',size=40,tint=ZO_ColorDef:New(.7,.7,.7,.6)},
	[9]={section=true,name='Undaunted',id={},pin={},texture='/esoui/art/icons/crafting_beer_003.dds',
		[704]={name='pinType_This_One\'s_On_Me',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/crafting_beer_003.dds',k=1},
		[1082]={name='pinType_Undaunted_Rescuer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/ability_warrior_007.dds',k=1}
		},
	[10]={section=true,name='World_achievements',id={},pin={},texture='/esoui/art/progression/progression_indexicon_world_up.dds',
		[872]={name='pinType_I_like_M\'aiq',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_066.dds',k=1},
		[873]={name='pinType_Lightbringer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1.25},
		[716]={name='pinType_Peacemaker',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/ability_healer_017.dds',k=1},
		},
	[11]={section=true,name='Orsinium',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds',	--'/esoui/art/icons/store_orsiniumdlc_collectable.dds',
		[1247]={name='pinType_One_Last_Brawl',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_010.dds',k=1},
		[1316]={name='pinType_Orsinium_Patron',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_024.dds',k=1,},
		[1250]={name='pinType_Wrothgar_Relic_Hunter',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_wrothgar_008.dds',k=1},
		},
	[12]={section=true,name='Thieves_guild',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds',	--'/esoui/art/icons/store_thievesguilddlc_collectable.dds',
		[1383]={name='pinType_A_Cutpurse_Above',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_thievesguild_044.dds',k=1},
		[1349]={name='pinType_Breaking_And_Entering',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/perks_theives_guild_004.dds',k=1},
		},
	[13]={section=true,name='Morrowind',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds',	--'/esoui/art/icons/store_morrowind_collectable.dds',
		[1824]={name='pinType_Vivec_Lessons',done=false,ach=true,maxDistance=0.05,level=100,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1,tint=ZO_ColorDef:New(.8,.8,.8,.8)},
		[1712]={name='pinType_Ancestral_Tombs',done=false,ach=true,maxDistance=0.05,level=30,texture='/esoui/art/icons/poi/poi_crypt_incomplete.dds',k=1},
		[1827]={name='pinType_Pilgrim\'s_Path',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_vvardenfel_032.dds',k=1},
		},
	[14]={section=true,name='Summerset',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_summerset_up.dds',	--'/esoui/art/icons/store_summerset_collectable.dds',
		[2099]={name='pinType_Summerset_Relics',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/quest_strosmkai_open_treasure_chest.dds',k=1},
		[2211]={name='pinType_Message_in_Bottle',done=false,ach=true,maxDistance=0.05,level=100,texture='/esoui/art/icons/crafting_stoneware_bottle_003.dds',k=1},
		[2171]={name='pinType_Summerset_world_event',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1.25,def_texture='/esoui/art/icons/achievement_su_rds_01.dds'},
		},
	[15]={name='pinType_Time_Rifts',done=false,id={},pin={},maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Treasure_1-2.dds',k=1.8},
	[16]={name='pinType_Shrines',done=false,id={},pin={},maxDistance=0.05,level=101,texture='/esoui/art/icons/poi/poi_daedricruin_incomplete.dds',k=1.25},
	[17]={name='pinType_Fishing_Nodes',done=false,id={},pin={},maxDistance=0.05,level=101,texture='/esoui/art/icons/achievements_indexicon_fishing_up.dds',k=1.25},
-- 	[17]={name='pinType_Fishing_Nodes_done',done=true,id={},pin={},maxDistance=0.05,level=101,texture='/esoui/art/icons/achievements_indexicon_fishing_up.dds',k=1.25},
	[18]={section=true,name='pinType_Clockwork_City',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_cwc_up.dds',	--'/art/fx/texture/clockworksigil.dds',
		[1958]={name='pinType_Precursor_Maker',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds',k=1,def_texture='/esoui/art/icons/achievement_update16_001.dds'},
		},
	[19]={section=true,name='pinType_Murkmire',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds',	--'/esoui/art/icons/store_murkmiredlc_collectable.dds',
		[2320]={name='pinType_Chronic_Chronogler',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/inventory/gamepad/gp_inventory_icon_craftbag_stylematerial.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_museum.dds'},
		[2341]={name='pinType_Poems_of_Nothing',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1},
		[2355]={name='pinType_Achievement_quests',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/tutorial/gamepad/gp_icon_new.dds',k=1},	--esoui/art/floatingmarkers/quest_icon.dds
		[2330]={name='pinType_Surreptitiously_Shadowed',done=false,ach=true,maxDistance=0.05,level=111,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_shadowscale_wisdom.dds'},
		[2358]={name='pinType_Swamp_Rescuer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/death/death_soulreservoir_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_murkmire_rescue_villagers.dds'},
		[2357]={name='pinType_Vine-Tongue_Traveler',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Lorebook_1-2.dds',k=1,def_texture='/esoui/art/icons/mh_hedgeguardian_strang.dds'},
		},
	[20]={section=true,name='pinType_Elsweyr',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds',
		[2463]={name='pinType_Mural_Mender',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_els_museum_mural.dds',k=1},
		[2534]={name='pinType_Pieces_of_History',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_museum_tapestry.dds',k=1},
		[2619]={name='pinType_Theater_Critic',done=false,ach=true,maxDistance=0.05,level=101,texture='/'..ADDON_NAME..'/textures/Scroll_1.dds',k=1,def_texture='/esoui/art/icons/quest_book_003.dds'},
		[2621]={name='pinType_Legacy_Slayer',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_familyofpirates.dds',k=1},
		[2620]={name='pinType_Grappling_Bow_Pathfinder',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u24_grappletreasures.dds',k=1},
		},
	[21]={name='pinType_Volendrung',id={},pin={},maxDistance=0.05,level=30,texture='/esoui/art/miscellaneous/help_icon.dds',k=1.25},
	[22]={section=true,name='pinType_Markarth',id={},pin={},texture='/esoui/art/treeicons/tutorial_indexicon_markarth_up.dds',
		[2927]={name='pinType_Red_Eagle\'s_Flight',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u28_jump_flavor.dds',k=1},
		[2851]={name='pinType_Offerings_to_the_Old_Spirits',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u28_reach_flavor.dds',k=1},
		[2964]={name='pinType_A_friend_in_deed',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/ability_u26_vampire_infection_stage4.dds',k=1},
		},
	[23]={section=true,name='pinType_Greymoor',id={},pin={},texture='/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds',
		[2669]={name='pinType_Instrumental_Triumph',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_u26_skyrim_sounds_of_success.dds'},
		[2759]={name='Mining_Sample_Collector',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/poi/poi_mine_compete.dds',k=1,def_texture='/esoui/art/icons/achievement_u26_skyrim_minerquest.dds'},
		},
	[24]={section=true,name='pinType_Antiquities',id={},pin={},texture='/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds', k=1.40,
		[70]={name='pinType_Antiquity_Leads',done=false,maxDistance=0.05,level=101,texture='/esoui/art/icons/servicetooltipicons/servicetooltipicon_antiquities.dds', k=1.40},
		},-- this doesn't need to be 70 but it's used to display hidden Leads
	[25]={section=true,name='pinType_Blackwood',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_blackwood_up.dds',
		[3083]={name='pinType_Lost_in_Wilds',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor4.dds',k=1},
		[3081]={name='pinType_Bane_of_Sul-Xan',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor2.dds',k=1},
		[3082]={name='pinType_Most_Admired',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_rds.dds',k=1},
		[74]={name='pinType_Random_Encounters',done=false,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1},
		[3080]={name='pinType_Leyawiin_Master_Burglar',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u30_flavor1.dds',k=1},
		},
	[26]={section=true,name='pinType_Imperial_City',id={},pin={},texture='/esoui/art/compass/ava_imperialcity_neutral.dds',
		[76]={name='pinType_IC_Bosses',done=false,maxDistance=0.05,level=101,texture='/esoui/art/icons/poi/poi_groupboss_incomplete.dds',k=1.25},
		[77]={name='pinType_IC_Respawns',done=false,maxDistance=0.05,level=101,texture='/esoui/art/death/death_soulreservoir_icon.dds',k=1},
		[1270]={name='pinType_Cunning_Scamp',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_ic_telvarscamp.dds',k=1},
		[1272]={name='pinType_Trove_Scamp',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_ic_treasurescamp.dds',k=1},
		},
	[27]={name='pinType_Portals',id={},pin={},maxDistance=0.05,level=30,texture='/esoui/art/icons/poi/poi_portal_complete.dds',k=1.26},
	[28]={section=true,name='pinType_High_Isle',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_highisle_up.dds',
		[3298]={name='pinType_Seeker_of_the_Green',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u34_flavor4_druid.dds',k=1},
		[3424]={name='pinType_No_Regrets',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/tutorial/gamepad/gp_icon_new.dds',k=1,def_texture='/esoui/art/icons/u34_flavor5_drunkedleap.dds'},
		[3299]={name='pinType_Inventor_of_Adventure',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/miscellaneous/help_icon.dds',k=1,def_texture='/esoui/art/icons/achievement_u34_rds.dds'},
		[3295]={name='pinType_Gonfalon_Bays_Master_Burglar',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/servicetooltipicons/servicetooltipicon_bagvendor.dds',k=1,def_texture='/esoui/art/icons/achievement_u34_flavor1_lockbox.dds'},
		},
	[29]={section=true,name='pinType_Firesong',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_firesong_up.dds',
		[3502]={name='pinType_The_Best_of_Friends',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor1.dds',k=1},
		[3503]={name='pinType_Ferret_the_Hunters',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor2.dds',k=1},
		[3504]={name='pinType_Firestarter',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor3.dds',k=1},
		[3505]={name='pinType_A_Joyous_Dance',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u36_zone_flavor4.dds',k=1},
		},
	[30]={section=true,name='pinType_Necrom',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_necrom_up.dds',
		[3678]={name='pinType_Syzygy',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor4.dds',k=1},
		[3677]={name='pinType_Tomes_of_Uknown_Color',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor3.dds',k=1},
		[3675]={name='pinType_Grave_Discoveries',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u38_flavor1.dds',k=1},
		[3749]={name='pinType_Slaughtered_by_Tentacles',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/u38_slaughtered_apocrypha.dds',k=1},
		},
	[31]={section=true,name='pinType_Gold_Road',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_goldroad_up.dds',
		[3968]={name='pinType_Gold_Road_Partaker',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u42_zone_flavor1.dds',k=1},
		[4040]={name='pinType_Wine_and_Warriors',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u42_rds.dds',k=1},
		[4041]={name='pinType_Minotaur_Tracker',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/u42_wandering_world_boss.dds',k=1},
		},
	[32]={section=true,name='pinType_Seasons_of_the_Worm_Cult',id={},pin={},texture='/esoui/art/treeicons/tutorial_idexicon_goldroad_up.dds',
		[4432]={name='pinType_Wanderers_of_Western_Solstice',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u46_zone_flavor1.dds',k=1},
		[4433]={name='pinType_So_Clean_in_Sunport',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u46_zone_flavor2.dds',k=1},
		[4434]={name='pinType_Solstice_Climbing_Club',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u46_zone_flavor3.dds',k=1},
		[4435]={name='pinType_Sanguine_s_Delights',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/achievement_u46_zone_flavor4.dds',k=1},
		[4455]={name='pinType_Soul Shriven_on_Solstice',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/u48_zone_flavor1.dds',k=1},
		[4456]={name='pinType_We_Were_Undaunted',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/u48_zone_flavor2.dds',k=1},
		[4457]={name='pinType_The_Legend_of_Atlorn_the_Lost',done=false,ach=true,maxDistance=0.05,level=101,texture='/esoui/art/icons/u48_zone_flavor3.dds',k=1},
		},
	[33]={name='pinType_Dynamic_Encounters',id={},pin={},maxDistance=0.05,level=100,texture='/esoui/art/icons/mapkey/mapkey_dynamic_world_event.dds',k=1.2},
}
--]]
local PinsNirn = {[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true,[20]=true,[22]=true,[23]=true,[24]=true,[25]=true,[27]=true,[28]=true,[29]=true,[30]=true,[31]=true,[32]=true,[33]=true}
local PinsAva = {[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[17]=true,[21]=true}
local PinsImperial = {[3]=true,[5]=true,[7]=true,[8]=true,[17]=true,[26]=true}
--]]


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

	-- self:MakeFiltersScroll()
	self:AddFilterControls()

	self.canvases = {}  -- TODO: temporary

	self:RegisterEvents()
end


function addon:MakeFiltersScroll()
	if not WORLD_MAP_FILTERS then return end

	local panels = {'pvePanel', 'pvpPanel', 'imperialPvPPanel'}

	local function _makePanelScroll(panel)
		if not panel then return end

		local containerScrollChild = ZO_WorldMapFiltersPvEContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvEContainer", ZO_WorldMapFiltersPvE, "ZO_ScrollContainer"):GetNamedChild("ScrollChild")

		if panel.checkBoxPool then
			panel.checkBoxPool.parent = containerScrollChild
			for i, control in pairs(panel.checkBoxPool.m_Active) do
				control:SetParent(panel.checkBoxPool.parent)
			end

			if ZO_WorldMapFiltersPvECheckBox1 then
				local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersPvECheckBox1:GetAnchor(0)
				if control == panel.control then
					ZO_WorldMapFiltersPvECheckBox1:SetAnchor(point,ZO_WorldMapFiltersPvEContainerScrollChild, relPoint, x, y)
				end
			end
		end

		if panel.comboBoxPool then
			panel.comboBoxPool.parent = containerScrollChild
			for i, control in pairs(panel.comboBoxPool.m_Active) do
				control:SetParent(panel.comboBoxPool.parent)
			end
			if ZO_WorldMapFiltersPvEComboBox1 then
				local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersPvEComboBox1:GetAnchor(0)
				if control == panel.control then
					ZO_WorldMapFiltersPvEComboBox1:SetAnchor(point, ZO_WorldMapFiltersPvEContainerScrollChild, relPoint, x, y)
				end
			end
		end
	end

	for _, panelName in pairs(panels) do
		local panel = WORLD_MAP_FILTERS[panelName]
		_makePanelScroll(panel)
	end

	--[[
	if WORLD_MAP_FILTERS.pvePanel then
		if WORLD_MAP_FILTERS.pvePanel.checkBoxPool then
			WORLD_MAP_FILTERS.pvePanel.checkBoxPool.parent=ZO_WorldMapFiltersPvEContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvEContainer",ZO_WorldMapFiltersPvE,"ZO_ScrollContainer"):GetNamedChild("ScrollChild")
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
			WORLD_MAP_FILTERS.pvePanel.comboBoxPool.parent=ZO_WorldMapFiltersPvEContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvEContainer",ZO_WorldMapFiltersPvE,"ZO_ScrollContainer"):GetNamedChild("ScrollChild")
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
			WORLD_MAP_FILTERS.pvpPanel.checkBoxPool.parent=ZO_WorldMapFiltersPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvPContainer",ZO_WorldMapFiltersPvP,"ZO_ScrollContainer"):GetNamedChild("ScrollChild")
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
			WORLD_MAP_FILTERS.pvpPanel.comboBoxPool.parent=ZO_WorldMapFiltersPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvPContainer",ZO_WorldMapFiltersPvP,"ZO_ScrollContainer"):GetNamedChild("ScrollChild")
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
			WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool.parent=ZO_WorldMapFiltersImperialPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersImperialPvPContainer",ZO_WorldMapFiltersImperialPvP,"ZO_ScrollContainer"):GetNamedChild("ScrollChild")
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
			WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool.parent=ZO_WorldMapFiltersImperialPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersImperialPvPContainer",ZO_WorldMapFiltersImperialPvP,"ZO_ScrollContainer"):GetNamedChild("ScrollChild")
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

local function _getFileName()
    return GetMapTileTexture():match('[^\\/]+$'):lower():gsub('%.dds$', ''):gsub('_[0-9]+$', '')
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
		if not panel.checkBoxPool then
        	panel.checkBoxPool = ZO_ControlPool:New('ZO_CheckButton', panel.control, 'CheckBox')
    	end

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
			AddCheckBox(WORLD_MAP_FILTERS[panelName], i, label, onCheckboxChange)
		end
	end
end

function addon:GetCheckboxTypeLabel(type)  -- TODO: actual names, translated
	-- return ('Text %d'):format(type)
	return PinTypes[type].name
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

-- Setup the events that need fire
function addon:RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
		self:UpdateAllPins()
	end)

	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() self:OnMapChanged() end)
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", function() self:OnMapChanged() end)
end

function addon:UpdatePins(type)
	self:RemovePins(type)

	if self.sv[type] then
		self:AddPins(type)
	end
end

function addon:RemovePins(type)
	local canvas = self.canvases[type]
	if canvas then
		canvas:Clear()
	end
end

local TYPE_TO_TABLE = {
	[1] = 'Bosses',
	[2] = 'Bosses',
	[3] = 'SkyShards',
	[4] = 'SkyShards',
	[5] = 'Lorebooks',
}

function addon:AddPins(type)
	self:InitializeCanvas(type)

	local canvas = self.canvases[type]
	local map = _getFileName()

	df('adding pins to map with file name %s', map)

	if not TYPE_TO_TABLE[type] then return end  -- TODO: remove afterwards, temporary plug
	local tbl = TYPE_TO_TABLE[type]

	local pinData = MP[tbl][map]

	if not pinData then return end
	for i = 1, #pinData do
		local pinDatum = pinData[i]
		canvas:Add(pinDatum[1], pinDatum[2], 0, 0, 32, 32, nil, {type, i, map})
	end
end

function addon:InitializeCanvas(pinType)
	if self.canvases[pinType] then return end

	local function _onMouseEnter(tag, surface, composite)
		df('mouse over type %d', pinType)
		composite:AnimateScale(surface, 1, 1.3, 150)
	end

	local function _onMouseExit(tag, surface, composite)
		df('mouse exit type %d', pinType)
		composite:AnimateScale(surface, 1.3, 1, 150)
	end

	local function _getTexture(type_)
		if PinTypes[type_].texture and type(PinTypes[type_].texture) == 'string' then
			return PinTypes[type_].texture
		end

		if PinTypes[type_].def_texture then
			return PinTypes[type_].def_texture
		end

		return  '/esoui/art/icons/icon_missing.dds'
	end

	self.canvases[pinType] = LibSurfaceTools.Tools.FlexRect(ZO_WorldMapContainer, nil, _onMouseEnter, _onMouseExit)
		:SetTexture(_getTexture(pinType))
end

function addon:OnMapChanged()
	local newMapId = GetCurrentMapId()
	df('loaded mapId %s, new mapId %s', tostring(self.loadedMapId), tostring(newMapId))
	if newMapId == self.loadedMapId then return end

	self:UpdateAllPins()
	self.loadedMapId = newMapId
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
