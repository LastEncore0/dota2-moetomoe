--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling levels up his Morph (Agility) ability.  Levels Morph (Strength) to match the new level,
	if Morph (Strength) exists.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_upgrade(keys)
	local morph_strength_ability = keys.caster:FindAbilityByName("alchemist_str")
	local morph_int_ability = keys.caster:FindAbilityByName("alchemist_int")
	local morph_agility_level = keys.ability:GetLevel()
	
	if morph_strength_ability ~= nil and morph_strength_ability:GetLevel() ~= morph_agility_level then
		morph_strength_ability:SetLevel(morph_agility_level)
	end
	if morph_int_ability ~= nil and morph_int_ability:GetLevel() ~= morph_agility_level then
		morph_int_ability:SetLevel(morph_agility_level)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling dies and has leveled Morph (Agility).  Untoggles Morph (Agility) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_owner_died(keys)
	if keys.ability:GetToggleState() == true then
		keys.ability:ToggleAbility()
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles on Morph (Agility).  Applies a modifier, starts a sound, and toggles off
	Morph (Strength) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_toggle_on(keys)
	local morph_strength_ability = keys.caster:FindAbilityByName("alchemist_str")
	local morph_int_ability = keys.caster:FindAbilityByName("alchemist_int")
	if morph_strength_ability ~= nil then
		if morph_strength_ability:GetToggleState() == true then
			morph_strength_ability:ToggleAbility()
		end
	end
	if morph_int_ability ~= nil then
		if morph_int_ability:GetToggleState() == true then
			morph_int_ability:ToggleAbility()
		end
	end
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_morphling_morph_agi_datadriven_toggled_on", {duration = -1})
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles off Morph (Agility).  Removes a modifier and stops a sound.
================================================================================================================= ]]
function morphling_morph_agi_datadriven_on_toggle_off(keys)
	keys.caster:RemoveModifierByName("modifier_morphling_morph_agi_datadriven_toggled_on")
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called at a regular interval while Morph (Agility) is toggled on.  Converts Strength into Agility, so long as
	Morphling has the required mana.
	Additional parameters: keys.PointsPerTick, keys.ManaCostPerSecond, and keys.ShiftRate
================================================================================================================= ]]
function modifier_morphling_morph_agi_datadriven_on_interval_think(keys)
	local mana_cost = keys.ManaCostPerSecond * keys.ShiftRate
	
	if keys.caster:IsRealHero() and keys.caster:GetMana() >= mana_cost then  --If Morphling has the required mana.
		if keys.caster:GetBaseAgility() >= keys.PointsPerTick then
		    if not keys.caster:HasTalent("edward_talent_1") then
			  keys.caster:SpendMana(mana_cost, keys.ability)  --Mana is not spent if Agility has bottomed out.
			end
			keys.caster:SetBaseAgility(keys.caster:GetBaseAgility() - keys.PointsPerTick)
			keys.caster:SetBaseStrength(keys.caster:GetBaseStrength() + keys.add)
			keys.caster:SetBaseIntellect(keys.caster:GetBaseIntellect() + keys.add)
			keys.caster:CalculateStatBonus(true)  --This is needed to update Morphling's maximum HP when his STR is changed, for example.
		end
	end
end

