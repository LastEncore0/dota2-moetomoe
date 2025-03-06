LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )
--[[
	梦幻召唤·基础系统
]]
function ModelSwapStart( keys )
	local caster = keys.caster
	local model = keys.model
	local ability = keys.ability
	local abilityname = ability:GetAbilityName()

	-- Returns the name of this ability.
	local projectile_model = keys.projectile_model
	local saber = caster:FindAbilityByName("saber")
	local lancer = caster:FindAbilityByName("lancer")
	local archer = caster:FindAbilityByName("archer")
	local rider = caster:FindAbilityByName("rider")
	local casterabili = caster:FindAbilityByName("caster")
	local assassin = caster:FindAbilityByName("assassin")

	
	local excalibur_illiya = caster:FindAbilityByName("excalibur_illiya")
	local avalon_illiya = caster:FindAbilityByName("avalon_illiya")
	local Zabaniya = caster:FindAbilityByName("Zabaniya")
	local Gae_Bolg = caster:FindAbilityByName("Gae_Bolg")
	local Rho_Aias = caster:FindAbilityByName("Rho_Aias")
	local Broken_Phantasm = caster:FindAbilityByName("Broken_Phantasm")
	local uninstall = caster:FindAbilityByName("uninstall")
	local Cybele = caster:FindAbilityByName("Cybele")
	local five_gun = caster:FindAbilityByName("five_gun")
	local rule_breaker = caster:FindAbilityByName("rule_breaker")
	
	local cooldown = uninstall:GetCooldown(uninstall:GetLevel() - 1)
	uninstall:StartCooldown(cooldown)
    caster:SetModelScale(2.1)
	-- Saves the original model and attack capability
	if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	print("abilityname",abilityname)
	if abilityname == "saber" then
	    caster:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
	elseif abilityname == "caster" then
	    caster:SetPrimaryAttribute(DOTA_ATTRIBUTE_INTELLECT)
	else
		caster:SetPrimaryAttribute(DOTA_ATTRIBUTE_AGILITY)
	end
	caster:SwapAbilities(uninstall:GetAbilityName(), "assassin", true, false) 
	
	rider:SetActivated(false)
	casterabili:SetActivated(false)
	assassin:SetActivated(false)
	saber:SetActivated(false)
	lancer:SetActivated(false)

	if abilityname == "saber" then
		caster:SwapAbilities("excalibur_illiya", "lancer", true, false) 
		caster:SwapAbilities("avalon_illiya", "archer", true, false) 
		excalibur_illiya:SetActivated(true)
		avalon_illiya:SetActivated(true)
	end

	if abilityname == "lancer" then
		caster:SwapAbilities("Gae_Bolg", "archer", true, false) 
		Gae_Bolg:SetActivated(true)
	end

	if abilityname == "archer" then
		caster:SwapAbilities("Rho_Aias", "lancer", true, false) 
		caster:SwapAbilities("Broken_Phantasm", "archer", true, false) 
		Rho_Aias:SetActivated(true)
		Broken_Phantasm:SetActivated(true)
	end

	if abilityname == "rider" then
		caster:SwapAbilities("Cybele", "archer", true, false) 
		Cybele:SetActivated(true)
	end

	if abilityname == "caster" then
		caster:SwapAbilities("five_gun", "lancer", true, false) 
		caster:SwapAbilities("rule_breaker", "archer", true, false) 
		five_gun:SetActivated(true)
		rule_breaker:SetActivated(true)
	end

	if abilityname == "assassin" then
		caster:SwapAbilities(Zabaniya:GetAbilityName(), "archer", true, false) 
		Zabaniya:SetActivated(true)
	end
	
	caster.caster_attack = caster:GetAttackCapability()
    caster.saber = true
	-- Sets the new model and projectile
	caster:SetOriginalModel(model)
	--caster:SetRangedProjectileName(projectile_model)
    
	-- Set this hero's primary attribute value.
	-- Sets the new attack type
	if abilityname ~= "caster" then
	    caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	else
		caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	    caster:SetRangedProjectileName(projectile_model)
	end
	-- caster:SwapAbilities(meelgun, doubleknifestrike, true, false) 

end

