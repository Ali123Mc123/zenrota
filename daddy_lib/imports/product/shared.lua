local product = {}

-- The resource a product id runs as, or nil while it is not started. Integrations ask by id, never by name.
function product.resource(id)
    local resource = (GlobalState['daddy_lib:products'] or {})[id]
    return resource and GetResourceState(resource) == 'started' and resource or nil
end

return product
