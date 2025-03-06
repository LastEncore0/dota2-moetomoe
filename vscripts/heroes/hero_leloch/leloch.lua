LinkLuaModifier("modifier_lelouch_lua", "heroes/hero_leloch/modifiers/modifier_lelouch_lua.lua", LUA_MODIFIER_MOTION_NONE)
function geass5(params)
	local ability = params.ability
	local agility_damage_multiplier = ability:GetLevelSpecialValueFor("attack_damage", ability:GetLevel() - 1) / 100

	ApplyDamage({ victim = params.target, attacker = params.caster,
		damage = params.target:GetAttackCapability() * agility_damage_multiplier,
		damage_type = ability:GetAbilityDamageType() })
end

--[[
	Author: kritth
	Date: 09.01.2015
	Calculating the damage for arcane bolt
]]
function geass(keys)
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multiplier = ability:GetLevelSpecialValueFor("int_multiplier", ability:GetLevel() - 1)
	local kill_threshold = ability:GetLevelSpecialValueFor("kill_threshold", ability:GetLevel() - 1)
	local intelligence = target:GetAttackDamage()
	print("intelligence =", intelligence)
	local damageType = ability:GetAbilityDamageType()
	local modfier = keys.modfier
	local damage_table = {}
	damage_table.victim = target
	damage_table.attacker = caster
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = intelligence * multiplier
	print("damage =", damage_table.damage)
	if target:IsRealHero() then
		-- Deal damage
		ApplyDamage(damage_table)
		print(caster:GetUnitName())
	elseif caster:HasTalent("leloch_talent_1") then
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.damage = kill_threshold
		ApplyDamage(damage_table)
	else
		target:ForceKill(true)
		print(target:GetUnitName())
	end
end

function zhanshu(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local zeroleader = "zeroleader"
	local fallground = "fallground"
	local strike = "strike"
	local Grail = "Grail"
	local zero = "zero"
	local modifier_zeroleader = "modifier_zeroleader"
	local modifier_strike_2 = "modifier_strike_2"
	local modifier_fallground = "modifier_fallground"
	local modifier_Grail_2 = "modifier_Grail_2"
	local modifier_zero = "modifier_zero"

	if caster:HasModifier(modifier_zeroleader) then
		caster:SwapAbilities(strike, zeroleader, true, false)
		caster:RemoveModifierByName(modifier_zeroleader)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_strike_2, {})
	elseif caster:HasModifier(modifier_strike_2) then
		caster:SwapAbilities(fallground, strike, true, false)
		caster:RemoveModifierByName(modifier_strike_2)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_fallground, {})
	elseif caster:HasModifier(modifier_fallground) then
		caster:SwapAbilities(Grail, fallground, true, false)
		caster:RemoveModifierByName(modifier_fallground)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_Grail_2, {})
	elseif caster:HasModifier(modifier_Grail_2) then
		caster:SwapAbilities(zero, Grail, true, false)
		caster:RemoveModifierByName(modifier_Grail_2)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_zero, {})
	elseif caster:HasModifier(modifier_zero) then
		caster:SwapAbilities(zeroleader, zero, true, false)
		caster:RemoveModifierByName(modifier_zero)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_zeroleader, {})
	end
end

function LevelUpAbilityleloch(event)
	local caster = event.caster
	local this_ability = event.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name_1 = event.ability_name_1
	local ability_name_2 = event.ability_name_2
	local ability_name_3 = event.ability_name_3
	local ability_name_4 = event.ability_name_4
	local ability_handle_1 = caster:FindAbilityByName(ability_name_1)
	local ability_handle_2 = caster:FindAbilityByName(ability_name_2)
	local ability_handle_3 = caster:FindAbilityByName(ability_name_3)
	local ability_handle_4 = caster:FindAbilityByName(ability_name_4)
	local ability_level_1 = ability_handle_1:GetLevel()
	local ability_level_2 = ability_handle_2:GetLevel()
	local ability_level_3 = ability_handle_3:GetLevel()
	local ability_level_4 = ability_handle_4:GetLevel()
	local one = 1



	-- Check to not enter a level up loop
	if ability_level_1 ~= this_abilityLevel then
		ability_handle_1:SetLevel(this_abilityLevel)
	end
	if ability_level_2 ~= this_abilityLevel then
		ability_handle_2:SetLevel(this_abilityLevel)
	end
	if ability_level_3 ~= this_abilityLevel then
		ability_handle_3:SetLevel(this_abilityLevel)
	end
	if ability_level_4 ~= this_abilityLevel then
		ability_handle_4:SetLevel(this_abilityLevel)
	end