function uninstall( keys )
	local caster = keys.caster
	local model = keys.model
	local ability = keys.ability
	local abilityname = ability:GetAbilityName()
	-- Returns the name of this ability.
	local projectile_model = keys.projectile_model
    caster:SetModelScale(1.0)
	
	local saber = caster:FindAbilityByName("saber")
	local lancer = caster:FindAbilityByName("lancer")
	local archer = caster:FindAbilityByName("archer")
	local rider = caster:FindAbilityByName("rider")
	local casterabili = caster:FindAbilityByName("caster")
	local assassin = caster:FindAbilityByName("assassin")

	
	local excalibur_illiya = caster:FindAbilityByName("excalibur_illiya")
	local avalon_illiya = caster:FindAbilityByName("avalon_illiya")
	local Zabaniya = caster:FindAbilityByName("Zabaniya")
	local Gae_Bolg = caster:FindAbilityByName("Gae_Bolg")
	local Rho_Aias = caster:FindAbilityByName("Rho_Aias")
	local Broken_Phantasm = caster:FindAbilityByName("Broken_Phantasm")
	local uninstall = caster:FindAbilityByName("uninstall")
	local Cybele = caster:FindAbilityByName("Cybele")
	local five_gun = caster:FindAbilityByName("five_gun")
	local rule_breaker = caster:FindAbilityByName("rule_breaker")
	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)

	caster:SwapAbilities("assassin","uninstall", true, false) 
	saber:SetActivated(true)
	lancer:SetActivated(true)
	archer:SetActivated(true)
	rider:SetActivated(true)
	casterabili:SetActivated(true)
	assassin:SetActivated(true)
	if caster:HasModifier("modifier_saber") then
		caster:SwapAbilities("excalibur_illiya", "lancer", false, true) 
		caster:SwapAbilities("avalon_illiya", "archer", false, true)
	end
	
	if caster:HasModifier("modifier_lancer") then
		caster:SwapAbilities("Gae_Bolg", "archer", false, true)
		if Gae_Bolg:GetToggleState() == true then
		Gae_Bolg:ToggleAbility()
		end
		caster:RemoveModifierByName("modifier_Gae_Bolg")
	end	

    if caster:HasModifier("modifier_archer") then
		caster:SwapAbilities("Rho_Aias", "lancer", false, true)
		caster:SwapAbilities("Broken_Phantasm", "archer", false, true)
	end
	
	if caster:HasModifier("modifier_rider") then
		caster:SwapAbilities("Cybele", "archer", false, true)
    end
	
	if caster:HasModifier("modifier_caster") then
		caster:SwapAbilities("five_gun", "lancer", false, true)
		caster:SwapAbilities("rule_breaker", "archer", false, true)
    end
	
	if caster:HasModifier("modifier_assassin") then
		caster:SwapAbilities("Zabaniya", "archer", false, true)
    end

		caster:RemoveModifierByName("modifier_saber")
		caster:RemoveModifierByName("modifier_lancer")
		caster:RemoveModifierByName("modifier_archer")
		caster:RemoveModifierByName("modifier_caster")
		caster:RemoveModifierByName("modifier_rider")
		caster:RemoveModifierByName("modifier_assassin")

end

