--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Applies the damage to the target and gives the caster's team vision around it]]
function ThundergodsWrath(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	
	-- If the target is not invisible, we deal damage to it
	if target:IsInvisible() ~= true then
		ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
	end
	-- Gives the caster's team vision around the target
	AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), sight_radius, sight_duration, false)
	-- Renders the particle on the target
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
	-- Raise 1000 if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1000 ))
	ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	-- Plays the sound on the target
	EmitSoundOn(keys.sound, target)
end

function truethunder_initialize( keys )
	local caster = keys.caster
	-- local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability	
	local ability_level = ability:GetLevel() - 1
	-- local point = keys.target_points[1]

	-- Ability variables
	ability.truethunder_damage_percent = 0.0
	ability.truethunder_traveled = 0
	-- ability.truethunder_direction = (point - caster_location):Normalized()
	-- ability.truethunder_source = caster_location
	-- ability.truethunder_currentPos = caster_location
	-- ability.truethunder_percent_movespeed = 100
	ability.truethunder_units_array = {}
	ability.truethunder_units_hit = {}

	ability.truethunder_interval_damage =  ability:GetLevelSpecialValueFor("damage_per_interval", ability_level)
	ability.truethunder_max_range = ability:GetLevelSpecialValueFor( "arrow_range", ability_level )
	-- ability.truethunder_max_movespeed = ability:GetLevelSpecialValueFor( "arrow_speed", ability_level )
	ability.truethunder_radius = ability:GetLevelSpecialValueFor( "arrow_width", ability_level )
	ability.truethunder_vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", ability_level )	
	ability.truethunder_vision_duration = ability:GetLevelSpecialValueFor( "vision_duration", ability_level )
	ability.truethunder_damage_reduction = ability:GetLevelSpecialValueFor( "damage_reduction", ability_level )
	-- ability.truethunder_speed_reduction = ability:GetLevelSpecialValueFor( "speed_reduction", ability_level )
    -- ability.truethunder_tree_width = ability:GetLevelSpecialValueFor("tree_width", ability_level) * 2 -- Double the radius because the original feels too small
	-- ability.powershot_units_array[ index ] = v
	-- ability.powershot_units_hit[ index ] = false
end



--[[
	Author: kritth
	Date: 01.10.2015.
	Init: Charge the damage per duration
]]
function truethunder_charge( keys )
	local ability = keys.ability
	
	-- Fail check
	if not ability.truethunder_damage_percent then
		ability.truethunder_damage_percent = 0.0
	end

	if not ability.truethunder_interval_damage then
		ability.truethunder_interval_damage = 0.01
	end

	ability.truethunder_damage_percent = ability.truethunder_damage_percent + ability.truethunder_interval_damage

end

