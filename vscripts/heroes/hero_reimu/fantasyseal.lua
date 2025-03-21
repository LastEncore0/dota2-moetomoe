--[[
	Author: Ractidous
	Date: 09.02.2015.
	Cast spirits.
]]
function CastSpirits( event )
	
	local caster	= event.caster
	local ability	= event.ability

	ability.spirits_startTime		= GameRules:GetGameTime()
	ability.spirits_numSpirits		= 0		-- Use this rather than "#spirits_spiritsSpawned"
	ability.spirits_spiritsSpawned	= {}
	caster.spirits_radius			= event.default_radius
	caster.spirits_movementFactor	= 0		-- Changed by the toggle abilities

	-- Enable the toggle abilities

  -- caster:SwapAbilities( event.ability, event.spirits_in_ability, false, true )
end

function checklanch( event )
	
	local caster	= event.caster
	local ability	= event.ability

	if caster:HasModifier("modifier_spirits_caster_datadriven") then
		ability:SetActivated(true)
	else
		ability:SetActivated(false)
	end
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Update spirits.
]]
function ThinkSpirits( event )
	
	local caster	= event.caster
	local ability	= event.ability

	local numSpiritsMax	= event.num_spirits

	local casterOrigin	= caster:GetAbsOrigin()

	local elapsedTime	= GameRules:GetGameTime() - ability.spirits_startTime

	--------------------------------------------------------------------------------
	-- Validate the number of spirits summoned
	--
	local idealNumSpiritsSpawned = elapsedTime / event.spirit_summon_interval
	idealNumSpiritsSpawned = math.min( idealNumSpiritsSpawned, numSpiritsMax )
    if ability.spirits_numSpirits < idealNumSpiritsSpawned then

       print("ability.spirits_numSpirits =",ability.spirits_numSpirits)

		-- Spawn a new spirit
		local newSpirit = CreateUnitByName( "npc_dota_wisp_spirit", casterOrigin, false, caster, caster, caster:GetTeam() )
        if ability.spirits_numSpirits == 0 then
		-- Create particle FX
		local pfx1 = ParticleManager:CreateParticle( event.spirit_particle_blue, PATTACH_ABSORIGIN_FOLLOW, newSpirit )
		newSpirit.spirit_pfx1 = pfx1
		ability:ApplyDataDrivenModifier( caster, newSpirit, "modifier_Fantasy_blue", {} )
		caster.bluespirit = newSpirit
		end
		if ability.spirits_numSpirits == 1 then
		-- Create particle FX
		local pfx2 = ParticleManager:CreateParticle( event.spirit_particle_red, PATTACH_ABSORIGIN_FOLLOW, newSpirit )
		ability:ApplyDataDrivenModifier( caster, newSpirit, "modifier_Fantasy_red", {} )
		newSpirit.spirit_pfx2 = pfx2
		caster.redspirit = newSpirit
		end
		if ability.spirits_numSpirits == 2 then
		-- Create particle FX
		local pfx3 = ParticleManager:CreateParticle( event.spirit_particle_green, PATTACH_ABSORIGIN_FOLLOW, newSpirit )
		ability:ApplyDataDrivenModifier( caster, newSpirit, "modifier_Fantasy_green", {} )
		newSpirit.spirit_pfx3 = pfx3
		caster.greenspirit = newSpirit
		end
		if ability.spirits_numSpirits == 3 then
		-- Create particle FX
		local pfx4 = ParticleManager:CreateParticle( event.spirit_particle_yellow, PATTACH_ABSORIGIN_FOLLOW, newSpirit )
		ability:ApplyDataDrivenModifier( caster, newSpirit, "modifier_Fantasy_yellow", {} )
		newSpirit.spirit_pfx4 = pfx4
		caster.yellowspirit = newSpirit
		end
		if ability.spirits_numSpirits == 4 then
		-- Create particle FX
		local pfx5 = ParticleManager:CreateParticle( event.spirit_particle_purple, PATTACH_ABSORIGIN_FOLLOW, newSpirit )
		ability:ApplyDataDrivenModifier( caster, newSpirit, "modifier_Fantasy_purple", {} )
		newSpirit.spirit_pfx5 = pfx5
		caster.purplespirit = newSpirit
		end

		-- Update the state
		local spiritIndex = ability.spirits_numSpirits + 1
		newSpirit.spirit_index = spiritIndex
		ability.spirits_numSpirits = spiritIndex
		ability.spirits_spiritsSpawned[spiritIndex] = newSpirit
		-- Apply the spirit modifier
		ability:ApplyDataDrivenModifier( caster, newSpirit, event.spirit_modifier, {} )

	end

	--------------------------------------------------------------------------------
	-- Update the radius
	--
	local currentRadius	= caster.spirits_radius
	local deltaRadius = caster.spirits_movementFactor * event.spirit_movement_rate * event.think_interval
	currentRadius = currentRadius + deltaRadius
	currentRadius = math.min( math.max( currentRadius, event.min_range ), event.max_range )

	caster.spirits_radius = currentRadius

	--------------------------------------------------------------------------------
	-- Update the spirits' positions
	--
	local currentRotationAngle	= elapsedTime * event.spirit_turn_rate
	local rotationAngleOffset	= 360 / event.num_spirits

	local numSpiritsAlive = 0

	for k,newSpirit in pairs( ability.spirits_spiritsSpawned ) do

		numSpiritsAlive = numSpiritsAlive + 1

		-- Rotate
		local rotationAngle = currentRotationAngle - rotationAngleOffset * ( k - 1 )
		local relPos = Vector( 0, currentRadius, 0 )
		relPos = RotatePosition( Vector(0,0,0), QAngle( 0, -rotationAngle, 0 ), relPos )

		local absPos = GetGroundPosition( relPos + casterOrigin, newSpirit )

		newSpirit:SetAbsOrigin( absPos )

		-- Update particle
		if newSpirit.spirit_pfx1 ~= nil then
		ParticleManager:SetParticleControl( newSpirit.spirit_pfx1, 1, Vector( currentRadius, 0, 0 ) )
		end
		if newSpirit.spirit_pfx2 ~= nil then
		ParticleManager:SetParticleControl( newSpirit.spirit_pfx2, 1, Vector( currentRadius, 0, 0 ) )
		end
		if newSpirit.spirit_pfx3 ~= nil then
		ParticleManager:SetParticleControl( newSpirit.spirit_pfx3, 1, Vector( currentRadius, 0, 0 ) )
		end
		if newSpirit.spirit_pfx4 ~= nil then
		ParticleManager:SetParticleControl( newSpirit.spirit_pfx4, 1, Vector( currentRadius, 0, 0 ) )
		end
		if newSpirit.spirit_pfx5 ~= nil then
		ParticleManager:SetParticleControl( newSpirit.spirit_pfx5, 1, Vector( currentRadius, 0, 0 ) )
		end

	end

	if ability.spirits_numSpirits == numSpiritsMax and numSpiritsAlive == 0 then
		-- All spirits have been exploded.
		caster:RemoveModifierByName( event.caster_modifier )
		return
	end

