--MapPins - The Elder Scrolls Online addon by Hoft, active support of art1ink and many players that helps with a new pins and localizations.
--Adds additional pins on your ingame map. Was made to work the fast as posible and with minimal memory usage.
--Supports CustomCompassPins, that can be installed separately.
--Apologize for the "one file" format. This was made to use all data and functions as local (stupid views of the author to safety and memory usage).
--Slash commands: /pinsize 16-40 - sets a size of the pins. /loc - receives current player map and coords. /loc2 - receives player waypoint coords.
--Full instruction how you can help to add new pins is here (ru, en version): https://forum.bandits-clan.ru/topic/75303-map-pins-collecting-data/?tab=comments#comment-1198876
--Thanks for help to: GaelicCat, Gamer1986PAN, Runs, Gandalf, Kibert, Bence, Daniel, Kelly, Danzio, demidaddy, Teva, Akotar, Zym, SuppeFuss165, remosito, Telmatoscopus and other players.

local AddonName="MapPins"
local Localization=MapPins_Localization or {}
local lang=GetCVar("language.2") if not Localization[lang] then lang="en" end
local function Loc(string)
	return Localization[lang][string] or Localization[lang]["en"] or string
end

local MundusDescription = {
	[13940] = "Increases Weapon Damage",
	[13943] = "Increases Maximum Magicka",
	[13974] = "Increases Stamina recovery",
	[13975] = "Increases Critical Strike chance",
	[13976] = "Increases Physical and Spell Resistance",
	[13977] = "Increases run speed by 5% & increases Health recovery",
	[13978] = "Increases Maximum Health",
	[13979] = "Increases Spell Damage",
	[13980] = "Increases healing effectiveness",
	[13981] = "Increases Physical and Spell Penetration",
	[13982] = "Increases Magicka recovery",
	[13984] = "Increases Critical Strike damage",
	[13985] = "Increases Maximum Stamina",
}


local PoiData={}


local TimeBreach={
summerset_base={{.587,.543,2},{.226,.599,2},{.292,.373,2},{.621,.322,2},{.561,.432,2},{.676,.62,2},{.479,.743,2},{.339,.424,2},{.738,.713,2}},
glenumbra_base={{.735,.199,2},{.336,.509,2},{.436,.807,2}},
stormhaven_base={{.516,.343,2},{.634,.361,2},{.13,.533,2}},	--{.84,.45,7}},
alikr_base={{.436,.472,2},{.717,.579,2},{.249,.632,2}},	--{.61,.467,4}},
eastmarch_base={{.5,.53,3},{.332,.482,3},{.327,.687,3}},
therift_base={{.737,.367,3},{.078,.259,3},{.318,.23,3}},
stonefalls_base={{.41,.523,3},{.52,.636,3},{.777,.504,3}},	--{.541,.628,7}},
--bangkorai_base={{.37,.456,4}},
grahtwood_base={{.291,.506,5},{.682,.463,5},{.23,.219,5}},
greenshade_base={{.127,.505,5},{.274,.1,5},{.584,.78,5}},	--{.537,.81,7}},
malabaltor_base={{.492,.346,5},{.647,.727,5},{.81,.242,5}},
shadowfen_base={{.748,.724,6},{.291,.777,6},{.552,.361,6},{.256,.236,6}},	--{.535,.524,4}},
deshaan_base={{.338,.572,6},{.1,.58,6},{.594,.44,6},{.78,.396,6},{.79,.57,6}},	--{.734,.616,4}},
rivenspire_base={{.157,.645,8},{.658,.626,8},{.823,.311,8},{.713,.471,8},{.61,.417,8},{.81,.117,8},{.216,.686,8},{.5,.677,8},{.201,.541,8}},
craglorn_base={{.177,.222,9},{.394,.383,9},{.242,.579,9},{.77,.687,9},{.654,.604,9},{.383,.7,9}},	--{.639,.566,7}}
}
local PinManager,CompassPinManager
local UpdatingMapPin,UpdatingCompassPin,PinId={},{},{}
local ChestsRange,ChestsLooted,LastZone,LastAchivement,PsijicSkillLine=.08,0,0,0,4
local ChronoglerTablet={[6771]=1,[141719]=2,[141720]=3,[141721]=4,[141722]=5,[141723]=6,[141724]=7,[141725]=8,[141726]=9,[141728]=11,[141727]=10,[141729]=12}
local AncestralTombRubbing={[114287]=1,[114288]=2,[114289]=3,[114298]=4,[114299]=5,[114300]=6,[114301]=7,[114302]=8,[114303]=9,[114304]=10,[114305]=11,[114306]=12,[114307]=13,[114308]=14,[114309]=15,[114310]=16,[114311]=17,[114312]=18,[114313]=19,[114314]=20,[114315]=21,[114316]=22,[114317]=23,[114318]=24,[114319]=25,[114320]=26,[114321]=27,[114322]=28,[114323]=29,[114324]=30}
local WrothgarRelics={[64578]=1,[64579]=2,[64580]=3,[64581]=4,[64582]=5,[64583]=6,[64584]=7,[64586]=8,[64587]=9,[64585]=10,[64589]=13,[64590]=14,[64591]=15,[64592]=16,[64594]=17,[64588]=18,[64593]=19,[64595]=20}
local RelicsOfSummerset={[133605]=1,[133606]=2,[133607]=3,[133608]=4,[133609]=5,[133610]=6,[133611]=7,[133612]=8,[133613]=9,[133614]=10,[133615]=11,[133616]=12,[133617]=13,[133618]=14,[133619]=15,[133620]=16,[133621]=17,[133622]=18,[133623]=19,[133624]=20}
local MuralMenderFragments={
[147519]=2,--Riverhold Fragment
[147520]=3,
[147521]=4,--Khenarthia
[147522]=5,--Dune
[147523]=6,--Verkarth
[147524]=7,--Merivale
[147525]=8,
[147526]=9,--Alabaster
[147527]=10,--Senchal
[147528]=11,
[147529]=12,
[147530]=13,
[147531]=14,
[147532]=15,
[147533]=16,
}
local PiecesOfHistory={
[7070]=1,	--Nishozo
[151942]=2,	--Amaffi
[151943]=3,	--Oranu
[153466]=4,	--Magpie
[153467]=5,	--Bufasa
[153468]=6,	--Seleiz
[153469]=7,	--Hiijar
[153470]=8,	--Grastia
[153471]=9,	--Dancer
[153472]=10,--Farro
[153473]=11,--Kesta
[153474]=12,--Jarro
}
local IsChest={["Chest"]=true,["Truhe^f"]=true,["coffre^m"]=true,["Сундук"]=true,["宝箱"]=true}
local IsTimeBreach={["Time Breach"]=true,["Zeitriss^m"]=true,["Rupture temporelle^f"]=true,["Временная брешь"]=true,["時の裂け目"]=true}
local IsThievesTrove={["Thieves Trove"]=true,["Diebesgut^ns"]=true,["trésor des voleurs^m"]=true,["Воровской клад"]=true,["盗賊の宝"]=true}

local PsijicMap={[6551]=1,[6581]=2,[6584]=3,[6622]=4,[6598]=5,[6588]=6,[6620]=7,[6601]=8,[6604]=9,[6638]=10}

local Shrines={
therift_base={{.723,.252,1},{.789,.422,2}},
bangkorai_base={{.479,.429,1},{.648,.366,2}},
reapersmarch_base={{.619,.217,1},{.664,.205,2}},
}