end

function LevelUpAbilityzhanshu(event)
	local caster = event.caster
	local this_ability = event.ability
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)
	local ability_level = ability_handle:GetLevel()

	print(this_ability:GetAbilityName())
	if ability_level ~= this_abilityLevel then
		print(ability_handle:GetAbilityName())
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function Vacuum(keys)
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local vacuum_modifier = keys.vacuum_modifier
	local remaining_duration = duration - (GameRules:GetGameTime() - target.vacuum_start_time)

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam()
	local target_types = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types,
		target_flags, FIND_CLOSEST, false)

	-- Calculate the position of each found unit
	for _, unit in ipairs(units) do
		local unit_location = unit:GetAbsOrigin()
		local vector_distance = target_location - unit_location
		local distance = (vector_distance):Length2D()
		local direction = (vector_distance):Normalized()

		-- Check if its a new vacuum cast
		-- Set the new pull speed if it is
		if unit.vacuum_caster ~= target then
			unit.vacuum_caster = target
			-- The standard speed value is for 1 second durations so we have to calculate the difference
			-- with 1/duration
			unit.vacuum_caster.pull_speed = distance * 1 / duration * 1 / 30
		end

		-- Apply the stun and no collision modifier then set the new location
		ability:ApplyDataDrivenModifier(caster, unit, vacuum_modifier, { duration = remaining_duration })
		unit:SetAbsOrigin(unit_location + direction * unit.vacuum_caster.pull_speed)
	end
end

--[[Author: Pizzalol
	Date: 03.04.2015.
	Track the starting vacuum time]]
function VacuumStart(keys)
	local target = keys.target

	target.vacuum_start_time = GameRules:GetGameTime()
end

function zero(keys)
	local caster = keys.caster
	local target = keys.target

	-- Clear the force attack target
	target:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	if caster:IsAlive() then
		local order =
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else
		target:Stop()
	end

	-- Set the force attack target to be the caster
	target:SetForceAttackTarget(caster)
end

-- Clears the force attack target upon expiration
function zeroEnd(keys)
	local target = keys.target

	target:SetForceAttackTarget(nil)
end

function zhiding(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_zhiding1 = keys.modifier_zhiding
	local ability_name = keys.ability_name
	local zhanshu1 = caster:FindAbilityByName(ability_name)
	local zhanshu_level = zhanshu1:GetLevel() - 1
	-- Return a handle to the modifier of the given name if found, else nil (string Name )
	if caster:HasTalent("leloch_talent_2") then
		local duration = zhanshu1:GetLevelSpecialValueFor("zhiding2", zhanshu_level)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_zhiding1, { Duration = duration })
	else
		local duration = zhanshu1:GetLevelSpecialValueFor("zhiding1", zhanshu_level)
		ability:ApplyDataDrivenModifier(caster, caster, modifier_zhiding1, { Duration = duration })
	end
	print(ability:GetAbilityName())

	--if caster:HasItemInInventory("item_silver_edge") then
	--duration = zhanshu1:GetLevelSpecialValueFor( "zhiding2", zhanshu_level - 1 )
	--print(ability_name)
	--end
	--if not caster:HasModifier( modifier_zhiding1 ) then
	ability:ApplyDataDrivenModifier(caster, caster, modifier_zhiding1, { Duration = duration })
	--end
end