--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling levels up his Morph (Strength) ability.  Levels Morph (Agility) to match the new level,
	if Morph (Agility) exists.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_upgrade(keys)
	local morph_agility_ability = keys.caster:FindAbilityByName("alchemist_agi")
	local morph_int_ability = keys.caster:FindAbilityByName("alchemist_int")
	local morph_strength_level = keys.ability:GetLevel()
	
	if morph_agility_ability ~= nil and morph_agility_ability:GetLevel() ~= morph_strength_level then
		morph_agility_ability:SetLevel(morph_strength_level)
	end
	if morph_int_ability ~= nil and morph_int_ability:GetLevel() ~= morph_strength_level then
		morph_int_ability:SetLevel(morph_strength_level)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling dies and has leveled Morph (Strength).  Untoggles Morph (Strength) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_owner_died(keys)
	if keys.ability:GetToggleState() == true then
		keys.ability:ToggleAbility()
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles on Morph (Strength).  Applies a modifier, starts a sound, and toggles off
	Morph (Agility) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_toggle_on(keys)
	local morph_agility_ability = keys.caster:FindAbilityByName("alchemist_agi")
	local morph_int_ability = keys.caster:FindAbilityByName("alchemist_int")
	if morph_agility_ability ~= nil then
		if morph_agility_ability:GetToggleState() == true then
			morph_agility_ability:ToggleAbility()
		end
	end
	if morph_int_ability ~= nil then
		if morph_int_ability:GetToggleState() == true then
			morph_int_ability:ToggleAbility()
		end
	end
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_morphling_morph_str_datadriven_toggled_on", {duration = -1})
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles off Morph (Strength).  Removes a modifier and stops a sound.
================================================================================================================= ]]
function morphling_morph_str_datadriven_on_toggle_off(keys)
	keys.caster:RemoveModifierByName("modifier_morphling_morph_str_datadriven_toggled_on")
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called at a regular interval while Morph (Strength) is toggled on.  Converts Agility into Strength, so long as
	Morphling has the required mana.
	Additional parameters: keys.PointsPerTick, keys.ManaCostPerSecond, and keys.ShiftRate
================================================================================================================= ]]
function modifier_morphling_morph_str_datadriven_on_interval_think(keys)
	local mana_cost = keys.ManaCostPerSecond * keys.ShiftRate
	
	if keys.caster:IsRealHero() and keys.caster:GetMana() >= mana_cost then  --If Morphling has the required mana.
		if keys.caster:GetBaseStrength() >= keys.PointsPerTick then
			if not keys.caster:HasTalent("edward_talent_1") then
			  keys.caster:SpendMana(mana_cost, keys.ability)  --Mana is not spent if Agility has bottomed out.
			end
			keys.caster:SetBaseIntellect(keys.caster:GetBaseIntellect() + keys.add)
			keys.caster:SetBaseAgility(keys.caster:GetBaseAgility() + keys.add)
			keys.caster:SetBaseStrength(keys.caster:GetBaseStrength() - keys.PointsPerTick)
			keys.caster:CalculateStatBonus(true)  --This is needed to update Morphling's maximum HP when his STR is changed, for example.
		end
	end
end
--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling levels up his Morph (Strength) ability.  Levels Morph (Agility) to match the new level,
	if Morph (Agility) exists.
================================================================================================================= ]]
function morphling_morph_int_datadriven_on_upgrade(keys)
	local morph_agility_ability = keys.caster:FindAbilityByName("alchemist_agi")
	local morph_strength_ability = keys.caster:FindAbilityByName("alchemist_str")
	local morph_int_level = keys.ability:GetLevel()
	
	if morph_agility_ability ~= nil and morph_agility_ability:GetLevel() ~= morph_strength_level then
		morph_agility_ability:SetLevel(morph_int_level)
	end
	if morph_strength_ability ~= nil and morph_strength_ability:GetLevel() ~= morph_int_level then
		morph_strength_ability:SetLevel(morph_int_level)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling dies and has leveled Morph (Strength).  Untoggles Morph (Strength) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_int_datadriven_on_owner_died(keys)
	if keys.ability:GetToggleState() == true then
		keys.ability:ToggleAbility()
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles on Morph (Strength).  Applies a modifier, starts a sound, and toggles off
	Morph (Agility) if it is toggled on.
================================================================================================================= ]]
function morphling_morph_int_datadriven_on_toggle_on(keys)
	local morph_agility_ability = keys.caster:FindAbilityByName("alchemist_agi")
	local morph_str_ability = keys.caster:FindAbilityByName("alchemist_str")
	if morph_agility_ability ~= nil then
		if morph_agility_ability:GetToggleState() == true then
			morph_agility_ability:ToggleAbility()
		end
	end
	if morph_str_ability ~= nil then
		if morph_str_ability:GetToggleState() == true then
			morph_str_ability:ToggleAbility()
		end
	end
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_morphling_morph_int_datadriven_toggled_on", {duration = -1})
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called when Morphling toggles off Morph (Strength).  Removes a modifier and stops a sound.
================================================================================================================= ]]
function morphling_morph_int_datadriven_on_toggle_off(keys)
	keys.caster:RemoveModifierByName("modifier_morphling_morph_int_datadriven_toggled_on")
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called at a regular interval while Morph (Strength) is toggled on.  Converts Agility into Strength, so long as
	Morphling has the required mana.
	Additional parameters: keys.PointsPerTick, keys.ManaCostPerSecond, and keys.ShiftRate