local ShrineIcon={[1]="/esoui/art/icons/ability_vampire_007.dds",[2]="/esoui/art/icons/ability_werewolf_010.dds"}
local FishIcon={
	[1]="/esoui/art/icons/crafting_slaughterfish.dds",       -- Foul
	[2]="/esoui/art/icons/crafting_fishing_river_betty.dds", -- River
	[3]="/esoui/art/icons/crafting_fishing_merringar.dds",	 -- Salt
	[4]="/esoui/art/icons/crafting_fishing_perch.dds"		 -- Lake
}

local Volendrung={ava_whole={
--ALLIANCE_ALDMERI_DOMINION
{.483,.791,1},
{.641,.769,1},
{.408,.636,1},
{.34,.709,1},
{.531,.876,1},
{.525,.619,1},
{.304,.536,1},
--ALLIANCE_EBONHEART_PACT
{.752,.486,2},	--Pact is nearest
{.685,.532,2},
{.711,.143,2},
{.631,.302,2},
{.776,.278,2},
{.484,.546,2},
{.711,.393,2},
{.595,.382,2},
{.844,.166,2},
--ALLIANCE_DAGGERFALL_COVENANT
{.347,.24,3},
{.199,.372,3},
{.349,.164,3},
{.209,.224,3},
{.108,.231,3},
{.302,.351,3},
{.392,.361,3},
{.483,.22,3},	--Border of the Pact and Covenant
}}
local ImperialCity={--Provided by remosito
imperialcity_base={
[76]={--Bosses
{.658,.383,"Glorgoloch the Destroyer / King Khrogo"},--ARENA
{.682,.615,"Lady Malygda / Ysenda Resplendent"},--Arboretum
{.505,.833,"Immolator Charr / Mazaluhad"},--TEMPLE
{.206,.679,"Amoncrul"},--NOBLES
{.182,.634,"Baron Thirsk"},--NOBLES
{.236,.359,"Zoal the Ever-Wakeful / The Screeching Matron"},--ELVEN GARDENS
{.496,.295,"Nunatak / Volghass"}},--MEMORIAL
[77]={--Respawn
--ALLIANCE_ALDMERI_DOMINION
{.647,.313,1},--ARENA
{.847,.607,1},--Arboretum
{.637,.809,1},--TEMPLE
{.295,.538,1},--NOBLE
{.345,.363,1},--ELVEN GARDENS
{.565,.195,1},--MEMORIAL
--ALLIANCE_DAGGERFALL_COVENANT
{.734,.472,3},--ARENA
{.797,.718,3},--Arboretum
{.381,.785,3},--TEMPLE
{.275,.759,3},--NOBLE
{.314,.288,3},--ELVEN GARDENS
{.541,.298,3},--MEMORIAL
--ALLIANCE_EBONHEART_PACT
{.851,.452,2},--ARENA
{.863,.533,2},--Arboretum
{.55,.72,2},--TEMPLE
{.35,.712,2},--NOBLE
{.308,.455,2},--ELVEN GARDENS
{.409,.234,2}},--MEMORIAL
}}
local AllianceColors={
[ALLIANCE_ALDMERI_DOMINION]={1,1,0,.8},
[ALLIANCE_EBONHEART_PACT]={1,.2,.2,.8},
[ALLIANCE_DAGGERFALL_COVENANT]={.2,.2,1,.8}
}
local PrecursorItems = {
[129900]=1,	--Left arm
[129901]=2,	--Right arm
[129902]=3,	--Left leg
[129903]=4,	--Right leg
[129904]=5,	--Pelvis
[129905]=6,	--Chestpiece
[129906]=7,	--Spine
[129907]=8,	--Left hand
[129908]=9,	--Right hand
[129909]=10,--Dynamo
[129910]=11,--Calculus
[129911]=12,--Introspection
[129912]=13,--Reason
[129913]=14,--Staff
}
local PrecursorTooltip = {
	{v=1,desc="  Alik'r Desert: Yldzuun"},
	{v=4,desc="  Alik'r Desert: Santaki"},
	{v=6,desc="  Alik'r Desert: Aldunz"},
	{v=2,desc="  Bangkorai: Klathzgar"},
	{v=3,desc="  Rift: Avancheznel"},
	{v=7,desc="  Eastmarch: Mzulft"},
	{v=8,desc="  Stonefalls: Inner Sea Armature"},
	{v=9,desc="  Deshaan: Mzithumz"},
	{v=5,desc="  Deshaan: Lower Bthanual"},
	{v=14,desc="Deshaan: Bthanual"},
	{v=10,desc="Stros M'Kai: Bthzark"},
	{v=11,desc="Brass Bortress: Mechanical Fundament"},
	{v=12,desc="Clockwork Base"},
	{v=13,desc="Brass Bortress: Machine District"}
}

local Instruments={
[156666]=2,	--Lute of Blue Longing
[156797]=3,	--Chime of the Endless
[156798]=4,	--Tenderclaw
[156799]=5,	--Shadow of Rahjin
[156800]=6,	--Lilytongue
[156801]=7, --Sky talker
[156802]=8,	--Long Fire
[156803]=9,	--Hightmourn Dizi
[156804]=10,	--Jarlsbane
[156805]=11,	--King Thunder
[156806]=12,	--Jahar Fuso'ja
[156807]=13,	--Pan Flute of Morachellis
[156808]=14,	--Reman War Drum
[160510]=15,	--Ateian Fife
[160511]=16,	--Shiek-of-Silk
[160512]=17,	--Kothringi Leviathan Bugle
[160514]=18,	--Lodestone
[160515]=19,	--Dozzen Talharpa
}
local InstrumentsTooltip={
	{v=2,desc="  Nchuthnkarst: Lute of Blue Longing"},
	{v=3,desc="  Blackreach: Chime of the Endless"},
	{v=4,desc="  Shadowgreen: Tenderclaw "},
	{v=5,desc="  Dragonhome: Shadow of Rahjin"},
	{v=6,desc="  Chill Wind Depths: Lilytongue"},
	{v=7,desc="  Labyrinthian: Sky talker"},
	{v=8,desc="  Western Skryim: Long Fire"},
	{v=9,desc="  Scraps: Hightmourn Dizi"},
	{v=10,desc="Western Skryim: Jarlsbane"},
	{v=11,desc="Western Skryim: King Thunder"},
	{v=12,desc="Western Skryim: Jahar Fuso'ja"},
	{v=13,desc="Blackreach: Pan Flute of Morachellis"},
	{v=14,desc="Blackreach: Reman War Drum"},
	{v=15,desc="Blackreach: Ateian Fife"},
	{v=16,desc="Western Skryim: Shiek-of-Silk"},
	{v=17,desc="Western Skryim: Kothringi Leviathan Bugle"},
	{v=18,desc="Western Skryim: Lodestone"},
	{v=19,desc="Western Skryim: Dozzen Talharpa"},
	}
local MiningSampleCollector={[7373]=1,[7375]=2,[7377]=3,[7385]=4,[7379]=5}
local MiningSampleTooltip={
	{v=1,desc="Kelbarn's Mining Samples"},
	{v=2,desc="Inguya's Mining Samples"},
	{v=3,desc="Reeh-La's Mining Samples"},
	{v=4,desc="Adanzda's Mining Samples"},
	{v=5,desc="Ghamborz's Mining Samples"},
}
local TrophyTable={--AcheventID = Trophy Table
[1712]=AncestralTombRubbing,
[1250]=WrothgarRelics,
[2099]=RelicsOfSummerset,
[1958]=PrecursorItems,
[2320]=ChronoglerTablet,
[2463]=MuralMenderFragments,
[2534]=PiecesOfHistory,
[2669]=Instruments,
[2759]=MiningSampleCollector,
}
local PortalsNames={
[1]=Loc("Oblivion_Portals"),
[2]=Loc("Dark_Fissures"),
[3]=Loc("Celestial_Rifts"),
[4]=Loc("Shadow_Fissures"),
[5]=Loc("Lava_Lashers"),
[6]=Loc("Soul_Reaper")
}



