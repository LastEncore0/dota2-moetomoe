--[[
	Author: Ractidous, with help from Noya
	Date: 03.02.2015.
	Initialize the slowed units list, and let the caster latch.
	We also need to track the health/mana, in order to grab amount gained of health/mana in the future.
]]
function CastTether( event )
	-- Variables
	local caster	= event.caster
	local attacker = event.attacker
	local ability	= event.ability
    if not attacker:IsHero() then
    attacker:ForceKill(true)
	end
	local attacker = event.attacker
	local attacker_team = attacker:GetTeamNumber()
    local vector = caster:GetAbsOrigin()
	-- Initialize the tracking data

	-- Ability variables
    print("caster_heaith =",caster:GetHealth())
	if caster:GetHealth() < 100 then

	-- Change the ownership of the unit and restore its mana to full
	 caster:SetTeam(attacker_team)
	caster:EmitSound("DOTA_Item.GhostScepter.Activate") 

     if attacker_team == DOTA_TEAM_BADGUYS then
       GameRules:SendCustomMessage("#MTM_good_lose_conquer", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
	   elseif attacker_team == DOTA_TEAM_GOODGUYS then
       GameRules:SendCustomMessage("#MTM_bad_lose_conquer", DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS, 0) 
	   end

	end

end
function setpfx( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
    local vector = caster:GetAbsOrigin()
	local caster_team = caster:GetTeamNumber()
    local particledire = "particles/world_tower/tower_upgrade/ti7_dire_tower_orb.vpcf"
	local particlersdi = "particles/world_tower/tower_upgrade/ti7_radiant_tower_orb.vpcf"
   -- print("setpfxcaster =",caster:GetName())
       
     if caster_team == DOTA_TEAM_BADGUYS then
	   --print("particleName =",particleName)
	   if caster.pfx ~= nil then
	    ParticleManager:DestroyParticle( caster.pfx , false )
		end
	   local particleName = "particles/world_tower/tower_upgrade/ti7_dire_tower_orb.vpcf"
	   caster.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	   ParticleManager:SetParticleControl( caster.pfx , 0, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 1, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 2, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 3, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 4, vector )   
	   elseif caster_team == DOTA_TEAM_GOODGUYS then
	   if caster.pfx ~= nil then
	    ParticleManager:DestroyParticle( caster.pfx , false )
		end
	   local particleName = "particles/world_tower/tower_upgrade/ti7_radiant_tower_orb.vpcf"
	  -- print("particleName =",particleName)
	   caster.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	   ParticleManager:SetParticleControl( caster.pfx , 0, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 1, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 2, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 3, vector )
	   ParticleManager:SetParticleControl( caster.pfx , 4, vector )
	   end
end
function LevelUplink( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
	local ability_level = ability:GetLevel() + 1
    ability:SetLevel(ability_level)
	--caster:CreatureLevelUp(ability_level)
	--[[
	if ability_level == 2 then
	caster:StartGesture(ACT_DOTA_CONSTANT_LAYER+level2)
	elseif ability_level == 3 then
	caster:StartGesture(ACT_DOTA_CONSTANT_LAYER+level3)
	elseif ability_level == 4 then
	caster:StartGesture(ACT_DOTA_CONSTANT_LAYER+level4)
	elseif ability_level == 5 then
	caster:StartGesture(ACT_DOTA_CONSTANT_LAYER+level5)
	elseif ability_level >= 6 then
	caster:StartGesture(ACT_DOTA_CONSTANT_LAYER+level6)
	end
	]]
end
function targetnohero( event )
	local caster = event.caster
	local target = event.target

	if not target:IsRealHero() then
    target:ForceKill(true)
	end
end

function attackernohero( event )
	local caster = event.caster
	local attacker = event.attacker

	if not attacker:IsRealHero() then
    attacker:ForceKill(true)
	end
end
--[[
	Author: Ractidous
	Date: 04.02.2015.
	Check for tether break distance.
]]
function CheckDistance( event )
	local caster = event.caster
	local ability = event.ability

	-- Now on latching, so we don't need to break tether.
	if caster:HasModifier( event.latch_modifier ) then
		return
	end

	local distance = ( ability.tether_ally:GetAbsOrigin() - caster:GetAbsOrigin() ):Length2D()
	if distance <= event.radius then
		return
	end

	-- Break tether
	caster:RemoveModifierByName( event.caster_modifier )
end

function transteam( keys )
	local caster = keys.caster
	local ability = keys.ability
	local attacker = ability.tether_ally
	local attacker_team = attacker:GetTeamNumber()

	-- Initialize the tracking data

	-- Ability variables

	if caster:HasModifier( event.caster_modifier ) then

	-- Change the ownership of the unit and restore its mana to full
	caster:SetTeam(attacker_team)
	
    ability.tether_ally:RemoveModifierByName( event.ally_modifier )
	caster:RemoveModifierByName( event.caster_modifier )
	end
end

function DropItem( keys )
    local caster = keys.caster
    local itm = caster: AddItemByName("item_lightyu")
    local pos = caster: GetOrigin() + RandomVector(100)
	print(caster:GetUnitName())
    -- if itm ~= nil then
       caster: DropItemAtPositionImmediate(itm,pos)
    -- end
end

function killneature( event )
	-- Variables
	local target = event.target
	-- target:ForceKill(true)
	print(target:GetUnitName())
end
--[[
	Author: Ractidous
	Date: 03.02.2015.
	Remove tether from the ally, then swap the abilities back to the original states.
]]
function EndTether( event )
	local caster = event.caster
	local ability = event.ability

	ability.tether_ally:RemoveModifierByName( event.ally_modifier )
	ability.tether_ally = nil

end

function goldplus( event )
	-- Variables
	local caster = event.attacker
	local target = event.unit
	local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
	local ability = event.ability
	local bonus_gold = ability:GetLevelSpecialValueFor( "bonus_gold", ability:GetLevel() - 1 )

	caster:ModifyGold(bonus_gold, false, 0)

	-- Show the particles, player only
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"		
	local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
	ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, target:GetAbsOrigin() )
	
	-- Message Particle, has a bunch of options
	-- Similar format to the popup library by soldiercrabs: http://www.reddit.com/r/Dota2Modding/comments/2fh49i/floating_damage_numbers_and_damage_block_gold/
	local symbol = 0 -- "+" presymbol
	local color = Vector(255, 200, 33) -- Gold
	local lifetime = 2
	local digits = string.len(stacks) + 1
	local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
	local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, target, player )
	ParticleManager:SetParticleControl(particle, 1, Vector(symbol, bonus_gold, symbol))
    ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(particle, 3, color)


end



--[[
	Author: Ractidous
	Date: 03.02.2015.
	Store the current health.
]]
function TrackCurrentHealth( event )
	local caster = event.caster
	caster.tether_lastHealth = caster:GetHealth()
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Store the current mana.
]]
function TrackCurrentMana( event )
	local caster = event.caster
	caster.tether_lastMana = caster:GetMana()
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Heal the gained health to the tethered ally.
]]
function HealAlly( event )
	local caster	= event.caster
	local ability	= event.ability
	local target	= ability.tether_ally

	local healthGained = caster:GetHealth() - caster.tether_lastHealth
	if healthGained < 0 then
		return
	end

	-- Heal the tethered ally
	target:Heal( healthGained * event.tether_heal_amp, ability )