function alive(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasTalent("leloch_talent_3") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_emperor_commend_2", {})
	end
end

function zhanshuzhiding(keys)
	local caster = keys.caster
	local ability = keys.ability
	local zhanshu1 = "zhanshu1"
	local leloch_empty = "leloch_empty"
	print(ability:GetAbilityName())
	caster:SwapAbilities(leloch_empty, zhanshu1, true, false)
end

function zhanshuzhid(keys)
	local caster = keys.caster
	local ability = keys.ability
	local zhanshu1 = "zhanshu1"
	local leloch_empty = "leloch_empty"
	print(ability:GetAbilityName())
	caster:SwapAbilities(leloch_empty, zhanshu1, false, true)
end

--[[geass:绝对服从]]
function HolyPersuasion(keys)
	local caster = keys.caster
	local target = keys.target
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_geass = keys.modifier_geass
	local modifier_geass_have = keys.modifier_geass_have
	local modifier_geass_time = keys.modifier_geass_time
	local modifier_geass_zero = keys.modifier_geass_zero

	local zero_units = ability:GetLevelSpecialValueFor("zero_units", ability_level)
	local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
	-- Initialize the tracking data
	ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count or 0
	ability.holy_persuasion_table = ability.holy_persuasion_table or {}
	if target:GetUnitName() ~= "guangyu" then
		-- Ability variables

		if target:IsHero() and caster.geass_target == nil then
			if not target:HasModifier("modifier_geass_2") and caster:HasTalent("leloch_talent_3") then
				local hero_name = target:GetUnitName()
				local targetLevel = target:GetLevel()
				local forwardV = target:GetForwardVector()
				local time = ability:GetLevelSpecialValueFor("time", ability_level)
				local origin = target:GetAbsOrigin()
				caster.geass_hero = CreateUnitByName(hero_name, origin, true, caster, nil, caster:GetTeamNumber())
				caster.geass_hero:SetAbilityPoints(0)
				caster.geass_hero:SetPlayerID(caster:GetPlayerID())
				caster.geass_hero:SetForwardVector(forwardV)
				caster.geass_target = target
				caster.geass_hero:SetMana(target:GetMana())
				caster.geass_hero:SetHealth(target:GetHealth())
				ability:ApplyDataDrivenModifier(caster, target, "modifier_geass_hero_duration", {})
				local underground_position = Vector(origin.x, origin.y, origin.z - 322)
				target:SetAbsOrigin(underground_position)
				--caster.geass_hero:AddNewModifier(caster, ability, "modifier_kill", {duration = time})
				caster.geass_hero:SetCanSellItems(false)

				-- Make them controllable
				caster.geass_hero:SetControllableByPlayer(player, true)
				for i = 1, targetLevel - 1 do
					caster.geass_hero:HeroLevelUp(false)
				end
				for abilitySlot = 0, 15 do
					local targetability = target:GetAbilityByIndex(abilitySlot)
					if targetability ~= nil then
						local targetabilityLevel = targetability:GetLevel()
						local targetabilityName = targetability:GetAbilityName()
						local illusionAbility = caster.geass_hero:FindAbilityByName(targetabilityName)
						illusionAbility:SetLevel(targetabilityLevel)
					end
				end

				for itemSlot = 0, 5 do
					local item = target:GetItemInSlot(itemSlot)
					if item ~= nil then
						local itemName = item:GetName()
						local newItem = CreateItem(itemName, caster.geass_hero, caster.geass_hero)
						caster.geass_hero:AddItem(newItem)
					end
				end
				caster.geass_hero:AddNewModifier(caster, ability, "modifier_arc_warden_tempest_double", nil)
				ability:ApplyDataDrivenModifier(caster, caster.geass_hero, "modifier_geass_have", {})
				ability:ApplyDataDrivenModifier(caster, target, "modifier_geass_2", {})
			else
				caster:Interrupt()
				ability:EndCooldown()
				caster:GiveMana(ability:GetManaCost(-1))
			end
		elseif caster:HasItemInInventory("item_silver_edge") then
			--local health_bonus = ability:GetLevelSpecialValueFor("health_zero", ability_level)
			--print("health_bonus =",health_bonus)

			ability:ApplyDataDrivenModifier(caster, target, modifier_geass_zero, {})
			print(target:GetUnitName())
			target:SetTeam(caster_team)
			target:SetOwner(caster)
			target:SetControllableByPlayer(player, true)
			target:GiveMana(target:GetMaxMana())
			-- Set the minimum health bonus as max hp if the current is lower than that
			-- if target:GetMaxHealth() < health_bonus then
			--	target:SetBaseMaxHealth(health_bonus)
			-- end	

			-- Track the unit
			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
			table.insert(ability.holy_persuasion_table, target)
		elseif not target:IsAncient() then
			print(target:GetUnitName())
			target:SetTeam(caster_team)
			target:SetOwner(caster)
			target:SetControllableByPlayer(player, true)
			target:GiveMana(target:GetMaxMana())

			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
			table.insert(ability.holy_persuasion_table, target)
		else
			caster:Interrupt()
			ability:EndCooldown()
			caster:GiveMana(ability:GetManaCost(-1))
		end
	end
	print("max_units =", max_units)
	print("zero_units =", zero_units)
	--[[
    if target:IsHero() then
    if orign_player == nil then
	orign_player = target:GetPlayerOwnerID()
	orign_team = target:GetTeamNumber()
    orign = target
	if caster:HasItemInInventory("item_silver_edge") and not target:HasModifier( modifier_geass_have )then
	 -- if not target:HasModifier( modifier_geass_have )then
	-- target:SetTeam(caster_team)
	target:SetOwner(caster)
	target:SetControllableByPlayer(player, true)
	ability:ApplyDataDrivenModifier(caster, target, modifier_geass_have, {})
	ability:ApplyDataDrivenModifier(caster, target, modifier_geass_time, {})
	else
    ability:ApplyDataDrivenModifier(caster, target, modifier_geass, {})
    print(ability:GetAbilityName())
	end

	else
	ability:ApplyDataDrivenModifier(caster, target, modifier_geass, {})
	print(caster:GetUnitName())
	end
else]]
	-- Change the ownership of the unit and restore its mana to full

	if caster:HasItemInInventory("item_silver_edge") then
		if ability.holy_persuasion_unit_count > zero_units then
			ability.holy_persuasion_table[1]:ForceKill(true)
		end
		-- If the maximum amount of units is reached then kill the oldest unit
	elseif ability.holy_persuasion_unit_count > max_units then
		ability.holy_persuasion_table[1]:ForceKill(true)
	end
end

function geasstargetchange(event)
	-- Hide the hero underground on the Active Split position
	local caster = event.caster
	local active_split_position = caster.geass_hero:GetAbsOrigin()
	local geass_target_heal = caster.geass_hero:GetHealth()
	local geass_target_mana = caster.geass_hero:GetMana()
	local underground_position = Vector(active_split_position.x, active_split_position.y, active_split_position.z - 322)
	caster.geass_target:SetAbsOrigin(underground_position)
	caster.geass_target:SetMana(geass_target_mana)
	caster.geass_target:SetHealth(geass_target_heal)
end

function PrimalSplitEnd(event)
	local caster = event.caster
	local facing_direction = caster.geass_hero:GetForwardVector()
	if caster.geass_hero then
		local position = caster.geass_hero:GetAbsOrigin()
		FindClearSpaceForUnit(caster.geass_target, position, true)
		caster:SetForwardVector(facing_direction)
		caster.geass_target = nil
		caster.geass_hero:RemoveSelf()
	end
end

function geassUnitDied(event)
	local caster = event.caster
	local attacker = event.attacker
	local unit = event.unit

	if attacker == unit then
		print("Primal Split End Succesfully")
	elseif attacker ~= unit then
		-- Kill the caster with credit to the attacker.
		caster.geass_target:Kill(nil, attacker)
		caster.geass_target = nil
	end

	if caster.geass_target then
		print(caster.geass_target:GetUnitName() .. " is active now")
	else
		print("All Split Units were killed!")
	end
end

function backorign(keys)
	-- orign:SetTeam(orign_team)
	orign:SetOwner(orign)
	orign:SetControllableByPlayer(orign_player, true)

	orign_player = nil
	orign_team = nil
	orign = nil
end

--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function HolyPersuasionRemove(keys)
	local target = keys.target
	local ability = keys.ability

	-- Find the unit and remove it from the table
	for i = 1, #ability.holy_persuasion_table do
		if ability.holy_persuasion_table[i] == target then
			table.remove(ability.holy_persuasion_table, i)
			ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count - 1
			break
		end
	end
end