--	/script local name,_,_,icon=GetAchievementInfo(3295) CHAT_ROUTER:AddSystemMessage(icon)
--	/script CHAT_ROUTER:AddSystemMessage(ZO_AchievementsContentsCategoriesScrollChildZO_IconHeader12Icon:GetTextureFileName())
--	/script CHAT_ROUTER:AddSystemMessage(GetCollectibleIcon(912))
--	/script d("|t26:26:/esoui/art/icons/achievement_u46_zone_flavor3.dds|t")

local function GetSetDescription(setData)
	if setData then
		local itemLink=("|H1:item:%d:370:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"):format(setData[1])
		local _, setName, numBonuses=GetItemLinkSetInfo(itemLink)
		local setBonuses=zo_strformat("|cEEEEEE<<1>> traits required|r\n", setData[2])
		local numRequired, Description
		for i=1, numBonuses do
			numRequired, Description=GetItemLinkSetBonusInfo(itemLink, false, i)
			Description=string.gsub(Description,"%d+ %w+ Health","|cFF2222%1|r")
			Description=string.gsub(Description,"%d+ %w+ Stamina","|c22FF22%1|r")
			Description=string.gsub(Description,"%d+ %w+ Magicka","|c5555EE%1|r")
			Description=string.gsub(Description,"%d+ Health %w+","|cFF2222%1|r")
			Description=string.gsub(Description,"%d+ Stamina %w+","|c22FF22%1|r")
			Description=string.gsub(Description,"%d+ Magicka %w+","|c5555EE%1|r")
			Description=string.gsub(Description,"%d+ Spell Damage","|c5555EE%1|r")
			Description=string.gsub(Description,"%d+ Weapon Damage","|cBBBBBB%1|r")
			Description=string.gsub(Description,"%d+ %w+ Critical","|cBB33BB%1|r")
			setBonuses=setBonuses..Description..(i<numBonuses and "\n" or "")
		end
		return zo_strformat("<<1>> set (<<2>> items)", setName, numRequired), setBonuses
	else
		return "", ""
	end
end

local function GetFishingAchievement(subzone)
--	/script local AchName=GetAchievementCriterion(2295,7) StartChatInput(AchName)
	if SavedVars.AllFish then return {[1]=true,[2]=true,[3]=true,[4]=true} end
	local id=FishingZones[subzone] or FishingZones[GetCurrentMapZoneIndex()]
	if id then
		local total={Lake=0,Foul=0,River=0,Salt=0,Oily=0,Mystic=0,Running=0}
		for i=1,GetAchievementNumCriteria(id) do
			local AchName,a,b=GetAchievementCriterion(id,i)
			if FishingBugFix[id] and FishingBugFix[id][i] then
				total[ FishingBugFix[id][i] ]=total[ FishingBugFix[id][i] ]+b-a
			else
				for water in pairs(total) do
					if string.match(AchName,"("..Loc(water)..")")~=nil then
						total[water]=total[water]+b-a
					end
				end
			end
		end
		total.Salt=total.Salt+total.Mystic total.Foul=total.Foul+total.Oily total.River=total.River+total.Running
		return {[1]=total.Foul>0,[2]=total.River>0,[3]=total.Salt>0,[4]=total.Lake>0}
	end
	return false
end

local function IsAbilityUnlocked(skillId)
    local skillType, skillLineIndex, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(skillId)
    return IsSkillAbilityPurchased(skillType, skillLineIndex, skillIndex)
end

local currentLoadingCoroutine = nil
local currentLoadingMap = ""

-- Helper to stop any existing loading process
local function AbortPinLoading(i)
    EVENT_MANAGER:UnregisterForUpdate(AddonName.."_PinLoader_"..i)
    currentLoadingCoroutine = nil
end
-- Create Pin that does only whats needed
local function customCreatePin(pinType, pinTag, xLoc, yLoc)
    local pin, pinKey = PinManager:AcquireObject()
    pin:SetData(pinType, pinTag)
    pin:SetOriginalPosition(xLoc, yLoc)
    pin:SetLocation(xLoc, yLoc)

    local customPinData = PinManager.customPins[pinType]
    if customPinData then
        PinManager:MapPinLookupToPinKey(customPinData.pinTypeString, pinType, pinTag, pinKey)
    end
end

