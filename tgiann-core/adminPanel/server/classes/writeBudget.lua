-- tgiann-core admin lib: how many writes an admin may send in a time window.

---@class AdminPanelWriteBudget : OxClass
---@field limit number writes per window
---@field window number seconds
---@field budgets table<number, { count: number, resetAt: number }>
AdminPanelWriteBudget = lib.class("AdminPanelWriteBudget")

---@param limit number
---@param window number
function AdminPanelWriteBudget:constructor(limit, window)
    self.limit = limit
    self.window = window
    self.budgets = {}
end

---Counts one write; false when the admin is over the limit.
---@param src number
---@return boolean
function AdminPanelWriteBudget:take(src)
    local now = os.time()
    local b = self.budgets[src]
    if not b or b.resetAt <= now then
        b = { count = 0, resetAt = now + self.window }
        self.budgets[src] = b
    end
    b.count = b.count + 1
    return b.count <= self.limit
end

---@param src number
function AdminPanelWriteBudget:forget(src)
    self.budgets[src] = nil
end
