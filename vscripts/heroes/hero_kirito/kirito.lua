--[[
	桐人
]]
function ball_lightning_traverse(keys)
	-- Check if spell has already casted
	if keys.caster.ball_lightning_is_running ~= nil and keys.caster.ball_lightning_is_running == true then
		keys.ability:RefundManaCost()
		return
	end

	-- Variables from keys
	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local target = keys.target_points[1]
	local ability = keys.ability
	-- Variables inheritted from ability
	local speed = ability:GetLevelSpecialValueFor("ball_lightning_move_speed", ability:GetLevel() - 1)
	local destroy_radius = ability:GetLevelSpecialValueFor("tree_destroy_radius", ability:GetLevel() - 1)
	local vision_radius = ability:GetLevelSpecialValueFor("ball_lightning_vision_radius", ability:GetLevel() - 1)
	local mana_percent = ability:GetLevelSpecialValueFor("ball_lightning_travel_cost_percent", ability:GetLevel() - 1)
	local distance_per_mana = ability:GetLevelSpecialValueFor("distance_per_mana", ability:GetLevel() - 1)
	local radius = ability:GetLevelSpecialValueFor("ball_lightning_aoe", ability:GetLevel() - 1)
	local mana_cost_base = ability:GetLevelSpecialValueFor("ball_lightning_travel_cost_base", ability:GetLevel() - 1)

	-- Variables based on modifiers and precaches
	local particle_dummy = "particles/status_fx/status_effect_base.vpcf"
	local loop_sound_name = "Hero_StormSpirit.BallLightning.Loop"
	local modifierName = "modifier_ball_lightning_buff_datadriven"
	local modifierDestroyTreesName = "modifier_ball_lightning_destroy_trees_datadriven"

	-- Necessary pre-calculated variable
	local currentPos = casterLoc
	local intervals_per_second = speed /
	destroy_radius                                   -- This will calculate how many times in one second unit should move based on destroy tree radius
	local forwardVec = (target - casterLoc):Normalized()
	local mana_per_distance = (mana_percent / 100) * caster:GetMaxMana()

	-- Set global value for damage mechanism
	caster.ball_lightning_start_pos = casterLoc
	caster.ball_lightning_is_running = true

	-- Adjust vision
	caster:SetDayTimeVisionRange(vision_radius)
	caster:SetNightTimeVisionRange(vision_radius)

	-- Start
	local distance = 0.0
	if caster:GetMana() > mana_per_distance then
		-- Spend initial mana
		-- caster:SpendMana( mana_per_distance, ability )

		--[[ Create dummy projectile
		local projectileTable =
		{
			EffectName = particle_dummy,
			Ability = ability,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = speed * forwardVec,
			fDistance = forwardVec,
			fStartRadius = radius,
			fEndRadius = radius,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = true,
			bProvidesVision = true,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		local projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
		]]
		-- Traverse
		Timers:CreateTimer(function()
			-- Spending mana
			distance = distance + speed / intervals_per_second
			-- if distance >= distance_per_mana then
			-- Check if there is enough mana to cast
			-- local mana_to_spend = mana_cost_base + mana_per_distance
			-- if caster:GetMana() >= mana_to_spend then
			-- 	caster:SpendMana( mana_to_spend, ability )
			-- else
			-- Exit condition
			-- caster:RemoveModifierByName( modifierName )
			-- caster:RemoveModifierByName( modifierDestroyTreesName )
			-- StopSoundEvent( loop_sound_name, caster )
			-- 	caster.ball_lightning_is_running = false
			-- 	return nil
			-- end
			-- distance = distance - distance_per_mana
			-- end

			-- Update location
			currentPos = currentPos + forwardVec * (speed / intervals_per_second)
			-- caster:SetAbsOrigin( currentPos ) -- This doesn't work because unit will not stick to the ground but rather travel in linear
			FindClearSpaceForUnit(caster, currentPos, false)

			-- Check if unit is close to the destination point
			if (target - currentPos):Length2D() <= speed / intervals_per_second then
				-- Exit condition
				caster:RemoveModifierByName(modifierName)
				caster:RemoveModifierByName(modifierDestroyTreesName)
				--StopSoundEvent( loop_sound_name, caster )
				caster.ball_lightning_is_running = false
				return nil
			else
				return 1 / intervals_per_second
			end
		end
		)
		-- else
		-- 	ability:RefundManaCost()
	end
end

--[[
	Author: kritth
	Date: 12.01.2015.
	Damage the units that user runs into based on the distance
]]
function ball_lightning_damage(keys)
	-- Variables
	local targetLoc = keys.target:GetAbsOrigin()
	local casterLoc = keys.caster.ball_lightning_start_pos
	local ability = keys.ability
	local damage_per_distance = ability:GetAbilityDamage()
	local distance_per_damage = ability:GetLevelSpecialValueFor("distance_per_damage", ability:GetLevel() - 1)
	local damageType = ability:GetAbilityDamageType()

	-- Calculate and damage the unit
	local real_damage = (targetLoc - casterLoc):Length2D() * damage_per_distance / distance_per_damage
	local damageTable = {
		victim = keys.target,
		attacker = keys.caster,
		damage = real_damage,
		damage_type = damageType
	}
	ApplyDamage(damageTable)
end

--[[
	Author: kritth
	Date: 12.01.2015.
	Destroy trees
	NOTE:	This function is very important. When caster is set to invulnerable, KV will not be able to attach anything to the caster at all.
			Therefore, everything has to be done manually in lua.
]]
function ball_lightning_destroy_trees(keys)
	local modifierName = "modifier_ball_lightning_destroy_trees_datadriven"
	keys.caster:RemoveModifierByName(modifierName)
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, modifierName, {})
end