--Callbacks
local MapPinCallback={
	[5]=function(i,subzone)
		local mapData=Lorebooks[subzone]
		if mapData then
			for _, pinData in pairs(mapData) do
				local AchName, iconLore, done=GetLoreBookInfo(1, pinData[3], pinData[4])
				if done==CustomPins[i].done then
					if SavedVars.ColorLore then CustomPins[i].texture = iconLore end
					customCreatePin(_G[CustomPins[i].name],{i,pinData[3], pinData[4]},pinData[1],pinData[2])
				end
			end
		end
	end,
	[6]=function(i,subzone)
		local mapData=TreasureMaps[subzone]
		if mapData then
			for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
				if itemData and itemData.itemType==ITEMTYPE_TROPHY then
					for _, pinData in pairs(mapData) do
						if GetItemId(BAG_BACKPACK,itemData.slotIndex)==pinData[3] then
							local pinTag=pinData[4] and
								(
								type(pinData[4])=="string" and {[1]=i,[2]=itemData.slotIndex,texture="esoui/art/icons/gear_reach_"..pinData[4].."_c.dds"}
	--								or pinData[4]==4 and	--Jewelry survey
								or {[1]=i,[2]=itemData.slotIndex,texture="/"..AddonName.."/textures/Treasure_"..(itemData.stackCount>1 and 4 or 3)..".dds"}
								)
							or {[1]=i,[2]=itemData.slotIndex,texture="/"..AddonName.."/textures/Treasure_2.dds"}	--Treasure map
							CustomPins[i].tint=type(pinData[4])=="string" and ZO_ColorDef:New(1,.3,.3,1) or nil
							pinTag.icon=itemData.iconFile
							customCreatePin(_G[CustomPins[i].name],pinTag,pinData[1],pinData[2])
							if LastZone~=subzone then
								LastZone=subzone
								d('You can find "'..itemData.name..'" in this zone')
							end
						end
					end
				end
			end
		end
	end,
	[7]=function(i,subzone)
		local id=_G[CustomPins[i].name]
		local mapData=ChestData[subzone]
		local x,y=GetMapPlayerPosition("player")
		local mult=GetMapContentType()==MAP_CONTENT_DUNGEON and 4 or 1
		if mapData then
			local FindersKeepers=IsAbilityUnlocked(74580)
			for chType, chData in pairs(mapData) do
				for chest, pinData in pairs(chData) do
					if math.abs(pinData[1]-x)<ChestsRange*mult and math.abs(pinData[2]-y)<ChestsRange*mult then
						if chType==2 and FindersKeepers then
							CustomPins[i].tint=ZO_ColorDef:New(.6,.6,1,.8)
							customCreatePin(id,{i,pinData[1], pinData[2]},pinData[1],pinData[2])
						elseif chType==1 then
							CustomPins[i].tint=ZO_ColorDef:New(1,1,1,.8)
							customCreatePin(id,{i,pinData[1], pinData[2]},pinData[1],pinData[2])
						end
					end
				end
			end
			CustomPins[i].tint=ZO_ColorDef:New(1,1,1,.8)
		end
		mapData=CustomChestData[subzone]
		if mapData then
			CustomPins[i].tint=ZO_ColorDef:New(.4,1,.4,.8)
			for chest, pinData in pairs(mapData) do
				if math.abs(pinData[1]-x)<ChestsRange*mult and math.abs(pinData[2]-y)<ChestsRange*mult then
					customCreatePin(id,{i,pinData[1], pinData[2]},pinData[1],pinData[2])
				end
			end
			CustomPins[i].tint=ZO_ColorDef:New(1,1,1,.8)
		end
	end,
	[8]=function(i,subzone)
		local zoneIndex=GetCurrentMapZoneIndex()
		local mapData=UnknownPOI[GetZoneId(zoneIndex)]
		for poiIndex=1,GetNumPOIs(zoneIndex) do
			local poiType=GetPOIType(zoneIndex, poiIndex)
			if poiType~=7 then -- no Houses
				local poiName = GetPOIInfo(zoneIndex, poiIndex)
				if poiName~="" then
					local normalizedX, normalizedY, _, icon, _, _, isDiscovered= GetPOIMapInfo(zoneIndex, poiIndex)
					local extras=0 -- 1= mundus, 2= SetCrafting
					if icon:find("mundus") then extras = 1 end
					if icon:find("crafting") then extras = 2 end
					--check if data is missing
					if extras==1 or extras==2 then if not mapData or not mapData[poiIndex] then extras=0 end end
					local pinTag={[1]=i,name=poiName,texture=icon}
					if extras==1 then	--Mundus
						pinTag.desc=MundusDescription[ mapData[poiIndex] ]
					elseif extras==2 then--Crafting station
						pinTag.name,pinTag.desc=GetSetDescription(mapData[poiIndex])
					end
					--Unknown POI
					if not isDiscovered and (normalizedX>0 or normalizedY>0) then
						local id=_G[CustomPins[i].name] customCreatePin(id,pinTag,normalizedX,normalizedY)
						local size=(BUI and BUI.name=="BanditsUserInterface" and BUI.init.MiniMap) and 40*BUI.Vars.PinScale/100 or 40 ZO_MapPin.PIN_DATA[id].size=size
					elseif extras==1 or extras==2 then	--Mundus, Crafting station known
						local id=_G[CustomPins[i].name] customCreatePin(id,pinTag,normalizedX,normalizedY)
						local size=(BUI and BUI.name=="BanditsUserInterface" and BUI.init.MiniMap) and 40*BUI.Vars.PinScale/100 or 40 ZO_MapPin.PIN_DATA[id].size=size
					end
				end
			end
		end
	end,
	[15]=function(i,subzone)--Psijic portals
		local mapData=TimeBreach[subzone]
		local level=GetSkillLineXPInfo(5,PsijicSkillLine)
		if mapData then
			for i1,pinData in ipairs(mapData) do
				if pinData[3]==level/10+2 and not (SavedVars.TimeBreachClosed[subzone] and SavedVars.TimeBreachClosed[subzone][i1]) then
					customCreatePin(_G[CustomPins[i].name],{i,pinData[3], pinData[4]},pinData[1],pinData[2])
				end
			end
		end
	end,
	[16]=function(i,subzone)
		local mapData=Shrines[subzone]
		if mapData then
			for i1,pinData in pairs(mapData) do
				CustomPins[i].texture=ShrineIcon[ pinData[3] ]
				customCreatePin(_G[CustomPins[i].name],{[1]=i,texture=ShrineIcon[ pinData[3] ]},pinData[1],pinData[2])
			end
		end
	end,
	[17]=function(i,subzone)
		if currentLoadingCoroutine ~= nil then
			if currentLoadingMap == subzone then return end
			AbortPinLoading(i)
		end
		currentLoadingMap = subzone

		local workQueue = {}
		local subzonesToProcess = {}

		--Add the map we want target
		if subzone == "u48_overland_base" then
			table.insert(subzonesToProcess, "u48_overland_base_east")
			table.insert(subzonesToProcess, "u48_overland_base_west")
		else
			table.insert(subzonesToProcess, subzone)
		end
		-- Add data(pins) to workQueue so we have 1 big table to process
		for _, name in ipairs(subzonesToProcess) do
			local mapData = FishingNodes[name]
			local achStatus = GetFishingAchievement(name)
			if mapData and achStatus then
				for ii = 1, #mapData do
					local pinData = mapData[ii]
					if achStatus[pinData[3]] then
						workQueue[#workQueue+1] = pinData
					end
				end
			end
		end
		local pinIndex = 1
		local frameBudget = 0.1

		currentLoadingCoroutine = function()
			local startTime = GetGameTimeSeconds()
			while pinIndex <= #workQueue do
				local pinData = workQueue[pinIndex]
					CustomPins[i].texture=FishIcon[ pinData[3] ]
					customCreatePin(_G[CustomPins[i].name],{[1]=i,texture=FishIcon[ pinData[3] ]},pinData[1],pinData[2])
					pinIndex = pinIndex + 1
				if pinIndex % 10 == 0 then
					if (GetGameTimeSeconds() - startTime) > frameBudget then
						return
					end
				end
			end
			AbortPinLoading(i)
		end

		-- Start Coroutine
		EVENT_MANAGER:RegisterForUpdate(AddonName.."_PinLoader_"..i, 0, function(i)
			if currentLoadingCoroutine then
				currentLoadingCoroutine()
			else
				AbortPinLoading(i)
			end
		end)
	end,
	[21]=function(i,subzone)
		local mapData=Volendrung[subzone]
		if mapData then
			for i1,pinData in pairs(mapData) do
				customCreatePin(_G[CustomPins[i].name],{[1]=i,name="Volendrung"..i1},pinData[1],pinData[2])
			end
		end
	end,
	[27]=function(i,subzone)--Portals
		local mapData=Achievements[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for i1,pinData in pairs(mapData) do
					customCreatePin(_G[CustomPins[i].name],{[1]=i,name=PortalsNames[pinData[3]]},pinData[1],pinData[2])
				end
			end
		end
	end,
	[33]=function(i,subzone)--Dynamic Encounters
		local mapData=Achievements[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for i1,pinData in pairs(mapData) do
					customCreatePin(_G[CustomPins[i].name],{[1]=i,name=Loc("Dynamic_Encounters")},pinData[1],pinData[2])
				end
			end
		end
	end,
	[70]=function(i,subzone)
		local mapData=Achievements[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for i1,pinData in pairs(mapData) do
					if GetNumAntiquitiesRecovered(pinData[3])<1 then	--and not DoesAntiquityHaveLead(pinData[3]) then
						customCreatePin(_G[CustomPins[i].name],{[1]=i,name=ZO_CachedStrFormat("<<C:1>>",GetAntiquityName(pinData[3]))},pinData[1],pinData[2])
					end
				end
			end
		end
	end,
	[74]=function(i,subzone)--Blackwood random encounters
		local mapData=Achievements[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for i1,pinData in pairs(mapData) do
					customCreatePin(_G[CustomPins[i].name],{[1]=i,name="Random encounter"},pinData[1],pinData[2])
				end
			end
		end
	end,
	[76]=function(i,subzone)--Imperial City bosses
		local mapData=ImperialCity[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for i1,pinData in pairs(mapData) do
					customCreatePin(_G[CustomPins[i].name],{[1]=i,name=pinData[3]},pinData[1],pinData[2])
				end
			end
		end
	end,
	[77]=function(i,subzone)--Imperial City player respawns
		local mapData=ImperialCity[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for i1,pinData in pairs(mapData) do
					CustomPins[i].tint=ZO_ColorDef:New(unpack(AllianceColors[ pinData[3] ]))
					customCreatePin(_G[CustomPins[i].name],{[1]=i,name="ImperialCityRespawn"..i1},pinData[1],pinData[2])
				end
			end
		end
	end,
	[873]=function(i,subzone)--Lightbringer
		local mapData=Achievements[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for _,pinData in pairs(mapData) do
					local Completed
					local zone=ZoneAchievement[subzone]
					if zone then
						local _,c1,r1=GetAchievementCriterion(873,zone)
						local _,c2,r2=GetAchievementCriterion(871,zone)
						local _,c3,r3=GetAchievementCriterion(869,zone)
						Completed=(c1+c2+c3)>=(r1+r2+r3)
					end
					if not Completed then
						customCreatePin(_G[CustomPins[i].name],{i,pinData[3],pinData[4]},pinData[1],pinData[2])
					end
				end
			end
		end
	end,
	[1383]=function(i,subzone)
		local mapData=Achievements[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for _,pinData in pairs(mapData) do
					local _,c1,r1=GetAchievementCriterion(pinData[3],pinData[4])
					local Completed=c1>=r1
					if SavedVars.Show[i] then Completed=false end
					if Completed==CustomPins[i].done then
						customCreatePin(_G[CustomPins[i].name],{pinData[3], pinData[4]},pinData[1],pinData[2])
					end
				end
			end
		end
	end,
}

local function MapPinAddCallback(i)
--	d("["..tostring(i).."] id="..tostring(PinId[i]).." enabled:"..tostring(PinManager:IsCustomPinEnabled(PinId[i])))
	if not CustomPins[i] then d("MapPins: "..tostring(i).." is wrong pin type.") return end
	if UpdatingMapPin[i]==true or GetMapType()>MAPTYPE_ZONE or not PinManager:IsCustomPinEnabled(PinId[i]) then return end
	local MapContentType=GetMapContentType()
	if i==5 and MapContentType==MAP_CONTENT_DUNGEON and IsUnitUsingVeteranDifficulty("player") then return end
	if not IsPlayerActivated() then
		UpdatingMapPin[i]=true
		EVENT_MANAGER:RegisterForEvent(AddonName.."_MapPin_"..i,EVENT_PLAYER_ACTIVATED,
			function()
				EVENT_MANAGER:UnregisterForEvent(AddonName.."_MapPin_"..i,EVENT_PLAYER_ACTIVATED)
				UpdatingMapPin[i]=false MapPinAddCallback(i)
			end)
		return
--[[
	elseif UpdatingMapPin[i]~=2 then
		UpdatingMapPin[i]=true
		zo_callLater(function()UpdatingMapPin[i]=2 MapPinAddCallback(i)end,250)
		return
--]]
	end
	UpdatingMapPin[i]=true
--	pl("Map pin "..i.." updating")

	local subzone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")
	if MapPinCallback[i] then
		MapPinCallback[i](i,subzone)
	elseif i<=4 then
		local mapData
		if i==1 or i==2 then
			mapData=Bosses[subzone]
			if mapData then
				for _,pinData in pairs(mapData) do
					local AchName,Completed,Required=GetAchievementCriterion(pinData[3],pinData[4])
					if (Completed==Required)==CustomPins[i].done then
						PinManager:CreatePin(_G[CustomPins[i].name],{i,pinData[3],pinData[4],pinData[5]},pinData[1],pinData[2])
					end
				end
			end
		elseif i==3 or i==4 then
			local zoneId=GetZoneId(GetCurrentMapZoneIndex())
			if dumbSkyshardFix[zoneId] then zoneId=dumbSkyshardFix[zoneId] end
			-- Table with skyshard achemevements related to zone
			local SkyshardAchievements = SkyshardZoneAchievements[zoneId]
			if not SkyshardAchievements then
				--Incase we are in a delve this grabs the upper zone
				zoneId=GetParentZoneId(zoneId)
				if dumbSkyshardFix[zoneId] then zoneId=dumbSkyshardFix[zoneId] end
				SkyshardAchievements=SkyshardZoneAchievements[zoneId] 
			end
			if SkyshardAchievements then
				local skyshardIndex=0
				for _,AchievementId in pairs(SkyshardAchievements) do
					for criterionIndex=1,GetNumSkyshardsInAchievement(AchievementId) do
						skyshardIndex=skyshardIndex+1
						local skyshardId=GetZoneSkyshardId(zoneId,skyshardIndex)
						local Completed=GetSkyshardDiscoveryStatus(skyshardId)
						if (Completed==2)==CustomPins[i].done then
							local normalizedX,normalizedY,inMap=GetNormalizedPositionForSkyshardId(skyshardId)
							if inMap and normalizedX > 0 and normalizedX < 1 and normalizedY > 0 and normalizedY < 1 then
								PinManager:CreatePin(_G[CustomPins[i].name],{i,AchievementId,criterionIndex,skyshardId},normalizedX,normalizedY)
							end
						end
					end
				end
			end
			--Create pins for those that are on delves
			mapData=SkyShards[subzone]
			if mapData then
				for _,pinData in pairs(mapData) do
					local Completed=GetSkyshardDiscoveryStatus(pinData[5])
					if (Completed==2)==CustomPins[i].done then
						PinManager:CreatePin(_G[CustomPins[i].name],{i,pinData[3],pinData[4],pinData[5]},pinData[1],pinData[2])
					end
				end
			end
		end
	elseif i>FILTER_COUNT then
		local mapData=Achievements[subzone]
		if mapData then
			mapData=mapData[i]
			if mapData then
				for _,pinData in pairs(mapData) do
					local Completed
					if pinData[3] then
						local _,c1,r1=GetAchievementCriterion(i,pinData[3])
						Completed=c1>=r1
					else
						Completed=IsAchievementComplete(i)
					end
					if SavedVars.Show[i] then Completed=false end
					local HaveItem=AchievementItems[i] and AchievementItems[i][ pinData[3] ] and true or false
					if Completed==CustomPins[i].done and HaveItem==CustomPins[i].done then
--						if HaveItem~=CustomPins[i].done then CustomPins[11].tint=ZO_ColorDef:New(1,.1,.4,.8) else CustomPins[11].tint=ZO_ColorDef:New(1,1,1,1) end
						customCreatePin(_G[CustomPins[i].name],{i,pinData[3]},pinData[1],pinData[2])
					end
				end
			end
		end
	end
	UpdatingMapPin[i]=false
end

local function CompassPinAddCallback(i)
	if UpdatingCompassPin[i] or GetMapType()>MAPTYPE_ZONE or not PinManager:IsCustomPinEnabled(PinId[i]) then return end
	local MapContentType=GetMapContentType()
	if i==5 and MapContentType==MAP_CONTENT_DUNGEON and IsUnitUsingVeteranDifficulty("player") then return end
	UpdatingCompassPin[i]=true
	if not IsPlayerActivated() then
		EVENT_MANAGER:RegisterForEvent(AddonName.."_CompassPin_"..i,EVENT_PLAYER_ACTIVATED,
			function()
				EVENT_MANAGER:UnregisterForEvent(AddonName.."_CompassPin_"..i,EVENT_PLAYER_ACTIVATED)
				UpdatingCompassPin[i]=false
				CompassPinAddCallback(i)
			end)
		return
	end
--	pl("Compass pin "..i.." updating")
	local subzone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")
	if i==5 then
		local mapData=Lorebooks[subzone]
		if mapData then
			for _, pinData in pairs(mapData) do
				local AchName, _, done=GetLoreBookInfo(1, pinData[3], pinData[4])
				if done==CustomPins[i].done and AchName~="" then
					COMPASS_PINS.pinManager:CreatePin(CustomPins[i].name,AchName..tostring(pinData[1]),pinData[1],pinData[2])
				end
			end
		end
	elseif i==6 then
		local mapData=TreasureMaps[subzone]
		if mapData then
			for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
				if itemData and itemData.itemType==ITEMTYPE_TROPHY then
					for _, pinData in pairs(mapData) do
						if GetItemId(BAG_BACKPACK,itemData.slotIndex)==pinData[3] then
							COMPASS_PINS.pinManager:CreatePin(CustomPins[i].name,itemData.name,pinData[1],pinData[2])
						end
					end
				end
			end
		end
	elseif i==7 then
		local mapData=ChestData[subzone]
		if mapData then
			local FindersKeepers=IsAbilityUnlocked(74580)
			for chType, chData in pairs(mapData) do
				for chest, pinData in pairs(chData) do
					if chType==1 or (chType==2 and FindersKeepers) then
						COMPASS_PINS.pinManager:CreatePin(CustomPins[i].name,"Chest_"..subzone.."_"..chType.."_"..chest,pinData[1],pinData[2])
					end
				end
			end
		end
		mapData=CustomChestData[subzone]
		if mapData then
			for chest, pinData in pairs(mapData) do
				COMPASS_PINS.pinManager:CreatePin(CustomPins[i].name,"Chest_"..subzone.."_3_"..chest,pinData[1],pinData[2])
			end
		end
	elseif i==15 then
		local mapData=TimeBreach[subzone]
		local level=GetSkillLineXPInfo(5,PsijicSkillLine)
		local num=1
		if mapData then
			for i1,pinData in ipairs(mapData) do
				if pinData[3]==level/10+2 and not (SavedVars.TimeBreachClosed[subzone] and SavedVars.TimeBreachClosed[subzone][i1]) then
					COMPASS_PINS.pinManager:CreatePin(CustomPins[i].name,"TimeRift"..num,pinData[1],pinData[2])
					num=num+1
				end
			end
		end
	elseif i>FILTER_COUNT then
		local mapData=Achievements[subzone]
		local num=1
		if mapData then
			mapData=mapData[i]
			if mapData then
				for _,pinData in pairs(mapData) do
					local AchName,Completed=pinData[3] or "",nil
					if i==873 then --Lightbringer
						local zone=ZoneAchievement[subzone]
						if zone then
							AchName="Lightbringer"
							local _,c1,r1=GetAchievementCriterion(873,zone)
							local _,c2,r2=GetAchievementCriterion(871,zone)
							local _,c3,r3=GetAchievementCriterion(869,zone)
							Completed=(c1+c2+c3)>=(r1+r2+r3)
						end
					elseif i==1383 then
						local name,c1,r1=GetAchievementCriterion(pinData[3],pinData[4])
						AchName=name
						Completed=c1>=r1
					elseif pinData[3] then
						local name,c1,r1=GetAchievementCriterion(i,pinData[3])
						AchName=name
						Completed=c1>=r1
					else
						Completed=IsAchievementComplete(i)
					end
					if SavedVars.Show[i] then Completed=false end
					local HaveItem=(AchievementItems[i] and AchievementItems[i][pinData[3] ]) and true or false
					if Completed==CustomPins[i].done and HaveItem==CustomPins[i].done then
						COMPASS_PINS.pinManager:CreatePin(CustomPins[i].name,AchName..num,pinData[1],pinData[2])
						num=num+1
					end
				end
			end
		end

	end
	UpdatingCompassPin[i]=false
end

local function AddCompassCustomPin(id,i)
	if COMPASS_PINS and (i==5 or i==6 or i==7 or i==15 or i>FILTER_COUNT) then
		local pin=CustomPins[i].filter or i
		if SavedVars[pin] then
--			pl("["..id.."] Compass pin "..i.." enabled")
			local CompassPinLayout={maxDistance=0.05,level=30,size=40,texture=(type(CustomPins[i].texture)=="string" and CustomPins[i].texture or "/"..AddonName.."/textures/Treasure_1.dds")}
			COMPASS_PINS:AddCustomPin(CustomPins[i].name, function() CompassPinAddCallback(i) end, CompassPinLayout)
			COMPASS_PINS:RefreshPins(CustomPins[i].name)
		else
			COMPASS_PINS.pinManager:RemovePins(CustomPins[i].name)
--			pl("["..id.."] Compass pin "..i.." disabled")
		end
	end
end

local function ScanInventory()
	for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
		if itemData and itemData.itemType==ITEMTYPE_TROPHY then
			local itemId=GetItemId(BAG_BACKPACK,itemData.slotIndex)
			for achId,achTable in ipairs(TrophyTable) do
				if achTable[itemId] then
					AchievementItems[achId][achTable[itemId] ]=true
					break
				end
			end
		end
	end
end

--Events
local function OnBackpackChanged(bagId,_,slotData)
    if bagId ~= BAG_BACKPACK or UpdatingMapPin[6] then return end
    UpdatingMapPin[6] = true
    zo_callLater(function()
        UpdatingMapPin[6] = false
        PinManager:RefreshCustomPins(_G[CustomPins[6].name])
        if COMPASS_PINS then COMPASS_PINS:RefreshPins(CustomPins[6].name) end
    end, 1000)
end

local function OnLootReceived(_, receivedBy, itemName, quantity, itemSound, lootType, self, _, questItemIcon, itemId)
	if lootType~=LOOT_TYPE_ITEM and lootType~=LOOT_TYPE_QUEST_ITEM then return end
	for achId,achTable in ipairs(TrophyTable) do
		if achTable[itemId] then
			AchievementItems[achId][achTable[itemId] ]=true
			PinManager:RefreshCustomPins(_G[CustomPins[achId].name])
			if COMPASS_PINS then COMPASS_PINS:RefreshPins(CustomPins[achId].name) end
			break
		end
	end
end

local function OnAchievementUpdate(achievementId,link)
	LastAchivement=achievementId
	local function RefreshPins(name)
		EVENT_MANAGER:RegisterForUpdate("CallLater_"..name, 1000,
		function()
			EVENT_MANAGER:UnregisterForUpdate("CallLater_"..name)
			PinManager:RefreshCustomPins(name)
			if COMPASS_PINS then COMPASS_PINS:RefreshPins(name) end
		end)
	end
	if BossesAchievements[achievementId] then -- Delve bosses
		if SavedVars[1] then RefreshPins(_G[CustomPins[1].name]) end
		if SavedVars[2] then RefreshPins(_G[CustomPins[2].name]) end
	elseif FishingAchievements[achievementId] and SavedVars[17] then -- Fishing
		RefreshPins(_G[CustomPins[17].name])
	elseif CustomPins[achievementId] and CustomPins[achievementId].ach then -- Achievements
		RefreshPins(_G[CustomPins[achievementId].name])
	elseif achievementId==1379 or achievementId==1380 or achievementId==1381 or achievementId==1382 then -- A Cutpurse Above Achievement
		RefreshPins(_G[CustomPins[1383].name])	
	end
end
local function OnSkyshardsUpdated()
    PinManager:RefreshCustomPins(_G[CustomPins[3].name])
    if COMPASS_PINS then COMPASS_PINS:RefreshPins(CustomPins[3].name) end
end
local function OnBookLearned(_,categoryIndex)
	if categoryIndex==1 then
	PinManager:RefreshCustomPins(_G[CustomPins[5].name])
	if COMPASS_PINS then COMPASS_PINS:RefreshPins(CustomPins[5].name) end
	end
end

local function CheckChestData(x,y,zone,subzone)
	if not zone then return end
	local delta=subzone and .01 or .003
	local mapData=ChestData[zone]
	if mapData then
		for chType, chData in pairs(mapData) do
			for i,data in pairs(chData) do
				if math.abs(data[1]-x)<delta and math.abs(data[2]-y)<delta then
					return true
				end
			end
		end
	end

	mapData=CustomChestData[zone]
	if mapData then
		for i,data in pairs(mapData) do
			if math.abs(data[1]-x)<delta and math.abs(data[2]-y)<delta then
				return true
			end
		end
	end

	return false
end

local function CheckQuestData(x,y,zone)
	if not zone then return end
	local delta=0.03
	mapData=CustomChestData[zone]
	if mapData then
		for i,data in pairs(mapData) do
			if math.abs(data[1]-x)<delta and math.abs(data[2]-y)<delta then
				return true
			end
		end
	end
	return false
end

local function CheckThievesTrove(x,y,zone)
	if not zone then return end
	local delta=0.014
	local mapData=ChestData[zone]
	if mapData then
		for chType, chData in pairs(mapData) do
			for i,data in pairs(chData) do
				if math.abs(data[1]-x)<delta and math.abs(data[2]-y)<delta then
					return true
				end
			end
		end
	end
	mapData=CustomThievesTrove[zone]
	if mapData then
		for i,data in pairs(mapData) do
			if math.abs(data[1]-x)<delta and math.abs(data[2]-y)<delta then
				return true
			end
		end
	end
	return false
end

local function OnQuestAdded(_,_,questName)
	if GetMapType()~=MAPTYPE_ZONE then return end
	local x,y,_=GetMapPlayerPosition("player") x=math.floor(x*10000)/10000 y=math.floor(y*10000)/10000
	local subzone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")
	local function AddQuest()
		for i=GetNumJournalQuests(),1,-1 do
			local _questName,_,_,_,_,_,_,_,_,_questType=GetJournalQuestInfo(i)
			if questName==_questName then
				if not CustomQuestData[subzone] then CustomQuestData[subzone]={} end
				table.insert(CustomQuestData[subzone], {x,y,_questType,questName})
				d("New quest added at "..("%05.02f"):format(zo_round(x*10000)/100).."x"..("%05.02f"):format(zo_round(y*10000)/100)..": "..questName.." (".._questType..")" )
				break
			end
		end
	end
	if not CheckQuestData(x,y,subzone) then
		zo_callLater(function()AddQuest()end,250)
	end
end

local function OnInteract(_,result,TargetName)
	if result~=CLIENT_INTERACT_RESULT_SUCCESS then return end
	if SavedVars[7] and IsThievesTrove[TargetName] then
		local zone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")
		if zone then
			local x,y,_=GetMapPlayerPosition("player") x=math.floor(x*10000)/10000 y=math.floor(y*10000)/10000
			if not CheckThievesTrove(x,y,zone) then
				if not CustomThievesTrove[zone] then CustomThievesTrove[zone]={} end
				table.insert(CustomThievesTrove[zone], {x,y})
				d("New thieves trove found at "..("%05.02f"):format(zo_round(x*10000)/100).."x"..("%05.02f"):format(zo_round(y*10000)/100))
			end
		end
	elseif SavedVars[7] and IsChest[TargetName] then
		ChestsLooted=ChestsLooted+1
		local zone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")
		if zone then
			local x,y,_=GetMapPlayerPosition("player") x=math.floor(x*10000)/10000 y=math.floor(y*10000)/10000
			local subzone=(GetMapType()==MAPTYPE_SUBZONE or GetMapContentType()==MAP_CONTENT_DUNGEON)
			if not CheckChestData(x,y,zone,subzone) then
				if not CustomChestData[zone] then CustomChestData[zone]={} end
				table.insert(CustomChestData[zone], {x,y})
				d("New chest found at "..("%05.02f"):format(zo_round(x*10000)/100).."x"..("%05.02f"):format(zo_round(y*10000)/100) )
			end
		end
	elseif SavedVars[15] and IsTimeBreach[TargetName] then
		local zone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")
		if zone then
			local x,y,_=GetMapPlayerPosition("player") x=math.floor(x*10000)/10000 y=math.floor(y*10000)/10000
			local delta=0.03
			mapData=TimeBreach[zone]
			if mapData then
				for i,data in ipairs(mapData) do
					if math.abs(data[1]-x)<delta and math.abs(data[2]-y)<delta then
						if not SavedVars.TimeBreachClosed[zone] then SavedVars.TimeBreachClosed[zone]={} end
						SavedVars.TimeBreachClosed[zone][i]=true
						PinManager:RefreshCustomPins(_G[CustomPins[15].name])
						if COMPASS_PINS then COMPASS_PINS:RefreshPins(CustomPins[15].name) end
					end
				end
			end
		end
	end
--	CHAT_ROUTER:AddSystemMessage(TargetName)
end

local function TrackChestsRange()
--	if IsUnitInCombat('player') then return end
	PinManager:RefreshCustomPins(PinId[7])
end

--AutoCalls refresh on chest Pins
local function RegisterChestRefresh()
	local lastX ,lastY = 0, 0
	local lastMap = nil
	EVENT_MANAGER:RegisterForUpdate("MapPins_Chest_Refresh",5000, function()
		local x,y=GetMapPlayerPosition("player")
		if not x or not y then return end
		local map = GetMapTileTexture()
		if map ~= lastMap then
			lastMap = map
			lastX,lastY = x,y
			TrackChestsRange()
			return
		end
		local range=.05
		if GetMapContentType() == MAP_CONTENT_DUNGEON then range=.15 end
		local dx=lastX-x
		local dy=lastY-y
		if dx*dx + dy*dy > range*range then
			lastX,lastY = x,y
			TrackChestsRange()
		end
	end)
end

local function ResizePins(minimap)
	ZO_MapPin.PIN_DATA[_G[CustomPins[8].name]].size=minimap and 40*BUI.Vars.PinScale/100 or 40	--Unknown POI
	ZO_MapPin.PIN_DATA[_G[CustomPins[17].name]].size=minimap and 10 or SavedGlobal.pinsize	--Fishing nodes
--	d("Unknown POIs size are resized to "..(minimap and "minimap" or "world map"))
end

local function RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_ACHIEVEMENT_UPDATED,function(_,achievementId,link) OnAchievementUpdate(achievementId)end)
	EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_ACHIEVEMENT_AWARDED,function(_,_,_,achievementId,link) OnAchievementUpdate(achievementId)end)

	if SavedVars[3] then
        EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_SKYSHARDS_UPDATED, OnSkyshardsUpdated)
    else
        EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_SKYSHARDS_UPDATED)
    end

	if SavedVars[5] then
		EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_LORE_BOOK_LEARNED, OnBookLearned)
	else
		EVENT_MANAGER:UnregisterForEvent(AddonName,EVENT_LORE_BOOK_LEARNED)
	end

	if SavedVars[6] then
--		EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_LOOT_RECEIVED, OnLootReceived)
		zo_callLater(function()
			SHARED_INVENTORY:RegisterCallback("SlotAdded", OnBackpackChanged)
			SHARED_INVENTORY:RegisterCallback("SlotRemoved", OnBackpackChanged)
		end, 2500)
	else
		SHARED_INVENTORY:UnregisterCallback("SlotAdded")
		SHARED_INVENTORY:UnregisterCallback("SlotRemoved")
	end

	if SavedVars[11] or SavedVars[13] or SavedVars[14] or SavedVars[18] or SavedVars[19] or SavedVars[20] or SavedVars[22] then
		ScanInventory()
		EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_LOOT_RECEIVED, OnLootReceived)
	else
		EVENT_MANAGER:UnregisterForEvent(AddonName,EVENT_LOOT_RECEIVED)
	end

	if SavedVars[7] or SavedVars[15] then
		EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_CLIENT_INTERACT_RESULT, OnInteract)
	else
		EVENT_MANAGER:UnregisterForEvent(AddonName,EVENT_CLIENT_INTERACT_RESULT)
	end

	if SavedVars[7] then
		if VOTANS_MINIMAP or FyrMM or AUI and AUI.Minimap.DoesShow() or BUI and BUI.Vars.MiniMap then RegisterChestRefresh() end
		WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
			if newState==SCENE_SHOWING then TrackChestsRange() end
		end)
	else
		WORLD_MAP_SCENE:UnregisterCallback("StateChange")
		EVENT_MANAGER:UnregisterForUpdate("MapPins_Chest_Refresh")
	end

	if SavedVars[8] and (BUI and BUI.name=="BanditsUserInterface") then
		CALLBACK_MANAGER:RegisterCallback("BUI_MiniMap_Shown", ResizePins)
	else
		CALLBACK_MANAGER:UnregisterCallback("BUI_MiniMap_Shown")
	end

	if SavedVars[15] then
		for i=1,GetNumSkillLines(5) do
			if GetSkillAbilityId(5,i,1,false)==103478 then PsijicSkillLine=i break end
		end
	end
