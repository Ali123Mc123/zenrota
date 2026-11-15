return {
   MaskModel = `p_d_scuba_mask_s`, -- Change this to the model of the mask
   TankModel = `p_s_scuba_tank_s`, -- Change this to the model of the tank

   GearAnimation = {
      dict = 'clothingshirt', -- Change this to the dictionary of the gear animation
      anim = 'try_shirt_positive_d' -- Change this to the animation of the gear animation
   },

   OxygenLevel = 200, -- Change this to the oxygen level of the diving gear
   RemoveDivingGear = true, -- Change this to true if you want to remove the diving gear when the oxygen level is 0

   Cloths = {
      [`mp_m_freemode_01`] = {
         mask = {
            item = 0, -- Change this to the item of the mask
            texture = 0, -- Change this to the texture of the mask
            componentId = 1 -- !! DO NOT CHANGE THIS !!
         },
         arms = { item = 1, texture = 0, componentId = 3 }, -- eller
         shirt = { item = 299, texture = 0, componentId = 8 }, -- gömlek
         jacket = { item = 1977, texture = 0, componentId = 11 }, -- üstler
         pants = { item = 916, texture = 0, componentId = 4 }, -- alt beden
         shoes = { item = 306, texture = 0, componentId = 6 }, -- ayakkabı
         accessories = { item = 0, texture = 0, componentId = 7 },
         bodyArmor = { item = 0, texture = 0, componentId = 9 }, -- vücut zırhı
         decals = { item = 0, texture = 0, componentId = 10 }, -- arma
      },
      [`mp_f_freemode_01`] = {
         mask = { item = 0, texture = 0, componentId = 1 },
         arms = { item = 30, texture = 0, componentId = 3 }, -- eller
         shirt = { item = 1245, texture = 0, componentId = 8 }, -- gömlek
         jacket = { item = 2306, texture = 0, componentId = 11 }, -- üstler
         pants = { item = 313, texture = 0, componentId = 4 }, -- alt beden
         shoes = { item = 442, texture = 20, componentId = 6 }, -- ayakkabı
         accessories = { item = 0, texture = 0, componentId = 7 },
         bodyArmor = { item = 0, texture = 0, componentId = 9 }, -- vücut zırhı
         decals = { item = 0, texture = 0, componentId = 10 }, -- arma
      },
   }
}