function FierySoul(keys)
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("fiery_soul_max_stacks", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_hayaku_run_buff"
	local modifierStackName = "modifier_hayaku_run_buff_stack"
	local modifierStopkName = "modifier_vorpal_strike"
	local hayaku_run = "hayaku_run"
	local vorpal_strike = "vorpal_strike"
	local modifierName

	if caster:HasTalent("kirito_talent_3") then
		maxStack = ability:GetLevelSpecialValueFor("talent_max_stacks", (ability:GetLevel() - 1))
	end


	if caster.position == nil then
		caster.position = caster:GetAbsOrigin()
	end

	local vector_distance = caster.position - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	if distance > 0 and not caster:HasModifier(modifierStopkName) then
		if distance > 100 then
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
	else
		for i = 0, modifierCount do
			modifierName = caster:GetModifierNameByIndex(i)

			if modifierName == modifierBuffName then
				currentStack = currentStack + 1
			end
		end

		caster:RemoveModifierByName(modifierStackName)
		for i = 0, currentStack do
			caster:RemoveModifierByName(modifierBuffName)
		end

		caster:SetModifierStackCount(modifierStackName, ability, 0)
	end
	local vorpalstrike = caster:FindAbilityByName("vorpal_strike")
	--print("currentStack  =",currentStack)
	if currentStack ~= nil and currentStack > 6 then
		vorpalstrike:SetActivated(true)
	else
		vorpalstrike:SetActivated(false)
	end
	--[[
	if caster:HasModifier("modifier_special_bonus_haste") then
		vorpalstrike:EndCooldown()
	end
]]
	caster.position = caster:GetAbsOrigin()
end

function DistanceCheck(keys)
	local caster = keys.caster
	local target = keys.target
	print(target)
	local ability = keys.ability
	local movement_damage_pct = ability:GetLevelSpecialValueFor("movement_damage_pct", ability:GetLevel() - 1) / 100
	local damage_cap_amount = ability:GetLevelSpecialValueFor("damage_cap_amount", ability:GetLevel() - 1)
	local damage = 0

	if target.position == nil then
		target.position = target:GetAbsOrigin()
	end
	local vector_distance = target.position - target:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	if distance <= damage_cap_amount and distance > 0 then
		damage = distance * movement_damage_pct
	end
	target.position = target:GetAbsOrigin()
	if damage ~= 0 then
		ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType() })
	end
end

----二刀流
function Fervor(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier = keys.modifier
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)
	if caster:HasTalent("kirito_talent_1") then
		max_stacks = ability:GetLevelSpecialValueFor("talent_stacks", ability_level)
	end

	-- Check if we have an old target
	if caster.fervor_target then
		-- Check if that old target is the same as the attacked target
		if caster.fervor_target == target then
			-- Check if the caster has the attack speed modifier
			if caster:HasModifier(modifier) then
				-- Get the current stacks
				local stack_count = caster:GetModifierStackCount(modifier, ability)

				-- Check if the current stacks are lower than the maximum allowed
				if stack_count < max_stacks then
					-- Increase the count if they are
					caster:SetModifierStackCount(modifier, ability, stack_count + 1)
				end
			else
				-- Apply the attack speed modifier and set the starting stack number
				ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
				caster:SetModifierStackCount(modifier, ability, 1)
			end
		else
			-- If its not the same target then set it as the new target and remove the modifier
			caster:RemoveModifierByName(modifier)
			caster.fervor_target = target
		end
	else
		caster.fervor_target = target
	end
end