--	EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_QUEST_ADDED, OnQuestAdded)
end

local filterIdToFilterIndex ={}
ZO_PostHook(ZO_WorldMapFilterPanel_Shared, "GetPinFilter", function(self, mapPinGroup)
    local i = filterIdToFilterIndex[mapPinGroup]
	if i then return SavedVars[i] end
end)

ZO_PostHook(ZO_WorldMapFilterPanel_Shared, "SetPinFilter", function(self, mapPinGroup, shown)
    local i = filterIdToFilterIndex[mapPinGroup]
	if i then
		SavedVars[i] = shown
		for pin,id in pairs(CustomPins[i].id) do
			PinManager:SetCustomPinEnabled(id, shown)
			AddCompassCustomPin(id,pin)
			PinManager:RefreshCustomPins(id)
		end
	end
end)

--update the Filters
local function OnMapChanged()
	for mapPinGroup,i in pairs(filterIdToFilterIndex) do
		if GAMEPAD_WORLD_MAP_FILTERS then
			GAMEPAD_WORLD_MAP_FILTERS.currentPanel:SetPinFilter(mapPinGroup, SavedVars[i] ~= false)
		end
	end
end

local function SetPinSize(pinSize)
	SavedGlobal.pinsize=pinSize
	for i,id in pairs(PinId) do
		if ZO_MapPin.PIN_DATA[id] and CustomPins[i].k then ZO_MapPin.PIN_DATA[id].size=pinSize*CustomPins[i].k end
	end
	PinManager:RefreshCustomPins()
