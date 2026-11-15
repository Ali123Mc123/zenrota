Venue.Permissions = {
    'dashboard.view',
    'orders.view', 'orders.manage', 'billing.view', 'billing.manage',
    'menu.view', 'menu.manage',
    'staff.view', 'staff.manage', 'staff.fire',
    'stock.view', 'stock.manage',
    'finance.view', 'finance.manage', 'finance.withdraw',
    'property.view', 'property.manage', 'property.build',
    'kitchen.view', 'kitchen.manage',
    'delivery.view', 'delivery.manage',
    'promo.manage',
    'settings.manage',
}

Venue.PermissionSet = Venue.set(Venue.Permissions)

Venue.Roles = {
    manager = {
        label = 'Müdür', rank = 80,
        permissions = {
            'dashboard.view', 'orders.view', 'orders.manage', 'billing.view', 'billing.manage', 'menu.view', 'menu.manage', 'staff.view', 'staff.manage',
            'stock.view', 'stock.manage', 'finance.view', 'kitchen.view', 'kitchen.manage', 'delivery.view', 'delivery.manage', 'promo.manage',
        },
    },
    chef = {
        label = 'Şef', rank = 50,
        permissions = { 'dashboard.view', 'orders.view', 'orders.manage', 'menu.view', 'stock.view', 'stock.manage', 'kitchen.view', 'kitchen.manage' },
    },
    cook = {
        label = 'Aşçı', rank = 30,
        permissions = { 'orders.view', 'orders.manage', 'menu.view', 'stock.view', 'kitchen.view' },
    },
    cashier = {
        label = 'Kasiyer', rank = 30,
        permissions = { 'orders.view', 'orders.manage', 'billing.view', 'menu.view' },
    },
    waiter = {
        label = 'Garson', rank = 20,
        permissions = { 'orders.view', 'orders.manage', 'billing.view', 'menu.view' },
    },
    courier = {
        label = 'Kurye', rank = 10,
        permissions = { 'orders.view', 'delivery.view' },
    },
}

Venue.OwnerRole = { id = 'owner', label = 'Sahip', rank = 100 }

function Venue.roleLabel(id)
    if id == Venue.OwnerRole.id then return Venue.OwnerRole.label end
    return Venue.Roles[id] and Venue.Roles[id].label or id
end

function Venue.rolePermissions(id)
    local role = Venue.Roles[id]
    return role and role.permissions or {}
end

function Venue.roleRank(id)
    if id == Venue.OwnerRole.id then return Venue.OwnerRole.rank end
    return Venue.Roles[id] and Venue.Roles[id].rank or 0
end
