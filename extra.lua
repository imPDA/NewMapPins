local function a()
    local allPOITextures = {}
    local lastPOIId = 0

    for i = 1, 14000 do
        local zoneIndex, poiIndex = GetPOIIndices(i)
        if zoneIndex ~= 1 or poiIndex ~= 1 then
            lastPOIId = i
            local normalizedX, normalizedZ, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby = GetPOIMapInfo(zoneIndex, poiIndex)
            allPOITextures[icon] = true
        end
    end

    GLOBAL_ALL_POI_TEXTURES = allPOITextures
    df('Last POI ID returning data is %d', lastPOIId)
end

GLOBAL_TEST_ALL_POI_TEXTURES = a
