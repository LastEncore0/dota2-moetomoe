--[[
	Author: Noya
	Date: 9.1.2015.
	Plays a looping and stops after the duration
]]
function AcidSpraySound( event )
	local target = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

	target:EmitSound("Hero_Sniper.ShrapnelShatter")

	-- Stops the sound after the duration, a bit early to ensure the thinker still exists
	Timers:CreateTimer(duration-0.1, function() 
		target:StopSound("Hero_Sniper.ShrapnelShatter") 
	end)

end

function madokarule( event )
	local caster = event.caster
    local target = event.target
	local ability = event.ability
    local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )

	-- Strong Dispel
	local RemovePositiveBuffs = true
	local RemoveDebuffs = false
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	if caster:HasTalent("madoka_talent_1") then
	local damageTable =
					{
						victim = target,
						attacker = caster,
						damage = damage,
						damage_type = ability:GetAbilityDamageType()
					}
					ApplyDamage( damageTable )
	end
end

function madokasave( event )
	local target = event.target

	-- Strong Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end

function madokalost( event )
	local caster = event.caster
	local ability = event.ability
	local modifier = event.modifier
	local madoka_release = ability:GetLevelSpecialValueFor( "madoka_release", ability:GetLevel() - 1 )

	local current_stack = caster:GetModifierStackCount( modifier, ability )
	if current_stack then
		caster:SetModifierStackCount( modifierName, ability, math.ceil(current_stack * madoka_release) )
	end
end

function madokayinguo( keys )
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("madokamax", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_madokasave_buff"
	local modifierStackName = "modifier_madokasave_stack"
	local modifierName
	

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

function madokalost( event )
	local caster = event.caster
	local ability = event.ability
	local modifier = event.modifier
	local madoka_release = ability:GetLevelSpecialValueFor( "madoka_release", ability:GetLevel() - 1 )

	local current_stack = caster:GetModifierStackCount( modifier, ability )
	if current_stack then
		caster:SetModifierStackCount( modifierName, ability, math.ceil(current_stack * madoka_release) )
	end
end

--[[
	Author: Noya
	Date: April 5, 2015
	Adds to the modified stacks when a unit is killed, limited by a max_souls.
	TODO: Confirm that SetModifierStackCount adds the damage instances without the need to apply shit
]]
function madokaSoul( keys )
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("madokami_max_souls", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_madokami_buff"
	local modifierStackName = "modifier_madokami_stack"
	local modifierName

	if caster:HasTalent("madoka_talent_2") then
	maxStack = maxStack + ability:GetLevelSpecialValueFor("madokami_talent_souls", (ability:GetLevel() - 1))
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

function madokadeath( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierCount = caster:GetModifierCount()
	local modifierBuffName = "modifier_madokami_buff"
	local modifierStackName = "modifier_madokami_stack"
	local current_stack = caster:GetModifierStackCount( modifierStackName, ability )
	local soul_release = ability:GetLevelSpecialValueFor( "soul_release", ability:GetLevel() - 1 )
	local currentStack = 0
	local modifierName


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

function madokalose( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierCount = caster:GetModifierCount()
	local modifierBuffName = "modifier_madokasave_buff"
	local modifierStackName = "modifier_madokasave_stack"
	local current_stack = caster:GetModifierStackCount( modifierStackName, ability )
	local soul_release = ability:GetLevelSpecialValueFor( "soul_release", ability:GetLevel() - 1 )
	local currentStack = 0
	local modifierName

		-- 减半
	   current_stack = math.floor(current_stack * soul_release)
        print("current_stack",current_stack)
		

		-- Remove all the old buff modifiers
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
    caster:SetModifierStackCount(modifierStackName, ability, currentStack)

end