function LevelUpAbilityilliya( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()
	if event.ability_name_1 ~= nil then
	-- The ability to level up
	local ability_name_1 = event.ability_name_1
	
	local ability_handle_1 = caster:FindAbilityByName(ability_name_1)	
	if ability_handle_1 ~= nil then
	local ability_level_1 = ability_handle_1:GetLevel()
		
	-- Check to not enter a level up loop
	if ability_level_1 ~= this_abilityLevel then
		ability_handle_1:SetLevel(this_abilityLevel)
	end
end
end
   if event.ability_name_2 ~= nil then
	local ability_name_2 = event.ability_name_2
	local ability_handle_2 = caster:FindAbilityByName(ability_name_2)	
	local ability_level_2 = ability_handle_2:GetLevel()
	if ability_level_2 ~= this_abilityLevel then
		ability_handle_2:SetLevel(this_abilityLevel)
	end
  end
end


function ModelSwapEnd( keys )
	local caster = keys.caster
	local doubleknifestrike = "doubleknifestrike"
	local meelgun = "meelgun"
	caster.saber = nil
	caster:SetModelScale(1.2)
	caster:SetModel(caster.caster_model)
	caster:SetOriginalModel(caster.caster_model)
	caster:SetAttackCapability(caster.caster_attack)
	caster:SetPrimaryAttribute( DOTA_ATTRIBUTE_INTELLECT )
	--caster:SwapAbilities(doubleknifestrike, meelgun, true, false) 
end

function Gae (keys)
	
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local ManaCost = ability:GetManaCost(ability:GetLevel() - 1)
		local mana = caster:GetMana()
		-- Get the mana on this unit.
		if mana < ManaCost and ability:GetToggleState() == true then
			ability:ToggleAbility()
		end	
			
			EmitSoundOn("Hero_Spectre.Desolate", caster)
	
			local particle_name = "particles/units/heroes/illiya/gae_bolg.vpcf"
			local particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT, target)
			local pelel = caster:GetForwardVector()
			ParticleManager:SetParticleControl(particle, 0, Vector(     target:GetAbsOrigin().x,
																		target:GetAbsOrigin().y, 
																		GetGroundPosition(target:GetAbsOrigin(), target).z + 140))
																		
			ParticleManager:SetParticleControlForward(particle, 0, caster:GetForwardVector())
	
	end



