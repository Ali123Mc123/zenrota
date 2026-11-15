local configServer = require 'config.config_s'

---@class ServerState
local State = {
    machinesInUse = {},
    machineObjects = {}
}

---@param machine string
---@param index number|string
---@param source Source?
function State.setMachineInUse(machine, index, source)
    State.machinesInUse[machine] = State.machinesInUse[machine] or {}
    State.machinesInUse[machine][index] = source

    if source then
        lib.print.debug(string.format("Machine %s[%s] now in use by player %d", machine, tostring(index), source))
    else
        lib.print.debug(string.format("Machine %s[%s] freed", machine, tostring(index)))
    end
end

---@param machine string
---@param index number
---@return Source?
function State.getMachineUser(machine, index)
    if not State.machinesInUse[machine] then return nil end
    return State.machinesInUse[machine][index]
end

---@param source Source
---@param data table
function State.setMachineObject(source, data)
    State.machineObjects[source] = data
end

---@param source Source
---@return table?
function State.getMachineObject(source)
    return State.machineObjects[source]
end

---@param source Source
function State.removeMachineObject(source)
    State.machineObjects[source] = nil
end

return State
