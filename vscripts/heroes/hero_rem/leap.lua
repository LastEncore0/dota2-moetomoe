--[[Author: Pizzalol
	Date: 26.09.2015.
	Clears current caster commands and disjoints projectiles while setting up everything required for movement]]
function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	-- Clears any current command and disjoints projectiles
	-- caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = ability:GetLevelSpecialValueFor("leap_distance", ability_level)
	ability.leap_speed = ability:GetLevelSpecialValueFor("leap_speed", ability_level) * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	-- For the first half of the distance the unit goes up and for the second half it goes down
	if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end

--[[
	Author: kritth
	Date: 12.01.2015.
	Start traversing the caster, creating projectile, and check if caster should stop traversing based on destination or mana
	This ability cannot be casted multiple times while it is active
]]
function ball_lightning_traverse( keys )
	-- Check if spell has already casted
	if keys.caster.ball_lightning_is_running ~= nil and keys.caster.ball_lightning_is_running == true then
		keys.ability:RefundManaCost()
		return
	end

	-- Variables from keys
	local caster = keys.caster
	local casterLoc = caster:GetAbsOrigin()
	local target = keys.target_points[ 1 ] 
	local ability = keys.ability
	-- Variables inheritted from ability
	local speed = ability:GetLevelSpecialValueFor( "ball_lightning_move_speed", ability:GetLevel() - 1 )
	local destroy_radius = ability:GetLevelSpecialValueFor( "tree_destroy_radius", ability:GetLevel() - 1 )
	local vision_radius = ability:GetLevelSpecialValueFor( "ball_lightning_vision_radius", ability:GetLevel() - 1 )
	local mana_percent = ability:GetLevelSpecialValueFor( "ball_lightning_travel_cost_percent", ability:GetLevel() - 1 )
	local distance_per_mana = ability:GetLevelSpecialValueFor( "distance_per_mana", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "ball_lightning_aoe", ability:GetLevel() - 1 )
	local mana_cost_base = ability:GetLevelSpecialValueFor( "ball_lightning_travel_cost_base", ability:GetLevel() - 1 )
	
	-- Variables based on modifiers and precaches
	local particle_dummy = "particles/status_fx/status_effect_base.vpcf"
	local loop_sound_name = "Hero_StormSpirit.BallLightning.Loop"
	local modifierName = "modifier_ball_lightning_buff_datadriven"
	local modifierDestroyTreesName = "modifier_ball_lightning_destroy_trees_datadriven"
	
	-- Necessary pre-calculated variable
	local currentPos = casterLoc
	local intervals_per_second = speed / destroy_radius		-- This will calculate how many times in one second unit should move based on destroy tree radius
	local forwardVec = ( target - casterLoc ):Normalized()
	local mana_per_distance = ( mana_percent / 100 ) * caster:GetMaxMana()
	
	-- Set global value for damage mechanism
	caster.ball_lightning_start_pos = casterLoc
	caster.ball_lightning_is_running = true
	
	-- Adjust vision
	caster:SetDayTimeVisionRange( vision_radius )
	caster:SetNightTimeVisionRange( vision_radius )
	
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
		Timers:CreateTimer( function()
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
				currentPos = currentPos + forwardVec * ( speed / intervals_per_second )
				-- caster:SetAbsOrigin( currentPos ) -- This doesn't work because unit will not stick to the ground but rather travel in linear
				FindClearSpaceForUnit( caster, currentPos, false )
				
				-- Check if unit is close to the destination point
				if ( target - currentPos ):Length2D() <= speed / intervals_per_second then
					-- Exit condition
					caster:RemoveModifierByName( modifierName )
					caster:RemoveModifierByName( modifierDestroyTreesName )
					StopSoundEvent( loop_sound_name, caster )
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