function HideWearables( event )
	local hero = event.caster
	local ability = event.ability

	hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(hero.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( event )
	local hero = event.caster

	for i,v in pairs(hero.hiddenWearables) do
		v:RemoveEffects(EF_NODRAW)
	end
end
function stopattacksound( event )
	StopSoundOn("Hero_Juggernaut.BladeFuryStart",keys.caster)
end

--[[
	梦幻召唤·基础系统 end
]]

----避矢加护
function Dodge_Arrow(keys)
	local caster = keys.caster
	local ability = keys.ability
    local target = keys.attacker
	local damage = keys.damge
	local Dodge = ability:GetLevelSpecialValueFor("damage_Dodge", ability:GetLevel() -1)
	local min_distance = ability:GetLevelSpecialValueFor("min_distance", ability:GetLevel() -1)
	local target_location = target:GetAbsOrigin()
	local caster_location = caster:GetAbsOrigin()
	local distance = (target_location - caster_location):Length2D() 
	local random = RandomInt(0, 100)
	local heal = damage
    print("random =",random)
	if distance > min_distance then
		if Dodge > random then
	   caster:SetHealth(caster:GetHealth() + heal)
		end
	end
end

-------气息遮蔽
function Blur( keys )
	local caster = keys.caster
	local ability = keys.ability
	local casterLocation = caster:GetAbsOrigin()
	local radius = ability:GetLevelSpecialValueFor("min_distance", (ability:GetLevel() - 1))

	local enemyHeroes = FindUnitsInRadius(caster:GetTeam(), casterLocation, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
  if not caster:HasTalent("illiya_talent_2") then
	if #enemyHeroes>0 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_blur_enemy", {})
	else
		if caster:HasModifier("modifier_blur_enemy") then
			caster:RemoveModifierByName("modifier_blur_enemy")
		end
	end
  end
end

-------炽天覆七重圆环
function AphoticShield( event )
	-- Variables
	local caster = event.caster
	local max_damage_absorb = event.ability:GetLevelSpecialValueFor("damage_absorb", event.ability:GetLevel() - 1 )
	local talent = event.ability:GetLevelSpecialValueFor("talent", event.ability:GetLevel() - 1 )
	local shield_size = 130 -- could be adjusted to model scale
    local casterloc = caster:GetAbsOrigin()
	-- Reset the shield
	if caster:HasTalent("illiya_talent_3") then
	    caster.AphoticShieldRemaining = max_damage_absorb + talent 
	else
		caster.AphoticShieldRemaining = max_damage_absorb 
	end	


	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		caster.ShieldParticle = ParticleManager:CreateParticle("particles/units/heroes/illiya/rho_aias.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(caster.ShieldParticle, 0, casterloc)
		ParticleManager:SetParticleControl(caster.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 5, Vector(shield_size,0,0))
        ParticleManager:SetParticleControl(caster.ShieldParticle, 6, casterloc)

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(caster.ShieldParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end)
end

function GiveVision(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	
	AddFOWViewer(caster:GetTeam(), point, sight_radius, sight_duration, false)
end


function sanlian( event )
	local caster = event.caster
	local ability = event.ability
	if not caster:HasModifier("modifier_archer_cd") then
		if caster:HasModifier("modifier_archer_2") then
			if caster.lian == nil then
				caster.lian = 1
			elseif caster.lian == 2 then
				caster:RemoveModifierByName("modifier_archer_2")
				caster.lian = nil
			  else
				caster.lian = 2
			end
		else
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_archer_2", {} )
		end
	end
end


function AphoticShieldHealth( event )
	local caster = event.caster

	caster.OldHealth = caster:GetHealth()
end

function AphoticShieldAbsorb( event )
	-- Variables
	local caster = event.caster
	local damage = event.DamageTaken
	local unit = event.unit
	local ability = event.ability
	local modifierName = "modifier_Rho_Aias"
	local current_stack = caster:GetModifierStackCount( modifierName, ability )
	
	-- Track how much damage was already absorbed by the shield
	local shield_remaining = caster.AphoticShieldRemaining
	print("Shield Remaining: "..shield_remaining)
	print("Damage Taken pre Absorb: "..damage)
    print("Damage Taken pre Absorb: "..damage)
	-- Check if the unit has the borrowed time modifier

	  if current_stack > 1 then
		local sumshield = shield_remaining * current_stack
		if damage > sumshield then
			local newHealth = caster.OldHealth - damage + sumshield
			caster:RemoveModifierByName(modifierName) 
			caster:RemoveModifierByName("modifier_aphotic_shield")
			print("Old Health: "..unit.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..sumshield)
			unit:SetHealth(newHealth)
		else
			local newHealth = caster.OldHealth			
			unit:SetHealth(newHealth)
			local reduce = math.floor(damage / shield_remaining)
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
			caster:SetModifierStackCount( modifierName, ability, current_stack - reduce )
			print("Old Health: "..unit.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..sumshield)
        end
	  else
	    if damage > shield_remaining then
			local newHealth = caster.OldHealth - damage + shield_remaining
			caster:RemoveModifierByName(modifierName) 
			caster:RemoveModifierByName("modifier_aphotic_shield")
			print("Old Health: "..caster.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..shield_remaining)
			unit:SetHealth(newHealth)
		else
			local newHealth = caster.OldHealth			
			unit:SetHealth(newHealth)
			print("Old Health: "..caster.OldHealth.." - New Health: "..newHealth.." - Absorbed: "..damage)
		end
	  end

        
		if caster.AphoticShieldRemaining then
			print("Shield Remaining after Absorb: "..caster.AphoticShieldRemaining)
			print("---------------")
		end

end

function Rho_Aias(keys)
	local caster = keys.caster
	local ability = keys.ability 
	local modifierName = "modifier_Rho_Aias"
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, ability, 7 )
end

function EndShieldParticle( event )
	local caster = event.caster
	local modifierName = "modifier_Rho_Aias"
	caster:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
	ParticleManager:DestroyParticle(caster.ShieldParticle,false)
	caster:RemoveModifierByName(modifierName) 
end

--鲜血神殿

function RenderParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	

	
	ability.formation_particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.formation_particle, 0, point)
	ParticleManager:SetParticleControl(ability.formation_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.formation_particle, 2, point)
	
	ability.marker_particle = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.marker_particle, 0, point)
	ParticleManager:SetParticleControl(ability.marker_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.marker_particle, 2, point)
end

function GiveVision(keys)
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() -1)
	local vision_duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() -1)
	ability.center = keys.target_points[1]
	
	AddFOWViewer(caster:GetTeam(), ability.center, vision_radius, vision_duration, false)

	
	ability.field_particle = ParticleManager:CreateParticle("particles/units/heroes/illiya/invoker_sun_strike.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(ability.field_particle, 0, ability.center)
	ParticleManager:SetParticleControl(ability.field_particle, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(ability.field_particle, 2, ability.center)
end

function DestroyParticles(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability.center = target:GetAbsOrigin()
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() -1)
	local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local damageType = ability:GetAbilityDamageType()
	local modifierBuffName = "modifier_Blood_FortAndromeda"
	local modifierStackName = "modifier_Blood_FortAndromeda_stack"
	local modifierName
	if caster.stack == nil then
	caster.stack = 0
	caser.oldstack = 0
	else
	caser.oldstack = caster.stack
	end
	local units = FindUnitsInRadius( caster:GetTeamNumber(), ability.center, nil, radius,
	targetTeam, targetType, targetFlag, 0, false )
for k, v in pairs( units ) do
local damageTable =
{
	victim = v,
	attacker = caster,
	damage = 9999,
	damage_type = DAMAGE_TYPE_PURE
}
ApplyDamage( damageTable )
caster.stack = caster.stack + 1
end
caster:RemoveModifierByName(modifierStackName) 


for i = 0, caser.oldstack do
	print("Removing modifiers")
	caster:RemoveModifierByName(modifierBuffName)
end

	-- Always apply the stack modifier 
	ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})

	caster:SetModifierStackCount(modifierStackName, ability, caster.stack)

		-- Apply the new increased stack
		for i = 1, caster.stack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	ParticleManager:DestroyParticle(ability.field_particle, true)
	-- Stops the field sound
