function mogic(keys)
    local caster = keys.caster
	local ability = keys.ability
    local mogicfier = keys.mogicfier
	local castOrg = caster:GetAbsOrigin()
	local enemyin = false
    local split_XP = ability:GetLevelSpecialValueFor("split_XP", (ability:GetLevel() -1))
    local range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() -1))
    local minlife = ability:GetLevelSpecialValueFor("minlife", (ability:GetLevel() -1))
    local givelife = ability:GetLevelSpecialValueFor("givelife", (ability:GetLevel() -1))
	local units = FindUnitsInRadius(caster:GetTeam() , castOrg, nil, 1600, DOTA_UNIT_TARGET_TEAM_BOTH , DOTA_UNIT_TARGET_HERO, 0, 0, false)
    if elder_life == nil then
       caster:SetHealth( minlife )
       elder_life = true
    end

	for _,unit in pairs(units) do
				local dist = (unit:GetAbsOrigin()-castOrg):Length2D()
					if dist < range  then
                    unit:SetHealth( unit:GetHealth() - 1 )
                    unit:AddExperience(split_XP, false, false)
					ability:ApplyDataDrivenModifier( caster, caster, mogicfier, {} )				
					end
			end
   if caster:GetHealth() >= givelife then
     --[[
       local pos = caster: GetOrigin() + RandomVector(100)
	print("pos =",pos)
    -- if itm ~= nil then
       roshan = CreateUnitByName("npc_dota_roshan", pos, true, caster, nil, caster:GetTeamNumber())
       roshan:AddItemByName("item_aegis")
       elder_life = nil
       ]]
    end		
end