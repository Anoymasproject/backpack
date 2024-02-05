local registeredStashes = {}
local ox_inventory = exports.ox_inventory

-- Generate a random string of uppercase letters excluding 'POL' and 'EMS'
local function GenerateText(num)
    local str
    repeat
        str = {}
        for i = 1, num do
            str[i] = string.char(math.random(65, 90))
        end
        str = table.concat(str)
    until str ~= 'POL' and str ~= 'EMS'
    return str
end

-- Generate a serial number for backpacks
local function GenerateSerial(text)
    if text and text:len() > 3 then
        return text
    end
    return ('%s%s%s'):format(math.random(100000, 999999), text == nil and GenerateText(3) or text, math.random(100000, 999999))
end

-- Event handler to open a backpack
RegisterServerEvent('backpack:openBackpack')
AddEventHandler('backpack:openBackpack', function(identifier)
    if not registeredStashes[identifier] then
        ox_inventory:RegisterStash('bag_' .. identifier, 'Backpack', Config.BackpackStorage.slots, Config.BackpackStorage.weight, false)
        registeredStashes[identifier] = true
    end
end)

-- Callback to get a new identifier for a backpack
lib.callback.register('backpack:getNewIdentifier', function(source, slot)
    local newId = GenerateSerial()
    ox_inventory:SetMetadata(source, slot, { identifier = newId })
    ox_inventory:RegisterStash('bag_' .. newId, 'Backpack', Config.BackpackStorage.slots, Config.BackpackStorage.weight, false)
    registeredStashes[newId] = true
    return newId
end)

-- Asynchronous task to wait for the 'ox_inventory' resource to start
CreateThread(function()
    while GetResourceState('ox_inventory') ~= 'started' do
        Wait(500)
    end

    -- Register hook for item swapping process
    local swapHook = ox_inventory:registerHook('swapItems', function(payload)
        local start, destination, move_type = payload.fromInventory, payload.toInventory, payload.toType
        local count_backpacks = ox_inventory:GetItem(payload.source, 'backpack', nil, true)

        if string.find(destination, 'bag_') then
            TriggerClientEvent('ox_lib:notify', payload.source, { type = 'error', title = Strings.action_incomplete, description = Strings.backpack_in_backpack })
            return false
        end

        if Config.OneBagInInventory then
            if count_backpacks > 0 and move_type == 'player' and destination ~= start then
                TriggerClientEvent('ox_lib:notify', payload.source, { type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
                return false
            end
        end

        return true
    end, {
        print = false,
        itemFilter = {
            backpack = true,
        },
    })

    -- Register hook for enforcing one backpack in the inventory rule
    local createHook
    if Config.OneBagInInventory then
        createHook = ox_inventory:registerHook('createItem', function(payload)
            local count_backpacks = ox_inventory:GetItem(payload.inventoryId, 'backpack', nil, true)
            local playerItems = ox_inventory:GetInventoryItems(payload.inventoryId)

            if count_backpacks > 0 then
                local slot = nil

                for _, item in pairs(playerItems) do
                    if item.name == 'backpack' then
                        slot = item.slot
                        break
                    end
                end

                Citizen.CreateThread(function()
                    local inventoryId = payload.inventoryId
                    local dontRemove = slot
                    Citizen.Wait(1000)

                    for _, item in pairs(ox_inventory:GetInventoryItems(inventoryId)) do
                        if item.name == 'backpack' and dontRemove ~= nil and item.slot ~= dontRemove then
                            local success = ox_inventory:RemoveItem(inventoryId, 'backpack', 1, nil, item.slot)
                            if success then
                                TriggerClientEvent('ox_lib:notify', inventoryId, { type = 'error', title = Strings.action_incomplete, description = Strings.one_backpack_only })
                            end
                            break
                        end
                    end
                end)
            end
        end, {
            print = false,
            itemFilter = {
                backpack = true
            }
        })
    end

    -- Event handler on resource stop to remove registered hooks
    AddEventHandler('onResourceStop', function()
        ox_inventory:removeHooks(swapHook)
        if Config.OneBagInInventory then
            ox_inventory:removeHooks(createHook)
        end
    end)
end)