end

function buffend(keys)
	local caster = keys.caster
	caster.stack = 0
end

--石化魔眼
	function StoneGazeStart( keys )
		local caster = keys.caster
	
		caster.stone_gaze_table = {}
	end
	
	--[[Author: Pizzalol
		Date: 07.03.2015.
		Checks if the caster has the Stone Gaze modifier
		If the caster doesnt have the modifier then remove the debuff modifier from the target]]
	function StoneGazeSlow( keys )
		local caster = keys.caster
		local target = keys.target
		
		local modifier_caster = keys.modifier_caster
		local modifier_target = keys.modifier_target
	
		if not caster:HasModifier(modifier_caster) then
			target:RemoveModifierByNameAndCaster(modifier_target, caster)
		end
	end
	
	--[[Author: Pizzalol, math by BMD
		Date: 07.03.2015.
		Checks if the target is currently facing the caster
		then it checks if the target faced the caster before
		if the target did face the caster before then apply the counter modifier
		otherwise add the target as a new target]]
	function StoneGaze( keys )
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local ability_level = ability:GetLevel() - 1
	
		-- Modifiers
		local modifier_slow = keys.modifier_slow
		local modifier_facing = keys.modifier_facing
	
		-- Ability variables
		local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
		local vision_cone = ability:GetLevelSpecialValueFor("vision_cone", ability_level)
	
		-- Locations
		local caster_location = caster:GetAbsOrigin()
		local target_location = target:GetAbsOrigin()	
	
		-- Angle calculation
		local direction = (caster_location - target_location):Normalized()
		local forward_vector = target:GetForwardVector()
		local angle = math.abs(RotationDelta((VectorToAngles(direction)), VectorToAngles(forward_vector)).y)
		--print("Angle: " .. angle)
	
		-- Facing check
		if angle <= vision_cone/2 then
			local check = false
			-- Check if its a target from before
			for _,v in ipairs(caster.stone_gaze_table) do
				if v == target then
					check = true
				end
			end
	
			-- If its a target from before then apply the counter modifier for 2 frames
			if check then
				ability:ApplyDataDrivenModifier(caster, target, modifier_facing, {Duration = 0.06})
			else
				-- If its a new target then add it to the table
				table.insert(caster.stone_gaze_table, target)
				-- Set the facing time to 0
				target.stone_gaze_look = 0
				-- Set the petrification variable to false
				target.stone_gaze_stoned = false
	
				-- Apply the slow and counter modifiers
				ability:ApplyDataDrivenModifier(caster, target, modifier_slow, {Duration = duration})
				ability:ApplyDataDrivenModifier(caster, target, modifier_facing, {Duration = 0.06})
			end
		end
	end
	
	--
	function StoneGazeFacing( keys )
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local ability_level = ability:GetLevel() - 1
	
		-- Ability variables
		local face_duration = ability:GetLevelSpecialValueFor("face_duration", ability_level)
		local stone_duration = ability:GetLevelSpecialValueFor("stone_duration", ability_level)
		local modifier_stone = keys.modifier_stone
	
		target.stone_gaze_look = target.stone_gaze_look + 0.03
	
		-- If the target was facing the caster for more than the required time and wasnt petrified before
		-- then petrify it
		if target.stone_gaze_look >= face_duration and not target.stone_gaze_stoned then
			ability:ApplyDataDrivenModifier(caster, target, modifier_stone, {Duration = stone_duration})
			target.stone_gaze_stoned = true
		end
	end

	function GetlPoints(keys)
        -- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
        local radius = keys.Radius        
        local count = keys.Count
        local caster = keys.caster
        local ability = caster:FindAbilityByName("five_gun")
        local point = keys.target_points[1]
        local caster_location = caster:GetAbsOrigin()
        caster.axe_range = (point - caster_location):Length()
