--[[丢你蕾姆]]
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
	local speed = ability:GetLevelSpecialValueFor( "rem_move_speed", ability:GetLevel() - 1 )
	local destroy_radius = ability:GetLevelSpecialValueFor( "rem_destroy_radius", ability:GetLevel() - 1 )
	local vision_radius = ability:GetLevelSpecialValueFor( "rem_vision_radius", ability:GetLevel() - 1 )
	
	-- Variables based on modifiers and precaches
	local particle_dummy = "particles/status_fx/status_effect_base.vpcf"
	local loop_sound_name = "Hero_StormSpirit.BallLightning.Loop"
	local modifierName = "modifier_rem_buff_datadriven"
	local modifierDestroyTreesName = "modifier_ball_lightning_destroy_trees_datadriven"
	
	-- Necessary pre-calculated variable
	local currentPos = casterLoc
	local intervals_per_second = speed / destroy_radius		-- This will calculate how many times in one second unit should move based on destroy tree radius
	local forwardVec = ( target - casterLoc ):Normalized()
	
	-- Set global value for damage mechanism
	caster.ball_lightning_start_pos = casterLoc
	caster.ball_lightning_is_running = true
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	-- Adjust vision
	caster:SetDayTimeVisionRange( vision_radius )
	caster:SetNightTimeVisionRange( vision_radius )
	
	-- Start
	local distance = 0.0
		Timers:CreateTimer( function()
				-- Spending mana
				distance = distance + speed / intervals_per_second
				currentPos = currentPos + forwardVec * ( speed / intervals_per_second )
				-- caster:SetAbsOrigin( currentPos ) -- This doesn't work because unit will not stick to the ground but rather travel in linear
				FindClearSpaceForUnit( caster, currentPos, false )
				print("length = ",( target - currentPos ):Length2D())
                print("speed = ",speed / intervals_per_second)
				-- Check if unit is close to the destination point
				if ( target - currentPos ):Length2D() <= speed / intervals_per_second then
					-- Exit condition
                    
					caster:RemoveModifierByName("modifier_rem_buff_datadriven")
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

function EchoSlam(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local echo_slam_damage_range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() -1))
	local echo_slam_echo_search_range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() -1))
	local echo_slam_echo_range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
    local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
    local bashpoint = caster:GetAbsOrigin() + caster:GetForwardVector() * 450
			
	-- Renders the echoslam start particle around the caster
	local particle2 = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, Vector(bashpoint.x,bashpoint.y,bashpoint.z))
	ParticleManager:SetParticleControl(particle2, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,bashpoint.z))
	ParticleManager:SetParticleControl(particle2, 2, Vector(bashpoint.x,bashpoint.y,bashpoint.z))
--[[
    local particle3 = ParticleManager:CreateParticle(keys.particle1, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle1, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle1, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle1, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
			
	-- Renders the echoslam start particle around the caster
	local particle4 = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle2, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle2, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	]]
	-- Units to take the initial echo slam damage, and to send echo projectiles from
	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), bashpoint, nil, echo_slam_damage_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	-- ability:ApplyDataDrivenModifier(caster, initial_units, modifier, {duration = duration})
	

	
	-- Loops through the targets
	for i,initial_unit in ipairs(initial_units) do
		-- Applies the initial damage to the target
		ApplyDamage({victim = initial_unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
		initial_unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})

	end
	
	
end

--鬼化

function mana_cost(keys)
local caster = keys.caster
local ability = keys.ability
local mana_cost = ability:GetManaCost(-1)
local draw_range = ability:GetLevelSpecialValueFor("draw_range", (ability:GetLevel() -1))
local draw_mana = ability:GetLevelSpecialValueFor("draw_mana", (ability:GetLevel() -1))
local manamut = ability:GetLevelSpecialValueFor("manamut", (ability:GetLevel() -1))/100


-- local modifier_flamewing = keys.modifier_flamewing
	if caster:GetMana() >= mana_cost then
	caster:SpendMana(mana_cost, ability)
	else
	ability:ToggleAbility()
end

local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, draw_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
print("draw_mana =",draw_mana)
     for i,unit in ipairs(units) do
     if caster:HasTalent("rem_talent_3") then
        draw_mana = draw_mana + unit:GetMaxMana() * manamut 
        end
        print("draw_mana =",draw_mana)
		if unit:GetMana() >= draw_mana then
	  unit:SpendMana(draw_mana, ability)
      caster:GiveMana(draw_mana)
     end
	end

end

function bluarua( keys )
	local caster = keys.caster
	local ability = keys.ability
	local draw_range = ability:GetLevelSpecialValueFor("draw_range", (ability:GetLevel() -1))
	local particleName = "particles/units/heroes/rem/blue_voodoo_restoration.vpcf"
	caster.bluearua = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	-- ParticleManager:SetParticleControl(caster.greenmodel, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(caster.bluearua, 1, Vector( draw_range, draw_range, draw_range ))
end

function bluaruaremove( keys )
	local caster = keys.caster
	local ability = keys.ability
	ParticleManager:DestroyParticle(caster.bluearua, false)
end

function icemagic( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local intmut = ability:GetLevelSpecialValueFor("intmut", (ability:GetLevel() -1))
    local damage = caster:GetIntellect() * intmut
	print("damage =",damage)
	if caster:HasTalent("rem_talent_2") then
	local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = damage

		ApplyDamage(damage_table)
    elseif caster:HasTalent("rem_talent_1") then
    ability:ApplyDataDrivenModifier( caster, target, "modifier_ice_magic_datadriven", {} )
       
	end

end

function Echorem(keys)
	local caster = keys.caster
	local ability = keys.ability
	local echo_slam_echo_range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() -1))
    local bashpoint = caster:GetAbsOrigin()
			
	-- Renders the echoslam start particle around the caster
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, Vector(bashpoint.x,bashpoint.y,bashpoint.z))
	ParticleManager:SetParticleControl(particle, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,bashpoint.z))
	ParticleManager:SetParticleControl(particle, 2, Vector(bashpoint.x,bashpoint.y,bashpoint.z))
	
	
end

