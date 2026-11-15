-- qb/qbx tables: characters (players) and owned vehicles (player_vehicles, from a garage or vehicle shop).
local players = {}
local has = DL.require('fw/schema')

local NAME = "CONCAT(JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')))"
local JOB = "JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) AS job, JSON_EXTRACT(job, '$.grade.level') AS grade"
local VEHICLE = 'SELECT UPPER(TRIM(plate)) AS plate, vehicle AS model, citizenid AS owner FROM player_vehicles'

function players.search(query, limit)
    local like = '%' .. query .. '%'
    return MySQL.query.await(('SELECT citizenid, %s AS name FROM players WHERE citizenid LIKE ? OR %s LIKE ? LIMIT ?'):format(NAME, NAME), { like, like, limit }) or {}
end

-- { citizenid, name, job, grade } of any character.
function players.find(citizenid)
    local row = MySQL.single.await(('SELECT citizenid, %s AS name, %s FROM players WHERE citizenid = ?'):format(NAME, JOB), { citizenid })
    if row then row.grade = tonumber(row.grade) or 0 end
    return row
end

function players.ownedVehicle(plate)
    if not has('player_vehicles') then return nil end
    return MySQL.single.await(VEHICLE .. ' WHERE UPPER(TRIM(plate)) = ? LIMIT 1', { plate })
end

function players.vehiclesOf(citizenid)
    if not has('player_vehicles') then return {} end
    return MySQL.query.await(VEHICLE .. ' WHERE citizenid = ? ORDER BY plate LIMIT 100', { citizenid }) or {}
end

function players.searchVehicles(text, limit, offset)
    if not has('player_vehicles') then return {}, 0 end
    local like = '%' .. text .. '%'
    local total = MySQL.scalar.await('SELECT COUNT(*) FROM player_vehicles WHERE plate LIKE ? OR vehicle LIKE ?', { like, like }) or 0
    return MySQL.query.await(VEHICLE .. ' WHERE plate LIKE ? OR vehicle LIKE ? ORDER BY plate LIMIT ? OFFSET ?', { like, like, limit, offset }) or {}, total
end

-- Grades keyed by number, whatever the framework stored: { [name] = { label, grades = { [0] = { name, payment, isboss } } } }.
function players.normalizeJobs(list)
    local out = {}
    for name, job in pairs(list or {}) do
        local grades = {}
        for level, grade in pairs(job.grades or {}) do
            grades[tonumber(level) or tonumber(grade.grade) or 0] = { name = grade.label or grade.name, payment = grade.payment or grade.salary, isboss = grade.isboss or grade.isBoss }
        end
        out[name] = { label = job.label, grades = grades }
    end
    return out
end

return players
