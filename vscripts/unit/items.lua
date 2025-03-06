--[[
	Author: Ractidous, with help from Noya
	Date: 03.02.2015.
	Initialize the slowed units list, and let the caster latch.
	We also need to track the health/mana, in order to grab amount gained of health/mana in the future.
]]
function dominator( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
	local target	= event.target
	local ability	= event.ability
	local damage_math = ability:GetLevelSpecialValueFor("damage_math", (ability:GetLevel() -1)) / 100
	local damage    = target:GetMaxHealth() * damage_math
	local target_kill	= PlayerResource:GetKills(target:GetOwner():GetPlayerID())
	local caster_kill	= PlayerResource:GetKills(caster:GetOwner():GetPlayerID())
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	print("target_kill =",target_kill)
	print("caster_kill =",caster_kill)
	print("damage =",damage)
	local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = damage
    if target_kill >= caster_kill   then
     ApplyDamage(damage_table)
	else
    target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
	end
end

function holybei( keys )
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
	local mutimana = ability:GetLevelSpecialValueFor("mutimana", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_holy_buff"
	local modifierStackName = "modifier_item_holy_buff_stacks"
	local modifierName
    local manaCount = caster:GetMana()/mutimana
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
		-- print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
	if manaCount >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)

		-- Apply the new refreshed stack
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	else
		-- Increase the number of stacks
		currentStack = manaCount

		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

		-- Apply the new increased stack
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_holy_buff", {})
			 print("Apply modifiers")
		end
	end
end

function noholybei( keys )
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("max_stacks", (ability:GetLevel() - 1))
	local mutimana = ability:GetLevelSpecialValueFor("mutimana", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_holy_buff"
	local modifierStackName = "modifier_item_holy_buff_stacks"
	local modifierName
    local manaCount = caster:GetMana()/mutimana
	--print("manaCount =",manaCount)
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
		-- print("Removing modifiers")
		caster:RemoveModifierByName(modifierBuffName)
	end
end

--[[ ============================================================================================================
	炼金术手套
================================================================================================================= ]]
function item_hand_of_midas_datadriven_on_spell_start(keys)
	local caster = keys.caster
	if caster.costmana ~= nil then
	keys.caster:ModifyGold(caster.costmana, true, 0)  --Give the player a flat amount of reliable gold.
	keys.caster:AddExperience(keys.target:GetDeathXP() * keys.XPMultiplier, false, false)  --Give the player some XP.
	end
	
	--Start the particle and sound.
	keys.target:EmitSound("DOTA_Item.Hand_Of_Midas")
	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)	
	ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), false)
    caster.costmana = 0
	--Remove default gold/XP on the creep before killing it so the caster does not receive anything more.
	--keys.target:SetDeathXP(0)
	--keys.target:SetMinimumGoldBounty(0)
	--keys.target:SetMaximumGoldBounty(0)
	keys.target:Kill(keys.ability, keys.caster) --Kill the creep.  This increments the caster's last hit counter.
end

function manacal(keys)
  local caster = keys.caster
  local mana = caster:GetMana()
  local ability = keys.ability
  local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", (ability:GetLevel() - 1))

  if caster.oldmana == nil then
	caster.oldmana = mana
  elseif not caster:HasModifier("modifier_fountain_aura_buff") then
	local manacost = caster.oldmana - mana
	caster.oldmana = mana
	if manacost > 0 then
	  if caster.costmana == nil then
		caster.costmana = manacost
	  else 
		caster.costmana = caster.costmana + manacost
		if caster.costmana > bonus_gold then
			ability:EndCooldown()
			-- Clear the cooldown remaining on this ability.
		end
	  end
	end
	

end

end


  