end

--[[
	Author: Ractidous
	Date: 04.02.2015.
	Give mana to the tethered ally.
]]
function GiveManaToAlly( event )
	local caster	= event.caster
	local ability	= event.ability
	local target	= ability.tether_ally

	local manaGained = caster:GetMana() - caster.tether_lastMana
	if manaGained < 0 then
		return
	end

	--print( caster.tether_lastMana )

	target:GiveMana( manaGained * event.tether_heal_amp )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Pull the caster to the tethered ally.
]]
function Latch( event )
	-- Variables
	local caster	= event.caster
	local ability	= event.ability
	local target 	= ability.tether_ally

	local tickInterval	= event.tick_interval
	local latchSpeed	= event.latch_speed
	local latchDistance	= event.latch_distance_to_target

	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()

	-- Calculate the distance
	local casterDir = casterOrigin - targetOrigin
	local distToAlly = casterDir:Length2D()
	casterDir = casterDir:Normalized()

	if distToAlly > latchDistance then

		-- Leap to the target
		distToAlly = distToAlly - latchSpeed * tickInterval
		distToAlly = math.max( distToAlly, latchDistance )	-- Clamp this value

		local pos = targetOrigin + casterDir * distToAlly
		pos = GetGroundPosition( pos, caster )

		caster:SetAbsOrigin( pos )

	end

	if distToAlly <= latchDistance then
		-- We've reached, so finish latching
		caster:RemoveModifierByName( event.latch_modifier )
	end

