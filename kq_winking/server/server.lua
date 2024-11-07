-- Simple event to synchronise the winking. When running this script on very large servers you may want to switch to state bags.
RegisterServerEvent('kq_winking:server:wink')
AddEventHandler('kq_winking:server:wink', function(netId, side)
    TriggerClientEvent('kq_winking:client:wink', -1, netId, side)
end)
