LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )
--[[
	Author: Noya, Pizzalol
	Date: 04.03.2015.
	After taking damage, checks the mana of the caster and prevents as many damage as possible.

	Note: This is post-reduction, because there's currently no easy way to get pre-mitigation damage.
]]
---全反击
function ManaShield( event )
	local caster = event.caster
	local ability = event.ability
	local attacker = event.attacker
	local damage_per_mana = ability:GetLevelSpecialValueFor("damage_per_mana", ability:GetLevel() - 1 )
	local damage_reduce_mana =  ability:GetLevelSpecialValueFor("damage_reduce_mana", ability:GetLevel() - 1 )
	local absorption_percent = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 ) * 0.01
	local damath = ability:GetLevelSpecialValueFor("damath", ability:GetLevel() - 1 )
	local damage = event.Damage * absorption_percent
	local not_reduced_damage = event.Damage - damage
	if caster:HasTalent("meliodas_talent_4") then
	caster.damage_per_mana = damage_per_mana - damage_reduce_mana
	else
	caster.damage_per_mana = damage_per_mana
    end
	-- Sees if this unit has a given modifier.
	local caster_mana = caster:GetMana()
	local mana_needed = damage * caster.damage_per_mana

	-- Check if the not reduced damage kills the caster
	local oldHealth = caster.OldHealth - not_reduced_damage
    local counterdamage = ability:GetLevelSpecialValueFor("absorption_tooltip", ability:GetLevel() - 1 ) * 0.01
	-- If it doesnt then do the HP calculation
	if oldHealth >= 1 then
		print("Damage taken "..damage.." | Mana needed: "..mana_needed.." | Current Mana: "..caster_mana)
		-- Set a filter function to control the behavior when a unit takes damage. (Modify the table and Return true to use new values, return false to cancel the event)
		-- If the caster has enough mana, fully heal for the damage done
		if mana_needed <= caster_mana then
			caster:SpendMana(mana_needed, ability)
			caster:SetHealth(oldHealth)
			ApplyDamage({victim = attacker, attacker = caster, damage = damage * damath, damage_type = ability:GetAbilityDamageType()})
			-- Impact particle based on damage absorbed
			local particleName = "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(mana_needed,0,0))
		else
			local newHealth = oldHealth - damage
			mana_needed =
			caster:SpendMana(mana_needed, ability)
			caster:SetHealth(newHealth)
		end
	end	
end

-- 检查是否关闭
function ManaShieldHealth( event )
	local caster = event.caster
	local ability = event.ability
	local mananeed = ability:GetLevelSpecialValueFor("mananeed", ability:GetLevel() - 1 )
	caster.OldHealth = caster:GetHealth()

	if mananeed >= caster:GetMana() or caster:IsSilenced()  then
		ability:ToggleAbility()
	end
end
---复仇反击
---记录伤害
function CalculateDamage( keys )
	local ability = keys.ability
	local damage_taken = keys.DamageTaken
	local backtrack_time = ability:GetLevelSpecialValueFor( "backtrack_time", ability:GetLevel() - 1 )
	
	-- Temporary damage array and index
	local temp = {}
	local temp_index = 0
	
	-- Global damage array and index
	local caster_index = 0
	if ability.caster_damage == nil then
		ability.caster_damage = {}
	end
	
	-- Sets the damage and game time values in the tempororary array, if void was attacked within 2 seconds of current time
	while ability.caster_damage do
		if ability.caster_damage[caster_index] == nil then
		break
		elseif Time() - ability.caster_damage[caster_index+1] <= backtrack_time then
			temp[temp_index] = ability.caster_damage[caster_index]
			temp[temp_index+1] = ability.caster_damage[caster_index+1]
			temp_index = temp_index + 2
		end
		caster_index = caster_index + 2
	end
	
	-- Places most recent damage and current time in the temporary array
	temp[temp_index] = damage_taken
	temp[temp_index+1] = Time()
	
	-- Sets the global array as the temporary array
	ability.caster_damage = temp