================================================================================================================= ]]
function modifier_morphling_morph_int_datadriven_on_interval_think(keys)
	local mana_cost = keys.ManaCostPerSecond * keys.ShiftRate
	
	if keys.caster:IsRealHero() and keys.caster:GetMana() >= mana_cost then  --If Morphling has the required mana.
		if keys.caster:GetBaseIntellect() >= keys.PointsPerTick then
			if not keys.caster:HasTalent("edward_talent_1") then
			  keys.caster:SpendMana(mana_cost, keys.ability)  --Mana is not spent if Agility has bottomed out.
			end
			keys.caster:SetBaseStrength(keys.caster:GetBaseStrength() + keys.add)
			keys.caster:SetBaseAgility(keys.caster:GetBaseAgility() + keys.add)
			keys.caster:SetBaseIntellect(keys.caster:GetBaseIntellect() - keys.PointsPerTick)
			keys.caster:CalculateStatBonus(true) --This is needed to update Morphling's maximum HP when his STR is changed, for example.
		end
	end
end

function edwardattack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifie = keys.modifie
	local Strength = caster:GetStrength()
	local Agility = caster:GetAgility()
	local Intellect = caster:GetIntellect()
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	local time = ability:GetLevelSpecialValueFor("time", (ability:GetLevel() -1))
	print("time =",time)
	if Strength >= Intellect and Strength >= Agility then
	target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end
	if Agility >= Intellect and Agility >= Strength then
	ability:ApplyDataDrivenModifier( caster, target, modifie, { Duration = time } )
	print("modifie =",modifie)
	end
	if Intellect >= Strength and Intellect >= Agility then
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	end
end

