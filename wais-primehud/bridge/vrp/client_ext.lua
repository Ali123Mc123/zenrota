local WaisPrimeHud = class("WaisPrimeHud", vRP.Extension)

function WaisPrimeHud:__construct()
    vRP.Extension.__construct(self)
end

WaisPrimeHud.event = {}

function WaisPrimeHud.event:playerComaState(coma)
    TriggerEvent('wais:primehud:client:setDead', coma == true)
end

function WaisPrimeHud.event:playerDeath()
    TriggerEvent('wais:primehud:client:setDead', true)
end

function WaisPrimeHud.event:playerSpawn()
    TriggerEvent('wais:primehud:client:setDead', false)
end

vRP:registerExtension(WaisPrimeHud)
