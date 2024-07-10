DoVehicleChecks = function(player)
    local vehicle = GetVehiclePedIsIn(player)
    if vehicle > 0 and DoesVehicleHaveRoof(vehicle) then
        if exports.ceeb_vehicle:IsVehicleIsVehicle(cache.vehicle) then
            return false
        end
        local doors = GetNumberOfVehicleDoors(vehicle)

        for i = 0, doors do
            if GetIsDoorValid(vehicle, i) then
                if IsVehicleDoorDamaged(vehicle, i) or IsVehicleDoorFullyOpen(vehicle, i) or GetVehicleDoorAngleRatio(vehicle, i) > 0.0 then
                    return false
                end
            end
        end

        local vehEntity = Entity(vehicle).state
        if vehEntity.windows_open then
            for _, v in pairs(vehEntity.windows_open) do
                if v then
                    return false
                end
            end
        end

        if AreAllVehicleWindowsIntact(vehicle) then
            return true
        end

        return false
    end
    return false
end

CreateThread(function()
    while true do
        local player = PlayerPedId()

        if player then
            local audioOcclusion = DoVehicleChecks(player)
            if audioOcclusion and not LocalPlayer.state.muffled then
                LocalPlayer.state:set("muffled", true, true)
                exports["pma-voice"]:overrideProximityRange(5.0, true)
            elseif not audioOcclusion and LocalPlayer.state.muffled then
                LocalPlayer.state:set("muffled", false, true)
                exports["pma-voice"]:clearProximityOverride()
            end
        end

        local player = cache.ped
        local playerVeh = cache.vehicle
        local players = GetActivePlayers()

        if #players > 1 then
            for _, v in ipairs(players) do
                local otherPlayer = GetPlayerPed(v)
                if player ~= otherPlayer then
                    local playerServerId = GetPlayerServerId(v)
                    local playerState = Player(playerServerId).state
                    local localPlayerState = LocalPlayer.state
                    if not playerState.micro and not playerState.megaphone and not radioData[playerServerId] and not callData[playerServerId] then
                        if playerState.muffled or localPlayerState.muffled then
                            if playerVeh ~= GetVehiclePedIsIn(otherPlayer) then
                                MumbleSetSubmixForServerId(playerServerId, exports["pma-voice"]:getCustomSubmix("muffled"))
                            else
                                if IsThisModelAHeli(GetEntityModel(playerVeh)) then
                                    MumbleSetSubmixForServerId(playerServerId, exports["pma-voice"]:getCustomSubmix("radio_default"))
                                else
                                    MumbleSetSubmixForServerId(playerServerId, -1)
                                end
                            end
                        else
                            MumbleSetSubmixForServerId(playerServerId, -1)
                        end
                    elseif playerState.megaphone then
                        MumbleSetSubmixForServerId(playerServerId, exports["pma-voice"]:getCustomSubmix("megaphone"))
                    elseif playerState.micro then
                        MumbleSetSubmixForServerId(playerServerId, exports["pma-voice"]:getCustomSubmix("micro"))
                    end
                end
            end
        end

        Wait(500)
    end
end)