function kiritoarmor(keys)
	-- init --
	local caster = keys.caster
	local ability = keys.ability
	local agility = keys.caster:GetBaseAgility()
	local damage = keys.damage
	local random = RandomFloat(0, 200)
	local chance = agility + random
	local block = ability:GetSpecialValueFor("damage_block")
	local crruentheal = caster:GetHealth()
	-- Get the maximum health of this entity.
	-- heal handling --
	print("random =", random)
	local heal = damage
	if chance > 200 then
		if damage > block then heal = block end

		caster:SetHealth(caster:GetHealth() + heal)

		print("kiritowin")
	else
		print("kiritolose")
	end
	-- stack handling --
end

function sleight_of_fist_init(keys)
	-- Cannot cast multiple stacks
	if keys.caster.sleight_of_fist_active ~= nil and keys.caster.sleight_of_fist_action == true then
		keys.ability:RefundManaCost()
		return nil
	end

	-- Inheritted variables
	local caster = keys.caster
	local targetPoint = keys.target_points[1]
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local attack_interval = ability:GetLevelSpecialValueFor("attack_interval", ability:GetLevel() - 1)
	local modifierTargetName = "modifier_sleight_of_fist_target_datadriven"
	local modifierHeroName = "modifier_sleight_of_fist_target_hero_datadriven"
	local modifierCreepName = "modifier_sleight_if_fist_target_creep_datadriven"
	local casterModifierName = "modifier_sleight_of_fist_caster_datadriven"
	local dummyModifierName = "modifier_sleight_of_fist_dummy_datadriven"
	local particleSlashName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf"
	local particleTrailName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf"
	local particleCastName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf"
	local slashSound = "Hero_EmberSpirit.SleightOfFist.Damage"

	-- Targeting variables
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local unitOrder = FIND_ANY_ORDER

	-- Necessary varaibles
	local counter = 0
	caster.sleight_of_fist_active = true
	local dummy = CreateUnitByName(caster:GetName(), caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, dummy, dummyModifierName, {})

	-- Casting particles
	local castFxIndex = ParticleManager:CreateParticle(particleCastName, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(castFxIndex, 0, targetPoint)
	ParticleManager:SetParticleControl(castFxIndex, 1, Vector(radius, 0, 0))

	Timers:CreateTimer(0.1, function()
		ParticleManager:DestroyParticle(castFxIndex, false)
		ParticleManager:ReleaseParticleIndex(castFxIndex)
	end
	)

	-- Start function
	local castFxIndex = ParticleManager:CreateParticle(particleCastName, PATTACH_CUSTOMORIGIN, caster)
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), targetPoint, caster, radius, targetTeam,
		targetType, targetFlag, unitOrder, false
	)

	for _, target in pairs(units) do
		counter = counter + 1
		ability:ApplyDataDrivenModifier(caster, target, modifierTargetName, {})
		Timers:CreateTimer(counter * attack_interval, function()
			-- Only jump to it if it's alive
			if target:IsAlive() then
				-- Create trail particles
				local trailFxIndex = ParticleManager:CreateParticle(particleTrailName, PATTACH_CUSTOMORIGIN, target)
				ParticleManager:SetParticleControl(trailFxIndex, 0, target:GetAbsOrigin())
				ParticleManager:SetParticleControl(trailFxIndex, 1, caster:GetAbsOrigin())

				Timers:CreateTimer(0.1, function()
					ParticleManager:DestroyParticle(trailFxIndex, false)
					ParticleManager:ReleaseParticleIndex(trailFxIndex)
					return nil
				end
				)

				-- Move hero there
				FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)

				if target:IsHero() then
					ability:ApplyDataDrivenModifier(caster, caster, modifierHeroName, {})
				else
					ability:ApplyDataDrivenModifier(caster, caster, modifierCreepName, {})
				end

				caster:PerformAttack(target, true, true, true, false, false)

				-- Slash particles
				local slashFxIndex = ParticleManager:CreateParticle(particleSlashName, PATTACH_ABSORIGIN_FOLLOW, target)
				StartSoundEvent(slashSound, caster)

				Timers:CreateTimer(0.1, function()
					ParticleManager:DestroyParticle(slashFxIndex, false)
					ParticleManager:ReleaseParticleIndex(slashFxIndex)
					StopSoundEvent(slashSound, caster)
					return nil
				end
				)

				-- Clean up modifier
				caster:RemoveModifierByName(modifierHeroName)
				caster:RemoveModifierByName(modifierCreepName)
				target:RemoveModifierByName(modifierTargetName)
			end
			return nil
		end
		)
	end

	-- Return caster to origin position
	Timers:CreateTimer((counter + 1) * attack_interval, function()
		FindClearSpaceForUnit(caster, dummy:GetAbsOrigin(), false)
		dummy:RemoveSelf()
		caster:RemoveModifierByName(casterModifierName)
		caster.sleight_of_fist_active = false
		return nil
	end
	)

	caster:SetAbsOrigin(targetPoint)
