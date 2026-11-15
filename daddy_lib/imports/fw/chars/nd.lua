-- ND_Core is not supported yet: the standalone stub with its own warning.
local stub = DL.require('fw/chars/standalone')

stub.server.conflicts = function()
    return { { level = 'warn', code = 'unsupported', text = 'ND_Core characters are not supported yet, so there are no characters to list or create' } }
end

return stub
