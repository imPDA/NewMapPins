--[[	Helper scripts
/script zo_callLater(function()d(GetGameCameraInteractableActionInfo())end,1000)
--	/script MP_MakeBase()
function MP_MakeBase()
	--Chests
	local count=0
	for n=1,6 do
		d("Chests: Working on base "..n)
--		if #AddChestData[n]["data"]>0 then
			for zone in pairs(AddChestData[n]["data"]) do
				for i,data in pairs(AddChestData[n]["data"][zone]) do
					local confirm=true
					local x,y=data[1],data[2]
					if CustomChestData["data"][1][zone]==nil then CustomChestData["data"][1][zone]={} end
					for ii,data in pairs(CustomChestData["data"][1][zone]) do
						if math.abs(data[1]-x)<0.003 and math.abs(data[2]-y)<0.003 then
							confirm=false --break
						end
					end
					if confirm then
						count=count+1
						table.insert(CustomChestData["data"][1][zone],{x,y})
					end
				end
			end
--		end
	end
	d("Chests added: "..count)

	--Thieves troves
	count=0
	for n=1,6 do
		d("Thieves troves: Working on base "..n)
--		if #AddThievesTrove[n]["data"]>0 then
			for zone in pairs(AddThievesTrove[n]["data"]) do
				for i,data in pairs(AddThievesTrove[n]["data"][zone]) do
					local confirm=true
					local x,y=data[1],data[2]
					if CustomChestData["data"][2][zone]==nil then CustomChestData["data"][2][zone]={} end
					for ii,data in pairs(CustomChestData["data"][2][zone]) do
						if math.abs(data[1]-x)<0.003 and math.abs(data[2]-y)<0.003 then
							confirm=false --break
						end
					end
					if confirm then
						count=count+1
						table.insert(CustomChestData["data"][2][zone],{x,y})
					end
				end
			end
--		end
	end
	d("Thieves trove added: "..count)
end

function MP_MakeBase()
--	local mapData=ChestData[subzone]
	local delta=0.003
	local x,y,confirm=0,0,false
	d("Chest scan start")
	for subzone,mapData in pairs(ChestData) do
		if mapData then
			local chData=mapData[2]
			if chData then
				for chest1, data1 in ipairs(chData) do
					x,y=data1[1],data1[2]
					for chest2, data2 in ipairs(chData) do
						if chest1~=chest2 and math.abs(data1[1]-data2[1])<delta and math.abs(data1[2]-data2[2])<delta then
							x=(x+data2[1])/2
							y=(y+data2[2])/2
							d(data2[1]..","..data2[2])
							confirm=true
						end
					end
					if confirm then d(data1[1]..","..data1[2].." ["..subzone.."] Change to {"..x..","..y.."}") end
					confirm=false
				end
			end
		end
	end
end

/script d(GetAchievementCriterion(709,1))
function MP_MakeBase()
	local count=0
	for base=1,4 do
		for zone in pairs(MP_Data[base]) do
			local subzone=string.match(zone, "%w+/%w+/%w+/(%w+_%w+)")
			if not subzone then
				d("Wrong zone: "..zone)
			else
				if not RawChestData[subzone] then RawChestData[subzone]={} end
				for i,data in pairs(MP_Data[base][zone]) do
					count=count+1
					index=#RawChestData[subzone]+1
					RawChestData[subzone][index]={tonumber(string.format("%.04f", data[1])),tonumber(string.format("%.04f", data[2]))}
				end
			end
		end
	end
	d("Added :"..count)
	count=0
	for zone in pairs(RawChestData) do
		for i,data in pairs(RawChestData[zone]) do
			local x,y=data[1],data[2]
			for ii,data in pairs(RawChestData[zone]) do
				if i~=ii then
					if math.abs(data[1]-x)<0.01 and math.abs(data[2]-y)<0.01 then
						count=count+1
						RawChestData[zone][ii]=nil
					end
				end
			end
		end
	end
	d("Removed :"..count)
	count=0
	for zone in pairs(RawChestData) do
		count=count+1
		ChestData[zone]=RawChestData[zone]
	end
	d("Zones added :"..count)
end

/script PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, .736,.674)
/script local id=_G["pinType_Treasure_Maps"] local en=ZO_WorldMap_GetPinManager():IsCustomPinEnabled(id) d(en)
/script ZO_WorldMap_GetPinManager():SetCustomPinEnabled(POI_TYPE_HOUSE,false)
/script d(string.match(GetMapTileTexture(), "%w+/%w+/%w+/(%w+_%w+)"))
/script d("|t26:26:/MapPins/Chest_1.dds|t")
/script MP_MakeBase()
/script Link=("|H1:item:%d:370:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"):format(130803) local _,name=GetItemLinkSetInfo(Link) CHAT_ROUTER:AddSystemMessage(name)
/script d(ZO_WorldMap_GetPinManager():IsCustomPinEnabled(201))
/script PinManager:RefreshCustomPins()
/script for pin,data in pairs(ZO_MapPin.PIN_DATA) do local texture=data.texture d(pin.." ("..tostring(data.size)..") |t18:18:"..tostring(texture).."|t"..tostring(texture)) end
/script ZO_MapPin.PIN_DATA[170].size=16
/script for id=1350,1400 do local AchName=GetAchievementCriterion(id,1) if string.match(AchName,"Explorer")~=nil then d("["..id.."] "..AchName) end end
/script d(GetAchievementCriterion(556,1))
function MP_MakeBase()
	for id=1,2000 do
		local AchName=GetAchievementCriterion(id,1)
		if string.match(AchName,"Group Challenge")~=nil then
			d("["..id.."] "..AchName)
			AchivementBase[id]=AchName
		end
	end
end

/script for i=1,GetNumSkillLines(5) do if GetSkillAbilityId(5,i,1,false)==103478 then PsijicSkillLine=i end end d(GetSkillLineXPInfo(5,PsijicSkillLine))

/script local x,y=GetMapPlayerWaypoint() CHAT_ROUTER:AddSystemMessage('{'..math.floor(x*1000)/1000 ..","..math.floor(y*1000)/1000 ..'},')

/script for _, itemData in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
	if itemData and itemData.itemType==ITEMTYPE_TROPHY then d(itemData.name.." "..itemData.stackCount) end
	end

--	POI
/script local zone=GetCurrentMapZoneIndex()
for i=1,GetNumPOIs(zone) do local id=GetPOIType(zone, i) local Name=GetPOIInfo(zone, i)
local _,_,poiType,_,_,_,known=GetPOIMapInfo(zone, i)
if id~=7 and Name~="" then d('['..i..']={"'..Name..'",'..id..','..poiType..' Known:'..tostring(known)..'},')
end end

/script d(GetPOIMapInfo(GetCurrentMapZoneIndex(), 7))
/script CHAT_ROUTER:AddSystemMessage(GetZoneId(GetCurrentMapZoneIndex()))
/script local i,zone=1,GetCurrentMapZoneIndex() local id=GetPOIType(zone, i) local Name=GetPOIInfo(zone, i) CHAT_ROUTER:AddSystemMessage('['..i..']={"'..Name..'",'..id..'},')

--]]



--[[	Helper scripts POI
	SLASH_COMMANDS["/makebase"]=function()
		PoiData=ZO_SavedVars:NewAccountWide("MP_PoiData",1,nil,{})
		local zone=GetCurrentMapZoneIndex()
		local zoneId=GetZoneId(zone)
		PoiData[zoneId]={}
		for i=1,GetNumPOIs(zone) do
			local id=GetPOIType(zone, i)
			local Name=GetPOIInfo(zone, i)
			local _,_,poiType,_,_,_,known=GetPOIMapInfo(zone, i)
			if id~=7 and Name~="" then
				d('['..i..']={"'..Name..'",'..id..','..poiType..' Known:'..tostring(known)..'},')
				PoiData[zoneId][i]=Name
			end
		end
	end
--]]