-- tgiann-core admin lib: requests to the server that wait for an answer by id (patch uploads).

---@class AdminPanelRequests : OxClass
---@field lastId number
---@field timeout number ms until a request answers itself with ADMIN_ERR_TIMEOUT
---@field pending table<number, table> id -> promise
AdminPanelRequests = lib.class("AdminPanelRequests")

---@param timeout number
function AdminPanelRequests:constructor(timeout)
    self.lastId = 0
    self.timeout = timeout
    self.pending = {}
end

---Sends with a new id and waits for its answer.
---@param sendFn fun(id: number)
---@return { ok: boolean, errKey?: string }
function AdminPanelRequests:send(sendFn)
    self.lastId = self.lastId + 1
    local id = self.lastId
    local p = promise.new()
    self.pending[id] = p
    SetTimeout(self.timeout, function()
        self:resolve(id, { ok = false, errKey = "ADMIN_ERR_TIMEOUT" })
    end)
    sendFn(id)
    return Citizen.Await(p)
end

---@param id number
---@param result { ok: boolean, errKey?: string }
function AdminPanelRequests:resolve(id, result)
    local p = self.pending[id]
    if not p then return end
    self.pending[id] = nil
    p:resolve(result)
end
