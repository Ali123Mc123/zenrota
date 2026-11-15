if Config.Framework ~= "qb" then
    return
end

while not QB do
    Wait(500)
    debugprint("Services: Waiting for QB to load")
end

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(jobInfo)
    local oldJob = PlayerData.job

    PlayerData.job = jobInfo

    TriggerEvent("lb-tablet:jobUpdated")

    if oldJob?.name ~= jobInfo.name or oldJob?.grade?.level ~= jobInfo.grade?.level then
        SendNUIAction("services:setCompany", GetCompanyData())
    else
        SendNUIAction("services:setDuty", jobInfo.onduty)
    end
end)

---@return string
function GetJob()
    return PlayerData.job?.name or "unemployed"
end

---@return boolean
function IsOnDuty()
    return PlayerData.job?.onduty
end

---@return number
function GetJobGrade()
    return PlayerData.job?.grade?.level or 0
end

function GetCompanyData()
    local jobData = {
        job = PlayerData.job?.name,
        jobLabel = PlayerData.job?.label,
        isBoss = PlayerData.job?.isboss,
        duty = PlayerData.job?.onduty,
        receiveCalls = GetCompanyCallsStatus and GetCompanyCallsStatus()
    }

    if not jobData.isBoss then
        return jobData
    end

    if GetResourceState("qb-management") ~= "started" then
        QB.Functions.TriggerCallback("qb-bossmenu:server:GetAccount", function(money)
            jobData.balance = money
        end, jobData.job)
    else
        jobData.balance = AwaitCallback("services:getAccount")
    end

    QB.Functions.TriggerCallback("qb-bossmenu:server:GetEmployees", function(employees)
        local onlineCitizenIds = AwaitCallback("services:getOnlineCitizenIds")

        for i = 1, #employees do
            local employee = employees[i]

            employees[i] = {
                name = employee.name,
                id = employee.empSource,

                gradeLabel = employee.grade.name,
                grade = employee.grade.level,

                canInteract = not employee.isboss,

                online = onlineCitizenIds[employee.empSource]
            }
        end

        jobData.employees = employees
    end, jobData.job)

    local timeout = GetGameTimer() + 2000

    while not jobData.balance or not jobData.employees do
        Wait(0)

        if GetGameTimer() > timeout then
            infoprint("error", "Failed to get company data (timed out after 2s)")
            print("balance: " .. tostring(jobData.balance))
            print("employees: " .. tostring(jobData.employees))

            jobData.employees = jobData.employees or {}
            jobData.balance = jobData.balance or 0
            break
        end
    end

    jobData.grades = {}

    for k, v in pairs(QB.Shared.Jobs[jobData.job].grades) do
        jobData.grades[#jobData.grades + 1] = {
            label = v.name,
            grade = tonumber(k)
        }
    end

    table.sort(jobData.grades, function(a, b)
        return a.grade < b.grade
    end)

    return jobData
end

function DepositMoney(amount)
    if GetResourceState("qb-management") == "started" then
        return AwaitCallback("services:addMoney", amount)
    end

    TriggerServerEvent("qb-bossmenu:server:depositMoney", amount)
    Wait(500) -- Wait for the server to update the balance

    local newBalancePromise = promise.new()

    QB.Functions.TriggerCallback("qb-bossmenu:server:GetAccount", function(balance)
        newBalancePromise:resolve(balance)
    end, GetJob())

    return Citizen.Await(newBalancePromise)
end

function WithdrawMoney(amount)
    if GetResourceState("qb-management") == "started" then
        return AwaitCallback("services:removeMoney", amount)
    end

    TriggerServerEvent("qb-bossmenu:server:withdrawMoney", amount)
    Wait(500) -- Wait for the server to update the balance

    local newBalancePromise = promise.new()

    QB.Functions.TriggerCallback("qb-bossmenu:server:GetAccount", function(balance)
        newBalancePromise:resolve(balance)
    end, GetJob())

    return Citizen.Await(newBalancePromise)
end

function HireEmployee(source)
    TriggerServerEvent("qb-bossmenu:server:HireEmployee", source)

    return AwaitCallback("services:getPlayerData", source)
end

function FireEmployee(citizenid)
    TriggerServerEvent("qb-bossmenu:server:FireEmployee", citizenid)

    return PlayerData.job?.isboss or false
end

function SetGrade(identifier, newGrade)
    local maxGrade = 0

    for grade, _ in pairs(QB.Shared.Jobs[GetJob()].grades) do
        grade = tonumber(grade)

        if grade and grade > maxGrade then
            maxGrade = grade
        end
    end

    if newGrade > maxGrade then
        return false
    end

    TriggerServerEvent("qb-bossmenu:server:GradeUpdate", {
        cid = identifier,
        grade = newGrade,
        gradename = QB.Shared.Jobs[GetJob()].grades[tostring(newGrade)].name
    })

    return true
end

function ToggleDuty()
    TriggerServerEvent("QBCore:ToggleDuty")
end
