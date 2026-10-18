-- MapPins_Localization = MapPins_Localization or {}
-- MapPins_Localization["en"] = {
-- 		--Water
-- 		Lake="Lake",Foul="Foul",River="River",Salt="Salt",Oily="Oily",Mystic="Mystic",Running="Running",
-- 		--Portals
-- 		,Celestial_Rifts="Celestial rifts",Dark_Fissures="Dark fissures",Oblivion_Portals="Oblivion portals",Shadow_Fissures="Shadow fissures",Lava_Lashers="Lava lashers",Soul_Reaper="Soul Reaper",
-- 		--Filters
-- 		Antiquity_Leads="Antiquity leads",
		-- ,IC_Bosses="Bosses",IC_Respawns="Respawns",
-- 		Cunning_Scamp="Cunning Scamp",Trove_Scamp="Trove Scamp",
-- 		Orsinium_world_event="Random encounters",
-- 		Summerset_world_event="Random encounters",
-- 		Random_Encounters="Random encounters",

-- 		--DLC	
-- 		}

local CSI = ZO_CreateStringId

CSI('MAP_PINS_SI_DELVE_BOSSES', 'Delve bosses')
CSI('MAP_PINS_SI_DELVE_BOSSES_DONE', 'Delve bosses (done)')
CSI('MAP_PINS_SI_SKYSHARDS', 'Skyshards')
CSI('MAP_PINS_SI_SKYSHARDS_DONE', 'Skyshards (done)')
CSI('MAP_PINS_SI_LOREBOOKS', 'Lore books')
CSI('MAP_PINS_SI_LOREBOOKS_DONE', 'Lore books (done)')
CSI('MAP_PINS_SI_TREASURE_MAPS', 'Treasure maps')
CSI('MAP_PINS_SI_TREASURE_CHESTS', 'Treasure chests')
CSI('MAP_PINS_SI_UNKNOWN_POI', 'Unknown POI')
CSI('MAP_PINS_SI_UNDAUNTED', 'Undaunted')
CSI('MAP_PINS_SI_WORLD_ACHIEVEMENTS', 'World achievements')
CSI('MAP_PINS_SI_ORSINIUM', 'Orsinium')
CSI('MAP_PINS_SI_THIEVES_GUILD', 'Thieves guild')
CSI('MAP_PINS_SI_MORROWIND', 'Morrowind')
CSI('MAP_PINS_SI_SUMMERSET', 'Summerset')
CSI('MAP_PINS_SI_TIME_RIFTS', 'Time Rifts')
CSI('MAP_PINS_SI_SHRINES', 'Shrines')
CSI('MAP_PINS_SI_FISHING_NODES', 'Fishing nodes')
CSI('MAP_PINS_SI_CLOCKWORK_CITY', 'Clockwork City')
CSI('MAP_PINS_SI_MURKMIRE', 'Murkmire')
CSI('MAP_PINS_SI_ELSWEYR', 'Elsweyr')
CSI('MAP_PINS_SI_VOLENDRUNG', 'Volendrung')
CSI('MAP_PINS_SI_MARKARTH', 'Markarth')
CSI('MAP_PINS_SI_GREYMOOR', 'Greymoor')
CSI('MAP_PINS_SI_ANTIQUITIES', 'Antiquities')
CSI('MAP_PINS_SI_BLACKWOOD', 'Blackwood')
CSI('MAP_PINS_SI_IMPERIAL_CITY', 'Imperial City')
CSI('MAP_PINS_SI_PORTALS', 'Portals')
CSI('MAP_PINS_SI_HIGH_ISLE', 'High Isle')
CSI('MAP_PINS_SI_FIRESONG', 'Firesong')
CSI('MAP_PINS_SI_NECROM', 'Necrom')
CSI('MAP_PINS_SI_GOLD_ROAD', 'Gold Road')
CSI('MAP_PINS_SI_SEASONS_OF_THE_WORM_CULT', 'Seasons of the Worm Cult')
CSI('MAP_PINS_SI_DYNAMIC_ENCOUNTERS', 'Dynamic Encounters')


-- TODO: reuse existing strings as much as possible
