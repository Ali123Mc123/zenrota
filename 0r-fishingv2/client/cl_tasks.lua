local Tasks <const> = require 'config.tasks'

--------------------------------
--- THREADS
--------------------------------

CreateThread(function()
   NuiMessage('SET_TASKS', Tasks)
end)

--------------------------------
--- EVENTS
--------------------------------

RegisterNetEvent(Scriptname .. ':client:updateTasks', function(databaseTasks)
   if databaseTasks then
      for k, v in pairs(databaseTasks) do
         if Tasks[tonumber(k)] then
            Tasks[tonumber(k)].currentAmount = v
         end
      end

      NuiMessage('SET_TASKS', Tasks)
   end
end)

RegisterNetEvent(Scriptname .. ':client:updateTask', function(taskId)
   Tasks[taskId].currentAmount = Tasks[taskId].currentAmount + 1
   NuiMessage('SET_TASKS', Tasks)
end)

--------------------------------
--- NUI CALLBACKS
--------------------------------

RegisterNUICallback('SELECT_TASK', function(data, cb)
   lib.callback(Scriptname .. ':server:selectTask', false, function(res)
      cb(res)
   end, data.task)
end)