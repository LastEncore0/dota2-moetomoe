--[[
	Author: Ractidous
	Date: 27.01.2015.
	Create the particle effect and projectiles.
]]
function FireMacropyre( event )
	local caster		= event.caster
	local ability		= event.ability

	local pathLength	= event.cast_range
	local pathRadius	= event.path_radius
	local duration		= event.duration

	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * pathLength

	ability.macropyre_startPos	= startPos
	ability.macropyre_endPos	= endPos
	ability.macropyre_expireTime = GameRules:GetGameTime() + duration

	-- Create particle effect
	local particleName = "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 3, startPos )

	-- Generate projectiles
	pathRadius = math.max( pathRadius, 64 )
	local projectileRadius = pathRadius * math.sqrt(2)
	local numProjectiles = math.floor( pathLength / (pathRadius*2) ) + 1
	local stepLength = pathLength / ( numProjectiles - 1 )

	local dummyModifierName = "modifier_macropyre_destroy_tree_datadriven"

	for i=1, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * (i-1) * stepLength

		ProjectileManager:CreateLinearProjectile( {
			Ability				= ability,
		--	EffectName			= "",
			vSpawnOrigin		= projectilePos,
			fDistance			= 64,
			fStartRadius		= projectileRadius,
			fEndRadius			= projectileRadius,
			Source				= caster,
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_MECHANICAL,
			fExpireTime			= ability.macropyre_expireTime,
			bDeleteOnHit		= false,
			vVelocity			= Vector( 0, 0, 0 ),	-- Don't move!
			bProvidesVision		= false,
		--	iVisionRadius		= 0,
		--	iVisionTeamNumber	= caster:GetTeamNumber(),
		} )

		-- Create dummy to destroy trees
		if i~=1 and GridNav:IsNearbyTree( projectilePos, pathRadius, true ) then
			local dummy = CreateUnitByName( "npc_dota_thinker", projectilePos, false, caster, caster, caster:GetTeamNumber() )
			ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
		end
	end
end

--[[
	Author: Ractidous
	Data: 27.01.2015.
	Apply a dummy modifier that periodcally checks whether the target is within the macropyre's path.
]]
function ApplyDummyModifier( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local modifierName = event.modifier_name

	local duration = ability.macropyre_expireTime - GameRules:GetGameTime()

	ability:ApplyDataDrivenModifier( caster, target, modifierName, { duration = duration } )
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Check whether the target is within the path, and apply damage if neccesary.
]]
function CheckMacropyre( event )
	local caster		= event.caster
	local target		= event.target
	local ability		= event.ability
	local pathRadius	= event.path_radius
	local damage		= event.damage

	local targetPos = target:GetAbsOrigin()
	targetPos.z = 0

	local distance = DistancePointSegment( targetPos, ability.macropyre_startPos, ability.macropyre_endPos )
	if distance < pathRadius then
		-- Apply damage
		ApplyDamage( {
			ability = ability,
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
		} )
	end
end
function ApplyFFFModifier (keys)

    local caster = keys.caster
	local ability = keys.ability
	local modifier_FFF = keys.modifier_FFF
	local damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() -1))
	local max_range = ability:GetLevelSpecialValueFor("max_radius", (ability:GetLevel() -1))
	local incrsing = ability:GetLevelSpecialValueFor("incrsing", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- Renders the echoslam particle around the caster
	if fff_range == nil then
	fff_range = ability:GetLevelSpecialValueFor("aura_radius", (ability:GetLevel() -1))
    elseif fff_range < max_range then
    fff_range = fff_range + incrsing
	else
	fff_range = max_range
    end

    local startPos = caster:GetAbsOrigin()

	local particleName = "particles/units/gyro_calldown_marker.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, Vector( fff_range, fff_range, fff_range ) )
    AddFOWViewer(DOTA_UNIT_TARGET_TEAM_ENEMY, caster:GetAbsOrigin(), fff_range, 5, false)
--[[
    local particleName1 = "particles/units/leshrac_split_earth.vpcf"
	local pfx1 = ParticleManager:CreateParticle( particleName1, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx1, 0, startPos )
	ParticleManager:SetParticleControl( pfx1, 1, Vector( fff_range, fff_range, fff_range ) )
    -- ParticleManager:SetParticleControl( pfx1, 15, Vector( 1, 1, 1 ) )
	-- ParticleManager:SetParticleControl( pfx1, 16, Vector( 0, 0, 0 ) )
]]
	-- Units to take the initial echo slam damage, and to send echo projectiles from
	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, fff_range, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, ability:GetAbilityTargetFlags() , 0, false)
    -- ApplyDamage({victim = units, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- local is_target = false
	-- local is_echo_target = false
	
	-- Loops through the targets
	for i,initial_unit in ipairs(initial_units) do
		if not initial_unit:IsHero() or initial_unit:IsControllableByAnyPlayer() then
			ability:ApplyDataDrivenModifier( caster, initial_unit, modifier_FFF, {} )
			end

	end  

	--ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
end
function ApplyFFFModifier1 (keys)

    local caster = keys.caster
	local ability = keys.ability
	local modifier_FFF = keys.modifier_FFF
	local damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() -1))
	local max_range = ability:GetLevelSpecialValueFor("max_radius", (ability:GetLevel() -1))
	local incrsing = ability:GetLevelSpecialValueFor("incrsing", (ability:GetLevel() -1))
	-- local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- Renders the echoslam particle around the caster
	if caster.fff_range1 == nil then
	caster.fff_range1 = ability:GetLevelSpecialValueFor("aura_radius", (ability:GetLevel() -1))
    elseif caster.fff_range1 < max_range then
    caster.fff_range1 = caster.fff_range1 + incrsing
	else
	caster.fff_range1 = max_range
    end

    local startPos = caster:GetAbsOrigin()

	local particleName = "particles/units/gyro_calldown_marker.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, Vector( caster.fff_range1, caster.fff_range1, caster.fff_range1 ) )
	AddFOWViewer(DOTA_UNIT_TARGET_TEAM_ENEMY, caster:GetAbsOrigin(), caster.fff_range1, 5, false)
