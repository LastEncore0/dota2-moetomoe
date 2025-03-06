
function healsteal (keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit
	local heal_steal = ability:GetLevelSpecialValueFor( "heal_steal", ability:GetLevel() - 1 )/100
	local targetheal = target:GetMaxHealth()
	local heal = targetheal * heal_steal
	
	caster:Heal(heal,caster)
end

function alucard_charm( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
	local time = ability:GetLevelSpecialValueFor("time", ability_level)
	local talent = ability:GetLevelSpecialValueFor("talent", ability_level)
	local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
	-- Initialize the tracking data
	print("time",time)
	ability.alucard_charm_unit_count = ability.alucard_charm_unit_count or 0
	ability.alucard_charm_table = ability.alucard_charm_table or {}
	if target:IsHero() then
		if caster:HasTalent("alucard_talent_1") then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_alucard_charm", {Duration = talent})
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_alucard_charm", {Duration = time})
		end 
	else
		print(target:GetUnitName())
		target:SetTeam(caster_team)
		target:SetOwner(caster)
		target:SetControllableByPlayer(player, true)
		target:GiveMana(target:GetMaxMana())

		ability.alucard_charm_unit_count = ability.alucard_charm_unit_count + 1
		table.insert(ability.alucard_charm_table, target)
	end

	if ability.alucard_charm_unit_count > max_units then
		ability.alucard_charm_table[1]:ForceKill(true) 
	end

end

function CurrencySoul( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit
	local maxStack = ability:GetLevelSpecialValueFor("blood_currency_souls", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_blood_currency_buff"
	local modifierStackName = "modifier_blood_currency_stack"
	local modifierName

	if target:IsHero() then
		caster.Soul_hero = target
	end

	if caster:HasTalent("alucard_talent_2") then
	maxStack = maxStack + ability:GetLevelSpecialValueFor("blood_currency_talent_souls", (ability:GetLevel() - 1))
	end
	print("maxStack =",maxStack)

	-- Always remove the stack modifier
	caster:RemoveModifierByName(modifierStackName) 

	-- Counts the current stacks
	for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	end

	-- Remove all the old buff modifiers
	for i = 0, currentStack do
		print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = currentStack + 1

		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	end
end

function alucarddeath( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierCount = caster:GetModifierCount()
	local modifierBuffName = "modifier_blood_currency_buff"
	local modifierStackName = "modifier_blood_currency_stack"
	local current_stack = caster:GetModifierStackCount( modifierStackName, ability )
	local soul_release = ability:GetLevelSpecialValueFor( "soul_release", ability:GetLevel() - 1 )
	local currentStack = 0
	local modifierName

    print("alucard death")
		-- 减半
	   current_stack = math.floor(current_stack * soul_release)
       print("current_stack",current_stack)
		caster:SetModifierStackCount(modifierStackName, ability, current_stack)

		for i = 1, current_stack do
		print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end
   for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
    end
	print("currentstack",currentStack)
    caster:SetModifierStackCount(modifierStackName, ability, currentStack)

end

function Reincarnation( event )
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local casterHP = caster:GetHealth()
	local casterMana = caster:GetMana()
	local abilityManaCost = ability:GetManaCost( ability:GetLevel() - 1 )
	local modifierCount = caster:GetModifierCount()
	local modifierBuffName = "modifier_blood_currency_buff"
	local modifierStackName = "modifier_blood_currency_stack"
	local current_stack = caster:GetModifierStackCount( modifierStackName, ability )
	local soul_release = ability:GetLevelSpecialValueFor( "soul_release", ability:GetLevel() - 1 )
	local Reincarnation = ability:GetLevelSpecialValueFor( "Reincarnation", ability:GetLevel() - 1 )
	local currentStack = 0
	local modifierName
    print("Reincarnate damage")
	-- Change it to your game needs
	local respawnTimeFormula = caster:GetLevel() * 4
	print("current_stack ",current_stack)
	print("Reincarnation ",Reincarnation)
	if casterHP == 0 and current_stack >= Reincarnation then
		print("Reincarnate")
		-- Variables for Reincarnation
		local reincarnate_time = ability:GetLevelSpecialValueFor( "reincarnate_time", ability:GetLevel() - 1 )
		local slow_radius = ability:GetLevelSpecialValueFor( "slow_radius", ability:GetLevel() - 1 )
		local casterGold = caster:GetGold()
		local respawnPosition = caster:GetAbsOrigin()

		current_stack = math.floor(current_stack * soul_release)
		print("current_stack",current_stack)
		 caster:SetModifierStackCount(modifierStackName, ability, current_stack)
 
		 for i = 1, current_stack do
		 print("Removing modifiers")
		 caster:RemoveModifierByName(modifierBuffName)
	 end
	for i = 0, modifierCount do
		 modifierName = caster:GetModifierNameByIndex(i)
 
		 if modifierName == modifierBuffName then
			 currentStack = currentStack + 1
		 end
	 end
	 print("currentstack",currentStack)
	 caster:SetModifierStackCount(modifierStackName, ability, currentStack)
		
		-- Start cooldown on the passive
		ability:StartCooldown(cooldown)

		-- Kill, counts as death for the player but doesn't count the kill for the killer unit
		caster:SetHealth(1)
		caster:Kill(caster, nil)
		-- Disable buyback.
		--caster:SetBuybackEnabled(false)
		-- Set the gold back
		caster:SetGold(casterGold, false)

		-- Set the short respawn time and respawn position
		caster:SetTimeUntilRespawn(reincarnate_time) 
		caster:SetRespawnPosition(respawnPosition) 

		-- Particle
		local particleName = "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf"
		caster.ReincarnateParticle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl(caster.ReincarnateParticle, 0, respawnPosition)
		ParticleManager:SetParticleControl(caster.ReincarnateParticle, 1, Vector(slow_radius,0,0))

		-- End Particle after reincarnating
		Timers:CreateTimer(reincarnate_time, function() 
			ParticleManager:DestroyParticle(caster.ReincarnateParticle, false)
			--caster:SetBuybackEnabled(true)
		end)

		-- Grave and rock particles
		-- The parent "particles/units/heroes/hero_skeletonking/skeleton_king_death.vpcf" misses the grave model
		local model = "models/props_gameplay/tombstoneb01.vmdl"
		local grave = Entities:CreateByClassname("prop_dynamic")
    	grave:SetModel(model)
    	grave:SetAbsOrigin(respawnPosition)

    	local particleName = "particles/units/heroes/hero_skeletonking/skeleton_king_death_bits.vpcf"
		local particle1 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
		ParticleManager:SetParticleControl(particle1, 0, respawnPosition)

		local particleName = "particles/units/heroes/hero_skeletonking/skeleton_king_death_dust.vpcf"
		local particle2 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl(particle2, 0, respawnPosition)

		local particleName = "particles/units/heroes/hero_skeletonking/skeleton_king_death_dust_reincarnate.vpcf"
		local particle3 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControl(particle3 , 0, respawnPosition)

    	-- End grave after reincarnating
    	Timers:CreateTimer(reincarnate_time, function() grave:RemoveSelf() end)		

		-- Sounds
		caster:EmitSound("Hero_SkeletonKing.Reincarnate")
		caster:EmitSound("Hero_SkeletonKing.Death")
		Timers:CreateTimer(reincarnate_time, function()
			caster:EmitSound("Hero_SkeletonKing.Reincarnate.Stinger")
		end)


	elseif casterHP == 0 then
		-- On Death without reincarnation, set the respawn time to the respawn time formula
		caster:SetTimeUntilRespawn(respawnTimeFormula)
	end	


end

function CallSoul( keys )
	local point = keys.target_points[1]
	local caster = keys.caster
	local ability = keys.ability
	local forwardV = caster:GetForwardVector()
	local player = caster:GetPlayerID()
	if caster.Soul_hero ~= nil then
		local hero_name = caster.Soul_hero:GetUnitName()
		local targetLevel = caster.Soul_hero:GetLevel()
		caster.call_hero = CreateUnitByName(hero_name, point, true, caster, nil, caster:GetTeamNumber())
		caster.call_hero:SetAbilityPoints(0)
		caster.call_hero:SetPlayerID(caster:GetPlayerID())
		caster.call_hero:SetForwardVector(forwardV)
		caster.call_hero:SetCanSellItems(false)

		caster.call_hero:SetControllableByPlayer(player, true)
		caster.call_hero:MakeIllusion()
		for i=1,targetLevel-1 do
				 caster.call_hero:HeroLevelUp(false)
			 end
			 for abilitySlot=0,15 do
				 local targetability = caster.Soul_hero:GetAbilityByIndex(abilitySlot)
				 if targetability ~= nil then 
					 local targetabilityLevel = targetability:GetLevel()
					 local targetabilityName = targetability:GetAbilityName()
					 local illusionAbility = caster.call_hero:FindAbilityByName(targetabilityName)
					 illusionAbility:SetLevel(targetabilityLevel)
				 end
			 end
		 
			 for itemSlot=0,5 do
				 local item = caster.Soul_hero:GetItemInSlot(itemSlot)
				 if item ~= nil then
					 local itemName = item:GetName()
					 local newItem = CreateItem(itemName, caster.call_hero, caster.call_hero)
					 caster.call_hero:AddItem(newItem)
				 end
			 end
		 caster.call_hero:AddNewModifier(caster, ability, "modifier_arc_warden_tempest_double", nil)
		 ability:ApplyDataDrivenModifier(caster, caster.call_hero, "modifier_call", {})
		 caster.Soul_hero = nil
			else
			ability:EndCooldown()
	end
	
end

function CallEnd( event )
    local caster = event.caster
	caster.call_hero:RemoveSelf()
end

