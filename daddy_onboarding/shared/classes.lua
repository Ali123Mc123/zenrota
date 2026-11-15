-- The six classes in their fixed order (the last tie-break). Names match daddycl_classes in College; texts are in
-- locales (classes.<key>).
Classes = {
    { name = 'Valiant', key = 'valiant', color = '#E63946' },
    { name = 'Orion', key = 'orion', color = '#F4B400' },
    { name = 'Eclipse', key = 'eclipse', color = '#2A9D4B' },
    { name = 'Zenith', key = 'zenith', color = '#1D7FE0' },
    { name = 'Nexus', key = 'nexus', color = '#CFD8DC' },
    { name = 'Apex', key = 'apex', color = '#8E44AD' },
}

ClassByName = {}
for index, class in ipairs(Classes) do
    class.order = index
    ClassByName[class.name] = class
end
