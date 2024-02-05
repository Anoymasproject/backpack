local bagEquipped = false  -- Use false instead of nil to initialize the variable
local ox_inventory = exports.ox_inventory
local ped = cache.ped
local justConnect = true

-- Function to equip the backpack
local function PutOnBag()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformConfig = skin.sex == 0 and Config.BackpackStorage.Uniform.Male or Config.BackpackStorage.Uniform.Female
        TriggerEvent('skinchanger:loadClothes', skin, uniformConfig)
        saveSkin()
    end)
    bagEquipped = true
end

-- Function to save the current outfit
local saveSkin = function()
    Wait(100)
    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('ox_backpack:save', skin)
    end)
end

-- Function to remove the backpack
local function RemoveBag()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local clothesWithoutBag = skin.sex == 0 and Config.CleanUniform.Male or Config.CleanUniform.Female
        TriggerEvent('skinchanger:loadClothes', skin, clothesWithoutBag)
        saveSkin()
        bagEquipped = false  -- Use false instead of nil to indicate the backpack is not equipped
    end)
end

-- Handler to update the inventory
AddEventHandler('ox_inventory:updateInventory', function(changes)
    if justConnect then
        Wait(4500)
        justConnect = false  -- Use false instead of nil after the first connection
    end

    for k, v in pairs(changes) do
        local count = ox_inventory:Search('count', 'backpack')

        if type(v) == 'table' then
            if count > 0 and (not bagEquipped) then
                PutOnBag()
            elseif count < 1 and bagEquipped then
                RemoveBag()
            end
        elseif type(v) == 'boolean' then
            if count < 1 and bagEquipped then
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