Config = {}

Config.checkForUpdates = true -- Check for updates?

Config.OneBagInInventory = true -- Allow only one bag in inventory?

Config.BackpackStorage = {
    slots = 15, -- Slots of backpack storage
    weight = 10000, -- Total weight for backpack
    Uniform = {
        Male = {
            ['bags_1'] = 82,
        },
        Female = {
            ['bags_1'] = 82,
        }
    },
}

Config.CleanUniform = {
    Male = {
        ['bags_1'] = 0
    },
    Female = {
        ['bags_1'] = 0
    }

}

Strings = { -- Notification strings
    action_incomplete = 'Action incomplète',
    one_backpack_only = 'Vous ne pouvez avoir que un sac à dos!',
    backpack_in_backpack = 'Vous ne pouvez pas placer un sac à dos dans un autre!',

}