end
function ReimuPoints( keys)
        -- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
         local radius = keys.Radius       local count = keys.Count
        local caster = keys.caster
        local angle = 60 / count
        local angle_count = math.floor(count / 2) -- Number of axes for each direction
        -- 之后我们获取施法者，也就是火枪面向的单位向量，和他的原点
        -- 之后把他的面向单位向量*2000，乘出来的结果就是英雄所面向的
        -- 2000距离的向量，再加上原点的位置，那么得到的就是英雄前方2000的那个点。
        local caster_fv = caster:GetForwardVector()
        local caster_origin = caster:GetOrigin()
        local center = caster_origin + caster_fv * caster.axe_range
	local angle_left = QAngle(0, angle, 0) -- Rotation angle to the left
	local angle_right = QAngle(0, -angle, 0) -- Rotation angle to the right
        local renumber = 0 -- Rotation angle to the right
        print("castRange =",caster.axe_range)
        print("center",center)
        -- 我们要做的散弹是发射Count个弹片，所以我们就进行Count次循环
        -- 之后在center，也就是我们上面所计算出来的，英雄面前2000距离的位置
        -- 周围radius距离里面随机一个点，并把他放到result这个表里面去
	local target_point = center
	--[[ 
	local new_angle = QAngle(0,0,0) -- Rotation angle

        
	-- Create axes that spread to the right
	 
	for i = 1, count do
		-- Angle calculation		
		
                 if i == 1 then
                 caster.vec = center
		-- Calculate the new position after applying the angle and then get the direction of it	
                elseif count % 2 ~= 0 then
                new_angle.y = angle_right.y * (i - 1) / 2	
		caster.vec = RotatePosition(caster_origin, new_angle, center)
                else
                new_angle.y = angle_left.y * i / 2 
                caster.vec = RotatePosition(caster_origin, new_angle, center)
                end
                table.insert(result,caster.vec)
	end
	]]
        --PrintTable(table.insert)
		local result = {}
          for i = 1, count do
                -- 这里先使用一个RandomFloat来获取一个从0到半径值的随机半径
                --  之后用RandomVector函数来在这个半径的圆周上获取随机一个点，
                -- 这样最后得到的vec就是那么一个圆形范围里面的随机一个点了。
                --local random = RandomFloat(0, radius)
                local vec = center + RandomVector(radius)
                table.insert(result,vec)
        end
        PrintTable(table.insert)
        
        -- 之后我们把这个地点列表返回给KV
        -- 举一反三的话，我们也可以做出比如说，向周围三百六十度，每间隔60度的方向各释放一个线性投射物的东西
        -- 这个大家自己试验就好
        return result
end

function GenerateShrapnelPoints( keys)
        -- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
        local radius = keys.Radius or 400        local count = keys.Count
        local caster = keys.caster
 
        -- 之后我们获取施法者，也就是火枪面向的单位向量，和他的原点
        -- 之后把他的面向单位向量*2000，乘出来的结果就是英雄所面向的
        -- 2000距离的向量，再加上原点的位置，那么得到的就是英雄前方2000的那个点。
        local caster_fv = caster:GetForwardVector()
        local caster_origin = caster:GetOrigin()
        local center = caster_origin + caster_fv * 2000
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
                table.insert(result,vec)
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
        if not ( caster and point and ability ) then return end
        CreateDummyAndCastAbilityAtPosition(caster, "sniper_shrapnel", ability:GetLevel(), point, 30, false)
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
                        unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)
 
                        return unit
                end
        )