--[[
	Author: kritth
	Date: 5.1.2015.
	Init: Register units to become target
]]
function truethunder_register_unit( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local index = keys.target:entindex()
	
	-- Register
	ability.truethunder_units_array[ index ] = target
	ability.truethunder_units_hit[ index ] = false
end

--[[
	Author: kritth, Pizzalol
	Date: 01.10.2015.
	Main: Start traversing upon timer while providing vision, reducing damage and speed per units hit, and also destroy trees
]]
function truethunder_start_traverse( keys )
	-- Variables
	local caster = keys.caster
    local target = keys.unit
	local ability = keys.ability
    local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	local manamutilate = ability:GetLevelSpecialValueFor("manamutilate", (ability:GetLevel() -1))
	local manadamage = 0
	local mana = caster:GetMana()

	if caster:HasTalent("misaka_talent_3") then
	manadamage = mana * manamutilate 	
	print("manadamage =",manadamage)
    end
	-- local startAttackSound = "Hero_Zuus.ArcLightning.Cast"
	-- local startTraverseSound = "Hero_Zuus.ArcLightning.Cast"
	-- local projectileName = "particles/units/heroes/hero_stormspirit/windrunner_spell_powershot.vpcf"
	
	-- Stop sound event and fire new one, can do this in datadriven but for continuous purpose, let's put it here
	-- StopSoundEvent( startAttackSound, caster )
	-- StartSoundEvent( startTraverseSound, caster )
	
	-- Create projectile
	-- local projectileTable =
	-- {
	-- 	EffectName = projectileName,
	-- 	Ability = ability,
	-- 	vSpawnOrigin = ability.truethunder_source,
	-- 	vVelocity = Vector(ability.truethunder_direction.x * ability.truethunder_max_movespeed, ability.truethunder_direction.y * ability.truethunder_max_movespeed, 0),
	-- 	fDistance = ability.truethunder_max_range,
	-- 	fStartRadius = ability.truethunder_radius,
	-- 	fEndRadius = ability.truethunder_radius,
	-- 	Source = caster,
	-- 	bHasFrontalCone = false,
	-- 	bReplaceExisting = true,
	-- 	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	-- 	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	-- 	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	-- 	iVisionRadius = ability.truethunder_vision_radius,
	-- 	iVisionTeamNumber = caster:GetTeamNumber()
	-- }
	-- caster.truethunder_projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
	
	-- Register units around caster
	--local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, ability.truethunder_radius,
	--		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	--for k, v in pairs( units ) do
	--	local index = v:entindex()
	--	ability.truethunder_units_array[ index ] = v
	--	ability.truethunder_units_hit[ index ] = false
	--end
	
	-- Traverse
	--Timers:CreateTimer( function()
			-- Traverse the point
			-- ability.truethunder_currentPos = ability.truethunder_currentPos + ( ability.truethunder_direction * ability.truethunder_percent_movespeed/100 * ability.truethunder_max_movespeed * 1/30 )
		-- ability.truethunder_traveled = ability.truethunder_traveled + ability.truethunder_max_movespeed * 1/30
			
			-- Loop through the units array
			--for k, v in pairs( ability.truethunder_units_array ) do
				-- Check if it never got hit and is in radius
			--	if ability.truethunder_units_hit[ k ] == false and truethunder_distance( v:GetAbsOrigin(), ability.truethunder_currentPos ) <= ability.truethunder_radius then
					-- Deal damage
              local      damage_percent = ability.truethunder_damage_percent * ( 1.0 - ability.truethunder_damage_reduction )
                    ApplyDamage(
                        {
                            victim = target, 
                            attacker = caster, 
                            damage = ability:GetAbilityDamage() * damage_percent + manadamage, 
                            damage_type = ability:GetAbilityDamageType()}
                        )
					-- Reduction
					
					--ability.truethunder_percent_movespeed = ability.truethunder_percent_movespeed * ( 1.0 - ability.truethunder_speed_reduction )
					-- Change flag
					--ability.truethunder_units_hit[ k ] = true
					-- Fire sound
					--StartSoundEvent( "Hero_Windrunner.PowershotDamage", v )
				--end
			--end
			
			-- Check for nearby trees, destroy them if they exist
			-- if GridNav:IsNearbyTree( ability.truethunder_currentPos, ability.truethunder_radius, true ) then
			-- 	GridNav:DestroyTreesAroundPoint(ability.truethunder_currentPos, ability.truethunder_tree_width, false)
			-- end
			
			-- Create visibility node
			AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), sight_radius, sight_duration, false)
	-- Renders the particle on the target
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
	-- Raise 1000 if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1000 ))
	ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	-- Plays the sound on the target
	EmitSoundOn(keys.sound, target)

	--end
	--)


end

--[[
	Author: kritth
	Date: 5.1.2015.
	Helper: Calculate distance between two points
]]
function truethunder_distance( pointA, pointB )
	local dx = pointA.x - pointB.x
	local dy = pointA.y - pointB.y
	return math.sqrt( dx * dx + dy * dy )
end

function ThundergodsWrath(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	local manamutilate = ability:GetLevelSpecialValueFor("manamutilate", (ability:GetLevel() -1))
	local manadamage = 0
	local mana = caster:GetMana()

	if caster:HasTalent("misaka_talent_3") then
	manadamage = mana * manamutilate 	
	print("manadamage =",manadamage)
    end
	local damage_percent = ability.truethunder_damage_percent
	
	-- If the target is not invisible, we deal damage to it
	if target:IsInvisible() ~= true then
		 ApplyDamage(
                        {
                            victim = target, 
                            attacker = caster, 
                            damage = ability:GetAbilityDamage() * damage_percent + manadamage, 
                            damage_type = ability:GetAbilityDamageType()}
                        )
	end
	-- Gives the caster's team vision around the target
	AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), sight_radius, sight_duration, false)
	-- Renders the particle on the target
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
	-- Raise 1000 if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1000 ))
	ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	-- Plays the sound on the target
	EmitSoundOn(keys.sound, target)
end
