function redmodel(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local kuroyuki_empty = "kuroyuki_empty"
	local starburststream = "starburststream"
	local stareclipse = "stareclipse"
	local bluemodel = "bluemodel"
	local greenmodel = "greenmodel"
	local redmodel = "redmodel"
	local projectile_model = keys.projectile_model
	--caster:SwapAbilities(starburststream, kuroyuki_empty, true, false)
	--caster:SwapAbilities(starburststream, stareclipse, true, false)

	-- Saves the original model and attack capability
	-- if caster.caster_model == nil then
	-- 	caster.caster_model = caster:GetModelName()
	-- end
	caster.caster_attack = caster:GetAttackCapability()

	-- Sets the new model and projectile
	caster:SetRangedProjectileName(projectile_model)

	-- Sets the new attack type
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function redmodelremove(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local kuroyuki_empty = "kuroyuki_empty"
	local starburststream = "starburststream"
	local stareclipse = "stareclipse"
	local bluemodel = "bluemodel"
	local greenmodel = "greenmodel"
	local redmodel = "redmodel"
	-- caster:SwapAbilities(kuroyuki_empty, starburststream, true, false)
	-- caster:SetModel(caster.caster_model)
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function bluemodel(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local kuroyuki_empty = "kuroyuki_empty"
	local starburststream = "starburststream"
	local stareclipse = "stareclipse"
	local bluemodel = "bluemodel"
	local greenmodel = "greenmodel"
	local redmodel = "redmodel"
	--caster:SwapAbilities(stareclipse, kuroyuki_empty, true, false)
	--caster:SwapAbilities(stareclipse, starburststream, true, false)
end

function bluemodelremove(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local kuroyuki_empty = "kuroyuki_empty"
	local starburststream = "starburststream"
	local stareclipse = "stareclipse"
	local bluemodel = "bluemodel"
	local greenmodel = "greenmodel"
	local redmodel = "redmodel"
	-- caster:SwapAbilities(kuroyuki_empty,stareclipse, true, false)
end

function greenmodel(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local kuroyuki_empty = "kuroyuki_empty"
	local starburststream = "starburststream"
	local stareclipse = "stareclipse"
	local bluemodel = "bluemodel"
	local greenmodel = "greenmodel"
	local redmodel = "redmodel"
	local green_radius = ability:GetLevelSpecialValueFor("green_radius", ability:GetLevel() - 1)
	--caster:SwapAbilities(kuroyuki_empty,starburststream, true, false)
	--caster:SwapAbilities(kuroyuki_empty,stareclipse, true, false)
	local particleName = "particles/units/heroes/kuroyuki/witchdoctor_voodoo_restoration.vpcf"
	caster.greenmodel = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	-- ParticleManager:SetParticleControl(caster.greenmodel, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(caster.greenmodel, 1, Vector(green_radius, green_radius, green_radius))
end

function greenmodelremove(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local kuroyuki_empty = "kuroyuki_empty"
	local starburststream = "starburststream"
	local stareclipse = "stareclipse"
	local bluemodel = "bluemodel"
	local greenmodel = "greenmodel"
	local redmodel = "redmodel"
	local green_radius = ability:GetLevelSpecialValueFor("green_radius", ability:GetLevel() - 1)
	ParticleManager:DestroyParticle(caster.greenmodel, false)
end

function kuroyukicheck1(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetUnitName() == "npc_dota_hero_zuus" or caster:HasModifier("modifier_redmodel") then
		ability:SetActivated(true)
	else
		ability:SetActivated(false)
	end
end

function kuroyukicheck2(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetUnitName() == "npc_dota_hero_zuus" or caster:HasModifier("modifier_bluemodel") then
		ability:SetActivated(true)
	else
		ability:SetActivated(false)
	end
end

function LevelUpAbility(event)
	local caster = event.caster
	local this_ability = event.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function LevelUpdeath(event)
	local caster = event.caster
	local this_ability = event.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function star_burst_stream_level(keys)
	local red_model_ability = keys.caster:FindAbilityByName("redmodel_datadriven")
	local star_burst_stream_level = keys.ability:GetLevel()

	if red_model_ability ~= nil and red_model_ability:GetLevel() ~= star_burst_stream_level then
		red_model_ability:SetLevel(star_burst_stream_level)
	end
end

function blue_model_level(keys)
	local star_eclipse_ability = keys.caster:FindAbilityByName("stareclipse_datadriven")
	local blue_model_level = keys.ability:GetLevel()

	if star_eclipse_ability ~= nil and star_eclipse_ability:GetLevel() ~= blue_model_level then
		star_eclipse_ability:SetLevel(blue_model_level)
	end
end

function star_eclipse_level(keys)
	local blue_model_ability = keys.caster:FindAbilityByName("bluemodel_datadriven")
	local star_eclipse_level = keys.ability:GetLevel()

	if blue_model_ability ~= nil and blue_model_ability:GetLevel() ~= star_eclipse_level then
		blue_model_ability:SetLevel(star_eclipse_level)
	end
end

function world_end(keys)
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_world_end_target"
	local damageType = ability:GetAbilityDamageType()
	local exceptionName = "put_your_exception_unit_here"

	-- Necessary value from KV
	local duration = ability:GetLevelSpecialValueFor("worldend_reset_time", ability:GetLevel() - 1)
	local world_end_stack = ability:GetLevelSpecialValueFor("world_end_stack", ability:GetLevel() - 1)
	if target:GetName() == exceptionName then -- Put exception here
		duration = ability:GetLevelSpecialValueFor("worldend_reset_time_roshan", ability:GetLevel() - 1)
	end

	-- Check if unit already have stack
	if target:HasModifier(modifierName) then
		local current_stack = target:GetModifierStackCount(modifierName, ability)

		-- Deal damage
		local damage_table = {
			victim = target,
			attacker = caster,
			damage = world_end_stack * current_stack,
			damage_type = damageType
		}
		ApplyDamage(damage_table)

		ability:ApplyDataDrivenModifier(caster, target, modifierName, { Duration = duration })
		target:SetModifierStackCount(modifierName, ability, current_stack + 1)
	else
		ability:ApplyDataDrivenModifier(caster, target, modifierName, { Duration = duration })
		target:SetModifierStackCount(modifierName, ability, 1)

		-- Deal damage
		local damage_table = {
			victim = target,
			attacker = caster,
			damage = world_end_stack,
			damage_type = damageType
		}
		ApplyDamage(damage_table)
	end
end

function deathbyattack(keys)
	local caster = keys.caster
	local ability = keys.ability

	print("caster attack type =", caster:GetAttackCapability())

	if caster:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
		if not caster:HasModifier("modifier_worldend_2") and caster:HasTalent("kuroyuki_talent_1") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_Barraging", {})
		end

		if not caster:HasModifier("modifier_worldend_3") and caster:HasTalent("kuroyuki_talent_2") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_Piercing", {})
		end
	end
end

function WhirlingAxesRanged(keys)
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local axe_width = ability:GetLevelSpecialValueFor("axe_width", ability_level)
	local axe_speed = ability:GetLevelSpecialValueFor("axe_speed", ability_level)
	local axe_range = ability:GetLevelSpecialValueFor("axe_range", ability_level)
	local axe_spread = ability:GetLevelSpecialValueFor("axe_spread", ability_level)
	local axe_count = ability:GetLevelSpecialValueFor("axe_count", ability_level)
	local axe_projectile = keys.axe_projectile
	caster.whirling_axes_ranged_hit_table = {}

	-- Vision
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)

	-- Initial angle calculation
	local angle = axe_spread / axe_count           -- The angle between the axes
	local direction = (target_point - caster_location):Normalized()
	local axe_angle_count = math.floor(axe_count / 2) -- Number of axes for each direction
	local angle_left = QAngle(0, angle, 0)         -- Rotation angle to the left
	local angle_right = QAngle(0, -angle, 0)       -- Rotation angle to the right

	-- Check if its an uneven number of axes
	-- If it is then create the middle axe
	if axe_count % 2 ~= 0 then
		local projectileTable =
		{
			EffectName = axe_projectile,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end

	local new_angle = QAngle(0, 0, 0) -- Rotation angle

	-- Create axes that spread to the right
	for i = 1, axe_angle_count do
		-- Angle calculation		
		new_angle.y = angle_right.y * i

		-- Calculate the new position after applying the angle and then get the direction of it			
		local position = RotatePosition(caster_location, new_angle, target_point)
		local position_direction = (position - caster_location):Normalized()

		-- Create the axe projectile
		local projectileTable =
		{
			EffectName = axe_projectile,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = position_direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end

	-- Create axes that spread to the left
	for i = 1, axe_angle_count do
		-- Angle calculation
		new_angle.y = angle_left.y * i

		-- Calculate the new position after applying the angle and then get the direction of it	
		local position = RotatePosition(caster_location, new_angle, target_point)
		local position_direction = (position - caster_location):Normalized()

		-- Create the axe projectile
		local projectileTable =
		{
			EffectName = axe_projectile,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = position_direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end
end

--[[
	Author: Noya
	Used by: Pizzalol
	Date: 14.03.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]


function WhirlingAxesRangedHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound = keys.sound

	local axe_damage = ability:GetLevelSpecialValueFor("axe_damage", ability_level)

	-- Check if the target has been hit before
	local hit_check = false

	for _, unit in ipairs(caster.whirling_axes_ranged_hit_table) do
		if unit == target then
			hit_check = true
			break
		end
	end

	-- If the target hasnt been hit before then insert it into the hit table to keep track of it
	if not hit_check then
		table.insert(caster.whirling_axes_ranged_hit_table, target)

		-- Play the sound
		EmitSoundOn(sound, target)

		-- Initialize the damage table and deal damage to the target
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType()
		damage_table.damage = axe_damage

		ApplyDamage(damage_table)
	end
end

function stareclipse(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1


	-- Ability variables
	local stareclipse_modifier = keys.phantom_strike_modifier
	local duration = ability:GetDuration()
	ability.stareclipse_attacks = ability:GetLevelSpecialValueFor("stareclipse_max_attack_count", ability_level)


	-- Order the caster to attack the target
	order =
	{
		UnitIndex = caster:GetEntityIndex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:GetEntityIndex(),
		Queue = true
	}

	ExecuteOrderFromTable(order)
end

function stareclipseAttack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stareclipse_modifier = keys.stareclipse_modifier

	-- Check if the attacked target is still the original target or if it still has any attack charges left
	if target ~= ability.stareclipse_target or ability.stareclipse_attacks <= 0 then
		-- If not then remove the attack speed modifier
		caster:RemoveModifierByName(phantom_strike_modifier)
	else
		-- Otherwise reduce the number of attack charges
		ability.stareclipse_attacks = ability.stareclipse_attacks - 1
	end
end

--[[Author: Pizzalol
	Date: 21.09.2015.
	Moves the target until it has traveled the distance to the chosen point]]
function stareclipseMotion(keys)
	local caster = keys.target
	local ability = keys.ability

	-- Move the caster while the distance traveled is less than the original distance upon cast
	if ability.time_walk_traveled_distance < ability.time_walk_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.time_walk_direction * ability.time_walk_speed)
		ability.time_walk_traveled_distance = ability.time_walk_traveled_distance + ability.time_walk_speed
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(false)
	end
end

function equipdeathby(keys)
	local caster = keys.caster
	local ability = keys.ability

	if caster:GetUnitName() == "npc_dota_hero_zuus" or caster:HasItemInInventory("item_world_end_sword") then
		ability:SetActivated(true)
	else
		ability:SetActivated(false)
	end
end

function deathby(event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	ability.tether_ally = target
end

function CheckDistance(event)
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local ability_level = ability:GetLevel() - 1
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)

	print(caster:GetUnitName())
	print(target:GetUnitName())
	print(target:GetAbsOrigin())
	print(caster:GetAbsOrigin())

	local distance = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
	-- Now on latching, so we don't need to break tether.
	print("distance = ", distance)
	if radius <= distance then
		caster:AddNewModifier(caster, ability, "modifier_stunned", { Duration = 1 })
	end


	-- Break tether
end

function worldenddamage(event)
	local caster = event.caster
	local ability = event.ability
	local target = event.attacker
	local modifierName = event.modifierName
	local ability_level = ability:GetLevel() - 1
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)

	local damage_table = {}
	damage_table.victim = target
	damage_table.attacker = caster
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	print(target:GetUnitName())

	-- Now on latching, so we don't need to break tether.

	if distance <= radius then
		ApplyDamage(damage_table)
		ability:ApplyDataDrivenModifier(caster, target, modifierName, {})
		print("damage =", damage)
	end


	-- Break tether
end

function sbsdamage(event)
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local modifierName = event.modifierName
	local ability_level = ability:GetLevel() - 1
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	local damage_table = {}
	damage_table.victim = target
	damage_table.attacker = caster
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	print(target:GetUnitName())

	-- Now on latching, so we don't need to break tether.

	if not target:HasModifier(modifierName) then
		ApplyDamage(damage_table)
		ability:ApplyDataDrivenModifier(caster, target, modifierName, {})
		print("damage =", damage)
	end


	-- Break tether
end
