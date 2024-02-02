local bagEquipped, skin
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local justConnect = true


local function PutOnBag()
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
            TriggerEvent('skinchanger:loadClothes', skin, Config.BackpackStorage.Uniform.Male)
        else
            TriggerEvent('skinchanger:loadClothes', skin, Config.BackpackStorage.Uniform.Female)
        end
        saveSkin()
    end)
    bagEquipped = true
end

saveSkin = function()
    Wait(100)

    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('backpack:save', skin)
    end)
end

local function RemoveBag()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local clothesWithoutBag
        if skin.sex == 0 then
            clothesWithoutBag = Config.CleanUniform.Male
        else
            clothesWithoutBag = Config.CleanUniform.Female
        end
        TriggerEvent('skinchanger:loadClothes', skin, clothesWithoutBag)
        saveSkin()
        bagEquipped = nil
    end)
end

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if justConnect then
        Wait(4500)
        justConnect = nil
    end
    for k, v in pairs(changes) do
        if type(v) == 'table' then
            local count = ox_inventory:Search('count', 'backpack')
	        if count > 0 and (not bagEquipped) then
                PutOnBag()
            elseif count < 1 and bagEquipped then
                RemoveBag()
            end
        end
        if type(v) == 'boolean' then
            local count = ox_inventory:Search('count', 'backpack')
            if count < 1 and bagEquipped then
                RemoveBag()
            end
        end
    end
end)

lib.onCache('ped', function(value)
    ped = value
end)

exports('openBackpack', function(data, slot)
    if not slot?.metadata?.identifier then
        local identifier = lib.callback.await('backpack:getNewIdentifier', 100, data.slot)
        ox_inventory:openInventory('stash', 'bag_'..identifier)
    else
        TriggerServerEvent('backpack:openBackpack', slot.metadata.identifier)
        ox_inventory:openInventory('stash', 'bag_'..slot.metadata.identifier)
    end
end)

