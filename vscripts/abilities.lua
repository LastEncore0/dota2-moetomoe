function redmodel( keys )

local caster = keys.caster
    

caster:AddAbility(starburststream)
caster:removeAbility(stareclipse)

caster:OnToggle(bluemodel)
caster:OnToggle(greenmodel)

end

function redmodelremove( keys )

local caster = keys.caster
    

caster:removeAbility(starburststream)

end