end


function intdamage( event )
	local caster = event.caster
	local ability = event.ability
	local target = event.target
	local modifierName = event.modifierName
	local ability_level = ability:GetLevel() - 1
	local int = ability:GetLevelSpecialValueFor("int", ability_level)
	local reduce = ability:GetLevelSpecialValueFor("reduce", ability_level)/100
	local intellect = caster:GetIntellect()
	local basedamage = ability:GetAbilityDamage()
	local intdamage = intellect * int
	local damage_table = {}
	if caster:HasTalent("illiya_talent_1") then
		ability.damage = intdamage + basedamage
	else
		ability.damage = basedamage
	end
	if target:HasModifier("modifier_five_gun_2") then
		ability.damagend = ability.damage * reduce
	  else
		ability.damagend = ability.damage
	  end
 	damage_table.victim = target
 	damage_table.attacker = caster
 	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = ability.damagend

	print(target:GetUnitName())

	
    ApplyDamage(damage_table)
	
	print("damage =", ability.damagend)
end

function rule_breaker( event )
	local target = event.target

	-- Strong Dispel
	local RemovePositiveBuffs = true
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = true
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end
---百般精通
function Proficient_all( event )
 local caster = event.caster
   if caster:HasModifier("modifier_Proficient_str") then
	caster:RemoveModifierByName("modifier_Proficient_str")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_Proficient_agi", {})
   elseif caster:HasModifier("modifier_Proficient_agi") then
	caster:RemoveModifierByName("modifier_Proficient_agi")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_Proficient_int", {})
   elseif caster:HasModifier("modifier_Proficient_int") then
	caster:RemoveModifierByName("modifier_Proficient_int")
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_Proficient_str", {})
   else
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_Proficient_str", {})
   end
end
---妄想幻象
function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster 
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin()
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )
	local stroutgoingDamage = ability:GetLevelSpecialValueFor( "strillusion_outgoing_damage", ability:GetLevel() - 1 )
	local strincomingDamage = ability:GetLevelSpecialValueFor( "strillusion_incoming_damage", ability:GetLevel() - 1 )
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))
	local Proficient = RandomInt(1, 5)
	local model = caster:GetModelName()
	
	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
		-- handle_UnitOwner needs to be nil, else it will crash the game.
			local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
			illusion:SetPlayerID(caster:GetPlayerID())
			illusion:SetControllableByPlayer(player, true)
			illusion:SetModelScale(2.1)
			illusion:SetOriginalModel(model)
			illusion:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
			local assassin = illusion:FindAbilityByName("assassin")
			assassin:ApplyDataDrivenModifier(illusion, illusion, "modifier_assassin", {})
			-- Level Up the unit to the casters level
			local casterLevel = caster:GetLevel()
			for i=1,casterLevel-1 do
				illusion:HeroLevelUp(false)
			end
		
			-- Set the skill points to 0 and learn the skills of the caster
			illusion:SetAbilityPoints(0)
			for abilitySlot=0,15 do
				local ability = caster:GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					local illusionAbility = illusion:FindAbilityByName(abilityName)
					illusionAbility:SetLevel(abilityLevel)
				end
			end
		
			-- Recreate the items of the caster
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					local newItem = CreateItem(itemName, illusion, illusion)
					illusion:AddItem(newItem)
				end
			end
		
			-- Set the unit as an illusion
			-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
			if Proficient == 1 then
				illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = strincomingDamage })
			elseif Proficient == 2 then
				illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = stroutgoingDamage, incoming_damage = incomingDamage })
			elseif Proficient == 3 then
				illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
				ability:ApplyDataDrivenModifier(caster, illusion, "modifier_Proficient_str", {})
			elseif Proficient == 4 then
				illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
				ability:ApplyDataDrivenModifier(caster, illusion, "modifier_Proficient_agi", {})
			elseif Proficient == 5 then
				illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
				ability:ApplyDataDrivenModifier(caster, illusion, "modifier_Proficient_int", {})
			end
			-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
			illusion:MakeIllusion()


end