--[[
    local particleName1 = "particles/units/leshrac_split_earth.vpcf"
	local pfx1 = ParticleManager:CreateParticle( particleName1, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx1, 0, startPos )
	ParticleManager:SetParticleControl( pfx1, 1, Vector( caster.fff_range1, caster.fff_range1, caster.fff_range1 ) )
    -- ParticleManager:SetParticleControl( pfx1, 15, Vector( 1, 1, 1 ) )
	-- ParticleManager:SetParticleControl( pfx1, 16, Vector( 0, 0, 0 ) )
]]

	-- Units to take the initial echo slam damage, and to send echo projectiles from
	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, caster.fff_range1, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, ability:GetAbilityTargetFlags() , 0, false)
    -- ApplyDamage({victim = units, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- local is_target = false
	-- local is_echo_target = false
	
	-- Loops through the targets
	for i,initial_unit in ipairs(initial_units) do
		-- Applies the initial damage to the target
		if not initial_unit:IsHero() or initial_unit:IsControllableByAnyPlayer() then
		ability:ApplyDataDrivenModifier( caster, initial_unit, modifier_FFF, {} )
		end

	end  

	--ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
end
function ApplyFFFdamage (keys)

    local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()
	local casterDir = casterOrigin - targetOrigin
	local distToAlly = casterDir:Length2D()
	local damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() -1))

	-- local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- Renders the echoslam particle around the caster
	if fff_range >= distToAlly then
	ApplyDamage({victim = target, attacker = caster, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})
    end

end
function ApplyFFFdamage1 (keys)

    local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()
	local casterDir = casterOrigin - targetOrigin
	local distToAlly = casterDir:Length2D()
	local damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() -1))

	-- local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- Renders the echoslam particle around the caster
	if caster.fff_range1 >= distToAlly then
	ApplyDamage({victim = target, attacker = caster, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})
    end

end
function ApplyFFFModifier2 (keys)

    local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local damage = ability:GetLevelSpecialValueFor("aura_damage", (ability:GetLevel() -1))
	local max_range = ability:GetLevelSpecialValueFor("max_radius", (ability:GetLevel() -1))
	local incrsing = ability:GetLevelSpecialValueFor("incrsing", (ability:GetLevel() -1))
	-- local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	-- Renders the echoslam particle around the caster
	if fff_range2 == nil then
	fff_range2 = ability:GetLevelSpecialValueFor("aura_radius", (ability:GetLevel() -1))
    elseif fff_range2 < max_range then
    fff_range2 = fff_range2 + incrsing
	else
	fff_range2 = max_range
    end

    local startPos = caster:GetAbsOrigin()
	--AddFOWViewer(DOTA_UNIT_TARGET_TEAM_BOTH, caster:GetAbsOrigin(), caster.fff_range1, duration, false)
	local particleName = "particles/units/gyro_calldown_marker.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, Vector( caster.fff_range1, caster.fff_range1, caster.fff_range1 ) )

--[[
    local particleName1 = "particles/units/leshrac_split_earth.vpcf"
	local pfx1 = ParticleManager:CreateParticle( particleName1, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( pfx1, 0, startPos )
	ParticleManager:SetParticleControl( pfx1, 1, Vector( caster.fff_range1, caster.fff_range1, caster.fff_range1 ) )
    -- ParticleManager:SetParticleControl( pfx1, 15, Vector( 1, 1, 1 ) )
	-- ParticleManager:SetParticleControl( pfx1, 16, Vector( 0, 0, 0 ) )
	]]

	-- Units to take the initial echo slam damage, and to send echo projectiles from
	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, fff_range2, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, ability:GetAbilityTargetFlags() , 0, false)
    -- ApplyDamage({victim = units, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- local is_target = false
	-- local is_echo_target = false
	
	-- Loops through the targets
	for i,initial_units in ipairs(initial_units) do
			ability:ApplyDataDrivenModifier( caster, initial_unit, modifier_FFF, {} )

	end  

	--ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
end
--[[
	Author: Ractidous
	Date: 27.01.2015.
	Distance between a point and a segment.
]]
function DistancePointSegment( p, v, w )
	local l = w - v
	local l2 = l:Dot( l )
	t = ( p - v ):Dot( w - v ) / l2
	if t < 0.0 then
		return ( v - p ):Length2D()
	elseif t > 1.0 then
		return ( w - p ):Length2D()
	else
		local proj = v + t * l
		return ( proj - p ):Length2D()
	end
end

