local KGCore = exports['kg-core']:GetCoreObject()

-- Functions

local function IncreasePlayerXP(source, xpGain, xpType)
    local Player = KGCore.Functions.GetPlayer(source)
    if Player then
        local currentXP = Player.Functions.GetRep(xpType)
        local newXP = currentXP + xpGain
        Player.Functions.AddRep(xpType, newXP)
        TriggerClientEvent('KGCore:Notify', source, string.format(Lang:t('notifications.xpGain'), xpGain, xpType), 'success')
    end
end

-- Callbacks

KGCore.Functions.CreateCallback('crafting:getPlayerInventory', function(source, cb)
    local player = KGCore.Functions.GetPlayer(source)
    if player then
        cb(player.PlayerData.items)
    else
        cb({})
    end
end)

-- Events
RegisterServerEvent('kg-crafting:server:removeMaterials', function(itemName, amount)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if Player then
        exports['kg-inventory']:RemoveItem(src, itemName, amount, false, 'kg-crafting:server:removeMaterials')
        TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[itemName], 'remove')
    end
end)

RegisterNetEvent('kg-crafting:server:removeCraftingTable', function(benchType)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if not Player then return end
    exports['kg-inventory']:RemoveItem(src, benchType, 1, false, 'kg-crafting:server:removeCraftingTable')
    TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[benchType], 'remove')
    TriggerClientEvent('KGCore:Notify', src, Lang:t('notifications.tablePlace'), 'success')
end)

RegisterNetEvent('kg-crafting:server:addCraftingTable', function(benchType)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if not Player then return end
    if not exports['kg-inventory']:AddItem(src, benchType, 1, false, false, 'kg-crafting:server:addCraftingTable') then return end
    TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[benchType], 'add')
end)

RegisterNetEvent('kg-crafting:server:receiveItem', function(craftedItem, requiredItems, amountToCraft, xpGain, xpType)
    local src = source
    local Player = KGCore.Functions.GetPlayer(src)
    if not Player then return end
    local canGive = true
    for _, requiredItem in ipairs(requiredItems) do
        if not exports['kg-inventory']:RemoveItem(src, requiredItem.item, requiredItem.amount, false, 'kg-crafting:server:receiveItem') then
            canGive = false
            return
        end
        TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[requiredItem.item], 'remove')
    end
    if canGive then
        if not exports['kg-inventory']:AddItem(src, craftedItem, amountToCraft, false, false, 'kg-crafting:server:receiveItem') then return end
        TriggerClientEvent('kg-inventory:client:ItemBox', src, KGCore.Shared.Items[craftedItem], 'add')
        TriggerClientEvent('KGCore:Notify', src, string.format(Lang:t('notifications.craftMessage'), KGCore.Shared.Items[craftedItem].label), 'success')
        IncreasePlayerXP(src, xpGain, xpType)
    end
end)

-- Items

for benchType, _ in pairs(Config) do
    KGCore.Functions.CreateUseableItem(benchType, function(source)
        TriggerClientEvent('kg-crafting:client:useCraftingTable', source, benchType)
    end)
end
