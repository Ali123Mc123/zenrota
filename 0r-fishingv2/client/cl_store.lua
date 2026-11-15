--------------------------------
--- NUI CALLBACKS
--------------------------------

RegisterNUICallback('BUY_ITEMS', function(data, cb)
   lib.callback(Scriptname .. ':server:buyItems', false, function(res)
      cb(res)
   end, data)
end)

RegisterNUICallback('SELL_ITEMS', function(data, cb)
   lib.callback(Scriptname .. ':server:sellItems', false, function(res)
      cb(res)
   end, data)
end)

RegisterNUICallback('SELL_ALL_ITEMS', function(data, cb)
   lib.callback(Scriptname .. ':server:sellAllItems', false, function(res)
      cb(res)
   end)
end)