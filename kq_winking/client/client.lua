local cooldown = 0

-- Models mapped to their custom animation dictionaries
local models = {
    zr350 = 'kq_winking@zr350',
    driftzr350 = 'kq_winking@zr350',
    futo2 = 'kq_winking@futo2',
    driftfuto2 = 'kq_winking@futo2',
}

local function LoadAnimDict(dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and timeout > GetGameTimer() do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

local function GetAnimDictForModel(model)
    -- Find the correct animation dict for the vehicle model
    for key, dict in pairs(models) do
        if GetHashKey(key) == model then
            return dict
        end
    end
    return nil
end

local function PerformWink(vehicle, dir)
    local _, on, high = GetVehicleLightsState(vehicle)
    local model = GetEntityModel(vehicle)
    local dict = GetAnimDictForModel(model)
    
    if not dict then
        return
    end
    
    local animName = 'wink_' .. (dir and 'left' or 'right')
    
    -- Use the alternative animation when the lights are on. Wink down instead of up
    if on + high >= 1 then
        animName = animName .. '_down'
    end
    
    LoadAnimDict(dict)
    PlayEntityAnim(vehicle, animName, dict, 10.0, false, false, true, 0, 0)
end

RegisterNetEvent('kq_winking:client:wink', function(netId, dir)
    if not NetworkDoesNetworkIdExist(netId) or not NetworkDoesEntityExistWithNetworkId(netId) then return end
        
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then return end
    
    PerformWink(vehicle, dir)
end)

local function TriggerWink(dir)
    -- Very basic cooldown system
    if cooldown > GetGameTimer() then
        return
    end
    cooldown = GetGameTimer() + 1300
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle == 0 then
        return -- Player is not in any vehicle
    end
    
    local model = GetEntityModel(vehicle)
    
    -- Early exit if the vehicle does not have a winking animation
    if not GetAnimDictForModel(model) then
        return
    end
    
    -- Send an event if the vehicle is networked. Otherwise, simply perform the wink
    if NetworkGetEntityIsNetworked(vehicle) then
        TriggerServerEvent('kq_winking:server:wink', NetworkGetNetworkIdFromEntity(vehicle), dir)
    else
        PerformWink(vehicle, dir)
    end
end

RegisterKeyMapping('kq_wink_r', 'Wink right headlight', 'keyboard', 'plus')
RegisterCommand('kq_wink_r', function() TriggerWink() end, false)

RegisterKeyMapping('kq_wink_l', 'Wink left headlight', 'keyboard', 'minus')
RegisterCommand('kq_wink_l', function() TriggerWink(true) end, false)

-- Get more premium scripts from https://KuzQuality.com/