end

local function CreateSettingMenu()
	local LHAS = LibHarvensAddonSettings
	if not LHAS then return end
	local LHAS_Menu = LHAS:AddAddon("Map Pins Addon")
	LHAS_Menu:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Pin Size \n Small <- -> Large",
		tooltip = "Default: "..DefaultGlobal.pinsize,
		default = DefaultGlobal.pinsize,
        setFunction = function(value)
           SetPinSize(value)
        end,
        getFunction = function()
            return SavedGlobal.pinsize
        end,
        min = 16,
        max = 40,
        step = 1,
    })
	LHAS_Menu:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show All Fish", 
		tooltip = "When Off will only show fish you need to collect.",
		default = DefaultVars.AllFish, 
        setFunction = function(value)
           SavedVars.AllFish = value
		   PinManager:RefreshCustomPins(_G["pinType_Fishing_Nodes"])
        end,
        getFunction = function()
            return SavedVars.AllFish
        end,
    })
	LHAS_Menu:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Color Lorebooks", 
		default = DefaultVars.ColorLore, 
        setFunction = function(value)
           SavedVars.ColorLore = value
		   PinManager:RefreshCustomPins(_G["pinType_Lore_books"])
        end,
        getFunction = function()
            return SavedVars.ColorLore
        end,
    })