end

function BlinkStrike(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	-- local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", ability_level)
	local victim_angle = target:GetAnglesAsVector()
	local victim_forward_vector = target:GetForwardVector()

	-- Angle and positioning variables
	local victim_angle_rad = victim_angle.y * math.pi / 180
	local victim_position = target:GetAbsOrigin()
	local attacker_new = target:GetOrigin() + RandomVector(100)
	-- print( "dummydealykilling" )
	-- dummydealy:RemoveSelf()

	-- Sets Riki behind the victim and facing it
	caster:SetAbsOrigin(attacker_new)
	FindClearSpaceForUnit(caster, attacker_new, true)
	caster:SetForwardVector(victim_forward_vector)


	-- Order the caster to attack the target
	-- Necessary on jumps to allies as well (does not actually attack), otherwise Riki will turn back to his initial angle
	order =
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = ability,
		Queue = true
	}

	ExecuteOrderFromTable(order)
end

function star_burst_stream(keys)
	local caster = keys.caster
	--star_burst_target = keys.target
	local ability = keys.ability
	local star_burst_stream = "star_burst_stream"
	local vorpal_strike = "vorpal_strike"
	local nitaoliu = "nitaoliu"
	local four_fangzhan = "four_fangzhan"
	local star_left = "star_left"
	local star_right = "star_right"
	local star_front = "star_front"
	local star_shan = "star_shan"
	local hayaku_run = "hayaku_run"
	local ability_level = ability:GetLevel() - 1
	caster:SwapAbilities("star_left", "kirito_empty", true, false)
	caster:SwapAbilities("star_front", "nitaoliu", true, false)
	caster:SwapAbilities("star_right", "four_fangzhan", true, false)
	caster:SwapAbilities("star_shan", "star_burst_stream", true, false)
	--print("star_burst_target =",keys.target)
end

function star_burst_mod(keys)
	local caster = keys.caster
	local ability = keys.ability
	local time = ability:GetLevelSpecialValueFor("time", ability:GetLevel() - 1)
	local random = RandomFloat(0, 3)
	local modifier_star_left = keys.modifier_star_left
	local modifier_star_front = keys.modifier_star_front
	local modifier_star_right = keys.modifier_star_right

	print("star_mod_stream")

	caster:RemoveModifierByName("modifier_star_left")
	caster:RemoveModifierByName("modifier_star_front")
	caster:RemoveModifierByName("modifier_star_right")


	if random < 1 then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_star_left, {})
	end
	if random < 2 and random >= 1 then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_star_front, {})
	end
	if random >= 2 then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_star_right, {})
	end
end

function star_charge(keys)
	local ability = keys.ability
	local caster = keys.caster
	-- Fail check
	if not star_damage_percent then
		star_damage_percent = 1.0
	end
	if star_damage_percent >= 0.2 then
		star_damage_percent = star_damage_percent - star_interval_damage
	else
		star_damage_percent = 0.2
	end
end

function star_zero(keys)
	star_damage_percent = 1.0
end

function star_end(keys)
	local caster = keys.caster
	local star_burst_stream = "star_burst_stream"
	local vorpal_strike = "vorpal_strike"
	local nitaoliu = "nitaoliu"
	local four_fangzhan = "four_fangzhan"
	local star_left = "star_left"
	local star_right = "star_right"
	local star_front = "star_front"
	local star_shan = "star_shan"
	local hayaku_run = "hayaku_run"
	caster:RemoveModifierByName("modifier_star_left")
	caster:RemoveModifierByName("modifier_star_front")
	caster:RemoveModifierByName("modifier_star_right")
	caster:SwapAbilities("star_left", "kirito_empty", false, true)
	caster:SwapAbilities("star_front", "nitaoliu", false, true)
	caster:SwapAbilities("star_right", "four_fangzhan", false, true)
	caster:SwapAbilities("star_shan", "star_burst_stream", false, true)
	caster.star = nil
end

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

