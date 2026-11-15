-- Polygon test on the ground plane, used by the zone tool on the client and by the checks on the server.
function Venue.inPolygon(poly, x, y)
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local a, b = poly[i], poly[j]
        if (a.y > y) ~= (b.y > y) and x < (b.x - a.x) * (y - a.y) / (b.y - a.y) + a.x then inside = not inside end
        j = i
    end
    return inside
end

function Venue.inPlace(place, x, y, z)
    return z >= place.minZ and z <= place.maxZ and Venue.inPolygon(place.poly, x, y)
end
