local bagEquipped = false
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local justConnect = true

-- Function to save the current outfit
local saveSkin = function()
    Wait(100)
    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('backpack:save', skin)
        TriggerServerEvent('illenium-appearance:server:saveAppearance', skin)
    end)
end

-- Function to equip the backpack
local function PutOnBag()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformConfig = skin.sex == 0 and Config.BackpackStorage.Uniform.Male or Config.BackpackStorage.Uniform.Female
        TriggerEvent('skinchanger:loadClothes', skin, uniformConfig)
        saveSkin()
    end)
    bagEquipped = true
end

-- Function to remove the backpack
local function RemoveBag()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local clothesWithoutBag = skin.sex == 0 and Config.CleanUniform.Male or Config.CleanUniform.Female
        TriggerEvent('skinchanger:loadClothes', skin, clothesWithoutBag)
        saveSkin()
        bagEquipped = false
    end)
end

-- Handler to update the inventory
AddEventHandler('ox_inventory:updateInventory', function(changes)
    if justConnect then
        Wait(6000) -- Increase the wait time to 6 seconds
        justConnect = false
    end

    for k, v in pairs(changes) do
        local count = ox_inventory:Search('count', 'backpack')

        if type(v) == 'table' then
            if count > 0 and (not bagEquipped) then
                Wait(1000) -- Add a delay before calling PutOnBag()
                PutOnBag()
            elseif count < 1 and bagEquipped then
                Wait(1000) -- Add a delay before calling RemoveBag()
                RemoveBag()
            end
        elseif type(v) == 'boolean' then
            if count < 1 and bagEquipped then
                Wait(1000) -- Add a delay before calling RemoveBag()
                RemoveBag()
            end
        end
    end
end)

-- Update the 'ped' variable when cached
lib.onCache('ped', function(value)
    ped = value
end)

-- Export the function to open the backpack
exports('openBackpack', function(data, slot)
    if not slot or not slot.metadata or not slot.metadata.identifier then
        local identifier = lib.callback.await('backpack:getNewIdentifier', 100, data.slot)
        ox_inventory:openInventory('stash', 'bag_'..identifier)
    else
        TriggerServerEvent('backpack:openBackpack', slot.metadata.identifier)
        ox_inventory:openInventory('stash', 'bag_'..slot.metadata.identifier)
    end
end)

-- Registering events
AddEventHandler("illenium-appearance:client:openClothingShopMenu", function(isPedMenu)
    if type(isPedMenu) == "table" then
        isPedMenu = false
    end
    OpenMenu(isPedMenu, "default")
end)

-- Event for reloading skin
AddEventHandler("illenium-appearance:client:reloadSkin", function(bypassChecks)
    if not bypassChecks and InCooldown() or Framework.CheckPlayerMeta() or cache.vehicle or IsPedFalling(cache.ped) then
        lib.notify({
            title = _L("commands.reloadskin.failure.title"),
            description = _L("commands.reloadskin.failure.description"),
            type = "error",
            position = Config.NotifyOptions.position
        })
        return
    end

    reloadSkinTimer = GetGameTimer()
    BackupPlayerStats()

    lib.callback("illenium-appearance:server:getAppearance", false, function(appearance)
        if not appearance then
            return
        end
        client.setPlayerAppearance(appearance)
        if Config.PersistUniforms then
            LoadPlayerUniform(bypassChecks)
        end
        RestorePlayerStats()
    end)
end)