-- CreateThread(function()
--     local wasStunned = false

--     while true do
--         if IsPedBeingStunned(cache.ped, 0) then
--             if not wasStunned then
--                 wasStunned = true
--                 LocalPlayer.state:set('isTazed', true, true)
--                 SetPedMinGroundTimeForStungun(cache.ped, math.random(4000, 7000))
--             end

--             Wait(0)
--         else
--             if wasStunned then
--                 wasStunned = false

--                 Wait(3000)

--                 if not IsPedBeingStunned(cache.ped, 0) then
--                     LocalPlayer.state:set('isTazed', false, true)
--                 end
--             else
--                 Wait(1000)
--             end
--         end
--     end
-- end)
