--[[Author: Amused/D3luxe
	Used by: Pizzalol
	Date: 11.07.2015.
	Blinks the target to the target point, if the point is beyond max blink range then blink the maximum range]]
function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer( 1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
end

function WhirlingAxesRanged( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local axe_width = ability:GetLevelSpecialValueFor("axe_width", ability_level) 
	local axe_speed = ability:GetLevelSpecialValueFor("axe_speed", ability_level) 
	-- local axe_range = ability:GetLevelSpecialValueFor("axe_range", ability_level) 
	local axe_spread = ability:GetLevelSpecialValueFor("axe_spread", ability_level) 
	local axe_count = ability:GetLevelSpecialValueFor("axe_count", ability_level)
	local reimu_projectile = keys.reimu_projectile
	caster.whirling_axes_ranged_hit_table = {}

	-- Vision
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)

	-- Initial angle calculation
	local angle = axe_spread / axe_count -- The angle between the axes
	local direction = (target_point - caster_location):Normalized()
	local axe_range = (target_point - caster_location):Length()
	print("axe_range =",axe_range)
	local axe_angle_count = math.floor(axe_count / 2) -- Number of axes for each direction
	local angle_left = QAngle(0, angle, 0) -- Rotation angle to the left
	local angle_right = QAngle(0, -angle, 0) -- Rotation angle to the right

	-- Check if its an uneven number of axes
	-- If it is then create the middle axe
	if axe_count % 2 ~= 0 then
		local projectileTable =
		{
			EffectName = reimu_projectile,
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

	local new_angle = QAngle(0,0,0) -- Rotation angle

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
			EffectName = reimu_projectile,
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
			EffectName = reimu_projectile,
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



function reimu_reduce( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local reduce = ability:GetLevelSpecialValueFor("reduce", (ability:GetLevel() - 1))
	local YinYang_Orbs = caster:FindAbilityByName("YinYang_Orbs")
	--local Dimensional_Rift = caster:FindAbilityByName("Dimensional_Rift")
	--local Dimensional_Riftreduce = Dimensional_Rift:GetLevelSpecialValueFor("reduce", (Dimensional_Rift:GetLevel() - 1)) or 3
	local modifier_flycard = caster.cardstack
	local reimu_flycard = caster.Attackcard
	

	-- Check if unit already have stack
	if caster:HasModifier( modifier_flycard ) then
		local stack = caster:GetModifierStackCount( modifier_flycard, reimu_flycard )
		print("stack =",stack)
		caster:SetModifierStackCount( modifier_flycard, reimu_flycard, stack - reduce )



	end

end

function addstack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local maxStack = ability:GetLevelSpecialValueFor("max", (ability:GetLevel() - 1))
	if caster:HasTalent("reimu_talent_2") then
	maxStack = maxStack + ability:GetLevelSpecialValueFor("add", (ability:GetLevel() - 1))
	end
	local modifierStackName = "modifier_card_fly"
	local modifierCount = caster:GetModifierStackCount( modifierStackName, ability )
	local currentStack = 0
	local modifierName
    print("currentStack1 =",currentStack)
	print("modifierCount =",modifierCount)
	-- Always remove the stack modifier
	caster:RemoveModifierByName(modifierStackName) 

	-- Counts the current stacks
	for i = 1, modifierCount do
			currentStack = currentStack + 1
	end

	-- Remove all the old buff modifiers

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	-- Reapply the maximum number of stacks
   if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)


   else
		-- Increase the number of stacks
		currentStack = currentStack + 1
        print("currentStack2 =",currentStack)
		caster:SetModifierStackCount(modifierStackName, ability, currentStack)

	
	
  end
  caster.Attackcard = ability
  caster.cardstack  = modifierStackName
  -- 
	
end
function checkstack( keys )
	local ability = keys.ability
	local caster = keys.caster
	local reduce = ability:GetLevelSpecialValueFor("reduce", (ability:GetLevel() - 1))
	local modifierStackName = "modifier_card_fly"
	local cardattack = caster:FindAbilityByName("card_attack")
	local modifierCount = caster:GetModifierStackCount( modifierStackName, cardattack )
	if not caster:GetUnitName() =="npc_dota_hero_zuus" or modifierCount < reduce  then
	ability:SetActivated(false)
	else
	ability:SetActivated(true)
	end
	
end

--[[
	Author: Ractidous
	Date: 28.01.2015.
	Cast Fire Spirts.
]]
function CastFireSpirits( event )
	local caster	= event.caster
	local ability	= event.ability
	local modifierStackName	= event.modifier_stack_name

	local hpCost		= event.hp_cost_perc
	local numSpirits	= event.spirit_count

	-- Create particle FX
	local particleName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl( pfx, 1, Vector( numSpirits, 0, 0 ) )
	for i=1, numSpirits do
		ParticleManager:SetParticleControl( pfx, 8+i, Vector( 1, 0, 0 ) )
	end

	caster.fire_spirits_numSpirits	= numSpirits
	caster.fire_spirits_pfx			= pfx

	-- Set the stack count
	caster:SetModifierStackCount( modifierStackName, ability, numSpirits )
end

--[[
	Author: Ractidous
	Date: 28.01.2015.
	Launch a fire spirit.
]]
function LaunchFireSpirit( event )
	local caster		= event.caster
	local ability		= event.ability
	local modifierName	= event.modifier_stack_name

	-- Update spirits count
	local mainAbility	= caster:FindAbilityByName( event.main_ability_name )
	local currentStack	= caster:GetModifierStackCount( modifierName, mainAbility )
	currentStack = currentStack - 1
	caster:SetModifierStackCount( modifierName, mainAbility, currentStack )

	--[[ Update the particle FX
	local pfx = caster.fire_spirits_pfx
	ParticleManager:SetParticleControl( pfx, 1, Vector( currentStack, 0, 0 ) )
	for i=1, caster.fire_spirits_numSpirits do
		local radius = 0
		if i <= currentStack then
			radius = 1
		end

		ParticleManager:SetParticleControl( pfx, 8+i, Vector( radius, 0, 0 ) )
	end
]]
	-- Remove the stack modifier if all the spirits has been launched.
	if currentStack == 0 then
		caster:RemoveModifierByName( modifierName )
	end
end

--[[
	Author: Ractidous
	Date: 28.01.2015.
	Remove fire spirits' FX.
]]
function RemoveFireSpirits( event )
	local caster	= event.caster
	local ability	= event.ability

	local pfx = caster.fire_spirits_pfx
	ParticleManager:DestroyParticle( pfx, false )
end

--[[
	Author: Ractidous
	Date: 02.16.2015.
	Create a linear projectile, then keep it tracked.
]]
function CastIllusoryOrb( event )
	
	local caster	= event.caster
	local ability	= event.ability
	local point		= event.target_points[1]

	local radius			= event.radius
	local maxDist			= event.max_distance
	local orbSpeed			= event.orb_speed
	local visionRadius		= event.orb_vision
	local visionDuration	= event.vision_duration
	local numExtraVisions	= event.num_extra_visions

	local travelDuration	= maxDist / orbSpeed
	local extraVisionInterval = travelDuration / numExtraVisions

	local casterOrigin		= caster:GetAbsOrigin()
	local targetDirection	= ( ( point - casterOrigin ) * Vector(1,1,0) ):Normalized()
	local projVelocity		= targetDirection * orbSpeed

	local startTime		= GameRules:GetGameTime()
	local endTime		= startTime + travelDuration

	local numExtraVisionsCreated = 0
	local isKilled		= false

	local modifierName	= event.modifier_stack_name
	local spiritModifier	= event.spirit_modifier

	-- Update spirits count
	local mainAbility	= caster:FindAbilityByName( event.main_ability_name )
	local currentStack	= caster:GetModifierStackCount( modifierName, mainAbility )
	currentStack = currentStack - 1
	caster:SetModifierStackCount( modifierName, mainAbility, currentStack )
	local units = FindUnitsInRadius(caster:GetTeam() , caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_ALL, 0, 0, false)
    if currentStack == 4 then
	ability.pfx = event.proj_particle
	caster.bluespirit:RemoveModifierByName( spiritModifier )
	print("blue")
	end
	if currentStack == 3 then
	ability.pfx = event.red
	caster.redspirit:RemoveModifierByName( spiritModifier )
	print("red")
	end
	if currentStack == 2 then
	ability.pfx = event.green
	caster.greenspirit:RemoveModifierByName( spiritModifier )
	print("green")
	end
	if currentStack == 1 then
	ability.pfx = event.yellow
	caster.yellowspirit:RemoveModifierByName( spiritModifier )
	print("yellow")
	end
	if currentStack == 0 then
	ability.pfx = event.purple
	caster.purplespirit:RemoveModifierByName( spiritModifier )
	print("purple")
	end
	-- Remove the stack modifier if all the spirits has been launched.
	if currentStack == 0 then
		caster:RemoveModifierByName( modifierName )
	end
    print("currentStack =",currentStack)
	print("pfx =",ability.pfx)
	-- Make Ethereal Jaunt active
	-- local etherealJauntAbility = ability.illusory_orb_etherealJauntAbility
	-- etherealJauntAbility:SetActivated( true )

	-- Create linear projectile
	local projID = ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= ability.pfx,
		vSpawnOrigin		= casterOrigin,
		fDistance			= maxDist,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= endTime,
		bDeleteOnHit		= false,
		vVelocity			= projVelocity,
		bProvidesVision		= true,
		iVisionRadius		= visionRadius,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	--[[print("projID = " .. projID)

	-- Create sound source
	local thinker = CreateUnitByName( "npc_dota_thinker", casterOrigin, false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, thinker, event.proj_modifier, { duration = -1 } )

	--
	-- Replace Ethereal Jaunt function
	--
	etherealJauntAbility.etherealJaunt_cast = function ( )
		-- Remove the projectile
		ProjectileManager:DestroyLinearProjectile( projID )

		-- Blink
		FindClearSpaceForUnit( caster, thinker:GetAbsOrigin(), false )

		-- Kill
		isKilled = true

		etherealJauntAbility.etherealJaunt_cast = nil
	end

	--
	-- Track the projectile
	--
	Timers:CreateTimer( function ( )
		
		local elapsedTime 	= GameRules:GetGameTime() - startTime
		local currentOrbPosition = casterOrigin + projVelocity * elapsedTime
		currentOrbPosition = GetGroundPosition( currentOrbPosition, thinker )

		-- Update position of the sound source
		thinker:SetAbsOrigin( currentOrbPosition )

		-- Try to create new extra vision
		if elapsedTime > extraVisionInterval * (numExtraVisionsCreated + 1) then
			ability:CreateVisibilityNode( currentOrbPosition, visionRadius, visionDuration )
			numExtraVisionsCreated = numExtraVisionsCreated + 1
		end

		-- Remove if the projectile has expired
		if elapsedTime >= travelDuration or isKilled then
			--print( numExtraVisionsCreated .. " extra vision created." )
			thinker:RemoveModifierByName( event.proj_modifier )
			--thinker:RemoveSelf()

			etherealJauntAbility:SetActivated( false )

			return nil
		end

		return 0.03

	end )
]]
end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Upgrade the sub ability and make inactive it.
]]
function OnUpgrade( event )
	local caster	= event.caster
	local ability	= event.ability
	local etherealJauntAbility = caster:FindAbilityByName( event.sub_ability )
	ability.illusory_orb_etherealJauntAbility = etherealJauntAbility

	if not etherealJauntAbility then
		print( "Ethereal jaunt not found. at heroes/hero_puck/illusory_orb.lua # OnUpgrade" )
		return
	end

	etherealJauntAbility:SetLevel( ability:GetLevel() )

	if etherealJauntAbility:GetLevel() == 1 then
		etherealJauntAbility:SetActivated( false )
	end
end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Cast Ethereal Jaunt.
]]
function CastEtherealJaunt( event )
	local ability = event.ability
	if ability.etherealJaunt_cast then
		ability.etherealJaunt_cast()
	end
end



--[[
	Author: Ractidous
	Date: 13.02.2015.
	Stop a sound on the target unit.
]]
function intdamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local damage = caster:GetIntellect()
	print("damage =",damage)
	if caster:HasTalent("reimu_talent_1") then
	local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = damage

		ApplyDamage(damage_table)
	end

end