end


--[[
	Author: Ractidous
	Date: 09.02.2015.
	Destroy all spirits and swap the abilities back to the original states.
]]
function EndSpirits( event )
	
	local caster	= event.caster
	local ability	= event.ability
	local modifier_flycard = caster.cardstack
	local reimu_flycard = caster.Attackcard

	local spiritModifier	= event.spirit_modifier
	for k,v in pairs( ability.spirits_spiritsSpawned ) do
		v:RemoveModifierByName( spiritModifier )
		
	end

    caster:SwapAbilities( event.empty1_ability, event.spirits_in_ability, true, false )
	--[[ Disable the toggle abilities
	if caster:GetModifierStackCount( modifier_flycard, reimu_flycard ) >= 5 then
	caster:SwapAbilities( event.empty1_ability, event.spirits_in_ability, true, false )
	else
	caster:SwapAbilities( event.empty2_ability, event.spirits_in_ability, true, false )
	end]]
	-- Returns length of this scene in seconds.
	--caster:SwapAbilities( event.empty2_ability, event.spirits_out_ability, true, false )

	-- Reset the toggle states.
	--ResetToggleState( caster, event.spirits_in_ability )
	--ResetToggleState( caster, event.spirits_out_ability )

end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Change the movement factor.
]]
function ToggleOn( event )
	local caster	= event.caster

	-- Make sure that the opposite ability is toggled off.
	ResetToggleState( caster, event.opposite_ability )

	-- Change the movement factor
	caster.spirits_movementFactor = event.spirit_movement
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Reset the movement factor.
]]
function ToggleOff( event )
	event.caster.spirits_movementFactor = 0
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Reset the toggle state.
]]
function ResetToggleState( caster, abilityName )
	local ability = caster:FindAbilityByName( abilityName )
	if ability:GetToggleState() then
		ability:ToggleAbility()
	end
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Apply a modifier which detects collision with a hero.
]]
function OnCreatedSpirit( event )
	
	local spirit = event.caster
	local ability = event.ability
    local numSpirits = ability:GetLevelSpecialValueFor("num_spirits", (ability:GetLevel() -1))
	-- Set the spirit to caster
	if not spirit:HasModifier( event.additionalModifier ) then
	ability:ApplyDataDrivenModifier( spirit, spirit, event.additionalModifier, {} )
    spirit:SetModifierStackCount( event.additionalModifier, ability, numSpirits )
	end
end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Destroy a spirit.
]]
function OnDestroySpirit( event )

	local spirit	= event.target
	local ability	= event.ability

	if spirit:HasModifier("modifier_Fantasy_blue") then
	ParticleManager:DestroyParticle( spirit.spirit_pfx1, false )
	end
	if spirit:HasModifier("modifier_Fantasy_red") then
    ParticleManager:DestroyParticle( spirit.spirit_pfx2, false )
	end
	if spirit:HasModifier("modifier_Fantasy_green") then
	ParticleManager:DestroyParticle( spirit.spirit_pfx3, false )
	end
	if spirit:HasModifier("modifier_Fantasy_yellow") then
	ParticleManager:DestroyParticle( spirit.spirit_pfx4, false )
	end
	if spirit:HasModifier("modifier_Fantasy_purple") then
	ParticleManager:DestroyParticle( spirit.spirit_pfx5, false )
	end

	-- Kill
	spirit:ForceKill( true )

end

--[[
	Author: Ractidous
	Date: 09.02.2015.
	Explode the spirit due to collision with an enemy hero.
]]
function ExplodeSpirit( event )
	
	local spirit	= event.caster		-- We have set the spirit to the caster
	local ability	= event.ability

	if not spirit.spirit_isExploded then

		spirit.spirit_isExploded = true

		-- Remove from the list of spirits
		ability.spirits_spiritsSpawned[spirit.spirit_index] = nil

		-- Remove the spirit modifier
		spirit:RemoveModifierByName( event.spirit_modifier )

		-- Fire the hit sound
		StartSoundEvent( event.explosion_sound, spirit )

	end

end



--[[
	Author: Noya
	Date: 16.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
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

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Stop a sound.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.caster )
end