end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Launch a projectile in order to detect enemies crosses the tether.
]]
function FireTetherProjectile( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target
	local ability	= event.ability

	local lineRadius	= event.tether_line_radius
	local tickInterval	= event.tick_interval

	local casterOrigin	= caster:GetAbsOrigin()
	local targetOrigin	= target:GetAbsOrigin()

	local velocity = targetOrigin - casterOrigin

	-- Create a projectile
	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		vSpawnOrigin		= casterOrigin,
		fDistance			= velocity:Length2D(),
		fStartRadius		= lineRadius,
		fEndRadius			= lineRadius,
		Source				= caster,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= GameRules:GetGameTime() + tickInterval + 0.03,
		bDeleteOnHit		= false,
		vVelocity			= velocity / tickInterval,
	} )
end

--[[
	Author: Ractidous
	Date: 03.02.2015.
	Apply the slow debuff to the enemy unit.
	If the unit has already got slowed in current cast of Tether, just skip it.
]]
function OnProjectileHit( event )
	-- Variables
	local caster	= event.caster
	local target	= event.target	-- An enemy unit
	local ability	= event.ability

	-- Already got slowed
	if ability.tether_slowedUnits[target] then
		return
	end

	-- Apply slow debuff
	ability:ApplyDataDrivenModifier( caster, target, event.slow_modifier, {} )

	-- An enemy unit may only be slowed once per cast.
	-- We store the enemy unit to the hashset, so we can check whether the unit has got debuff already later on.
	ability.tether_slowedUnits[target] = true
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

function Track( keys )
	local caster = keys.caster
	local target = keys.target
	local targetLocation = target:GetAbsOrigin() 
	local ability = keys.ability
	local bonus_gold_self = ability:GetLevelSpecialValueFor("bonus_gold_self", (ability:GetLevel() - 1))
	local bonus_gold = ability:GetLevelSpecialValueFor("bonus_gold", (ability:GetLevel() - 1))
	local bonus_gold_radius = ability:GetLevelSpecialValueFor("bonus_gold_radius", (ability:GetLevel() - 1))

	-- Checks if the target is alive when the modifier is destroyed
	if not target:IsAlive() then

		-- Gives gold to the caster
		-- caster:ModifyGold(bonus_gold_self, true, 0)
		-- Finds all valid friendly heroes within the bonus gold radius
		local bonus_gold_targets = FindUnitsInRadius(caster:GetTeam() , targetLocation, nil, bonus_gold_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, 0, 0, false)

		-- Grants them gold but we must exclude the caster
		for i,v in ipairs(bonus_gold_targets) do
			if not (v == caster) then
				v:ModifyGold(bonus_gold, true, 0)
			end
		end
	end

	-- Remove the track aura from the target
	-- NOTE: Trying to do this in KV is not possible it seems
	target:RemoveModifierByName("modifier_track_aura_datadriven") 
end

function invisible_conquer(keys)
    local caster = keys.caster
	local ability = keys.ability
	local castOrg = caster:GetAbsOrigin()
	local enemyin = false
	units = FindUnitsInRadius(caster:GetTeam() , castOrg, nil, 1600, DOTA_UNIT_TARGET_TEAM_FRIENDLY , DOTA_UNIT_TARGET_HERO, 0, 0, false)
    enemyunits = FindUnitsInRadius(caster:GetTeam() , castOrg, nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for _,enemyunit in pairs(enemyunits) do
				enemydist = (enemyunit:GetAbsOrigin()-castOrg):Length2D()
					if enemydist < 700 then
					enemyin = true
					end
			end
	for _,unit in pairs(units) do
				dist = (unit:GetAbsOrigin()-castOrg):Length2D()
				if unit:GetTeamNumber()==caster:GetTeamNumber() then
					if dist < 700 and enemyin == false then
					unit:AddNewModifier(caster, ability, "modifier_invisible", {Duration = 3.0})					
					else 
					unit:RemoveModifierByName("modifier_invisible")
					end
				end
			end

	

		
end