function GenerateShrapnelPoints(keys)
	-- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
	local radius = keys.Radius
	local count = keys.Count
	local caster = keys.caster

	-- 之后我们获取施法者，也就是火枪面向的单位向量，和他的原点
	-- 之后把他的面向单位向量*2000，乘出来的结果就是英雄所面向的
	-- 2000距离的向量，再加上原点的位置，那么得到的就是英雄前方2000的那个点。
	local caster_fv = caster:GetForwardVector()
	local caster_origin = caster:GetOrigin()
	local center = caster_origin + caster_fv * 100
	-- 我们要做的散弹是发射Count个弹片，所以我们就进行Count次循环
	-- 之后在center，也就是我们上面所计算出来的，英雄面前2000距离的位置
	-- 周围radius距离里面随机一个点，并把他放到result这个表里面去
	local result = {}
	for i = 1, count do
		-- 这里先使用一个RandomFloat来获取一个从0到半径值的随机半径
		--  之后用RandomVector函数来在这个半径的圆周上获取随机一个点，
		-- 这样最后得到的vec就是那么一个圆形范围里面的随机一个点了。
		local random = RandomFloat(0, radius)
		local vec = center + RandomVector(random)
		table.insert(result, vec)
	end
	-- 之后我们把这个地点列表返回给KV
	-- 举一反三的话，我们也可以做出比如说，向周围三百六十度，每间隔60度的方向各释放一个线性投射物的东西
	-- 这个大家自己试验就好
	return result
end

function OnShrapnelStart(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local modifier = keys.modifier
	local ability_level = ability:GetLevel() - 1
	local max_stars = ability:GetLevelSpecialValueFor("max_stars", ability_level)
	local time = ability:GetLevelSpecialValueFor("time", ability_level)
	local star_burst_stream = "star_burst_stream"
	local vorpal_strike = "vorpal_strike"
	local nitaoliu = "nitaoliu"
	local four_fangzhan = "four_fangzhan"
	local star_left = "star_left"
	local star_right = "star_right"
	local star_front = "star_front"
	local star_shan = "star_shan"
	local hayaku_run = "hayaku_run"
	local modifier_star_left = keys.modifier_star_left
	local modifier_star_front = keys.modifier_star_front
	local modifier_star_right = keys.modifier_star_right
	local random = RandomFloat(0, 3)
	if caster.star == nil then
		caster.star = 0
	end
	if not (caster and point and ability) then return end
	CreateDummyAndCastAbilityAtPosition(caster, "sniper_shrapnel", ability:GetLevel(), point, 30, false)

	if caster:HasModifier(modifier) and max_stars >= caster.star then
		caster.star = caster.star + 1
		print("caster.star =", caster.star)
		print("ability =", ability)
		caster:RemoveModifierByName(modifier)
		if random < 1 then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_star_left, {})
			print("modifier_star_left =", modifier_star_left)
		end
		if random < 2 and random >= 1 then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_star_front, {})
			print("modifier_star_front =", modifier_star_front)
		end
		if random >= 2 then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_star_right, {})
			print("modifier_star_right =", modifier_star_right)
		end
		-- Add a modifier to this unit.
	else
		caster:RemoveModifierByName("modifier_star_left")
		caster:RemoveModifierByName("modifier_star_front")
		caster:RemoveModifierByName("modifier_star_right")
		caster:SwapAbilities("star_left", "kirito_empty", false, true)
		caster:SwapAbilities("star_front", "nitaoliu", false, true)
		caster:SwapAbilities("star_right", "four_fangzhan", false, true)
		caster:SwapAbilities("star_shan", "star_burst_stream", false, true)
		caster.star = nil
	end
end

function CreateDummyAndCastAbilityAtPosition(owner, ability_name, ability_level, position, release_delay, scepter)
	local dummy = CreateUnitByNameAsync("npc_dummy", owner:GetOrigin(), false, owner, owner, owner:GetTeam(),
		function(unit)
			print("unit created")
			unit:AddAbility(ability_name)
			unit:SetForwardVector((position - owner:GetOrigin()):Normalized())
			local ability = unit:FindAbilityByName(ability_name)
			ability:SetLevel(ability_level)
			ability:SetOverrideCastPoint(0)

			if scepter then
				local item = CreateItem("item_ultimate_scepter", unit, unit)
				unit:AddItem(item)
			end

			unit:SetContextThink(DoUniqueString("cast_ability"),
				function()
					unit:CastAbilityOnPosition(position, ability, owner:GetPlayerID())
				end,
				0)
			unit:SetContextThink(DoUniqueString("Remove_Self"),
				function()
					print("removing dummy units", release_delay)
					unit:RemoveSelf()
				end, release_delay)

			return unit
		end
	)
end

function attackdamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = caster:GetAttackDamage() * 2
	print("damage =", damage)
	if caster:HasTalent("kirito_talent_2") then
		print("damage attack")
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType()
		damage_table.damage = damage

		ApplyDamage(damage_table)
	end
end