end
---造成伤害
function countdamage ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local backtrack_time = ability:GetLevelSpecialValueFor( "backtrack_time", ability:GetLevel() - 1 )
	local damage_sum = 0
	local caster_index = 0
	local target = keys.target
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	local damageType = ability:GetAbilityDamageType() -- DAMAGE_TYPE_MAGICAL
	
	
	-- Provide visibility
	ability:CreateVisibilityNode( target:GetAbsOrigin(), radius, duration )
	
	-- Sums damage over the last 2 seconds
	while ability.caster_damage do
		if ability.caster_damage[caster_index] == nil then
		break
		elseif Time() - ability.caster_damage[caster_index+1] <= backtrack_time then
			damage_sum = damage_sum + ability.caster_damage[caster_index]
		end
		caster_index = caster_index + 2
	end
	
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = damage_sum,
		damage_type = damageType,
	}
	ApplyDamage( damageTable )

end

---魔神降临
---换模型
function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
    local ability = keys.ability
	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end

	-- Sets the new model and projectile
	caster:SetOriginalModel(model)

	if caster:HasTalent("meliodas_talent_1") then
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_demoattack", {})
	end
	if caster:HasTalent("meliodas_talent_2") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_Demonstrength", {})
	end
end

--[[Author: Pizzalol/Noya
	Date: 10.01.2015.
	Reverts back to the original model and attack type
]]
function ModelSwapEnd( keys )
	local caster = keys.caster

	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:RemoveModifierByName("modifier_demoattack")
	caster:RemoveModifierByName("modifier_Demonstrength")
end


--[[突进]]
	function ApplyBuff(keys)
		local caster = keys.caster
		local target = keys.target
		local caster_origin = caster:GetAbsOrigin()
		
		local ability = keys.ability
		local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
		local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
		local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
		local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
		
		-- Checks if the ability is off cooldown and if the caster is attacking a target
		if not caster:HasModifier("modifier_Demonization_3") and target ~= null then
			-- Checks if the target is an enemy
			if caster:GetTeam() ~= target:GetTeam() then
				local target_origin = target:GetAbsOrigin()
				local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
				ability.target = target
				-- Checks if the caster is in range of the target
				if distance >= min_distance and distance <= max_distance then
					-- Removes the 522 move speed cap
					caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
					-- Apply the speed buff
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_demon", {})
					-- Start cooldown on the passive
					--ability:StartCooldown(cooldown)
				-- If the caster is too far from the target, we continuously check his distance until the attack command is canceled
				elseif distance >= max_distance then
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_demon_distance", {})
				end
			end
		end
	end
	
	--[[Author: YOLOSPAGHETTI
		Date: February 16, 2016
		Checks if the caster is in range of the target]]
	function DistanceCheck(keys)
		local caster = keys.caster
		local caster_origin = caster:GetAbsOrigin()
		
		local ability = keys.ability
		local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
		local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
		local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
		local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
		
		-- Checks if the caster is still attacking the same target
		if caster:GetAggroTarget() == ability.target then
			local target_origin = ability.target:GetAbsOrigin()
			local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
			-- Checks if the caster is in range of the target
			if distance >= min_distance and distance <= max_distance then
				-- Removes the 522 move speed cap
				caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
				-- Apply the speed buff
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_demon", {})
				-- Start cooldown on the passive
				--ability:StartCooldown(cooldown)
				caster:RemoveModifierByName("modifier_demon_distance")
			end
		else
			caster:RemoveModifierByName("modifier_demon_distance")
		end
	end
	
	--[[Author: YOLOSPAGHETTI
		Date: February 16, 2016
		Removes the speed buff if the attack command is canceled]]
	function RemoveBuff(keys)
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		
		if target == null or target ~= ability.target then
			caster:RemoveModifierByName("modifier_speed_demon")
		end
	end

	function Demonization(keys)
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local min_hel = ability:GetLevelSpecialValueFor("min_hel", ability:GetLevel() -1) / 100
		local maxhel = caster:GetMaxHealth()
		local curhel = caster:GetHealth()
		local needhel = maxhel * min_hel
		local mana = caster:GetMana()
		local id = caster:GetPlayerID()
		if not caster:IsSilenced() and ability:IsCooldownReady() and mana > ability:GetManaCost(-1) and curhel < needhel then 
			caster:CastAbilityNoTarget(ability, id)
		end
		if caster:HasTalent("meliodas_talent_3") and curhel < needhel then 
			caster:CastAbilityNoTarget(ability, id)
		end
	end