end

local PinTooltipSupres={
[7]=true,
[16]=true,
[17]=true,
[77]=true,--Imperial City player respawns
}

local PinTooltipCreator={
	tooltip=1,
	creator=function(pin)
		local _, pinTag=pin:GetPinTypeAndTag()
		local name,desc,desc1,icon
		if pinTag[1]==15 then
			icon=CustomPins[15].texture
			name=Loc("Time_Rifts")
		elseif (pinTag[1]==1 or pinTag[1]==2) and pinTag[4] then
			name,desc,_,icon=GetAchievementInfo(pinTag[2])
			desc1="  Set items:"
			for _,id in pairs(pinTag[4]) do
				desc1=desc1..("\n|H1:item:%d:359:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"):format(id)
			end
		elseif pinTag[1]==873 then	--Lightbringer
			icon=CustomPins[873].texture
			name=GetString(SI_JOURNAL_MENU_ACHIEVEMENTS) or "Achievements"
			desc=zo_strformat("|t24:24:<<4>>|t <<1>>\n", GetAchievementInfo(873))--Lightbringer
			..zo_strformat("|t24:24:<<4>>|t <<1>>\n", GetAchievementInfo(871))--Give to Poor
			..zo_strformat("|t24:24:<<4>>|t <<1>>", GetAchievementInfo(869))--Crime Pays
		-- Handles Portals, Dynamic Encounters and Imperial Pins
		elseif pinTag[1]==27 or pinTag[1]==33 or pinTag[1]==70 or pinTag[1]==74 or pinTag[1]==76 then
			icon=CustomPins[ pinTag[1] ].texture
			name=pinTag.name
		elseif pinTag[1]<=4 then	-- Tooltip for Bosses & Skyshards
			name,desc,_,icon=GetAchievementInfo(pinTag[2])
			if pinTag[3] then desc=GetAchievementCriterion(pinTag[2], pinTag[3]) end
		elseif pinTag[1]>FILTER_COUNT then	--Main tooltip for achievements
			name,desc,_,icon=GetAchievementInfo(pinTag[1])
			if pinTag[2] then desc=GetAchievementCriterion(pinTag[1], pinTag[2]) pinTag[3]=pinTag[2] end
		elseif pinTag[1]==5 then
			name, icon, _=GetLoreBookInfo(1, pinTag[2], pinTag[3])
		elseif pinTag[1]==6 then
			icon=pinTag.icon
			local _, iStack, _, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, pinTag[2])
			name=GetItemName(BAG_BACKPACK,pinTag[2]) .. " (" .. tostring(iStack) .. ")"
		elseif pinTag[1]==8 then
			icon=pinTag.texture
			name=pinTag.name
			desc=pinTag.desc
		elseif pinTag[1]==21 then
			icon=CustomPins[21].texture
			name=Loc("Volendrung").." spawn location"
		end
		name=(pinTag[3] and "["..pinTag[3].."] " or "")..name
		ZO_MapLocationTooltip_Gamepad:LayoutIconStringLine(ZO_MapLocationTooltip_Gamepad.tooltip, icon, zo_strformat("<<1>>", name), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapLocationTooltipWayshrineHeader"))
		if desc then
			ZO_MapLocationTooltip_Gamepad:LayoutIconStringLine(ZO_MapLocationTooltip_Gamepad.tooltip, nil, zo_strformat("<<1>>", desc), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapRecallCost"))
		end
		if desc1 then
			ZO_MapLocationTooltip_Gamepad:LayoutIconStringLine(ZO_MapLocationTooltip_Gamepad.tooltip, nil, zo_strformat("<<1>>", desc1), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapRecallCost"))
		end
	end
}