function PrimalSplit( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1 )
	local level = ability:GetLevel()
	local heal = ability:GetLevelSpecialValueFor( "heal" , ability:GetLevel() - 1 )
	local levelup = ability:GetLevel() - 1
    local levelup = ability:GetLevel() - 1
	local Strength = caster:GetStrength()
	local Agility = caster:GetAgility()
	local Intellect = caster:GetIntellect()
	--[[ Ability variables
	 local edward_tower_damage = ability:GetLevelSpecialValueFor("edward_tower_damage", levelup) 
	 local edward_tower_hp = ability:GetLevelSpecialValueFor("edward_tower_hp", levelup) 
	local edward_tower_armor = ability:GetLevelSpecialValueFor("edward_tower_armor", levelup) 
	local sedward_tower_attack_range = ability:GetLevelSpecialValueFor("sedward_tower_range", levelup) 
	 local edward_tower_mana = ability:GetLevelSpecialValueFor("edward_tower_mana", levelup) 
	 local edward_tower_duration = ability:GetLevelSpecialValueFor("edward_tower_duration", levelup) 
	 local edward_tower_count_quas = ability:GetLevelSpecialValueFor("edward_tower_count", levelup)
	local edward_tower_count_exort = ability:GetLevelSpecialValueFor("edward_tower_count", levelup)
]]

	-- Set the unit names to create,concatenated with the level number

	-- STORM
	local unit_name = event.unit_name_storm
 

	-- Set the positions
	local forwardV = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    local distance = 100
	local ang_right = QAngle(0, -90, 0)
    local ang_left = QAngle(0, 90, 0)
	local model = event.model

    local origin = caster:GetAbsOrigin() + RandomVector(100)
	-- Create the units
	edward_tower = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
    edward_tower:SetOwner(caster)
	-- 
	-- Set the health of this entity.
	
	-- Make them controllable
	edward_tower:SetControllableByPlayer(player, true)

	-- Set all of them looking at the same point as the caster
	edward_tower:SetForwardVector(forwardV)

	edward_tower:SetOriginalModel(model)
	edward_tower:SetCanSellItems(false)
	edward_tower:MakeIllusion()
	if caster:HasTalent("edward_talent_2") then
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, edward_tower, edward_tower)
				edward_tower:AddItem(newItem)
			end
		end
		edward_tower:AddNewModifier(caster, ability, "modifier_arc_warden_tempest_double", nil)
	end
    if Strength > Intellect and Strength > Agility then
	ability:ApplyDataDrivenModifier( caster, edward_tower, event.modifie1, { Duration = duration } )
	end
	if Agility > Intellect and Agility > Strength then
	ability:ApplyDataDrivenModifier( caster, edward_tower, event.modifie2, { Duration = duration } )
	end
	if Intellect > Strength and Intellect > Agility then
	ability:ApplyDataDrivenModifier( caster, edward_tower, event.modifie3, { Duration = duration } )
	end
	-- Sets the maximum base damage.
	-- 

    -- edward_tower:MakeIllusion()
    
	-- Set the mana on this unit.(edward_tower_hp)

	-- Ultimate Scepter rule: 
	-- If the caster has it, summoned units get all their abilities
	--if caster:HasScepter() then
	--LearnAllAbilities(edward_tower, level)
	--else	
	-- If the item is not found, do not skill these abilities:

		--local storm_scepter_ability = "brewmaster_drunken_haze"
		--LearnAllAbilitiesExcluding(edward_tower, 1, storm_scepter_ability)

	--end	



	-- Set the Earth unit as the primary active of the split (the hero will be periodically moved to the ActiveSplit location)
	--caster.ActiveSplit = caster.Earth

	-- Hide the hero underground
	--local underground_position = Vector(origin.x, origin.y, origin.z - 322)
	--caster:SetAbsOrigin(underground_position)

end

function LearnAllAbilities( unit, level )

	for i=0,15 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(level)
			print("Set Level "..level.." on "..ability:GetAbilityName())
		end
	end
end

-- When the spell ends, the Brewmaster takes Earth's place. 
-- If Earth is dead he takes Storm's place, and if Storm is dead he takes Fire's place.
function SplitUnitDied( event )
	local caster = event.caster
	local attacker = event.attacker
	local unit = event.unit

	-- Chech which spirits are still alive
	if IsValidEntity(caster.Earth) and caster.Earth:IsAlive() then
		caster.ActiveSplit = caster.Earth
	elseif IsValidEntity(edward_tower) and edward_tower:IsAlive() then
		caster.ActiveSplit = edward_tower
	elseif IsValidEntity(caster.Fire) and caster.Fire:IsAlive() then
		caster.ActiveSplit = caster.Fire
	else
		-- Check if they died because the spell ended, or where killed by an attacker
		-- If the attacker is the same as the unit, it means the summon duration is over.
		if attacker == unit then
			print("Primal Split End Succesfully")
		elseif attacker ~= unit then
			-- Kill the caster with credit to the attacker.
			caster:Kill(nil, attacker)
			caster.ActiveSplit = nil
		end
	end

	if caster.ActiveSplit then
		print(caster.ActiveSplit:GetUnitName() .. " is active now")
	else
		print("All Split Units were killed!")
	end

end

-- While the main spirit is alive, reposition the hero to its position so that auras are carried over.
-- This will also help finding the current Active primal split unit with the hero hotkey
function PrimalSplitAuraMove( event )
	-- Hide the hero underground on the Active Split position
	local caster = event.caster
	local active_split_position = caster.ActiveSplit:GetAbsOrigin()
	local underground_position = Vector(active_split_position.x, active_split_position.y, active_split_position.z - 322)
	caster:SetAbsOrigin(underground_position)

end

-- Ends the the ability, repositioning the hero on the latest active split unit
function PrimalSplitEnd( event )
    local caster = event.caster
	edward_tower:RemoveSelf()
end

