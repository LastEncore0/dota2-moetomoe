function rightHook( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	caster.ni_hook = false

	if caster.point == nil then
	   caster.point = target_point
	   else
	   caster.distance_point = (caster.point - target_point):Length2D() * 0.5
       caster.distance_direction = (caster.point - target_point):Normalized()
	   caster.point = caster_location + 3 * caster.distance_direction * caster.distance_point
	   caster.ni_hook = true
	end

	-- Distance calculations
	if caster.ni_hook == true then
    caster.basespeed1 = 3 * ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	caster.basedistance1 = (caster.point - caster_location):Length2D()
	caster.basedirection1 = (caster.point - caster_location):Normalized()
	caster.baseduration1 = caster.basedistance/caster.basespeed
	else
	caster.basespeed1 = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	caster.basedistance1 = (caster.point - caster_location):Length2D()
	caster.basedirection1 = (caster.point - caster_location):Normalized()
	caster.baseduration1 = caster.basedistance/caster.basespeed
    end
	


	-- Saving the data in the ability
	caster.hook_distance1 = distance
	caster.hook_speed1 = caster.basedistance * 1/30 -- 1/30 is how often the motion controller ticks
	caster.hook_direction1 = caster.basedirection
	caster.hook_traveled_distance1 = 0

	-- If another hook is already out, refund mana cost and do nothing
	if caster.hook_launched then
		caster:GiveMana(ability:GetManaCost(ability_level))
		ability:EndCooldown()
		return nil
	end

	
	-- Set the global hook_launched variable
	caster.hook_launched = true

	-- Prevent Pudge from using tps while the hook is out
	local forbidden_items = {
		"item_tpscroll",
		"item_travel_boots",
		"item_travel_boots_2"
	}
	for i = 0, 5 do
		local current_item = caster:GetItemInSlot(i)
		local should_mute = false

		-- If this item is forbidden, do not refresh it
		for _,forbidden_item in pairs(forbidden_items) do
			if current_item and current_item:GetName() == forbidden_item then
				should_mute = true
			end
		end

		-- Make item inactive
		if current_item and should_mute then
			current_item:SetActivated(false)
		end
	end

	-- Sound, particle and modifier keys
	local sound_extend = keys.sound_extend
	local sound_hit = keys.sound_hit
	local sound_retract = keys.sound_retract
	local sound_retract_stop = keys.sound_retract_stop
	local particle_hook = keys.particle_hook
	local particle_hit = keys.particle_hit
	local modifier_caster = keys.modifier_caster
	local modifier_target_enemy = keys.modifier_target_enemy
	local modifier_target_ally = keys.modifier_target_ally
	local modifier_dummy = keys.modifier_dummy
	local modifier_light = keys.modifier_light
	local modifier_sharp = keys.modifier_sharp
	
	-- Parameters
	local base_speed = ability:GetLevelSpecialValueFor("base_speed", ability_level)
	local hook_width = ability:GetLevelSpecialValueFor("hook_width", ability_level)
	local base_range = ability:GetLevelSpecialValueFor("base_range", ability_level)
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", ability_level)
	local stack_range = ability:GetLevelSpecialValueFor("stack_range", ability_level)
	local stack_speed = ability:GetLevelSpecialValueFor("stack_speed", ability_level)
	local stack_damage = ability:GetLevelSpecialValueFor("stack_damage", ability_level)
	local damage_scepter = ability:GetLevelSpecialValueFor("damage_scepter", ability_level)
	local cooldown_scepter = ability:GetLevelSpecialValueFor("cooldown_scepter", ability_level)
	local cooldown_cap_scepter = ability:GetLevelSpecialValueFor("cooldown_cap_scepter", ability_level)
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)
	local enemy_disable_linger = ability:GetLevelSpecialValueFor("enemy_disable_linger", ability_level)
	local caster_loc = caster:GetAbsOrigin()
	local start_loc = caster_loc + (keys.target_points[1] - caster_loc):Normalized() * hook_width
    local currentPos = casterLoc
	-- Calculate range, speed, and damage
	local light_stacks = caster:GetModifierStackCount(modifier_light, caster)
	local sharp_stacks = caster:GetModifierStackCount(modifier_sharp, caster)
	local hook_speed = base_speed
	local hook_range = base_range
	local hook_damage = base_damage


	-- Stun the caster for the hook duration
	ability:ApplyDataDrivenModifier(caster, caster, modifier_caster, {})

	-- Play Hook launch sound
	caster:EmitSound(sound_extend)

	-- Create and set up the Hook dummy unit
	local hook_right = CreateUnitByName("npc_dummy_blank", start_loc + Vector(0, 0, 150), false, caster, caster, caster:GetTeam())
	hook_right:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, hook_right, modifier_dummy, {})
	hook_right:SetForwardVector(caster:GetForwardVector())

	-- Make the hook always visible to both teams
	caster:MakeVisibleToTeam(DOTA_TEAM_GOODGUYS, hook_range / hook_speed)
	caster:MakeVisibleToTeam(DOTA_TEAM_BADGUYS, hook_range / hook_speed)
	
	-- Attach the Hook particle
	local hook_pfx = ParticleManager:CreateParticle(particle_hook, PATTACH_RENDERORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleAlwaysSimulate(hook_pfx)
	ParticleManager:SetParticleControlEnt(hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_1", caster_loc, true)
	ParticleManager:SetParticleControl(hook_pfx, 1, start_loc)
	ParticleManager:SetParticleControl(hook_pfx, 2, Vector(hook_speed, hook_range, hook_width) )
	ParticleManager:SetParticleControl(hook_pfx, 6, start_loc)
	ParticleManager:SetParticleControlEnt(hook_pfx, 6, hook_right, PATTACH_POINT_FOLLOW, "attach_overhead", start_loc, false)
	ParticleManager:SetParticleControlEnt(hook_pfx, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster_loc, true)

	-- Remove the caster's hook
	local weapon_hook
	if caster:IsHero() then
		weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if weapon_hook ~= nil then
			weapon_hook:AddEffects( EF_NODRAW )
		end
	end

	-- Initialize Hook variables
	local hook_loc = start_loc
	local tick_rate = 0.03
	hook_speed = hook_speed * tick_rate

	local travel_distance = (hook_loc - caster_loc):Length2D()
	local hook_step = (keys.target_points[1] - caster_loc):Normalized() * hook_speed
    local moveloc = caster:GetAbsOrigin()
	caster.wall_hit = false
	local target

	      for i = -20, 20 do
			targetponit = keys.target_points[1] + Vector(i, i, 0)
			  if not GridNav:IsTraversable(targetponit) then
	          caster.targetponit = keys.target_points[1] + Vector(i, i, 0)
			  caster.wall_hit = true
			  break
	          end
			end
	 

	-- Main Hook loop
	Timers:CreateTimer(tick_rate, function()

		--[[Check for valid units in the area
		local units = FindUnitsInRadius(caster:GetTeamNumber(), hook_loc, nil, hook_width, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
		for _,unit in pairs(units) do
			if unit ~= caster and unit ~= hook_right and not unit:IsAncient() and not IsNearFriendlyClass(unit, 1360, "ent_dota_fountain") then
				-- target_hit = true
				target = unit
				break
			end
		end

		--[[ If a valid target was hit, start dragging them
		if target_hit then

			-- Apply stun/root modifier, and damage if the target is an enemy
			if caster:GetTeam() == target:GetTeam() then
				ability:ApplyDataDrivenModifier(caster, target, modifier_target_ally, {})
			else
				ability:ApplyDataDrivenModifier(caster, target, modifier_target_enemy, {})
				ApplyDamage({attacker = caster, victim = target, ability = ability, damage = hook_damage, damage_type = DAMAGE_TYPE_PURE})
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, hook_damage, nil)
			end

			-- Play the hit sound and particle
			target:EmitSound(sound_hit)
			local hook_pfx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN_FOLLOW, target)

			-- Grant vision on the hook hit area
			ability:CreateVisibilityNode(hook_loc, vision_radius, vision_duration)

			-- Increase hook return speed
			hook_speed = math.max(hook_speed, 3000 * tick_rate)
		end
]]
		-- If no target was hit and the maximum range is not reached, move the hook and keep going
		if travel_distance < hook_range then

			-- Move the hook
			hook_right:SetAbsOrigin(hook_loc + hook_step)

			-- Recalculate position and distance
			hook_loc = hook_right:GetAbsOrigin()
			travel_distance = (hook_loc - caster_loc):Length2D()
			
			return tick_rate
			
		end

		-- If we are here, this means the hook has to start reeling back; prepare return variables
		local direction = ( caster_loc - hook_loc )
		local current_tick = 0

		-- Stop the extending sound and start playing the return sound
		caster:StopSound(sound_extend)
		caster:EmitSound(sound_retract)

		-- Remove the caster's self-stun
		caster:RemoveModifierByName(modifier_caster)

		--[[ Play sound reaction according to which target was hit
		if target_hit and target:IsRealHero() and target:GetTeam() ~= caster:GetTeam() then
			caster:EmitSound("pudge_pud_ability_hook_0"..RandomInt(1,9))
		elseif target_hit and target:IsRealHero() and target:GetTeam() == caster:GetTeam() then
			caster:EmitSound("pudge_pud_ability_hook_miss_01")
		elseif target_hit then
			caster:EmitSound("pudge_pud_ability_hook_miss_0"..RandomInt(2,6))
		else
			caster:EmitSound("pudge_pud_ability_hook_miss_0"..RandomInt(8,9))
		end
]]
		-- Hook reeling loop
		Timers:CreateTimer(tick_rate, function()

			-- Recalculate position variables
			caster_loc = caster:GetAbsOrigin()
			hook_loc = hook_right:GetAbsOrigin()
			direction = ( caster_loc - hook_loc )
			hook_step = direction:Normalized() * hook_speed
			current_tick = current_tick + 1
			
			-- If the target is close enough, or the hook has been out too long, finalize the hook return
			if direction:Length2D() < hook_speed or current_tick > 100 then

				--[[ Stop moving the target
				if target_hit then
					local final_loc = caster_loc + caster:GetForwardVector() * 100
					FindClearSpaceForUnit(target, final_loc, false)

					-- Remove the target's modifiers
					target:RemoveModifierByName(modifier_target_ally)

					-- Enemies have a small extra duration on their stun
					Timers:CreateTimer(enemy_disable_linger, function()
						target:RemoveModifierByName(modifier_target_enemy)
					end)
				end
]]
				-- Destroy the hook dummy and particles
				hook_right:Destroy()
				ParticleManager:DestroyParticle(hook_pfx, false)
				ParticleManager:ReleaseParticleIndex(hook_pfx)

				-- Stop playing the reeling sound
				caster:StopSound(sound_retract)
				caster:EmitSound(sound_retract_stop)

				-- Give back the caster's hook
				if weapon_hook ~= nil then
					weapon_hook:RemoveEffects( EF_NODRAW )
				end

				-- Clear global variables
				caster.hook_launched = nil

				-- Reactivate tp scrolls/boots
				for i = 0, 5 do
					local current_item = caster:GetItemInSlot(i)
					if current_item then
						current_item:SetActivated(true)
					end
				end

			-- If this is not the final step, keep reeling the hook in
			else

				-- Move the hook and an eventual target
				hook_right:SetAbsOrigin(hook_loc + hook_step)
				-- ParticleManager:SetParticleControl(hook_pfx, 6, hook_loc + hook_step + Vector(0, 0, 90))
		

			if caster.wall_hit == true then
	        
			   movelength = ((hook_loc - caster_loc)/(100 - current_tick)):Length2D()
			   if caster.hook_traveled_distance < caster.hook_distance then
			      moveloc = caster:GetAbsOrigin() + caster.hook_direction * caster.hook_speed
				  caster.hook_traveled_distance = caster.hook_traveled_distance + caster.hook_speed
			      print("hook_speed =",caster.hook_speed)
			      print("moveloc =",moveloc)
	             FindClearSpaceForUnit( caster, moveloc, false )
			   end
	          end

--[[
				if target_hit then
					target:SetAbsOrigin(hook_loc + hook_step)
					target:SetForwardVector(direction:Normalized())
					ability:CreateVisibilityNode(hook_loc, vision_radius, 0.5)
				end
			]]	
				return tick_rate
			end
		end)
	end)
end